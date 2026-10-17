class_name RoomLighting
extends Node2D
## Additive light pass over the blacked-out rooms. Each ceiling lamp / chandelier casts a
## warm amber (or emergency red) cone that swings like a pendulum and flickers on tremors.

const AMBER: Color = Color(1.0, 0.66, 0.30)
const EMERGENCY: Color = Color(1.0, 0.16, 0.10)
const RED_ROOMS: Array[int] = [RoomDiorama.Kind.WORKSHOP, RoomDiorama.Kind.LAUNDRY, RoomDiorama.Kind.GYM, RoomDiorama.Kind.ROOF_CONTROL]

var building: ApartmentBuilding
## 0..1 global shake, fed each frame from the camera by MainGame.
var tremor: float = 0.0
var generator_boost: float = 1.0
var lights: Array[Dictionary] = []
var _clock: float = 0.0

func _ready() -> void:
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive

func setup(home: ApartmentBuilding) -> void:
	building = home
	lights.clear()
	for prop: BuildingProp in home.props:
		if prop.kind != BuildingProp.Kind.LAMP and prop.kind != BuildingProp.Kind.CHANDELIER:
			continue
		var room: RoomDiorama = prop.get_parent() as RoomDiorama
		var red: bool = room != null and RED_ROOMS.has(room.room_kind)
		lights.append({"prop": prop, "room": room, "color": EMERGENCY if red else AMBER, "emergency": red,
			"seed": float(lights.size()) * 1.731, "agitation": 0.0, "level": 1.0, "sway": 0.0})

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	_clock += delta
	if building != null and building.collapse_time > 0.0:
		building.collapse_time = maxf(0.0, building.collapse_time - delta)
	for light: Dictionary in lights:
		var prop: BuildingProp = light["prop"]
		var local: float = tremor
		if prop._shake_left > 0.0:
			local = maxf(local, 0.7)
		var agitation: float = maxf(float(light["agitation"]) * exp(-1.4 * delta), local)
		var seed: float = light["seed"]
		var sway: float = sin(_clock * (5.5 + fmod(seed, 1.3)) + seed * 2.0) * 0.30 * agitation
		light["agitation"] = agitation
		light["sway"] = sway
		if prop.kind == BuildingProp.Kind.LAMP:
			prop.sway = sway
		light["level"] = intensity(light)
		light["color_now"] = light_color(light)
	queue_redraw()

## A critical room's lamp switches to emergency red.
func light_color(light: Dictionary) -> Color:
	var room: RoomDiorama = light["room"]
	if room != null and room.state() == RoomDiorama.RoomState.CRITICAL:
		return EMERGENCY
	return light["color"]

## Emergency lamps pulse; tired bulbs stutter now and then; tremors make them strobe.
## Room damage: faulty flicker (damaged), red blinking (critical), dark (collapsed).
func intensity(light: Dictionary) -> float:
	var seed: float = light["seed"]
	var room: RoomDiorama = light["room"]
	if building != null and building.collapsed_building:
		return 0.5 if building.collapse_time > 0.0 and sin(_clock * 37.0 + seed) > 0.3 else 0.0
	var room_state: int = room.state() if room != null else RoomDiorama.RoomState.INTACT
	if room_state == RoomDiorama.RoomState.COLLAPSED:
		return 0.0
	var level: float = 1.0
	if room_state == RoomDiorama.RoomState.DAMAGED and sin(_clock * 23.0 + seed * 4.0) * sin(_clock * 9.3 + seed) > 0.45:
		level *= 0.25
	if room_state == RoomDiorama.RoomState.CRITICAL:
		level *= 1.0 if sin(_clock * 6.5 + seed) > 0.0 else 0.12
	if bool(light["emergency"]):
		level *= 0.7 + 0.3 * sin(_clock * 3.2 + seed)
	if sin(_clock * 11.3 + seed * 3.1) * sin(_clock * 3.7 + seed) > 0.9:
		level *= 0.35
	if float(light["agitation"]) > 0.15 and sin(_clock * 41.0 + seed * 5.0) * sin(_clock * 17.0 + seed) > 0.25:
		level *= 0.2
	return level * generator_boost

func _draw() -> void:
	for light: Dictionary in lights:
		var prop: BuildingProp = light["prop"]
		if not prop.is_visible_in_tree():
			continue
		var sway: float = light["sway"]
		var level: float = light["level"]
		if level <= 0.001:
			continue
		var color: Color = light.get("color_now", light["color"])
		var chandelier: bool = prop.kind == BuildingProp.Kind.CHANDELIER
		var mount: Vector2 = to_local(prop.to_global(Vector2(0, -prop.prop_size.y if chandelier else -59.0)))
		var drop: float = prop.prop_size.y * 0.78 if chandelier else 57.0
		var direction: Vector2 = Vector2.DOWN.rotated(sway)
		var bulb: Vector2 = mount + direction * drop
		var floor_line: float = to_local(Vector2(0, building.floor_y(prop.floor_index))).y
		var room: RoomDiorama = light["room"]
		var left: float = to_local(room.to_global(Vector2(22, 0))).x if room != null else -INF
		var right: float = to_local(room.to_global(Vector2(room.room_size.x - 22, 0))).x if room != null else INF
		var length: float = (floor_line - bulb.y) / maxf(0.5, cos(sway)) + 4.0
		var across: Vector2 = Vector2(direction.y, -direction.x)
		var top_half: float = 40.0 if chandelier else 12.0
		var bottom_half: float = 150.0 if chandelier else 95.0
		var hit: Vector2 = bulb + direction * length
		var cone: PackedVector2Array = PackedVector2Array([bulb - across * top_half, bulb + across * top_half, hit + across * bottom_half, hit - across * bottom_half])
		for i: int in range(cone.size()):
			cone[i].x = clampf(cone[i].x, left, right)
			cone[i].y = minf(cone[i].y, floor_line)
		draw_polygon(cone, PackedColorArray([Color(color, 0.30 * level), Color(color, 0.30 * level), Color(color, 0.08 * level), Color(color, 0.08 * level)]))
		var inner: PackedVector2Array = PackedVector2Array([bulb - across * top_half * 0.5, bulb + across * top_half * 0.5, hit + across * bottom_half * 0.45, hit - across * bottom_half * 0.45])
		for i: int in range(inner.size()):
			inner[i].x = clampf(inner[i].x, left, right)
			inner[i].y = minf(inner[i].y, floor_line)
		draw_polygon(inner, PackedColorArray([Color(color, 0.18 * level), Color(color, 0.18 * level), Color(color, 0.0), Color(color, 0.0)]))
		# Pool of light on the floorboards and a hot halo around the bulb.
		var pool: Vector2 = Vector2(clampf(hit.x, left, right), floor_line - 8.0)
		for i: int in range(3):
			draw_colored_polygon(_ellipse(pool, Vector2(bottom_half * (1.0 - i * 0.25), 12.0 - i * 3.0)), Color(color, 0.07 * level))
		draw_circle(bulb, 30.0, Color(color, 0.12 * level))
		draw_circle(bulb, 14.0, Color(color, 0.35 * level))
		draw_circle(bulb, 6.0, Color(1.0, 0.95, 0.85, 0.6 * level))

static func _ellipse(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(18):
		var a: float = TAU * float(i) / 18.0
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	return points
