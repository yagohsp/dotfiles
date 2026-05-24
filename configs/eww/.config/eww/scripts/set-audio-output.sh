#!/usr/bin/env bash

set -euo pipefail

output_json="$1"
type="$(jq -r '.type // ""' <<< "$output_json")"

move_all_inputs() {
  local sink_name="$1"
  local input_index

  while IFS= read -r input_index; do
    [[ -n "$input_index" ]] || continue
    pactl move-sink-input "$input_index" "$sink_name"
  done < <(pactl -f json list sink-inputs | jq -r '.[].index')
}

case "$type" in
  sink)
    sink_name="$(jq -r '.sink_name // ""' <<< "$output_json")"
    [[ -n "$sink_name" ]] || exit 1
    pactl set-default-sink "$sink_name"
    move_all_inputs "$sink_name"
    ;;
  profile)
    card_name="$(jq -r '.card_name // ""' <<< "$output_json")"
    profile="$(jq -r '.profile // ""' <<< "$output_json")"
    sink_profile="$(jq -r '.sink_profile // ""' <<< "$output_json")"

    [[ -n "$card_name" && -n "$profile" && -n "$sink_profile" ]] || exit 1

    pactl set-card-profile "$card_name" "$profile"

    for _ in {1..20}; do
      sink_name="$(pactl -f json list sinks | jq -r --arg card "$card_name" --arg profile "$sink_profile" '
        first(
          .[]
          | select(
              (.properties["device.name"] // "") == $card
              and (.properties["device.profile.name"] // "") == $profile
            )
          | .name
        ) // ""
      ')"

      if [[ -n "$sink_name" ]]; then
        pactl set-default-sink "$sink_name"
        move_all_inputs "$sink_name"
        exit 0
      fi

      sleep 0.1
    done

    exit 1
    ;;
esac
