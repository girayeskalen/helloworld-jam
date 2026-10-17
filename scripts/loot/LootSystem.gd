class_name LootSystem
extends Node2D
## Construction supplies have a strict grounded lifetime. Combat repair and safe
## construction use the same eligibility predicates as the HUD and room markers.

signal collected(kind: int)
signal repaired(room: RoomDiorama)
signal manual_action(room: RoomDiorama)

enum Kind { CEMENT_MORTAR, STEEL_CROSSBRACE, L_ANCHOR_BOLT, STORM_SHUTTER, EMERGENCY_MEDKIT }
enum RepairResult { REPAIRED, NO_MATERIAL, NOT_NEEDED, COLLAPSED, REINFORCED }
## Amber mortar, blue steel, turquoise anchor, yellow shutter, green medical bag.
const AURA: Array[Color] = [Color("ffb52e"), Color("4fc3ff"), Color("42e1d0"), Color("ffe064"), Color("2fe08a")]
const DROP_TIME: float = 0.45

@export var spawn_interval: Vector2 = Vector2(5.5, 6.5)
@export var max_active: int = 3
@export var repair_amount: float = 45.0
## One medical bag restores 25 health and the entire dash meter.
@export var medkit_heal: float = 25.0
@export var kind_weights: Array[float] = [0.36, 0.18, 0.18, 0.18, 0.10]
@export var loot_lifetime: float = 4.0
@export var pickup_radius: float = 36.0
var repair_shield_duration: float = 0.0
@export var random_seed: int = 9371

var building: ApartmentBuilding
var player: SiegePlayer
var waves: DisasterWaveManager
## {kind, room, floor, position (world, resting), drop 0..1, age, ground_age}
var items: Array[Dictionary] = []
var cement: int = 0
var steel: int = 0
var anchors: int = 0
var shutters: int = 0
var expired_count: int = 0
## Floating feedback drawn crisply by WorldLabels: {position, text, color, life}.
var messages: Array[Dictionary] = []
var spawn_count: int = 0
var last_room: int = -1
var spawn_history: Array[int] = []
var _next_spawn: float = 6.0
var _clock: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _glow: Node2D

func _ready() -> void:
	# After the player has moved this frame, so pickups use the current position.
	process_physics_priority = 3
	_glow = Node2D.new()
	_glow.name = "LootGlow"
	_glow.show_behind_parent = true
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = additive
	_glow.draw.connect(_draw_glow)
	add_child(_glow)

func configure(home: ApartmentBuilding, actor: SiegePlayer, wave_manager: DisasterWaveManager) -> void:
	building = home
	player = actor
	waves = wave_manager
	reset()

func reset() -> void:
	items.clear()
	messages.clear()
	cement = 0
	steel = 0
	anchors = 0
	shutters = 0
	expired_count = 0
	spawn_count = 0
	last_room = -1
	spawn_history.clear()
	_rng.seed = random_seed
	_next_spawn = _rng.randf_range(spawn_interval.x, spawn_interval.y)
	queue_redraw()

func materials() -> int:
	return cement + steel + anchors + shutters

func _physics_process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if building == null or (waves != null and (waves.failed or waves.victory or waves.upgrade_pending)):
		return
	_clock += delta
	# Age existing drops first: a newly spawned item starts at age zero this tick.
	for i: int in range(items.size() - 1, -1, -1):
		var item: Dictionary = items[i]
		var fall_left: float = maxf(0.0, (1.0 - float(item["drop"])) * DROP_TIME)
		item["drop"] = minf(1.0, float(item["drop"]) + delta / DROP_TIME)
		item["age"] = float(item["age"]) + delta
		item["ground_age"] = float(item["ground_age"]) + maxf(0.0, delta - fall_left)
		if building.rooms[int(item["room"])].is_collapsed() or float(item["ground_age"]) + 0.000001 >= loot_lifetime:
			_message(Vector2(item["position"]) + Vector2(-90, -40), "MALZEME ENKAZDA KAYBOLDU", Color("d4aa84"))
			expired_count += 1
			items.remove_at(i)
	_check_pickups()
	if waves == null or waves.state == DisasterWaveManager.State.SIEGE_PHASE:
		_next_spawn -= delta
		if _next_spawn <= 0.000001:
			spawn()
			_next_spawn += _rng.randf_range(spawn_interval.x, spawn_interval.y)
	for i: int in range(messages.size() - 1, -1, -1):
		messages[i]["life"] = float(messages[i]["life"]) - delta
		messages[i]["position"] = Vector2(messages[i]["position"]) + Vector2(0, -38.0 * delta)
		if float(messages[i]["life"]) <= 0.0:
			messages.remove_at(i)
	queue_redraw()
	_glow.queue_redraw()

