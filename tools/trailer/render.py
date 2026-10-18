"""Render trailer shots with Godot's Movie Maker (one AVI per shot).

    python tools/trailer/render.py --godot PATH [--out DIR] [--debug] [SHOT_ID ...]

A temporary override.cfg makes the window 1920x1080 for the recording (Movie Maker
records the startup window size) and is removed afterwards. Stops on SCRIPT ERROR.
"""
import argparse
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OVERRIDE = ROOT / "override.cfg"
OVERRIDE_TEXT = "[display]\n\nwindow/size/window_width_override=1920\nwindow/size/window_height_override=1080\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    parser.add_argument("--out", default=str(ROOT / "captures" / "trailer" / "raw"))
    parser.add_argument("--debug", action="store_true", help="stamp shot/frame in the corner")
    parser.add_argument("shots", nargs="*")
    args = parser.parse_args()
    data = json.loads((ROOT / "tools" / "trailer" / "shots.json").read_text(encoding="utf-8"))
    wanted = args.shots or [shot["id"] for shot in data["shots"]]
    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    (out / "logs").mkdir(exist_ok=True)
    existed = OVERRIDE.exists()
    if not existed:
        OVERRIDE.write_text(OVERRIDE_TEXT, encoding="ascii")
    try:
        for shot_id in wanted:
            target = out / f"{shot_id}.avi"
            command = [args.godot, "--path", str(ROOT), "--fullscreen", "--write-movie", str(target),
                       "res://scenes/Trailer.tscn", "--", f"--shot={shot_id}"]
            if args.debug:
                command.append("--trailer-debug")
            result = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=600)
            log = result.stdout + result.stderr
            (out / "logs" / f"{shot_id}.log").write_text(log, encoding="utf-8")
            frames = [line for line in log.splitlines() if "frames at" in line]
            print(shot_id, frames[0].strip() if frames else "NO MOVIE", flush=True)
            if "SCRIPT ERROR" in log or not target.exists():
                print(log[-3000:])
                return 1
    finally:
        if not existed and OVERRIDE.exists():
            OVERRIDE.unlink()
    return 0


if __name__ == "__main__":
    sys.exit(main())
