#!/usr/bin/env sh

set -eu

dev=$(ls /sys/class/backlight 2>/dev/null | head -n1)
[ -n "$dev" ] || exit 0
[ -w "/sys/class/backlight/$dev/brightness" ] || exit 0

current=$(cat "/sys/class/backlight/$dev/brightness")
max=$(cat "/sys/class/backlight/$dev/max_brightness")
[ "$max" -gt 0 ] || exit 0

printf '%d\n' "$((current * 100 / max))"
