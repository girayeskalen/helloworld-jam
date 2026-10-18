class_name MusicDirector
extends RefCounted
## CC0 recordings above the existing adaptive score. Source clocks, A/B loop
## seams and level envelopes keep running across pause, defeat and retry.
## Tuning lives here; the recordings and the procedural composition stay intact.
const ROOT: String = "res://assets/audio/music/"
const SILENT: float = -80.0
const BED_PITCH: float = 1.122462
const MENU_DB: float = -10.0
const MENU_CEILING_DB: float = -6.0
const BED_DB: float = -16.0
const SHAKE_BOOST_DB: float = 4.0
const DEFEAT_BED_DB: float = -30.0
const PREP_DB: float = -20.0
const PREP_COMBAT_DB: float = -40.0
const FINAL_DB: float = -11.0
const NOVA_DB: float = -8.0
const VICTORY_DB: float = -10.0
const CLOSING_DB: float = -16.0
const MENU_FADE: float = 2.5
const STATE_FADE: float = 1.5
const SHAKE_FADE: float = 0.25
const SHAKE_RELEASE: float = 0.6
const VICTORY_FADE: float = 1.0
const CLOSING_FADE: float = 4.0
const FINAL_LEAD_IN: float = 1.0
const VICTORY_FALLBACK_SECONDS: float = 6.0
const CLOCK_SLEW: float = 0.5
const MAX_CLOCK_ERROR: float = 1.0
const PREP_STATES: Array[String] = ["preparation", "cards"]
const COMBAT_STATES: Array[String] = ["intro", "combat"]
const TRACKS: Dictionary = {
	"bed": {"file": "bed_dark_place.ogg", "start": 14.0, "end": 54.5, "crossfade": 3.0},
	"menu": {"file": "menu_blackout.mp3", "start": 42.0, "end": 170.0, "crossfade": 4.0},
	"prep": {"file": "prep_sector.ogg", "start": 2.0, "end": 54.5, "crossfade": 3.0},
	"final": {"file": "final_urgent.ogg", "start": 1.0, "end": 56.0, "crossfade": 2.0},
	"victory": {"file": "victory_srg774.ogg", "start": 0.0, "end": 0.0, "crossfade": 0.0},
}

class Level extends RefCounted:
	var db: float = SILENT
	var target: float = SILENT
	var origin: float = SILENT
	var elapsed: float = 0.0
	var duration: float = 0.0
	func set_target(value: float, seconds: float) -> void:
		if is_equal_approx(target, value): return
		origin = db
		target = value
		elapsed = 0.0
		duration = seconds
		if seconds <= 0.0: db = target
	func advance(delta: float) -> void:
		elapsed = minf(duration, elapsed + delta)
		db = lerpf(origin, target, elapsed / duration) if duration > 0.0 else target
		if elapsed >= duration - 0.000001: db = target

