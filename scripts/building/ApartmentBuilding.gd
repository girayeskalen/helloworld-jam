class_name ApartmentBuilding
extends Node2D

const COLUMN_COUNT: int = 4
const K = BuildingProp.Kind

@export var custom_sprite: Texture2D
@export var art_assets: SiegeArtAssets
@export var room_width: float = 400.0
@export var building_width: float = 1600.0
@export var floor_height: float = 220.0
@export_range(4, 4) var floor_count: int = 4
@export var max_integrity: float = 100.0
## This many simultaneously collapsed rooms bring the whole building down.
@export var collapse_limit: int = 4
## Building integrity is the average of the 16 room HP values (0..100, HUD meter).
var integrity: float:
	get:
		if rooms.is_empty():
			return max_integrity
		var total: float = 0.0
		for room: RoomDiorama in rooms:
			total += room.hp / room.max_hp
		return total / float(rooms.size()) * max_integrity
## True once the whole apartment has come down (game over until R).
const REPAIR_CAP: int = 3
const REPAIR_GRACE: float = 10.0
var pacing_enabled: bool = false
var structural_factor: float = 1.0
var secondary_factor: float = 1.0
var wear_clock: float = 0.0
var _damage_credit: Dictionary = {}
var _alert_age: Dictionary = {}
var _visual_origin: Dictionary = {}
var sway: Vector2 = Vector2.ZERO
## 0..1 strength of a live tremor: painted rooms/props rock harder (collision never moves).
var tremor: float = 0.0
var _tremor_clock: float = 0.0
var collapsed_building: bool = false
var collapse_time: float = 0.0

func restore_integrity() -> void:
	pacing_enabled = false
	wear_clock = 0.0
	_damage_credit.clear()
	_alert_age.clear()
	collapsed_building = false
	collapse_time = 0.0
	tremor = 0.0
	for prop: BuildingProp in props:
		prop.secured = false
		prop.set_toppled(false, 1.0, true)
		prop.tilt = 0.0
		prop.condition = prop.authored_condition
	for room: RoomDiorama in rooms:
		room.shaking = false
		room.restore()

## Building-wide wear in integrity points: every standing room loses that much HP.
func damage_integrity(amount: float) -> void:
	if amount <= 0.0:
		return
	for room: RoomDiorama in rooms:
		if not room.is_collapsed():
			room.apply_damage(amount * room.max_hp / max_integrity * structural_factor,1)

func column_at(x: float) -> int:
	return clampi(int(floor((x - global_position.x) / room_width)), 0, COLUMN_COUNT - 1)

func room_at_point(floor_index: int, x: float) -> RoomDiorama:
	return room_at(clampi(floor_index, 0, floor_count - 1), column_at(x))

func damage_room(floor_index: int, column: int, amount: float, source: int = 1) -> float:
	return room_at(clampi(floor_index, 0, floor_count - 1), clampi(column, 0, COLUMN_COUNT - 1)).apply_damage(amount,source)

func damage_room_at(floor_index: int, x: float, amount: float, source: int = 1) -> float:
	return room_at_point(floor_index, x).apply_damage(amount,source)

func collapsed_count() -> int:
	var count: int = 0
	for room: RoomDiorama in rooms:
		count += 1 if room.is_collapsed() else 0
	return count

## Game-over rule: 4+ rooms down at once, or the whole building at 0%.
func is_failing() -> bool:
	return collapsed_count() >= collapse_limit or integrity <= 0.0

func begin_siege_pacing() -> void:
	_damage_credit.clear()
	_alert_age.clear()
	for room: RoomDiorama in rooms:
		_damage_credit[room] = 1.0
		if room.needs_repair(): _alert_age[room] = 0.0

func repair_count() -> int:
	var count: int = 0
	for room: RoomDiorama in rooms:
		if room.needs_repair(): count += 1
	return count

