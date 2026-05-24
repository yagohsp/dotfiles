#!/usr/bin/env bash

set -euo pipefail

outputs_file="$HOME/dotfiles/configs/eww/.config/audio/outputs.json"
refresh_script="$HOME/dotfiles/scripts/refresh-audio-outputs"

if [[ ! -r "$outputs_file" && -x "$refresh_script" ]]; then
  "$refresh_script" >/dev/null
fi

if [[ ! -r "$outputs_file" ]]; then
  printf 'Unknown\n'
  exit 0
fi

default_sink="$(pactl get-default-sink)"
current_profile="$(pactl -f json list sinks | jq -r --arg sink "$default_sink" '
  first(.[] | select(.name == $sink) | .properties["device.profile.name"]) // ""
')"

jq -r --arg sink "$default_sink" --arg profile "$current_profile" '
  first(
    .[]
    | select(
        (.type == "sink" and (.sink_name // "") == $sink)
        or (.type == "profile" and (.sink_profile // "") == $profile)
      )
    | .name
  ) // "Unknown"
' "$outputs_file"
