#!/bin/bash

THRESHOLD=20

BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)

if [ "$BATTERY_LEVEL" -le "$THRESHOLD" ]; then
    notify-send "Nível de bateria baixo" "Bateria em $BATTERY_LEVEL%. Conecte o carregador."
fi
