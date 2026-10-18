class_name SampleLibrary
extends RefCounted
## Only processed, game-used derivatives. Missing assets never prevent synthesis.
const MANIFEST: String = "res://assets/audio/manifest.json"
var enabled: bool = true
var samples: Dictionary = {}
var manifest: Dictionary = {}
var _last_variant: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	_rng.randomize()
	if not FileAccess.file_exists(MANIFEST): return
	var decoded: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if not decoded is Dictionary: return
	manifest = decoded
	for row: Dictionary in manifest.get("outputs", []):
		var path: String = "res://assets/audio/" + str(row["file"])
		if not ResourceLoader.exists(path): continue
		var wav: AudioStreamWAV = load(path) as AudioStreamWAV
		if wav == null: continue
		# Duplicate to avoid changing the global resource cache when forcing loops.
		wav = wav.duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD if row["loop"] else AudioStreamWAV.LOOP_DISABLED
		wav.loop_begin = 0
		wav.loop_end = int(row["frames"])
		var key: String = row["key"]
		if not samples.has(key): samples[key] = []
		samples[key].append(wav)
	for alias: String in manifest.get("aliases", {}):
		var target: String = manifest["aliases"][alias]
		if samples.has(target): samples[alias] = samples[target]

func has(key: String) -> bool:
	return enabled and samples.has(key) and not samples[key].is_empty()

func pick(key: String) -> AudioStream:
	if not has(key): return null
	var choices: Array = samples[key]
	var index: int = _rng.randi_range(0, choices.size()-1)
	if choices.size() > 1 and index == int(_last_variant.get(key, -1)):
		index = (index + 1) % choices.size()
	_last_variant[key] = index
	return choices[index]

func clear() -> void:
	samples.clear()
