#!/usr/bin/env bash

print_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub("%","",$5); print $5; exit}'
}

print_volume

pactl subscribe | while read -r event; do
  if echo "$event" | grep -q "sink"; then
    print_volume
  fi
done
