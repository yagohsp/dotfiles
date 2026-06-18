#!/usr/bin/env bash
set -euo pipefail

fifo="/tmp/qs-osd"
[ -p "$fifo" ] || mkfifo "$fifo"

wpctl_out="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
volume="$(echo "$wpctl_out" | awk '{printf "%d", $2 * 100}')"
muted="$(echo "$wpctl_out" | grep -q '\[MUTED\]' && echo true || echo false)"

echo "${volume}:${muted}" > "$fifo" &
disown
