#!/usr/bin/env sh

set -eu

bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -n "$bat" ] || exit 0

capacity=$(cat "$bat/capacity" 2>/dev/null) || exit 0
status=$(cat "$bat/status" 2>/dev/null) || status="Unknown"

plugged=0
for p in /sys/class/power_supply/*/; do
  t=$(cat "$p/type" 2>/dev/null) || continue
  case "$t" in
    Mains|USB) ;;
    *) continue ;;
  esac
  o=$(cat "$p/online" 2>/dev/null) || continue
  if [ "$o" = "1" ]; then
    plugged=1
    break
  fi
done

printf '%s,%s,%s\n' "$capacity" "$status" "$plugged"
