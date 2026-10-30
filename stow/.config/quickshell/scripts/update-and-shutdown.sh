#!/bin/bash

# Update system with paru and shutdown
# Opens a terminal to run paru update, then shuts down.
# Clears a stale pacman lock first; on failure the window stays open instead of powering off.

LOCK=/var/lib/pacman/db.lck

# Re-run this script inside a terminal (kitty, alacritty, etc.)
if [ "$1" != "--in-terminal" ]; then
    kitty --title "System Update" bash "$0" --in-terminal &
    exit 0
fi

fail() {
    echo
    echo "Update failed — NOT shutting down. $1"
    read -rp "Press Enter to close..."
    exit 1
}

if [ -e "$LOCK" ]; then
    if pgrep -x pacman >/dev/null; then
        fail "pacman is running in another process; let it finish and try again."
    fi
    echo "Stale pacman lock found (created $(stat -c %y "$LOCK" | cut -d. -f1)), no pacman is running."
    read -rp "Remove it and continue? [Y/n] " ans
    case "$ans" in
        [nN]*) fail "Lock left in place." ;;
    esac
    sudo rm -f "$LOCK" || fail "Could not remove $LOCK."
fi

paru -Syu --noconfirm || fail "paru exited with status $?."

echo "Update complete. Shutting down in 5 seconds... (Ctrl+C to cancel)"
sleep 5
pkill obs
systemctl poweroff
