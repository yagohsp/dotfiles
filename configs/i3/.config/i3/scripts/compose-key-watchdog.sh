#!/usr/bin/env sh
# Re-applies the compose:menu XKB option whenever a keyboard (re)connects.
# Needed because some custom/split keyboards (e.g. a flaky Bluetooth/USB
# split board) get a fresh libinput virtual subdevice on every reconnect,
# and the per-device XKB options from /etc/X11/xorg.conf.d don't reliably
# propagate to the shared core keymap that apps actually see.
set -eu

udevadm monitor --udev --subsystem-match=input | grep --line-buffered -i 'UDEV.*add' | while read -r _; do
  sleep 0.5
  setxkbmap -option compose:menu
done