class Track extends RefCounted:
	var stream: AudioStream
	var players: Array[AudioStreamPlayer] = []
	var positions: PackedFloat64Array = PackedFloat64Array([0.0, 0.0])
	var weights: Vector2 = Vector2(1.0, 0.0)
	var level: Level = Level.new()
	var active: int = 0
	var running: bool = false
	var crossing: bool = false
	var completed: bool = false
	var loop_start: float = 0.0
	var loop_end: float = 0.0
	var crossfade: float = 0.0
	var pitch: float = 1.0
	var starts: int = 0
	var wraps: int = 0
	var keep_running: bool = false
	var ceiling: float = 0.0

	func start(at: float) -> void:
		if stream == null: return
		for player: AudioStreamPlayer in players: player.stop()
		active = 0
		positions[0] = at
		positions[1] = 0.0
		weights = Vector2(1.0, 0.0)
		crossing = false
		completed = false
		running = true
		starts += 1
		# Apply the current gain before play; no full-volume decoder startup block.
		_apply_gain()
		players[0].play(at)

	func advance(delta: float, native_clock: bool = false) -> void:
		level.advance(delta)
		for player: AudioStreamPlayer in players: player.pitch_scale = pitch
		if not running:
			_apply_gain()
			return
		var remaining: float = delta * pitch
		# Own clock is sufficient for Dummy/manual steps. In native playback,
		# gently reconcile hardware drift without seeking either audible voice.
		if native_clock and players[active].playing:
			var observed: float = players[active].get_playback_position()
			var error: float = observed + AudioServer.get_time_since_last_mix() * pitch - positions[active] - remaining
			if observed > 0.0 and absf(error) < MAX_CLOCK_ERROR:
				remaining += clampf(error, -remaining * CLOCK_SLEW, remaining * CLOCK_SLEW)
		if crossfade <= 0.0:
			positions[active] += remaining
			if positions[active] >= stream.get_length():
				running = false
				completed = true
				players[active].stop()
		else:
			# Split at source-time boundaries, including large deterministic steps.
			# The incoming head advances DURING the seam; never replay it afterwards.
			while remaining > 0.0000001:
				var edge: float = loop_end if crossing else loop_end - crossfade
				var step: float = minf(remaining, maxf(0.0, edge - positions[active]))
				positions[active] += step
				if crossing: positions[1 - active] += step
				remaining -= step
				if positions[active] >= edge - 0.0000001:
					if crossing:
						players[active].stop()
						active = 1 - active
						crossing = false
						wraps += 1
					else:
						positions[1 - active] = loop_start
						players[1 - active].volume_db = SILENT
						crossing = true
			var ratio: float = clampf((positions[active] - (loop_end - crossfade)) / crossfade, 0.0, 1.0) if crossing else 0.0
			weights[active] = cos(ratio * PI * 0.5)
			weights[1 - active] = sin(ratio * PI * 0.5)
			# Start the incoming decoder AFTER consuming this frame's overshoot.
			# Otherwise a slow frame permanently desynchronizes its audible head.
			# A stopped decoder also recovers here, at our clock rather than zero.
			for i: int in range(2):
				if (i == active or crossing) and not players[i].playing:
					players[i].volume_db = SILENT
					players[i].play(positions[i])
		if level.db <= SILENT and level.target <= SILENT and not keep_running:
			for player: AudioStreamPlayer in players: player.stop()
			running = false
		_apply_gain()

	func _apply_gain() -> void:
		for i: int in range(2):
			players[i].volume_db = minf(ceiling, level.db) + linear_to_db(maxf(0.00000001, weights[i]))

var tracks: Dictionary = {}
var stem_level: Level = Level.new()
var state: String = ""
var state_age: float = 0.0
var victory_started: bool = false
var closing: bool = false
var _menu_started: bool = false

func configure(owner_node: Node, directory: String = ROOT) -> void:
	for key: String in TRACKS:
		var spec: Dictionary = TRACKS[key]
		var track: Track = Track.new()
		track.loop_start = spec["start"]
		track.loop_end = spec["end"]
		track.crossfade = spec["crossfade"]
		track.keep_running = key == "bed"
		track.ceiling = MENU_CEILING_DB if key == "menu" else 0.0
		track.pitch = BED_PITCH if key == "bed" else 1.0
		var path: String = directory.path_join(spec["file"])
		if ResourceLoader.exists(path):
			track.stream = load(path) as AudioStream
			if track.stream != null:
				track.stream = track.stream.duplicate() as AudioStream
				track.stream.set("loop", false)
		for side: String in ["A", "B"]:
			var player: AudioStreamPlayer = AudioStreamPlayer.new()
			player.name = "Recorded_%s_%s" % [key, side]
			player.process_mode = Node.PROCESS_MODE_ALWAYS
			player.bus = "Music"
			player.volume_db = SILENT
			player.pitch_scale = track.pitch
			player.stream = track.stream
			owner_node.add_child(player)
			track.players.append(player)
		tracks[key] = track
	stem_level.db = 0.0
	stem_level.target = 0.0

func has(key: String) -> bool:
	return tracks.has(key) and tracks[key].stream != null

