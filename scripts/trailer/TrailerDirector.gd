extends Node
## Trailer director (trailer only; excluded from the build). `-- --shot=<id>` plays one
## shot of tools/trailer/shots.json inside the real MainGame. All setup happens in the
## preroll (trimmed away later); everything visible is the game's own systems driven
## by real input actions (TrailerPilot). Run through Godot's Movie Maker, see README.

const SHOTS: String = "res://tools/trailer/shots.json"
const QUAKE: Color = Color("ff9500")
const STORM: Color = Color("00f0ff")
const FLOOD: Color = Color("2b7fff")
const FINAL: Color = Color("e9f4f2")
## World area the default camera shows (base zoom); zoomed views stay inside it.
const WORLD_VIEW: Rect2 = Rect2(0, 0, 2461.5, 1384.6)
const EQ: int = DisasterWaveManager.Mode.EARTHQUAKE
const ST: int = DisasterWaveManager.Mode.STORM
const FL: int = DisasterWaveManager.Mode.FLOOD
const FI: int = DisasterWaveManager.Mode.CATACLYSM
## Action shots: the boss at its climax tempo, an opening choreography fired in the
## preroll ([seconds, pattern index]), the auto pilot dodging; later patterns follow
## the game's own cadence. remaining = siege seconds left (10 -> 1.45x tempo; <= 12 in
## the final = nova).
const ACTION: Dictionary = {
	"H1": {"mode": EQ, "fire": [[-0.75, 2]], "floor": 1, "x": 860.0, "zoom": 1.25, "seed": 11},
	"H2": {"mode": ST, "fire": [[-0.95, 0]], "floor": 2, "x": 1500.0, "zoom": 1.25, "seed": 12},
	"H3": {"mode": FL, "fire": [[-1.05, 1]], "floor": 1, "x": 1000.0, "zoom": 1.2, "seed": 13},
	"H4": {"mode": FI, "fire": [[-0.9, 0]], "remaining": 11.4, "floor": 2, "x": 1350.0, "zoom": 1.2, "seed": 14},
	"A1": {"mode": EQ, "fire": [[-0.55, 3]], "floor": 1, "x": 1500.0, "zoom": 1.2, "seed": 21},
	"A2": {"mode": EQ, "fire": [[-0.35, 0], [0.95, 2]], "floor": 1, "x": 950.0, "zoom": 1.75, "follow": true, "seed": 22, "slow": [1.55, 2.35]},
	"S1": {"mode": ST, "fire": [[-0.5, 3]], "floor": 1, "x": 1200.0, "zoom": 1.2, "seed": 31, "caption": ["2. GÜN · FIRTINA", STORM]},
	"S2": {"mode": ST, "fire": [[-0.3, 1]], "floor": 1, "x": 1350.0, "zoom": 1.2, "seed": 32},
	"F1": {"mode": FL, "fire": [[-0.6, 2]], "floor": 2, "x": 1100.0, "zoom": 1.2, "seed": 41, "caption": ["3. GÜN · SEL", FLOOD]},
	"F2": {"mode": FL, "fire": [[-0.5, 3]], "floor": 1, "x": 1250.0, "zoom": 1.2, "seed": 42},
	"X2": {"mode": FI, "fire": [[-0.6, 0]], "remaining": 15.0, "floor": 2, "x": 1100.0, "floors": [2, 3], "zoom": 1.2, "seed": 51, "caption": ["Ve hepsi birden", FINAL, 300.0]},
	"X3": {"mode": FI, "fire": [[-0.8, 1]], "remaining": 11.4, "floor": 2, "x": 1300.0, "zoom": 1.6, "follow": true, "seed": 52, "slow": [0.75, 1.45]},
	"X4": {"mode": FI, "fire": [[-0.7, 2]], "remaining": 10.2, "floor": 1, "x": 1000.0, "zoom": 1.2, "seed": 53, "flash_out": true},
}

