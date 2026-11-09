#!/usr/bin/env bash
set -euo pipefail
exec python3 "$(dirname "$0")/listen-stream-peaks.py"
