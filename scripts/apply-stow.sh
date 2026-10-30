#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
stow_dir="$repo_dir"
package=stow
package_dir="$repo_dir/$package"

if ! command -v stow >/dev/null 2>&1; then
  printf 'stow is not installed. Install it first.\n' >&2
  exit 1
fi

if [ ! -d "$package_dir" ]; then
  printf 'stow package not found: %s\n' "$package_dir" >&2
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

  link_target=$(readlink -f "$target" 2>/dev/null || true)
  raw_target=$(readlink "$target")

  case "$link_target" in
    "$package_dir"/*|"$repo_dir/configs"/*)
      return 0
      ;;
  esac

  case "$raw_target" in
    *dotfiles/stow/*|*dotfiles/configs/*|"$package_dir"/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

dir_has_managed_links() {
  dir=$1
  [ -d "$dir" ] || return 1

  # Avoid zsh nomatch on empty globs when this script is run via zsh.
  set -- "$dir"/* "$dir"/.[!.]* "$dir"/..?*
  for child in "$@"; do
    if [ -e "$child" ] || [ -L "$child" ]; then
      if is_managed_link "$child"; then
        return 0
      fi
    fi
  done

  return 1
}

for rel in $TARGETS; do
  target="$HOME/$rel"

  if is_managed_link "$target"; then
    rm "$target"
    continue
  fi

  if [ -d "$target" ] && [ ! -L "$target" ] && dir_has_managed_links "$target"; then
    continue
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$backup_root/$(dirname "$rel")"
    mv "$target" "$backup_root/$rel"
    backed_up=1
    printf 'backed up %s\n' "$rel"
  fi
done

stow --restow -d "$stow_dir" -t "$HOME" "$package"

if [ "$backed_up" -eq 1 ]; then
  printf 'backup saved to %s\n' "$backup_root"
else
  printf 'no existing targets needed backup\n'
fi
