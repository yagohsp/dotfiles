#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

rule_source="$repo_dir/system/udev/rules.d/90-backlight.rules"
rule_target="/etc/udev/rules.d/90-backlight.rules"

if [ -z "$(ls /sys/class/backlight 2>/dev/null)" ]; then
  printf 'no backlight device present, skipping\n'
  exit 0
fi

sudo install -Dm644 "$rule_source" "$rule_target"
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight

printf 'backlight write permissions enabled\n'
