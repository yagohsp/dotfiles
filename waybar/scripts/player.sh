#!/bin/sh

player_status=$(playerctl status 2> /dev/null)
icon="󰎇"
if [ "$player_status" = "Playing" ]; then
    echo "${icon}  $(playerctl metadata artist) - $(playerctl metadata title)"
elif [ "$player_status" = "Paused" ]; then
    echo "${icon}  $(playerctl metadata artist) - $(playerctl metadata title)"
else
    echo "${icon}  Nothing playing"
fi
