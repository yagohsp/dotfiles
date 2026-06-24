#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
env_file="$repo_dir/monitors.env"

xrandr --query | awk '
  / connected / {
    name = $1
    is_primary = ($0 ~ / primary /) ? 1 : 0
    order[++order_n] = name
    primary_flag[name] = is_primary
    cur = name
    next
  }
  /^[^ ]/ { cur = ""; next }
  cur != "" {
    line = $0
    gsub(/ +\*/, "*", line)
    gsub(/ +\+/, "+", line)
    n = split(line, toks, /[ \t]+/)
    for (i = 1; i <= n; i++) {
      tok = toks[i]
      if (tok ~ /\*/) {
        gsub(/[*+]/, "", tok)
        hz[cur] = tok
      } else if (tok ~ /\+/) {
        gsub(/[*+]/, "", tok)
        if (!(cur in pref)) pref[cur] = tok
      }
    }
  }
  END {
    primary = ""
    secondary = ""
    for (i = 1; i <= order_n; i++) {
      if (primary_flag[order[i]] == 1 && primary == "") primary = order[i]
    }
    if (primary == "" && order_n >= 1) primary = order[1]
    for (i = 1; i <= order_n; i++) {
      if (order[i] != primary && secondary == "") secondary = order[i]
    }
    if (primary != "" && !(primary in hz)) hz[primary] = pref[primary]
    if (secondary != "" && !(secondary in hz)) hz[secondary] = pref[secondary]
    if (primary != "") {
      print "PRIMARY_MONITOR=\"" primary "\""
      print "PRIMARY_HZ=\"" hz[primary] "\""
    }
    if (secondary != "") {
      print "SECONDARY_MONITOR=\"" secondary "\""
      print "SECONDARY_HZ=\"" hz[secondary] "\""
    }
  }
' > "$env_file"

printf 'monitors.env updated from current xrandr state:\n'
cat "$env_file"
