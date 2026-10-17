class_name BuildingProp
extends Node2D
## Each visible object has independent, serializable preparation/damage data.

enum Kind { PILLAR, WINDOW, SOFA, BOOKCASE, TABLE, GAS_VALVE, ELECTRICAL, LAMP, PLANT, KITCHEN,
	WORKBENCH, TOOL_CABINET, TOOLBOX, FRIDGE, STOVE, HOOD, SHELF, TV, COFFEE_TABLE,
	COMPUTER, SWIVEL_CHAIR, CORKBOARD, BED, NIGHTSTAND, WARDROBE, CURTAINS,
	BUNK_BED, TOY_SHELF, AIRCON, POSTER, SKYLIGHT, FIRE_CABINET, VENT_MOTOR, CHANDELIER,
	BOILER, MAILBOXES, ENTRY_DOOR, WASHER, VITRINE, DINING_TABLE, DINING_CHAIR, PIANO,
	TURNTABLE, SPEAKER, BATHTUB, SINK_MIRROR, SUITCASE, PLANTER_RACK, TREADMILL,
	WEIGHT_RACK, PUNCH_BAG, EASEL, PAINT_TABLE, HVAC_UNIT }
enum Condition { UNSECURED, REINFORCED, DAMAGED }

@export var custom_sprite: Texture2D:
	set(value):
		custom_sprite = value
		queue_redraw()
@export var kind: Kind = Kind.TABLE
@export var condition: Condition = Condition.UNSECURED:
	set(value):
		condition = value
		if is_inside_tree() and value != Condition.UNSECURED:
			stop_shaking()
		queue_redraw()
@export var prop_size: Vector2 = Vector2(90, 70)
@export var palette: Color = Color("ad7655")
@export var floor_index: int = 0
@export var object_id: StringName = &"prop"
## Pendulum angle of hanging lamps (radians around the ceiling mount); set by RoomLighting.
var sway: float = 0.0:
	set(value):
		if absf(value - sway) > 0.002 or (value == 0.0 and sway != 0.0):
			sway = value
			queue_redraw()
## Resting lean (radians around the foot point) of loose furniture in a damaged room.
var tilt: float = 0.0:
	set(value):
		tilt = value
		if _shake_left <= 0.0:
			rotation = value
## Condition authored by the level data; restored when the building is reset.
var authored_condition: Condition = Condition.UNSECURED
var _rest_position: Vector2 = Vector2.ZERO
var _shake_left: float = 0.0
var _shake_clock: float = 0.0

func _ready() -> void:
	_rest_position = position

func shake_unsecured(duration: float) -> void:
	if condition == Condition.UNSECURED:
		_shake_left = maxf(_shake_left, duration)

func stop_shaking() -> void:
	_shake_left = 0.0
	rotation = tilt
	position = _rest_position

func _process(delta: float) -> void:
	if _shake_left <= 0:
		return
	_shake_left = maxf(0.0, _shake_left - delta)
	_shake_clock += delta
	rotation = tilt + sin(_shake_clock * 43) * 0.025
	position = _rest_position + Vector2(sin(_shake_clock * 61) * 2.5, 0)
	if _shake_left <= 0:
		stop_shaking()

func state_record() -> Dictionary:
	return {"id": String(object_id), "kind": kind, "condition": condition, "floor": floor_index}

func _draw() -> void:
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(Vector2(-prop_size.x * 0.5, -prop_size.y), prop_size), false)
		return
	match kind:
		Kind.PILLAR: _pillar()
		Kind.WINDOW: _window()
		Kind.SOFA: _sofa()
		Kind.BOOKCASE: _bookcase()
		Kind.TABLE: _table()
		Kind.GAS_VALVE: _gas_valve()
		Kind.ELECTRICAL: _electrical()
		Kind.LAMP: _lamp()
		Kind.PLANT: _plant()
		Kind.KITCHEN: _kitchen()
		_: FurnitureArt.draw_furniture(self, kind, prop_size, palette)
	draw_set_transform(Vector2.ZERO)
	if condition == Condition.REINFORCED and kind == Kind.WINDOW:
		_window_shutter()
	elif condition == Condition.REINFORCED and kind != Kind.PILLAR:
		_l_brackets()
	if condition == Condition.DAMAGED and kind != Kind.WINDOW:
		draw_polyline(PackedVector2Array([Vector2(-8, -prop_size.y + 7), Vector2(3, -prop_size.y * 0.6), Vector2(-5, -prop_size.y * 0.4), Vector2(9, -10)]), CelArt.INK, 2.5, true)

