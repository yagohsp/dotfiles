#!/usr/bin/env bash

set -euo pipefail

stream_index="$1"
sink_name="$2"

[[ -n "$stream_index" && -n "$sink_name" ]] || exit 1

object_id="$(pactl -f json list sink-inputs | jq -r --arg idx "$stream_index" '.[] | select(.index == ($idx | tonumber)) | .properties["object.id"] // empty')"
sink_props="$(pactl -f json list sinks | jq -r --arg name "$sink_name" '.[] | select(.name == $name) | .properties | "\(.["object.id"] // "")\t\(.["object.serial"] // "")"')"
node_id="$(cut -f1 <<< "$sink_props")"
node_serial="$(cut -f2 <<< "$sink_props")"

[[ -n "$object_id" && -n "$node_id" && -n "$node_serial" ]] || exit 1

# pactl move-sink-input writes target.node/target.object as -1 ("no override") when the
# stream is already on the requested sink, which looks pinned but isn't and emits no
# subscribe event. Pin explicitly via pw-metadata so the pin is real and the UI refreshes.
#
# target.node is matched against the node's PipeWire global id (== object.id), but
# target.object is matched against object.serial — a *different* counter that only
# coincidentally equals object.id for some nodes. Passing object.id for both works for
# those nodes but silently fails to resolve (and falls back to the default sink) for
# nodes where the two diverge — e.g. this card's "pro-output-*" sinks.
pactl move-sink-input "$stream_index" "$sink_name" >/dev/null 2>&1 || true
pw-metadata "$object_id" target.node "$node_id" >/dev/null
pw-metadata "$object_id" target.object "$node_serial" >/dev/null

# pactl subscribe fires no event when the stream is already on the target sink, so
# listen-stream-routes.sh never re-emits. Do a no-op mute set (current value → same value)
# which fires a "change! sink-input" event and wakes up the listener.
_muted="$(pactl -f json list sink-inputs | jq -r --arg idx "$stream_index" \
  '.[] | select(.index == ($idx | tonumber)) | .mute')"
pactl set-sink-input-mute "$stream_index" "${_muted:-false}" 2>/dev/null || true
