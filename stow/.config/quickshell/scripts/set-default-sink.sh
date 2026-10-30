#!/usr/bin/env bash

set -euo pipefail

sink_name="$1"

[[ -n "$sink_name" ]] || exit 1

pactl set-default-sink "$sink_name"
