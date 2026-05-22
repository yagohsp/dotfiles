#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
configs_dir="$repo_dir/configs"

if ! command -v stow >/dev/null 2>&1; then
  printf 'stow is not installed. Install it first.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
. "$script_dir/stow-packages.sh"

timestamp=$(date +%Y%m%d-%H%M%S)
backup_root=${1:-"$HOME/.dotfiles-backups/$timestamp"}
backed_up=0

is_managed_link() {
  target=$1

  if [ ! -L "$target" ]; then
    return 1
  fi

  link_target=$(readlink -f "$target")

  case "$link_target" in
    "$configs_dir"/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

for rel in $TARGETS; do
  target="$HOME/$rel"

  if is_managed_link "$target"; then
    continue
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$backup_root/$(dirname "$rel")"
    mv "$target" "$backup_root/$rel"
    backed_up=1
    printf 'backed up %s\n' "$rel"
  fi
done

stow --restow -d "$configs_dir" -t "$HOME" $PACKAGES

if [ "$backed_up" -eq 1 ]; then
  printf 'backup saved to %s\n' "$backup_root"
else
  printf 'no existing targets needed backup\n'
fi
