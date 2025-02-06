#!/bin/bash
current_variant=$(
    hyprctl devices -j \
        | grep -A 4 '"name": "g603-keyboard"' \
        | grep variant | awk -F ': ' '{print $2}' \
        | tr -d '",'
)


if [ "$current_variant" == "intl" ]; then
    hyprctl keyword input:kb_variant ""
else
    hyprctl keyword input:kb_variant intl
fi
