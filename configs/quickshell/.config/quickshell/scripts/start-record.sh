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

if [[ ! "$geo" =~ ^(-?[0-9]+)x(-?[0-9]+)\+(-?[0-9]+)\+(-?[0-9]+)$ ]]; then
  echo "[$(date)] unparsable geometry: $geo"
  _qs_state "none" false
  exit 1
fi
w="${BASH_REMATCH[1]}"; h="${BASH_REMATCH[2]}"; x="${BASH_REMATCH[3]}"; y="${BASH_REMATCH[4]}"

# flameshot can report a negative width/height on multi-monitor setups
# (the selection's anchor corner ends up on the "wrong" side); normalize
# by sliding the origin and taking the absolute size.
if [ "$w" -lt 0 ]; then x=$((x + w)); w=$((-w)); fi
if [ "$h" -lt 0 ]; then y=$((y + h)); h=$((-h)); fi

wh="${w}x${h}"
xy="${x},${y}"
echo "[$(date)] normalized geo: ${wh}+${xy}"

ffmpeg -y -nostdin -f x11grab -s "$wh" -i "$DISPLAY+$xy" /tmp/capture-rec.mp4 &
echo $! > /tmp/capture-rec.pid
