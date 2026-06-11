#!/usr/bin/env bash

set -euo pipefail

outputs_file="$HOME/dotfiles/configs/eww/.config/audio/outputs.json"
refresh_script="$HOME/dotfiles/scripts/refresh-audio-outputs"

if [[ -x "$refresh_script" ]]; then
  "$refresh_script" >/dev/null
fi

if [[ ! -r "$outputs_file" ]]; then
  printf '[]\n'
  exit 0
fi

default_sink="$(pactl get-default-sink)"

jq -c --arg default_sink "$default_sink" '
  [ .[] | select(.type == "sink") | {
      name,
      display_name,
      sink_name,
      is_default: (.sink_name == $default_sink)
    } ]
' "$outputs_file"
