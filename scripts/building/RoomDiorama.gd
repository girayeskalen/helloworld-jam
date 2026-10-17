class_name RoomDiorama
extends Node2D

## Index = floor * 4 + column. Every one of the 16 rooms is a real, unique space.
enum Kind { WORKSHOP, LOBBY, KITCHEN, LAUNDRY, LIVING, DINING, STUDY, MUSIC,
	MASTER_BEDROOM, BATHROOM, KIDS, GUEST, GREENHOUSE, GYM, ART_STUDIO, ROOF_CONTROL }
const NAMES: Array[String] = ["TEKNİK ATÖLYE / KAZAN DAİRESİ", "GİRİŞ LOBİSİ / POSTA", "MUTFAK / KİLER",
	"ÇAMAŞIRHANE / VANA ODASI", "SALON", "YEMEK ODASI", "ÇALIŞMA ODASI / KÜTÜPHANE", "MÜZİK / PLAK ODASI",
	"EBEVEYN YATAK ODASI", "BANYO", "ÇOCUK / GENÇ ODASI", "MİSAFİR ODASI",
	"KIŞ BAHÇESİ / SERA", "SPOR ODASI", "RESİM ATÖLYESİ", "ÇATI ELEKTRİK / KLİMA"]

@export var custom_sprite: Texture2D:
	set(value):
		custom_sprite = value
		invalidate_static()
		queue_redraw()
@export var room_size: Vector2 = Vector2(400, 220)
@export var wall_color: Color = Color("a49c7d")
@export var floor_index: int = 0
@export var room_kind: Kind = Kind.LIVING
## Optional tiled back-wall texture (AssetRegistry `tileset.png`), tinted by wall_color.
@export var wall_texture: Texture2D:
	set(value):
		wall_texture = value
		invalidate_static()
		queue_redraw()

const DITHER: float = 5.128
const BAYER: Array[int] = [0, 2, 3, 1]

## Room health and its five visual states (user numbering 0..4).
enum RoomState { FORTIFIED, INTACT, DAMAGED, CRITICAL, COLLAPSED }
const MAX_HP: float = 100.0
const DAMAGED_BELOW: float = 70.0
const CRITICAL_BELOW: float = 35.0
## Furniture lean per state (radians); bolted (fortified) furniture stays upright.
const STATE_TILT: Array[float] = [0.0, 0.0, 0.06, 0.13, 0.32]
signal state_changed(room: RoomDiorama, state: int)

var damage_limiter: Callable
## Chain support is half of a full retrofit (27.5% mitigation), never a free anchor kit.
var chain_support: bool = false
var heat: float = 0.0
var hp: float = MAX_HP
var max_hp: float = MAX_HP
enum Reinforcement { STEEL, SHUTTER, ANCHOR }
var reinforcements: Array[int] = []
var reinforcement_level: int:
	get: return reinforcements.size()
var utilities_isolated: bool = false
var auto_protection: bool = false
var shutter_block: float = .5
var flood_barrier_bonus: float = 0.0
## Support is typed: steel/FRP halves structural hits; shutters halve facade shots.
var fortified: bool = false
var _state: int = RoomState.INTACT
## Whole-building collapse: heavy dust curtains in every room.
var shaking: bool = false:
	set(value):
		shaking = value
		if _fx != null:
			_fx.queue_redraw()
var _shade: Node2D
## Animated damage layer (dust, sparks, smoke, rubble, braces) drawn above the pillars.
var _fx: Node2D
var _supports: Node2D
var _support_cache: SubViewport
var _support_painter: Node2D
var _fx_clock: float = 0.0
var _fx_redraw_clock: float = 0.0
var _cache_source: bool = false
var _static_cache: SubViewport
var _shade_cache: SubViewport
var _visual_dirty: bool = false
var static_revision: int = 0
const CACHE_BOUNDS: Rect2 = Rect2(-8,-8,416,236)
const CACHE_FIELDS: Array[String] = ["custom_sprite","wall_texture","wall_color","room_size","floor_index","room_kind","_state"]

func _ready() -> void:
	if _cache_source: return
	_static_cache = StaticCanvasCache.create(self,CACHE_BOUNDS)
	StaticCanvasCache.painter(_static_cache,self,CACHE_FIELDS)
	static_revision += 1
	# Corner occlusion, vignette and dithered shadow sit above the furniture.
	_shade = Node2D.new()
	_shade.name = "Shade"
	_shade.z_index = 1
	_shade_cache = StaticCanvasCache.create(self,Rect2(Vector2.ZERO,room_size))
	var shade_painter: Node2D = Node2D.new()
	_shade_cache.add_child(shade_painter)
	shade_painter.draw.connect(_paint_shade.bind(shade_painter))
	_shade.draw.connect(func() -> void: _shade.draw_texture_rect(_shade_cache.get_texture(),Rect2(Vector2.ZERO,room_size),false))
	add_child(_shade)
	_fx = Node2D.new()
	_fx.name = "DamageFX"
	_fx.z_index = 5
	_fx.draw.connect(_draw_fx)
	add_child(_fx)
	_supports = Node2D.new()
	_supports.name = "StaticReinforcements"
	_supports.z_index = 5
	_support_cache = StaticCanvasCache.create(self,CACHE_BOUNDS)
	_support_painter = Node2D.new()
	_support_cache.add_child(_support_painter)
	_support_painter.draw.connect(_paint_supports.bind(_support_painter))
	_supports.draw.connect(func() -> void: _supports.draw_texture_rect(_support_cache.get_texture(),CACHE_BOUNDS,false))
	add_child(_supports)

func invalidate_static() -> void:
	if _cache_source or _static_cache == null or _visual_dirty: return
	_visual_dirty = true
	call_deferred("_refresh_static")

func _refresh_static() -> void:
	_visual_dirty = false
	StaticCanvasCache.refresh(_static_cache,self,CACHE_FIELDS)
	static_revision += 1
	_refresh_supports()
	queue_redraw()

