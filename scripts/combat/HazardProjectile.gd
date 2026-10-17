class_name HazardProjectile
extends Node2D
## Pool entries are never freed during combat. Collision is swept in relative space.

@export var custom_sprite: Texture2D
const TRAIL_LENGTH: int = 4
## Step 7 high-contrast bullets: 3 px near-black rim, the boss neon, a white core.
const OUTLINE: Color = Color("05070a")
const CORE: Color = Color("ffffff")
const NEON: Array[Color] = [Color("00f0ff"), Color("ff9500"), Color("2b7fff"), Color("ff9500")]
## Rim thickness in world units: ~3 px on the 1920x1080 screen (base zoom 0.78).
const OUTLINE_WIDTH: float = 4.0
## Silhouettes: round orb, oriented blade, chunky rock, ground spike.
enum Shape { ORB, BLADE, ROCK, SPIKE }
## Shapes are rasterised once at this radius and scaled to each bullet.
const CACHE_RADIUS: float = 24.0
const STORM_GLOW: Color = Color("00f0ff")
const QUAKE_GLOW: Color = Color("ff9500")
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
## A graze (near miss) is reported once per bullet.
var graze_reported: bool = false
## Closest edge clearance seen while inside the graze window (INF = not yet near).
var graze_gap: float = INF
## Each armored room gets one roll per bullet, including fast boundary crossings.
var armor_checked: Dictionary = {}
const BODY_BOUNDS: Rect2 = Rect2(-70,-70,140,140)
## Each cached texture is a two-cell atlas: solid rim silhouette | neon body + core.
## Both cells come from one texture, so a bullet stays a single batch; the rim cell is
## scaled to radius + OUTLINE_WIDTH, keeping a constant rim on every bullet size.
const SILHOUETTE_REGION: Rect2 = Rect2(0, 0, 140, 140)
const BODY_REGION: Rect2 = Rect2(140, 0, 140, 140)
const ATLAS_BOUNDS: Rect2 = Rect2(-70, -70, 280, 140)

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
	return neon(attack.source)

static func neon(source: int) -> Color:
	return NEON[clampi(source, 0, NEON.size() - 1)]

static func shape_of(kind: int) -> int:
	match kind:
		HazardAttack.Kind.WIND_BLADE, HazardAttack.Kind.KNIFE, HazardAttack.Kind.HARPOON, HazardAttack.Kind.WATER_BLADE, HazardAttack.Kind.FIRE_DART:
			return Shape.BLADE
		HazardAttack.Kind.BRICK, HazardAttack.Kind.CONCRETE, HazardAttack.Kind.SHARD, HazardAttack.Kind.DEBRIS, HazardAttack.Kind.FLOATING_DEBRIS, HazardAttack.Kind.METEOR, HazardAttack.Kind.CHANDELIER, HazardAttack.Kind.WARDROBE:
			return Shape.ROCK
		HazardAttack.Kind.SHOCKWAVE:
			return Shape.SPIKE
	return Shape.ORB

static func cache_key(kind: int, source: int) -> int:
	return shape_of(kind) * 10 + clampi(source, 0, 2)

## Body polygons of a shape at radius r (ORB is a plain circle, SPIKE three teeth).
static func shape_polygons(shape: int, r: float) -> Array[PackedVector2Array]:
	match shape:
		Shape.BLADE:
			return [PackedVector2Array([Vector2(r * 1.7, 0), Vector2(r * .15, -r * .62), Vector2(-r * 1.25, -r * .2), Vector2(-r * .7, 0), Vector2(-r * 1.25, r * .2), Vector2(r * .15, r * .62)])]
		Shape.ROCK:
			var rock: PackedVector2Array = PackedVector2Array()
			for i: int in range(7):
				rock.append(Vector2.from_angle(i * TAU / 7.0 + .3) * r * (0.84 if i % 2 == 0 else 1.0))
			return [rock]
		Shape.SPIKE:
			var teeth: Array[PackedVector2Array] = []
			for i: int in range(3):
				var x: float = (i - 1) * r * .85
				var h: float = r * (1.6 if i == 1 else 1.15)
				teeth.append(PackedVector2Array([Vector2(x - r * .5, r * .55), Vector2(x, r * .55 - h), Vector2(x + r * .5, r * .55)]))
			return teeth
	return []

