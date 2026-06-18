#!/usr/bin/env bash
fifo="/tmp/qs-volume-modal"
[ -p "$fifo" ] || mkfifo "$fifo"
echo "toggle" > "$fifo" &
disown
