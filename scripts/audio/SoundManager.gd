class_name SoundManager
extends Node
## Sample-first sound with procedural fallback. SoundRecipes are baked
## by SoundSynth on a worker thread; game events arrive through existing signals.
## Mix rules: soft envelopes everywhere, ±6 % pitch per play, per-key throttles,
## projectile launch/impact sounds 8 dB under the main effects, limiter on Master.

signal settings_changed

const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"
const BUS_UI: String = "UI"
const BUS_AMBIENCE: String = "Ambience"
## Main-effect reference level; projectiles sit 8 dB under it.
const SFX_REFERENCE_DB: float = -14.0
const PROJECTILE_OFFSET_DB: float = -8.0
const PROJECTILE_DB: float = SFX_REFERENCE_DB + PROJECTILE_OFFSET_DB
const PITCH_MIN: float = 0.94
const PITCH_MAX: float = 1.06
const SFX_VOICES: int = 18
const BEAT_VOICES: int = 4
const UI_VOICES: int = 4
const MAX_LEVEL: int = 10
const PAUSE_CUTOFF: float = 650.0
## key: [volume_db, bus, throttle seconds].
const MIX: Dictionary = {
	"thunder": [-10.0, BUS_SFX, 4.0], "siren": [-18.0, BUS_SFX, 8.0],
	"slam": [-10.0, BUS_SFX, .35], "boom": [-7.0, BUS_SFX, .5],
	"whoosh_wind": [PROJECTILE_DB, BUS_SFX, .12],
	"valve": [-12.0, BUS_SFX, .2], "breaker": [-12.0, BUS_SFX, .2],
	"ui_hover": [-24.0, BUS_UI, .08], "ui_start": [-12.0, BUS_UI, .2], "ui_back": [-16.0, BUS_UI, .1],
	"intro_riser": [-14.0, BUS_SFX, .3], "intro_hit": [-10.0, BUS_SFX, .3], "final_intro": [-12.0, BUS_SFX, .3],
	"countdown": [-18.0, BUS_UI, 4.0], "health_low": [-16.0, BUS_UI, 2.0], "creak": [-24.0, BUS_SFX, 1.0],

	"safe": [-12.0, BUS_SFX, .3], "karne_ok": [-12.0, BUS_UI, .05], "karne_miss": [-12.0, BUS_UI, .05],
	"rain": [-17.0, BUS_MUSIC, 0.0], "drone": [-15.0, BUS_MUSIC, 0.0], "siege_pad": [-15.0, BUS_MUSIC, 0.0],
	"kick": [-12.0, BUS_MUSIC, 0.05], "tick": [-24.0, BUS_MUSIC, 0.05], "clank": [-25.0, BUS_MUSIC, 0.05],
	"warn": [-12.0, BUS_SFX, 0.14],
	"ui_open": [-10.0, BUS_UI, 0.1], "ui_confirm": [-9.0, BUS_UI, 0.1], "ui_pause": [-11.0, BUS_UI, 0.05],
	"ui_resume": [-11.0, BUS_UI, 0.05], "ui_toggle": [-12.0, BUS_UI, 0.05],
	"storm_in": [-6.0, BUS_SFX, 0.3], "storm_out": [-7.0, BUS_SFX, 0.3], "quake_in": [-6.0, BUS_SFX, 0.3],
	"quake_out": [-6.0, BUS_SFX, 0.3], "flood_in": [-6.0, BUS_SFX, 0.3], "flood_out": [-7.0, BUS_SFX, 0.3],
	"tremor": [-6.0, BUS_SFX, 1.0], "topple": [-8.0, BUS_SFX, 0.12], "secure": [-9.0, BUS_SFX, 0.1], "cover": [-13.0, BUS_SFX, 0.2],
	"alarm": [-11.0, BUS_SFX, 0.6],
	"fire_in": [-6.0, BUS_SFX, 0.3], "fire_out": [-8.0, BUS_SFX, 0.3], "titan_in": [-4.0, BUS_SFX, 0.3],
	"titan_fuse": [-3.0, BUS_SFX, 0.3], "titan_out": [-4.0, BUS_SFX, 0.3],
	"cast_storm": [SFX_REFERENCE_DB, BUS_SFX, 0.14], "cast_quake": [SFX_REFERENCE_DB, BUS_SFX, 0.14],
	"cast_flood": [SFX_REFERENCE_DB, BUS_SFX, 0.14], "cast_fire": [SFX_REFERENCE_DB, BUS_SFX, 0.14],
	"whoosh": [PROJECTILE_DB, BUS_SFX, 0.12],
	"impact_glass": [PROJECTILE_DB, BUS_SFX, 0.11], "impact_wood": [PROJECTILE_DB, BUS_SFX, 0.11],
	"impact_stone": [PROJECTILE_DB, BUS_SFX, 0.11], "impact_metal": [PROJECTILE_DB, BUS_SFX, 0.11],
	"impact_water": [PROJECTILE_DB, BUS_SFX, 0.11], "impact_fire": [PROJECTILE_DB, BUS_SFX, 0.11],
	"block": [-12.0, BUS_SFX, 0.14],
	"jump": [-14.0, BUS_SFX, 0.09], "floor_up": [-12.0, BUS_SFX, 0.09], "drop_land": [-12.0, BUS_SFX, 0.09],
	"dash": [-11.0, BUS_SFX, 0.09], "dodge": [-9.0, BUS_SFX, 0.12], "graze": [-12.0, BUS_SFX, 0.06], "hurt": [-8.0, BUS_SFX, 0.12],
	"heartbeat": [-14.0, BUS_SFX, 0.3],
	"loot_drop": [-14.0, BUS_SFX, 0.1], "pickup": [-10.0, BUS_SFX, 0.08], "heal": [-9.0, BUS_SFX, 0.1],
	"safety": [-11.0, BUS_SFX, 0.1], "repair": [-8.0, BUS_SFX, 0.2],
	"collapse_room": [-7.0, BUS_SFX, 0.3], "collapse_building": [-4.0, BUS_SFX, 0.5],
	"victory": [-6.0, BUS_SFX, 0.5], "defeat": [-6.0, BUS_SFX, 0.5],
}
const CASTS: Array[String] = ["cast_storm", "cast_quake", "cast_flood", "cast_fire"]
## Mode order: storm, quake, double siege, flood, fire, final titan.
const INTROS: Array = [["storm_in"], ["quake_in"], ["flood_in"], ["titan_in"]]
const OUTROS: Array = [["storm_out"], ["quake_out"], ["flood_out"], ["titan_out"]]
const FALLBACK: Dictionary = {
	"thunder": "storm_in", "siren": "alarm", "slam": "cast_quake", "boom": "collapse_building",
	"whoosh_wind": "whoosh", "valve": "safety", "breaker": "secure", "ui_hover": "tick",
	"ui_start": "ui_confirm", "ui_back": "ui_resume", "intro_riser": "storm_in", "intro_hit": "quake_in",
	"final_intro": "titan_in", "countdown": "alarm", "health_low": "heartbeat", "creak": "clank",
	"amb_rain": "rain", "amb_wind": "rain", "amb_hail": "rain", "amb_water": "rain",
	"amb_interior": "drone", "amb_quake": "siege_pad",
}
const PENTATONIC: Array[int] = [62, 65, 67, 69, 72, 74]
var library: SampleLibrary
var ambience: AmbienceDirector
var combo_degree: int = 0
var combo_note: int = 62
var _combo_at: float = -10.0
var _notes: Array[AudioStreamWAV] = []
var _ducks: Array[Dictionary] = []
var duck_db: float = 0.0
var _shake_duck: float = 0.0
var _shaking: bool = false
var _music_cutoff: float = 20000.0
var _creak_left: float = 7.0
var _thunder_at: float = -10.0
var _low_health_announced: bool = false
var _first_siren: bool = false
var _countdown_played: bool = false
var bgm_player: AudioStreamPlayer
var score: AdaptiveMusic
var director: MusicDirector
var _music_wall_usec: int = 0
## BGM playback rate during the fight climax (~+5% tempo).
const CLIMAX_PITCH: float = 1.05
var bgm_restarts: int = 0

