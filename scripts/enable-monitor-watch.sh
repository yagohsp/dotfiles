#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

rule_source="$repo_dir/system/udev/rules.d/99-monitor-watch.rules"
rule_target="/etc/udev/rules.d/99-monitor-watch.rules"
trigger_source="$repo_dir/system/udev/dotfiles-monitor-watch-trigger"
trigger_target="/usr/local/bin/dotfiles-monitor-watch-trigger"

sudo install -Dm644 "$rule_source" "$rule_target"
sudo install -Dm755 "$trigger_source" "$trigger_target"
sudo udevadm control --reload-rules

printf 'monitor watch enabled (udev rule + trigger installed)\n'
