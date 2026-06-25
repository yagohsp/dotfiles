#!/usr/bin/env bash

set -uo pipefail

creds_file="$HOME/.config/quickshell/gcalcli-client.conf"

command -v gcalcli >/dev/null 2>&1 || exit 4

[ -r "$creds_file" ] || exit 3
client_id=$(sed -n '1p' "$creds_file")
client_secret=$(sed -n '2p' "$creds_file")
[ -n "$client_id" ] && [ -n "$client_secret" ] || exit 3

title="$1"
when="$2"
duration="${3:-60}"

gcalcli_base=(gcalcli --client-id="$client_id" --client-secret="$client_secret" --nocolor)

calendar=$(timeout 15 "${gcalcli_base[@]}" list 2>/dev/null \
  | awk '$1=="owner"{$1=""; sub(/^[ \t]+/,""); print; exit}')
[ -n "$calendar" ] || exit 5

timeout 30 "${gcalcli_base[@]}" add --noprompt \
  --calendar "$calendar" --title "$title" --when "$when" --duration "$duration"
exit $?