var game: MainGame
var muted: bool = false
var volume_level: int = 8
var paused_view: bool = false
## Current pulse tempo (0 = no pulse). Siege tempo rises with the wave number.
var bpm: float = 0.0
var clock: float = 0.0
## Every accepted play: {key, time, volume_db, pitch, bus}. Tests read it.
var history: Array[Dictionary] = []
var streams: Dictionary = {}
var music: Dictionary = {}
var music_target: Dictionary = {}
var _recipes: Dictionary = {}
var _last: Dictionary = {}
var _pools: Dictionary = {}
var _cursor: Dictionary = {}
var _pending: Array[Dictionary] = []
var _thread: Thread
var _mutex: Mutex = Mutex.new()
var _baked: Array = []
var _cancel: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_state: int = -1
var _was_failed: bool = false
var _room_states: Dictionary = {}
var _was_victory: bool = false

func _ready() -> void:
	add_to_group("siege_audio")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_setup_buses()
	_pools[BUS_SFX] = _make_pool(SFX_VOICES, BUS_SFX, Node.PROCESS_MODE_PAUSABLE)
	_pools[BUS_MUSIC] = _make_pool(BEAT_VOICES, BUS_MUSIC, Node.PROCESS_MODE_PAUSABLE)
	_pools[BUS_UI] = _make_pool(UI_VOICES, BUS_UI, Node.PROCESS_MODE_ALWAYS)
	library = SampleLibrary.new()
	ambience = AmbienceDirector.new()
	ambience.configure(self)
	music = ambience.players
	music_target = ambience.target
	for note: int in PENTATONIC:
		var recipe: Dictionary = {"length": .32, "peak": .45, "lp": 2600.0, "layers": [{"type": "tone", "wave": "warm", "f0": 440.0*pow(2.0,(note-69)/12.0), "env": [.006,.08,.15,.14]}]}
		_notes.append(SoundSynth.make_stream(SoundSynth.to_pcm16(SoundSynth.render(recipe, note)), false))
	_apply_settings()
	score = AdaptiveMusic.new()
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	bgm_player.bus = BUS_MUSIC
	bgm_player.volume_db = MusicDirector.SILENT
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.stream = score.stream
	add_child(bgm_player)
	bgm_player.play()
	director = MusicDirector.new()
	director.configure(self)
	_recipes = SoundRecipes.all()
	_thread = Thread.new()
	_thread.start(_bake_worker.bind(_recipes))

