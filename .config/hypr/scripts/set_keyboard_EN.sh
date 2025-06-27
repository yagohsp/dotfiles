#!/bin/bash

fcitx5-remote -s keyboard-us-intl
pkill -SIGRTMIN+12 waybar

sleep 15

fcitx5-remote -s keyboard-us
pkill -SIGRTMIN+12 waybar

