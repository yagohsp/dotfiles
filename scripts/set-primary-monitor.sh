#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
env_file="$repo_dir/monitors.env"

name="${1:?usage: set-primary-monitor.sh <monitor-name> <hz>}"
hz="${2:?usage: set-primary-monitor.sh <monitor-name> <hz>}"

. "$env_file"

if [ "$name" = "${PRIMARY_MONITOR:-}" ]; then
  # Refresh-rate-only change on the monitor that's already primary: no
  # topology change, so just bump the rate directly instead of going through
  # apply-monitors.sh's i3 restart + workspace shuffle, which needlessly
  # disrupts focus and can transiently tear down quickshell's bar windows
  # (closing anything anchored to them, like the settings panel).
  {
    printf 'PRIMARY_MONITOR="%s"\n'   "$PRIMARY_MONITOR"
    printf 'PRIMARY_HZ="%s"\n'        "$hz"
    printf 'SECONDARY_MONITOR="%s"\n' "${SECONDARY_MONITOR:-}"
    printf 'SECONDARY_HZ="%s"\n'      "${SECONDARY_HZ:-}"
  } > "$env_file"
  xrandr --output "$name" --mode 1920x1080 --rate "$hz"
  exit 0
fi

if [ "$name" = "${SECONDARY_MONITOR:-}" ]; then
  new_primary="$name"
  new_primary_hz="$hz"
  new_secondary="$PRIMARY_MONITOR"
  new_secondary_hz="$PRIMARY_HZ"
else
  printf 'unknown monitor "%s" (known: %s, %s)\n' "$name" "${PRIMARY_MONITOR:-}" "${SECONDARY_MONITOR:-}" >&2
  exit 1
fi

{
  printf 'PRIMARY_MONITOR="%s"\n'   "$new_primary"
  printf 'PRIMARY_HZ="%s"\n'        "$new_primary_hz"
  printf 'SECONDARY_MONITOR="%s"\n' "$new_secondary"
  printf 'SECONDARY_HZ="%s"\n'      "$new_secondary_hz"
} > "$env_file"

"$script_dir/apply-monitors.sh"
