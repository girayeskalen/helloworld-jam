class_name WorldLabels
extends Node2D
## Screen-space cues without words: a small warning diamond over rooms that need
## repair, bobbing chevrons over preparedness tasks, an E key over the player when E
## would act (with a work ring), tutorial key caps (A D, W, W W, S, C, SHIFT) and
## arrows, the C key and an amber screen edge during a tremor, and a green frame on
## the safe floor during the storm roulette. Hazards explain themselves through their
## telegraphs; attack names, floating pickup texts and DODGE/graze words are gone.

var game: MainGame
## Cue glyphs drawn in the last frame, and how many of them contained letters.
var drawn: int = 0
var texts_drawn: int = 0
var repair_markers: int = 0
var safe_frames: int = 0
var task_markers: int = 0
## Key caps drawn this frame (E, tutorial keys, C), in draw order.
var keys_drawn: PackedStringArray = PackedStringArray()
var arrows_drawn: int = 0
var tremor_edges: bool = false
## Rooms framed as needing repair this frame, and the guide chevron over a kit.
var repair_frames: int = 0
var loot_guides: int = 0
## When each room's repair alert first appeared (for the expanding ping).
var _alert_since: Dictionary = {}
const PING_TIME: float = 1.1
const RECOVERY_LIMIT: int = 16
var recovery_frames: Array[Dictionary] = []

func clear_feel() -> void:
	recovery_frames.clear()
	_alert_since.clear()
	queue_redraw()

func on_room_recovered(room: RoomDiorama) -> void:
	for index: int in range(recovery_frames.size() - 1, -1, -1):
		if recovery_frames[index]["room"] == room: recovery_frames.remove_at(index)
	if recovery_frames.size() >= RECOVERY_LIMIT: recovery_frames.pop_front()
	recovery_frames.append({"room": room, "age": 0.0})
	queue_redraw()

func configure(owner_game: MainGame) -> void:
	game = owner_game

func _process(delta: float) -> void:
	advance_feel(delta / maxf(.001, Engine.time_scale))
	queue_redraw()

func advance_feel(delta: float) -> void:
	for index: int in range(recovery_frames.size() - 1, -1, -1):
		recovery_frames[index]["age"] = float(recovery_frames[index]["age"]) + delta
		if float(recovery_frames[index]["age"]) >= .7: recovery_frames.remove_at(index)

func _draw() -> void:
	drawn = 0
	texts_drawn = 0
	repair_markers = 0
	safe_frames = 0
	task_markers = 0
	keys_drawn = PackedStringArray()
	arrows_drawn = 0
	tremor_edges = false
	repair_frames = 0
	loot_guides = 0
	if game == null:
		return
	var clock: float = Time.get_ticks_msec() / 1000.0
	_draw_tremor_edges(clock)
	_draw_safe_floor(clock)
	_draw_repair_markers(clock)
	_draw_recoveries()
	_draw_tasks(clock)
	_draw_loot_guide(clock)
	_draw_action_key()
	_draw_hints(clock)

## Güvenli Kat Ruleti: the open floor gets a soft green frame (the swept floors
## already carry the red-edged corridor telegraph).
func _draw_safe_floor(clock: float) -> void:
	var b: ApartmentBuilding = game.building
	for attack: HazardAttack in game.telegraphs.pending:
		if attack.pattern != HazardAttack.Pattern.SAFE_FLOOR or not attack.lead or attack.warning_delay > 0.0: continue
		var safe: int = int(String(attack.room_source).get_slice("_", 1))
		var top_left: Vector2 = game.world_to_screen(Vector2(b.interior_left(), b.floor_y(safe) - 196.0))
		var bottom_right: Vector2 = game.world_to_screen(Vector2(b.interior_right(), b.floor_y(safe)))
		var frame: Rect2 = Rect2(top_left, bottom_right - top_left)
		var pulse: float = 0.55 + 0.35 * sin(clock * 10.0)
		draw_rect(frame, Color(UIStyle.SAFE, 0.07))
		draw_rect(frame, Color(UIStyle.SAFE, pulse), false, 3.0)
		safe_frames += 1
		drawn += 1

