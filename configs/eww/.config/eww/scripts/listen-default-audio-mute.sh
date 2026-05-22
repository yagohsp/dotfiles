#!/bin/bash

pactl subscribe | while read -r line; do
    if echo "$line" | grep -q "sink"; then
        pactl get-sink-mute @DEFAULT_SINK@ | awk -F': ' '{print $2}'
    fi
done
