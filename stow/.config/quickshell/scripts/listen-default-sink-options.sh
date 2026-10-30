#!/usr/bin/env bash

set -euo pipefail

script_dir="$(dirname "$0")"
list_script="$script_dir/list-default-sink-options.sh"

emit() {
  "$list_script"
}

until pactl info >/dev/null 2>&1; do
  sleep 0.5
done

emit

pactl subscribe 2>/dev/null | while IFS= read -r event; do
  case "$event" in
    *"on sink "*|*"on server "*|*"on card "*)
      emit
      ;;
  esac
done
