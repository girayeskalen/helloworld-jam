class_name SiegePlayer
extends CharacterBody2D

signal dash_started
signal floor_transition_started(target_floor: int)
signal floor_changed(floor_index: int)
signal damaged(remaining_health: float)
## Audio/feedback hooks: a ground or top-floor air jump, and a landing (0..1 impact).
signal jumped(air: bool)
signal landed(impact: float)
## Step 7 graze reward (dash energy) was granted.
signal grazed(world_position: Vector2)
## Çök-Kapan-Tutun: C was pressed on the floor (drop, cover the head, hold on).
signal cover_started
## A tremor blocked a floor change ("sarsıntıda merdivene koşma").
signal stair_blocked

@export var custom_sprite: Texture2D
@export var sprite_size: Vector2 = Vector2(64, 88)
## Step 2.7: 30% faster than the original 310 px/s, with snappy response.
@export var run_speed: float = 403.0
@export var acceleration: float = 9000.0
@export var braking: float = 7600.0
## Reversing direction skips the slow-down entirely (Celeste-style turn).
@export var turn_acceleration: float = 16000.0
@export var dash_speed: float = 1150.0
## Base dash invulnerability stays 0.25 s, including the longer grapple dash.
@export var dash_duration: float = 0.25
@export var dash_cost: float = 32.0
## Dash energy granted by one graze, and the minimum gap between two rewards.
const GRAZE_ENERGY: float = 25.0
const GRAZE_COOLDOWN: float = 0.12
var _graze_cooldown: float = 0.0
@export var dash_cooldown: float = 0.304
@export var max_health: float = 100.0
## A ground jump stays inside the current room (apex ~115 px under a 200 px ceiling).
@export var jump_speed: float = 625.0
@export var gravity: float = 1700.0
@export var coyote_time: float = 0.1
@export var fast_fall_speed: float = 1100.0
## Highest the feet may rise above the current floor; the head stays below the slab.
@export var ceiling_clearance: float = 116.0
## 2x W floor jump: launch so the arc peaks this far above the upper floor, then
## re-arm that floor's collision and fall onto it under normal gravity.
@export var floor_jump_apex: float = 32.0
## Stronger gravity while launching keeps the rise punchy (~0.3 s) yet parabolic.
@export var floor_jump_gravity: float = 4200.0
@export var floor_down_duration: float = 0.11
@export var wind_response: float = 620.0
@export var beam_length: float = 380.0
@export var beam_spread: float = 0.30

var building: ApartmentBuilding
var mechanics: SiegeMechanics
var energy_regen_multiplier: float = 1.0
var health: float = 100.0
var controls_locked: bool = false
## Trailer-only safety net (scenes/Trailer.tscn): hazards deal no damage while true;
## grazes still count. The game itself never sets it.
var trailer_guard: bool = false
var grapple_enabled: bool = false
var hazard_drag: float = 0.0
var hazard_pull: float = 0.0
var speed_boost: float = 0.0
var _ghost_phasing: bool = false
var repair_shield: float = 0.0
var stamina: float = 100.0
var current_floor: int = 0
var dash_remaining: float = 0.0
var hit_invulnerability: float = 0.0
var previous_position: Vector2 = Vector2.ZERO
var dashing_this_tick: bool = false
var is_dashing: bool:
	get:
		return dash_remaining > 0.0
var invulnerable: bool:
	get:
		return is_dashing or hit_invulnerability > 0.0 or repair_shield > 0.0 or (mechanics != null and mechanics.floor_guard)
