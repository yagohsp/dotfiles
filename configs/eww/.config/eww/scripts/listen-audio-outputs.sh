#!/usr/bin/env bash

print_sinks() {
  pactl --format=json list sink-inputs 2>/dev/null | \
  jq -c '[.[] | {
    id: .sink,
    name: .properties["application.name"],
    volume: (.volume["front-left"].value_percent | rtrimstr("%") | tonumber)
  }]' 2>&1 | grep -v "Invalid ASCII"
}

print_sinks

pactl subscribe 2>/dev/null | grep --line-buffered "sink-input" | while read -r event; do
  print_sinks
done