func _exit_tree() -> void:
	_mutex.lock()
	_cancel = true
	_mutex.unlock()
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	# Release mixer references explicitly, including loops still running at quit.
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			child.stop()
	# Mixer stop commands are consumed on the audio thread. Retain the PCM data
	# for one driver block before releasing it (also needed by 4.3's Dummy driver).
	OS.delay_msec(40)
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			child.stream = null
	streams.clear()
	_notes.clear()
	if library != null: library.clear()
	if director != null: director.release()

func configure(owner_game: MainGame) -> void:
	game = owner_game
	var w: DisasterWaveManager = game.waves
	w.phase_changed.connect(_on_phase)
	w.attack_launched.connect(_on_launch)
	w.fusion_burst.connect(func() -> void: play("titan_fuse"))
	w.intro_beat.connect(_on_intro_beat)
	w.grazed.connect(func(point: Vector2) -> void: musical_feedback(); play_at("graze", point))
	game.projectiles.projectile_impacted.connect(_on_impact)
	game.projectiles.dodged.connect(func(_point: Vector2) -> void: play("dodge"))
	game.player.dash_started.connect(func() -> void: play("dash"))
	game.player.jumped.connect(func(_air: bool) -> void: play("jump"))
	game.player.landed.connect(_on_land)
	game.player.floor_transition_started.connect(_on_floor_shift)
	game.player.damaged.connect(_on_hurt)
	game.loot.collected.connect(_on_collect)
	game.loot.landed.connect(func(_kind: int) -> void: play("loot_drop"))
	game.loot.repaired.connect(func(room: RoomDiorama) -> void: play_at("repair", room.global_position))
	game.upgrades.selection_changed.connect(_on_cards)
	game.upgrades.upgrade_selected.connect(func(_id: int) -> void: play("ui_confirm"))
	game.mechanics.activated.connect(_on_module_activated)
	game.mechanics.blocked.connect(func(_point: Vector2) -> void: play("block"))
	game.preparedness.task_done.connect(_on_task_done)
	game.preparedness.bag_used.connect(func(_point: Vector2) -> void: play("heal"))
	game.preparedness.window_shattered.connect(func(point: Vector2) -> void: play_at("impact_glass", point, 8.0))
	game.tremor.warned.connect(func(_seconds: float) -> void: play("tremor"))
	game.tremor.toppled.connect(func(prop: BuildingProp) -> void: play_at("topple", prop.global_position))
	game.tremor.shaking_changed.connect(_on_shaking)
	game.weather.lightning.connect(_on_lightning)
	game.tremor.debris.connect(_on_debris)
	game.upgrade_overlay.karne_row_revealed.connect(_on_karne_row)
	game.hud.karne_row_revealed.connect(_on_karne_row)
	game.player.cover_started.connect(func() -> void: play("cover"))
	for room: RoomDiorama in game.building.rooms:
		room.state_changed.connect(_on_room_state)
	for boss: DisasterBoss in w.bosses():
		boss.cued.connect(func(_seconds: float) -> void: play("warn"))
	_last_state = w.state

