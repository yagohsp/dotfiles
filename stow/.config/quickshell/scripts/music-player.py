#!/usr/bin/env python3
"""Headless mpv player for YouTube Music."""

from __future__ import annotations

import argparse
import json
import os
import random
import socket
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

SOCKET_PATH = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "quickshell-music.sock"
QUEUE_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "quickshell-music-queue.json"


def emit(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False), flush=True)


def mpv_request(payload: dict[str, Any], timeout: float = 2.0) -> dict[str, Any] | None:
    if not SOCKET_PATH.exists():
        return None
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        sock.connect(SOCKET_PATH.as_posix())
        sock.sendall((json.dumps(payload) + "\n").encode())
        chunks: list[bytes] = []
        while True:
            part = sock.recv(4096)
            if not part:
                break
            chunks.append(part)
            if b"\n" in part:
                break
        if not chunks:
            return None
        line = b"".join(chunks).split(b"\n", 1)[0]
        return json.loads(line.decode())
    except (OSError, TimeoutError, json.JSONDecodeError):
        return None
    finally:
        sock.close()


def mpv_command(*args: Any) -> dict[str, Any] | None:
    return mpv_request({"command": list(args)})


def mpv_property(name: str) -> Any:
    response = mpv_request({"command": ["get_property", name]})
    if not response or response.get("error") != "success":
        return None
    return response.get("data")


