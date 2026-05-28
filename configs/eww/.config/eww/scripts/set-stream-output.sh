#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"
sink_name="$2"

[[ -n "$stream_index" && -n "$sink_name" ]] || exit 1

exec pactl move-sink-input "$stream_index" "$sink_name"