# --------------------------------------------------------------- baking ----

func _bake_worker(recipes: Dictionary) -> void:
	for key: String in SoundRecipes.ORDER:
		_mutex.lock()
		var stop: bool = _cancel
		_mutex.unlock()
		if stop: return
		var bytes: PackedByteArray = SoundSynth.to_pcm16(SoundSynth.render(recipes[key], hash(key)))
		_mutex.lock()
		_baked.append([key, bytes])
		_mutex.unlock()

func _drain_baked() -> void:
	_mutex.lock()
	var ready_items: Array = _baked.duplicate()
	_baked.clear()
	_mutex.unlock()
	for item: Array in ready_items:
		var key: String = item[0]
		var loop: bool = SoundRecipes.LOOPS.has(key)
		streams[key] = SoundSynth.make_stream(item[1], loop)
		for alias: String in FALLBACK:
			if FALLBACK[alias] == key: streams[alias] = streams[key]

## Blocks until every sound exists (tests and the first-frame fallback).
func bake_all_now() -> void:
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	_drain_baked()

func is_baked() -> bool:
	return streams.has_all(SoundRecipes.ORDER)

# ---------------------------------------------------------------- buses ----

func _setup_buses() -> void:
	for bus_name: String in [BUS_MUSIC, BUS_SFX, BUS_UI, BUS_AMBIENCE, "WorldLeft", "WorldRight"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var index: int = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
			AudioServer.set_bus_send(index, "Master")
	for bus_name: String in [BUS_MUSIC, BUS_AMBIENCE]:
		var bus: int = AudioServer.get_bus_index(bus_name)
		if AudioServer.get_bus_effect_count(bus) == 0:
			var low_pass: AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
			low_pass.cutoff_hz = 20000.0
			AudioServer.add_bus_effect(bus, low_pass)
		AudioServer.set_bus_effect_enabled(bus, 0, false)
		AudioServer.set_bus_volume_db(bus, 0.0)
	var sfx_bus: int = AudioServer.get_bus_index(BUS_SFX)
	if AudioServer.get_bus_effect_count(sfx_bus) == 0:
		var reverb: AudioEffectReverb = AudioEffectReverb.new()
		reverb.room_size = .3
		reverb.wet = .1
		AudioServer.add_bus_effect(sfx_bus, reverb)
	for side: String in ["WorldLeft", "WorldRight"]:
		var bus: int = AudioServer.get_bus_index(side)
		AudioServer.set_bus_send(bus, BUS_SFX)
		if AudioServer.get_bus_effect_count(bus) == 0:
			var pan: AudioEffectPanner = AudioEffectPanner.new()
			pan.pan = -.5 if side == "WorldLeft" else .5
			AudioServer.add_bus_effect(bus, pan)
	if AudioServer.get_bus_effect_count(0) == 0:
		# Safety ceiling for stacked events; the mix itself leaves ample headroom.
		var limiter: AudioEffect = ClassDB.instantiate("AudioEffectHardLimiter") if ClassDB.class_exists("AudioEffectHardLimiter") else AudioEffectLimiter.new()
		limiter.set("ceiling_db", -1.0)
		AudioServer.add_bus_effect(0, limiter)

func _make_pool(count: int, bus_name: String, mode: Node.ProcessMode) -> Array[AudioStreamPlayer]:
	var pool: Array[AudioStreamPlayer] = []
	for i: int in range(count):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "%s_%02d" % [bus_name, i]
		player.bus = bus_name
		player.process_mode = mode
		add_child(player)
		pool.append(player)
	_cursor[bus_name] = 0
	return pool

func voice_count() -> int:
	var total: int = 0
	for bus_name: String in _pools: total += (_pools[bus_name] as Array).size()
	return total

# ----------------------------------------------------------------- play ----

## Plays a one-shot unless its throttle window is still open. Returns true if played.
func play(key: String, offset_db: float = 0.0, pan: float = 0.0) -> bool:
	var spec: Array = MIX.get(key, [SFX_REFERENCE_DB, BUS_SFX, 0.05])
	if clock - float(_last.get(key, -100.0)) < float(spec[2]) - 0.00001:
		return false
	var stream: AudioStream = library.pick(key) if library.has(key) else streams.get(key)
	if stream == null: return false
	_last[key] = clock
	var player: AudioStreamPlayer = _voice(spec[1])
	player.stream = stream
	player.bus = str(spec[1])
	if spec[1] == BUS_SFX and absf(pan) > .08:
		player.bus = "WorldLeft" if pan < 0.0 else "WorldRight"
	player.volume_db = float(spec[0]) + offset_db
	player.pitch_scale = _rng.randf_range(PITCH_MIN, PITCH_MAX)
	player.play()
	history.append({"key": key, "time": clock, "volume_db": player.volume_db, "pitch": player.pitch_scale, "bus": spec[1], "pan": -.5 if player.bus == "WorldLeft" else (.5 if player.bus == "WorldRight" else 0.0), "sample": library.has(key)})
	if key == "hurt": duck(-6.0, .05, .15, .4)
	elif key in ["topple", "slam"]: duck(-4.0, .04, .15, .4)
	elif key in ["boom", "collapse_room", "collapse_building", "titan_fuse"]: duck(-10.0, .03, .4, .8)
	if history.size() > 400: history.remove_at(0)
	return true

func play_later(key: String, delay: float, offset_db: float = 0.0) -> void:
	_pending.append({"key": key, "at": clock + delay, "offset": offset_db})

func _voice(bus_name: String) -> AudioStreamPlayer:
	var pool: Array = _pools[bus_name]
	for i: int in range(pool.size()):
		var index: int = (int(_cursor[bus_name]) + i) % pool.size()
		if not (pool[index] as AudioStreamPlayer).playing:
			_cursor[bus_name] = (index + 1) % pool.size()
			return pool[index]
	# Every voice busy: steal the oldest in round-robin order.
	var stolen: AudioStreamPlayer = pool[int(_cursor[bus_name])]
	_cursor[bus_name] = (int(_cursor[bus_name]) + 1) % pool.size()
	return stolen

func plays(key: String) -> int:
	var count: int = 0
	for entry: Dictionary in history: count += 1 if entry["key"] == key else 0
	return count

# ------------------------------------------------------------- settings ----

func toggle_mute() -> void:
	muted = not muted
	_apply_settings()
	if not muted: play("ui_toggle")
	settings_changed.emit()

func change_volume(step: int) -> void:
	volume_level = clampi(volume_level + step, 0, MAX_LEVEL)
	_apply_settings()
	play("ui_toggle")
	settings_changed.emit()

func level_db() -> float:
	return -80.0 if volume_level <= 0 else linear_to_db(float(volume_level) / MAX_LEVEL)

func _apply_settings() -> void:
	AudioServer.set_bus_mute(0, muted)
	AudioServer.set_bus_volume_db(0, level_db())

## Pause muffles and lowers the music bed; one-shots on the SFX bus freeze with the tree.
func set_paused_view(value: bool) -> void:
	if paused_view == value: return
	paused_view = value
	var music_bus: int = AudioServer.get_bus_index(BUS_MUSIC)
	AudioServer.set_bus_effect_enabled(music_bus, 0, value)
	AudioServer.set_bus_volume_db(music_bus, -5.0 if value else 0.0)
	_update_mix(0.0)
	play("ui_pause" if value else "ui_resume")

# ---------------------------------------------------------------- music ----

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	clock += delta
	# The mixer loops its PCM even when the game thread stalls. Recover an
	# unexpected stop without fighting explicit Master mute or tree pause.
	if bgm_player != null and not bgm_player.playing and not muted:
		bgm_player.play()
		score.transport = 0.0
		score._last_mix_position = -1.0
		bgm_restarts += 1
	if not is_baked(): _drain_baked()
	var frozen: bool = get_tree() != null and get_tree().paused
	if frozen:
		for item: Dictionary in _pending: item["at"] += delta
	if not frozen:
		for i: int in range(_pending.size() - 1, -1, -1):
			if clock >= float(_pending[i]["at"]):
				var item: Dictionary = _pending[i]
				_pending.remove_at(i)
				play(item["key"], float(item["offset"]))
	_update_music(delta, frozen)
	_update_environment(delta, frozen)
	_update_mix(delta)

## Calm, tense bed in preparation; a dark industrial pulse under every siege.
func _update_music(delta: float, frozen: bool) -> void:
	if game == null: return
	var w: DisasterWaveManager = game.waves
	var siege: bool = w.state == DisasterWaveManager.State.SIEGE_PHASE and not w.failed and not w.victory
	var preparing: bool = w.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE] and not w.failed
	bpm = MusicScore.BPM if siege else (MusicScore.BPM*.5 if preparing else 0.0)
	# Step 7 climax (last 15 s): the score runs a touch faster; eased, never a jump.
	if bgm_player != null and not frozen:
		bgm_player.pitch_scale = move_toward(bgm_player.pitch_scale, CLIMAX_PITCH if w.is_climax() else 1.0, delta * 0.12)
	var music_delta: float = delta / maxf(.001, Engine.time_scale)
	# A continuous recording follows wall time even during hitstop or a slow
	# rendered frame. Explicit/manual advances (including Dummy tests) stay exact.
	if DisplayServer.get_name() != "headless" and is_processing():
		var now: int = Time.get_ticks_usec()
		if _music_wall_usec > 0: music_delta = (now - _music_wall_usec) / 1000000.0
		_music_wall_usec = now
	else:
		_music_wall_usec = 0
	var recorded_event: String = director.advance(music_delta, game, bgm_player.pitch_scale, _shaking, DisplayServer.get_name() != "headless" and is_processing())
	bgm_player.volume_db = director.stem_level.db
	var sting: String = score.advance(music_delta, game, bgm_player, _shaking, frozen)
	if sting != "" and not (sting == "victory" and director.has("victory")): play(sting)
	if recorded_event != "":
		history.append({"key": recorded_event, "time": clock, "volume_db": MusicDirector.VICTORY_DB, "pitch": 1.0, "bus": BUS_MUSIC, "pan": 0.0, "sample": true, "recording": "victory_srg774"})
		if history.size() > 400: history.remove_at(0)