## Rooms that need repair: the whole room gets a pulsing frame, a large warning
## diamond with a breathing ring sits in its upper-left quarter (clear of the lamp
## glow), and a newly damaged room sends out one expanding ping. Red when critical.
func _draw_repair_markers(clock: float) -> void:
	for room: RoomDiorama in game.building.rooms:
		if not game.loot.repair_alert(room):
			_alert_since.erase(room)
			continue
		if not _alert_since.has(room): _alert_since[room] = clock
		var critical: bool = room.state() == RoomDiorama.RoomState.CRITICAL
		var speed: float = 9.0 if critical else 5.0
		var pulse: float = 0.6 + 0.4 * sin(clock * speed + room.room_kind)
		var color: Color = UIStyle.DANGER if critical else UIStyle.ALERT
		var frame: Rect2 = repair_frame(room)
		draw_rect(frame, Color(color, 0.05 + 0.05 * pulse))
		draw_rect(frame, Color(0.03, 0.04, 0.05, 0.5), false, 6.0)
		draw_rect(frame, Color(color, 0.45 + 0.45 * pulse), false, 3.0)
		repair_frames += 1
		var center: Vector2 = game.world_to_screen(room.global_position + Vector2(room.room_size.x * 0.22, 46)).round()
		var breath: float = fmod(clock * 1.2 + room.room_kind * 0.37, 1.0)
		draw_arc(center, 18.0 + breath * 16.0, 0.0, TAU, 28, Color(color, (1.0 - breath) * 0.7), 3.0)
		var age: float = clock - float(_alert_since[room])
		if age < PING_TIME:
			var t: float = age / PING_TIME
			draw_arc(center, 24.0 + t * 130.0, 0.0, TAU, 40, Color(color, (1.0 - t) * 0.85), 5.0)
		_diamond(center, 16.0, Color(color, 0.75 + 0.25 * pulse))
		repair_markers += 1
		drawn += 1

func repair_frame(room: RoomDiorama) -> Rect2:
	var top_left: Vector2 = game.world_to_screen(room.global_position + Vector2(10, 8)).round()
	var bottom_right: Vector2 = game.world_to_screen(room.global_position + room.room_size - Vector2(10, 24)).round()
	return Rect2(top_left, bottom_right - top_left)

func _draw_recoveries() -> void:
	for data: Dictionary in recovery_frames:
		var frame: Rect2 = repair_frame(data["room"])
		var alpha: float = 1.0 - float(data["age"]) / .7
		draw_rect(frame, Color(UIStyle.SAFE, .12 * alpha))
		draw_rect(frame, Color(UIStyle.SAFE, alpha), false, 4.0)

## Repair guidance: a bobbing amber chevron over the column kit to fetch.
func _draw_loot_guide(clock: float) -> void:
	if game.tutorial == null or game.tutorial.guide_loot < 0 or game.tutorial.guide_loot >= game.loot.items.size(): return
	var item: Dictionary = game.loot.items[game.tutorial.guide_loot]
	var tip: Vector2 = game.world_to_screen(game.loot.item_draw_position(item) + Vector2(0, -58)).round() + Vector2(0, roundf(sin(clock * 5.0) * 5.0))
	draw_colored_polygon(PackedVector2Array([tip + Vector2(-17, -16), tip + Vector2(17, -16), tip + Vector2(0, 13)]), Color(0.03, 0.04, 0.05, 0.9))
	draw_colored_polygon(PackedVector2Array([tip + Vector2(-12, -12), tip + Vector2(12, -12), tip + Vector2(0, 8)]), UIStyle.ALERT)
	loot_guides += 1
	drawn += 1

## Hazırlık: a bobbing chevron in the task's colour over every task still to do.
func _draw_tasks(clock: float) -> void:
	var prep: Preparedness = game.preparedness
	if prep == null or not prep.available(): return
	var reach: Dictionary = prep.in_reach()
	var index: int = 0
	for task: Dictionary in prep.pending():
		index += 1
		var color: Color = Preparedness.COLORS[int(task["kind"])]
		var tip: Vector2 = game.world_to_screen(prep.marker(task)).round() + Vector2(0, roundf(sin(clock * 4.0 + index) * 4.0))
		var size: float = 12.0 if task == reach else 9.0
		var rim: float = size + 4.0
		draw_colored_polygon(PackedVector2Array([tip + Vector2(-rim, -rim), tip + Vector2(rim, -rim), tip + Vector2(0, rim * 0.8)]), Color(0.03, 0.04, 0.05, 0.9))
		draw_colored_polygon(PackedVector2Array([tip + Vector2(-size, -size), tip + Vector2(size, -size), tip + Vector2(0, size * 0.8)]), Color(color, 0.7 + 0.3 * sin(clock * 6.0 + index)))
		task_markers += 1
		drawn += 1

## The E key floats over the player only while E would actually do something.
func _draw_action_key() -> void:
	var loot: LootSystem = game.loot
	if loot == null or game.waves.failed or game.waves.victory or game.waves.upgrade_pending: return
	var center: Vector2 = game.world_to_screen(game.player.global_position + Vector2(0, -112)).round()
	var prep: Preparedness = game.preparedness
	if prep != null:
		var task: Dictionary = prep.working if not prep.working.is_empty() else prep.in_reach()
		if not task.is_empty():
			var color: Color = Preparedness.COLORS[int(task["kind"])]
			var cap: Rect2 = _keycap(center, "E", color)
			if not prep.working.is_empty():
				draw_arc(center, cap.size.x * 0.5 + 6.0, -PI * 0.5, -PI * 0.5 + TAU * prep.work_progress(), 24, color, 3.0)
			return
	if loot.short_hint() == "": return
	_keycap(center, "E", UIStyle.ALERT if loot.can_offer_repair() else UIStyle.TEXT)

