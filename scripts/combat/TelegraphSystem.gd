class_name TelegraphSystem
extends Node2D

signal attack_ready(attack: HazardAttack)
## A storm gust is not damage, but it is still announced before it pushes.
signal gust_ready(direction: float, strength: float, duration: float)

const MIN_WARNING: float = 0.55
const MAX_WARNING: float = 0.75
## Step 7 neon palette, shared with the projectiles: cyan storm, amber quake, blue flood.
const STORM_WARNING: Color = Color("00f0ff")
const QUAKE_WARNING: Color = Color("ff9500")
const FLOOD_WARNING: Color = Color("2b7fff")
const STORM_ROW: Color = Color("00f0ff")
const QUAKE_ROW: Color = Color("ff9500")
## Safe-floor roulette corridors: turquoise wind with red danger edges.
const ROULETTE_EDGE: Color = Color("ff3b4e")
const FLASH: Color = Color("ffffff")
const GUST: Color = Color("a8ecff")
@export var custom_sprite: Texture2D
var pending: Array[HazardAttack] = []
var warning_bonus: float = 0.0
var gust_warning_left: float = 0.0
var gust_warning_total: float = 0.65
var gust_active_left: float = 0.0
var gust_direction: float = 1.0
var gust_strength: float = 0.0
var gust_duration: float = 0.0
var gust_area: Rect2 = Rect2()
var gust_floors: PackedFloat32Array = PackedFloat32Array()
var _gust_clock: float = 0.0
var _next_id: int = 1

func _ready() -> void:
	process_physics_priority = 10

func warn_gust(area: Rect2, floor_lines: PackedFloat32Array, direction: float, strength: float, duration: float, seconds: float = 0.65, extension: float = 0.0) -> void:
	gust_area = area
	gust_floors = floor_lines
	gust_direction = signf(direction) if not is_zero_approx(direction) else 1.0
	gust_strength = strength
	gust_duration = duration
	gust_warning_total = clampf(seconds, MIN_WARNING, MAX_WARNING) + warning_bonus + extension
	gust_warning_left = gust_warning_total
	gust_active_left = 0.0
	queue_redraw()

func warn(attack: HazardAttack, seconds: float = 0.65) -> int:
	# The trajectory cannot be retargeted after this copy is placed on screen.
	attack = attack.frozen_copy()
	# Step 7: every ordinary telegraph is exactly STANDARD_WARNING (0.55 s), whatever
	# the pattern asked for. Whole-floor/area hazards keep their longer minimum
	# (1.0 flood/wall, 0.8 seal, 0.65 safe-floor roulette); radar/final extras add on.
	var required: float = attack.minimum_warning()-attack.warning_extension
	var base: float = required if required > HazardAttack.STANDARD_WARNING + 0.0001 else HazardAttack.STANDARD_WARNING
	attack.warning_duration = base + warning_bonus + attack.warning_extension
	attack.warning_elapsed = 0.0
	attack.warning_confirmed = false
	attack.warning_id = _next_id
	if not attack.is_area() and not attack.is_wall() and not attack.is_vertical_warning():
		# One thin continuous laser along the frozen path (sampled once, drawn in one call).
		for sample: int in range(0,25):
			attack.warning_lines.append(attack.point_at(attack.lifetime*float(sample)/24.0))
	_next_id += 1
	pending.append(attack)
	queue_redraw()
	return attack.warning_id

func clear() -> void:
	pending.clear()
	gust_warning_left = 0.0
	gust_active_left = 0.0
	queue_redraw()

func _physics_process(delta: float) -> void:
	_gust_clock += delta
	if gust_warning_left > 0.0:
		gust_warning_left = maxf(0.0, gust_warning_left - delta)
		if gust_warning_left <= 0.000001:
			gust_warning_left = 0.0
			gust_active_left = gust_duration
			gust_ready.emit(gust_direction, gust_strength, gust_duration)
	elif gust_active_left > 0.0:
		gust_active_left = maxf(0.0, gust_active_left - delta)
	# Iterate a copy: a phase change triggered by a callback can safely clear pending.
	for attack: HazardAttack in pending.duplicate():
		if not pending.has(attack):
			continue
		var warning_delta: float = delta
		if attack.warning_delay > 0.0:
			warning_delta = maxf(0.0, delta - attack.warning_delay)
			attack.warning_delay = maxf(0.0, attack.warning_delay - delta)
			if warning_delta <= 0.0: continue
		attack.warning_elapsed += warning_delta
		if attack.warning_elapsed + 0.000001 >= attack.warning_duration:
			pending.erase(attack)
			attack.warning_confirmed = true
			attack_ready.emit(attack)
	queue_redraw()