# --------------------------------------------------------------- events ----

func _on_phase() -> void:
	var w: DisasterWaveManager = game.waves
	if w.failed or w.victory or w.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE, DisasterWaveManager.State.WAVE_INTRO]:
		_pending.clear()
	if w.failed and not _was_failed and w.fail_reason == DisasterWaveManager.FailReason.BUILDING:
		play("collapse_building")
		play("siren")
	if w.state == DisasterWaveManager.State.WAVE_INTRO:
		_countdown_played = false
		_low_health_announced = false
		for key: String in INTROS[w.mode]: play(key)
		play_later("intro_hit", maxf(.1, w.intro_duration() - .2))
		if not _first_siren:
			_first_siren = true
			play("siren")
	elif w.state == DisasterWaveManager.State.WAVE_OUTRO and _last_state != DisasterWaveManager.State.WAVE_OUTRO:
		for key: String in OUTROS[w.mode]: play(key)
	_was_failed = w.failed
	_was_victory = w.victory
	_last_state = w.state

func _on_intro_beat(mode_id: int, beat: int) -> void:
	match mode_id:
		DisasterWaveManager.Mode.STORM: play("storm_in", -5.0)
		DisasterWaveManager.Mode.EARTHQUAKE: play("cast_quake", -3.0 if beat == 0 else 0.0)
		DisasterWaveManager.Mode.FLOOD: play("cast_flood", -3.0)
		DisasterWaveManager.Mode.CATACLYSM:
			for key: String in ["cast_storm","cast_quake","cast_flood"]: play(key,-6.0)

