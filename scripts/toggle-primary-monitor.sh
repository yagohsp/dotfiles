#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
env_file="$repo_dir/monitors.env"

. "$env_file"

if [ -z "${SECONDARY_MONITOR:-}" ]; then
  printf 'only one monitor configured, nothing to toggle\n' >&2
  exit 1
fi

{
  printf 'PRIMARY_MONITOR="%s"\n'   "$SECONDARY_MONITOR"
  printf 'PRIMARY_HZ="%s"\n'        "$SECONDARY_HZ"
  printf 'SECONDARY_MONITOR="%s"\n' "$PRIMARY_MONITOR"
  printf 'SECONDARY_HZ="%s"\n'      "$PRIMARY_HZ"
} > "$env_file"

"$script_dir/apply-monitors.sh"