## Near-black rim at a constant world thickness, drawn under the cached body.
static func paint_outline(c: CanvasItem, shape: int, r: float) -> void:
	if shape == Shape.ORB:
		c.draw_circle(Vector2.ZERO, r + OUTLINE_WIDTH, OUTLINE)
		return
	for polygon: PackedVector2Array in shape_polygons(shape, r):
		c.draw_colored_polygon(_grow(polygon, OUTLINE_WIDTH), OUTLINE)

## Neon body + white core at radius r (the cache paints this once per shape/neon).
static func paint_body(c: CanvasItem, shape: int, source: int, r: float) -> void:
	var color: Color = neon(source)
	if shape == Shape.ORB:
		c.draw_circle(Vector2.ZERO, r, color)
		c.draw_circle(Vector2.ZERO, r * .64, color.lightened(.3))
		c.draw_circle(Vector2.ZERO, r * .4, CORE)
		return
	var polygons: Array[PackedVector2Array] = shape_polygons(shape, r)
	for polygon: PackedVector2Array in polygons: c.draw_colored_polygon(polygon, color)
	match shape:
		Shape.BLADE:
			c.draw_line(Vector2(-r * .55, 0), Vector2(r * 1.2, 0), CORE, maxf(2.0, r * .24))
		Shape.ROCK:
			var rock: PackedVector2Array = polygons[0]
			c.draw_colored_polygon(PackedVector2Array([rock[1] * .45, rock[2] * .45, rock[3] * .3]), color.lightened(.35))
			c.draw_circle(Vector2.ZERO, r * .34, CORE)
		Shape.SPIKE:
			for tooth: PackedVector2Array in polygons:
				c.draw_line(tooth[0].lerp(tooth[2], .5) + Vector2(0, -r * .1), tooth[1].lerp(tooth[0].lerp(tooth[2], .5), .2), CORE, maxf(2.0, r * .16))

## Atlas painter used by ProjectilePool: rim silhouette left, body right.
static func paint_atlas(c: CanvasItem, shape: int, source: int, r: float) -> void:
	if shape == Shape.ORB:
		c.draw_circle(Vector2.ZERO, r, OUTLINE)
	else:
		for polygon: PackedVector2Array in shape_polygons(shape, r): c.draw_colored_polygon(polygon, OUTLINE)
	c.draw_set_transform(Vector2(BODY_BOUNDS.size.x, 0))
	paint_body(c, shape, source, r)
	c.draw_set_transform(Vector2.ZERO)

## Rim + body from the cached atlas at radius r (two rects, one texture).
func _draw_cached(center: Vector2, spin: float, r: float) -> void:
	draw_set_transform(center, spin, Vector2.ONE * ((r + OUTLINE_WIDTH) / CACHE_RADIUS))
	draw_texture_rect_region(body_texture, BODY_BOUNDS, SILHOUETTE_REGION)
	draw_set_transform(center, spin, Vector2.ONE * (r / CACHE_RADIUS))
	draw_texture_rect_region(body_texture, BODY_BOUNDS, BODY_REGION)

## Pushes every vertex out from the centroid so the fill keeps a uniform rim.
static func _grow(points: PackedVector2Array, amount: float) -> PackedVector2Array:
	var center: Vector2 = Vector2.ZERO
	for p: Vector2 in points: center += p
	center /= points.size()
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in points: out.append(p + (p - center).normalized() * amount)
	return out

func activate(specification: HazardAttack) -> bool:
	if not specification.is_armed():
		return false
	attack = specification
	age = 0.0
	contacted_player = false
	dodge_reported = false
	graze_reported = false
	graze_gap = INF
	armor_checked.clear()
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