func begin_wave() -> void:
	_next_spawn = _rng.randf_range(spawn_interval.x, spawn_interval.y)

func clear_drops() -> void:
	items.clear()
	queue_redraw()
	_glow.queue_redraw()

func count_kind(kind: int) -> int:
	match kind:
		Kind.CEMENT_MORTAR: return cement
		Kind.STEEL_CROSSBRACE: return steel
		Kind.L_ANCHOR_BOLT: return anchors
		Kind.STORM_SHUTTER: return shutters
	return 0

func grant(kind: int, amount: int = 1) -> void:
	match kind:
		Kind.CEMENT_MORTAR: cement += amount
		Kind.STEEL_CROSSBRACE: steel += amount
		Kind.L_ANCHOR_BOLT: anchors += amount
		Kind.STORM_SHUTTER: shutters += amount

## Drops one item; kind/room may be forced (tests, scripted drops). Returns false when full.
func spawn(kind: int = -1, room_index: int = -1) -> bool:
	if items.size() >= max_active:
		return false
	if room_index < 0:
		room_index = _pick_room()
	if room_index < 0 or room_index >= building.rooms.size() or building.rooms[room_index].is_collapsed():
		return false
	var room: RoomDiorama = building.rooms[room_index]
	if kind < 0:
		kind = _pick_kind()
	var ground: float = building.floor_y(room.floor_index)
	var x: float = room.global_position.x + _rng.randf_range(70.0, room.room_size.x - 70.0)
	items.append({"kind": kind, "room": room_index, "floor": room.floor_index, "position": Vector2(x, ground - 26.0), "drop": 0.0, "age": 0.0, "ground_age": 0.0})
	last_room = room_index
	spawn_count += 1
	spawn_history.append(room_index)
	return true

func _pick_room() -> int:
	var player_room: int = player_room_index()
	var occupied: Dictionary = {}
	for item: Dictionary in items:
		occupied[int(item["room"])] = true
	var preferred: Array[int] = []
	
	for index: int in range(building.rooms.size()):
		if building.rooms[index].is_collapsed() or index == last_room or index == player_room or occupied.has(index):
			continue
		var room: RoomDiorama = building.rooms[index]
		var longest_x: float = absf(room.global_position.x + room.room_size.x * 0.5 - player.global_position.x) + 130.0
		var travel: float = longest_x / player.run_speed + abs(room.floor_index - player.current_floor) * 0.45
		if travel > loot_lifetime - 0.5: continue
		preferred.append(index)
	var choices: Array[int] = preferred
	if choices.is_empty():
		return -1
	return choices[_rng.randi_range(0, choices.size() - 1)]

func _pick_kind() -> int:
	# A long run cannot depend on an unlucky string of non-repair kits.
	if cement == 0 and building.repair_count() > 0 and spawn_count % 2 == 0:
		return Kind.CEMENT_MORTAR
	var weights: Array[float] = kind_weights.duplicate()
	if player != null and player.health < player.max_health * 0.5:
		weights[Kind.EMERGENCY_MEDKIT] *= 2.0
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	var roll: float = _rng.randf() * total
	for kind: int in range(weights.size()):
		roll -= weights[kind]
		if roll <= 0.0:
			return kind
	return Kind.CEMENT_MORTAR

func player_room_index() -> int:
	if player == null or building == null:
		return -1
	return player.current_floor * ApartmentBuilding.COLUMN_COUNT + building.column_at(player.global_position.x)