func _on_launch(attack: HazardAttack) -> void:
	play_at(CASTS[clampi(attack.source, 0, 3)], attack.origin)
	if attack.source == 1: play_at("slam", attack.origin, -5.0)
	if not attack.is_area(): play("whoosh")

func _on_impact(attack: HazardAttack, point: Vector2) -> void:
	if attack.is_area(): return
	var room: RoomDiorama = game.building.room_at_point(attack.floor_index, point.x)
	if attack.source in [0, 2, 3] and room != null and room.has_reinforcement(RoomDiorama.Reinforcement.SHUTTER):
		play_at("impact_metal", point)
		play_at("block", point)
		return
	var key: String = impact_key(attack)
	if key != "": play_at(key, point)

static func impact_key(attack: HazardAttack) -> String:
	match attack.kind:
		HazardAttack.Kind.GLASS, HazardAttack.Kind.PLATE, HazardAttack.Kind.CHANDELIER: return "impact_glass"
		HazardAttack.Kind.POT, HazardAttack.Kind.CHAIR, HazardAttack.Kind.WARDROBE, HazardAttack.Kind.BOOK, HazardAttack.Kind.TOY, HazardAttack.Kind.DEBRIS, HazardAttack.Kind.FLOATING_DEBRIS: return "impact_wood"
		HazardAttack.Kind.BRICK, HazardAttack.Kind.CONCRETE, HazardAttack.Kind.SHOCKWAVE, HazardAttack.Kind.SHARD, HazardAttack.Kind.METEOR: return "impact_stone"
		HazardAttack.Kind.KNIFE, HazardAttack.Kind.SAW, HazardAttack.Kind.TOOL, HazardAttack.Kind.HARPOON: return "impact_metal"
		HazardAttack.Kind.WATER_BLADE, HazardAttack.Kind.HYDRO_ORB, HazardAttack.Kind.WATER_SHARD, HazardAttack.Kind.TIDAL_WALL: return "impact_water"
		HazardAttack.Kind.FIREBALL, HazardAttack.Kind.FIRE_DART, HazardAttack.Kind.FIRE_BEAM, HazardAttack.Kind.LOW_FLAME: return "impact_fire"
		HazardAttack.Kind.ROW_SWEEP: return "impact_stone" if attack.source == 1 else "whoosh"
	return "whoosh"