## Tutorial key caps over the player (A D, W, W W, S, SHIFT) plus the C key whenever
## a tremor is announced or shaking; an arrow beside the player toward a task.
func _draw_hints(clock: float) -> void:
	var player: SiegePlayer = game.player
	if game.waves.failed or game.waves.victory or game.waves.upgrade_pending or player.controls_locked: return
	var keys: PackedStringArray = PackedStringArray()
	if game.tutorial != null: keys = game.tutorial.hint_keys.duplicate()
	var tremor: bool = game.tremor != null and game.tremor.busy() and not player.covering
	if tremor and not keys.has("C"): keys = PackedStringArray(["C"])
	var anchor: Vector2 = game.world_to_screen(player.global_position + Vector2(0, -178)).round()
	if not keys.is_empty():
		var pulse: float = 0.75 + 0.25 * sin(clock * 10.0)
		var color: Color = Color(UIStyle.ALERT, pulse) if keys.has("C") else UIStyle.TEXT
		var widths: Array[float] = []
		var total: float = 0.0
		for key: String in keys:
			widths.append(_keycap_width(key))
			total += widths[-1]
		total += 8.0 * (keys.size() - 1)
		var x: float = anchor.x - total * 0.5
		for i: int in range(keys.size()):
			_keycap(Vector2(roundf(x + widths[i] * 0.5), anchor.y), keys[i], color)
			x += widths[i] + 8.0
	if game.tutorial != null and game.tutorial.arrow != 0:
		var side: float = float(game.tutorial.arrow)
		var tip: Vector2 = game.world_to_screen(player.global_position + Vector2(side * 70.0, -40.0)).round() + Vector2(roundf(side * (2.0 + 4.0 * sin(clock * 7.0))), 0)
		for k: int in range(2):
			var point: Vector2 = tip + Vector2(side * k * 12.0, 0)
			var chevron: PackedVector2Array = PackedVector2Array([point + Vector2(-side * 9, -11), point, point + Vector2(-side * 9, 11)])
			draw_polyline(chevron, Color(0.03, 0.04, 0.05, 0.9), 7.0)
			draw_polyline(chevron, UIStyle.TEXT, 3.0)
		arrows_drawn += 1
		drawn += 1

## Tremor: an amber pulse along the screen edges (stronger while it shakes).
func _draw_tremor_edges(clock: float) -> void:
	if game.tremor == null or not game.tremor.busy(): return
	var strength: float = 1.0 if game.tremor.active() else 0.55
	var alpha: float = (0.10 + 0.08 * sin(clock * 12.0)) * strength
	for i: int in range(5):
		var depth: float = 6.0 + i * 10.0
		var tint: Color = Color(UIStyle.ALERT, alpha * (1.0 - i / 5.0))
		draw_rect(Rect2(0, 0, 1920, depth), tint)
		draw_rect(Rect2(0, 1080 - depth, 1920, depth), tint)
		draw_rect(Rect2(0, 0, depth, 1080), tint)
		draw_rect(Rect2(1920 - depth, 0, depth, 1080), tint)
	tremor_edges = true

static func _keycap_width(label: String) -> float:
	return maxf(32.0, UIStyle.width(label, UIStyle.SMALL) + 18.0)

## A dark key cap with a coloured rim and its letter(s); returns the cap rect.
func _keycap(center: Vector2, label: String, accent: Color) -> Rect2:
	var width: float = _keycap_width(label)
	var cap: Rect2 = Rect2(center - Vector2(roundf(width * 0.5), 16), Vector2(width, 32))
	draw_rect(cap, Color(0.03, 0.04, 0.05, 0.85))
	draw_rect(cap, Color(accent, 0.9), false, 2.0)
	UIStyle.text(self, Vector2(center.x + 1, center.y + 7), label, UIStyle.SMALL, accent, HORIZONTAL_ALIGNMENT_CENTER)
	keys_drawn.append(label)
	texts_drawn += 1
	drawn += 1
	return cap

func _diamond(center: Vector2, radius: float, color: Color) -> void:
	var rim: float = radius + 4.0
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -rim), center + Vector2(rim, 0), center + Vector2(0, rim), center + Vector2(-rim, 0)]), Color(0.03, 0.04, 0.05, 0.9))
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius, 0), center + Vector2(0, radius), center + Vector2(-radius, 0)]), color)
	var mark: Color = Color(0.08, 0.04, 0.03, 1.0)
	var unit: float = radius / 11.0
	draw_rect(Rect2(center + Vector2(-1.5, -6) * unit, Vector2(3, 7) * unit), mark)
	draw_rect(Rect2(center + Vector2(-1.5, 3) * unit, Vector2(3, 3) * unit), mark)