func current_room() -> RoomDiorama:
	var index: int = player_room_index()
	return building.rooms[index] if index >= 0 and index < building.rooms.size() else null

## Both the room marker and E action call this exact predicate.
func repair_alert(room: RoomDiorama) -> bool:
	return room != null and room.needs_repair() and waves != null and waves.state == DisasterWaveManager.State.SIEGE_PHASE and not waves.failed and not waves.victory and not waves.upgrade_pending

func can_offer_repair() -> bool:
	return repair_alert(current_room()) and cement > 0

func can_build() -> bool:
	return waves != null and waves.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE and not waves.upgrade_pending and not waves.failed and not waves.victory

## Each distinct kit adds one tier. Cement remains a repair resource, never a free armor kit.
func next_component(room: RoomDiorama) -> int:
	for pair: Array in [[Kind.STEEL_CROSSBRACE, RoomDiorama.Reinforcement.STEEL], [Kind.STORM_SHUTTER, RoomDiorama.Reinforcement.SHUTTER], [Kind.L_ANCHOR_BOLT, RoomDiorama.Reinforcement.ANCHOR]]:
		if count_kind(pair[0]) > 0 and not room.has_reinforcement(pair[1]):
			return pair[0]
	return -1

func interaction_hint() -> String:
	var room: RoomDiorama = current_room()
	if room == null or room.is_collapsed():
		return ""
	if repair_alert(room):
		return "[E] ONAR · +%d HP · 1 ÇİMENTO" % int(repair_amount) if cement > 0 else "ONARIM İÇİN ÇİMENTO TOPLA"
	if can_build():
		if room.hp < room.max_hp and cement > 0:
			return "[E] ONAR · +%d HP · 1 ÇİMENTO" % int(repair_amount)
		var kind: int = next_component(room)
		if kind >= 0:
			return "[E] %s · KADEME %d → %d" % [short_name(kind), room.reinforcement_level, room.reinforcement_level + 1]
		return "KADEME %d/3 · %s" % [room.reinforcement_level, "TAM ZIRHLI SIĞINAK" if room.reinforcement_level == 3 else "ÇELİK / KEPENK / SABİTLEME KİTİ GEREK"]
	return ""

static func short_name(kind: int) -> String:
	return ["ÇİMENTO", "X-KİRİŞ", "SABİTLEME", "KEPENK", "İLK YARDIM"][kind]

func _check_pickups() -> void:
	if player == null or player.health <= 0.0 or player.is_shifting:
		return
	for i: int in range(items.size() - 1, -1, -1):
		var item: Dictionary = items[i]
		if float(item["drop"]) < 1.0 or int(item["floor"]) != player.current_floor:
			continue
		var spot: Vector2 = item["position"]
		if absf(player.global_position.x - spot.x) <= pickup_radius and absf(player.global_position.y - 30.0 - spot.y) <= 60.0:
			collect(i)

func collect(index: int) -> void:
	var item: Dictionary = items[index]
	items.remove_at(index)
	var kind: int = item["kind"]
	var text: String = ""
	if kind == Kind.EMERGENCY_MEDKIT:
		player.health = minf(player.max_health, player.health + medkit_heal)
		player.stamina = 100.0
		text = "İLK YARDIM · +25 CAN · ENERJİ DOLU"
	else:
		grant(kind)
		text = "+1 " + short_name(kind)
	_message(Vector2(item["position"]) + Vector2(-80, -50), text, AURA[kind])
	collected.emit(kind)