func _refresh_supports() -> void:
	if _support_painter == null: return
	_support_painter.queue_redraw()
	_support_cache.render_target_update_mode = SubViewport.UPDATE_ONCE

func state() -> int:
	if hp <= 0.0:
		return RoomState.COLLAPSED
	if hp / max_hp < CRITICAL_BELOW / MAX_HP:
		return RoomState.CRITICAL
	if hp / max_hp < DAMAGED_BELOW / MAX_HP:
		return RoomState.DAMAGED
	return RoomState.FORTIFIED if fortified else RoomState.INTACT

func is_collapsed() -> bool:
	return hp <= 0.0

func damage_factor(source: int) -> float:
	if source == 1 and has_reinforcement(Reinforcement.STEEL): return .5
	if source in [0,2,3] and has_reinforcement(Reinforcement.SHUTTER): return 1.0-shutter_block-(flood_barrier_bonus if source in [0,2] else 0.0)
	return .725 if chain_support else 1.0

## Mitigation precedes the existing shared pacing gate; collapsed rooms stay lost.
func apply_damage(amount: float, source: int = 1) -> float:
	if amount <= 0.0 or hp <= 0.0:
		return 0.0
	var taken: float = minf(amount * damage_factor(source), hp)
	if damage_limiter.is_valid(): taken = float(damage_limiter.call(taken))
	hp -= taken
	if hp < 0.0001:
		hp = 0.0
	_refresh_state()
	return taken

## Patch + reinforce. Collapsed rooms cannot be rebuilt mid-siege.
func repair(amount: float, fortify: bool = false) -> bool:
	if hp <= 0.0:
		return false
	hp = minf(max_hp, hp + amount)
	if fortify:
		reinforcements.assign([Reinforcement.STEEL, Reinforcement.SHUTTER, Reinforcement.ANCHOR])
		fortified = true
	_refresh_state(true)
	return true

func needs_repair() -> bool:
	return state() in [RoomState.DAMAGED, RoomState.CRITICAL]

func reinforce(component: int) -> bool:
	if is_collapsed() or reinforcements.has(component) or component < 0 or component > Reinforcement.ANCHOR:
		return false
	reinforcements.append(component)
	fortified = true
	_refresh_state(true)
	return true

func has_reinforcement(component: int) -> bool:
	return reinforcements.has(component)

func restore() -> void:
	auto_protection = false
	utilities_isolated = false
	shutter_block = .5
	flood_barrier_bonus = 0.0
	heat = 0.0
	chain_support = false
	hp = max_hp
	fortified = false
	reinforcements.clear()
	_refresh_state(true)

func props() -> Array[BuildingProp]:
	var list: Array[BuildingProp] = []
	for child: Node in get_children():
		if child is BuildingProp:
			list.append(child as BuildingProp)
	return list

func _refresh_state(force: bool = false) -> void:
	var current: int = state()
	if current == _state and not force:
		return
	_state = current
	_apply_state_to_props()
	invalidate_static()
	queue_redraw()
	if _fx != null:
		_fx.queue_redraw()
	_refresh_supports()
	state_changed.emit(self, current)

## Windows crack or get shutters; loose furniture leans with damage or gets bolted down.
func _apply_state_to_props() -> void:
	var index: int = 0
	for prop: BuildingProp in props():
		index += 1
		if prop.kind == BuildingProp.Kind.WINDOW:
			if has_reinforcement(Reinforcement.SHUTTER):
				prop.condition = BuildingProp.Condition.REINFORCED
			elif _state >= RoomState.DAMAGED:
				prop.condition = BuildingProp.Condition.DAMAGED
			else:
				prop.condition = prop.authored_condition
			continue
		if prop.kind in [BuildingProp.Kind.LAMP, BuildingProp.Kind.SKYLIGHT]:
			continue
		if has_reinforcement(Reinforcement.ANCHOR):
			prop.stop_shaking()
			prop.tilt = 0.0
			prop.condition = BuildingProp.Condition.REINFORCED
		else:
			prop.tilt = STATE_TILT[_state] * (1.0 if index % 2 == 0 else -1.0) * (0.7 + 0.15 * float(index % 3))
			prop.condition = prop.authored_condition

func _process(delta: float) -> void:
	_fx_redraw_clock += delta
	if heat > 0.0:
		heat = maxf(0.0, heat - delta * 4.0)
	if heat > 0.0 or _state >= RoomState.DAMAGED or shaking:
		_fx_clock += delta
		if _fx_redraw_clock >= .05:
			_fx_redraw_clock = fmod(_fx_redraw_clock,.05)
			_fx.queue_redraw()

## Identity data only; rooms no longer print their names (the furniture tells the story).
func room_name() -> String:
	return NAMES[room_kind]