## Fortified furniture: steel L-brackets bolting both feet (and the top) to the wall.
func _l_brackets() -> void:
	var w: float = prop_size.x * 0.5
	var steel: Color = Color("8fa3ad")
	for side: float in [-1.0, 1.0]:
		var foot: Vector2 = Vector2(side * (w - 4.0), -2.0)
		var bracket: PackedVector2Array = PackedVector2Array([foot + Vector2(0, -16), foot, foot + Vector2(-side * 14, 0)])
		draw_polyline(bracket, CelArt.INK, 7.0, true)
		draw_polyline(bracket, steel, 3.5, true)
		CelArt.bolt(self, foot + Vector2(-side * 6, -6), Color("cfe7f2"))
	var top: Vector2 = Vector2(w * 0.4, -prop_size.y + 6.0)
	draw_polyline(PackedVector2Array([top + Vector2(-10, 0), top, top + Vector2(0, -10)]), CelArt.INK, 6.0, true)
	draw_polyline(PackedVector2Array([top + Vector2(-10, 0), top, top + Vector2(0, -10)]), Color(Color("4fc3ff"), 0.9), 2.6, true)

## Fortified window: corrugated steel shutter half-drawn and a sandbag sill.
func _window_shutter() -> void:
	var w: float = prop_size.x
	var h: float = prop_size.y
	CelArt.rect(self, Rect2(-w * 0.5 - 2, -h - 2, w + 4, h * 0.62), Color("5c6870"), 2.5)
	for i: int in range(6):
		var y: float = -h + 4.0 + i * h * 0.1
		draw_line(Vector2(-w * 0.5, y), Vector2(w * 0.5, y), Color("3b454b"), 2.0)
	draw_line(Vector2(-w * 0.5 - 2, -h * 0.4), Vector2(w * 0.5 + 2, -h * 0.4), Color(Color("4fc3ff"), 0.8), 2.0)
	for i: int in range(3):
		var x: float = -w * 0.5 + 6.0 + i * (w - 12.0) / 2.0
		CelArt.poly(self, PackedVector2Array([Vector2(x - 12, 2), Vector2(x - 13, -6), Vector2(x - 6, -12), Vector2(x + 9, -12), Vector2(x + 13, -5), Vector2(x + 11, 2)]), Color("8a7d5c"))

func _pillar() -> void:
	var h: float = prop_size.y
	CelArt.box(self, Rect2(-13, -h, 26, h), Color("777e73"), Vector2(9, -5))
	CelArt.rect(self, Rect2(-19, -h, 39, 15), Color("b0b39b"))
	CelArt.rect(self, Rect2(-19, -15, 39, 15), Color("a7a58f"))
	CelArt.rect(self, Rect2(-8, -h + 20, 7, h - 42), Color("a2a895"), 0)
	for y: int in range(30, int(h) - 15, 38):
		CelArt.line(self, Vector2(-10, -y), Vector2(12, -y - 4), Color("5e665e"), 2)
	if condition == Condition.REINFORCED:
		for y: float in [-h + 26, -48.0]:
			CelArt.box(self, Rect2(-18, y, 37, 22), Color("628d89"), Vector2(5, -4))
			CelArt.bolt(self, Vector2(-11, y + 10))
			CelArt.bolt(self, Vector2(11, y + 10))
		CelArt.line(self, Vector2(-12, -h + 50), Vector2(13, -49), CelArt.INK, 7)
		CelArt.line(self, Vector2(-12, -h + 50), Vector2(13, -49), Color("94c8ae"), 3)

