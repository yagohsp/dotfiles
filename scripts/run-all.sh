#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

"$script_dir/install-packages.sh"
"$script_dir/enable-package-sync.sh"
"$script_dir/apply-stow.sh"

printf 'dotfiles setup complete\n'
