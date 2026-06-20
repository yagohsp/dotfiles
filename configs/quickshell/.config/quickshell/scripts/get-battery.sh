#!/usr/bin/env sh

set -eu

bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -n "$bat" ] || exit 0

capacity=$(cat "$bat/capacity" 2>/dev/null) || exit 0
status=$(cat "$bat/status" 2>/dev/null) || status="Unknown"

printf '%s,%s\n' "$capacity" "$status"
