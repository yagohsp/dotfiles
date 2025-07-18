#!/bin/bash

games_json=$(lutris -l --json)

choices=$(echo "$games_json" | jq -r '.[] | [.name, .icon] | @tsv' | while IFS=$'\t' read -r name icon; do
    # Replace marker with actual special characters
    echo -e "${name}\0icon\x1f${icon}"
done)

selected=$(echo -e "$choices" | rofi -dmenu -markup-rows -p "Lutris Games")

game=$(echo -e "$selected" | cut -d$'\0' -f1)

if [[ -n "$game" ]]; then
    lutris lutris:rungame/"$game" &
fi
