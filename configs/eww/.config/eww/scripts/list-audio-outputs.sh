#!/bin/bash

# Get headset ID (sink, not device)
headset_id=$(wpctl status | grep "│.*HyperX Cloud Flight" | grep "\[vol:" | awk '{print $2}' | tr -d '. *')

# Get GPU card ID  
gpu_card="53"

# Output as JSON array
cat << EOF
[
  {"name": "Headset", "type": "sink", "id": "$headset_id"},
  {"name": "Monitor 1 (HDMI 1)", "type": "profile", "card": "$gpu_card", "profile": "output:hdmi-stereo"},
  {"name": "Monitor 2 (HDMI 2)", "type": "profile", "card": "$gpu_card", "profile": "output:hdmi-stereo-extra1"}
]
EOF