func _draw() -> void:
	if not _cache_source and _static_cache != null:
		draw_texture_rect(_static_cache.get_texture(),CACHE_BOUNDS,false)
		return
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(Vector2.ZERO, room_size), false)
		return
	var w: float = room_size.x
	var h: float = room_size.y
	# Back wall + four perspective planes; the front remains cut away.
	CelArt.rect(self, Rect2(0, 0, w, h), Color("2f2c27"))
	CelArt.rect(self, Rect2(22, 18, w - 44, h - 62), wall_color)
	if wall_texture != null:
		draw_texture_rect(wall_texture, Rect2(22, 18, w - 44, h - 62), true, wall_color.lightened(0.3))
	CelArt.poly(self, PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w - 22, 18), Vector2(22, 18)]), wall_color.darkened(0.27))
	CelArt.poly(self, PackedVector2Array([Vector2(0, 0), Vector2(22, 18), Vector2(22, h - 44), Vector2(0, h - 20)]), wall_color.darkened(0.37))
	CelArt.poly(self, PackedVector2Array([Vector2(w, 0), Vector2(w - 22, 18), Vector2(w - 22, h - 44), Vector2(w, h - 20)]), wall_color.darkened(0.20))
	CelArt.poly(self, PackedVector2Array([Vector2(22, h - 44), Vector2(w - 22, h - 44), Vector2(w, h - 20), Vector2(0, h - 20)]), _floor_color())
	# Floorboards follow the room's vanishing direction instead of a screen grid.
	for plank: int in range(12):
		var x: float = 22.0 + plank * (w - 44.0) / 12.0
		var bottom_x: float = (x - w * 0.5) * 1.125 + w * 0.5
		CelArt.line(self, Vector2(x, h - 44), Vector2(bottom_x, h - 20), _floor_color().darkened(0.32), 1.5)
	CelArt.line(self, Vector2(11, h - 33), Vector2(w - 11, h - 33), _floor_color().lightened(0.22), 2)
	# Corner occlusion and picture rail.
	CelArt.rect(self, Rect2(22, 18, w - 44, 9), Color(0.07, 0.09, 0.08, 0.20), 0)
	CelArt.rect(self, Rect2(22, 18, 9, h - 62), Color(0.07, 0.09, 0.08, 0.18), 0)
	CelArt.rect(self, Rect2(w - 32, 18, 10, h - 62), Color(0.07, 0.09, 0.08, 0.13), 0)
	CelArt.rect(self, Rect2(22, h - 53, w - 44, 9), wall_color.darkened(0.42), 0)
	CelArt.line(self, Vector2(23, 56), Vector2(w - 23, 56), wall_color.lightened(0.17), 3)
	if wall_texture == null:
		for x: int in range(43, int(w) - 30, 24):
			for y: int in range(70, 152, 26):
				draw_circle(Vector2(x, y), 1.6, wall_color.darkened(0.12))
	_draw_identity()
	_draw_grime()
	_draw_damage()
	# Exposed I-beam, rivets and a narrow highlight on each floor edge.
	CelArt.rect(self, Rect2(0, h - 20, w, 20), Color("424f4f"))
	CelArt.rect(self, Rect2(0, h - 20, w, 5), Color("8b9d91"))
	CelArt.rect(self, Rect2(0, h - 5, w, 5), Color("202c2c"))
	for x: int in range(17, int(w), 37):
		CelArt.bolt(self, Vector2(x, h - 11), Color("98a395"))
	# Uneven plaster damage is part of the illustrative environment.
	draw_polyline(PackedVector2Array([Vector2(w - 63, 19), Vector2(w - 71, 31), Vector2(w - 67, 40), Vector2(w - 79, 50)]), wall_color.darkened(0.48), 2, true)

func _floor_color() -> Color:
	match room_kind:
		Kind.WORKSHOP, Kind.ROOF_CONTROL: return Color("6f716a")
		Kind.LOBBY: return Color("b2a38a")
		Kind.LAUNDRY, Kind.BATHROOM: return Color("9fb3ad")
		Kind.GREENHOUSE: return Color("a7694f")
		Kind.GYM: return Color("3f4b4d")
		Kind.ART_STUDIO: return Color("a8946f")
		Kind.MUSIC: return Color("6e4a3c")
	return Color("98734f")

