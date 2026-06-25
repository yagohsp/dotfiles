#!/usr/bin/env bash

set -uo pipefail

creds_file="$HOME/.config/quickshell/gcalcli-client.conf"

command -v gcalcli >/dev/null 2>&1 || exit 4

[ -r "$creds_file" ] || exit 3
client_id=$(sed -n '1p' "$creds_file")
client_secret=$(sed -n '2p' "$creds_file")
[ -n "$client_id" ] && [ -n "$client_secret" ] || exit 3

year=$(date +%Y)
start="$((year - 1))-01-01"
end="$((year + 1))-12-31"

# gcalcli falls back to an interactive browser auth flow (and hangs) when the
# cached token is missing/expired, so cap it instead of blocking the listener.
timeout 60 gcalcli \
  --client-id="$client_id" --client-secret="$client_secret" \
  --nocolor agenda --tsv --details description "$start" "$end"
status=$?
[ "$status" -eq 124 ] && exit 3
exit "$status"