## All sources (slams, splits, wear, direct damage) share this gate. Warnings
## represent real HP: a fourth room cannot cross the 70% boundary. A new alert
## gets ten real seconds to fetch material, then loses at most 1.3 HP/second.
func limit_damage(amount: float, room: RoomDiorama) -> float:
	if not pacing_enabled: return amount
	var threshold: float = room.max_hp * 0.7
	if not room.needs_repair() and repair_count() >= REPAIR_CAP:
		amount = minf(amount, maxf(0.0, room.hp - threshold))
	if room.needs_repair() and float(_alert_age.get(room, 0.0)) < REPAIR_GRACE:
		return 0.0
	var allowed: float = minf(amount, float(_damage_credit.get(room, 0.0)))
	_damage_credit[room] = maxf(0.0, float(_damage_credit.get(room, 0.0)) - allowed)
	if room.hp >= threshold and room.hp - allowed < threshold:
		_alert_age[room] = 0.0
		# No burst may jump straight from intact to critical.
		allowed = minf(allowed, room.hp - threshold + 0.25)
	return allowed

func advance_wear(delta: float) -> void:
	if not pacing_enabled: return
	wear_clock += delta
	var focus: RoomDiorama = null
	for room: RoomDiorama in rooms:
		if room.is_collapsed(): continue
		if room.needs_repair():
			_alert_age[room] = float(_alert_age.get(room, 0.0)) + delta
		else:
			_alert_age.erase(room)
			if focus == null or room.hp < focus.hp: focus = room
		var rate: float = 1.3 if room.needs_repair() else 4.0
		_damage_credit[room] = minf(1.5, float(_damage_credit.get(room, 0.0)) + rate * delta)
		room.apply_damage(delta * (0.6 if room.needs_repair() else 0.04)*structural_factor)
	if focus != null:
		focus.apply_damage(delta * 2.0 / (1.0 + repair_count() * 0.65)*structural_factor)

## Sway only painted children; static collision bodies and floor coordinates never move.
func _process(delta: float) -> void:
	var desired: Vector2 = Vector2(sin(wear_clock * 2.1) * 1.8 + sin(wear_clock * 31.0) * 0.45, sin(wear_clock * 23.0) * 0.55) if pacing_enabled else Vector2.ZERO
	if tremor > 0.0:
		_tremor_clock += delta
		desired += Vector2(sin(_tremor_clock * 37.0) * 6.0 + sin(_tremor_clock * 11.0) * 3.0, sin(_tremor_clock * 29.0) * 2.5) * tremor
	sway = sway.lerp(desired, minf(1.0, delta * 15.0))
	for child: Node in get_children():
		if child is RoomDiorama or child is BuildingProp or child is RoomLighting:
			if not _visual_origin.has(child): _visual_origin[child] = child.position
			child.position = Vector2(_visual_origin[child]) + sway
	# CanvasItem command lists stay cached; sway moves their common transform.
	if _facade != null: _facade.position = sway

## During a siege, already damaged rooms keep crumbling slowly unless repaired.
func erode(delta: float, rate: float) -> void:
	for room: RoomDiorama in rooms:
		var current: int = room.state()
		if current == RoomDiorama.RoomState.DAMAGED or current == RoomDiorama.RoomState.CRITICAL:
			room.apply_damage(rate * delta*structural_factor)

## Secondary electrical/gas damage is separate from structural crumbling.
## It never bypasses player telegraphs: only the already damaged room loses HP.
func secondary_damage(delta: float, rate: float) -> void:
	for room: RoomDiorama in rooms:
		if room.needs_repair() and not room.utilities_isolated:
			room.apply_damage(rate * delta*secondary_factor,4)

## The apartment gives way: every room shakes and sheds dust, lights die.
func start_collapse() -> void:
	collapsed_building = true
	collapse_time = 1.6
	for room: RoomDiorama in rooms:
		room.shaking = true

var props: Array[BuildingProp] = []
var rooms: Array[RoomDiorama] = []
var floor_bodies: Array[StaticBody2D] = []
## Additive lamp cones above rooms/props, below the pillars.
var lighting: RoomLighting
var darkness: Color = Color.WHITE
var _cache_source: bool = false
var _facade: Sprite2D
var _static_cache: SubViewport