func _draw_identity() -> void:
	# Each wall and floor has its own material; furniture is stateful child art.
	match room_kind:
		Kind.KITCHEN:
			for x: int in range(25, 375, 22):
				for y: int in range(62, 173, 22):
					CelArt.rect(self, Rect2(x, y, 20, 20), Color("c7d3bd") if (x / 22 + y / 22) % 2 == 0 else Color("9fb6a6"), 0.7)
			for i: int in range(12):
				CelArt.poly(self, PackedVector2Array([Vector2(22 + i * 29, 177), Vector2(50 + i * 29, 177), Vector2(38 + i * 32, 198), Vector2(7 + i * 32, 198)]), Color("cbd1b4") if i % 2 == 0 else Color("658f89"), 1)
		Kind.WORKSHOP:
			CelArt.rect(self, Rect2(24, 140, 351, 28), Color("6d7973"), 0)
			for i: int in range(18):
				var x: float = 28 + i * 19
				CelArt.poly(self, PackedVector2Array([Vector2(x, 140), Vector2(x + 9, 140), Vector2(x + 21, 168), Vector2(x + 12, 168)]), Color("d6b65a"), 0)
			CelArt.line(self, Vector2(32, 42), Vector2(365, 42), CelArt.INK, 6)
			CelArt.line(self, Vector2(32, 42), Vector2(365, 42), Color("c5ad66"), 3)
		Kind.LOBBY:
			CelArt.rect(self, Rect2(24, 116, 352, 52), Color("8f7556"), 0)
			for x: int in range(30, 372, 44):
				CelArt.rect(self, Rect2(x, 122, 36, 40), Color("a08563"), 1.2)
			CelArt.poly(self, PackedVector2Array([Vector2(120, 177), Vector2(290, 177), Vector2(310, 198), Vector2(100, 198)]), Color("a64f3e"), 1.5)
			CelArt.line(self, Vector2(112, 190), Vector2(300, 190), CelArt.GOLD, 2)
		Kind.LAUNDRY:
			for x: int in range(24, 376, 16):
				for y: int in range(112, 168, 16):
					CelArt.rect(self, Rect2(x, y, 15, 15), Color("cfe0dc") if (x + y) % 32 == 0 else Color("b3cdd0"), 0.6)
			CelArt.line(self, Vector2(36, 66), Vector2(214, 60), Color("e2d8b4"), 2)
			for i: int in range(5):
				var x: float = 52 + i * 34
				CelArt.poly(self, PackedVector2Array([Vector2(x, 64 - i * 1.1), Vector2(x + 22, 64 - i * 1.1), Vector2(x + 19, 88), Vector2(x + 3, 88)]), Color.from_hsv(fmod(i * .23 + .5, 1), .35, .85), 1.5)
		Kind.LIVING:
			for x: int in range(32, 377, 16):
				CelArt.line(self, Vector2(x, 59), Vector2(x, 168), Color(wall_color.darkened(.12), .55), 2)
			CelArt.poly(self, PackedVector2Array([Vector2(101, 175), Vector2(278, 175), Vector2(295, 197), Vector2(85, 197)]), Color("a96f58"))
			CelArt.line(self, Vector2(110, 183), Vector2(274, 183), CelArt.GOLD, 2)
		Kind.DINING:
			for x: int in range(24, 380, 30):
				CelArt.line(self, Vector2(x, 60), Vector2(x + 30, 114), wall_color.darkened(0.15), 1.5)
				CelArt.line(self, Vector2(x + 30, 60), Vector2(x, 114), wall_color.darkened(0.15), 1.5)
			CelArt.rect(self, Rect2(24, 116, 352, 52), Color("8a5a46"), 0)
			CelArt.line(self, Vector2(24, 116), Vector2(376, 116), Color("d4a46f"), 3)
			CelArt.poly(self, PackedVector2Array([Vector2(96, 177), Vector2(304, 177), Vector2(322, 198), Vector2(78, 198)]), Color("6f8f7c"), 1.5)
		Kind.STUDY:
			CelArt.rect(self, Rect2(25, 144, 350, 25), Color("526d6c"), 0)
			for x: int in range(34, 375, 23):
				CelArt.line(self, Vector2(x, 146), Vector2(x, 168), Color("9fae96"), 1.5)
		Kind.MUSIC:
			for x: int in range(30, 372, 26):
				for y: int in range(62, 118, 26):
					CelArt.rect(self, Rect2(x, y, 22, 22), Color("4e4a6b"), 1)
					CelArt.poly(self, PackedVector2Array([Vector2(x + 3, y + 3), Vector2(x + 19, y + 3), Vector2(x + 11, y + 19)]), Color("5f5a82"), 0)
			CelArt.ellipse(self, Vector2(220, 187), Vector2(120, 10), Color("b8945e"))
		Kind.MASTER_BEDROOM:
			for x: int in range(33, 376, 25):
				CelArt.line(self, Vector2(x, 59), Vector2(x, 166), Color("887e92"), 1)
			CelArt.ellipse(self, Vector2(205, 186), Vector2(114, 10), Color("d2c1af"))
		Kind.BATHROOM:
			for x: int in range(24, 376, 22):
				for y: int in range(60, 168, 22):
					CelArt.rect(self, Rect2(x, y, 22, 22), Color("e2eee9") if y > 100 else Color("c4e0db"), 0.8)
			for i: int in range(14):
				CelArt.rect(self, Rect2(30 + i * 25, 180, 22, 8), Color("e6efe9") if i % 2 == 0 else Color("6f9ea8"), 0.8)
		Kind.KIDS:
			for i: int in range(12):
				draw_circle(Vector2(36 + i * 29, 65 + i % 3 * 29), 3, Color("d4bb79"))
			for i: int in range(4):
				var p: Vector2 = Vector2(60 + i * 90, 86 + i % 2 * 26)
				CelArt.poly(self, PackedVector2Array([p + Vector2(0, -8), p + Vector2(3, -2), p + Vector2(9, -2), p + Vector2(4, 2), p + Vector2(6, 8), p + Vector2(0, 4), p + Vector2(-6, 8), p + Vector2(-4, 2), p + Vector2(-9, -2), p + Vector2(-3, -2)]), Color("efca88"), 1.2)
			CelArt.poly(self, PackedVector2Array([Vector2(170, 175), Vector2(270, 175), Vector2(280, 197), Vector2(155, 197)]), Color("ceae70"))
		Kind.GUEST:
			for y: int in range(64, 166, 14):
				CelArt.line(self, Vector2(24, y), Vector2(376, y), Color(wall_color.lightened(0.1), 0.7), 5)
			CelArt.line(self, Vector2(24, 120), Vector2(376, 120), Color("9b7d55"), 4)
			CelArt.poly(self, PackedVector2Array([Vector2(80, 177), Vector2(220, 177), Vector2(232, 197), Vector2(66, 197)]), Color("a58aa3"))
		Kind.GREENHOUSE:
			CelArt.rect(self, Rect2(24, 20, 352, 148), Color("bcd8cf"), 0)
			for x: int in range(24, 380, 44):
				CelArt.line(self, Vector2(x, 20), Vector2(x, 168), Color("eef0dc"), 4)
				CelArt.line(self, Vector2(x + 6, 30), Vector2(x + 20, 60), Color(1, 1, 1, 0.35), 3)
			for y: int in [70, 120]:
				CelArt.line(self, Vector2(24, y), Vector2(376, y), Color("eef0dc"), 4)
			for i: int in range(9):
				CelArt.ellipse(self, Vector2(30 + i % 2 * 8, 40 + i * 14), Vector2(6, 4), Color("6f9c6a"), 1)
				CelArt.ellipse(self, Vector2(368 - i % 2 * 8, 44 + i * 14), Vector2(6, 4), Color("6f9c6a"), 1)
		Kind.GYM:
			CelArt.rect(self, Rect2(150, 62, 210, 56), Color("a9cdd0"), 2)
			for x: int in [176, 236, 300]:
				CelArt.line(self, Vector2(x, 66), Vector2(x - 14, 114), Color(1, 1, 1, 0.45), 4)
			CelArt.rect(self, Rect2(24, 140, 352, 10), Color("d1694f"), 0)
			for x: int in range(30, 372, 40):
				CelArt.line(self, Vector2(x, 180), Vector2(x - 4, 197), Color("2c3434"), 2)
		Kind.ART_STUDIO:
			for i: int in range(16):
				var p: Vector2 = Vector2(40 + (i * 67) % 330, 66 + (i * 37) % 96)
				draw_circle(p, 3.0 + i % 4, Color.from_hsv(fmod(i * .17, 1), .55, .85, .8))
			CelArt.poly(self, PackedVector2Array([Vector2(60, 177), Vector2(340, 177), Vector2(356, 198), Vector2(42, 198)]), Color("e3d8bd"), 1.5)
			for i: int in range(8):
				draw_circle(Vector2(80 + i * 34, 186 + i % 3 * 3), 3, Color.from_hsv(fmod(i * .29, 1), .6, .8))
		Kind.ROOF_CONTROL:
			for x: int in range(26, 376, 9):
				CelArt.line(self, Vector2(x, 60), Vector2(x, 168), wall_color.darkened(0.18) if x % 18 == 8 else wall_color.lightened(0.08), 2)
			for i: int in range(8):
				CelArt.poly(self, PackedVector2Array([Vector2(26 + i * 44, 150), Vector2(48 + i * 44, 150), Vector2(36 + i * 44, 168), Vector2(14 + i * 44, 168)]), CelArt.GOLD if i % 2 == 0 else Color("2c3434"), 0)
			for y: int in range(28, 176, 18):
				CelArt.line(self, Vector2(290, y), Vector2(306, y), Color("c0a35e"), 3)
			CelArt.line(self, Vector2(290, 18), Vector2(290, 176), CelArt.INK, 4)
			CelArt.line(self, Vector2(306, 18), Vector2(306, 176), CelArt.INK, 4)
			CelArt.rect(self, Rect2(284, 18, 28, 8), Color("3b4246"), 1.5)

