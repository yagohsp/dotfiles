#!/usr/bin/env bash

set -euo pipefail

script_dir="$(dirname "$0")"
list_script="$script_dir/list-output-device-volumes.sh"

emit() {
  "$list_script"
}

emit

pactl subscribe 2>/dev/null | while IFS= read -r event; do
  case "$event" in
    *"on sink "*|*"on server "*|*"on card "*)
      emit
      ;;
  esac
done
