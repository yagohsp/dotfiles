#!/bin/sh

keyboard_language=$(hyprctl devices -j | grep -B 5 '"main": true' | grep variant | awk -F ': ' '{print $2}')
if [ "$keyboard_language" = '"intl",' ]; then
    echo "BR"
else
    echo "EN"
fi

echo $keyboard_language
