#!/usr/bin/env bash
fifo="/tmp/qs-lock"
[ -p "$fifo" ] || mkfifo "$fifo"
echo "lock" > "$fifo" &
disown
