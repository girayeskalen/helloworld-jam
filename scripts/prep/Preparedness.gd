class_name Preparedness
extends Node2D
## Hazırlık: before each disaster the player walks the apartment and does real
## preparedness habits with E — bolt tall furniture to the wall, shutter windows,
## turn off the gas, cut the mains, pack the emergency bag. Each one has a concrete
## payoff in the fight that follows and a line on the karne afterwards. The numbers
## are game balance; the habits follow AFAD guidance (see SOURCES.md).

signal task_done(kind: int, point: Vector2)
signal bag_used(point: Vector2)
signal window_shattered(point: Vector2)

enum Task { SECURE, SHUTTER, GAS, POWER, BAG }
const WORK_TIME: float = 0.35
const REACH: float = 66.0
## All tasks of a preparation done: the disaster comes after this short beat.
const AUTO_START: float = 0.8
## A later preparation with no task left and no kit to spend shrinks to this.
const IDLE_PREP: float = 3.0
## Tall furniture that topples in a tremor unless it is bolted to the wall.
const TALL_KINDS: Array[int] = [BuildingProp.Kind.WARDROBE, BuildingProp.Kind.BOOKCASE, BuildingProp.Kind.VITRINE, BuildingProp.Kind.FRIDGE]
## One storm shutter per floor: kitchen, living room, bedroom, art studio.
const SHUTTER_ROOMS: Array[int] = [RoomDiorama.Kind.KITCHEN, RoomDiorama.Kind.LIVING, RoomDiorama.Kind.MASTER_BEDROOM, RoomDiorama.Kind.ART_STUDIO]
## Campaign step (completed disasters) from which each task can be done.
const UNLOCK: Dictionary = {Task.SECURE: 0, Task.GAS: 0, Task.BAG: 0, Task.SHUTTER: 1, Task.POWER: 2}
const COLORS: Array[Color] = [Color("ffb04a"), Color("8fd6ff"), Color("ff7d4a"), Color("ffe066"), Color("7dffb2")]
## The bag waits by the lobby exit door, where it can be grabbed on the way out.
const BAG_ROOM: int = RoomDiorama.Kind.LOBBY
const BAG_POINT: Vector2 = Vector2(96, 199)
const BAG_HEAL: float = 35.0
const BAG_THRESHOLD: float = 0.35
## Standing this close to an unshuttered window when glass breaks hurts.
const WINDOW_REACH: float = 90.0
const GLASS_DAMAGE: float = 8.0
## Objective-line wording: what the task is and, in two words, why.
const SECURE_NAMES: Dictionary = {BuildingProp.Kind.WARDROBE: "Gardırobu", BuildingProp.Kind.BOOKCASE: "Kitaplığı", BuildingProp.Kind.VITRINE: "Vitrini", BuildingProp.Kind.FRIDGE: "Buzdolabını"}
const TASK_LINES: Dictionary = {Task.SHUTTER: "Kepengi indir: cam kırılmasın", Task.GAS: "Gazı kapat: kaçak olmasın", Task.POWER: "Sigortaları kapat: su çarpmasın", Task.BAG: "Afet çantasını al: ilk yardım"}
## Live mains turn flood water into an electric hazard.
const ELECTRIC_FACTOR: float = 1.5
const WATER_KINDS: Array[int] = [HazardAttack.Kind.FLOOD_ZONE, HazardAttack.Kind.TIDAL_WALL]

var game: MainGame
## {kind, prop (BuildingProp or null), room, done}
var tasks: Array[Dictionary] = []
var gas_off: bool = false
var power_off: bool = false
var bag_ready: bool = false
## The bag's first aid is used at most once per fight.
var bag_spent: bool = false
var working: Dictionary = {}
var work_left: float = 0.0
var auto_start_left: float = -1.0
## What happened in the current/last fight (karne input).
var phase_stats: Dictionary = {}
var _clock: float = 0.0
## The current preparation was already checked for having nothing to do.
var _idle_checked: bool = false
var _shards: Array[Dictionary] = []

