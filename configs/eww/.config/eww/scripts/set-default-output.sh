#!/bin/bash

selection="$1"

echo "$(date): set-default-output.sh called with: $selection" >> /tmp/eww-audio-debug.log

if [[ "$selection" == "headset" ]]; then
    # Set to headset
    headset_sink=$(pactl list sinks short | grep "HyperX" | awk '{print $2}')
    echo "$(date): Setting headset sink: $headset_sink" >> /tmp/eww-audio-debug.log
    pactl set-default-sink "$headset_sink"
elif [[ "$selection" == "monitor" ]]; then
    # Get GPU card number
    gpu_card=$(pactl list cards short | grep "pci-0000_07_00.1" | awk '{print $1}')
    
    # Get current profile
    current_profile=$(pactl list cards | grep -B 5 -A 50 "pci-0000_07_00.1" | grep "Active Profile" | awk '{print $3}')
    
    echo "$(date): GPU card: $gpu_card, Current profile: $current_profile" >> /tmp/eww-audio-debug.log
    
    # Cycle between HDMI 1 and HDMI 2
    if [[ "$current_profile" == "output:hdmi-stereo" ]]; then
        # Currently on HDMI 1, switch to HDMI 2
        echo "$(date): Switching to HDMI 2" >> /tmp/eww-audio-debug.log
        pactl set-card-profile "$gpu_card" "output:hdmi-stereo-extra1"
    else
        # Switch to HDMI 1
        echo "$(date): Switching to HDMI 1" >> /tmp/eww-audio-debug.log
        pactl set-card-profile "$gpu_card" "output:hdmi-stereo"
    fi
    
    sleep 0.3
    # Set HDMI sink as default
    hdmi_sink=$(pactl list sinks short | grep "pci-0000_07_00.1" | awk '{print $2}')
    echo "$(date): HDMI sink found: '$hdmi_sink'" >> /tmp/eww-audio-debug.log
    echo "$(date): All sinks: $(pactl list sinks short)" >> /tmp/eww-audio-debug.log
    if [ -n "$hdmi_sink" ]; then
        pactl set-default-sink "$hdmi_sink"
        echo "$(date): Set default to: $hdmi_sink" >> /tmp/eww-audio-debug.log
    else
        echo "$(date): ERROR: hdmi_sink is empty!" >> /tmp/eww-audio-debug.log
    fi
fi
