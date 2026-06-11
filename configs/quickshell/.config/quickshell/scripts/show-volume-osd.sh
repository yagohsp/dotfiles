#!/usr/bin/env bash
set -euo pipefail

# Signal QuickShell's VolumeOsd via FIFO
fifo="/tmp/qs-osd"
[ -p "$fifo" ] || mkfifo "$fifo"

echo "$(pamixer --get-volume):$(pamixer --get-mute)" > "$fifo" &
disown