static func warning_color(attack: HazardAttack) -> Color:
	return [STORM_WARNING, QUAKE_WARNING, FLOOD_WARNING, QUAKE_WARNING][clampi(attack.source, 0, 3)]

## The last FLASH_WINDOW seconds of every telegraph flash white: "ŞİMDİ KAÇ!".
static func is_flashing(attack: HazardAttack) -> bool:
	return attack.warning_delay <= 0.0 and attack.warning_duration - attack.warning_elapsed <= HazardAttack.FLASH_WINDOW + 0.000001

## Clean warning language: thin laser lines for paths, flat fills for floors, rooms
## and ceiling drops. No circles or icons; the final 0.12 s turns everything white.
## Text for these warnings is drawn crisply in screen space by WorldLabels.
func _draw() -> void:
	_draw_gust()
	for attack: HazardAttack in pending:
		if attack.warning_delay > 0.0: continue
		var progress: float = clampf(attack.warning_elapsed / attack.warning_duration, 0, 1)
		var flash: bool = is_flashing(attack)
		var color: Color = warning_color(attack)
		var edge: Color = FLASH if flash else color
		if attack.is_area():
			for segment: Rect2 in attack.area_segments():
				draw_rect(segment, Color(FLASH, .32) if flash else Color(color, .10 + progress * .16))
				draw_line(segment.position, Vector2(segment.end.x, segment.position.y), edge, 2.0)
				draw_line(Vector2(segment.position.x, segment.end.y), segment.end, edge, 2.0)
		elif attack.is_wall():
			var start: Vector2 = Vector2(minf(attack.origin.x, attack.point_at(attack.lifetime).x), attack.floor_y - attack.row_height)
			var band: Rect2 = Rect2(start, Vector2(absf(attack.velocity.x * attack.lifetime), attack.row_height))
			var roulette: bool = attack.pattern == HazardAttack.Pattern.SAFE_FLOOR
			draw_rect(band, Color(FLASH, .30) if flash else Color(color, .12 + progress * .14))
			var rim: Color = FLASH if flash else (ROULETTE_EDGE if roulette else color)
			draw_line(band.position, Vector2(band.end.x, band.position.y), rim, 3.0)
			draw_line(Vector2(band.position.x, band.end.y), band.end, rim, 3.0)
			# Direction ticks: the corridor sweeps from the origin side.
			var dir: float = signf(attack.velocity.x)
			for i: int in range(6):
				var x: float = band.position.x + band.size.x * (i + .5) / 6.0
				var y: float = band.get_center().y
				draw_line(Vector2(x - dir * 10, y - 9), Vector2(x, y), Color(edge, .7), 2.0)
				draw_line(Vector2(x - dir * 10, y + 9), Vector2(x, y), Color(edge, .7), 2.0)
		elif attack.is_vertical_warning():
			var bottom: float = attack.floor_y - 4.0
			var top: float = bottom - 176.0
			var half_width: float = maxf(attack.radius + 8.0, 18.0)
			draw_rect(Rect2(attack.origin.x - half_width, top, half_width * 2, bottom - top), Color(FLASH, .30) if flash else Color(color, .10 + progress * .16))
			draw_line(Vector2(attack.origin.x, top), Vector2(attack.origin.x, bottom), edge, 2.0)
			draw_line(Vector2(attack.origin.x - half_width, bottom), Vector2(attack.origin.x + half_width, bottom), edge, 3.0)
		elif attack.warning_lines.size() >= 2:
			draw_polyline(attack.warning_lines, Color(edge, .22), 7.0)
			draw_polyline(attack.warning_lines, edge, 2.0)
			if attack.lead:
				# A tiny emitter mark where the volley is born (no rings, no icons).
				var o: Vector2 = attack.origin
				draw_colored_polygon(PackedVector2Array([o + Vector2(0, -7), o + Vector2(7, 0), o + Vector2(0, 7), o + Vector2(-7, 0)]), edge)

func _draw_gust() -> void:
	if gust_warning_left <= 0.0 and gust_active_left <= 0.0:
		return
	var tint: Color = GUST
	var left: float = gust_area.position.x
	var width: float = gust_area.size.x
	if gust_warning_left > 0.0:
		# Chevrons point the way the storm will push; nothing moves the player yet.
		var progress: float = 1.0 - gust_warning_left / gust_warning_total
		for y: float in gust_floors:
			var row: float = y - 104.0
			for i: int in range(int(width / 150.0)):
				var x: float = left + 60.0 + i * 150.0 + progress * 40.0 * gust_direction
				var a: Color = Color(tint, 0.25 + 0.5 * progress)
				for k: int in range(2):
					var tip: Vector2 = Vector2(x + k * 16.0 * gust_direction, row)
					var chevron: PackedVector2Array = PackedVector2Array([tip + Vector2(-12 * gust_direction, -14), tip, tip + Vector2(-12 * gust_direction, 14)])
					draw_polyline(chevron, Color(tint, a.a * 0.3), 10.0, true)
					draw_polyline(chevron, a, 4.0, true)
		return
	var fade: float = clampf(gust_active_left / 0.4, 0.0, 1.0)
	for y: float in gust_floors:
		for i: int in range(13):
			var travel: float = fmod(i * 173.0 + _gust_clock * 760.0, width)
			var x: float = left + (travel if gust_direction > 0 else width - travel)
			var row: float = y - 30.0 - float((i * 37) % 140)
			var tail: Vector2 = Vector2(x - gust_direction * (70.0 + i % 3 * 24.0), row)
			draw_line(Vector2(x, row), tail, Color(CelArt.INK, 0.25 * fade), 6.0, true)
			draw_line(Vector2(x, row), tail, Color(Color("dff1ee"), 0.75 * fade), 3.0, true)

