#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"

[[ -n "$stream_index" ]] || exit 1

exec pactl set-sink-input-mute "$stream_index" toggle