func _on_task_done(kind: int, point: Vector2) -> void:
	var completed: int = 0
	for task: Dictionary in game.preparedness.tasks:
		if task["done"]: completed += 1
	musical_feedback(clampi(completed - 1, 0, 5))
	play_at(["secure", "impact_metal", "safety", "breaker", "pickup"][clampi(kind, 0, 4)], point)

func _on_debris(covered: bool) -> void:
	play_at("impact_stone", game.player.global_position, 3.0 if covered else 6.0)
	if covered:
		musical_feedback()
		play("safe")

func _on_karne_row(ok: bool) -> void:
	play("karne_ok" if ok else "karne_miss")

func _on_land(impact: float) -> void:
	play("drop_land", lerpf(-8.0, 0.0, clampf(impact, 0.0, 1.0)))

func _on_floor_shift(target: int) -> void:
	if target > game.player.current_floor: play("floor_up")

func _on_hurt(remaining: float) -> void:
	play("hurt")
	if remaining > 0.0: play_later("heartbeat", 0.14)

func _on_collect(kind: int) -> void:
	musical_feedback()
	match kind:
		LootSystem.Kind.EMERGENCY_BAG: play("heal")
		LootSystem.Kind.SAFETY_KIT: play("safety")
		_: play("pickup")

func _on_cards() -> void:
	if game.upgrades.pending: play("ui_open")

func _on_room_state(room: RoomDiorama, state: int) -> void:
	var previous: int = int(_room_states.get(room, RoomDiorama.RoomState.INTACT))
	_room_states[room] = state
	if state == RoomDiorama.RoomState.COLLAPSED: play_at("collapse_room", room.global_position)
	if state == RoomDiorama.RoomState.CRITICAL and previous != state: play_at("creak", room.global_position)
	# A room newly needs repair (or got worse) during a fight: one alert ping.
	elif state in [RoomDiorama.RoomState.DAMAGED, RoomDiorama.RoomState.CRITICAL] and state > previous and game.waves.state == DisasterWaveManager.State.SIEGE_PHASE:
		play("alarm")

func _on_module_activated(id: int, _point: Vector2) -> void:
	if id == SiegeUpgrades.Kind.AWARE_BAG: play("heal")
	elif id == SiegeUpgrades.Kind.AUTO_DRONE: play("repair")


func play_at(key: String, point: Vector2, offset: float = 0.0) -> bool:
	var x: float = game.world_to_screen(point).x if game != null else 960.0
	return play(key, offset, clampf((x - 960.0) / 1920.0, -.5, .5))

