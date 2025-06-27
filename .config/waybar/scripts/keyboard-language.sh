#!/bin/sh

keyboard_language=$(fcitx5-remote -n)
if [ "$keyboard_language" = 'keyboard-us-intl' ]; then
    echo "BR"
elif [ "$keyboard_language" = 'keyboard-us' ]; then
    echo "EN"
else
    echo "JP"
fi

echo $keyboard_language