## True during the short scripted phase through a floor slab (double jump up / S down).
var is_shifting: bool = false
## Holding C on the floor: crouched with arms over the helmet, not moving.
var covering: bool = false
## A tremor is shaking the building: slow, unsteady steps and no floor changes.
var shaking: bool = false
## Hazırlık work animation (bolting, turning a valve): brief crouch, no movement.
var work_time: float = 0.0
const SHAKE_SPEED: float = 0.45
var shift_direction: int = 0
## Current horizontal storm drift in px/s; input and dash fight against it.
var wind_velocity: float = 0.0
var facing: float = 1.0
## Squash & stretch (x, y) that springs back to (1, 1); lean is the run tilt in radians.
var visual_scale: Vector2 = Vector2.ONE
var lean: float = 0.0
## 0 grounded .. 1 fully airborne pose (tucked legs, raised arms).
var air_pose: float = 0.0
var gear_offset: Vector2 = Vector2.ZERO
var _gear_velocity: Vector2 = Vector2.ZERO
var _cape: Vector2 = Vector2(-8, 14)
var _clock: float = 0.0
var _was_on_floor: bool = true
var _dash_direction: Vector2 = Vector2.RIGHT
var _coyote_remaining: float = 0.0
var _jump_buffer: float = 0.0
var _air_dash_used: bool = false
var _air_jump_used: bool = false
var _fast_falling: bool = false
var _cooldown: float = 0.0
var _regen_delay: float = 0.0
var _shift_elapsed: float = 0.0
var _shift_duration: float = 0.2
var _shift_start_y: float = 0.0
var _shift_end_y: float = 0.0
var _shift_slab_y: float = 0.0
var _slab_dust_done: bool = false
var _target_floor: int = 0
## Upper floor being jumped onto (its slab ignores us until the apex), or -1.
var _boost_floor: int = -1
var _wind_target: float = 0.0
var _wind_left: float = 0.0
var _stride: float = 0.0
var _ghost_clock: float = 0.0
var _dust_clock: float = 0.0
var _ghosts: Array[Dictionary] = []
var _dust: Array[Dictionary] = []
var _beam: Node2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 5.0
	health = max_health
	var shape: CapsuleShape2D = CapsuleShape2D.new()
	shape.radius = 12.0
	shape.height = 48.0
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "BodyCollision"
	collision.shape = shape
	collision.position = Vector2(0, -24)
	add_child(collision)
	# Helmet lamp: additive cone drawn just behind the body, above the dark rooms.
	_beam = Node2D.new()
	_beam.name = "HelmetBeam"
	_beam.show_behind_parent = true
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_beam.material = additive
	_beam.draw.connect(_draw_beam)
	add_child(_beam)

