#!/usr/bin/env bash
exec >> /tmp/qs-record-debug.log 2>&1
echo "[$(date)] start-record.sh $* DISPLAY=$DISPLAY"

if [ -f /tmp/capture-rec.pid ] && kill -0 "$(cat /tmp/capture-rec.pid)" 2>/dev/null; then
  echo "[$(date)] already recording (pid $(cat /tmp/capture-rec.pid)), ignoring"
  exit 0
fi

mode="${1:-mp4}"

_qs_state() { printf '{"recordingMode":"%s","encoding":%s}\n' "$1" "${2:-false}" > /tmp/qs-capture.json; }

_qs_state "$mode" false

geo=$(flameshot gui --accept-on-select --print-geometry 2>/dev/null)
if [ -z "$geo" ]; then
  _qs_state "none" false
  exit 0
fi

wh=$(echo "$geo" | cut -d'+' -f1)
xy=$(echo "$geo" | cut -d'+' -f2-3 | tr '+' ',')

ffmpeg -y -nostdin -f x11grab -s "$wh" -i "$DISPLAY+$xy" /tmp/capture-rec.mp4 &
echo $! > /tmp/capture-rec.pid
