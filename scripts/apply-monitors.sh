#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
dotfiles=$(CDPATH= cd -- "$script_dir/.." && pwd)

. "$dotfiles/monitors.env"

I3_DIR="$dotfiles/configs/i3/.config/i3"
EWW_WINDOWS="$dotfiles/configs/eww/.config/eww/windows"

# i3 workspaces: ws1-4 → primary, ws5-8 → secondary
sed -i \
  -e "s|\(workspace \\\$ws[1-4] output \).*|\1$PRIMARY_MONITOR|" \
  -e "s|\(workspace \\\$ws[5-8] output \).*|\1$SECONDARY_MONITOR|" \
  "$I3_DIR/workspaces.conf"

# eww single-monitor windows → primary
for f in panel.yuck system-menu.yuck calendar-dropdown.yuck volume-modal.yuck; do
  sed -i "s/:monitor \"[^\"]*\"/:monitor \"$PRIMARY_MONITOR\"/g" "$EWW_WINDOWS/$f"
done

# eww bar.yuck: first defwindow → primary, second → secondary
awk -v primary="$PRIMARY_MONITOR" -v secondary="$SECONDARY_MONITOR" '
  /^\(defwindow / { window_count++ }
  /:monitor "/ {
    if (window_count == 1) sub(/"[^"]*"/, "\"" primary "\"")
    else sub(/"[^"]*"/, "\"" secondary "\"")
  }
  /monitor_name "/ {
    if (window_count == 1) sub(/"[^"]*"/, "\"" primary "\"")
    else sub(/"[^"]*"/, "\"" secondary "\"")
  }
  { print }
' "$EWW_WINDOWS/bar.yuck" > "$EWW_WINDOWS/bar.yuck.tmp" && mv "$EWW_WINDOWS/bar.yuck.tmp" "$EWW_WINDOWS/bar.yuck"

# Apply xrandr
xrandr \
  --output "$SECONDARY_MONITOR" --mode 1920x1080 --rate "$SECONDARY_HZ" \
  --output "$PRIMARY_MONITOR"   --mode 1920x1080 --rate "$PRIMARY_HZ" --primary --right-of "$SECONDARY_MONITOR"

# Reload i3
i3-msg restart

# Restart eww
eww kill || true
eww daemon &
sleep 1
eww open bar
eww open bar-dp0

printf 'Monitors applied: primary=%s secondary=%s\n' "$PRIMARY_MONITOR" "$SECONDARY_MONITOR"
