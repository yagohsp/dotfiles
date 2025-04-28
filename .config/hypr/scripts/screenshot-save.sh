#!/bin/bash

wayfreeze &
sleep .1

screenshot_file="$HOME/Downloads/$(date +'%Y-%m-%d_%H-%M-%S').png"

grim -g "$(slurp -d)" "$screenshot_file"

tee >(wl-copy < "$screenshot_file") < "$screenshot_file"

pkill wayfreeze