var game: MainGame
var pilot: TrailerPilot
var captions: TrailerCaptions
var shot: Dictionary = {}
var shot_id: String = ""
var action: Dictionary = {}
var debug_frames: bool = false
## Rendered frames since start, and seconds of the visible shot (negative = preroll).
var frame: int = 0
var t: float = 0.0
var length: float = 0.0
var cam_zoom: float = 0.0
var cam_center: Vector2 = Vector2.ZERO
var hide_hud: bool = false
var hide_labels: bool = false
var hide_objective: bool = false
var hint: PackedStringArray = PackedStringArray()
var hint_until: float = -INF
var overlay_zoom: float = 1.0
var slow_from: float = INF
var slow_to: float = -INF
var _fired: Dictionary = {}
var _task_target: Dictionary = {}
## Action close-ups: the camera trails the player (smoothed).
var cam_follow: bool = false

func _ready() -> void:
	process_priority = 100
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--shot="): shot_id = argument.trim_prefix("--shot=")
		if argument == "--trailer-debug": debug_frames = true
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SHOTS))
	for item: Dictionary in data["shots"]:
		if item["id"] == shot_id: shot = item
	if shot.is_empty():
		push_error("Unknown trailer shot '%s'" % shot_id)
		get_tree().quit(1)
		return
	length = float(shot["length"])
	seed(1802)
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	add_child(game)
	game.hitstop_enabled = true
	game.player.trailer_guard = true
	game.loot._rng.seed = 1802
	game.upgrades._rng.seed = 7
	game.weather._rng.seed = 11
	# Music is laid in afterwards as one continuous bed. The rain/wind/water ambience
	# loops are muted too: across fast cuts their noise floor jumped like a TV channel
	# switch. Shots keep only the game's event sounds (hits, dashes, tremor, karne...).
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambience"), true)
	# Noise-like one-shots (boss cast swells, launch whooshes, siren) and the frequent
	# dash whoosh hissed like a channel switch on every fast cut; under the score they
	# are silenced by pinning their throttle clock far in the future (game code as is).
	# Boss entry/exit sweeps (quake_in, storm_in...) were the real "channel switch": each
	# action shot is set up through a siege start, so a long swell began under every cut.
	for key: String in ["cast_storm", "cast_quake", "cast_flood", "cast_fire", "whoosh", "whoosh_wind", "siren", "dash",
			"storm_in", "quake_in", "flood_in", "titan_in", "storm_out", "quake_out", "flood_out", "titan_out", "titan_fuse", "intro_riser", "intro_hit", "final_intro"]:
		game.sound._last[key] = 1.0e12
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	captions = TrailerCaptions.new()
	layer.add_child(captions)
	pilot = TrailerPilot.new(game)
	t = -float(shot["preroll"])
	if ACTION.has(shot_id): _setup_action(ACTION[shot_id])
	else: call("_setup_" + shot_id)

func _process(delta: float) -> void:
	if shot.is_empty(): return
	t = frame / 60.0 - float(shot["preroll"])
	Engine.time_scale = _time_scale()
	if not action.is_empty(): _run_action()
	else: call("_run_" + shot_id)
	pilot.update(delta)
	game.hud.visible = not hide_hud
	game.labels.visible = not hide_labels
	if hide_objective: game.tutorial.objective_text = ""
	if t <= hint_until: game.tutorial.hint_keys = hint
	if overlay_zoom != 1.0 or game.upgrade_overlay.scale != Vector2.ONE:
		game.upgrade_overlay.pivot_offset = Vector2(960, 230)
		game.upgrade_overlay.scale = Vector2.ONE * overlay_zoom
	if cam_follow:
		cam_center = cam_center.lerp(game.player.global_position + Vector2(0, -70), 1.0 - exp(-5.0 * delta / maxf(0.05, Engine.time_scale)))
	_apply_camera()
	captions.advance(t)
	if debug_frames: captions.debug_text = "%s f%d t%.3f d%d" % [shot_id, frame, t, pilot.dashes]
	frame += 1
	if t >= length + 0.25:
		pilot.release_all()
		Engine.time_scale = 1.0
		get_tree().quit()

func _time_scale() -> float:
	if t < slow_from or t > slow_to + 0.15: return 1.0
	var into: float = clampf((t - slow_from) / 0.15, 0.0, 1.0)
	var out: float = clampf((t - slow_to) / 0.15, 0.0, 1.0)
	return lerpf(1.0, 0.35, into * (1.0 - out))