def ensure_mpv() -> None:
    if mpv_property("idle-active") is not None:
        return

    SOCKET_PATH.unlink(missing_ok=True)
    subprocess.Popen(
        [
            "mpv",
            "--no-video",
            "--really-quiet",
            "--idle=yes",
            "--keep-open=yes",
            f"--input-ipc-server={SOCKET_PATH.as_posix()}",
            "--ytdl=yes",
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )

    for _ in range(40):
        if mpv_property("idle-active") is not None:
            return
        time.sleep(0.05)
    raise RuntimeError("mpv failed to start")


def song_url(video_id: str) -> str:
    return f"https://music.youtube.com/watch?v={video_id}"


def load_queue() -> dict[str, Any]:
    if not QUEUE_FILE.is_file():
        return {"videoIds": [], "shuffle": False, "source": ""}
    try:
        return json.loads(QUEUE_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {"videoIds": [], "shuffle": False, "source": ""}


def save_queue(state: dict[str, Any]) -> None:
    QUEUE_FILE.parent.mkdir(parents=True, exist_ok=True)
    QUEUE_FILE.write_text(json.dumps(state, ensure_ascii=False), encoding="utf-8")


def build_playback_order(video_ids: list[str], start_index: int, shuffle: bool) -> list[str]:
    if not video_ids:
        return []
    start_index = max(0, min(start_index, len(video_ids) - 1))
    current = video_ids[start_index]
    rest = video_ids[start_index + 1 :]
    if shuffle and rest:
        rest = rest.copy()
        random.shuffle(rest)
    return [current, *rest]


def load_playback_order(order: list[str]) -> None:
    if not order:
        raise RuntimeError("empty queue")
    ensure_mpv()
    for index, video_id in enumerate(order):
        mode = "replace" if index == 0 else "append"
        response = mpv_command("loadfile", song_url(video_id), mode)
        if not response or response.get("error") != "success":
            raise RuntimeError("failed to start playback")


def current_video_id() -> str:
    filename = mpv_property("filename") or ""
    if "watch?v=" in filename:
        return filename.split("watch?v=", 1)[1].split("&", 1)[0]
    return ""


def rebuild_from_current(state: dict[str, Any]) -> None:
    video_ids = state.get("videoIds") or []
    shuffle = bool(state.get("shuffle"))
    if not video_ids:
        return

    playing = current_video_id()
    if playing and playing in video_ids:
        start_index = video_ids.index(playing)
    else:
        pos = mpv_property("playlist-pos")
        start_index = int(pos or 0)
        start_index = max(0, min(start_index, len(video_ids) - 1))

    order = build_playback_order(video_ids, start_index, shuffle)
    pos_before = mpv_property("time-pos")
    load_playback_order(order)
    if pos_before:
        mpv_command("set_property", "time-pos", pos_before)


def metadata() -> dict[str, Any]:
    meta = mpv_property("metadata") or {}
    filename = mpv_property("filename") or ""
    video_id = current_video_id()

    idle_active = mpv_property("idle-active")
    paused = bool(mpv_property("pause"))
    duration = mpv_property("duration")
    position = mpv_property("time-pos")
    playlist_pos = mpv_property("playlist-pos")
    playlist_count = mpv_property("playlist-count")

    title = meta.get("title") or meta.get("Title") or ""
    artist = meta.get("artist") or meta.get("Artist") or meta.get("uploader") or ""

    active = idle_active is not None and not bool(idle_active)
    state = load_queue()

    return {
        "active": active,
        "paused": paused,
        "title": title,
        "artist": artist,
        "position": float(position or 0),
        "duration": float(duration or 0),
        "videoId": video_id,
        "shuffle": bool(state.get("shuffle")),
        "queueLength": int(playlist_count or 0),
        "queuePosition": int(playlist_pos or 0) + 1 if active and playlist_count else 0,
    }


def cmd_status(_: argparse.Namespace) -> None:
    emit(metadata())


def cmd_play(args: argparse.Namespace) -> None:
    if not args.video_id:
        emit({"status": "error", "message": "video id required"})
        raise SystemExit(1)

    try:
        load_playback_order([args.video_id])
    except RuntimeError as exc:
        emit({"status": "error", "message": str(exc)})
        raise SystemExit(1) from exc

    save_queue({"videoIds": [args.video_id], "shuffle": False, "source": "song"})
    emit({"status": "ok"})


def cmd_play_queue(args: argparse.Namespace) -> None:
    video_ids = [part.strip() for part in args.video_ids.split(",") if part.strip()]
    if not video_ids:
        emit({"status": "error", "message": "empty queue"})
        raise SystemExit(1)

    start_index = max(0, min(args.index, len(video_ids) - 1))
    shuffle = bool(args.shuffle)
    order = build_playback_order(video_ids, start_index, shuffle)

    try:
        load_playback_order(order)
    except RuntimeError as exc:
        emit({"status": "error", "message": str(exc)})
        raise SystemExit(1) from exc

    save_queue({"videoIds": video_ids, "shuffle": shuffle, "source": "playlist"})
    emit({"status": "ok"})


def cmd_set_shuffle(args: argparse.Namespace) -> None:
    state = load_queue()
    video_ids = state.get("videoIds") or []
    if len(video_ids) < 2:
        state["shuffle"] = bool(args.enabled)
        save_queue(state)
        emit({"status": "ok", "shuffle": state["shuffle"]})
        return

    state["shuffle"] = bool(args.enabled)
    save_queue(state)
    try:
        rebuild_from_current(state)
    except RuntimeError as exc:
        emit({"status": "error", "message": str(exc)})
        raise SystemExit(1) from exc
    emit({"status": "ok", "shuffle": state["shuffle"]})


def cmd_seek(args: argparse.Namespace) -> None:
    ensure_mpv()
    response = mpv_command("set_property", "time-pos", max(0.0, args.seconds))
    if not response or response.get("error") != "success":
        emit({"status": "error", "message": "seek failed"})
        raise SystemExit(1)
    emit({"status": "ok"})


def cmd_control(args: argparse.Namespace) -> None:
    ensure_mpv()
    action = args.action
    mapping = {
        "play-pause": ("cycle", "pause"),
        "next": ("playlist-next", "weak"),
        "prev": ("playlist-prev", "weak"),
        "stop": ("stop",),
    }
    if action not in mapping:
        emit({"status": "error", "message": f"unknown action {action}"})
        raise SystemExit(1)

    response = mpv_command(*mapping[action])
    if not response or response.get("error") != "success":
        emit({"status": "error", "message": f"{action} failed"})
        raise SystemExit(1)

    if action == "stop":
        save_queue({"videoIds": [], "shuffle": False, "source": ""})

    emit({"status": "ok"})


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("status")

    play = sub.add_parser("play")
    play.add_argument("--video-id")

    play_queue = sub.add_parser("play-queue")
    play_queue.add_argument("--video-ids")
    play_queue.add_argument("--index", type=int, default=0)
    play_queue.add_argument("--shuffle", choices=("true", "false"), default="false")

    shuffle = sub.add_parser("set-shuffle")
    shuffle.add_argument("enabled", choices=("true", "false"))

    seek = sub.add_parser("seek")
    seek.add_argument("seconds", type=float)

    control = sub.add_parser("control")
    control.add_argument("action", choices=("play-pause", "next", "prev", "stop"))

    args = parser.parse_args()
    if args.command == "status":
        cmd_status(args)
    elif args.command == "play":
        cmd_play(args)
    elif args.command == "play-queue":
        cmd_play_queue(args)
    elif args.command == "set-shuffle":
        args.enabled = args.enabled == "true"
        cmd_set_shuffle(args)
    elif args.command == "seek":
        cmd_seek(args)
    elif args.command == "control":
        cmd_control(args)
    else:
        raise SystemExit(f"unknown command {args.command}")


if __name__ == "__main__":
    main()
