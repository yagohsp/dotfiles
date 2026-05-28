#!/usr/bin/env bash

set -euo pipefail

outputs_file="$HOME/dotfiles/configs/eww/.config/audio/outputs.json"
refresh_script="$HOME/dotfiles/scripts/refresh-audio-outputs"

if [[ -x "$refresh_script" ]]; then
  "$refresh_script" >/dev/null
fi

if [[ ! -r "$outputs_file" ]]; then
  printf '[]\n'
  exit 0
fi

outputs_json="$(jq -c '[ .[] | select(.type == "sink") ]' "$outputs_file")"
inputs_json="$(pactl -f json list sink-inputs)"
sinks_json="$(pactl -f json list sinks)"

jq -cn \
  --argjson outputs "$outputs_json" \
  --argjson inputs "$inputs_json" \
  --argjson sinks "$sinks_json" '
  def output_at($arr; $index): ($arr[$index] // {});
  def output_button_label($output):
    if (($output.name // "") == "Headset") then "Headset"
    elif (($output.name // "") | test("Monitor 1")) then "HDMI 1"
    elif (($output.name // "") | test("Monitor 2")) then "HDMI 2"
    else ($output.name // "Output")
    end;
  def useful_media_name($media_name; $app_name):
    ($media_name // "") as $media
    | if $media == ""
         or $media == "(null)"
         or $media == $app_name
         or $media == "Playback"
         or $media == "playStream"
         or ($media | startswith("audio stream #"))
      then ""
      else $media
      end;
  def stream_label:
    (.properties["application.name"] // "") as $app_name
    | (.properties["media.name"] // "") as $media_name
    | (.properties["application.process.binary"] // "") as $binary
    | (useful_media_name($media_name; $app_name)) as $useful_media
    | if $app_name != "" and $useful_media != "" then
        $app_name + " - " + $useful_media
      elif $app_name != "" then
        $app_name
      elif $useful_media != "" then
        $useful_media
      elif $binary != "" then
        $binary
      else
        "Stream " + (.index | tostring)
      end;

  $inputs
  | map(
      . as $input
      | ($sinks[] | select(.index == ($input.sink // -1)) | .name)? as $current_sink_name
      | ($outputs | map({
          name,
          sink_name,
          current: (.sink_name == ($current_sink_name // ""))
        })) as $stream_outputs
      | {
          index: .index,
          name: stream_label,
          muted: (.mute // false),
          volume: ((.volume["front-left"].value_percent // .volume["aux0"].value_percent // "0%") | rtrimstr("%") | tonumber),
          current_sink_name: ($current_sink_name // ""),
          current_output_name: (
            ($outputs[] | select(.sink_name == ($current_sink_name // "")) | .name)?
            // "Unknown"
          ),
          output_1_name: (output_at($stream_outputs; 0).name // ""),
          output_1_button_label: output_button_label(output_at($stream_outputs; 0)),
          output_1_sink_name: (output_at($stream_outputs; 0).sink_name // ""),
          output_1_current: (output_at($stream_outputs; 0).current // false),
          output_2_name: (output_at($stream_outputs; 1).name // ""),
          output_2_button_label: output_button_label(output_at($stream_outputs; 1)),
          output_2_sink_name: (output_at($stream_outputs; 1).sink_name // ""),
          output_2_current: (output_at($stream_outputs; 1).current // false),
          output_3_name: (output_at($stream_outputs; 2).name // ""),
          output_3_button_label: output_button_label(output_at($stream_outputs; 2)),
          output_3_sink_name: (output_at($stream_outputs; 2).sink_name // ""),
          output_3_current: (output_at($stream_outputs; 2).current // false)
        }
    )
  | sort_by(.name, .index)
  | group_by(.name)
  | map(max_by(.index))
'
