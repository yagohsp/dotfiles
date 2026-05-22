#!/bin/bash

get_current() {
    default_sink=$(pactl get-default-sink)
    
    if echo "$default_sink" | grep -q "HyperX"; then
        echo "Headset"
    elif pactl list cards | grep -A 20 "pci-0000_07_00.1" | grep "Active Profile" | grep -q "hdmi-stereo-extra1"; then
        echo "Monitor 2 (HDMI 2)"
    elif pactl list cards | grep -A 20 "pci-0000_07_00.1" | grep "Active Profile" | grep -q "hdmi-stereo"; then
        echo "Monitor 1 (HDMI 1)"
    else
        echo "Unknown"
    fi
}

get_current