## Dirty, lived-in walls: ceiling water stains, cracks, soot and mould near the floor.
func _draw_grime() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9173 + room_kind * 131 + floor_index * 7
	var stain: Color = Color(0.08, 0.07, 0.05, 0.28)
	for i: int in range(3):
		var x: float = rng.randf_range(40.0, room_size.x - 60.0)
		var length: float = rng.randf_range(30.0, 90.0)
		var width: float = rng.randf_range(10.0, 26.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 19), Vector2(x + width, 19), Vector2(x + width * 0.7, 19 + length), Vector2(x + width * 0.4, 19 + length + 10), Vector2(x + width * 0.15, 19 + length)]), stain)
	for i: int in range(2):
		var start: Vector2 = Vector2(rng.randf_range(40.0, room_size.x - 40.0), rng.randf_range(60.0, 140.0))
		var crack: PackedVector2Array = PackedVector2Array([start])
		for step: int in range(4):
			start += Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(6.0, 14.0))
			crack.append(start)
		draw_polyline(crack, Color(0.06, 0.05, 0.05, 0.55), 1.6, true)
	for i: int in range(5):
		var p: Vector2 = Vector2(rng.randf_range(30.0, room_size.x - 30.0), rng.randf_range(150.0, 170.0))
		draw_colored_polygon(_blob(p, Vector2(rng.randf_range(10.0, 26.0), rng.randf_range(4.0, 9.0))), Color(0.10, 0.13, 0.08, 0.22))
	# Sparse dark speckle: the dithered "dirt" texture of a pixel-art wall.
	for i: int in range(40):
		var p: Vector2 = Vector2(rng.randf_range(24.0, room_size.x - 30.0), rng.randf_range(20.0, room_size.y - 50.0))
		draw_rect(Rect2(p.snapped(Vector2(DITHER, DITHER)), Vector2(DITHER, DITHER)), Color(0, 0, 0, 0.16))

