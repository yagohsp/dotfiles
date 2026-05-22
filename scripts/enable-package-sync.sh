#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
hook_source="$repo_dir/system/pacman/hooks/95-dotfiles-packages.hook"
hook_target="/etc/pacman.d/hooks/95-dotfiles-packages.hook"
state_dir="${DOTFILES_PACKAGE_STATE_DIR:-/var/lib/dotfiles-package-sync}"
state_file="$state_dir/explicit-packages.txt"

sudo install -Dm644 "$hook_source" "$hook_target"

if sudo test -f "$state_file"; then
  sudo "$script_dir/sync-dotfiles-packages"
else
  sudo "$script_dir/sync-dotfiles-packages" --init
fi

printf 'package sync enabled\n'
