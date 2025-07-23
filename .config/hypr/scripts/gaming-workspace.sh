#!/bin/bash

active_window=$(hyprctl activewindow -j | jq -r '.workspace.name')

hyprctl dispatch togglespecialworkspace gaming

if [ "$active_window" = "special:gaming" ]; then
  pkill -f hyprland-cursor-lock
else
  hyprland-cursor-lock
fi

