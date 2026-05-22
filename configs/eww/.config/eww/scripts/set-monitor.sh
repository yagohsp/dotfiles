#!/bin/bash

# Get GPU card number
gpu_card=$(pactl list cards short | grep "pci-0000_07_00.1" | awk '{print $1}')

# Get current profile
current_profile=$(pactl list cards | grep -B 5 -A 50 "pci-0000_07_00.1" | grep "Active Profile" | awk '{print $3}')

# Get current default sink
current_sink=$(pactl get-default-sink)

# If already on monitor, cycle between HDMI 1 and HDMI 2
if [[ "$current_sink" == *"pci-0000_07_00.1"* ]]; then
    if [[ "$current_profile" == "output:hdmi-stereo" ]]; then
        pactl set-card-profile "$gpu_card" "output:hdmi-stereo-extra1"
    else
        pactl set-card-profile "$gpu_card" "output:hdmi-stereo"
    fi
else
    # Not on monitor, just activate current profile
    pactl set-card-profile "$gpu_card" "$current_profile"
fi

# Set HDMI sink as default
hdmi_sink=$(pactl list sinks short | grep "pci-0000_07_00.1" | awk '{print $2}')

if [ -n "$hdmi_sink" ]; then
    pactl set-default-sink "$hdmi_sink"
fi
