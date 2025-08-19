#!/bin/bash

keyboard_language=$(fcitx5-remote -n)

if [ "$keyboard_language" = 'keyboard-us' ]; then
    fcitx5-remote -s keyboard-us-intl
    sleep 10
    fcitx5-remote -s keyboard-us
else
    fcitx5-remote -s keyboard-us
fi
