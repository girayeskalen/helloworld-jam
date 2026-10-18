class_name TremorSystem
extends Node2D
## Sarsıntı: in the earthquake (and the final) the whole building shakes at intervals.
## Each tremor is telegraphed (TelegraphSystem.warn_tremor), then for 1.8 s: steps are
## slow and floor changes are blocked; unsecured tall furniture topples onto whoever is
## next to it; an unshuttered window nearby showers glass; at the peak plaster falls
## from the ceiling and only Çök-Kapan-Tutun (holding C) keeps the player unhurt; with
## the gas still on, rooms with gas appliances take leak damage. Bullet patterns hold
## while a tremor runs so the drill gets the player's full attention.

## A tremor was announced (warning seconds); drives the rumble sound.
signal warned(seconds: float)
signal toppled(prop: BuildingProp)
## Debris moment: covered = the player was doing Çök-Kapan-Tutun.
signal debris(covered: bool)

## Short, sharp drills (18 Oct polish): 1.0 s warning + 1.4 s shake keeps the hold
## on bullet patterns brief, and tremors come more often.
const WARNING: float = 1.0
const DURATION: float = 1.4
const TOPPLE_AT: float = 0.35
const DEBRIS_AT: float = 0.8
const FIRST_DELAY: float = 2.0
const EARTHQUAKE_INTERVAL: float = 8.0
const FINAL_INTERVAL: float = 12.0
const FINAL_FIRST_DELAY: float = 5.0
const DEBRIS_DAMAGE: float = 14.0
const TOPPLE_DAMAGE: float = 18.0
const ROOM_TREMOR: float = 1.5
const TOPPLE_ROOM_DAMAGE: float = 6.0
const GAS_LEAK_DAMAGE: float = 3.0
const GAS_ROOMS: Array[int] = [RoomDiorama.Kind.WORKSHOP, RoomDiorama.Kind.KITCHEN, RoomDiorama.Kind.LAUNDRY, RoomDiorama.Kind.BATHROOM]

var game: MainGame
var mode: int = -1
var next_left: float = 0.0
var active_left: float = 0.0
var elapsed: float = 0.0
var stats: Dictionary = {}
var _toppled_done: bool = false
var _debris_done: bool = false
var _clock: float = 0.0
var _dust: Array[Dictionary] = []
var _haze_left: float = 0.0

func configure(owner_game: MainGame) -> void:
	game = owner_game
	z_index = 6
	game.telegraphs.tremor_ready.connect(_on_tremor_ready)
	reset_phase(-1)

static func applies(phase_mode: int) -> bool:
	return phase_mode in [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.CATACLYSM]

## A new fight in `phase_mode`; statistics restart (karne input).
func reset_phase(phase_mode: int) -> void:
	cancel()
	mode = phase_mode
	next_left = FINAL_FIRST_DELAY if phase_mode == DisasterWaveManager.Mode.CATACLYSM else FIRST_DELAY
	stats = {"shakes": 0, "covered": 0, "debris_hits": 0, "topples": 0, "topple_hits": 0, "glass_hits": 0, "gas_leaks": 0, "stair_attempts": 0}

func warning() -> bool:
	return game.telegraphs.tremor_warning_left > 0.0

func active() -> bool:
	return active_left > 0.0

## True while a tremor is announced or shaking (bullet patterns hold).
func busy() -> bool:
	return warning() or active()

## Stop any live shake (phase end, defeat, reset); dust FX may finish fading.
func cancel() -> void:
	active_left = 0.0
	if game == null: return
	game.telegraphs.tremor_warning_left = 0.0
	game.player.shaking = false
	game.building.tremor = 0.0

## Siege tick from DisasterWaveManager. Returns true while patterns must hold.
func advance(delta: float, waves: DisasterWaveManager) -> bool:
	if not applies(waves.mode): return false
	if active():
		_shake(delta)
		return true
	if warning(): return true
	if waves.nova: return false
	next_left -= delta
	if next_left <= 0.0:
		next_left = FINAL_INTERVAL if waves.mode == DisasterWaveManager.Mode.CATACLYSM else EARTHQUAKE_INTERVAL
		announce(waves)
		return true
	return false

func announce(waves: DisasterWaveManager) -> void:
	var b: ApartmentBuilding = game.building
	var ceilings: PackedFloat32Array = PackedFloat32Array()
	for f: int in range(b.floor_count):
		ceilings.append(b.floor_y(f) - b.floor_height + 20.0)
	var area: Rect2 = Rect2(b.global_position, Vector2(b.building_width, b.floor_count * b.floor_height))
	var seconds: float = WARNING + (TutorialGuide.TREMOR_EXTRA if game.tutorial != null and game.tutorial.first_phase() else 0.0)
	game.telegraphs.warn_tremor(area, ceilings, seconds, CataclysmPatterns.WARNING_EXTRA if waves.mode == DisasterWaveManager.Mode.CATACLYSM else 0.0)
	var boss: DisasterBoss = game.titan if waves.mode == DisasterWaveManager.Mode.CATACLYSM else game.earthquake
	boss.wind_up(game.telegraphs.tremor_warning_total)
	game.game_camera.apply_shake(3.0, game.telegraphs.tremor_warning_total)
	warned.emit(game.telegraphs.tremor_warning_total)

func _on_tremor_ready() -> void:
	var waves: DisasterWaveManager = game.waves
	if waves.state != DisasterWaveManager.State.SIEGE_PHASE or waves.failed or not applies(waves.mode): return
	active_left = DURATION
	elapsed = 0.0
	_toppled_done = false
	_debris_done = false
	stats["shakes"] = int(stats["shakes"]) + 1
	game.player.shaking = true
	game.building.tremor = 1.0
	game.game_camera.apply_shake(15.0, DURATION)
	(game.titan if waves.mode == DisasterWaveManager.Mode.CATACLYSM else game.earthquake).strike()
	for prop: BuildingProp in game.building.props:
		prop.shake_unsecured(DURATION)

