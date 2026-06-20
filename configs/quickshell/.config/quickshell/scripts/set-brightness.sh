#!/usr/bin/env sh

set -eu

percent=${1:?usage: set-brightness.sh <0-100>}
dev=$(ls /sys/class/backlight 2>/dev/null | head -n1)
[ -n "$dev" ] || exit 0

max=$(cat "/sys/class/backlight/$dev/max_brightness")
raw=$((percent * max / 100))
[ "$raw" -ge 0 ] || raw=0
[ "$raw" -le "$max" ] || raw=$max

printf '%d' "$raw" > "/sys/class/backlight/$dev/brightness"
