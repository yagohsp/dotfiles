#!/usr/bin/env sh

set -eu

command -v nmcli >/dev/null 2>&1 || exit 0
nmcli -t -f TYPE device status 2>/dev/null | grep -q '^wifi$' || exit 0

if [ "$(nmcli -g WIFI general status 2>/dev/null)" != "enabled" ]; then
  printf 'off,,\n'
  exit 0
fi

active=$(nmcli -t -e no -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes:' | head -n1)

if [ -z "$active" ]; then
  printf 'disconnected,,\n'
  exit 0
fi

ssid=$(printf '%s' "$active" | cut -d: -f2)
signal=$(printf '%s' "$active" | cut -d: -f3)
printf 'connected,%s,%s\n' "$ssid" "$signal"
