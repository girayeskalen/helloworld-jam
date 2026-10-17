class_name HazardAttack
extends RefCounted
## One frozen trajectory shared by its warning and its pooled projectile.

enum Kind { GLASS, POT, CHAIR, WIND_BLADE, BRICK, CONCRETE, CHANDELIER, SHOCKWAVE, BOOK,
	WIND_ORB, SHARD, ROW_SWEEP, WARDROBE, KNIFE, PLATE, SAW, TOOL, TOY, DEBRIS,
	FLOOD_ZONE, TIDAL_WALL, WATER_BLADE, HYDRO_ORB, WATER_SHARD, HARPOON,
	FLOATING_DEBRIS, WHIRLPOOL, METEOR, FIRE_ZONE, FIREBALL, FIRE_DART, FIRE_BEAM, LOW_FLAME,
	STEAM_COLUMN }
enum Motion { LINEAR, ARC, WAVE, BOUNCE, SPIRAL, REFLECT, HELIX }
enum Pattern { FAN, FURNITURE, GROUND_WAVE, CLUSTER, FULL_ROW, ROOM_OBJECT, SPLINTER,
	VORTEX, CROSSFIRE, CORRIDOR_WAVE, RISING_FLOOD, BILATERAL_TIDE, HYDRO_BOUNCE,
	WHIRLPOOL_PULL, DEBRIS_CROSS, METEOR_SHOWER, NAPALM, DOUBLE_HELIX, EMBER_DETONATION, BACKDRAFT,
	STEAM_TSUNAMI, STEAM_BURST, FIRENADO, SEISMIC_TIDE, QUADRANT_SEAL, CATACLYSM_NOVA }
## The elemental seal is the one 0.8 s telegraph requested for the final boss.
const SEAL_WARNING: float = 0.8

var kind: Kind = Kind.GLASS
var motion: Motion = Motion.LINEAR
var origin: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity: float = 0.0
var amplitude: float = 0.0
var frequency: float = 9.0
var bounce_decay: float = 0.8
var lifetime: float = 2.0
var radius: float = 10.0
var damage: float = 12.0
var structure_damage: float = 0.0
var floor_index: int = 0
var floor_y: float = 0.0
var source: int = 0
var starts_slam: bool = false
var pattern: Pattern = Pattern.FAN
var splits: bool = false
var row_height: float = 164.0
var room_source: StringName = &""
# Spiral rings: polar path around origin, squashed into the floor's height band.
var spiral_angle: float = 0.0
var spiral_spin: float = 0.0
var spiral_speed: float = 0.0
var spiral_start: float = 0.0
## The first shot of a group also draws the group's shared emitter art.
var lead: bool = false
var warning_id: int = 0
var warning_duration: float = 0.65
var warning_elapsed: float = 0.0
var warning_confirmed: bool = false
## Area/path data is frozen with the trajectory; effects never retarget after warning.
var area: Rect2 = Rect2()
var safe_areas: Array[Rect2] = []
var warning_delay: float = 0.0
var path_times: PackedFloat32Array = PackedFloat32Array()
var path_points: PackedVector2Array = PackedVector2Array()
var cross_floor: bool = false
var leaves_fire: bool = false
var effect_strength: float = 0.0
var final_tuned: bool = false
var difficulty_damage_scale: float = 1.0
var warning_extension: float = 0.0
## Warning geometry is made once after freezing the path, then drawn in one batch.
var warning_lines: PackedVector2Array = PackedVector2Array()

func is_area() -> bool:
	return kind in [Kind.FLOOD_ZONE, Kind.FIRE_ZONE, Kind.WHIRLPOOL, Kind.STEAM_COLUMN]

func is_wall() -> bool:
	return kind in [Kind.ROW_SWEEP, Kind.TIDAL_WALL, Kind.FIRE_BEAM]

func minimum_warning() -> float:
	if pattern == Pattern.QUADRANT_SEAL: return SEAL_WARNING+warning_extension
	return (1.0 if pattern in [Pattern.FULL_ROW, Pattern.EMBER_DETONATION] or is_wall() or kind == Kind.FLOOD_ZONE else 0.55)+warning_extension

## Stretch time without changing the endpoint, bounce geometry or warning path.
func scale_travel_speed(factor: float) -> void:
	if is_area(): return
	velocity *= factor
	gravity *= factor*factor
	frequency *= factor
	bounce_decay *= factor
	spiral_spin *= factor
	spiral_speed *= factor
	lifetime /= factor
	for i: int in range(path_times.size()): path_times[i] /= factor

