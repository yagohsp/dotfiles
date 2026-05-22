#!/bin/bash

output_json="$1"

name=$(echo "$output_json" | jq -r '.name')
type=$(echo "$output_json" | jq -r '.type')

if [ "$type" = "sink" ]; then
    id=$(echo "$output_json" | jq -r '.id')
    wpctl set-default "$id"
elif [ "$type" = "profile" ]; then
    card=$(echo "$output_json" | jq -r '.card')
    profile=$(echo "$output_json" | jq -r '.profile')
    wpctl set-profile "$card" "$profile"
    sleep 0.2
    # Get HDMI sink and set as default
    hdmi_id=$(wpctl status | grep "GA104.*HDMI" | awk '{print $2}' | tr -d '. *')
    if [ -n "$hdmi_id" ]; then
        wpctl set-default "$hdmi_id"
    fi
fi