## Combat only patches a visibly damaged room. Safe construction consumes a distinct kit.
func repair_current_room() -> RepairResult:
	var room: RoomDiorama = current_room()
	if room == null or waves == null or waves.failed or waves.victory or waves.upgrade_pending:
		return RepairResult.NOT_NEEDED
	if not can_build() and not repair_alert(room):
		# In particular: intact siege rooms are completely silent and consume nothing.
		return RepairResult.NOT_NEEDED
	var anchor: Vector2 = player.global_position + Vector2(-120, -130)
	if room.is_collapsed():
		return RepairResult.COLLAPSED
	if room.hp < room.max_hp and cement > 0:
		cement -= 1
		room.repair(repair_amount)
		player.repair_shield = maxf(player.repair_shield, repair_shield_duration)
		_message(anchor, "ODA ONARILDI · +%d HP" % int(repair_amount), AURA[0])
		manual_action.emit(room)
		repaired.emit(room)
		return RepairResult.REPAIRED
	if can_build():
		var kind: int = next_component(room)
		if kind >= 0:
			var component: int = RoomDiorama.Reinforcement.STEEL
			if kind == Kind.STORM_SHUTTER: component = RoomDiorama.Reinforcement.SHUTTER
			elif kind == Kind.L_ANCHOR_BOLT: component = RoomDiorama.Reinforcement.ANCHOR
			if room.reinforce(component):
				grant(kind, -1)
				_message(anchor, "KADEME %d/3 · %s KURULDU" % [room.reinforcement_level, short_name(kind)], AURA[kind])
				manual_action.emit(room)
				repaired.emit(room)
				return RepairResult.REINFORCED
	_message(anchor, "ÇİMENTO YOK · MALZEME TOPLA" if not can_build() else "UYGUN KİT YOK · BAŞKA ODAYI DENE", Color("ffb52e"))
	return RepairResult.NO_MATERIAL

func _message(world: Vector2, text: String, color: Color) -> void:
	messages.append({"position": world, "text": text, "color": color, "life": 1.4})

func item_draw_position(item: Dictionary) -> Vector2:
	var rest: Vector2 = item["position"]
	var drop: float = item["drop"]
	if drop < 1.0:
		# Falls from the ceiling, accelerating, then a small settle.
		return rest + Vector2(0, -170.0 * (1.0 - drop * drop))
	return rest + Vector2(0, sin(float(item["age"]) * 3.2 + rest.x) * 5.0 - 4.0)

func _draw() -> void:
	for item: Dictionary in items:
		if not item_visible(item):
			continue
		var kind: int = item["kind"]
		var aura: Color = AURA[kind]
		var pulse: float = 0.75 + 0.25 * sin(float(item["age"]) * 6.0)
		# Drawn 1.35x around its centre so the icon reads from across the dark building.
		draw_set_transform(item_draw_position(item), 0.0, Vector2.ONE * 1.35)
		var p: Vector2 = Vector2.ZERO
		var remaining: float = clampf(1.0 - float(item["ground_age"]) / loot_lifetime, 0.0, 1.0)
		draw_arc(p, 25.0, -PI / 2, -PI / 2 + TAU * remaining, 32, Color(aura, 0.9 * pulse), 4.0)
		draw_arc(p, 25.0, 0, TAU, 20, CelArt.INK, 1.5)
		match kind:
			Kind.CEMENT_MORTAR:
				CelArt.poly(self, PackedVector2Array([p + Vector2(-15, -12), p + Vector2(12, -14), p + Vector2(16, 12), p + Vector2(-16, 13)]), Color("b8a786"))
				draw_line(p + Vector2(-12, -4), p + Vector2(12, -6), Color("8f8264"), 2.0)
				CelArt.poly(self, PackedVector2Array([p + Vector2(4, 2), p + Vector2(22, -6), p + Vector2(20, 4)]), Color("aeb8bd"), 1.6)
				CelArt.line(self, p + Vector2(4, 2), p + Vector2(-2, 10), Color("8a5a36"), 3.5)
			Kind.STEEL_CROSSBRACE:
				for pair: Array in [[Vector2(-14,-14), Vector2(14,14)], [Vector2(14,-14), Vector2(-14,14)]]:
					CelArt.line(self, pair[0], pair[1], aura, 7.0)
				for corner: Vector2 in [Vector2(-14,-14),Vector2(14,-14),Vector2(-14,14),Vector2(14,14)]:
					CelArt.bolt(self, corner, Color("d7e1e7"))
			Kind.L_ANCHOR_BOLT:
				var bracket: PackedVector2Array = PackedVector2Array([Vector2(-12,-14),Vector2(-12,12),Vector2(15,12)])
				draw_polyline(bracket, CelArt.INK, 12.0)
				draw_polyline(bracket, aura, 7.0)
				CelArt.bolt(self, Vector2(-12,-8), Color.WHITE)
				CelArt.bolt(self, Vector2(9,12), Color.WHITE)
			Kind.STORM_SHUTTER:
				CelArt.rect(self, Rect2(p + Vector2(-15, -15), Vector2(26, 26)), Color("6f7c84"), 2.0)
				for i: int in range(4):
					draw_line(p + Vector2(-13, -10 + i * 6), p + Vector2(9, -10 + i * 6), Color("3b454b"), 2.0)
				var bracket: PackedVector2Array = PackedVector2Array([p + Vector2(6, -2), p + Vector2(6, 14), p + Vector2(20, 14)])
				draw_polyline(bracket, CelArt.INK, 7.0)
				draw_polyline(bracket, aura, 3.5)
			Kind.EMERGENCY_MEDKIT:
				CelArt.rect(self, Rect2(p + Vector2(-16, -11), Vector2(32, 24)), Color("e8ece6"), 2.0)
				draw_rect(Rect2(p + Vector2(-8, -16), Vector2(16, 6)), CelArt.INK, false, 2.5)
				draw_rect(Rect2(p + Vector2(-3, -8), Vector2(6, 18)), Color("23b866"))
				draw_rect(Rect2(p + Vector2(-9, -2), Vector2(18, 6)), Color("23b866"))
	draw_set_transform(Vector2.ZERO)