func _apply_camera() -> void:
	if cam_zoom <= 0.0: return
	var camera: GameCamera = game.game_camera
	camera.zoom = Vector2.ONE * game.base_zoom / float(game.pixel_scale) * cam_zoom
	var half: Vector2 = WORLD_VIEW.size * 0.5 / cam_zoom
	camera.global_position = Vector2(clampf(cam_center.x, half.x, WORLD_VIEW.end.x - half.x), clampf(cam_center.y, half.y, WORLD_VIEW.end.y - half.y))
	camera.force_update_scroll()

## True on the first frame at or after `at` seconds of the visible shot.
func _once(key: String, at: float) -> bool:
	if t < at or _fired.has(key): return false
	_fired[key] = true
	return true

func _show_keys(keys: Array, from: float, until: float) -> void:
	if t >= from and t <= until:
		hint = PackedStringArray(keys)
		hint_until = until

# ---------------------------------------------------------------- helpers ----

func _place(floor_index: int, x: float, facing: float = 1.0) -> void:
	var player: SiegePlayer = game.player
	player.global_position = Vector2(x, game.building.floor_y(floor_index))
	player.velocity = Vector2.ZERO
	player.current_floor = floor_index
	player.facing = facing

## A fight already under way: intro skipped in the preroll, every clock quiet until a
## shot starts the choreography it needs.
func _siege(mode: int) -> void:
	game.waves.start_siege(mode, true)
	game.waves.advance_wave(game.waves.intro_duration())
	_quiet()

func _quiet() -> void:
	var w: DisasterWaveManager = game.waves
	w._quake_clock = 999.0
	w._storm_clock = 999.0
	w._marathon_clock = 999.0
	game.tremor.next_left = 999.0
	game.loot._next_spawn = 999.0

## Preparation with `done` campaign steps behind it (unlocks shutter/fuse tasks).
func _prep(done: int = 0) -> void:
	game.waves.completed_waves = done
	game.waves.prep_hold = true
	hide_objective = true

func _task(kind: int, prop_kind: int = -1) -> Dictionary:
	for task: Dictionary in game.preparedness.tasks:
		if int(task["kind"]) != kind: continue
		if prop_kind >= 0 and (task["prop"] as BuildingProp).kind != prop_kind: continue
		return task
	return {}

func _task_on(kind: int, floor_index: int) -> Dictionary:
	for task: Dictionary in game.preparedness.tasks:
		if int(task["kind"]) == kind and game.preparedness.task_floor(task) == floor_index: return task
	return {}

func _complete(kind: int, except_prop: int = -1) -> void:
	for task: Dictionary in game.preparedness.tasks:
		if int(task["kind"]) != kind: continue
		if except_prop >= 0 and task["prop"] != null and (task["prop"] as BuildingProp).kind == except_prop: continue
		game.preparedness.complete(task)

# ------------------------------------------------------- preparation shots ----

## A brisk human pass: already running in, E the moment the task is in reach, then
## straight off with a hop toward the next job.
func _setup_task(task: Dictionary, from_x: float, caption: String, done: int = 0) -> void:
	_prep(done)
	_task_target = task
	var floor_index: int = game.preparedness.task_floor(task)
	var x: float = game.preparedness.anchor_x(task)
	_place(floor_index, from_x, signf(x - from_x))
	cam_zoom = 1.7
	cam_center = Vector2(clampf((x + from_x) * 0.5, 1005.0, 1457.0), game.building.floor_y(floor_index) - 110.0)
	captions.add(caption, 0.06, length - 0.06, Preparedness.COLORS[int(task["kind"])])

func _run_task() -> void:
	var prep: Preparedness = game.preparedness
	var x: float = prep.anchor_x(_task_target)
	if _once("walk", -0.32): pilot.walk_to(x + signf(game.player.global_position.x - x) * 16.0, 8.0)
	if not _task_target["done"] and prep.working.is_empty() and prep.in_reach() == _task_target and _once("press", -INF):
		pilot.event_tap(&"repair")
	if _task_target["done"] and not _fired.has("left_at"):
		_fired["left_at"] = t
	if _fired.has("left_at") and t > float(_fired["left_at"]) + 0.12 and _once("go", -INF):
		var away: float = signf(game.player.global_position.x - x)
		pilot.walk_to(x + (away if away != 0.0 else 1.0) * 400.0, 10.0)
		pilot.tap(&"jump", 5)

# ---------------------------------------------------------- action shots ----

