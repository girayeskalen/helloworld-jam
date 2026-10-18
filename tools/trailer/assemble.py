"""Assemble the trailer: trim each Movie Maker shot, join them, lay the music bed
under the game's own sound effects and encode the final MP4.

    python tools/trailer/assemble.py --ffmpeg PATH --raw DIR [--out DIR]

Requires ffmpeg/ffprobe (same folder) and numpy. Music: Gregor Quendel, "Cinematic
Epic Trailer (With SFX)" (CC BY 4.0, tools/trailer/music/KAYNAK.md), cut so its
drop, second section, biggest impact and final hit land on the key cuts; a soft
CC0 drone (bed_dark_place) under the title. The game's event sounds sit ~5 dB below
the score; only the loudest moments duck it, by at most 2 dB. Also writes a version
with only the game's sound.
"""
import argparse
import json
import pathlib
import subprocess
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
RATE = 48000
MUSIC = ROOT / "assets" / "audio" / "music"
SFX = ROOT / "assets" / "audio" / "sfx"
TRAILER_MUSIC = ROOT / "tools" / "trailer" / "music" / "gregor_quendel_cinematic_epic_trailer_with_sfx.mp3"


def run(command):
    result = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if result.returncode != 0:
        print(" ".join(map(str, command)))
        print(result.stderr[-3000:])
        raise SystemExit(1)
    return result


def decode(ffmpeg, path, extra=()):
    """Any audio file -> float32 stereo array at RATE."""
    out = subprocess.run([ffmpeg, "-v", "error", "-i", str(path), *extra, "-f", "f32le", "-ac", "2", "-ar", str(RATE), "-"], capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.float32).reshape(-1, 2).copy()


def place(track, clip, at, gain_db=0.0, fade_in=0.0, fade_out=0.0):
    start = int(round(at * RATE))
    clip = clip.copy() * (10 ** (gain_db / 20))
    if fade_in > 0:
        n = min(len(clip), int(fade_in * RATE))
        clip[:n] *= np.linspace(0, 1, n)[:, None]
    if fade_out > 0:
        n = min(len(clip), int(fade_out * RATE))
        clip[-n:] *= np.linspace(1, 0, n)[:, None]
    end = min(len(track), start + len(clip))
    if end > start:
        track[start:end] += clip[: end - start]


def segment(audio, start, length):
    a = int(round(start * RATE))
    return audio[a: a + int(round(length * RATE))]


def envelope(signal, window=0.05):
    mono = np.abs(signal).mean(axis=1)
    n = int(window * RATE)
    kernel = np.ones(n) / n
    return np.sqrt(np.convolve(mono ** 2, kernel, mode="same"))


