#!/usr/bin/env bash
# Puts a clipmenu history entry back on the clipboard, the way clipmenu itself does.
dir="$HOME/.local/share/clipmenu.6.$USER"
file="$dir/$(cksum <<< "$1")"
[[ -f "$file" ]] || exit 1
for selection in clipboard primary; do
    xsel --logfile /dev/null -i --"$selection" < "$file"
done
