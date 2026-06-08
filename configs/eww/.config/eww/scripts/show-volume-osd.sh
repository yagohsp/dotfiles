#!/usr/bin/env bash

set -euo pipefail

window="volume-osd"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/eww-volume-osd"
mkdir -p "$state_dir"
pid_file="$state_dir/hide.pid"

volume="$(pamixer --get-volume)"
muted="$(pamixer --get-mute)"

eww update volume_osd_value="$volume" volume_osd_muted="$muted"

if ! eww active-windows | grep -q "^$window:"; then
  eww open "$window"
fi

if [[ -f "$pid_file" ]]; then
  kill "$(cat "$pid_file")" 2>/dev/null || true
fi

(
  sleep 1.4
  eww close "$window"
  rm -f "$pid_file"
) &
disown
echo $! > "$pid_file"
