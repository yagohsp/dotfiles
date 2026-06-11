#!/usr/bin/env bash
set -euo pipefail

fifo="/tmp/qs-osd"
[ -p "$fifo" ] || mkfifo "$fifo"

echo "$(pamixer --get-volume):$(pamixer --get-mute)" > "$fifo" &
disown
