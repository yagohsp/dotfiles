#!/usr/bin/env sh

set -eu

if [ "$(id -un)" = root ]; then
  printf 'run this as your normal user, not via sudo - sudo is invoked internally where needed\n' >&2
  exit 1
fi

# Set up autologin BEFORE disabling/stopping the login manager: if this
# script is run from inside the session the login manager is hosting,
# `disable --now` kills that session (and this script) immediately,
# never reaching anything after it.
#
# tty1 autologin -> .zprofile execs startx on VT1 -> .xinitrc execs i3.
target_user=$(id -un)
autologin_dir=/etc/systemd/system/getty@tty1.service.d
sudo mkdir -p "$autologin_dir"
printf '[Service]\nExecStart=\nExecStart=-/usr/sbin/agetty --autologin %s --noclear %%I $TERM\n' "$target_user" \
  | sudo tee "$autologin_dir/autologin.conf" >/dev/null
sudo systemctl daemon-reload
printf 'tty1 will autologin %s on next boot\n' "$target_user"

alias_unit=/etc/systemd/system/display-manager.service
found=0

if [ -e "$alias_unit" ]; then
  service_path=$(readlink -f "$alias_unit")
  service_name=$(basename "$service_path")
  sudo systemctl disable --now "$service_name"
  printf 'disabled and stopped %s\n' "$service_name"
  found=1
fi

# ly enables a per-tty instance (e.g. ly@tty2.service) instead of the
# display-manager.service alias, so it needs its own lookup.
for unit_link in /etc/systemd/system/*.wants/ly@*.service; do
  [ -e "$unit_link" ] || continue
  service_name=$(basename "$unit_link")
  sudo systemctl disable --now "$service_name"
  printf 'disabled and stopped %s\n' "$service_name"
  found=1
done

if [ "$found" -eq 0 ]; then
  printf 'no login manager is enabled\n'
fi
