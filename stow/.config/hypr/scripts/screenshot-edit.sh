#!/bin/bash

hyprctl keyword cursor:inactive_timeout 0.0001
sleep .1
wayfreeze &
sleep .1
hyprctl keyword cursor:inactive_timeout 0

screenshot_file=$(mktemp)

grim -g "$(slurp -d)" "$screenshot_file"

tee >(wl-copy < "$screenshot_file") < "$screenshot_file"

pkill wayfreeze

pinta "$screenshot_file"

rm "$screenshot_file"
