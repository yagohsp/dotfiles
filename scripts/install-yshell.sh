#!/usr/bin/env sh
# Builds what yshell needs outside the repo: the compiled QML plugin, its colour scheme
# and the cursor theme. Safe to run again.

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
src="${YSHELL_SRC:-$repo_dir/stow/.config/yshell}"
data="${XDG_DATA_HOME:-$HOME/.local/share}/yshell-light"
state="${XDG_STATE_HOME:-$HOME/.local/state}/yshell-light"
third_party="$data/third_party"

# Arch's cava package has no library, so cavacore is built locally.
if [ ! -f "$third_party/prefix/lib/pkgconfig/cava.pc" ]; then
  rm -rf "$third_party"
  mkdir -p "$third_party/prefix/include/cava" "$third_party/prefix/lib/pkgconfig"
  git clone --depth 1 --branch 1.0.0 https://github.com/karlstav/cava "$third_party/cava"
  cp "$third_party/cava/cavacore.h" "$third_party/prefix/include/cava/"
  gcc -O2 -fPIC -c "$third_party/cava/cavacore.c" -o "$third_party/prefix/lib/cavacore.o"
  ar rcs "$third_party/prefix/lib/libcavacore.a" "$third_party/prefix/lib/cavacore.o"
  rm "$third_party/prefix/lib/cavacore.o"
  cat > "$third_party/prefix/lib/pkgconfig/cava.pc" <<PC
Name: cava
Description: cavacore local
Version: 1.0.0
Cflags: -I$third_party/prefix/include
Libs: -L$third_party/prefix/lib -lcavacore -lfftw3 -lm
PC
fi

PKG_CONFIG_PATH="$third_party/prefix/lib/pkgconfig" cmake -S "$src" -B "$data/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DVERSION=1.0.0 -DGIT_REVISION="$(git -C "$repo_dir" rev-parse HEAD)" \
  -DENABLE_MODULES=plugin
ninja -C "$data/build"

# Kept if it already exists, so a later scheme change is not overwritten.
mkdir -p "$state"
[ -e "$state/scheme.json" ] || cp "$src/assets/schemes/sakura-tren.json" "$state/scheme.json"

theme="$HOME/.icons/Bibata-Sakura"
if [ ! -d "$theme" ]; then
  tmp=$(mktemp -d)
  curl -fsSL https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz \
    | tar -xJ --no-same-owner -C "$tmp"
  mkdir -p "$HOME/.icons"
  python3 -I "$script_dir/build-bibata-sakura" "$tmp/Bibata-Modern-Classic" "$theme"
  rm -rf "$tmp"
fi

mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nName=Default\nInherits=Bibata-Sakura\n' > "$HOME/.icons/default/index.theme"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface cursor-theme Bibata-Sakura || true
fi
if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --filesystem=~/.icons:ro \
    --env=XCURSOR_PATH="$HOME/.icons:/run/host/user-share/icons:/run/host/share/icons" \
    --env=XCURSOR_THEME=Bibata-Sakura --env=XCURSOR_SIZE=24
fi
