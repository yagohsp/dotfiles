#!/bin/bash

sleep 1

VIDEOS=~/Videos

# Find most recently added file (by modification time)
file_time=$(find "$VIDEOS" -type f -printf '%T@ %p\n' | sort -nr | head -n1 | awk '{print $1}')

if [ -z "$file_time" ]; then
  exit 0 
fi

now=$(date +%s)
file_time="${file_time%.*}"

if (( now - file_time < 10 )); then
  notify-send "Clipe salvo!"
fi
