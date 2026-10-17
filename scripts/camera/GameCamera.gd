class_name GameCamera
extends Camera2D

@export var max_intensity: float = 28.0
var _remaining: float = 0.0
var _duration: float = 0.0
var _intensity: float = 0.0
var _elapsed: float = 0.0
var cinematic_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	make_current()

func apply_shake(intensity: float, duration: float) -> void:
	if intensity <= 0.0 or duration <= 0.0:
		return
	if _remaining > 0 and intensity < _intensity * _remaining / _duration:
		return
	_intensity = clampf(intensity, 0.0, max_intensity)
	_duration = duration
	_remaining = duration
	_elapsed = 0.0

## Current decayed shake amplitude in world units (0 when calm). Drives lamp sway.
func shake_strength() -> float:
	if _remaining <= 0.0 or _duration <= 0.0:
		return 0.0
	return _intensity * pow(_remaining / _duration, 2.0)

func clear_shake() -> void:
	_remaining = 0.0
	offset = Vector2.ZERO

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_shake"):
		apply_shake(17.0, 0.65)
	if _remaining <= 0.0:
		offset = cinematic_offset
		return
	_remaining = maxf(0.0, _remaining - delta)
	_elapsed += delta
	var decay: float = pow(_remaining / _duration, 2.0)
	offset = cinematic_offset + Vector2(sin(_elapsed * 93.0), cos(_elapsed * 117.0)) * _intensity * decay
