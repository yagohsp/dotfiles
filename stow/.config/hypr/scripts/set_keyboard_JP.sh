#!/bin/bash

keyboard_language=$(fcitx5-remote -n)
if [ "$keyboard_language" = 'keyboard-us' ]; then
    fcitx5-remote -s mozc
    pkill -SIGRTMIN+12 waybar
else
    fcitx5-remote -s keyboard-us
    pkill -SIGRTMIN+12 waybar
fi



