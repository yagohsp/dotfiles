#!/bin/bash

# Update system with paru and shutdown
# Opens a terminal to run paru update, then shuts down

# Use your terminal emulator (kitty, alacritty, etc.)
kitty --title "System Update" bash -c "paru -Syu --noconfirm && echo 'Update complete. Shutting down in 5 seconds...' && sleep 5 && systemctl poweroff" &
