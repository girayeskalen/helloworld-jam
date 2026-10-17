class_name HazardAttack
extends RefCounted
## One frozen trajectory shared by its warning and its pooled projectile.

enum Kind { GLASS, POT, CHAIR, WIND_BLADE, BRICK, CONCRETE, CHANDELIER, SHOCKWAVE, BOOK,
	WIND_ORB, SHARD, ROW_SWEEP, WARDROBE, KNIFE, PLATE, SAW, TOOL, TOY, DEBRIS }
enum Motion { LINEAR, ARC, WAVE, BOUNCE, SPIRAL }
enum Pattern { FAN, FURNITURE, GROUND_WAVE, CLUSTER, FULL_ROW, ROOM_OBJECT, SPLINTER,
	VORTEX, CROSSFIRE, CORRIDOR_WAVE }

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

func frozen_copy() -> HazardAttack:
	var copy: HazardAttack = HazardAttack.new()
	for field: String in ["kind", "motion", "origin", "velocity", "gravity", "amplitude", "frequency", "lifetime", "radius", "damage", "structure_damage", "floor_index", "floor_y", "source", "starts_slam", "pattern", "splits", "row_height", "room_source", "spiral_angle", "spiral_spin", "spiral_speed", "spiral_start", "lead"]:
		copy.set(field, get(field))
	copy.bounce_decay = bounce_decay
	return copy

func point_at(seconds: float) -> Vector2:
	var point: Vector2 = origin + velocity * seconds
	if motion == Motion.ARC:
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
	var required: float = 1.0 if pattern == Pattern.FULL_ROW else 0.55
	return warning_confirmed and warning_id > 0 and warning_duration >= required and warning_elapsed + .000001 >= warning_duration
