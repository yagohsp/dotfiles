#!/usr/bin/env bash

set -euo pipefail

output_json="$1"
volume="$2"
sink_name="$(jq -r '.sink_name // ""' <<< "$output_json")"

[[ -n "$sink_name" ]] || exit 1

exec pactl set-sink-volume "$sink_name" "${volume}%"
