#!/bin/bash

wayfreeze &
sleep .1

screenshot_file=$(mktemp)
ocr_text_file=$(mktemp)

grim -g "$(slurp -d)" "$screenshot_file"

# Copy screenshot image to clipboard
tee >(wl-copy < "$screenshot_file") < "$screenshot_file" > /dev/null

# Run OCR with Tesseract (output to text file)
tesseract -l jpn_vert --psm 5 "$screenshot_file" "$ocr_text_file" 

# Copy recognized text to clipboard
cat "${ocr_text_file}.txt" | wl-copy 

pkill wayfreeze

rm "$screenshot_file" "${ocr_text_file}.txt"