func _setup_action(config: Dictionary) -> void:
	action = config
	_siege(int(config["mode"]))
	game.waves.siege_remaining = float(config.get("remaining", 10.0))
	_place(int(config["floor"]), float(config["x"]), 1.0)
	cam_zoom = float(config.get("zoom", 1.2))
	cam_center = Vector2(1231, 760)
	cam_follow = bool(config.get("follow", false))
	if cam_follow: cam_center = game.player.global_position + Vector2(0, -70)
	pilot.start_auto(int(config.get("seed", 1)))
	if config.has("floors"): pilot.floors_allowed.assign(config["floors"])
	if config.has("slow"):
		slow_from = float(config["slow"][0])
		slow_to = float(config["slow"][1])
	if config.has("caption"):
		var caption: Array = config["caption"]
		captions.add(caption[0], 0.06, minf(1.6, length - 0.08), caption[1], UIStyle.LARGE, float(caption[2]) if caption.size() > 2 else TrailerCaptions.TOP_BASELINE)

func _run_action() -> void:
	var w: DisasterWaveManager = game.waves
	var fires: Array = action["fire"]
	for i: int in range(fires.size()):
		if _once("fire%d" % i, float(fires[i][0])):
			var index: int = int(fires[i][1])
			match int(action["mode"]):
				EQ:
					w._quake_pattern = index
					w._quake_clock = 0.0
				ST:
					w._storm_pattern = index
					w._storm_clock = 0.0
				_:
					w._marathon_pattern = index
					w._marathon_clock = 0.0
	game.tremor.next_left = 999.0
	if action.get("flash_out", false): captions.white = clampf((t - (length - 0.06)) / 0.05, 0.0, 1.0)

# ------------------------------------------------------------ story shots ----

## T1 black card: the title's promise.
func _setup_T1() -> void:
	_prep()
	hide_hud = true
	hide_labels = true
	captions.black = 1.0
	captions.add("4 gün. 4 afet.", 0.12, length - 0.1, QUAKE, 96, 580.0)

func _run_T1() -> void:
	pass

## T2 the same building on a calm night: preparation is the answer.
func _setup_T2() -> void:
	_prep()
	_place(0, 1010, 1)
	hide_hud = true
	hide_labels = true
	captions.add("Hazırlık hayat kurtarır.", 0.1, length - 0.08, UIStyle.SAFE)

func _run_T2() -> void:
	if _once("flash", 0.15): game.weather.trigger_flash(0.85)
	if _once("walk", -0.4): pilot.walk_to(1180, 8.0)

func _setup_P1() -> void:
	_setup_task(_task(Preparedness.Task.SECURE, BuildingProp.Kind.WARDROBE), 965, "Eşyaları sabitle")

func _run_P1() -> void:
	_run_task()

func _setup_P2() -> void:
	_setup_task(_task(Preparedness.Task.GAS), 1770, "Gazı kapat")

func _run_P2() -> void:
	_run_task()

func _setup_P3() -> void:
	_setup_task(_task(Preparedness.Task.BAG), 1050, "Afet çantanı hazırla")

func _run_P3() -> void:
	_run_task()

func _setup_P4() -> void:
	_setup_task(_task_on(Preparedness.Task.SHUTTER, 1), 650, "Kepenkleri indir", 1)

func _run_P4() -> void:
	_run_task()

func _setup_P5() -> void:
	_setup_task(_task(Preparedness.Task.POWER), 1000, "Selden önce sigortayı kapat", 2)

func _run_P5() -> void:
	_run_task()

## D1 day one: the game's own DEPREM entry.
func _setup_D1() -> void:
	_place(1, 1100, 1)
	game.waves.start_siege(EQ, true)
	captions.add("1. GÜN", 0.08, length - 0.08, QUAKE, UIStyle.TITLE, 300.0)

func _run_D1() -> void:
	pass

## L1 the lesson: the one unsecured bookcase falls; Çök-Kapan-Tutun through the plaster.
func _setup_L1() -> void:
	_siege(EQ)
	_complete(Preparedness.Task.SECURE, BuildingProp.Kind.BOOKCASE)
	_place(1, 1290, 1)
	cam_zoom = 1.9
	cam_center = Vector2(1330, 840)
	captions.add("Çök · Kapan · Tutun", 0.05, length - 0.12, QUAKE)

