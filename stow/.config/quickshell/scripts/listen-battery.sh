#!/usr/bin/env bash

set -euo pipefail

script_dir="$(dirname "$0")"
emit_script="$script_dir/get-battery.sh"

emit() {
  "$emit_script"
}

emit

upower --monitor 2>/dev/null | while IFS= read -r _; do
  emit
done
