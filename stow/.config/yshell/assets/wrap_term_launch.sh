#!/usr/bin/env sh

cat ~/.local/state/yshell-light/sequences.txt 2>/dev/null

exec "$@"
