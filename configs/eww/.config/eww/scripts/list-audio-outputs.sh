#!/usr/bin/env bash

set -euo pipefail

outputs_file="$HOME/dotfiles/configs/eww/.config/audio/outputs.json"
refresh_script="$HOME/dotfiles/scripts/refresh-audio-outputs"

if [[ ! -r "$outputs_file" && -x "$refresh_script" ]]; then
  "$refresh_script" >/dev/null
fi

if [[ -r "$outputs_file" ]]; then
  exec jq -c '.' "$outputs_file"
fi

printf '[]\n'