## Edge-to-edge clearance between this frame's bullet sweep and the player capsule
## (<= 0 means contact). Same relative segment test as crosses_player.
func clearance(player: SiegePlayer, previous_projectile: Vector2) -> float:
	var start: Vector2 = previous_projectile - player.previous_position
	var end: Vector2 = global_position - player.global_position
	var closest: PackedVector2Array = Geometry2D.get_closest_points_between_segments(start, end, Vector2(0, -36), Vector2(0, -12))
	return closest[0].distance_to(closest[1]) - (attack.radius + 12.0)

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
	if _cache_source:
		return
	if not active or attack == null:
		return
	if custom_sprite != null and not attack.is_area():
		draw_set_transform(Vector2.ZERO, _spin())
		draw_texture_rect(custom_sprite, Rect2(Vector2.ONE * -attack.radius, Vector2.ONE * attack.radius * 2), false)
		draw_set_transform(Vector2.ZERO)
		return
	if attack.kind == HazardAttack.Kind.ROCKFALL:
		_draw_rockfall()
		return
	if attack.is_area():
		MarathonArt.projectile(self)
		return
	if attack.is_wall():
		_draw_wall()
		return
	var shape: int = shape_of(attack.kind)
	var spin: float = _spin()
	if body_texture != null:
		_draw_cached(Vector2.ZERO, spin, attack.radius)
	else:
		draw_set_transform(Vector2.ZERO, spin)
		paint_outline(self, shape, attack.radius)
		paint_body(self, shape, attack.source, attack.radius)
	draw_set_transform(Vector2.ZERO)

func _spin() -> float:
	match shape_of(attack.kind):
		Shape.BLADE: return attack.velocity.angle() if attack.motion == HazardAttack.Motion.LINEAR else (attack.point_at(minf(attack.lifetime, age + .02)) - attack.point_at(age)).angle()
		Shape.ROCK: return age * 3.0 * signf(attack.velocity.x if absf(attack.velocity.x) > 1.0 else 1.0)
		Shape.SPIKE: return 0.0
	return 0.0

## Whole-floor wind corridor / tidal wall: neon band, black rim, white core line.
func _draw_wall() -> void:
	var h: float = attack.row_height
	var w: float = maxf(14.0, attack.radius * 1.2)
	var color: Color = neon(attack.source)
	draw_rect(Rect2(-w * .5 - OUTLINE_WIDTH, -h * .5 - OUTLINE_WIDTH, w + OUTLINE_WIDTH * 2, h + OUTLINE_WIDTH * 2), OUTLINE)
	draw_rect(Rect2(-w * .5, -h * .5, w, h), color)
	draw_line(Vector2(0, -h * .5 + 4), Vector2(0, h * .5 - 4), CORE, 3.0)
	var dir: float = signf(attack.velocity.x)
	for i: int in range(5):
		var y: float = -h * .4 + i * h * .2
		draw_line(Vector2(-dir * (w + 26), y), Vector2(-dir * w * .5, y), Color(color, .55), 3.0)

## Ceiling collapse inside one room: amber rocks rain down for the zone's short life.
func _draw_rockfall() -> void:
	var color: Color = neon(attack.source)
	for world_area: Rect2 in attack.area_segments():
		var area: Rect2 = Rect2(world_area.position - global_position, world_area.size)
		draw_rect(area, Color(color, .14 * clampf((attack.lifetime - age) * 4.0, 0.0, 1.0)))
		for i: int in range(9):
			var x: float = area.position.x + 22.0 + fmod(i * 41.7, area.size.x - 44.0)
			var fall: float = fmod(age * (720.0 + i * 37.0) + i * 53.0, area.size.y)
			var r: float = 11.0 + i % 3 * 3.0
			var center: Vector2 = Vector2(x, area.position.y + fall)
			if body_texture != null:
				_draw_cached(center, age * 4.0 + i, r)
			else:
				draw_set_transform(center, age * 4.0 + i)
				paint_outline(self, Shape.ROCK, r)
				paint_body(self, Shape.ROCK, attack.source, r)
		draw_set_transform(Vector2.ZERO)
		draw_line(Vector2(area.position.x, area.end.y - 2), Vector2(area.end.x, area.end.y - 2), Color(CORE, .6), 2.0)

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
