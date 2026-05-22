#!/bin/bash


# Set to headset
headset_sink=$(pactl list sinks short | grep "HyperX" | awk '{print $2}')

pactl set-default-sink "$headset_sink"