## Additive light beam, floor ring and halo behind each drop.
func _draw_glow() -> void:
	for item: Dictionary in items:
		if not item_visible(item):
			continue
		var p: Vector2 = item_draw_position(item)
		var rest: Vector2 = item["position"]
		var aura: Color = AURA[int(item["kind"])]
		var pulse: float = 0.7 + 0.3 * sin(float(item["age"]) * 6.0)
		var floor_y: float = rest.y + 26.0
		_glow.draw_polygon(PackedVector2Array([Vector2(rest.x - 26, floor_y), Vector2(rest.x + 26, floor_y), Vector2(rest.x + 8, floor_y - 175), Vector2(rest.x - 8, floor_y - 175)]),
			PackedColorArray([Color(aura, 0.42 * pulse), Color(aura, 0.42 * pulse), Color(aura, 0.0), Color(aura, 0.0)]))
		_glow.draw_circle(p, 46.0, Color(aura, 0.18 * pulse))
		_glow.draw_circle(p, 28.0, Color(aura, 0.26 * pulse))
		for i: int in range(3):
			var ring: PackedVector2Array = PackedVector2Array()
			for k: int in range(18):
				var a: float = TAU * k / 18.0
				ring.append(Vector2(rest.x, floor_y - 4) + Vector2(cos(a) * (34.0 - i * 9.0), sin(a) * (7.0 - i * 2.0)))
			_glow.draw_colored_polygon(ring, Color(aura, 0.10 * pulse))

func item_visible(item: Dictionary) -> bool:
	var remaining: float = loot_lifetime - float(item["ground_age"])
	return remaining > 1.5 or int(float(item["ground_age"]) * 12.0) % 2 == 0

func consume_construction() -> bool:
	for kind: int in [Kind.CEMENT_MORTAR, Kind.STEEL_CROSSBRACE, Kind.L_ANCHOR_BOLT, Kind.STORM_SHUTTER]:
		if count_kind(kind) > 0:
			grant(kind, -1)
			return true
	return false

func reflex_drop() -> void:
	# The perfect-dodge reward obeys max 3; replace the oldest drop when full.
	if items.size() >= max_active:
		var oldest: int = 0
		for i: int in range(1, items.size()):
			if float(items[i]["age"]) > float(items[oldest]["age"]): oldest = i
		items.remove_at(oldest)
	if spawn(Kind.CEMENT_MORTAR, player_room_index()):
		items[-1]["position"] = Vector2(clampf(player.global_position.x + 65.0, building.interior_left(), building.interior_right()), building.floor_y(player.current_floor) - 26)