func _shake(delta: float) -> void:
	elapsed += delta
	active_left = maxf(0.0, active_left - delta)
	game.building.tremor = clampf(active_left / 0.4, 0.0, 1.0)
	if not _toppled_done and elapsed >= TOPPLE_AT:
		_toppled_done = true
		_topple_furniture()
		game.preparedness.shatter_near_player(game.hazard_scale())
	if not _debris_done and elapsed >= DEBRIS_AT:
		_debris_done = true
		_ceiling_debris()
	if active_left <= 0.000001:
		active_left = 0.0
		game.player.shaking = false
		game.building.tremor = 0.0

func _topple_furniture() -> void:
	var player: SiegePlayer = game.player
	for prop: BuildingProp in game.building.props:
		if prop.kind not in Preparedness.TALL_KINDS or prop.secured or prop.toppled: continue
		var room: RoomDiorama = prop.get_parent() as RoomDiorama
		if room == null or room.is_collapsed(): continue
		# Falls into the room, away from its nearer side wall.
		var local_x: float = prop.global_position.x - room.global_position.x
		var direction: float = 1.0 if local_x < room.room_size.x * 0.5 else -1.0
		prop.set_toppled(true, direction)
		room._refresh_state(true)
		room.apply_damage(TOPPLE_ROOM_DAMAGE, 1)
		stats["topples"] = int(stats["topples"]) + 1
		for i: int in range(10):
			_dust.append({"position": prop.global_position + Vector2(direction * (20.0 + i * prop.prop_size.y * 0.09), -6.0), "velocity": Vector2(direction * (20.0 + i * 6.0), -30.0 - i % 4 * 12.0), "life": 0.7, "radius": 5.0 + i % 3 * 2.0})
		toppled.emit(prop)
		# Whoever stands in the fall sweep is hit, covered or not: secure it beforehand.
		if player.current_floor == room.floor_index:
			var reach: float = (player.global_position.x - prop.global_position.x) * direction
			if reach >= -16.0 and reach <= prop.prop_size.y + 10.0:
				if player.take_damage(TOPPLE_DAMAGE * game.hazard_scale()):
					stats["topple_hits"] = int(stats["topple_hits"]) + 1

func _ceiling_debris() -> void:
	var player: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var room: RoomDiorama = b.room_at_point(player.current_floor, player.global_position.x)
	var ceiling: float = b.floor_y(player.current_floor) - b.floor_height + 24.0
	for i: int in range(14):
		var x: float = room.global_position.x + 30.0 + i * (room.room_size.x - 60.0) / 13.0
		_dust.append({"position": Vector2(x, ceiling), "velocity": Vector2(sin(i * 1.7) * 14.0, 120.0 + i % 4 * 40.0), "life": 0.85, "radius": 3.0 + i % 3})
	var covered: bool = player.covering and player.health > 0.0
	if covered:
		stats["covered"] = int(stats["covered"]) + 1
	elif player.health > 0.0 and player.take_damage(DEBRIS_DAMAGE * game.hazard_scale()):
		stats["debris_hits"] = int(stats["debris_hits"]) + 1
	debris.emit(covered)
	for each: RoomDiorama in b.rooms:
		if not each.is_collapsed(): each.apply_damage(ROOM_TREMOR, 1)
	if not game.preparedness.gas_off:
		var leaked: bool = false
		for each: RoomDiorama in b.rooms:
			if each.room_kind in GAS_ROOMS and not each.is_collapsed():
				each.apply_damage(GAS_LEAK_DAMAGE, 4)
				leaked = true
		if leaked:
			stats["gas_leaks"] = int(stats["gas_leaks"]) + 1
			_haze_left = 2.2
	if b.is_failing(): game.waves.collapse_building()

func note_stair_attempt() -> void:
	if active(): stats["stair_attempts"] = int(stats["stair_attempts"]) + 1

func _process(delta: float) -> void:
	_clock += delta
	_haze_left = maxf(0.0, _haze_left - delta)
	for i: int in range(_dust.size() - 1, -1, -1):
		_dust[i]["life"] = float(_dust[i]["life"]) - delta
		_dust[i]["position"] = Vector2(_dust[i]["position"]) + Vector2(_dust[i]["velocity"]) * delta
		if float(_dust[i]["life"]) <= 0.0: _dust.remove_at(i)
	if not _dust.is_empty() or _haze_left > 0.0 or active(): queue_redraw()

func _draw() -> void:
	for particle: Dictionary in _dust:
		var alpha: float = clampf(float(particle["life"]) / 0.7, 0.0, 1.0)
		draw_circle(Vector2(particle["position"]), float(particle["radius"]), Color(Color("cbbd9f"), 0.55 * alpha))
	if _haze_left > 0.0:
		# Leaking gas: a faint, wavering green-grey haze in the appliance rooms.
		for room: RoomDiorama in game.building.rooms:
			if room.room_kind not in GAS_ROOMS or room.is_collapsed(): continue
			var fade: float = clampf(_haze_left / 2.2, 0.0, 1.0)
			for i: int in range(4):
				var center: Vector2 = room.global_position + Vector2(90.0 + i * 70.0 + sin(_clock * 1.7 + i) * 12.0, 120.0 - i % 2 * 26.0)
				draw_circle(center, 34.0 + i * 4.0, Color(Color("9fb59a"), 0.12 * fade))