def smooth_gain(target_db, attack=0.02, release=0.3):
    out = np.empty_like(target_db)
    a = np.exp(-1.0 / (attack * RATE))
    r = np.exp(-1.0 / (release * RATE))
    level = 0.0
    # Downsample for speed: one control value per 1 ms.
    step = RATE // 1000
    coarse = target_db[::step]
    smoothed = np.empty_like(coarse)
    a1 = np.exp(-1.0 / (attack * 1000))
    r1 = np.exp(-1.0 / (release * 1000))
    for i, value in enumerate(coarse):
        coef = a1 if value < level else r1
        level = coef * level + (1 - coef) * value
        smoothed[i] = level
    out = np.repeat(smoothed, step)[: len(target_db)]
    if len(out) < len(target_db):
        out = np.pad(out, (0, len(target_db) - len(out)), mode="edge")
    return out


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ffmpeg", required=True)
    parser.add_argument("--raw", required=True)
    parser.add_argument("--out", default=str(ROOT / "exports" / "trailer"))
    args = parser.parse_args()
    ffmpeg = pathlib.Path(args.ffmpeg)
    raw = pathlib.Path(args.raw)
    out = pathlib.Path(args.out)
    work = out / "work"
    work.mkdir(parents=True, exist_ok=True)
    data = json.loads((ROOT / "tools" / "trailer" / "shots.json").read_text(encoding="utf-8"))
    total = float(data["total"])

    # 1. Trim every shot to its frames (preroll removed); 10 ms audio fades at cuts.
    clips = []
    for shot in data["shots"]:
        clip = work / f"{shot['id']}.mkv"
        length = shot["frames"] / 60.0
        # Input seek (exact on all-intra MJPEG) restarts both streams at zero.
        run([ffmpeg, "-v", "error", "-y", "-ss", f"{shot['preroll']:.4f}", "-i", str(raw / f"{shot['id']}.avi"),
             "-frames:v", str(shot["frames"]), "-vf", "scale=in_range=pc:out_range=tv,format=yuv420p", "-color_range", "tv",
             "-c:v", "libx264", "-preset", "fast", "-crf", "10", "-r", "60",
             "-af", f"aresample={RATE},apad,atrim=0:{length:.4f},afade=t=in:d=0.01,afade=t=out:st={length - 0.01:.4f}:d=0.01",
             "-c:a", "pcm_s16le", "-ar", str(RATE), "-ac", "2", str(clip)])
        clips.append(clip)
    listing = work / "clips.txt"
    listing.write_text("".join(f"file '{c.as_posix()}'\n" for c in clips), encoding="utf-8")
    joined = work / "joined.mkv"
    run([ffmpeg, "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(listing), "-c", "copy", str(joined)])

    # 2. Music bed + game SFX.
    samples = int(round(total * RATE))
    # A gentle top cut keeps any remaining game hiss under the score.
    sfx = decode(ffmpeg, joined, ("-af", "lowpass=f=7000"))[:samples]
    sfx = np.pad(sfx, ((0, samples - len(sfx)), (0, 0)))
    music = np.zeros((samples, 2), dtype=np.float32)
    extras = np.zeros((samples, 2), dtype=np.float32)
    bed = decode(ffmpeg, MUSIC / "bed_dark_place.ogg")
    score = decode(ffmpeg, TRAILER_MUSIC)
    score_soft = decode(ffmpeg, TRAILER_MUSIC, ("-af", "lowpass=f=1400"))
    starts = {}
    cursor = 0
    for shot in data["shots"]:
        starts[shot["id"]] = cursor / 60.0
        cursor += shot["frames"]
    hook_end, day1 = starts["T1"], starts["D1"]
    karne_from, karne_to = starts["K1"], starts["K2"]
    second, day4, hit, title = starts["P4"], starts["X1"], starts["V1"], starts["TT"]
    # Music edit (seconds in the Gregor Quendel track, measured onsets): the cold open
    # rides the climax so its biggest hit (51.75) lands on the storm->flood cut; the
    # quiet build (10.8-18.0) runs under the black card and preparation so the drop
    # (18.0) lands on "1. GÜN"; the second section (50.15) lands on "4. GÜN" with the
    # 51.75 impact on "Ve hepsi birden"; the final hit (73.98) lands on the victory.
    DROP, SECOND, BIG, FINAL = 17.995, 50.149, 51.751, 73.979
    hook_from = BIG - starts["H3"]
    build_from = DROP - (day1 - hook_end)
    late_from = SECOND - (day4 - second)
    segments = [
        (0.0, hook_end, hook_from, 0.0, 0.04, 0.0),
        (hook_end, day1, build_from, 0.02, 0.0, 5.0),  # the quiet build, lifted
        (day1, second, DROP, 0.0, 0.06, 0.0),
        (second, hit, late_from, 0.06, 0.04, 0.0),
        (hit, total, FINAL, 0.0, 0.0, 0.0),
    ]
    for video_from, video_to, music_from, fade_in, fade_out, gain in segments:
        length = video_to - video_from
        piece = segment(score, music_from, length)
        if video_from == day1:
            # Under the karne the score softens (low-pass, -3 dB) so the reasons read.
            soft = segment(score_soft, music_from, length)
            t = np.arange(len(piece)) / RATE + video_from
            dip = np.clip((t - karne_from) / 0.3, 0, 1) * np.clip((karne_to - t) / 0.3, 0, 1)
            piece = piece * (1 - dip)[:, None] + soft * (dip * 10 ** (-3 / 20))[:, None]
        place(music, piece, video_from, gain, fade_in=fade_in, fade_out=fade_out)
    # Under the black card and the preparation a low drone and a riser carry the
    # tension into the drop on "1. GÜN".
    place(music, segment(bed, 14.0, day1 - hook_end), hook_end, -9.0, fade_in=0.4, fade_out=0.1)
    riser = decode(ffmpeg, SFX / "intro_riser_01.wav")
    place(extras, riser, day1 - len(riser) / RATE, -3.0)
    # A low drone keeps the title card from going silent after the final hit decays.
    place(music, segment(bed, 14.0, total - title), title, -8.0, fade_in=1.2, fade_out=0.8)
    # Accents from the game's own processed effects: the black-card boom and the two
    # day cards the score does not already hit.
    boom = decode(ffmpeg, SFX / "boom_01.wav")
    place(extras, boom, hook_end, -3.0)
    impact = decode(ffmpeg, SFX / "intro_hit_01.wav")
    for day in ("S1", "F1"):
        place(extras, impact, starts[day], -6.0)

    # The music drives the cut: it sits ~6 dB above the game sounds and only the
    # loudest game moments (tremor, impacts) duck it, by at most ~2 dB.
    level = 20 * np.log10(envelope(sfx) + 1e-6)
    duck_db = -2.0 * np.clip((level + 18.0) / 10.0, 0, 1)
    music *= (10 ** (smooth_gain(duck_db) / 20))[:, None]
    fade = int(0.8 * RATE)

    def write_mix(name, signal):
        signal = signal.copy()
        signal[-fade:] *= np.linspace(1, 0, fade)[:, None]  # whole mix fades out over 0.8 s
        peak = float(np.abs(signal).max())
        if peak > 0.98:
            signal *= 0.98 / peak
        raw_path = work / (name + ".f32")
        signal.astype(np.float32).tofile(raw_path)
        wav_path = work / (name + ".wav")
        run([ffmpeg, "-v", "error", "-y", "-f", "f32le", "-ar", str(RATE), "-ac", "2", "-i", str(raw_path), "-c:a", "pcm_s24le", str(wav_path)])
        return wav_path

    with_music = write_mix("mix", music + sfx * 10 ** (-5.0 / 20) + extras)
    # Same picture with only the game's own sound, for teams that score it themselves.
    game_only = write_mix("mix_game_only", sfx + extras)

    # 3. Two-pass loudness normalisation (-14 LUFS, -1.5 dBTP) and the final encodes.
    def encode(wav_path, targets):
        measure = run([ffmpeg, "-hide_banner", "-i", str(wav_path), "-af", "loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json", "-f", "null", "-"]).stderr
        stats = json.loads(measure[measure.rindex("{"): measure.rindex("}") + 1])
        loudnorm = ("loudnorm=I=-14:TP=-1.5:LRA=11:linear=true:measured_I={input_i}:measured_TP={input_tp}:measured_LRA={input_lra}:"
                    "measured_thresh={input_thresh}:offset={target_offset}").format(**stats)
        for target, crf in targets:
            run([ffmpeg, "-v", "error", "-y", "-i", str(joined), "-i", str(wav_path), "-map", "0:v", "-map", "1:a", "-c:v", "libx264", "-preset", "slow",
                 "-crf", crf, "-pix_fmt", "yuv420p", "-color_range", "tv", "-colorspace", "bt709", "-color_primaries", "bt709", "-color_trc", "bt709", "-profile:v", "high", "-r", "60", "-af", loudnorm + f",aresample={RATE}", "-c:a", "aac", "-b:a", "192k",
                 "-ar", str(RATE), "-t", f"{total:.3f}", "-movflags", "+faststart", str(target)])
            print("wrote", target, target.stat().st_size, "bytes")

    final = out / "4GUN_Fragman.mp4"
    encode(with_music, ((final, "17"), (out / "4GUN_Fragman_kucuk.mp4", "24")))
    encode(game_only, ((out / "4GUN_Fragman_muziksiz.mp4", "17"),))

    # 4. QA: one frame per second as a 6x10 sheet.
    qa = out / "qa"
    qa.mkdir(exist_ok=True)
    run([ffmpeg, "-v", "error", "-y", "-i", str(final), "-vf", "fps=1,scale=320:-1,tile=6x10", "-frames:v", "1", str(qa / "contact.png")])
    return 0


if __name__ == "__main__":
    sys.exit(main())
