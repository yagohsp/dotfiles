#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"

[[ -n "$stream_index" ]] || exit 1

object_id="$(pactl -f json list sink-inputs | jq -r --arg idx "$stream_index" '.[] | select(.index == ($idx | tonumber)) | .properties["object.id"] // empty')"

[[ -n "$object_id" ]] || exit 1

pw-metadata -d "$object_id" target.node >/dev/null
pw-metadata -d "$object_id" target.object >/dev/null

default_sink="$(pactl get-default-sink)"
pactl move-sink-input "$stream_index" "$default_sink" 2>/dev/null || true

# No-op mute set to fire a "change! sink-input" subscribe event so the listener re-emits.
_muted="$(pactl -f json list sink-inputs | jq -r --arg idx "$stream_index" \
  '.[] | select(.index == ($idx | tonumber)) | .mute')"
pactl set-sink-input-mute "$stream_index" "${_muted:-false}" 2>/dev/null || true