func musical_feedback(task_degree: int = -1) -> void:
	combo_degree = 0 if clock - _combo_at >= 2.0 else mini(combo_degree + 1, PENTATONIC.size()-1)
	if task_degree >= 0: combo_degree = clampi(task_degree, 0, PENTATONIC.size()-1)
	_combo_at = clock
	combo_note = PENTATONIC[combo_degree]
	var voice: AudioStreamPlayer = _voice(BUS_SFX)
	voice.bus = BUS_SFX
	voice.stream = _notes[combo_degree]
	voice.volume_db = -17.0
	voice.pitch_scale = 1.0
	voice.play()

## Overlaps take the strongest reduction, never multiply into a silent mix.
func duck(db: float, attack: float, hold: float, release: float) -> void:
	if _ducks.size() == 8: _ducks.remove_at(0)
	_ducks.append({"db": minf(0.0, db), "attack": maxf(.001, attack), "hold": maxf(0.0, hold), "release": maxf(.001, release), "age": 0.0})

func _update_mix(delta: float) -> void:
	duck_db = 0.0
	for i: int in range(_ducks.size()-1, -1, -1):
		var d: Dictionary = _ducks[i]
		d["age"] += delta
		var age: float = d["age"]
		var total: float = d["attack"] + d["hold"] + d["release"]
		if age >= total:
			_ducks.remove_at(i)
			continue
		var envelope: float = minf(1.0, age/d["attack"]) if age < d["attack"]+d["hold"] else (total-age)/d["release"]
		duck_db = minf(duck_db, float(d["db"])*envelope)
	_shake_duck = move_toward(_shake_duck, -8.0 if _shaking else 0.0, delta * (160.0 if _shaking else 8.0/.6))
	duck_db = minf(duck_db, _shake_duck)
	var music_bus: int = AudioServer.get_bus_index(BUS_MUSIC)
	var amb_bus: int = AudioServer.get_bus_index(BUS_AMBIENCE)
	AudioServer.set_bus_volume_db(music_bus, duck_db + (-5.0 if paused_view else 0.0))
	AudioServer.set_bus_volume_db(amb_bus, duck_db)
	var low: bool = game != null and game.player.health < game.player.max_health*.3
	var cutoff: float = 600.0 if _shaking else (PAUSE_CUTOFF if paused_view else (2400.0 if low else 20000.0))
	_music_cutoff = move_toward(_music_cutoff, cutoff, delta*19400.0/.6)
	(AudioServer.get_bus_effect(music_bus, 0) as AudioEffectLowPassFilter).cutoff_hz = _music_cutoff
	AudioServer.set_bus_effect_enabled(music_bus, 0, _music_cutoff < 19999.0 or paused_view)
	(AudioServer.get_bus_effect(amb_bus, 0) as AudioEffectLowPassFilter).cutoff_hz = PAUSE_CUTOFF if paused_view else 20000.0
	AudioServer.set_bus_effect_enabled(amb_bus, 0, paused_view)

func _on_shaking(value: bool) -> void:
	_shaking = value

func _on_lightning(strength: float) -> void:
	if clock - _thunder_at < 4.0 or strength <= .0: return
	var delay: float = _rng.randf_range(.2, 1.2)
	_thunder_at = clock + delay
	play_later("thunder", delay, lerpf(-10.0, 0.0, strength))

func _update_environment(delta: float, frozen: bool) -> void:
	if game == null: return
	var w: DisasterWaveManager = game.waves
	var menu: bool = game.front_end != null and game.front_end.active
	var siege: bool = w.state == DisasterWaveManager.State.SIEGE_PHASE and not w.failed and not w.victory and not menu
	var state: String = "preparation"
	if menu: state = "menu"
	elif w.failed or w.victory: state = "result"
	elif siege or w.state == DisasterWaveManager.State.WAVE_INTRO:
		state = ["storm_climax" if w.is_climax() else "storm", "quake", "flood", "final"][w.mode]
	ambience.set_state(state, _shaking)
	ambience.advance(delta, library, streams)
	if frozen: return
	if siege:
		if w.siege_remaining <= 4.0 and not _countdown_played:
			_countdown_played = true
			play("countdown")
		if game.player.health < game.player.max_health*.3 and not _low_health_announced:
			_low_health_announced = true
			play("health_low")
		if w.mode in [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.CATACLYSM]:
			_creak_left -= delta
			if _creak_left <= 0.0:
				_creak_left = _rng.randf_range(6.0, 10.0)
				play_at("creak", game.building.rooms[_rng.randi_range(0,15)].global_position)
	elif w.state == DisasterWaveManager.State.PREPARATION_PHASE:
		_first_siren = false
