class_name HazardProjectile
extends Node2D
## Pool entries are never freed during combat. Collision is swept in relative space.

@export var custom_sprite: Texture2D
const TRAIL_LENGTH: int = 4
## Rim glow: electric blue for the storm, ember orange for the quake; red danger core.
const STORM_GLOW: Color = Color("5fc8ff")
const QUAKE_GLOW: Color = Color("ff7b2e")
const CORE: Color = Color("ff3a2c")
var active: bool = false
var attack: HazardAttack
var age: float = 0.0
var dodge_reported: bool = false
var contacted_player: bool = false
## Additive neon halo + motion trail, drawn behind the body. Created once with the pool.
var glow: Node2D
var _trail: Array[Vector2] = []
var _trail_line: PackedVector2Array = PackedVector2Array()
var _cache_source: bool = false
var body_texture: Texture2D
const BODY_BOUNDS: Rect2 = Rect2(-70,-70,140,140)

func _ready() -> void:
	if _cache_source: return
	set_process(false)
	set_physics_process(false)
	visible = false
	glow = Node2D.new()
	glow.name = "Glow"
	glow.show_behind_parent = true
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = additive
	glow.draw.connect(_draw_glow)
	add_child(glow)

func glow_color() -> Color:
	if attack == null:
		return STORM_GLOW
	return [STORM_GLOW, QUAKE_GLOW, Color("55f2e2"), Color("ff602a")][attack.source]

func activate(specification: HazardAttack) -> bool:
	if not specification.is_armed():
		return false
	attack = specification
	age = 0.0
	contacted_player = false
	dodge_reported = false
	global_position = attack.origin
	rotation = 0.0
	_trail.clear()
	_trail_line.clear()
	active = true
	# ProjectilePool advances entries centrally; no per-entry callbacks are needed.
	set_process(false)
	set_physics_process(false)
	visible = true
	queue_redraw()
	return true

func deactivate() -> void:
	active = false
	set_process(false)
	set_physics_process(false)
	visible = false
	attack = null
	_trail.clear()
	_trail_line.clear()

func advance(delta: float) -> void:
	if not active or attack == null: return
	_trail.push_front(global_position)
	if _trail.size() > TRAIL_LENGTH:
		_trail.pop_back()
	age = minf(age + delta, attack.lifetime)
	global_position = attack.point_at(age)
	_trail_line.resize(_trail.size())
	for i: int in range(_trail.size()): _trail_line[i] = to_local(_trail[i])
	queue_redraw()
	glow.queue_redraw()

func crosses_player(player: SiegePlayer, previous_projectile: Vector2) -> bool:
	if attack.is_area():
		if attack.kind == HazardAttack.Kind.WHIRLPOOL: return false
		for area: Rect2 in attack.area_segments():
			if _crosses_area(player,area): return true
		return false
	if contacted_player:
		return false
	# Moving projectile versus moving capsule: relative segment to the vertical spine.
	var start: Vector2 = previous_projectile - player.previous_position
	var end: Vector2 = global_position - player.global_position
	if attack.is_wall():
		# A tall, narrow wall; a huge circle would incorrectly hit adjacent floors.
		var bottom: float = attack.floor_y - global_position.y
		var closest_wall: PackedVector2Array = Geometry2D.get_closest_points_between_segments(start, end, Vector2(0, -36 - bottom), Vector2(0, -12 + attack.row_height - bottom))
		return closest_wall[0].distance_squared_to(closest_wall[1]) <= pow(attack.radius + 12, 2)
	var closest: PackedVector2Array = Geometry2D.get_closest_points_between_segments(start, end, Vector2(0, -36), Vector2(0, -12))
	return closest[0].distance_squared_to(closest[1]) <= pow(attack.radius + 12.0, 2.0)