func configure(owner_game: MainGame) -> void:
	game = owner_game
	z_index = 6
	process_physics_priority = 4
	tasks.clear()
	for prop: BuildingProp in game.building.props:
		var room: RoomDiorama = prop.get_parent() as RoomDiorama
		if room == null: continue
		if prop.kind in TALL_KINDS:
			tasks.append({"kind": Task.SECURE, "prop": prop, "room": room, "done": false})
		elif prop.kind == BuildingProp.Kind.WINDOW and room.room_kind in SHUTTER_ROOMS:
			tasks.append({"kind": Task.SHUTTER, "prop": prop, "room": room, "done": false})
		elif prop.kind == BuildingProp.Kind.GAS_VALVE and String(prop.object_id).ends_with("gas_valve"):
			tasks.append({"kind": Task.GAS, "prop": prop, "room": room, "done": false})
		elif prop.kind == BuildingProp.Kind.ELECTRICAL and String(prop.object_id).ends_with("main_panel"):
			tasks.append({"kind": Task.POWER, "prop": prop, "room": room, "done": false})
	tasks.append({"kind": Task.BAG, "prop": null, "room": game.building.rooms[BAG_ROOM], "done": false})
	game.player.damaged.connect(_on_player_damaged)
	reset()

func reset() -> void:
	for task: Dictionary in tasks:
		task["done"] = false
	gas_off = false
	power_off = false
	bag_ready = false
	bag_spent = false
	working = {}
	work_left = 0.0
	auto_start_left = -1.0
	_idle_checked = false
	_shards.clear()
	begin_phase()
	queue_redraw()

## A new fight: the bag can help once again, fight statistics start from zero.
func begin_phase() -> void:
	bag_spent = false
	phase_stats = {"bag_used": false, "shocks": 0, "water_hits": 0, "glass": 0}

func available() -> bool:
	var w: DisasterWaveManager = game.waves
	if game.tutorial != null and game.tutorial.blocks_tasks(): return false
	return w.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE] and not w.failed and not w.victory and not w.upgrade_pending and not game.player.controls_locked

func unlocked(task: Dictionary) -> bool:
	return int(UNLOCK[int(task["kind"])]) <= game.waves.completed_waves

func pending() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for task: Dictionary in tasks:
		if not task["done"] and unlocked(task): list.append(task)
	return list

func count(kind: int, done_only: bool = true) -> int:
	var total: int = 0
	for task: Dictionary in tasks:
		if int(task["kind"]) == kind and (task["done"] or not done_only): total += 1
	return total

func task_floor(task: Dictionary) -> int:
	return (task["room"] as RoomDiorama).floor_index

func anchor_x(task: Dictionary) -> float:
	if task["prop"] != null: return (task["prop"] as BuildingProp).global_position.x
	return (task["room"] as RoomDiorama).global_position.x + BAG_POINT.x

## World point above the target where the marker bobs.
func marker(task: Dictionary) -> Vector2:
	var floor_line: float = game.building.floor_y(task_floor(task))
	if task["prop"] != null:
		var prop: BuildingProp = task["prop"]
		return Vector2(prop.global_position.x, minf(prop.global_position.y - prop.prop_size.y - 20.0, floor_line - 60.0))
	return Vector2(anchor_x(task), floor_line - 78.0)

## The pending task E would act on right now (closest within reach), or {}.
func in_reach() -> Dictionary:
	if not available() or game.player.is_shifting: return {}
	var best: Dictionary = {}
	var best_gap: float = REACH
	for task: Dictionary in pending():
		if task_floor(task) != game.player.current_floor: continue
		var gap: float = absf(anchor_x(task) - game.player.global_position.x)
		if gap <= best_gap:
			best_gap = gap
			best = task
	return best

