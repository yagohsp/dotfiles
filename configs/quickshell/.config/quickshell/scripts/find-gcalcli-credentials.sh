#!/usr/bin/env bash

set -uo pipefail

shopt -s nullglob nocaseglob
candidates=("$HOME/.config/quickshell"/*client_secret*.json)
shopt -u nullglob nocaseglob

[ "${#candidates[@]}" -gt 0 ] || exit 1

newest=$(ls -t "${candidates[@]}" | head -n1)

python3 - "$newest" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError):
    sys.exit(2)

if "installed" not in data and "web" in data:
    sys.exit(5)

block = data.get("installed") or data
client_id = block.get("client_id", "")
client_secret = block.get("client_secret", "")

if not client_id or not client_secret:
    sys.exit(2)

print(client_id)
print(client_secret)
PY
