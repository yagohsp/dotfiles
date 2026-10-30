#!/usr/bin/env python3
"""Poll CPU usage and top processes for Quickshell."""

from __future__ import annotations

import json
import subprocess
import time


def read_cpu_times() -> tuple[int, int]:
    with open("/proc/stat", encoding="utf-8") as fh:
        parts = fh.readline().split()
    values = [int(x) for x in parts[1:8]]
    idle = values[3] + values[4]
    total = sum(values)
    return total, idle


def cpu_percent(previous: tuple[int, int] | None) -> tuple[int, tuple[int, int]]:
    current = read_cpu_times()
    if previous is None:
        time.sleep(0.2)
        current = read_cpu_times()
        return 0, current

    total_delta = current[0] - previous[0]
    idle_delta = current[1] - previous[1]
    if total_delta <= 0:
        return 0, current

    usage = round(100 * (1 - idle_delta / total_delta))
    return max(0, min(100, usage)), current


def top_processes(limit: int = 100) -> list[dict[str, object]]:
    result = subprocess.run(
        ["ps", "-eo", "pid,comm,pcpu", "--no-headers", "--sort=-pcpu"],
        capture_output=True,
        text=True,
        check=False,
    )
    processes: list[dict[str, object]] = []
    for line in result.stdout.splitlines():
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        pid_s, name, cpu_s = parts
        try:
            pid = int(pid_s)
            cpu = float(cpu_s)
        except ValueError:
            continue
        if pid <= 0:
            continue
        processes.append({"pid": pid, "name": name, "cpu": round(cpu, 1)})
        if len(processes) >= limit:
            break
    return processes


def main() -> None:
    prev: tuple[int, int] | None = None
    while True:
        usage, prev = cpu_percent(prev)
        payload = {"cpu": usage, "processes": top_processes()}
        print(json.dumps(payload, ensure_ascii=False), flush=True)
        time.sleep(2)


if __name__ == "__main__":
    main()