func _window() -> void:
	var w: float = prop_size.x
	var h: float = prop_size.y
	CelArt.box(self, Rect2(-w * 0.5 - 5, -h - 5, w + 10, h + 10), Color("9c917c"), Vector2(5, -5))
	CelArt.rect(self, Rect2(-w * 0.5, -h, w, h), Color("4f7884"))
	CelArt.poly(self, PackedVector2Array([Vector2(-w * 0.5 + 3, -h + 4), Vector2(-3, -h + 4), Vector2(-w * 0.5 + 3, -12)]), Color("79a6a3"), 0)
	for i: int in range(4):
		var x: float = -w * 0.5 + 9.0 + i * w * 0.23
		CelArt.rect(self, Rect2(x, -27 - i % 2 * 10, 11, 26 + i % 2 * 10), Color("304954"), 0)
	CelArt.line(self, Vector2(0, -h), Vector2(0, 0), CelArt.INK, 5)
	CelArt.line(self, Vector2(-w * 0.5, -h * 0.52), Vector2(w * 0.5, -h * 0.52), CelArt.INK, 5)
	CelArt.box(self, Rect2(-w * 0.5 - 9, -1, w + 18, 9), Color("c4b69a"), Vector2(4, -4))
	if condition == Condition.DAMAGED:
		draw_polyline(PackedVector2Array([Vector2(0, -h * 0.52), Vector2(13, -h * 0.7), Vector2(8, -h), Vector2(23, -h * 0.85)]), CelArt.INK, 2.5, true)
		CelArt.poly(self, PackedVector2Array([Vector2(2, -h * 0.5), Vector2(28, -h * 0.27), Vector2(5, -h * 0.16)]), Color("263d48"))

func _sofa() -> void:
	CelArt.ellipse(self, Vector2(4, -1), Vector2(78, 11), Color(0.05, 0.07, 0.06, 0.28), 0)
	CelArt.box(self, Rect2(-65, -58, 129, 36), palette.darkened(0.12))
	CelArt.box(self, Rect2(-60, -34, 121, 24), palette.lightened(0.1))
	for x: float in [-64.0, 52.0]:
		CelArt.box(self, Rect2(x, -46, 16, 39), palette)
	for x: float in [-42.0, -3.0, 34.0]:
		CelArt.line(self, Vector2(x, -53), Vector2(x, -30), palette.darkened(0.4), 2)
	for x: float in [-49.0, 44.0]:
		CelArt.rect(self, Rect2(x, -8, 9, 8), Color("403d35"))
	CelArt.box(self, Rect2(-35, -55, 28, 27), Color("d7aa6b"), Vector2(3, -3))

func _bookcase() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, prop_size.y / 119.0))
	CelArt.box(self, Rect2(-39, -119, 78, 117), Color("906146"))
	CelArt.rect(self, Rect2(-31, -110, 61, 103), Color("4f4136"), 0)
	var colors: Array[Color] = [Color("8ab3a0"), Color("cd795c"), Color("c9b580"), Color("6a8b9c"), Color("b6aa8c")]
	for row: int in range(3):
		for book: int in range(7):
			var h: float = 20.0 + float((book * 13 + row * 7) % 12)
			var x: float = -27.0 + book * 8.0
			var y: float = -77.0 + row * 33.0
			CelArt.rect(self, Rect2(x, y - h, 7, h), colors[(book + row) % colors.size()], 1.3)
			CelArt.line(self, Vector2(x + 2, y - h + 5), Vector2(x + 5, y - h + 5), CelArt.PAPER, 1)
		CelArt.rect(self, Rect2(-33, -77 + row * 33, 66, 5), Color("bd8b5b"))
	for x: float in [-31.0, 27.0]:
		CelArt.bolt(self, Vector2(x, -112))

func _table() -> void:
	for x: float in [-47.0, 38.0]:
		CelArt.box(self, Rect2(x, -48, 10, 47), Color("80604b"), Vector2(5, -4))
	CelArt.box(self, Rect2(-56, -58, 112, 12), Color("bc966b"), Vector2(12, -10))
	CelArt.line(self, Vector2(-47, -55), Vector2(47, -55), Color("e0b984"), 2)
	CelArt.box(self, Rect2(7, -71, 25, 12), Color("d6d1b0"), Vector2(4, -3))
	CelArt.ellipse(self, Vector2(-18, -63), Vector2(7, 4), Color("b9cec2"))
	CelArt.rect(self, Rect2(-24, -76, 12, 12), Color("a9c1b5"))

