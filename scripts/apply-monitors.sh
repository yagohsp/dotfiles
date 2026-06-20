#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
dotfiles=$(CDPATH= cd -- "$script_dir/.." && pwd)

. "$dotfiles/monitors.env"

SECONDARY_MONITOR="${SECONDARY_MONITOR:-}"
SECONDARY_HZ="${SECONDARY_HZ:-}"

I3_DIR="$dotfiles/configs/i3/.config/i3"

# i3 workspaces: ws1-4 → primary, ws5-8 → secondary (falls back to primary if no secondary monitor)
sed -i \
  -e "s|\(workspace \\\$ws[1-4] output \).*|\1$PRIMARY_MONITOR|" \
  -e "s|\(workspace \\\$ws[5-8] output \).*|\1${SECONDARY_MONITOR:-$PRIMARY_MONITOR}|" \
  "$I3_DIR/workspaces.conf"

# Apply xrandr
if [ -n "$SECONDARY_MONITOR" ]; then
  xrandr \
    --output "$SECONDARY_MONITOR" --mode 1920x1080 --rate "$SECONDARY_HZ" \
    --output "$PRIMARY_MONITOR"   --mode 1920x1080 --rate "$PRIMARY_HZ" --primary --right-of "$SECONDARY_MONITOR"
else
  xrandr --output "$PRIMARY_MONITOR" --primary
fi

# Reload i3
i3-msg restart

printf 'Monitors applied: primary=%s secondary=%s\n' "$PRIMARY_MONITOR" "${SECONDARY_MONITOR:-none}"
