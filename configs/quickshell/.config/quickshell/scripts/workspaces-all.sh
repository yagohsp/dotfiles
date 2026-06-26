#!/usr/bin/env python3
import json, os, subprocess, sys

WS_NAMES = {1:"1:A",2:"2:S",3:"3:D",4:"4:F",5:"5:Z",6:"6:X",7:"7:C",8:"8:V"}

icon_cache: dict[str, str] = {}

def find_icon(cls: str) -> str:
    key = cls.lower()
    if key in icon_cache:
        return icon_cache[key]
    result = ""
    for base in (
        f"/usr/share/icons/hicolor/scalable/apps/{key}",
        f"/usr/share/icons/hicolor/48x48/apps/{key}",
        f"/usr/share/pixmaps/{key}",
    ):
        for ext in ("svg", "png", "xpm"):
            path = f"{base}.{ext}"
            if os.path.exists(path):
                result = f"file://{path}"
                break
        if result:
            break
    if not result:
        for ext in ("svg", "png"):
            try:
                out = subprocess.run(
                    ["find", "/usr/share/icons", "-path", f"*/apps/{key}.{ext}"],
                    capture_output=True, text=True, timeout=3
                ).stdout.strip()
                if out:
                    result = f"file://{out.splitlines()[0]}"
                    break
            except Exception:
                pass
    icon_cache[key] = result
    return result

def load_monitors() -> tuple[str, str]:
    env = {}
    with open(os.path.expanduser("~/dotfiles/monitors.env")) as f:
        for line in f:
            line = line.strip().lstrip("export ")
            if "=" in line:
                k, _, v = line.partition("=")
                env[k] = v.strip('"')
    return env.get("PRIMARY_MONITOR", ""), env.get("SECONDARY_MONITOR", "")

def collect_windows(node: dict, result: dict, ws_num: int | None = None) -> None:
    if node.get("type") == "workspace":
        ws_num = node.get("num")
        result.setdefault(ws_num, [])
    if ws_num is not None and node.get("window") is not None:
        cls = node.get("window_properties", {}).get("class", "")
        if cls and cls not in result[ws_num]:
            result[ws_num].append(cls)
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        collect_windows(child, result, ws_num)

def emit() -> None:
    primary, secondary = load_monitors()
    ws_list = json.loads(subprocess.run(
        ["i3-msg", "-t", "get_workspaces"], capture_output=True, text=True
    ).stdout)
    tree = json.loads(subprocess.run(
        ["i3-msg", "-t", "get_tree"], capture_output=True, text=True
    ).stdout)

    ws_map = {w["num"]: w for w in ws_list}
    win_map: dict[int, list[str]] = {}
    collect_windows(tree, win_map)

    out = []
    for i in range(1, 9):
        ws = ws_map.get(i)
        classes = win_map.get(i, [])
        icons = [ic for ic in (find_icon(c) for c in classes) if ic]
        out.append({
            "id": i,
            "name": WS_NAMES[i],
            "active": ws["focused"] if ws else False,
            "occupied": len(classes) > 0,
            "monitor": ws["output"] if ws else (primary if i <= 4 else secondary),
            "icons": icons,
        })
    print(json.dumps(out), flush=True)

emit()

proc = subprocess.Popen(
    ["i3-msg", "-t", "subscribe", "-m", '["workspace", "window"]'],
    stdout=subprocess.PIPE, text=True
)
for _ in proc.stdout:
    emit()
