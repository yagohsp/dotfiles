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

outputs_json="$(jq -c '[ .[] | select(.type == "sink") ]' "$outputs_file")"
sinks_json="$(pactl -f json list sinks)"

jq -cn \
  --argjson outputs "$outputs_json" \
  --argjson sinks "$sinks_json" '
  $outputs
  | map(
      . as $output
      | ([ $sinks[] | select(.name == $output.sink_name) ][0] // null) as $sink
      | select($sink != null)
      | $output + {
          muted: ($sink.mute // false),
          volume: (($sink.volume["front-left"].value_percent // $sink.volume["aux0"].value_percent // "0%") | rtrimstr("%") | tonumber)
        }
    )
'
