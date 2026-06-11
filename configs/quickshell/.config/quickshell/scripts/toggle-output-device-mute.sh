#!/usr/bin/env bash

set -euo pipefail

output_json="$1"
sink_name="$(jq -r '.sink_name // ""' <<< "$output_json")"

[[ -n "$sink_name" ]] || exit 1

exec pactl set-sink-mute "$sink_name" toggle
