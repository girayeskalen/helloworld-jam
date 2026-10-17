class_name TelegraphSystem
extends Node2D

signal attack_ready(attack: HazardAttack)
## A storm gust is not damage, but it is still announced before it pushes.
signal gust_ready(direction: float, strength: float, duration: float)

const MIN_WARNING: float = 0.55
const MAX_WARNING: float = 0.75
## Neon warning palette for the blackout: electric blue storm, ember/red quake.
const STORM_WARNING: Color = Color("62d0ff")
const QUAKE_WARNING: Color = Color("ff6a3a")
const STORM_ROW: Color = Color("7fe0ff")
const QUAKE_ROW: Color = Color("ff4a3a")
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

func warn_gust(area: Rect2, floor_lines: PackedFloat32Array, direction: float, strength: float, duration: float, seconds: float = 0.65) -> void:
	gust_area = area
	gust_floors = floor_lines
	gust_direction = signf(direction) if not is_zero_approx(direction) else 1.0
	gust_strength = strength
	gust_duration = duration
	gust_warning_total = clampf(seconds, MIN_WARNING, MAX_WARNING) + warning_bonus
	gust_warning_left = gust_warning_total
	gust_active_left = 0.0
	queue_redraw()

func warn(attack: HazardAttack, seconds: float = 0.65) -> int:
	# The trajectory cannot be retargeted after this copy is placed on screen.
	attack = attack.frozen_copy()
	attack.warning_duration = (1.0 if attack.minimum_warning() == 1.0 else clampf(seconds, MIN_WARNING, MAX_WARNING)) + warning_bonus
	attack.warning_elapsed = 0.0
	attack.warning_confirmed = false
	attack.warning_id = _next_id
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
	if attack.source >= 2: return Color("54e9dc") if attack.source == 2 else Color("ff9c48")
	if attack.pattern == HazardAttack.Pattern.FULL_ROW:
		return STORM_ROW if attack.source == 0 else QUAKE_ROW
	return STORM_WARNING if attack.source == 0 else QUAKE_WARNING

## Text for these warnings is drawn crisply in screen space by WorldLabels.
func _draw() -> void:
	_draw_gust()
	for attack: HazardAttack in pending:
		if attack.warning_delay > 0.0: continue
		var progress: float = clampf(attack.warning_elapsed / attack.warning_duration, 0, 1)
		var pulse: float = 0.65 + 0.35 * sin(progress * 26.0)
		var color: Color = warning_color(attack)
		color.a = 0.75 + progress * 0.25
		if attack.is_area():
			for segment: Rect2 in attack.area_segments():
				draw_rect(segment, Color(color,.10 + progress*.14))
				draw_rect(segment, color, false, 3.0)
				_dashes(segment.position, Vector2(segment.end.x, segment.position.y),color)
				_icon(segment.get_center()+Vector2(0,-32),color,pulse)
		elif attack.is_wall():
			var start: Vector2 = Vector2(minf(attack.origin.x, attack.point_at(attack.lifetime).x), attack.floor_y - attack.row_height)
			var size: Vector2 = Vector2(absf(attack.velocity.x * attack.lifetime), attack.row_height)
			draw_rect(Rect2(start, size), Color(color, .10 + .10 * progress))
			draw_rect(Rect2(start, size).grow(3), Color(color, 0.25 * pulse), false, 9.0)
			draw_rect(Rect2(start, size), Color(color, pulse), false, 3.2)
			_dashes(start + Vector2(0, size.y * .5), start + Vector2(size.x, size.y * .5), color)
			_icon(start + Vector2(size.x * .5, size.y * .70), color, pulse)
		elif attack.is_vertical_warning():
			var bottom: float = attack.floor_y - 4.0
			var top: float = bottom - 180.0
			var half_width: float = maxf(attack.radius + 12.0, 22.0)
			draw_rect(Rect2(attack.origin.x - half_width, top, half_width * 2, bottom - top), Color(color, 0.08 + progress * 0.12))
			CelArt.line(self, Vector2(attack.origin.x - half_width, top), Vector2(attack.origin.x - half_width, bottom), Color(color, 0.45), 2.6)
			CelArt.line(self, Vector2(attack.origin.x + half_width, top), Vector2(attack.origin.x + half_width, bottom), Color(color, 0.45), 2.6)
			_dashes(Vector2(attack.origin.x, top), Vector2(attack.origin.x, bottom), color)
			draw_set_transform(Vector2(attack.origin.x, bottom), 0, Vector2(1, 0.28))
			draw_arc(Vector2.ZERO, half_width + 5.0, 0, TAU, 32, Color(color, 0.3), 14.0, true)
			draw_arc(Vector2.ZERO, half_width + 5.0, 0, TAU, 32, color, 5.0, true)
			draw_set_transform(Vector2.ZERO)
			_icon(Vector2(attack.origin.x, top + 18), color, pulse)
		else:
			if attack.pattern == HazardAttack.Pattern.EMBER_DETONATION and attack.lead:
				draw_circle(attack.origin,20,Color("391810"))
				draw_arc(attack.origin,29,-PI/2,-PI/2+TAU*maxf(.01,progress),28,color,5.0)
				draw_circle(attack.origin,9,Color("fff1a2"))
			if attack.pattern == HazardAttack.Pattern.VORTEX and attack.lead:
				draw_vortex_eye(self, attack.origin, attack.warning_elapsed * 6.0, 0.35 + progress * 0.55, 0.4 + progress * 0.6)
			if attack.pattern == HazardAttack.Pattern.SPLINTER:
				for fragment: int in range(3):
					var p: Vector2 = attack.origin + Vector2((fragment - 1) * 11, -4 - fragment % 2 * 5)
					CelArt.poly(self, PackedVector2Array([p + Vector2(-5, 3), p + Vector2(0, -5), p + Vector2(6, 2)]), Color("8f8370"), 1.5)
			var previous: Vector2 = attack.origin
			for sample: int in range(1, 33):
				var next: Vector2 = attack.point_at(attack.lifetime * float(sample) / 32.0)
				_dashes(previous, next, color)
				previous = next
			if attack.kind == HazardAttack.Kind.WIND_BLADE:
				draw_line(attack.origin, attack.point_at(attack.lifetime), Color(color, 0.08), attack.radius * 2, true)
			if (attack.pattern not in [HazardAttack.Pattern.VORTEX,HazardAttack.Pattern.EMBER_DETONATION]) or attack.lead:
				_icon(attack.origin + Vector2(0, -31), color, pulse)

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

func _dashes(start: Vector2, end: Vector2, color: Color) -> void:
	var length: float = start.distance_to(end)
	var direction: Vector2 = start.direction_to(end)
	var cursor: float = 0.0
	var halo: Color = Color(color, color.a * 0.22)
	while cursor < length:
		var a: Vector2 = start + direction * cursor
		var b: Vector2 = start + direction * minf(cursor + 11, length)
		draw_line(a, b, halo, 8.0, true)
		draw_line(a, b, color, 3.2, true)
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