func _draw_glow() -> void:
	if not active or attack == null:
		return
	var color: Color = glow_color()
	if attack.is_area(): return
	# One bounded four-point strip, one halo; no multilayer trail tessellation.
	if _trail_line.size() >= 2: glow.draw_polyline(_trail_line,Color(color,.34),maxf(3.0,attack.radius*.65),false)
	if attack.is_wall():
		glow.draw_rect(Rect2(-26, -attack.row_height * 0.5 - 6, 52, attack.row_height + 12), Color(color, 0.22))
		return
	var pulse: float = 0.85 + 0.15 * sin(age * 18.0)
	glow.draw_circle(Vector2.ZERO, attack.radius * 1.65, Color(color, 0.28 * pulse))

func _draw() -> void:
	if not active or attack == null:
		return
	if body_texture != null and custom_sprite == null:
		if attack.pattern == HazardAttack.Pattern.VORTEX and attack.lead and age < 1.4:
			TelegraphSystem.draw_vortex_eye(self,to_local(attack.origin),age*9.0,.9-age*.3,1.0-age/1.4)
		var angle: float = age*(5.0 if attack.source == 0 else 2.4)
		if attack.kind == HazardAttack.Kind.WIND_BLADE: angle = attack.velocity.angle()
		elif attack.kind == HazardAttack.Kind.DEBRIS: angle = age*9.0*signf(attack.velocity.x)
		draw_set_transform(Vector2.ZERO,angle)
		draw_texture_rect(body_texture,BODY_BOUNDS,false)
		draw_set_transform(Vector2.ZERO)
		return
	if attack.source >= 2:
		MarathonArt.projectile(self)
		return
	if attack.pattern == HazardAttack.Pattern.VORTEX and attack.lead and age < 1.4:
		# The mini-tornado eye lingers briefly where the ring was born, then dissipates.
		TelegraphSystem.draw_vortex_eye(self, to_local(attack.origin), age * 9.0, 0.9 - age * 0.3, 1.0 - age / 1.4)
	var spin: float = age * (5.0 if attack.source == 0 else 2.4)
	if attack.kind in [HazardAttack.Kind.SHOCKWAVE, HazardAttack.Kind.ROW_SWEEP]:
		spin = 0.0
	elif attack.kind == HazardAttack.Kind.WIND_BLADE:
		# Crossfire blades fly diagonally; the cutting edge leads the path.
		spin = attack.velocity.angle()
	elif attack.kind == HazardAttack.Kind.DEBRIS:
		spin = age * 9.0 * signf(attack.velocity.x)
	draw_set_transform(Vector2.ZERO, spin)
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(Vector2.ONE * -attack.radius, Vector2.ONE * attack.radius * 2), false)
	else:
		match attack.kind:
			HazardAttack.Kind.GLASS:
				CelArt.poly(self, PackedVector2Array([Vector2(-12, -7), Vector2(16, -3), Vector2(-4, 12)]), Color("b6dad1"))
				CelArt.line(self, Vector2(-6, -4), Vector2(10, -3), Color("edf0cc"), 2)
			HazardAttack.Kind.POT:
				CelArt.poly(self, PackedVector2Array([Vector2(-17, -6), Vector2(17, -6), Vector2(11, 16), Vector2(-10, 16)]), Color("be7c58"))
				CelArt.rect(self, Rect2(-20, -11, 40, 8), Color("e5aa73"))
				for i: int in range(3):
					CelArt.ellipse(self, Vector2(-12 + i * 12, -18 - i % 2 * 6), Vector2(8, 12), Color("7da37b"))
			HazardAttack.Kind.CHAIR:
				CelArt.box(self, Rect2(-18, -25, 36, 20), Color("b79160"), Vector2(5, -5))
				CelArt.box(self, Rect2(-20, -3, 40, 8), Color("d0ae78"), Vector2(5, -5))
				for x: float in [-15.0, 14.0]:
					CelArt.line(self, Vector2(x, -12), Vector2(x, 24), CelArt.INK, 6)
					CelArt.line(self, Vector2(x, -12), Vector2(x, 24), Color("a67d51"), 3)
			HazardAttack.Kind.WIND_BLADE:
				CelArt.poly(self, PackedVector2Array([Vector2(-32, -42), Vector2(12, -29), Vector2(34, 0), Vector2(8, 28), Vector2(-35, 42), Vector2(-10, 12), Vector2(3, 0), Vector2(-11, -13)]), Color("a7d0c4"))
				CelArt.line(self, Vector2(7, -22), Vector2(24, 0), Color("e1e5c8"), 3)
			HazardAttack.Kind.BRICK:
				CelArt.box(self, Rect2(-16, -11, 32, 22), Color("b77657"), Vector2(6, -6))
				CelArt.line(self, Vector2(-11, 0), Vector2(6, -5), Color("774e41"), 2)
			HazardAttack.Kind.CONCRETE:
				CelArt.poly(self, PackedVector2Array([Vector2(-26, -18), Vector2(16, -23), Vector2(29, -6), Vector2(21, 23), Vector2(-16, 25), Vector2(-29, 6)]), Color("a8ac96"))
				CelArt.poly(self, PackedVector2Array([Vector2(-26, -18), Vector2(16, -23), Vector2(29, -6), Vector2(-6, -1)]), Color("c3c4a9"), 1.5)
				draw_polyline(PackedVector2Array([Vector2(4, -12), Vector2(-4, 2), Vector2(8, 9), Vector2(2, 22)]), CelArt.INK, 2.5, true)
				CelArt.line(self, Vector2(-22, -9), Vector2(-34, -19), CelArt.INK, 3)
			HazardAttack.Kind.CHANDELIER:
				CelArt.line(self, Vector2(0, -28), Vector2(0, 3), CelArt.INK, 5)
				for x: float in [-22.0, 0.0, 22.0]:
					CelArt.line(self, Vector2(0, 3), Vector2(x, 13), Color("c09b58"), 6)
					CelArt.poly(self, PackedVector2Array([Vector2(x - 10, 10), Vector2(x + 10, 10), Vector2(x + 7, 25), Vector2(x - 7, 25)]), Color("e5c785"))
			HazardAttack.Kind.SHOCKWAVE:
				CelArt.poly(self, PackedVector2Array([Vector2(-24, 9), Vector2(-15, -5), Vector2(-7, 0), Vector2(1, -15), Vector2(13, -3), Vector2(23, 9)]), Color("da9e64"))
				CelArt.line(self, Vector2(-18, 9), Vector2(21, 9), Color("f2d296"), 3)
			HazardAttack.Kind.BOOK:
				CelArt.box(self, Rect2(-12, -16, 24, 32), Color("6c9a8c"), Vector2(5, -3))
				CelArt.rect(self, Rect2(-8, -11, 17, 23), Color("e2d6b3"), 1)
			HazardAttack.Kind.WIND_ORB:
				CelArt.ellipse(self, Vector2.ZERO, Vector2(12, 12), Color("74aeb4"))
				for i: int in range(2):
					draw_arc(Vector2.ZERO, 4 + i * 5, age * 6 + i, age * 6 + i + PI, 8, Color("d8e6cb"), 2, false)
			HazardAttack.Kind.SHARD:
				CelArt.poly(self, PackedVector2Array([Vector2(-8, 7), Vector2(-5, -7), Vector2(7, -4), Vector2(9, 5)]), Color("b7ad8c"))
				CelArt.line(self, Vector2(-3, -3), Vector2(5, 2), CelArt.PAPER, 2)
			HazardAttack.Kind.ROW_SWEEP:
				for i: int in range(8):
					var y: float = -attack.row_height * .5 + i * attack.row_height / 8
					var x: float = sin(age * 29 + i) * 9
					CelArt.poly(self, PackedVector2Array([Vector2(x - 13, y), Vector2(x + 9, y - 6), Vector2(x + 19, y + 7), Vector2(x - 10, y + 19)]), Color("94c9c5") if attack.source == 0 else Color("c4a27b"))
			HazardAttack.Kind.WARDROBE:
				CelArt.box(self, Rect2(-18, -29, 36, 58), Color("aa8771"), Vector2(5, -4))
				CelArt.line(self, Vector2(0, -26), Vector2(0, 25), CelArt.INK, 2)
				CelArt.ellipse(self, Vector2(5, 0), Vector2(2, 3), CelArt.GOLD, 1)
			HazardAttack.Kind.KNIFE:
				CelArt.poly(self, PackedVector2Array([Vector2(-4, -20), Vector2(6, -8), Vector2(5, 7), Vector2(-4, 7)]), Color("c5d9cc"))
				CelArt.rect(self, Rect2(-4, 7, 9, 14), Color("8f6950"))
			HazardAttack.Kind.PLATE:
				CelArt.ellipse(self, Vector2.ZERO, Vector2(15, 9), Color("e0d9b8"))
				CelArt.ellipse(self, Vector2.ZERO, Vector2(10, 5), Color("91b8b1"), 1.5)
			HazardAttack.Kind.SAW:
				var points: PackedVector2Array = []
				for i: int in range(24):
					points.append(Vector2.from_angle(i * TAU / 24) * (17 if i % 2 == 0 else 12))
				CelArt.poly(self, points, Color("acb9b1"))
				CelArt.ellipse(self, Vector2.ZERO, Vector2(5, 5), Color("6d837d"))
			HazardAttack.Kind.TOOL:
				CelArt.rect(self, Rect2(-4, -19, 8, 35), Color("bb8d55"))
				CelArt.box(self, Rect2(-13, -20, 26, 11), Color("99aaa1"), Vector2(4, -3))
			HazardAttack.Kind.TOY:
				CelArt.box(self, Rect2(-11, -11, 22, 22), Color("b68c68"), Vector2(4, -4))
				CelArt.poly(self, PackedVector2Array([Vector2(-5, 6), Vector2(0, -6), Vector2(5, 6)]), CelArt.PAPER, 1.2)
			HazardAttack.Kind.DEBRIS:
				# Storm-dragged plank and roof tile, rolling low along the floor.
				CelArt.poly(self, PackedVector2Array([Vector2(-17, -6), Vector2(14, -10), Vector2(17, -2), Vector2(-14, 4)]), Color("a7764f"))
				CelArt.line(self, Vector2(-11, -4), Vector2(10, -7), Color("d1a06c"), 2)
				CelArt.poly(self, PackedVector2Array([Vector2(-8, 2), Vector2(9, 0), Vector2(12, 13), Vector2(-6, 15)]), Color("b8674a"))
				CelArt.ellipse(self, Vector2(10, -12), Vector2(6, 4), Color("7da37b"), 1.5)
	draw_set_transform(Vector2.ZERO)
	# Bright red danger core: every hostile shot shares one readable centre.
	if attack.kind != HazardAttack.Kind.ROW_SWEEP:
		var core: float = clampf(attack.radius * 0.28, 3.0, 7.0)
		draw_circle(Vector2.ZERO, core + 2.0, Color(CelArt.INK, 0.8))
		draw_circle(Vector2.ZERO, core, CORE)
		draw_circle(Vector2.ZERO, core * 0.45, Color(1.0, 0.85, 0.75))

func _crosses_area(player: SiegePlayer, area: Rect2) -> bool:
	area = area.grow(12)
	var foot: Vector2 = player.global_position+Vector2(0,-12)
	var head: Vector2 = player.global_position+Vector2(0,-36)
	if area.has_point(foot) or area.has_point(head): return true
	var previous: Vector2 = player.previous_position+Vector2(0,-12)
	var corners: Array[Vector2] = [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]
	for edge: int in range(4):
		if Geometry2D.segment_intersects_segment(previous,foot,corners[edge],corners[(edge+1)%4]) != null: return true
	return false
