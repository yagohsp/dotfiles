#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"

[[ -n "$stream_index" ]] || exit 1

object_id="$(pactl -f json list sink-inputs | jq -r --arg idx "$stream_index" '.[] | select(.index == ($idx | tonumber)) | .properties["object.id"] // empty')"

[[ -n "$object_id" ]] || exit 1

pw-metadata -d "$object_id" target.node >/dev/null
pw-metadata -d "$object_id" target.object >/dev/null