func _wanted_state(game: MainGame) -> String:
	var w: DisasterWaveManager = game.waves
	if game.front_end != null and game.front_end.active: return "menu"
	if w.victory: return "victory"
	if w.failed: return "defeat"
	if game.upgrades.pending: return "cards"
	if w.mode == DisasterWaveManager.Mode.CATACLYSM:
		if w.state == DisasterWaveManager.State.SIEGE_PHASE or w.state == DisasterWaveManager.State.WAVE_OUTRO: return "final"
		if w.state == DisasterWaveManager.State.WAVE_INTRO and w.transition_remaining <= FINAL_LEAD_IN: return "final"
	if w.state == DisasterWaveManager.State.SIEGE_PHASE: return "combat"
	if w.state == DisasterWaveManager.State.WAVE_INTRO: return "intro"
	if w.state == DisasterWaveManager.State.WAVE_OUTRO: return "cards"
	return "preparation"

func _target(key: String, db: float, fade: float, at: float = -1.0) -> void:
	var track: Track = tracks[key]
	track.level.set_target(db, fade)
	if db > SILENT and not track.running and not track.completed:
		track.start(track.loop_start if at < 0.0 else at)

## Returns the legacy history key only when the new victory recording starts.
func advance(delta: float, game: MainGame, shared_pitch: float, shaking: bool, native_clock: bool = false) -> String:
	var next: String = _wanted_state(game)
	var changed: bool = next != state
	var previous: String = state
	if changed:
		state = next
		state_age = 0.0
		if state != "victory":
			victory_started = false
			closing = false
			tracks["victory"].completed = false
	var fade: float = MENU_FADE if state == "menu" or previous == "menu" else STATE_FADE
	var bed_db: float = BED_DB + (SHAKE_BOOST_DB if shaking else 0.0)
	if state == "menu" or state == "victory": bed_db = SILENT
	elif state == "defeat": bed_db = DEFEAT_BED_DB
	var bed_fade: float = fade if changed else (SHAKE_FADE if shaking else SHAKE_RELEASE)
	_target("bed", bed_db, VICTORY_FADE if state == "victory" else bed_fade)
	_target("prep", PREP_DB if state in PREP_STATES else (PREP_COMBAT_DB if state in COMBAT_STATES else SILENT), VICTORY_FADE if state == "victory" else (FINAL_LEAD_IN if state == "final" else fade))
	_target("final", (NOVA_DB if game.waves.nova else FINAL_DB) if state == "final" else SILENT, VICTORY_FADE if state == "victory" else (FINAL_LEAD_IN if state == "final" else fade))
	if state == "menu":
		_target("menu", MENU_DB, 0.0 if previous == "" else MENU_FADE, TRACKS["menu"]["start"] if _menu_started else 0.0)
		_menu_started = true
	elif not closing:
		_target("menu", SILENT, VICTORY_FADE if state == "victory" else fade)
	var exclusive: bool = (state == "menu" and has("menu")) or (state == "final" and has("final")) or (state == "victory" and (has("victory") or closing))
	var gate_fade: float = VICTORY_FADE if state == "victory" else fade
	if previous == "" or state == "final": gate_fade = 0.0
	stem_level.set_target(SILENT if exclusive else 0.0, gate_fade)
	stem_level.advance(delta)
	tracks["bed"].pitch = BED_PITCH * shared_pitch
	tracks["final"].pitch = shared_pitch
	# Sector shares pitch while it overlaps the score; Blackout/victory never do.
	tracks["prep"].pitch = shared_pitch
	var event: String = ""
	state_age += delta
	for key: String in tracks: tracks[key].advance(delta, native_clock)
	if state == "victory":
		if state_age >= VICTORY_FADE and not victory_started:
			victory_started = true
			if has("victory"):
				_target("victory", VICTORY_DB, 0.0, 0.0)
				event = "victory"
		if victory_started and not closing and ((has("victory") and tracks["victory"].completed) or (not has("victory") and state_age >= VICTORY_FADE + VICTORY_FALLBACK_SECONDS)):
			closing = true
			_target("menu", CLOSING_DB, CLOSING_FADE, TRACKS["menu"]["start"])
	else:
		_target("victory", SILENT, VICTORY_FADE)
	return event

func release() -> void:
	# SoundManager has already stopped the players and waited one mixer block.
	for key: String in tracks: tracks[key].stream = null
