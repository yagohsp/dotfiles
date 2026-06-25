#!/usr/bin/env bash

set -uo pipefail

client_id="$1"
client_secret="$2"
creds_file="$HOME/.config/quickshell/gcalcli-client.conf"

mkdir -p "$(dirname "$creds_file")"

export PYTHONUNBUFFERED=1

gcalcli --nocolor --client-id="$client_id" --client-secret="$client_secret" init \
  < <(printf 'y\n') 2>&1 | while IFS= read -r line; do
    if [[ "$line" == *"Please visit this URL"* ]]; then
      url=$(printf '%s' "$line" | grep -oE 'https?://[^[:space:]]+')
      if [ -n "$url" ]; then
        xdg-open "$url" >/dev/null 2>&1 &
        printf 'AUTHURL:%s\n' "$url"
      fi
    fi
  done
status=${PIPESTATUS[0]}

if [ "$status" -eq 0 ]; then
  printf '%s\n%s\n' "$client_id" "$client_secret" > "$creds_file"
  chmod 600 "$creds_file"
fi

exit "$status"
