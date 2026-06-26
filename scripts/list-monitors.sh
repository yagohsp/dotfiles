#!/usr/bin/env python3
import json, os, re, subprocess

def load_monitors_env():
    path = os.path.expanduser("~/dotfiles/monitors.env")
    env = {}
    if os.path.exists(path):
        with open(path) as f:
            for line in f:
                line = line.strip()
                if "=" in line:
                    k, _, v = line.partition("=")
                    env[k] = v.strip().strip('"')
    return env

env = load_monitors_env()
primary_name = env.get("PRIMARY_MONITOR", "")

out = subprocess.run(["xrandr", "--query"], capture_output=True, text=True).stdout

monitors = []
cur = None
for line in out.splitlines():
    m = re.match(r"^(\S+) connected", line)
    if m:
        cur = {"name": m.group(1), "rates": [], "currentRate": None}
        monitors.append(cur)
        continue
    if re.match(r"^\S", line):
        cur = None
        continue
    if cur is None:
        continue
    mode_m = re.match(r"^\s*(\d+x\d+)\s+(.*)$", line)
    if not mode_m:
        continue
    mode, rest = mode_m.groups()
    if mode != "1920x1080":
        continue
    for tok in rest.split():
        rate = tok.rstrip("*+")
        try:
            rate_f = float(rate)
        except ValueError:
            continue
        cur["rates"].append(rate_f)
        if "*" in tok:
            cur["currentRate"] = rate_f

for mon in monitors:
    mon["primary"] = mon["name"] == primary_name
    mon["rates"].sort(reverse=True)

print(json.dumps(monitors))
