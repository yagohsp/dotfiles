#!/bin/bash

hyprctl keyword cursor:inactive_timeout 0.0001
sleep .1
wayfreeze &
sleep .1
hyprctl keyword cursor:inactive_timeout 0

screenshot_file="$HOME/Downloads/$(date +'%Y-%m-%d_%H-%M-%S').png"

grim -g "$(slurp -d)" "$screenshot_file"

tee >(wl-copy < "$screenshot_file") < "$screenshot_file"

pkill wayfreeze
