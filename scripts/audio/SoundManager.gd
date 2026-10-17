class_name SoundManager
extends Node
## Procedural sound + dark music engine (no audio files). SoundRecipes are baked
## by SoundSynth on a worker thread; game events arrive through existing signals.
## Mix rules: soft envelopes everywhere, ±6 % pitch per play, per-key throttles,
## projectile launch/impact sounds 8 dB under the main effects, limiter on Master.

signal settings_changed

const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"
const BUS_UI: String = "UI"
## Main-effect reference level; projectiles sit 8 dB under it.
const SFX_REFERENCE_DB: float = -9.0
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
	"rain": [-17.0, BUS_MUSIC, 0.0], "drone": [-15.0, BUS_MUSIC, 0.0], "siege_pad": [-15.0, BUS_MUSIC, 0.0],
	"kick": [-12.0, BUS_MUSIC, 0.05], "tick": [-24.0, BUS_MUSIC, 0.05], "clank": [-25.0, BUS_MUSIC, 0.05],
	"warn": [-12.0, BUS_SFX, 0.14],
	"ui_open": [-10.0, BUS_UI, 0.1], "ui_confirm": [-9.0, BUS_UI, 0.1], "ui_pause": [-11.0, BUS_UI, 0.05],
	"ui_resume": [-11.0, BUS_UI, 0.05], "ui_toggle": [-12.0, BUS_UI, 0.05],
	"storm_in": [-6.0, BUS_SFX, 0.3], "storm_out": [-7.0, BUS_SFX, 0.3], "quake_in": [-6.0, BUS_SFX, 0.3],
	"quake_out": [-6.0, BUS_SFX, 0.3], "flood_in": [-6.0, BUS_SFX, 0.3], "flood_out": [-7.0, BUS_SFX, 0.3],
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
var bgm_player: AudioStreamPlayer
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
var _was_victory: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_setup_buses()
	_pools[BUS_SFX] = _make_pool(SFX_VOICES, BUS_SFX, Node.PROCESS_MODE_PAUSABLE)
	_pools[BUS_MUSIC] = _make_pool(BEAT_VOICES, BUS_MUSIC, Node.PROCESS_MODE_PAUSABLE)
	_pools[BUS_UI] = _make_pool(UI_VOICES, BUS_UI, Node.PROCESS_MODE_ALWAYS)
	for key: String in SoundRecipes.LOOPS:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "Music_" + key
		player.bus = BUS_MUSIC
		player.volume_db = -60.0
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		music[key] = player
		music_target[key] = -60.0
	_apply_settings()
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	bgm_player.bus = "Master"
	bgm_player.volume_db = -5.0
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.stream = MusicScore.make_stream()
	add_child(bgm_player)
	bgm_player.play()
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

func configure(owner_game: MainGame) -> void:
	game = owner_game
	var w: DisasterWaveManager = game.waves
	w.phase_changed.connect(_on_phase)
	w.attack_launched.connect(_on_launch)
	w.fusion_burst.connect(func() -> void: play("titan_fuse"))
	w.intro_beat.connect(_on_intro_beat)
	w.grazed.connect(func(_point: Vector2) -> void: play("graze"))
	game.projectiles.projectile_impacted.connect(_on_impact)
	game.projectiles.dodged.connect(func(_point: Vector2) -> void: play("dodge"))
	game.player.dash_started.connect(func() -> void: play("dash"))
	game.player.jumped.connect(func(_air: bool) -> void: play("jump"))
	game.player.landed.connect(_on_land)
	game.player.floor_transition_started.connect(_on_floor_shift)
	game.player.damaged.connect(_on_hurt)
	game.loot.collected.connect(_on_collect)
	game.loot.landed.connect(func(_kind: int) -> void: play("loot_drop"))
	game.loot.repaired.connect(func(_room: RoomDiorama) -> void: play("repair"))
	game.upgrades.selection_changed.connect(_on_cards)
	game.upgrades.upgrade_selected.connect(func(_id: int) -> void: play("ui_confirm"))
	game.mechanics.activated.connect(_on_module_activated)
	game.mechanics.blocked.connect(func(_point: Vector2) -> void: play("block"))
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
		if loop:
			var player: AudioStreamPlayer = music[key]
			player.stream = streams[key]
			player.play()

## Blocks until every sound exists (tests and the first-frame fallback).
func bake_all_now() -> void:
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	_drain_baked()