func _ready() -> void:
	if _cache_source: return
	if art_assets != null and art_assets.building != null:
		custom_sprite = art_assets.building
	_build_rooms()
	_build_pillars()
	_build_collisions()
	_static_cache = StaticCanvasCache.create(self,Rect2(-60,-120,building_width+120,floor_count*floor_height+180))
	StaticCanvasCache.painter(_static_cache,self,["custom_sprite","building_width","floor_count","floor_height"])
	_facade = Sprite2D.new()
	_facade.name = "CachedFacade"
	_facade.centered = false
	_facade.offset = Vector2(-60,-120)
	_facade.texture = _static_cache.get_texture()
	add_child(_facade)
	for prop: BuildingProp in props:
		prop.authored_condition = prop.condition
	lighting = RoomLighting.new()
	lighting.name = "RoomLighting"
	lighting.z_index = 3
	add_child(lighting)
	lighting.setup(self)
	if custom_sprite != null:
		for room: RoomDiorama in rooms:
			room.visible = false
		for prop: BuildingProp in props:
			prop.visible = false

## Blackout tint for everything painted (rooms, furniture, pillars, facade). The light
## layer is deliberately excluded so lamp cones and the helmet beam stay bright.
func set_darkness(tint: Color) -> void:
	if tint.is_equal_approx(darkness):
		return
	darkness = tint
	self_modulate = tint
	if _facade != null: _facade.modulate = tint
	for room: RoomDiorama in rooms:
		room.modulate = tint
	for prop: BuildingProp in props:
		if prop.get_parent() == self:
			prop.modulate = tint

## Step 7: during a siege loose furniture recedes (cooler, matte) so the neon bullets
## read first. Additive lamp cones still light it, so the tint is ~31% to land at ~25%
## darker on screen (measured on native 1920x1080 captures). Pillars/windows stay full.
const COMBAT_DIM_TINT: Color = Color(0.68, 0.69, 0.74)
var combat_dim: float = 0.0

func set_combat_dim(amount: float) -> void:
	amount = clampf(amount, 0.0, 1.0)
	if is_equal_approx(amount, combat_dim): return
	combat_dim = amount
	var tint: Color = Color.WHITE.lerp(COMBAT_DIM_TINT, amount)
	for prop: BuildingProp in props:
		if prop.kind not in [BuildingProp.Kind.PILLAR, BuildingProp.Kind.WINDOW]:
			prop.self_modulate = tint

func floor_y(floor_index: int) -> float:
	return global_position.y + (floor_count - floor_index) * floor_height - 20.0

func center_x() -> float:
	return global_position.x + building_width * 0.5

func interior_left() -> float:
	return global_position.x + 24.0

func interior_right() -> float:
	return global_position.x + building_width - 24.0

func room_at(floor_index: int, column: int) -> RoomDiorama:
	return rooms[floor_index * COLUMN_COUNT + column]

func _build_rooms() -> void:
	# Index = floor * 4 + column; every room has its own wall tone and identity.
	var colors: Array[Color] = [
		Color("969b86"), Color("b8a98a"), Color("b0c2b0"), Color("8fb0b8"),
		Color("c0a084"), Color("b58e7a"), Color("7e9c9b"), Color("77729a"),
		Color("a99caf"), Color("a7c9c4"), Color("9fb8b2"), Color("c4b48f"),
		Color("93ad84"), Color("9aa3b5"), Color("d0b78a"), Color("7d8b86")]
	for floor_index: int in range(floor_count):
		var row_y: float = (floor_count - floor_index - 1) * floor_height
		for column: int in range(COLUMN_COUNT):
			var index: int = floor_index * COLUMN_COUNT + column
			var room: RoomDiorama = RoomDiorama.new()
			room.name = "Room_%d_%d" % [floor_index, column]
			room.position = Vector2(column * room_width, row_y)
			room.room_size = Vector2(room_width, floor_height)
			room.room_kind = index
			room.floor_index = floor_index
			# Grimdark: keep each room's hue but pull it toward soot grey.
			room.wall_color = colors[index].lerp(Color("4a4d4f"), 0.38)
			if art_assets != null:
				room.custom_sprite = art_assets.room
			add_child(room)
			rooms.append(room)
			room.damage_limiter = Callable(self, "limit_damage").bind(room)
			_furnish(room, floor_index, column)