## Three real boundary reflections, followed by a short readable final travel.
## Storing the piecewise path makes warning, collision and split point identical.
func reflect_in(bounds: Rect2, bounces: int = 3) -> void:
	motion = Motion.REFLECT
	path_times = PackedFloat32Array([0.0])
	path_points = PackedVector2Array([origin])
	var p: Vector2 = origin
	var v: Vector2 = velocity
	var elapsed: float = 0.0
	for i: int in range(bounces):
		var tx: float = ((bounds.end.x if v.x > 0 else bounds.position.x) - p.x) / v.x if absf(v.x) > 0.001 else INF
		var ty: float = ((bounds.end.y if v.y > 0 else bounds.position.y) - p.y) / v.y if absf(v.y) > 0.001 else INF
		var step: float = maxf(0.001, minf(tx, ty))
		p += v * step
		elapsed += step
		path_times.append(elapsed)
		path_points.append(p)
		if tx <= ty + 0.00001: v.x = -v.x
		if ty <= tx + 0.00001: v.y = -v.y
	# Split before a possible fourth collision.
	var tx: float = ((bounds.end.x if v.x > 0 else bounds.position.x) - p.x) / v.x if absf(v.x) > 0.001 else INF
	var ty: float = ((bounds.end.y if v.y > 0 else bounds.position.y) - p.y) / v.y if absf(v.y) > 0.001 else INF
	var tail: float = minf(0.12, minf(tx, ty) * 0.5)
	lifetime = elapsed + maxf(0.001, tail)
	path_times.append(lifetime)
	path_points.append(p + v * maxf(0.001, tail))

func frozen_copy() -> HazardAttack:
	var copy: HazardAttack = HazardAttack.new()
	for field: String in ["kind", "motion", "origin", "velocity", "gravity", "amplitude", "frequency", "lifetime", "radius", "damage", "structure_damage", "floor_index", "floor_y", "source", "starts_slam", "pattern", "splits", "row_height", "room_source", "spiral_angle", "spiral_spin", "spiral_speed", "spiral_start", "lead"]:
		copy.set(field, get(field))
	copy.safe_areas.assign(safe_areas)
	copy.bounce_decay = bounce_decay
	for field: String in ["area", "warning_delay", "leaves_fire", "effect_strength", "cross_floor", "final_tuned", "difficulty_damage_scale", "warning_extension"]:
		copy.set(field, get(field))
	copy.path_times = path_times.duplicate()
	copy.path_points = path_points.duplicate()
	return copy

func point_at(seconds: float) -> Vector2:
	var point: Vector2 = origin + velocity * seconds
	if motion == Motion.REFLECT and path_times.size() > 1:
		for i: int in range(1, path_times.size()):
			if seconds <= path_times[i]:
				return path_points[i - 1].lerp(path_points[i], clampf((seconds - path_times[i - 1]) / (path_times[i] - path_times[i - 1]), 0.0, 1.0))
		return path_points[-1]
	elif motion == Motion.HELIX:
		point.y += (sin(seconds * frequency + spiral_angle) - sin(spiral_angle)) * amplitude
	elif motion == Motion.ARC:
		point.y += 0.5 * gravity * seconds * seconds
	elif motion == Motion.WAVE:
		point.y += sin(seconds * frequency) * amplitude
	elif motion == Motion.BOUNCE:
		# Analytic damped hops: warning and projectile sample exactly the same path.
		var cycle: float = seconds * frequency
		point.y = floor_y - radius - absf(sin(cycle * PI)) * amplitude * exp(-seconds * bounce_decay)
	elif motion == Motion.SPIRAL:
		# Rotating, expanding ring. Vertical reach saturates at `amplitude` so the
		# vortex never leaves its own floor, while the horizontal radius keeps growing.
		var reach: float = spiral_start + spiral_speed * seconds
		var angle: float = spiral_angle + spiral_spin * seconds
		point = origin + Vector2(cos(angle) * reach, sin(angle) * minf(reach * 0.55, amplitude))
	return point

func is_vertical_warning() -> bool:
	return kind in [Kind.BRICK, Kind.CONCRETE, Kind.CHANDELIER, Kind.WARDROBE]

func is_armed() -> bool:
	var required: float = minimum_warning()
	return warning_confirmed and warning_id > 0 and warning_duration >= required and warning_elapsed + .000001 >= warning_duration

## Equipment cuts holes out of a floor hazard without retargeting its frozen path.
func area_segments() -> Array[Rect2]:
	var pieces: Array[Rect2] = [area]
	for safe: Rect2 in safe_areas:
		var next: Array[Rect2] = []
		for piece: Rect2 in pieces:
			if not piece.intersects(safe):
				next.append(piece)
				continue
			if piece.position.x < safe.position.x:
				next.append(Rect2(piece.position,Vector2(safe.position.x-piece.position.x,piece.size.y)))
			if piece.end.x > safe.end.x:
				next.append(Rect2(Vector2(safe.end.x,piece.position.y),Vector2(piece.end.x-safe.end.x,piece.size.y)))
		pieces = next
	return pieces

func contains_area_point(point: Vector2) -> bool:
	for piece: Rect2 in area_segments():
		if piece.has_point(point): return true
	return false
