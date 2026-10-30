#!/usr/bin/env bash

set -euo pipefail

script_dir="$(dirname "$0")"
emit_script="$script_dir/list-wifi-networks.sh"

emit() {
  "$emit_script"
  printf '%s\n' "---"
}

emit

nmcli monitor 2>/dev/null | while IFS= read -r _; do
  emit
done
