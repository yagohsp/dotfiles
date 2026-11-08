#!/usr/bin/env bash
# Keyboard focus for the override-redirect overlay, which i3 never focuses itself.
#
#   x11-focus.sh grab <pid> <x> <y> <w> <h>   focus the overlay, print the previous focus
#   x11-focus.sh release <window>             give focus back to <window>
set -u

case "${1:-}" in
grab)
    pid=$2 x=$3 y=$4 w=$5 h=$6
    previous=$(xdotool getwindowfocus)
    for id in $(xdotool search --pid "$pid" 2>/dev/null); do
        geometry=$(xdotool getwindowgeometry --shell "$id" | tr '\n' ' ')
        case "$geometry" in
        *"X=$x Y=$y WIDTH=$w HEIGHT=$h "*)
            xdotool windowfocus "$id"
            echo "$previous"
            exit 0
            ;;
        esac
    done
    echo "x11-focus: overlay window not found" >&2
    exit 1
    ;;
release)
    xdotool windowfocus "$2"
    ;;
*)
    echo "usage: x11-focus.sh grab <pid> <x> <y> <w> <h> | release <window>" >&2
    exit 2
    ;;
esac