func is_baked() -> bool:
	return streams.size() == SoundRecipes.ORDER.size()

# ---------------------------------------------------------------- buses ----

func _setup_buses() -> void:
	for bus_name: String in [BUS_MUSIC, BUS_SFX, BUS_UI]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var index: int = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
			AudioServer.set_bus_send(index, "Master")
	var music_bus: int = AudioServer.get_bus_index(BUS_MUSIC)
	if AudioServer.get_bus_effect_count(music_bus) == 0:
		var low_pass: AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
		low_pass.cutoff_hz = PAUSE_CUTOFF
		AudioServer.add_bus_effect(music_bus, low_pass)
	AudioServer.set_bus_effect_enabled(music_bus, 0, false)
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
func play(key: String, offset_db: float = 0.0) -> bool:
	var spec: Array = MIX.get(key, [SFX_REFERENCE_DB, BUS_SFX, 0.05])
	if clock - float(_last.get(key, -100.0)) < float(spec[2]) - 0.00001:
		return false
	if not streams.has(key):
		return false
	_last[key] = clock
	var player: AudioStreamPlayer = _voice(spec[1])
	player.stream = streams[key]
	player.volume_db = float(spec[0]) + offset_db
	player.pitch_scale = _rng.randf_range(PITCH_MIN, PITCH_MAX)
	player.play()
	history.append({"key": key, "time": clock, "volume_db": player.volume_db, "pitch": player.pitch_scale, "bus": spec[1]})
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
		bgm_restarts += 1
	if not is_baked(): _drain_baked()
	var frozen: bool = get_tree() != null and get_tree().paused
	if not frozen:
		for i: int in range(_pending.size() - 1, -1, -1):
			if clock >= float(_pending[i]["at"]):
				var item: Dictionary = _pending[i]
				_pending.remove_at(i)
				play(item["key"], float(item["offset"]))
	_update_music(delta, frozen)

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
	music_target["rain"] = -31.0
	music_target["drone"] = -60.0
	music_target["siege_pad"] = -60.0
	for key: String in music:
		var player: AudioStreamPlayer = music[key]
		player.volume_db = move_toward(player.volume_db, float(music_target[key]), 24.0 * delta)
	# The composed score contains its own sample-accurate drums. Legacy kick/tick
	# recipes remain available as SFX; they must not double the music rhythm.

# --------------------------------------------------------------- events ----

func _on_phase() -> void:
	var w: DisasterWaveManager = game.waves
	if w.failed and not _was_failed:
		play("collapse_building" if w.fail_reason == DisasterWaveManager.FailReason.BUILDING else "defeat")
	if w.victory and not _was_victory:
		play("victory")
	if w.state == DisasterWaveManager.State.WAVE_INTRO:
		for key: String in INTROS[w.mode]: play(key)
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
	play(CASTS[clampi(attack.source, 0, 3)])
	if not attack.is_area(): play("whoosh")

func _on_impact(attack: HazardAttack, point: Vector2) -> void:
	if attack.is_area(): return
	var room: RoomDiorama = game.building.room_at_point(attack.floor_index, point.x)
	if attack.source in [0, 2, 3] and room != null and room.has_reinforcement(RoomDiorama.Reinforcement.SHUTTER):
		play("block")
		return
	var key: String = impact_key(attack)
	if key != "": play(key)

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

func _on_land(impact: float) -> void:
	play("drop_land", lerpf(-8.0, 0.0, clampf(impact, 0.0, 1.0)))

func _on_floor_shift(target: int) -> void:
	if target > game.player.current_floor: play("floor_up")

func _on_hurt(remaining: float) -> void:
	play("hurt")
	if remaining > 0.0: play_later("heartbeat", 0.14)

func _on_collect(kind: int) -> void:
	match kind:
		LootSystem.Kind.EMERGENCY_BAG: play("heal")
		LootSystem.Kind.SAFETY_KIT: play("safety")
		_: play("pickup")

func _on_cards() -> void:
	if game.upgrades.pending: play("ui_open")

func _on_room_state(_room: RoomDiorama, state: int) -> void:
	if state == RoomDiorama.RoomState.COLLAPSED: play("collapse_room")

func _on_module_activated(id: int, _point: Vector2) -> void:
	if id == SiegeUpgrades.Kind.AWARE_BAG: play("heal")
	elif id == SiegeUpgrades.Kind.AUTO_DRONE: play("repair")
