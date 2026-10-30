#!/usr/bin/env bash

set -uo pipefail

pid=$(pgrep -xo quickshell 2>/dev/null || true)
[ -n "$pid" ] || exit 1

best=
best_area=0

for wid in $(xdotool search --pid "$pid" 2>/dev/null); do
  [ -n "$wid" ] || continue
  read -r w h < <(
    xdotool getwindowgeometry --shell "$wid" 2>/dev/null \
      | awk -F= '/^WIDTH=/ {w=$2} /^HEIGHT=/ {h=$2} END {print w, h}'
  )
  [ -n "${w:-}" ] && [ -n "${h:-}" ] || continue
  # Bar strip is 44px; full-screen backdrops are taller than popups.
  if [ "$w" -lt 300 ] || [ "$h" -lt 100 ] || [ "$h" -gt 800 ]; then
    continue
  fi
  area=$((w * h))
  if [ "$area" -gt "$best_area" ]; then
    best=$wid
    best_area=$area
  fi
done

if [ -n "$best" ]; then
  xdotool windowfocus --sync "$best" 2>/dev/null || xdotool windowactivate --sync "$best" 2>/dev/null
  exit 0
fi

exit 1