func _run_L1() -> void:
	if _once("tremor", -0.8): game.tremor.next_left = 0.0
	if _once("cover", 0.12): pilot.press(&"cover")
	if _once("rise", 1.75): pilot.release(&"cover")

## R1 keep the building standing: kit, S, E — the room turns green.
func _setup_R1() -> void:
	_siege(EQ)
	_place(2, 1050, -1)
	game.loot.spawn(LootSystem.Kind.COLUMN_KIT, 9)
	game.loot.items[-1]["position"].x = 1000.0
	cam_zoom = 1.7
	cam_center = Vector2(1031, 860)
	hide_objective = true
	captions.add("Binayı ayakta tut", 0.06, length - 0.1, QUAKE)

func _run_R1() -> void:
	if _once("damage", -0.25):
		var room: RoomDiorama = game.building.rooms[5]
		room.hp = room.max_hp * 0.45
		room._refresh_state()
	if _once("kit", -0.1): pilot.walk_to(1000, 8.0)
	_show_keys(["S"], 0.2, 0.4)
	if _once("down", 0.4): pilot.floor_down()
	if _once("repair", 0.8): pilot.event_tap(&"repair")
	if _once("hop", 1.3): pilot.walk_to(1150, 10.0)

## K1/K2 the karne after day one: what was done, why it matters, what to fix; a card.
func _setup_karne() -> void:
	_siege(EQ)
	_complete(Preparedness.Task.SECURE, BuildingProp.Kind.BOOKCASE)
	_complete(Preparedness.Task.GAS)
	_complete(Preparedness.Task.BAG)
	game.tremor.stats["shakes"] = 2
	game.tremor.stats["covered"] = 2
	game.tremor.stats["topples"] = 1
	_place(1, 1100, 1)

func _setup_K1() -> void:
	_setup_karne()
	captions.add("Her afet bir ders", 0.3, length - 0.12, UIStyle.SAFE, UIStyle.LARGE, 1040.0)

func _run_K1() -> void:
	if _once("finish", -1.25): game.waves.finish_wave()
	overlay_zoom = 1.0 + 0.12 * smoothstep(0.0, length, t) if t >= 0.0 else 1.0

func _setup_K2() -> void:
	_setup_karne()

func _run_K2() -> void:
	if _once("finish", -1.7): game.waves.finish_wave()
	if _once("focus", 0.15) and game.upgrade_overlay.cards.size() > 1: game.upgrade_overlay.cards[1].grab_focus()
	if _once("choose", 0.55): game.upgrades.choose(1)

## X1 day four: the fusion entry and the big AFET name.
func _setup_X1() -> void:
	_place(1, 1100, 1)
	game.waves.start_siege(FI, true)
	captions.add("4. GÜN", 0.08, length - 0.08, FINAL, UIStyle.TITLE, 300.0)

func _run_X1() -> void:
	pass

## V1 the final karne: everything prepared, everything ticked.
func _setup_V1() -> void:
	_siege(FI)
	for task: Dictionary in game.preparedness.tasks: game.preparedness.complete(task)
	game.preparedness.auto_start_left = -1.0
	game.tremor.stats["shakes"] = 3
	game.tremor.stats["covered"] = 3
	_place(1, 1100, 1)

func _run_V1() -> void:
	if _once("finish", -1.0): game.waves.siege_remaining = 0.001
	captions.white = clampf(1.0 - t / 0.14, 0.0, 1.0) if t >= 0.0 else 0.0
	# Slow push toward the outcome karne so its reasons read on a projector.
	var push: float = 1.0 + 0.22 * smoothstep(0.0, length, maxf(t, 0.0))
	var pivot: Vector2 = Vector2(960, 470)
	game.hud.scale = Vector2.ONE * push
	game.hud.position = pivot * (1.0 - push)

## TT title on the night building.
func _setup_TT() -> void:
	_prep()
	_place(0, 1000, 1)
	hide_hud = true
	hide_labels = true
	captions.dim = 1.0
	captions.title = {"start": 0.02}

func _run_TT() -> void:
	if _once("flash", 0.0): game.weather.trigger_flash(1.0)
	captions.black = clampf((t - (length - 1.2)) / 0.6, 0.0, 1.0)
	captions.fade_all = clampf((t - (length - 0.7)) / 0.6, 0.0, 1.0)
