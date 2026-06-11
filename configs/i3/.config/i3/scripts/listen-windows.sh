eww_window=""

while read -r event; do
  event_type=$(jq -r '.change' <<< "$event")

  if [[ "$event_type" == "focus" ]]; then
    name=$(jq -r '.container.window_properties.instance' <<< "$event")

    if [[ "$name" == "eww" ]]; then
      window_name=$(jq -r '.container.name' <<< "$event")
      eww_window=${window_name#*- }
    elif [[ "$eww_window" != "" ]]; then
      eww close "$eww_window"
      eww_window=""
    fi
  fi
done < <(i3-msg -t subscribe -m '["window"]' | stdbuf -oL jq -c '.')