## Nearest pending task by rough travel cost (floors count as a room width).
func nearest_pending() -> Dictionary:
	var best: Dictionary = {}
	var best_cost: float = INF
	for task: Dictionary in pending():
		var cost: float = absf(anchor_x(task) - game.player.global_position.x) + absf(task_floor(task) - game.player.current_floor) * 420.0
		if cost < best_cost:
			best_cost = cost
			best = task
	return best

static func task_label(task: Dictionary) -> String:
	if int(task["kind"]) == Task.SECURE:
		return "%s sabitle: devrilmesin" % SECURE_NAMES.get((task["prop"] as BuildingProp).kind, "Eşyayı")
	return TASK_LINES[int(task["kind"])]

## Top-of-screen line during a preparation: progress and the task at hand, e.g.
## "Hazırlık 2/6 · Gardırobu sabitle: devrilmesin"; "Hazırsın" when all are done.
func objective() -> String:
	if not available(): return ""
	var total: int = 0
	var done: int = 0
	for task: Dictionary in tasks:
		if not unlocked(task): continue
		total += 1
		if task["done"]: done += 1
	if total == 0: return ""
	if done == total: return "Hazırsın"
	var task: Dictionary = working
	if task.is_empty(): task = in_reach()
	if task.is_empty(): task = nearest_pending()
	return "Hazırlık %d/%d · %s" % [done, total, task_label(task)]

func objective_color() -> Color:
	var task: Dictionary = working if not working.is_empty() else in_reach()
	if task.is_empty(): task = nearest_pending()
	return COLORS[int(task["kind"])] if not task.is_empty() else UIStyle.SAFE

## E during a preparation: start the short work animation on the task in reach.
func interact() -> bool:
	if not available(): return false
	if not working.is_empty(): return true
	var task: Dictionary = in_reach()
	if task.is_empty(): return false
	working = task
	work_left = WORK_TIME
	game.player.work_time = WORK_TIME
	game.player.facing = signf(anchor_x(task) - game.player.global_position.x) if absf(anchor_x(task) - game.player.global_position.x) > 4.0 else game.player.facing
	return true

func work_progress() -> float:
	return 0.0 if working.is_empty() else clampf(1.0 - work_left / WORK_TIME, 0.0, 1.0)

func complete(task: Dictionary) -> void:
	if task["done"]: return
	task["done"] = true
	var prop: BuildingProp = task["prop"]
	var room: RoomDiorama = task["room"]
	match int(task["kind"]):
		Task.SECURE:
			prop.secured = true
			room._refresh_state(true)
		Task.SHUTTER:
			room.reinforce(RoomDiorama.Reinforcement.SHUTTER)
		Task.GAS:
			gas_off = true
			prop.secured = true
			for each: RoomDiorama in game.building.rooms:
				each.utilities_isolated = true
		Task.POWER:
			power_off = true
			prop.secured = true
		Task.BAG:
			bag_ready = true
	task_done.emit(int(task["kind"]), marker(task))
	if pending().is_empty() and available(): auto_start_left = AUTO_START
	queue_redraw()

func _physics_process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	_clock += delta
	_shorten_idle_preparation()
	if not working.is_empty():
		if not available():
			working = {}
		else:
			work_left = maxf(0.0, work_left - delta)
			if work_left <= 0.000001:
				var task: Dictionary = working
				working = {}
				complete(task)
	if auto_start_left >= 0.0:
		if not available():
			auto_start_left = -1.0
		else:
			auto_start_left -= delta
			if auto_start_left <= 0.0:
				auto_start_left = -1.0
				game.waves.start_next_wave()
	for i: int in range(_shards.size() - 1, -1, -1):
		_shards[i]["life"] = float(_shards[i]["life"]) - delta
		if float(_shards[i]["life"]) <= 0.0: _shards.remove_at(i)
	queue_redraw()

