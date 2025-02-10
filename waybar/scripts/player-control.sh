#!/bin/sh

player_status=$(playerctl status 2> /dev/null)
if [ "$player_status" = "Playing" ]; then
    echo $1
elif [ "$player_status" = "Paused" ]; then
    echo $2
else
    echo ""
fi
