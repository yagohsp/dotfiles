#!/usr/bin/env sh

set -eu

shell_path=/usr/bin/zsh
current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)

if [ "$current_shell" = "$shell_path" ]; then
  printf 'default shell already set to %s\n' "$shell_path"
  exit 0
fi

chsh -s "$shell_path"
printf 'default shell set to %s (takes effect on next login)\n' "$shell_path"