## Between disasters, once the cards are chosen: nothing to prepare and no kit to
## install means no reason to wait the full clock.
func _shorten_idle_preparation() -> void:
	var w: DisasterWaveManager = game.waves
	if w.state != DisasterWaveManager.State.BUILD_PREPARATION_PHASE:
		_idle_checked = false
		return
	if _idle_checked or not available(): return
	_idle_checked = true
	if pending().is_empty() and game.loot.materials() == 0 and w.preparation_remaining > IDLE_PREP:
		w.set_preparation(IDLE_PREP)

# ----------------------------------------------------------------- payoffs ----

func _on_player_damaged(remaining: float) -> void:
	if not bag_ready or bag_spent or remaining <= 0.0 or game.waves.state != DisasterWaveManager.State.SIEGE_PHASE: return
	if remaining >= game.player.max_health * BAG_THRESHOLD: return
	bag_spent = true
	phase_stats["bag_used"] = true
	game.player.health = minf(game.player.max_health, game.player.health + BAG_HEAL)
	bag_used.emit(game.player.global_position)

## The unshuttered window the player stands next to in their room, or null.
func exposed_window() -> BuildingProp:
	var player: SiegePlayer = game.player
	var room: RoomDiorama = game.building.room_at_point(player.current_floor, player.global_position.x)
	if room == null or room.has_reinforcement(RoomDiorama.Reinforcement.SHUTTER): return null
	for prop: BuildingProp in room.props():
		if prop.kind == BuildingProp.Kind.WINDOW and absf(prop.global_position.x - player.global_position.x) <= WINDOW_REACH:
			return prop
	return null

## Glass from a nearby unshuttered window (storm gust or tremor). Returns true on a hit.
func shatter_near_player(scale: float = 1.0) -> bool:
	var window: BuildingProp = exposed_window()
	if window == null: return false
	var point: Vector2 = window.global_position + Vector2(0, -window.prop_size.y * 0.5)
	for i: int in range(8):
		_shards.append({"origin": point, "velocity": Vector2.from_angle(-PI * 0.5 + (i - 3.5) * 0.32) * (160.0 + i % 3 * 50.0), "life": 0.5})
	window_shattered.emit(point)
	if game.player.take_damage(GLASS_DAMAGE * scale):
		phase_stats["glass"] = int(phase_stats["glass"]) + 1
		return true
	return false

func electrified(attack: HazardAttack) -> bool:
	return not power_off and attack.kind in WATER_KINDS

## Player-damage factor from preparation for one projectile hit (live mains in water).
func hit_factor(attack: HazardAttack) -> float:
	return ELECTRIC_FACTOR if electrified(attack) else 1.0

func record_hit(attack: HazardAttack) -> void:
	if attack.kind in WATER_KINDS:
		phase_stats["water_hits"] = int(phase_stats["water_hits"]) + 1
		if electrified(attack): phase_stats["shocks"] = int(phase_stats["shocks"]) + 1

# ---------------------------------------------------------------- drawing ----

func _draw() -> void:
	if not bag_ready:
		var room: RoomDiorama = game.building.rooms[BAG_ROOM]
		var at: Vector2 = room.global_position + BAG_POINT + Vector2(0, -20)
		draw_set_transform(at, 0.0, Vector2.ONE * 1.25)
		EquipmentArt.draw_kit(self, LootSystem.Kind.EMERGENCY_BAG, _clock)
		draw_set_transform(Vector2.ZERO)
	for shard: Dictionary in _shards:
		var t: float = 0.5 - float(shard["life"])
		var velocity: Vector2 = shard["velocity"]
		var p: Vector2 = Vector2(shard["origin"]) + velocity * t + Vector2(0, 420.0 * t * t)
		var tint: Color = Color(Color("cfe9ee"), clampf(float(shard["life"]) * 2.4, 0.0, 1.0))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-4, -2), p + Vector2(3, -5), p + Vector2(5, 3), p + Vector2(-2, 4)]), tint)
