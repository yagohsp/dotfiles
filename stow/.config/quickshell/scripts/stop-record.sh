#!/usr/bin/env bash
exec >> /tmp/qs-record-debug.log 2>&1
echo "[$(date)] stop-record.sh starting"

_qs_state() { printf '{"recordingMode":"%s","encoding":%s}\n' "$1" "${2:-false}" > /tmp/qs-capture.json; }

mode=$(jq -r '.recordingMode // "mp4"' /tmp/qs-capture.json 2>/dev/null || echo "mp4")
echo "[$(date)] mode=$mode"
_qs_state "none" false

[ -f /tmp/capture-rec.pid ] || { echo "no pid file, exiting"; exit 0; }

ffpid=$(cat /tmp/capture-rec.pid)
echo "[$(date)] killing ffpid=$ffpid"
rm -f /tmp/capture-rec.pid

kill -INT "$ffpid"
while kill -0 "$ffpid" 2>/dev/null; do
  sleep 0.2
done
echo "[$(date)] ffmpeg exited"

[ -f /tmp/capture-rec.mp4 ] || { echo "no mp4 file, exiting"; exit 1; }

outfile=~/Pictures/rec-$(date +%d-%m-%Y_%H-%M-%S)
_qs_state "$mode" true

if [ "$mode" = "gif" ]; then
  ffmpeg -i /tmp/capture-rec.mp4 \
    -vf "fps=20,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
    "${outfile}.gif" \
    && rm -f /tmp/capture-rec.mp4
  _qs_state "none" false
  notify-send -i camera "Capture" "GIF saved: $(basename "${outfile}.gif")"
else
  ffmpeg -i /tmp/capture-rec.mp4 \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    -c:v libx264 -crf 26 -preset veryslow -pix_fmt yuv420p -an \
    -movflags +faststart \
    "${outfile}.mp4" \
    && rm -f /tmp/capture-rec.mp4
  _qs_state "none" false
  notify-send -i camera "Capture" "MP4 saved: $(basename "${outfile}.mp4")"
fi