func _gas_valve() -> void:
	CelArt.line(self, Vector2(0, -115), Vector2(0, 0), CelArt.INK, 12)
	CelArt.line(self, Vector2(0, -115), Vector2(0, 0), Color("7daeba") if String(object_id).contains("water") else Color("c7a95f"), 7)
	for y: float in [-96.0, -31.0]:
		CelArt.rect(self, Rect2(-8, y, 16, 8), Color("8c8d76"))
		CelArt.bolt(self, Vector2(0, y + 4))
	draw_circle(Vector2(0, -61), 16, CelArt.INK)
	draw_circle(Vector2(0, -61), 12, Color("bd6c4b"))
	draw_circle(Vector2(0, -61), 7, Color("3c4943"))
	for i: int in range(4):
		var direction: Vector2 = Vector2.from_angle(PI * 0.5 * i)
		CelArt.line(self, Vector2(0, -61) + direction * 3, Vector2(0, -61) + direction * 13, Color("df9d62"), 3)
	CelArt.bolt(self, Vector2(0, -61))

func _electrical() -> void:
	CelArt.box(self, Rect2(-28, -71, 56, 70), Color("8b9990"), Vector2(7, -5))
	CelArt.rect(self, Rect2(-20, -61, 39, 47), Color("485a55"))
	for i: int in range(3):
		CelArt.rect(self, Rect2(-13 + i * 10, -53, 6, 17), Color("c8c7a4"), 1.5)
	CelArt.poly(self, PackedVector2Array([Vector2(0, -33), Vector2(-11, -16), Vector2(11, -16)]), CelArt.GOLD, 1.5)
	CelArt.line(self, Vector2(0, -28), Vector2(-2, -21), CelArt.INK, 2)
	CelArt.bolt(self, Vector2(21, -38))

func _lamp() -> void:
	# Ceiling rose stays put; cord, shade and bulb swing around it (RoomLighting casts the cone).
	CelArt.rect(self, Rect2(-8, -61, 16, 6), Color("4c5550"))
	draw_set_transform(Vector2(0, -59), sway)
	CelArt.line(self, Vector2(0, 0), Vector2(0, 50), CelArt.INK, 4)
	CelArt.poly(self, PackedVector2Array([Vector2(-9, 39), Vector2(10, 39), Vector2(23, 56), Vector2(-23, 56)]), Color("35564f"))
	CelArt.ellipse(self, Vector2(0, 57), Vector2(20, 4), Color("f4ce7f"), 2)
	draw_set_transform(Vector2.ZERO)

func _plant() -> void:
	# Authored at 34 x 61; fern, palm and herb pots reuse it at their own scale.
	draw_set_transform(Vector2.ZERO, 0.0, prop_size / Vector2(34, 61))
	CelArt.poly(self, PackedVector2Array([Vector2(-18, -27), Vector2(18, -27), Vector2(12, 0), Vector2(-12, 0)]), Color("b87858"))
	CelArt.rect(self, Rect2(-21, -31, 42, 8), Color("ce9168"))
	for i: int in range(5):
		var end: Vector2 = Vector2(-25 + i * 12, -52 - (i % 2) * 13)
		CelArt.line(self, Vector2(0, -30), end, CelArt.INK, 4)
		CelArt.ellipse(self, end, Vector2(10, 17), Color("688c64"))

func _kitchen() -> void:
	CelArt.box(self, Rect2(-87, -58, 175, 56), Color("a6afa0"), Vector2(10, -7))
	for x: float in [-81.0, -26.0, 30.0]:
		CelArt.rect(self, Rect2(x, -49, 47, 43), Color("7f9387"))
		CelArt.line(self, Vector2(x + 30, -41), Vector2(x + 39, -41), CelArt.INK, 3)
	CelArt.box(self, Rect2(-92, -65, 185, 8), Color("d6cdb4"), Vector2(12, -8))
	CelArt.ellipse(self, Vector2(22, -69), Vector2(20, 6), Color("687b7b"))
	CelArt.line(self, Vector2(35, -72), Vector2(35, -91), CelArt.INK, 5)
	CelArt.line(self, Vector2(35, -91), Vector2(24, -91), CelArt.INK, 5)
