#!/usr/bin/env bash

set -euo pipefail

pid="${1:-}"
[ -n "$pid" ] || exit 1

kill -9 "$pid" 2>/dev/null || kill "$pid"
