#!/usr/bin/env bash

set -uo pipefail

script_dir="$(dirname "$0")"
emit_script="$script_dir/refresh-calendar.sh"

"$emit_script"

while true; do
  sleep 300
  "$emit_script"
done
