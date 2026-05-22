#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
packages_file="$repo_dir/packages/packages-dotfiles.txt"

if ! command -v paru >/dev/null 2>&1; then
  printf 'paru is not installed. Install it first.\n' >&2
  exit 1
fi

if [ ! -f "$packages_file" ]; then
  printf 'package list not found: %s\n' "$packages_file" >&2
  exit 1
fi

set --

while IFS= read -r pkg; do
  case "$pkg" in
    ''|'#'*)
      continue
      ;;
  esac

  set -- "$@" "$pkg"
done < "$packages_file"

if [ "$#" -eq 0 ]; then
  printf 'no packages listed in %s\n' "$packages_file"
  exit 0
fi

paru -S --needed -- "$@"
