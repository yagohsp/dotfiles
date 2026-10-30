#!/usr/bin/env python3
"""Poll memory usage and top processes for Quickshell."""

from __future__ import annotations

import json
import subprocess
import time


def read_meminfo() -> dict[str, int]:
    info: dict[str, int] = {}
    with open("/proc/meminfo", encoding="utf-8") as fh:
        for line in fh:
            key, value = line.split(":", 1)
            info[key] = int(value.strip().split()[0])
    return info


def memory_percent() -> int:
    info = read_meminfo()
    total = info.get("MemTotal", 0)
    if total <= 0:
        return 0

    available = info.get("MemAvailable")
    if available is None:
        free = info.get("MemFree", 0)
        buffers = info.get("Buffers", 0)
        cached = info.get("Cached", 0)
        sreclaim = info.get("SReclaimable", 0)
        available = free + buffers + cached + sreclaim

    used = max(0, total - available)
    return max(0, min(100, round(100 * used / total)))


def top_processes(limit: int = 100) -> list[dict[str, object]]:
    result = subprocess.run(
        ["ps", "-eo", "pid,comm,pmem", "--no-headers", "--sort=-pmem"],
        capture_output=True,
        text=True,
        check=False,
    )
    processes: list[dict[str, object]] = []
    for line in result.stdout.splitlines():
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        pid_s, name, mem_s = parts
        try:
            pid = int(pid_s)
            mem = float(mem_s)
        except ValueError:
            continue
        if pid <= 0:
            continue
        processes.append({"pid": pid, "name": name, "mem": round(mem, 1)})
        if len(processes) >= limit:
            break
    return processes


def main() -> None:
    while True:
        payload = {"mem": memory_percent(), "processes": top_processes()}
        print(json.dumps(payload, ensure_ascii=False), flush=True)
        time.sleep(2)


if __name__ == "__main__":
    main()