## Shared mini-tornado eye for the vortex ring warning and its live lead projectile.
static func draw_vortex_eye(canvas: CanvasItem, center: Vector2, spin: float, scale: float, alpha: float) -> void:
	for layer: int in range(6):
		var y: float = center.y + (-54.0 + layer * 22.0) * scale
		var width: float = (44.0 - layer * 6.5) * scale
		var sway: float = sin(spin * 0.6 + layer * 0.9) * 5.0 * scale
		var color: Color = Color("2f4250") if layer % 2 == 0 else Color("3f5664")
		CelArt.ellipse(canvas, Vector2(center.x + sway, y), Vector2(width, 8.0 * scale), Color(color, alpha), 2.0)
		canvas.draw_line(Vector2(center.x + sway - width * 0.6, y - 2), Vector2(center.x + sway + width * 0.5, y - 4), Color(STORM_WARNING, alpha * 0.8), 2.6, true)
	for ring: int in range(3):
		var r: float = (30.0 + ring * 16.0) * scale
		canvas.draw_arc(center, r, spin + ring * 2.1, spin + ring * 2.1 + PI * 1.1, 18, Color(STORM_WARNING, alpha * 0.3), 8.0, true)
		canvas.draw_arc(center, r, spin + ring * 2.1, spin + ring * 2.1 + PI * 1.1, 18, Color(Color("d8f4ff"), alpha * 0.8), 2.6, true)

## Final-boss emitter: an element orb whose ring fills during its exact warning.
static func draw_element_orb(canvas: CanvasItem, center: Vector2, color: Color, progress: float, clock: float) -> void:
	canvas.draw_circle(center, 31.0, Color(color, 0.12 + progress * 0.18))
	canvas.draw_circle(center, 21.0, Color("140f14"))
	canvas.draw_arc(center, 21.0, 0, TAU, 24, CelArt.INK, 4.0)
	canvas.draw_arc(center, 28.0, -PI / 2, -PI / 2 + TAU * maxf(0.01, progress), 28, color, 5.0)
	canvas.draw_circle(center, 7.0 + progress * 8.0, color.lightened(0.45))
	for i: int in range(4):
		var p: Vector2 = center + Vector2.from_angle(clock * 3.0 + i * TAU / 4) * 40.0
		canvas.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -6), p + Vector2(6, 0), p + Vector2(0, 6), p + Vector2(-6, 0)]), Color(color, 0.85))

func _dashes(start: Vector2, end: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	_append_dashes(points,start,end)
	if not points.is_empty(): draw_multiline(points,color,3.2)

static func _append_dashes(points: PackedVector2Array, start: Vector2, end: Vector2) -> void:
	var length: float = start.distance_to(end)
	var direction: Vector2 = start.direction_to(end)
	var cursor: float = 0.0
	while cursor < length:
		var a: Vector2 = start + direction * cursor
		var b: Vector2 = start + direction * minf(cursor + 11, length)
		points.append(a)
		points.append(b)
		cursor += 18.0

## Diamond with a drawn "!" glyph (no font), crisp on the low-res pixel grid.
func _icon(point: Vector2, color: Color, pulse: float) -> void:
	var diamond: PackedVector2Array = PackedVector2Array([point + Vector2(0, -17), point + Vector2(17, 0), point + Vector2(0, 17), point + Vector2(-17, 0)])
	draw_colored_polygon(diamond, Color("150d10"))
	var closed: PackedVector2Array = diamond.duplicate()
	closed.append(diamond[0])
	draw_polyline(closed, Color(color, 0.3), 8.0, true)
	draw_polyline(closed, Color(color, pulse), 3.0, true)
	draw_rect(Rect2(point + Vector2(-2.6, -10), Vector2(5.2, 12)), Color(color, pulse))
	draw_rect(Rect2(point + Vector2(-2.6, 4.5), Vector2(5.2, 5.2)), Color(color, pulse))
