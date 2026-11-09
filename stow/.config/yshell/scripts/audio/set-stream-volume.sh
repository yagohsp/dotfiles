#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"
volume="$2"

[[ -n "$stream_index" && -n "$volume" ]] || exit 1

exec pactl set-sink-input-volume "$stream_index" "${volume}%"
