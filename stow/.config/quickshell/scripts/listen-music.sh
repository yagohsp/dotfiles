#!/usr/bin/env bash

set -uo pipefail

script_dir="$(dirname "$0")"
player="$script_dir/music-player.py"

while true; do
  "$player" status
  printf '%s\n' "---"
  sleep 1
done
