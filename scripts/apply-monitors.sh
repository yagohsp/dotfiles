#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
dotfiles=$(CDPATH= cd -- "$script_dir/.." && pwd)

. "$dotfiles/monitors.env"

SECONDARY_MONITOR="${SECONDARY_MONITOR:-}"
SECONDARY_HZ="${SECONDARY_HZ:-}"

I3_DIR="$dotfiles/configs/i3/.config/i3"

# i3 workspaces: ws1-4 → primary, ws5-8 → secondary (falls back to primary if no secondary monitor)
# Written to a gitignored file so machine-specific monitor names never dirty git.
cat > "$I3_DIR/monitors-outputs.conf" <<EOF
set \$primary_output $PRIMARY_MONITOR
set \$secondary_output ${SECONDARY_MONITOR:-$PRIMARY_MONITOR}
EOF

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

# i3 restart keeps existing workspaces on their current output; force them
# to the right output so the move actually happens (ws1-4 → primary, ws5-8 → secondary).
tries=0
until i3-msg -t get_version >/dev/null 2>&1; do
  tries=$((tries + 1))
  [ "$tries" -ge 50 ] && break
  sleep 0.1
done

focused_ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

for n in 1 2 3 4; do
  i3-msg "workspace number $n; move workspace to output $PRIMARY_MONITOR" >/dev/null
done
for n in 5 6 7 8; do
  i3-msg "workspace number $n; move workspace to output ${SECONDARY_MONITOR:-$PRIMARY_MONITOR}" >/dev/null
done

if [ -n "$focused_ws" ]; then
  i3-msg "workspace \"$focused_ws\"" >/dev/null
fi

printf 'Monitors applied: primary=%s secondary=%s\n' "$PRIMARY_MONITOR" "${SECONDARY_MONITOR:-none}"
