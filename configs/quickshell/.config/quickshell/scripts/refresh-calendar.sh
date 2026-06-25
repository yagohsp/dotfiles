#!/usr/bin/env bash

set -uo pipefail

script_dir="$(dirname "$0")"
out="$("$script_dir/get-calendar.sh")"
status=$?

case "$status" in
  0) printf 'OK\n' ;;
  3) printf 'NOAUTH\n' ;;
  4) printf 'NOTOOL\n' ;;
  *) printf 'ERROR\n' ;;
esac

[ -n "$out" ] && printf '%s\n' "$out"
printf '%s\n' "---"
