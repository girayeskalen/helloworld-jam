"""Export the Windows and Linux builds and pack the jam ZIPs.

    python tools/package/package.py --godot PATH [--only windows|linux]

Uses export_presets.cfg ("Windows Desktop", "Linux"; embedded PCK) and the export
templates installed for that Godot version. Each ZIP holds the executable,
OYNA_BENI.txt and GODOT_LISANS.txt (the engine's own license text).
"""
import argparse
import pathlib
import subprocess
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUILDS = {
    "windows": ("Windows Desktop", "exports/build/windows/4GUN.exe", "exports/4GUN_Windows.zip"),
    "linux": ("Linux", "exports/build/linux/4GUN.x86_64", "exports/4GUN_Linux.zip"),
}
LICENSE_SCRIPT = """extends SceneTree
func _initialize() -> void:
	print("@@LICENSE@@")
	print(Engine.get_license_text())
	print("\\n=== Godot Engine: ucuncu taraf bilesenler ===")
	for component: Dictionary in Engine.get_copyright_info():
		print("\\n- " + str(component["name"]))
		for part: Dictionary in component["parts"]:
			for holder: String in part["copyright"]: print("  (c) " + holder)
			print("  Lisans: " + str(part["license"]))
	var texts: Dictionary = Engine.get_license_info()
	for name: String in texts:
		print("\\n=== " + name + " ===\\n" + str(texts[name]))
	quit(0)
"""


def license_text(godot: str) -> str:
    script = ROOT / "exports" / "_license.gd"
    script.parent.mkdir(parents=True, exist_ok=True)
    script.write_text(LICENSE_SCRIPT, encoding="utf-8")
    try:
        out = subprocess.run([godot, "--headless", "--script", str(script)], capture_output=True, text=True, encoding="utf-8", errors="replace").stdout
    finally:
        script.unlink(missing_ok=True)
    body = out.split("@@LICENSE@@", 1)[-1].strip()
    return "Godot Engine (https://godotengine.org) — MIT lisansı\n\n" + body + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    parser.add_argument("--only", choices=sorted(BUILDS))
    args = parser.parse_args()
    commit = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip() or "?"
    dirty = subprocess.run(["git", "-C", str(ROOT), "status", "--porcelain", "--", "scripts", "scenes", "project.godot", "export_presets.cfg", "assets"],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print("UYARI: build girdilerinde commit edilmemiş değişiklik var; ZIP repo sürümüyle birebir olmayabilir:\n" + dirty)
    readme = (ROOT / "tools" / "package" / "OYNA_BENI.txt").read_text(encoding="utf-8").replace("{COMMIT}", commit)
    godot_license = license_text(args.godot)
    for key, (preset, binary, archive) in BUILDS.items():
        if args.only and key != args.only:
            continue
        target = ROOT / binary
        target.parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run([args.godot, "--headless", "--path", str(ROOT), "--export-release", preset, str(target)],
                                capture_output=True, text=True, encoding="utf-8", errors="replace")
        log = result.stdout + result.stderr
        if result.returncode != 0 or not target.exists() or "SCRIPT ERROR" in log:
            print(log[-3000:])
            return 1
        zip_path = ROOT / archive
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as pack:
            info = zipfile.ZipInfo(target.name)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = (0o755 << 16) if key == "linux" else 0
            pack.writestr(info, target.read_bytes())
            pack.writestr("OYNA_BENI.txt", readme)
            pack.writestr("GODOT_LISANS.txt", godot_license)
        print(f"{key}: {target.stat().st_size} B -> {zip_path} {zip_path.stat().st_size} B")
    return 0


if __name__ == "__main__":
    sys.exit(main())