func _physics_process(delta: float) -> void:
	previous_position = global_position
	if controls_locked:
		dashing_this_tick = false
		return
	speed_boost = maxf(0.0, speed_boost - delta)
	repair_shield = maxf(0.0, repair_shield - delta)
	dashing_this_tick = is_dashing
	_clock += delta
	hit_invulnerability = maxf(0.0, hit_invulnerability - delta)
	_graze_cooldown = maxf(0.0, _graze_cooldown - delta)
	if hit_invulnerability < 0.00001:
		hit_invulnerability = 0.0
	self_modulate.a = 0.3 if hit_invulnerability > 0 and int(hit_invulnerability * 16) % 2 == 0 else 1.0
	_update_effects(delta)
	_update_wind(delta)
	_cooldown = maxf(0.0, _cooldown - delta)
	_regen_delay = maxf(0.0, _regen_delay - delta)
	if _regen_delay <= 0.0 and not is_dashing:
		stamina = minf(100.0, stamina + 38.0 * delta * energy_regen_multiplier)
	_beam.queue_redraw()
	if health <= 0:
		velocity = Vector2.ZERO
		queue_redraw()
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	var want_cover: bool = InputMap.has_action(&"cover") and Input.is_action_pressed(&"cover") and is_on_floor() and not is_shifting and not is_dashing and _boost_floor < 0 and not Input.is_action_just_pressed("dash")
	if want_cover != covering:
		covering = want_cover
		if covering:
			cover_started.emit()
			visual_scale = Vector2(1.2, 0.78)
	if covering or work_time > 0.0:
		work_time = maxf(0.0, work_time - delta)
		velocity.x = move_toward(velocity.x, 0.0, braking * delta)
		velocity.y = minf(velocity.y + gravity * delta, fast_fall_speed)
		move_and_slide()
		_sync_floor()
		_update_pose(delta)
		queue_redraw()
		return
	if not is_zero_approx(direction):
		facing = signf(direction)
	if is_shifting and shift_direction < 0:
		_update_shift(delta, direction)
		_update_pose(delta)
		queue_redraw()
		return
	var boosting: bool = _boost_floor >= 0
	if is_on_floor() and not is_dashing and not boosting:
		_coyote_remaining = coyote_time
		_air_dash_used = false
		_air_jump_used = false
		_fast_falling = false
	else:
		_coyote_remaining = maxf(0.0, _coyote_remaining - delta)
	_jump_buffer = maxf(0.0, _jump_buffer - delta)
	if Input.is_action_just_pressed("dash"):
		try_dash(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	if not is_dashing and not boosting:
		if Input.is_action_just_pressed("move_down") and _press_down():
			_update_pose(delta)
			queue_redraw()
			return
		if Input.is_action_just_pressed("jump"):
			if not try_jump():
				try_air_jump()
		elif _jump_buffer > 0.0:
			try_jump()
		boosting = _boost_floor >= 0
	if is_dashing:
		dashing_this_tick = true
		velocity = _dash_direction * dash_speed * (1.6 if grapple_enabled else 1.0)
		_ghost_clock -= delta
		if _ghost_clock <= 0.0:
			_ghosts.append({"position": global_position, "facing": facing, "life": 0.22, "roll": 1.0 - dash_remaining / dash_duration, "tint": Color(0.58, 0.85, 0.74)})
			_ghost_clock = 0.03
		dash_remaining = maxf(0.0, dash_remaining - delta)
		if dash_remaining < 0.00001:
			dash_remaining = 0.0
	else:
		velocity.x = _run_velocity(direction, delta)
		# Releasing W shortens a ground jump, never the floor-jump launch.
		if not boosting and velocity.y < -270.0 and not Input.is_action_pressed("jump"):
			velocity.y = -270.0
		velocity.y = minf(velocity.y + (floor_jump_gravity if boosting else gravity) * delta, fast_fall_speed)
		if _fast_falling:
			velocity.y = fast_fall_speed
	if absf(velocity.x) > 20.0:
		_stride += delta * (20.0 if is_dashing else 6.0 + 14.0 * minf(1.3, absf(velocity.x) / run_speed))
		_dust_clock -= delta
		if _dust_clock <= 0.0 and is_on_floor():
			_emit_dust()
			_dust_clock = 0.025 if is_dashing else 0.09
	else:
		_stride = move_toward(_stride, 0.0, delta * 12.0)
	var falling: float = velocity.y
	if grapple_enabled and dashing_this_tick:
		_ghost_phasing = true
		collision_mask = 0
	move_and_slide()
	if _ghost_phasing:
		global_position.x = clampf(global_position.x, building.interior_left(), building.interior_right())
		global_position.y = clampf(global_position.y, building.floor_y(3) - ceiling_clearance, building.floor_y(0) - 0.5)
		current_floor = clampi(int(floor((building.floor_y(0) - global_position.y) / building.floor_height)), 0, 3)
		if not is_dashing:
			# Resolve an end point inside a slab into the room below it before collisions return.
			global_position.y = maxf(global_position.y, building.floor_y(current_floor) - ceiling_clearance)
			collision_mask = 1
			_ghost_phasing = false
	if _boost_floor >= 0:
		_update_floor_jump(delta)
	if not _ghost_phasing: _apply_room_ceiling()
	_sync_floor()
	# Landing squash scales with how hard we hit the floor.
	if is_on_floor() and not _was_on_floor and falling > 150.0:
		var impact: float = clampf(falling / fast_fall_speed, 0.25, 1.0)
		visual_scale = Vector2(1.0 + 0.32 * impact, 1.0 - 0.3 * impact)
		_burst(Vector2.ZERO, 6)
		landed.emit(impact)
	_was_on_floor = is_on_floor()
	_update_pose(delta)
	queue_redraw()

## Snappy run: near-instant acceleration and a dedicated turn-around rate.
func _run_velocity(direction: float, delta: float) -> float:
	var target: float = direction * run_speed * (1.3 if speed_boost > 0.0 else 1.0) * (SHAKE_SPEED if shaking else 1.0) * (1.0 - hazard_drag) + wind_velocity + hazard_pull
	var rate: float = acceleration if direction != 0.0 else braking
	if direction != 0.0 and absf(velocity.x) > 20.0 and signf(direction) != signf(velocity.x):
		rate = turn_acceleration
	return move_toward(velocity.x, target, rate * delta)

func _update_pose(delta: float) -> void:
	var desired: Vector2 = Vector2(clampf(-velocity.x*.007,-4,4),clampf(-velocity.y*.004,-3,4))
	_gear_velocity += ((desired-gear_offset)*140-_gear_velocity*18)*delta
	gear_offset += _gear_velocity*delta
	var rest: Vector2 = Vector2(1.16, 0.64) if covering else (Vector2(1.08, 0.84) if work_time > 0.0 else Vector2.ONE)
	visual_scale = visual_scale.lerp(rest, 1.0 - exp(-13.0 * delta))
	var grounded: bool = is_on_floor() and not is_shifting
	var target_lean: float = 0.0
	if not is_dashing:
		target_lean = clampf(velocity.x / run_speed, -1.3, 1.3) * (0.17 if grounded else 0.08)
	lean = lerpf(lean, target_lean, 1.0 - exp(-16.0 * delta))
	air_pose = move_toward(air_pose, 0.0 if grounded else 1.0, delta * 8.0)
	var cape_target: Vector2 = Vector2(clampf(-velocity.x * 0.045, -34.0, 34.0) - facing * 8.0, clampf(14.0 - velocity.y * 0.02, -16.0, 30.0))
	_cape = _cape.lerp(cape_target, 1.0 - exp(-10.0 * delta))

## Ground jump only: coyote window or standing on a floor.
func try_jump() -> bool:
	if health <= 0 or is_dashing or is_shifting or _coyote_remaining <= 0.0:
		if Input.is_action_just_pressed("jump") and _air_jump_used:
			_jump_buffer = 0.1
		return false
	velocity.y = -jump_speed
	_coyote_remaining = 0.0
	_jump_buffer = 0.0
	_fast_falling = false
	visual_scale = Vector2(0.78, 1.26)
	_emit_dust()
	jumped.emit(false)
	return true

## The second W in the air: phase up one floor, or a plain air jump on the top floor.
func try_air_jump() -> bool:
	if health <= 0 or is_dashing or is_shifting or _air_jump_used or is_on_floor() or _coyote_remaining > 0.0:
		return false
	_air_jump_used = true
	_jump_buffer = 0.0
	if building != null and current_floor < building.floor_count - 1:
		return try_floor_shift(1)
	velocity.y = -jump_speed * 0.9
	_fast_falling = false
	visual_scale = Vector2(0.8, 1.22)
	_burst(Vector2(0, -6), 8)
	jumped.emit(true)
	return true

func _press_down() -> bool:
	if try_floor_shift(-1):
		return true
	if not is_on_floor():
		_fast_falling = true
		visual_scale = Vector2(0.84, 1.18)
	return false

## Up: a physical launch through the upper slab (see _start_floor_jump).
## Down: a short scripted phase through the current slab.
func try_floor_shift(direction: int) -> bool:
	if building == null or health <= 0 or is_shifting or is_dashing:
		return false
	if shaking:
		stair_blocked.emit()
		return false
	var target: int = current_floor + direction
	if target < 0 or target >= building.floor_count:
		return false
	if direction > 0:
		return _start_floor_jump(target)
	is_shifting = true
	shift_direction = direction
	_target_floor = target
	_shift_elapsed = 0.0
	_shift_duration = floor_down_duration
	_shift_start_y = global_position.y
	_shift_end_y = building.floor_y(target) - 0.5
	# The slab being crossed: the current deck when dropping.
	_shift_slab_y = building.floor_y(current_floor) + 10.0
	_slab_dust_done = false
	_air_jump_used = true
	_fast_falling = false
	_coyote_remaining = 0.0
	_jump_buffer = 0.0
	velocity.y = 0.0
	visual_scale = Vector2(0.72, 1.34)
	# Phasing never touches floor/wall colliders, so it cannot snag mid-slab.
	collision_mask = 0
	_burst(Vector2.ZERO, 9)
	floor_transition_started.emit(target)
	return true

## Launch velocity whose discrete (60 Hz) arc peaks exactly floor_jump_apex above
## the upper floor: v = g*dt/2 + sqrt((g*dt/2)^2 + 2*g*h).
func _start_floor_jump(target: int) -> bool:
	var apex_y: float = building.floor_y(target) - floor_jump_apex
	var rise: float = global_position.y - apex_y
	if rise <= 0.0:
		return false
	var step: float = floor_jump_gravity * (1.0 / float(Engine.physics_ticks_per_second)) * 0.5
	is_shifting = true
	shift_direction = 1
	_boost_floor = target
	_target_floor = target
	_shift_elapsed = 0.0
	_shift_duration = (step + sqrt(step * step + 2.0 * floor_jump_gravity * rise)) / floor_jump_gravity
	_shift_slab_y = building.floor_y(target) + 10.0
	_slab_dust_done = false
	_air_jump_used = true
	_fast_falling = false
	_coyote_remaining = 0.0
	_jump_buffer = 0.0
	velocity.y = -(step + sqrt(step * step + 2.0 * floor_jump_gravity * rise))
	visual_scale = Vector2(0.72, 1.34)
	# Only the upper deck is ignored; walls keep colliding during the launch.
	add_collision_exception_with(building.floor_bodies[target])
	_burst(Vector2.ZERO, 9)
	floor_transition_started.emit(target)
	return true

func _update_floor_jump(delta: float) -> void:
	_shift_elapsed += delta
	_stride += delta * 14.0
	_ghost_clock -= delta
	if _ghost_clock <= 0.0:
		_ghosts.append({"position": global_position, "facing": facing, "life": 0.2, "roll": 0.0, "tint": Color(0.70, 0.86, 0.92)})
		_ghost_clock = 0.025
	if not _slab_dust_done and global_position.y < _shift_slab_y - 10.0:
		_slab_dust_done = true
		_slab_dust()
	# Apex: vertical speed reaches zero above the deck -> re-arm it and fall normally.
	if velocity.y >= 0.0:
		_finish_floor_jump()

func _finish_floor_jump() -> void:
	if _boost_floor < 0:
		return
	remove_collision_exception_with(building.floor_bodies[_boost_floor])
	current_floor = _boost_floor
	_boost_floor = -1
	is_shifting = false
	velocity.y = 0.0
	floor_changed.emit(current_floor)

func _slab_dust() -> void:
	for i: int in range(10):
		_dust.append({"position": Vector2(global_position.x + (i - 4.5) * 9.0, _shift_slab_y - 10.0), "velocity": Vector2((i - 4.5) * 26.0, -30.0 - (i % 3) * 14.0), "life": 0.36, "radius": 3.5 + (i % 3)})

## S: scripted ease-out drop through the current slab.
func _update_shift(delta: float, direction: float) -> void:
	_shift_elapsed += delta
	var t: float = clampf(_shift_elapsed / _shift_duration, 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - t, 3.0)
	velocity.x = _run_velocity(direction, delta)
	global_position.x = clampf(global_position.x + velocity.x * delta, building.interior_left(), building.interior_right())
	global_position.y = lerpf(_shift_start_y, _shift_end_y, eased)
	_stride += delta * 19.0
	_ghost_clock -= delta
	if _ghost_clock <= 0.0:
		_ghosts.append({"position": global_position, "facing": facing, "life": 0.2, "roll": 0.0, "tint": Color(0.70, 0.86, 0.92)})
		_ghost_clock = 0.02
	if not _slab_dust_done and global_position.y > _shift_slab_y + 10.0:
		_slab_dust_done = true
		_slab_dust()
	if t >= 1.0:
		current_floor = _target_floor
		is_shifting = false
		collision_mask = 1
		velocity.y = 110.0
		visual_scale = Vector2(1.28, 0.74)
		_burst(Vector2.ZERO, 6)
		floor_changed.emit(current_floor)
		landed.emit(0.8)

func try_dash(direction: Vector2 = Vector2.ZERO) -> bool:
	if health <= 0 or is_shifting or is_dashing or _cooldown > 0.0 or stamina < dash_cost:
		return false
	if not is_on_floor() and _air_dash_used:
		return false
	_dash_direction = Vector2(facing, 0) if direction.is_zero_approx() else direction.normalized()
	if not is_zero_approx(_dash_direction.x):
		facing = signf(_dash_direction.x)
	_air_dash_used = true
	_fast_falling = false
	dash_remaining = dash_duration
	_cooldown = dash_cooldown
	_regen_delay = dash_duration + 0.25
	stamina -= dash_cost
	_ghost_clock = 0.0
	visual_scale = Vector2(1.22, 0.84)
	for i: int in range(7):
		_emit_dust()
	dash_started.emit()
	return true

## Storm gust: a drift the player must run or dash against. Not damage.
func apply_wind(strength: float, duration: float) -> void:
	_wind_target = strength
	_wind_left = maxf(_wind_left, duration)

func clear_wind() -> void:
	hazard_drag = 0.0
	hazard_pull = 0.0
	_wind_target = 0.0
	_wind_left = 0.0
	wind_velocity = 0.0

func _update_wind(delta: float) -> void:
	_wind_left = maxf(0.0, _wind_left - delta)
	var target: float = _wind_target if _wind_left > 0.0 else 0.0
	wind_velocity = move_toward(wind_velocity, target, wind_response * delta)

func _apply_room_ceiling() -> void:
	# Single jumps and upward dashes bonk under the slab instead of entering the next room.
	if building == null:
		return
	var room_floor: int = _boost_floor if _boost_floor >= 0 else current_floor
	var ceiling: float = building.floor_y(room_floor) - ceiling_clearance
	if global_position.y < ceiling:
		global_position.y = ceiling
		if velocity.y < 0.0:
			velocity.y = 0.0

func _sync_floor() -> void:
	if building == null or not is_on_floor():
		return
	for index: int in range(building.floor_count):
		if absf(global_position.y - building.floor_y(index)) < 8 and current_floor != index:
			current_floor = index
			floor_changed.emit(index)

func take_damage(amount: float) -> bool:
	if trailer_guard: return false
	if controls_locked or amount <= 0.0 or invulnerable or dashing_this_tick or health <= 0.0:
		return false
	health = maxf(0.0, health - amount)
	hit_invulnerability = 1.0
	# A lethal hit may be rescued before listeners evaluate defeat.
	if mechanics != null: mechanics.on_player_hurt()
	damaged.emit(health)
	return true

## Near miss reward: +25 dash energy at most once per GRAZE_COOLDOWN.
func graze(point: Vector2) -> bool:
	if health <= 0.0 or controls_locked or _graze_cooldown > 0.0 or hit_invulnerability > 0.0:
		return false
	_graze_cooldown = GRAZE_COOLDOWN
	stamina = minf(100.0, stamina + GRAZE_ENERGY)
	grazed.emit(point)
	return true

func reset_player() -> void:
	if building == null:
		return
	_graze_cooldown = 0.0
	covering = false
	shaking = false
	work_time = 0.0
	_ghost_phasing = false
	speed_boost = 0.0
	current_floor = 0
	controls_locked = false
	repair_shield = 0.0
	health = max_health
	stamina = 100.0
	dash_remaining = 0.0
	hit_invulnerability = 0.0
	dashing_this_tick = false
	self_modulate.a = 1.0
	_cooldown = 0.0
	_coyote_remaining = 0.0
	_jump_buffer = 0.0
	_air_dash_used = false
	_air_jump_used = false
	_fast_falling = false
	_regen_delay = 0.0
	if _boost_floor >= 0:
		remove_collision_exception_with(building.floor_bodies[_boost_floor])
	_boost_floor = -1
	is_shifting = false
	shift_direction = 0
	clear_wind()
	collision_mask = 1
	velocity = Vector2.ZERO
	gear_offset = Vector2.ZERO
	_gear_velocity = Vector2.ZERO
	visual_scale = Vector2.ONE
	lean = 0.0
	air_pose = 0.0
	_was_on_floor = true
	global_position = Vector2(building.center_x() - 230.0, building.floor_y(0) - 0.5)
	previous_position = global_position
	_ghosts.clear()
	_dust.clear()
	floor_changed.emit(current_floor)

## Helmet lamp polygon in global space, clipped to the room the helmet is in.
func beam_polygon() -> PackedVector2Array:
	var helmet: Vector2 = global_position + Vector2(facing * 12.0, -80.0 * visual_scale.y).rotated(lean)
	var forward: Vector2 = Vector2(facing, 0.16).normalized().rotated(lean * 0.5)
	var points: PackedVector2Array = PackedVector2Array([helmet,
		helmet + forward.rotated(-beam_spread) * beam_length,
		helmet + forward * beam_length * 1.04,
		helmet + forward.rotated(beam_spread) * beam_length])
	if building == null:
		return points
	var bottom_floor: float = building.floor_y(0)
	var band: int = clampi(int(floor((bottom_floor - helmet.y) / building.floor_height)), 0, building.floor_count - 1)
	var floor_line: float = building.floor_y(band)
	for i: int in range(points.size()):
		points[i].x = clampf(points[i].x, building.interior_left(), building.interior_right())
		points[i].y = clampf(points[i].y, floor_line - building.floor_height + 20.0, floor_line)
	return points

func _draw_beam() -> void:
	if health <= 0 or building == null:
		return
	var global_points: PackedVector2Array = beam_polygon()
	var local: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in global_points:
		local.append(to_local(point))
	var warm: Color = Color(1.0, 0.92, 0.72)
	_beam.draw_polygon(local, PackedColorArray([Color(warm, 0.42), Color(warm, 0.0), Color(warm, 0.06), Color(warm, 0.0)]))
	var inner: PackedVector2Array = PackedVector2Array([local[0], local[0].lerp(local[1], 0.55).lerp(local[2], 0.45), local[2], local[0].lerp(local[3], 0.55).lerp(local[2], 0.45)])
	_beam.draw_polygon(inner, PackedColorArray([Color(warm, 0.30), Color(warm, 0.02), Color(warm, 0.10), Color(warm, 0.02)]))
	_beam.draw_circle(local[0], 12.0, Color(warm, 0.35))
	_beam.draw_circle(local[0], 5.0, Color(1.0, 1.0, 0.95, 0.7))

func _emit_dust() -> void:
	var i: float = float(_dust.size() % 9)
	_dust.append({"position": global_position + Vector2(-facing * 8, -2), "velocity": Vector2(-facing * (32.0 + i * 7.0), -18.0 - i * 4), "life": 0.32, "radius": 3.0 + fmod(i, 3.0)})

func _burst(offset: Vector2, count: int) -> void:
	for i: int in range(count):
		var angle: float = PI + PI * float(i) / float(maxi(1, count - 1))
		_dust.append({"position": global_position + offset, "velocity": Vector2.from_angle(angle) * Vector2(95.0, 45.0), "life": 0.3, "radius": 3.0 + (i % 3)})

func _update_effects(delta: float) -> void:
	for i: int in range(_ghosts.size() - 1, -1, -1):
		_ghosts[i]["life"] = float(_ghosts[i]["life"]) - delta
		if float(_ghosts[i]["life"]) <= 0.0:
			_ghosts.remove_at(i)
	for i: int in range(_dust.size() - 1, -1, -1):
		_dust[i]["life"] = float(_dust[i]["life"]) - delta
		_dust[i]["position"] = Vector2(_dust[i]["position"]) + Vector2(_dust[i]["velocity"]) * delta
		if float(_dust[i]["life"]) <= 0.0:
			_dust.remove_at(i)

func _pose() -> Dictionary:
	return {"scale": visual_scale, "lean": lean, "air": air_pose, "cape": _cape, "clock": _clock, "gear": gear_offset}

func _draw() -> void:
	if repair_shield > 0.0:
		draw_arc(Vector2(0, -40), 52, 0, TAU, 32, Color(0.3, 1.0, 0.85, 0.8), 3.0)
	for ghost: Dictionary in _ghosts:
		var point: Vector2 = to_local(Vector2(ghost["position"]))
		var tint: Color = Color(ghost.get("tint", Color(0.58, 0.85, 0.74)))
		tint.a = float(ghost["life"]) / 0.22 * 0.36
		if custom_sprite != null:
			draw_texture_rect(custom_sprite, Rect2(point - Vector2(sprite_size.x * 0.5, sprite_size.y), sprite_size), false, tint)
		else:
			CharacterArt.draw_avatar(self, point, _stride, float(ghost["facing"]), float(ghost["roll"]), tint, {"lean": lean})
	for particle: Dictionary in _dust:
		var alpha: float = float(particle["life"]) / 0.32
		draw_circle(to_local(Vector2(particle["position"])), float(particle["radius"]) * (1.4 - alpha * 0.4), Color(0.62, 0.58, 0.50, alpha * 0.6))
	if is_shifting:
		# Rushing air: streaks trail opposite to the phase direction.
		var t: float = clampf(_shift_elapsed / _shift_duration, 0.0, 1.0)
		for i: int in range(6):
			var x: float = -26.0 + i * 10.4
			var length: float = 40.0 + float((i * 13) % 26)
			var y0: float = 6.0 if shift_direction > 0 else -96.0
			var y1: float = y0 + length * (1.0 if shift_direction > 0 else -1.0)
			draw_line(Vector2(x, y0), Vector2(x, y1), Color(0.86, 0.94, 0.92, 0.6 * (1.0 - t * 0.6)), 2.6, true)
	if absf(wind_velocity) > 25.0:
		var gust: float = clampf(absf(wind_velocity) / 160.0, 0.0, 1.0)
		for i: int in range(3):
			var y: float = -70.0 + i * 26.0
			var x: float = -signf(wind_velocity) * (30.0 + i * 6.0)
			draw_line(Vector2(x, y), Vector2(x - signf(wind_velocity) * 26.0, y), Color(0.86, 0.94, 0.92, 0.45 * gust), 2.6, true)
	CelArt.ellipse(self, Vector2(0, 1), Vector2(25 * visual_scale.x, 6), Color(0.0, 0.0, 0.0, 0.45), 0)
	var roll: float = 1.0 - dash_remaining / dash_duration if is_dashing else 0.0
	if custom_sprite != null:
		var size: Vector2 = sprite_size * visual_scale
		draw_set_transform(Vector2(0, -size.y * 0.5).rotated(lean), roll * TAU * facing + lean, Vector2(facing, 1))
		draw_texture_rect(custom_sprite, Rect2(-size * 0.5, size), false)
		draw_set_transform(Vector2.ZERO)
	else:
		CharacterArt.draw_avatar(self, Vector2.ZERO, _stride, facing, roll, Color.WHITE, _pose())
	if covering:
		_draw_cover_arms()
	if is_dashing:
		CelArt.ellipse(self, Vector2(0, -34), Vector2(35, 43), Color(0.65, 0.88, 0.77, 0.08), 0)

## Çök-Kapan-Tutun pose: both forearms folded over the helmet and neck.
func _draw_cover_arms() -> void:
	var top: float = -34.0 * visual_scale.y - 30.0 * visual_scale.y
	for side: float in [-1.0, 1.0]:
		var elbow: Vector2 = Vector2(side * 19.0 * facing, top + 14.0)
		var hand: Vector2 = Vector2(-side * 3.0 * facing, top - 3.0)
		CelArt.line(self, elbow, hand, CelArt.INK, 10)
		CelArt.line(self, elbow, hand, CharacterArt.NAVY.lightened(0.1), 6)
		CelArt.line(self, elbow - Vector2(2, 1), elbow + Vector2(3, 2), CharacterArt.ORANGE, 3)
		CelArt.ellipse(self, hand, Vector2(5, 5), Color("25353c"), 2)
