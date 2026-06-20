#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

repo_url="https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme.git"
src_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/Rose-Pine-GTK-Theme"
theme_name="Rosepine-Light"

if ! command -v paru >/dev/null 2>&1; then
  printf 'paru is not installed. Install it first.\n' >&2
  exit 1
fi

# sassc, gtk-engine-murrine and gnome-themes-extra are required by the theme
# for correct rendering; git is needed to fetch the theme source.
paru -S --needed -- git sassc gtk-engine-murrine gnome-themes-extra

if [ -d "$src_dir/.git" ]; then
  git -C "$src_dir" pull --ff-only
else
  mkdir -p "$(dirname "$src_dir")"
  git clone --depth 1 "$repo_url" "$src_dir"
fi

cd "$src_dir/themes"
# Light only, to match this setup's gtk-application-prefer-dark-theme=0;
# the resulting theme dir name ("Rosepine-Light") must match $theme_name above.
./install.sh -c light

sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$theme_name/" \
  "$repo_dir/configs/gtk/.config/gtk-3.0/settings.ini" \
  "$repo_dir/configs/gtk/.config/gtk-4.0/settings.ini"
sed -i "s/^Net\/ThemeName .*/Net\/ThemeName \"$theme_name\"/" \
  "$repo_dir/configs/qt/.config/xsettingsd/xsettingsd.conf"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "$theme_name" || true
fi

if pgrep -x xsettingsd >/dev/null 2>&1; then
  pkill -HUP -x xsettingsd
fi
