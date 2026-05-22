#!/usr/bin/env bash

get_default_sink() {
  pactl info | awk -F': ' '/Default Sink/ {print $2}'
}

last=""

update() {
  current=$(get_default_sink)
  if [[ "$current" != "$last" ]]; then
    if [[  "$current" == *"hdmi"* ]]; then
      echo "monitor"
    else
      echo "headset"
    fi
    last="$current"
  fi
}

# print initial value
update

pactl subscribe | while read -r line; do
  if echo "$line" | grep -q "sink\|server"; then
    update
  fi
done