func _blob(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(10):
		var a: float = TAU * float(i) / 10.0
		points.append(center + Vector2(cos(a), sin(a)) * radius * (0.8 + 0.2 * sin(a * 3.0 + center.x)))
	return points

## Ambient occlusion + vignette over the furniture: soft gradients into each corner and
## edge, finished with a 2x2 ordered dither band so the falloff reads as pixel shading.
func _paint_shade(canvas: Node2D) -> void:
	var w: float = room_size.x
	var h: float = room_size.y
	var dark: Color = Color(0.01, 0.015, 0.02, 0.62)
	var clear: Color = Color(0.01, 0.015, 0.02, 0.0)
	var top: float = 18.0
	var bottom: float = h - 20.0
	_gradient(canvas, Rect2(0, 0, w, 58), dark, clear, true)
	_gradient(canvas, Rect2(0, bottom - 34, w, 34), clear, Color(dark, 0.45), true)
	_gradient(canvas, Rect2(0, top, 70, bottom - top), dark, clear, false)
	_gradient(canvas, Rect2(w - 70, top, 70, bottom - top), clear, dark, false)
	for corner: Vector2 in [Vector2(22, 18), Vector2(w - 22, 18), Vector2(22, h - 44), Vector2(w - 22, h - 44)]:
		for i: int in range(3):
			canvas.draw_circle(corner, 46.0 - i * 13.0, Color(0.0, 0.0, 0.0, 0.10 + i * 0.06))
	# Dither the inner edge of each band (threshold rises toward the dark side).
	var c: Color = Color(0.01, 0.015, 0.02, 0.45)
	for column: int in range(int(w / DITHER)):
		for row: int in range(4):
			if BAYER[(row % 2) * 2 + column % 2] >= row:
				canvas.draw_rect(Rect2(column * DITHER, 58.0 + row * DITHER, DITHER, DITHER), c)
	for row: int in range(int((bottom - top) / DITHER)):
		for column: int in range(4):
			if BAYER[(row % 2) * 2 + column % 2] >= column:
				canvas.draw_rect(Rect2(70.0 + column * DITHER, top + row * DITHER, DITHER, DITHER), c)
				canvas.draw_rect(Rect2(w - 70.0 - (column + 1) * DITHER, top + row * DITHER, DITHER, DITHER), c)

static func _gradient(canvas: CanvasItem, area: Rect2, from: Color, to: Color, vertical: bool) -> void:
	var points: PackedVector2Array = PackedVector2Array([area.position, Vector2(area.end.x, area.position.y), area.end, Vector2(area.position.x, area.end.y)])
	var colors: PackedColorArray = PackedColorArray([from, to, to, from]) if not vertical else PackedColorArray([from, from, to, to])
	canvas.draw_polygon(points, colors)

# ------------------------------------------------------------ damage art ----

## Static damage baked into the room drawing: deep cracks, spalled plaster showing
## brick, and a sagging ceiling once the room is critical.
func _draw_damage() -> void:
	if _state < RoomState.DAMAGED:
		return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4111 + room_kind * 53 + floor_index * 11
	var cracks: int = 4 if _state == RoomState.DAMAGED else 8
	for i: int in range(cracks):
		var start: Vector2 = Vector2(rng.randf_range(30.0, room_size.x - 30.0), 19.0 if i % 2 == 0 else rng.randf_range(60.0, 150.0))
		_crack(start, rng, 5 + i % 3)
	var holes: int = 1 if _state == RoomState.DAMAGED else 3
	for i: int in range(holes):
		var center: Vector2 = Vector2(rng.randf_range(60.0, room_size.x - 60.0), rng.randf_range(70.0, 140.0))
		var size: Vector2 = Vector2(rng.randf_range(18.0, 34.0), rng.randf_range(12.0, 22.0)) * (1.0 if _state == RoomState.DAMAGED else 1.4)
		var hole: PackedVector2Array = _blob(center, size)
		draw_colored_polygon(hole, Color("5e3426"))
		for row: int in range(-2, 3):
			var y: float = center.y + row * 7.0
			draw_line(Vector2(center.x - size.x * 0.8, y), Vector2(center.x + size.x * 0.8, y), Color("2b1a14"), 1.6)
		var closed: PackedVector2Array = hole.duplicate()
		closed.append(hole[0])
		draw_polyline(closed, CelArt.INK, 2.5, true)
	if _state >= RoomState.CRITICAL:
		# The slab above sags in the middle.
		var w: float = room_size.x
		draw_colored_polygon(PackedVector2Array([Vector2(22, 18), Vector2(w - 22, 18), Vector2(w * 0.62, 34), Vector2(w * 0.45, 40), Vector2(w * 0.3, 30)]), Color("1f1b17"))
		draw_polyline(PackedVector2Array([Vector2(22, 18), Vector2(w * 0.3, 30), Vector2(w * 0.45, 40), Vector2(w * 0.62, 34), Vector2(w - 22, 18)]), CelArt.INK, 3.0, true)

func _crack(start: Vector2, rng: RandomNumberGenerator, steps: int) -> void:
	var path: PackedVector2Array = PackedVector2Array([start])
	var point: Vector2 = start
	for step: int in range(steps):
		point += Vector2(rng.randf_range(-16.0, 16.0), rng.randf_range(8.0, 20.0))
		point.y = minf(point.y, room_size.y - 46.0)
		path.append(point)
		if step == 2:
			var branch: Vector2 = point + Vector2(rng.randf_range(-24.0, 24.0), rng.randf_range(6.0, 18.0))
			draw_line(point, branch, Color("15110e"), 2.0, true)
	draw_polyline(path, Color("15110e"), 3.4, true)
	var lit: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in path:
		lit.append(p + Vector2(1.6, 0.8))
	draw_polyline(lit, Color(wall_color.lightened(0.25), 0.55), 1.2, true)

## Animated layer above furniture, light cones and pillars.
func _draw_fx() -> void:
	if heat > 0.0:
		_fx.draw_rect(Rect2(24, 20, room_size.x-48, room_size.y-40), Color(1.0,.15,.02,heat*.0015))
	if custom_sprite != null:
		return
	var t: float = _fx_clock
	match _state:
		RoomState.DAMAGED:
			_draw_falling_dust(t, 6, Color(0.55, 0.52, 0.46, 0.7))
			_hp_bar(Color("e0b04c"))
		RoomState.CRITICAL:
			_draw_buckled_columns(t)
			_draw_falling_dust(t, 12, Color(0.6, 0.56, 0.5, 0.85))
			if not utilities_isolated:
				_draw_sparks(t)
			_fx.draw_rect(Rect2(22, 18, room_size.x - 44, room_size.y - 38), Color(0.6, 0.05, 0.03, 0.05 + 0.05 * (0.5 + 0.5 * sin(t * 6.0))))
			_hp_bar(Color("ff4a3a"))
		RoomState.COLLAPSED:
			_draw_collapse(t)
	if shaking and _state != RoomState.COLLAPSED:
		_fx.draw_rect(Rect2(20, 16, room_size.x - 40, room_size.y - 36), Color(0.05, 0.05, 0.05, 0.35))
		_draw_falling_dust(t * 2.5, 18, Color(0.5, 0.48, 0.44, 0.9))

## Full-sized retrofit silhouettes. Colors stay readable under the existing night tint.
func _paint_supports(canvas: Node2D) -> void:
	if custom_sprite != null: return
	if auto_protection and not is_collapsed(): EquipmentArt.draw_safety_installation(canvas,room_size,0)
	if chain_support and not fortified:
		for x: float in [16.0,room_size.x-16.0]:
			canvas.draw_line(Vector2(x,55),Vector2(x,room_size.y-35),Color("4c969c"),9)
			for y: float in [60.0,room_size.y-40.0]: canvas.draw_circle(Vector2(x,y),4,Color("9ce4d7"))
	if fortified and not is_collapsed(): _draw_braces(canvas)

func _draw_braces(canvas: Node2D) -> void:
	var bottom: float = room_size.y - 22.0
	if has_reinforcement(Reinforcement.STEEL):
		EquipmentArt.draw_carbon_wrap(canvas,room_size)
		for side: int in range(2):
			var x: float = 6.0 if side == 0 else room_size.x - 74.0
			CelArt.box(canvas, Rect2(x, 8, 68, bottom - 8), Color("324957"), Vector2(5, -4))
			for diagonal: Array in [[Vector2(x + 4, 15), Vector2(x + 64, bottom - 7)], [Vector2(x + 64, 15), Vector2(x + 4, bottom - 7)]]:
				canvas.draw_line(diagonal[0], diagonal[1], CelArt.INK, 18.0)
				canvas.draw_line(diagonal[0], diagonal[1], Color("c1d6df"), 12.0)
				canvas.draw_line(diagonal[0] + Vector2(-2,0), diagonal[1] + Vector2(-2,0), Color("648ba0"), 4.0)
			for y: float in [14.0, bottom * 0.5, bottom - 10.0]:
				CelArt.rect(canvas, Rect2(x - 3, y - 9, 74, 18), Color("f5c84c"), 3.0)
				for stripe: int in range(5):
					var sx: float = x + stripe * 14
					canvas.draw_colored_polygon(PackedVector2Array([Vector2(sx,y-7),Vector2(sx+7,y-7),Vector2(sx+13,y+7),Vector2(sx+6,y+7)]), CelArt.INK)
				CelArt.bolt(canvas, Vector2(x + 5, y), Color("e1e8d7"))
				CelArt.bolt(canvas, Vector2(x + 62, y), Color("e1e8d7"))
		CelArt.box(canvas, Rect2(76, 7, room_size.x - 152, 13), Color("7e9dac"), Vector2(0, -4))
	if has_reinforcement(Reinforcement.SHUTTER):
		for prop: BuildingProp in props():
			if prop.kind != BuildingProp.Kind.WINDOW: continue
			var rect: Rect2 = Rect2(prop.position - Vector2(prop.prop_size.x * 0.5 + 5, prop.prop_size.y + 3), prop.prop_size + Vector2(10, 6))
			CelArt.box(canvas, rect, Color("697e87"), Vector2(4, -3))
			for y: float in range(int(rect.position.y) + 6, int(rect.end.y), 10):
				canvas.draw_line(Vector2(rect.position.x + 3, y), Vector2(rect.end.x - 3, y), Color("c0c7b8"), 3.0)
			CelArt.rect(canvas, Rect2(rect.position.x + 4, rect.position.y + 3, 8, rect.size.y - 6), Color("d3ae43"))
			CelArt.rect(canvas, Rect2(rect.end.x - 12, rect.position.y + 3, 8, rect.size.y - 6), Color("d3ae43"))
		for row: int in range(2):
			for bag: int in range(5 - row):
				var pos: Vector2 = Vector2(86 + bag * 46 + row * 23, bottom - row * 17)
				CelArt.poly(canvas, PackedVector2Array([pos+Vector2(-3,-12),pos+Vector2(4,-18),pos+Vector2(39,-17),pos+Vector2(44,-9),pos+Vector2(39,0),pos]), Color("b9a77b").lightened(row*.08), 2.5)
				canvas.draw_line(pos+Vector2(5,-6),pos+Vector2(35,-5),Color("756a4c"),2.0)
	if has_reinforcement(Reinforcement.ANCHOR):
		for prop: BuildingProp in props():
			if prop.kind in [BuildingProp.Kind.WINDOW, BuildingProp.Kind.LAMP, BuildingProp.Kind.SKYLIGHT, BuildingProp.Kind.POSTER, BuildingProp.Kind.CURTAINS]: continue
			var half: float = minf(prop.prop_size.x * .5, 55.0)
			var center: Vector2 = prop.position - Vector2(0, prop.prop_size.y * .6)
			canvas.draw_line(center - Vector2(half,0),center + Vector2(half,0), CelArt.INK, 9.0)
			canvas.draw_line(center - Vector2(half,0),center + Vector2(half,0), Color("80d6c4"), 5.0)
			for direction: float in [-1.0,1.0]:
				var pin: Vector2 = center + Vector2(direction * half,0)
				CelArt.rect(canvas, Rect2(pin-Vector2(5,9),Vector2(10,18)),Color("c0d4ca"),2.0)
				CelArt.bolt(canvas,pin,Color("e7f0d7"))
	# Three individual status LEDs make partial and fully completed rooms distinct.
	for tier: int in range(3):
		var lit: bool = tier < reinforcement_level
		var point: Vector2 = Vector2(room_size.x * .5 - 18 + tier * 18, 34)
		CelArt.rect(canvas,Rect2(point-Vector2(7,5),Vector2(14,10)),Color("72ffb0") if lit else Color("303c39"),2.0)
		if lit: canvas.draw_circle(point, 13.0, Color(0.3,1.0,.6,.18))

func _draw_falling_dust(t: float, count: int, color: Color) -> void:
	var w: float = room_size.x
	for k: int in range(count):
		var x: float = 30.0 + fmod(k * 73.3 + floor_index * 31.0, w - 60.0)
		var y: float = 22.0 + fmod(t * (34.0 + k * 6.0) + k * 41.0, room_size.y - 70.0)
		_fx.draw_rect(Rect2(x + sin(t * 2.0 + k) * 4.0, y, 5.1, 5.1), color)
	# Occasional plaster chunk breaking off the ceiling.
	var chunk: float = fmod(t * 0.6 + room_kind * 0.13, 1.0)
	if chunk < 0.4:
		var cx: float = 60.0 + fmod(room_kind * 97.0 + floor(t * 0.6) * 131.0, w - 120.0)
		_fx.draw_colored_polygon(PackedVector2Array([Vector2(cx, 20 + chunk * 330), Vector2(cx + 9, 23 + chunk * 330), Vector2(cx + 5, 31 + chunk * 330)]), Color("6a655c"))

## Columns bowing with cracked concrete and exposed glowing rebar.
func _draw_buckled_columns(t: float) -> void:
	var bottom: float = room_size.y - 20.0
	var quiver: float = sin(t * 23.0) * 1.2
	for side: float in [-1.0, 1.0]:
		var x: float = 0.0 if side < 0 else room_size.x
		var bulge: float = 12.0 * (1.0 if side < 0 else -1.0) + quiver
		var shape: PackedVector2Array = PackedVector2Array([Vector2(x - 19, 0), Vector2(x + 19, 0), Vector2(x + 19 + bulge, bottom * 0.5), Vector2(x + 19, bottom), Vector2(x - 19, bottom), Vector2(x - 19 + bulge, bottom * 0.5)])
		CelArt.poly(_fx, shape, Color("5b625c"))
		_fx.draw_line(Vector2(x - 6 + bulge * 0.6, bottom * 0.36), Vector2(x + 8 + bulge, bottom * 0.62), Color("ff8a3a"), 2.4, true)
		_fx.draw_line(Vector2(x + 4 + bulge * 0.6, bottom * 0.4), Vector2(x - 4 + bulge, bottom * 0.66), Color("c46a2c"), 2.0, true)
		_fx.draw_polyline(PackedVector2Array([Vector2(x - 12, 30), Vector2(x - 2 + bulge * 0.5, bottom * 0.35), Vector2(x + 6 + bulge, bottom * 0.5), Vector2(x - 4, bottom * 0.75)]), CelArt.INK, 2.5, true)

func _draw_sparks(t: float) -> void:
	for k: int in range(6):
		var cycle: float = fmod(t * 1.4 + k * 0.29 + room_kind * 0.07, 1.0)
		if cycle > 0.4:
			continue
		var origin: Vector2 = Vector2(50.0 + fmod(k * 61.0 + room_kind * 23.0, room_size.x - 100.0), 22.0)
		var fall: Vector2 = origin + Vector2(sin(k * 1.7) * 30.0 * cycle, cycle * 260.0)
		var fade: float = 1.0 - cycle / 0.4
		for ray: int in range(3):
			var direction: Vector2 = Vector2.from_angle(PI * 0.5 + (ray - 1) * 0.6 + k)
			_fx.draw_line(fall, fall + direction * 7.0, Color(1.0, 0.82, 0.45, fade), 2.6)
		_fx.draw_circle(fall, 4.0, Color(1.0, 0.55, 0.2, 0.4 * fade))

## Fallen slab, rubble heap, bent beam, darkness and rising smoke.
func _draw_collapse(t: float) -> void:
	var w: float = room_size.x
	var h: float = room_size.y
	_fx.draw_rect(Rect2(20, 16, w - 40, h - 36), Color(0.02, 0.02, 0.025, 0.62))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 777 + room_kind * 19
	CelArt.poly(_fx, PackedVector2Array([Vector2(24, 18), Vector2(w * 0.55, 18), Vector2(w * 0.35, 92), Vector2(26, 46)]), Color("4d514c"))
	_fx.draw_line(Vector2(w * 0.2, 30), Vector2(w * 0.3, 70), Color("a0603a"), 2.0)
	CelArt.poly(_fx, PackedVector2Array([Vector2(w * 0.6, 18), Vector2(w - 24, 18), Vector2(w - 26, 60), Vector2(w * 0.72, 120)]), Color("454944"))
	_fx.draw_line(Vector2(w * 0.18, h - 30), Vector2(w * 0.78, 40), CelArt.INK, 12.0)
	_fx.draw_line(Vector2(w * 0.18, h - 30), Vector2(w * 0.78, 40), Color("3d3a35"), 7.0)
	var heap: PackedVector2Array = PackedVector2Array([Vector2(20, h - 20)])
	for i: int in range(9):
		heap.append(Vector2(30.0 + i * (w - 60.0) / 8.0, h - 70.0 - rng.randf_range(0.0, 46.0) * sin(PI * (0.15 + 0.7 * i / 8.0))))
	heap.append(Vector2(w - 20, h - 20))
	CelArt.poly(_fx, heap, Color("4a4842"))
	for i: int in range(14):
		var p: Vector2 = Vector2(rng.randf_range(40.0, w - 40.0), rng.randf_range(h - 100.0, h - 34.0))
		CelArt.poly(_fx, PackedVector2Array([p, p + Vector2(rng.randf_range(10, 22), -rng.randf_range(4, 12)), p + Vector2(rng.randf_range(14, 26), rng.randf_range(2, 10)), p + Vector2(rng.randf_range(2, 8), rng.randf_range(8, 14))]), Color("5d5a52").lerp(Color("72675a"), rng.randf()), 1.6)
	for i: int in range(4):
		var p: Vector2 = Vector2(rng.randf_range(60.0, w - 60.0), h - 60.0)
		_fx.draw_line(p, p + Vector2(rng.randf_range(-20, 20), -rng.randf_range(24, 44)), Color("8a4b2c"), 2.4)
	for k: int in range(6):
		var phase: float = fmod(t * 0.32 + k * 0.17, 1.0)
		var center: Vector2 = Vector2(50.0 + k * (w - 100.0) / 5.0 + sin(t + k) * 10.0, h - 70.0 - phase * 140.0)
		_fx.draw_circle(center, 12.0 + phase * 26.0, Color(0.16, 0.16, 0.17, 0.45 * (1.0 - phase)))
		if k % 2 == 0 and phase < 0.5:
			_fx.draw_rect(Rect2(center + Vector2(6, 8), Vector2(5.1, 5.1)), Color(1.0, 0.45, 0.15, 0.8 * (1.0 - phase * 2.0)))

func _hp_bar(color: Color) -> void:
	var ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	CelArt.rect(_fx, Rect2(30, 26, 84, 8), Color(0.04, 0.05, 0.06, 0.85), 1.5)
	_fx.draw_rect(Rect2(32, 28, 80 * ratio, 4), color)
