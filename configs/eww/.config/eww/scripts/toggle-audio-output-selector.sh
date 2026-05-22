#!/bin/bash

if eww windows | grep -q "\*audio-output-selector"; then
    eww close audio-output-selector
else
    eww open audio-output-selector
fi