func _prop(parent: Node2D, kind: BuildingProp.Kind, point: Vector2, size: Vector2, id_suffix: String, floor_index: int, state: BuildingProp.Condition = BuildingProp.Condition.UNSECURED) -> BuildingProp:
	var prop: BuildingProp = BuildingProp.new()
	prop.kind = kind
	prop.position = point
	prop.prop_size = size
	prop.floor_index = floor_index
	prop.condition = state
	prop.object_id = StringName("f%d_%s" % [floor_index, id_suffix])
	prop.name = String(prop.object_id)
	if art_assets != null:
		prop.custom_sprite = art_assets.texture_for_prop(kind, prop.object_id)
	parent.add_child(prop)
	props.append(prop)
	return prop

func _furnish(room: RoomDiorama, floor_index: int, column: int) -> void:
	# Lists are authored per room: kind, foot point, size, unique suffix, optional palette.
	var window: String = "window_%d" % column
	var lamp: String = "lamp_%d" % column
	var furniture: Array = []
	match room.room_kind:
		RoomDiorama.Kind.WORKSHOP: furniture = [
			[K.BOILER, Vector2(82, 188), Vector2(92, 146), "boiler"],
			[K.WORKBENCH, Vector2(222, 184), Vector2(140, 113), "workbench"],
			[K.TOOL_CABINET, Vector2(337, 184), Vector2(63, 116), "tool_cabinet"],
			[K.TOOLBOX, Vector2(296, 197), Vector2(48, 28), "toolbox"],
			[K.LAMP, Vector2(222, 50), Vector2(37, 38), lamp]]
		RoomDiorama.Kind.LOBBY: furniture = [
			[K.ENTRY_DOOR, Vector2(74, 178), Vector2(90, 142), "entry_door"],
			[K.MAILBOXES, Vector2(194, 150), Vector2(104, 70), "mailboxes"],
			[K.FIRE_CABINET, Vector2(268, 160), Vector2(46, 62), "fire_cabinet"],
			[K.ELECTRICAL, Vector2(328, 162), Vector2(56, 74), "main_panel"],
			[K.PLANT, Vector2(376, 194), Vector2(30, 54), "lobby_plant"],
			[K.LAMP, Vector2(194, 50), Vector2(37, 38), lamp]]
		RoomDiorama.Kind.KITCHEN: furniture = [
			[K.WINDOW, Vector2(64, 131), Vector2(60, 77), window],
			[K.LAMP, Vector2(105, 50), Vector2(37, 38), lamp],
			[K.FRIDGE, Vector2(61, 188), Vector2(64, 128), "fridge"],
			[K.KITCHEN, Vector2(206, 186), Vector2(185, 73), "kitchen"],
			[K.SHELF, Vector2(203, 98), Vector2(119, 47), "plates"],
			[K.STOVE, Vector2(327, 188), Vector2(65, 68), "stove"],
			[K.HOOD, Vector2(325, 113), Vector2(78, 60), "hood"]]
		RoomDiorama.Kind.LAUNDRY: furniture = [
			[K.WINDOW, Vector2(354, 126), Vector2(50, 62), window],
			[K.LAMP, Vector2(150, 50), Vector2(37, 38), lamp],
			[K.WASHER, Vector2(72, 192), Vector2(72, 80), "washer"],
			[K.WASHER, Vector2(154, 192), Vector2(72, 80), "dryer", Color("c99a6b")],
			[K.GAS_VALVE, Vector2(258, 170), Vector2(30, 115), "gas_valve"],
			[K.GAS_VALVE, Vector2(304, 170), Vector2(26, 115), "water_valve"]]
		RoomDiorama.Kind.LIVING: furniture = [
			[K.WINDOW, Vector2(64, 131), Vector2(60, 77), window],
			[K.SOFA, Vector2(113, 182), Vector2(138, 68), "sofa"],
			[K.TV, Vector2(322, 181), Vector2(81, 87), "tv"],
			[K.COFFEE_TABLE, Vector2(219, 192), Vector2(83, 45), "coffee_table"],
			[K.CHANDELIER, Vector2(211, 102), Vector2(99, 83), "chandelier"],
			[K.PLANT, Vector2(367, 192), Vector2(34, 61), "living_plant"]]
		RoomDiorama.Kind.DINING: furniture = [
			[K.WINDOW, Vector2(60, 126), Vector2(54, 70), window],
			[K.LAMP, Vector2(200, 50), Vector2(37, 38), lamp],
			[K.VITRINE, Vector2(352, 188), Vector2(70, 150), "vitrine"],
			[K.DINING_CHAIR, Vector2(110, 194), Vector2(38, 72), "chair_left"],
			[K.DINING_TABLE, Vector2(200, 194), Vector2(160, 62), "dining_table"],
			[K.DINING_CHAIR, Vector2(290, 194), Vector2(38, 72), "chair_right"]]
		RoomDiorama.Kind.STUDY: furniture = [
			[K.WINDOW, Vector2(64, 131), Vector2(60, 77), window],
			[K.LAMP, Vector2(105, 50), Vector2(37, 38), lamp],
			[K.COMPUTER, Vector2(186, 181), Vector2(129, 94), "computer"],
			[K.BOOKCASE, Vector2(325, 181), Vector2(78, 161), "bookcase"],
			[K.SWIVEL_CHAIR, Vector2(223, 195), Vector2(46, 71), "chair"],
			[K.CORKBOARD, Vector2(180, 91), Vector2(90, 42), "corkboard"],
			[K.PLANT, Vector2(64, 194), Vector2(34, 61), "study_plant"]]
		RoomDiorama.Kind.MUSIC: furniture = [
			[K.LAMP, Vector2(170, 50), Vector2(37, 38), lamp],
			[K.POSTER, Vector2(258, 98), Vector2(64, 52), "record_wall", Color("c46f55")],
			[K.PIANO, Vector2(112, 190), Vector2(150, 104), "piano"],
			[K.TURNTABLE, Vector2(258, 188), Vector2(84, 72), "turntable"],
			[K.SPEAKER, Vector2(350, 190), Vector2(52, 108), "speaker"]]
		RoomDiorama.Kind.MASTER_BEDROOM: furniture = [
			[K.WINDOW, Vector2(64, 131), Vector2(60, 77), window],
			[K.CURTAINS, Vector2(64, 143), Vector2(83, 107), "curtains"],
			[K.LAMP, Vector2(105, 50), Vector2(37, 38), lamp],
			[K.BED, Vector2(170, 192), Vector2(160, 96), "bed", Color("526975")],
			[K.NIGHTSTAND, Vector2(272, 184), Vector2(40, 75), "nightstand"],
			[K.WARDROBE, Vector2(342, 188), Vector2(84, 158), "wardrobe"]]
		RoomDiorama.Kind.BATHROOM: furniture = [
			[K.LAMP, Vector2(200, 50), Vector2(37, 38), lamp],
			[K.BOILER, Vector2(364, 124), Vector2(40, 70), "water_heater"],
			[K.BATHTUB, Vector2(118, 192), Vector2(180, 74), "bathtub"],
			[K.SINK_MIRROR, Vector2(290, 188), Vector2(72, 148), "sink_mirror"],
			[K.PLANT, Vector2(372, 194), Vector2(26, 44), "bath_plant"]]
		RoomDiorama.Kind.KIDS: furniture = [
			[K.LAMP, Vector2(200, 50), Vector2(37, 38), lamp],
			[K.BUNK_BED, Vector2(114, 189), Vector2(129, 134), "bunk"],
			[K.TOY_SHELF, Vector2(315, 184), Vector2(86, 90), "toys"],
			[K.AIRCON, Vector2(321, 69), Vector2(80, 29), "aircon"],
			[K.POSTER, Vector2(236, 124), Vector2(37, 51), "poster"],
			[K.POSTER, Vector2(229, 168), Vector2(31, 33), "poster_small", Color("7f9fb8")]]
		RoomDiorama.Kind.GUEST: furniture = [
			[K.WINDOW, Vector2(330, 126), Vector2(54, 68), window],
			[K.LAMP, Vector2(60, 50), Vector2(37, 38), lamp],
			[K.POSTER, Vector2(140, 92), Vector2(70, 44), "guest_painting", Color("6f8f7c")],
			[K.BED, Vector2(140, 192), Vector2(140, 84), "guest_bed", Color("8c6f86")],
			[K.NIGHTSTAND, Vector2(240, 184), Vector2(36, 68), "guest_nightstand"],
			[K.SUITCASE, Vector2(330, 196), Vector2(54, 58), "suitcase"]]
		RoomDiorama.Kind.GREENHOUSE: furniture = [
			[K.SKYLIGHT, Vector2(200, 52), Vector2(120, 34), "skylight"],
			[K.PLANTER_RACK, Vector2(318, 188), Vector2(110, 124), "planter_rack"],
			[K.PLANT, Vector2(66, 194), Vector2(36, 58), "fern"],
			[K.PLANT, Vector2(132, 194), Vector2(50, 96), "palm"],
			[K.PLANT, Vector2(200, 194), Vector2(30, 46), "herb"]]
		RoomDiorama.Kind.GYM: furniture = [
			[K.LAMP, Vector2(180, 50), Vector2(37, 38), lamp],
			[K.POSTER, Vector2(256, 98), Vector2(50, 62), "gym_poster", Color("b65343")],
			[K.TREADMILL, Vector2(112, 192), Vector2(160, 92), "treadmill"],
			[K.WEIGHT_RACK, Vector2(262, 192), Vector2(96, 70), "weight_rack"],
			[K.PUNCH_BAG, Vector2(352, 168), Vector2(40, 150), "punch_bag"]]
		RoomDiorama.Kind.ART_STUDIO: furniture = [
			[K.WINDOW, Vector2(60, 126), Vector2(54, 70), window],
			[K.LAMP, Vector2(200, 50), Vector2(37, 38), lamp],
			[K.POSTER, Vector2(340, 106), Vector2(62, 62), "painting_a", Color("c97b54")],
			[K.POSTER, Vector2(254, 92), Vector2(46, 46), "painting_b", Color("5f8fa0")],
			[K.EASEL, Vector2(150, 194), Vector2(84, 132), "easel"],
			[K.PAINT_TABLE, Vector2(270, 192), Vector2(112, 64), "paint_table"]]
		RoomDiorama.Kind.ROOF_CONTROL: furniture = [
			[K.LAMP, Vector2(230, 50), Vector2(37, 38), lamp],
			[K.HVAC_UNIT, Vector2(112, 190), Vector2(160, 104), "hvac_unit"],
			[K.ELECTRICAL, Vector2(255, 160), Vector2(56, 74), "roof_panel"],
			[K.VENT_MOTOR, Vector2(345, 188), Vector2(68, 92), "roof_vent"]]
	for item: Array in furniture:
		var prop: BuildingProp = _prop(room, item[0] as BuildingProp.Kind, item[1], item[2], item[3], floor_index)
		if item.size() > 4:
			prop.palette = item[4]
	# A storm-cracked pane remains part of the authored state data.
	if room.room_kind == RoomDiorama.Kind.MASTER_BEDROOM:
		for prop: BuildingProp in props:
			if prop.object_id == StringName("f%d_%s" % [floor_index, window]):
				prop.condition = BuildingProp.Condition.DAMAGED

