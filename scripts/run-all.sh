#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

"$script_dir/install-packages.sh"
"$script_dir/enable-package-sync.sh"
"$script_dir/enable-monitor-watch.sh"
"$script_dir/enable-backlight.sh"
"$script_dir/apply-stow.sh"
"$script_dir/set-default-shell.sh"
"$script_dir/refresh-audio-outputs"
"$script_dir/install-rose-pine-gtk-theme.sh"

printf 'dotfiles setup complete\n'
