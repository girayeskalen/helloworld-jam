class_name AmbienceDirector
extends RefCounted
const KEYS: Array[String] = ["amb_rain", "amb_wind", "amb_hail", "amb_water", "amb_interior", "amb_quake"]
const FADE: float = 1.5
const STATES: Dictionary = {
	"menu": {"amb_rain": -18.0, "amb_interior": -26.0},
	"preparation": {"amb_rain": -16.0, "amb_interior": -24.0},
	"storm": {"amb_rain": -12.0, "amb_wind": -14.0},
	"storm_climax": {"amb_rain": -12.0, "amb_wind": -14.0, "amb_hail": -16.0},
	"quake": {"amb_rain": -16.0, "amb_quake": -24.0},
	"flood": {"amb_rain": -14.0, "amb_water": -14.0},
	"final": {"amb_wind": -18.0, "amb_water": -18.0, "amb_quake": -18.0},
	"result": {"amb_rain": -30.0, "amb_wind": -30.0, "amb_hail": -30.0, "amb_water": -30.0, "amb_interior": -30.0, "amb_quake": -30.0},
}
var players: Dictionary = {}
var target: Dictionary = {}
var _from: Dictionary = {}
var state: String = ""
var shaking: bool = false
var _fade: float = 0.0

func configure(owner_node: Node) -> void:
	for key: String in KEYS:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.name = key
		p.bus = "Ambience"
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		p.volume_db = -80.0
		owner_node.add_child(p)
		players[key] = p
	set_state("preparation")

func set_state(next: String, tremor: bool = false) -> void:
	if next == state and tremor == shaking: return
	state = next
	shaking = tremor
	_fade = 0.0
	for key: String in KEYS:
		_from[key] = db_to_linear(players[key].volume_db)
		target[key] = float(STATES.get(state, {}).get(key, -80.0))
	if shaking: target["amb_quake"] = -10.0

func advance(delta: float, library: SampleLibrary, fallback: Dictionary) -> void:
	_fade = minf(FADE, _fade + delta)
	var k: float = smoothstep(0.0, FADE, _fade)
	for key: String in KEYS:
		var p: AudioStreamPlayer = players[key]
		if p.stream == null:
			p.stream = library.pick(key) if library.has(key) else fallback.get(key)
		if p.stream != null and not p.playing: p.play()
		p.volume_db = linear_to_db(maxf(.0001, lerpf(float(_from.get(key, .0001)), db_to_linear(target[key]), k)))