func _build_pillars() -> void:
	for column: int in range(COLUMN_COUNT + 1):
		var pillar: BuildingProp = _prop(self, BuildingProp.Kind.PILLAR, Vector2(column * room_width, floor_count * floor_height), Vector2(39, floor_count * floor_height), "pillar_%d" % column, 0)
		pillar.z_index = 4
		if column == 0:
			pillar.condition = BuildingProp.Condition.REINFORCED
		elif column == 2:
			pillar.condition = BuildingProp.Condition.DAMAGED

func _build_collisions() -> void:
	for floor_index: int in range(floor_count):
		var body: StaticBody2D = _solid("Floor%d" % floor_index, Vector2(building_width * 0.5, floor_y(floor_index) - global_position.y + 10), Vector2(building_width - 18, 20))
		var shape: CollisionShape2D = body.get_child(0) as CollisionShape2D
		shape.one_way_collision = floor_index > 0
		shape.one_way_collision_margin = 4.0
		floor_bodies.append(body)
	var height: float = floor_count * floor_height
	_solid("LeftBoundary", Vector2(0, height * 0.5), Vector2(20, height + 30))
	_solid("RightBoundary", Vector2(building_width, height * 0.5), Vector2(20, height + 30))

func _solid(node_name: String, point: Vector2, size: Vector2) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = node_name
	body.position = point
	body.collision_layer = 1
	body.collision_mask = 2
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func _draw() -> void:
	if not _cache_source and _static_cache != null: return
	draw_set_transform(sway)
	var height: float = floor_count * floor_height
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(0, -40, building_width, height + 66), false)
		return
	# Clean, serious silhouette: no signage or floor plaques. Roof coping, fascia,
	# a rain-streaked vent, water tank, bent aerial and the base plinth only.
	CelArt.box(self, Rect2(-23, -29, building_width + 46, 28), Color("5d625a"), Vector2(18, -19))
	CelArt.rect(self, Rect2(-23, -16, building_width + 46, 7), Color("7e7d6d"), 0)
	for x: int in range(8, int(building_width), 55):
		CelArt.bolt(self, Vector2(x, -8), Color("7f8a86"))
	CelArt.box(self, Rect2(83, -67, 81, 37), Color("566a64"), Vector2(13, -9))
	for i: int in range(5):
		CelArt.line(self, Vector2(93, -59 + i * 5), Vector2(154, -59 + i * 5), Color("26352f"), 2)
	var tank_x: float = building_width * 0.56
	for x: float in [tank_x + 8.0, tank_x + 62.0]:
		CelArt.line(self, Vector2(x, -29), Vector2(x, -54), CelArt.INK, 6)
	CelArt.box(self, Rect2(tank_x, -98, 70, 46), Color("4f5552"), Vector2(10, -7))
	for y: float in [-86.0, -70.0]:
		CelArt.line(self, Vector2(tank_x + 3, y), Vector2(tank_x + 67, y), Color("30363a"), 2)
	var aerial_x: float = building_width - 135.0
	CelArt.line(self, Vector2(aerial_x, -29), Vector2(aerial_x + 6, -100), CelArt.INK, 4)
	CelArt.line(self, Vector2(aerial_x - 26, -74), Vector2(aerial_x + 30, -82), CelArt.INK, 3)
	CelArt.line(self, Vector2(aerial_x - 14, -94), Vector2(aerial_x + 22, -90), CelArt.INK, 3)
	CelArt.box(self, Rect2(-30, height, building_width + 60, 29), Color("343d39"), Vector2(14, -8))
	# Soot and rain streaks down the outer columns of the facade.
	for x: float in [-6.0, building_width + 6.0]:
		for i: int in range(6):
			var y: float = 20.0 + i * 140.0
			CelArt.line(self, Vector2(x, y), Vector2(x + 2, y + 60 + i % 3 * 20), Color(0.05, 0.06, 0.07, 0.6), 4)
