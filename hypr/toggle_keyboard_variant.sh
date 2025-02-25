#!/bin/bash

hyprctl keyword input:kb_variant intl
pkill -SIGRTMIN+12 waybar

sleep 15

hyprctl keyword input:kb_variant ""
pkill -SIGRTMIN+12 waybar

