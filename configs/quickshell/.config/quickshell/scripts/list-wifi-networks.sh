#!/usr/bin/env sh

set -eu

command -v nmcli >/dev/null 2>&1 || exit 0
nmcli -t -f TYPE device status 2>/dev/null | grep -q '^wifi$' || exit 0

printf 'radio:%s\n' "$(nmcli -g WIFI general status 2>/dev/null || printf disabled)"
nmcli -g ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY device wifi list 2>/dev/null
