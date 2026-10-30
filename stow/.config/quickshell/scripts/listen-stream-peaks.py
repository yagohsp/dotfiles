#!/usr/bin/env python3
"""Emit per-stream audio peak levels as JSON lines for Quickshell."""

from __future__ import annotations

import json
import select
import struct
import subprocess
import threading
import time

RATE = 8000
CHUNK_SAMPLES = 256
EMIT_INTERVAL = 0.1
POLL_INTERVAL = 0.25
RISE = 0.55
FALL = 0.82
SILENCE_DECAY = 0.75
DISPLAY_GAIN = 3.0
READ_TIMEOUT = 0.12


def wait_for_pulse() -> None:
    while True:
        try:
            subprocess.run(
                ["pactl", "info"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True,
            )
            return
        except (subprocess.CalledProcessError, FileNotFoundError):
            time.sleep(0.5)


def list_stream_indices() -> list[int]:
    try:
        raw = subprocess.check_output(
            ["pactl", "-f", "json", "list", "sink-inputs"],
            text=True,
        )
        inputs = json.loads(raw)
    except (subprocess.CalledProcessError, json.JSONDecodeError, FileNotFoundError):
        return []

    return [int(entry["index"]) for entry in inputs if entry.get("index") is not None]


class StreamMonitor:
    def __init__(self, index: int) -> None:
        self.index = index
        self.peak = 0.0
        self._stop = threading.Event()
        self._proc: subprocess.Popen[bytes] | None = None
        self._thread: threading.Thread | None = None

    def start(self) -> None:
        self._proc = subprocess.Popen(
            [
                "parec",
                f"--monitor-stream={self.index}",
                "--format=s16le",
                "--channels=1",
                f"--rate={RATE}",
                "--latency-msec=25",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        self._thread = threading.Thread(target=self._read_loop, daemon=True)
        self._thread.start()

    def _read_loop(self) -> None:
        assert self._proc and self._proc.stdout
        chunk_bytes = CHUNK_SAMPLES * 2
        fd = self._proc.stdout.fileno()

        while not self._stop.is_set():
            if self._proc.poll() is not None:
                break

            ready, _, _ = select.select([fd], [], [], READ_TIMEOUT)
            if not ready:
                self.peak *= SILENCE_DECAY
                continue

            try:
                data = self._proc.stdout.read(chunk_bytes)
            except OSError:
                break

            if not data or len(data) < 2:
                self.peak *= SILENCE_DECAY
                continue

            count = len(data) // 2
            samples = struct.unpack(f"<{count}h", data[: count * 2])
            instant = max(abs(sample) for sample in samples) / 32768.0
            if instant >= self.peak:
                self.peak += (instant - self.peak) * RISE
            else:
                self.peak = self.peak * FALL + instant * (1.0 - FALL)

    def stop(self) -> None:
        self._stop.set()
        if self._proc and self._proc.poll() is None:
            self._proc.terminate()
            try:
                self._proc.wait(timeout=1)
            except subprocess.TimeoutExpired:
                self._proc.kill()


def main() -> int:
    wait_for_pulse()
    monitors: dict[int, StreamMonitor] = {}
    last_poll = 0.0
    last_emit = 0.0

    while True:
        now = time.time()

        if now - last_poll >= POLL_INTERVAL:
            active = set(list_stream_indices())

            for index in list(monitors):
                if index not in active:
                    monitors[index].stop()
                    del monitors[index]

            for index in active:
                if index not in monitors:
                    monitor = StreamMonitor(index)
                    monitor.start()
                    monitors[index] = monitor

            last_poll = now

        if now - last_emit >= EMIT_INTERVAL:
            payload = {
                str(index): round(min(1.0, monitor.peak * DISPLAY_GAIN), 4)
                for index, monitor in monitors.items()
            }
            print(json.dumps(payload), flush=True)
            last_emit = now

        time.sleep(0.02)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(0)
