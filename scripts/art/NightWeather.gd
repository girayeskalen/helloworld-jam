class_name NightWeather
extends Node2D
## Animated night layer behind the building: slanted downpour, drifting ash/embers and
## occasional cold lightning. MainGame reads `flash` to light the rooms for a moment.

@export var view_size: Vector2 = Vector2(1920, 1080)
@export var ground_y: float = 917.0
@export var rain_count: int = 260
@export var ash_count: int = 70
@export var rain_speed: float = 1500.0
@export var rain_slant: float = 0.32
## Seconds between ambient strikes; a visible storm boss shortens the wait.
@export var flash_interval: Vector2 = Vector2(5.0, 11.0)

var flash: float = 0.0
var storminess: float = 0.0
var flash_count: int = 0
var _clock: float = 0.0
var _next_flash: float = 3.0
var _flash_age: float = -1.0
var _flash_strength: float = 1.0
var _bolt: PackedVector2Array = PackedVector2Array()
var _branch: PackedVector2Array = PackedVector2Array()
var _drops: PackedVector3Array = PackedVector3Array()
var _ash: PackedVector3Array = PackedVector3Array()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = 7741
	for i: int in range(rain_count):
		_drops.append(Vector3(_rng.randf_range(-60.0, view_size.x + 60.0), _rng.randf_range(-60.0, ground_y), _rng.randf_range(0.7, 1.3)))
	for i: int in range(ash_count):
		_ash.append(Vector3(_rng.randf_range(0.0, view_size.x), _rng.randf_range(0.0, ground_y), _rng.randf_range(0.0, TAU)))

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	_clock += delta
	_next_flash -= delta * (1.0 + storminess * 1.4)
	if _next_flash <= 0.0:
		trigger_flash(_rng.randf_range(0.65, 1.0))
		_next_flash = _rng.randf_range(flash_interval.x, flash_interval.y)
	if _flash_age >= 0.0:
		_flash_age += delta
		flash = _flash_curve(_flash_age) * _flash_strength
		if _flash_age > 0.6:
			_flash_age = -1.0
			flash = 0.0
	queue_redraw()

func trigger_flash(strength: float = 1.0) -> void:
	_flash_age = 0.0
	_flash_strength = clampf(strength, 0.0, 1.0)
	flash = _flash_strength
	flash_count += 1
	# A forked bolt from the cloud deck toward the horizon.
	_bolt = PackedVector2Array()
	# Strike in the open sky beside the building so the bolt is never hidden behind it.
	var side: float = _rng.randf_range(0.02, 0.14) if _rng.randf() < 0.5 else _rng.randf_range(0.86, 0.98)
	var point: Vector2 = Vector2(view_size.x * side, -40.0)
	_bolt.append(point)
	while point.y < ground_y * 0.62:
		point += Vector2(_rng.randf_range(-60.0, 60.0), _rng.randf_range(40.0, 85.0))
		_bolt.append(point)
	var fork: int = int(_bolt.size() * 0.4)
	_branch = PackedVector2Array([_bolt[fork]])
	point = _bolt[fork]
	for i: int in range(4):
		point += Vector2(_rng.randf_range(20.0, 70.0) * (1.0 if fork % 2 == 0 else -1.0), _rng.randf_range(30.0, 60.0))
		_branch.append(point)

## Bright strike, quick fade, then a second strobe ~0.18 s later.
func _flash_curve(age: float) -> float:
	return clampf(exp(-age * 9.0) + 0.7 * exp(-pow((age - 0.18) * 25.0, 2.0)), 0.0, 1.0)

func _draw() -> void:
	var w: float = view_size.x + 120.0
	var span: float = ground_y + 60.0
	if flash > 0.01:
		draw_rect(Rect2(-60, -60, w, view_size.y + 120), Color(0.55, 0.65, 0.85, flash * 0.3))
		if flash > 0.25:
			for stroke: PackedVector2Array in [_bolt, _branch]:
				draw_polyline(stroke, Color(0.55, 0.72, 1.0, flash * 0.35), 20.0, true)
				draw_polyline(stroke, Color(0.92, 0.96, 1.0, flash), 6.0, true)
	var rain: Color = Color(0.42, 0.52, 0.66, 0.30 + flash * 0.35)
	var slant: Vector2 = Vector2(rain_slant, 1.0).normalized()
	for drop: Vector3 in _drops:
		var fall: float = _clock * rain_speed * drop.z
		var y: float = fposmod(drop.y + 60.0 + fall, span) - 60.0
		var x: float = fposmod(drop.x + 60.0 + fall * rain_slant, w) - 60.0
		draw_line(Vector2(x, y), Vector2(x, y) + slant * (22.0 + drop.z * 10.0), rain, 2.6)
	for mote: Vector3 in _ash:
		var drift: float = _clock * (28.0 + fmod(mote.z * 13.0, 22.0))
		var x: float = fposmod(mote.x + drift + sin(_clock * 1.3 + mote.z) * 18.0, view_size.x)
		var y: float = fposmod(mote.y + _clock * 16.0 + cos(_clock * 0.9 + mote.z) * 10.0, ground_y)
		var ember: bool = int(mote.z * 10.0) % 4 == 0
		var color: Color = Color(0.86, 0.36, 0.14, 0.55 + 0.35 * sin(_clock * 6.0 + mote.z)) if ember else Color(0.40, 0.42, 0.46, 0.55)
		draw_rect(Rect2(x, y, 5.1, 5.1), color)
