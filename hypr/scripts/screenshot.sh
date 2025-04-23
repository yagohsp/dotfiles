#!/bin/bash

wayfreeze &
sleep .1

screenshot_file=$(mktemp)

grim -g "$(slurp -d)" "$screenshot_file"

tee >(wl-copy < "$screenshot_file") < "$screenshot_file"

pkill wayfreeze

rm "$screenshot_file"
