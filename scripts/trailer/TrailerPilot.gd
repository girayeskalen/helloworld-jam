class_name TrailerPilot
extends RefCounted
## Trailer-only "player": real input actions (Input.action_press / parse_input_event),
## so every move on screen is the game's own run, jump, 2x W floor jump, S drop, dash,
## Çök-Kapan-Tutun and E. Scripted helpers serve the calm shots; `auto` plays the
## action shots like an engaged human: it reads every live bullet's frozen path
## (HazardAttack.point_at) and the pending area telegraphs, dashes out of a hit at
## the last moment, hops low bullets, leaves marked rooms/floors and keeps moving.

var game: MainGame
## World x the pilot runs to (NAN = stand still) and how close counts as there.
var target_x: float = NAN
var tolerance: float = 10.0
var _held: Dictionary = {}
var _taps: Array[Dictionary] = []
var _no_walk_until: float = -1.0

## --- auto play ---
var auto: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Dashes stay available in the trailer (the energy line barely shows it).
var energy_floor: float = 66.0
var floors_allowed: Array[int] = [0, 1, 2, 3]
var floor_changes: bool = true
var x_band: Vector2 = Vector2(505, 1955)
var clock: float = 0.0
var _wander_at: float = 0.0
var _hop_at: float = 0.0
var _floor_at: float = 0.0
var _flourish_at: float = 0.0
var _shift_ready_at: float = 0.0
var dashes: int = 0
var dodges_planned: int = 0

const SPINE_TOP: float = -36.0
const SPINE_BOTTOM: float = -12.0
const BODY: float = 12.0
const DASH_SPEED: float = 1150.0
const DASH_TIME: float = 0.25
const DIRECTIONS: Array[Vector2] = [Vector2(1, 0), Vector2(-1, 0), Vector2(1, -1), Vector2(-1, -1), Vector2(0, -1)]

func _init(owner_game: MainGame) -> void:
	game = owner_game

func press(action: StringName) -> void:
	if _held.get(action, false): return
	_held[action] = true
	Input.action_press(action)

func release(action: StringName) -> void:
	if not _held.get(action, false): return
	_held[action] = false
	Input.action_release(action)

## Press for a few rendered frames (just_pressed fires on the first physics tick).
func tap(action: StringName, frames: int = 3) -> void:
	press(action)
	_taps.append({"action": action, "left": frames})

## E and other actions read through _unhandled_input need a real InputEvent.
func event_tap(action: StringName) -> void:
	var down: InputEventAction = InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	var up: InputEventAction = InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)

func walk_to(x: float, close: float = 10.0) -> void:
	target_x = x
	tolerance = close

func stop() -> void:
	target_x = NAN
	release(&"move_left")
	release(&"move_right")

## W, then W again in the air: one floor up (the game's own 2x W arc).
func floor_up(director: Node) -> void:
	tap(&"jump", 3)
	director.get_tree().create_timer(0.12, true, false).timeout.connect(func() -> void: tap(&"jump", 3))

func floor_down() -> void:
	tap(&"move_down", 3)

## Eight-way dash: the walk keys are released first so get_vector reads only `direction`.
func dash(direction: Vector2) -> void:
	release(&"move_left")
	release(&"move_right")
	_no_walk_until = clock + 0.1
	if direction.x < 0: tap(&"move_left", 5)
	elif direction.x > 0: tap(&"move_right", 5)
	if direction.y < 0: tap(&"move_up", 5)
	tap(&"dash", 3)
	dashes += 1

func release_all() -> void:
	for action: StringName in _held.keys():
		if _held[action]: Input.action_release(action)
	_held.clear()
	_taps.clear()
	target_x = NAN

func start_auto(seed_value: int) -> void:
	auto = true
	rng.seed = seed_value
	_wander_at = 0.0
	_hop_at = rng.randf_range(0.15, 0.4)
	_floor_at = rng.randf_range(0.9, 1.6)
	_flourish_at = rng.randf_range(0.6, 1.2)

# ----------------------------------------------------------------- per frame --

func update(delta: float = 1.0 / 60.0) -> void:
	clock += delta
	if auto: _think()
	for i: int in range(_taps.size() - 1, -1, -1):
		_taps[i]["left"] = int(_taps[i]["left"]) - 1
		if int(_taps[i]["left"]) <= 0:
			var action: StringName = _taps[i]["action"]
			_taps.remove_at(i)
			# The second W of floor_up_now lands after the first one was released.
			if action == &"__second_jump": tap(&"jump", 3)
			else: release(action)
	if is_nan(target_x) or clock < _no_walk_until: return
	var x: float = game.player.global_position.x
	if absf(target_x - x) <= tolerance:
		stop()
		return
	if target_x > x:
		release(&"move_left")
		press(&"move_right")
	else:
		release(&"move_right")
		press(&"move_left")

func _think() -> void:
	var p: SiegePlayer = game.player
	if p.controls_locked or p.health <= 0.0: return
	p.stamina = maxf(p.stamina, energy_floor)
	# 1. A bullet is about to touch the spine: dash out at the last moment, or hop it.
	var threat: Dictionary = _bullet_threat(0.3)
	if float(threat["time"]) < 0.17 and _can_dash():
		dash(_best_dash())
		dodges_planned += 1
		return
	if float(threat["time"]) < 0.14 and p.is_on_floor() and bool(threat["low"]) and not p.is_dashing:
		tap(&"jump", 6)
		return
	# 2. The storm roulette names its safe floor; go there.
	var safe: int = _safe_floor()
	if safe >= 0 and safe != p.current_floor:
		_go_floor(safe)
		return
	# 3. A marked room/floor is about to fire under the player: step out, or change floor.
	if _escape_zones(): return
	_wander()

func _can_dash() -> bool:
	var p: SiegePlayer = game.player
	return not p.is_dashing and not p.is_shifting and p._cooldown <= 0.0 and p.stamina >= p.dash_cost and (p.is_on_floor() or not p._air_dash_used)

func _spine_distance(point: Vector2, feet: Vector2) -> float:
	var top: Vector2 = feet + Vector2(0, SPINE_TOP)
	var bottom: Vector2 = feet + Vector2(0, SPINE_BOTTOM)
	return Geometry2D.get_closest_point_to_segment(point, top, bottom).distance_to(point)

## Earliest predicted contact of a live bullet with the (moving) player within
## `horizon` seconds; walls count when they sweep the player's floor.
func _bullet_threat(horizon: float) -> Dictionary:
	var p: SiegePlayer = game.player
	var best: Dictionary = {"time": INF, "low": false}
	for projectile: HazardProjectile in game.projectiles.entries:
		if not projectile.active or projectile.attack == null: continue
		var attack: HazardAttack = projectile.attack
		if attack.is_area(): continue
		for k: int in range(1, 9):
			var t: float = horizon * k / 8.0
			if projectile.age + t > attack.lifetime: break
			var point: Vector2 = attack.point_at(projectile.age + t)
			var feet: Vector2 = p.global_position + p.velocity * t * 0.5
			var hit: bool = false
			if attack.is_wall():
				hit = attack.floor_index == p.current_floor and absf(point.x - feet.x) < attack.radius + BODY + 6.0
			else:
				hit = _spine_distance(point, feet) < attack.radius + BODY + 7.0
			if hit:
				if t < float(best["time"]):
					best = {"time": t, "low": point.y > p.global_position.y - 30.0 and absf(attack.velocity.x) > absf(attack.velocity.y)}
				break
	return best

## The dash whose path keeps the widest margin from every live bullet; up-diagonals
## win ties (they read best), the building walls are respected.
func _best_dash() -> Vector2:
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var best_dir: Vector2 = Vector2(p.facing, 0)
	var best_score: float = -INF
	for direction: Vector2 in DIRECTIONS:
		var d: Vector2 = direction.normalized()
		if d.y < 0.0 and (p.current_floor >= b.floor_count - 1 and not p.is_on_floor()): continue
		var score: float = INF
		for k: int in range(1, 8):
			var t: float = 0.05 * k
			var feet: Vector2 = p.global_position + d * DASH_SPEED * minf(t, DASH_TIME)
			if feet.x < b.interior_left() + 20.0 or feet.x > b.interior_right() - 20.0: score = minf(score, -50.0)
			for projectile: HazardProjectile in game.projectiles.entries:
				if not projectile.active or projectile.attack == null or projectile.attack.is_area(): continue
				var attack: HazardAttack = projectile.attack
				if projectile.age + t > attack.lifetime: continue
				var point: Vector2 = attack.point_at(projectile.age + t)
				var gap: float = (absf(point.x - feet.x) if attack.is_wall() and attack.floor_index == p.current_floor else _spine_distance(point, feet)) - attack.radius - BODY
				score = minf(score, gap)
		score += (8.0 if d.y < 0.0 and d.x != 0.0 else 0.0) + rng.randf_range(0.0, 4.0)
		if score > best_score:
			best_score = score
			best_dir = direction
	return best_dir

func _safe_floor() -> int:
	for attack: HazardAttack in game.telegraphs.pending:
		if attack.pattern == HazardAttack.Pattern.SAFE_FLOOR and attack.warning_delay <= 0.0:
			return int(String(attack.room_source).get_slice("_", 1))
	return -1

func _go_floor(target: int) -> void:
	var p: SiegePlayer = game.player
	if clock < _shift_ready_at or p.is_shifting or p.is_dashing: return
	if target > p.current_floor:
		if p.is_on_floor(): floor_up_now()
		elif not p._air_jump_used: tap(&"jump", 3)  # already airborne: the second W alone
		else: return
	elif target < p.current_floor:
		floor_down()
	else: return
	_shift_ready_at = clock + 0.5

## A roulette corridor set is pending or sweeping: stay on the safe floor.
func _roulette_running() -> bool:
	for attack: HazardAttack in game.telegraphs.pending:
		if attack.pattern == HazardAttack.Pattern.SAFE_FLOOR: return true
	for projectile: HazardProjectile in game.projectiles.entries:
		if projectile.active and projectile.attack != null and projectile.attack.pattern == HazardAttack.Pattern.SAFE_FLOOR: return true
	return false

## 2x W without a timer (the second press lands a few frames later from _think).
func floor_up_now() -> void:
	tap(&"jump", 3)
	_taps.append({"action": &"__second_jump", "left": 7})

## Pending/live floor areas (rockfall columns, floods, whirlpools) about to cover the
## player: walk to the nearest clear x, or leave the floor when it is all marked.
func _escape_zones() -> bool:
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var areas: Array[Rect2] = []
	for attack: HazardAttack in game.telegraphs.pending:
		if not attack.is_area() or attack.floor_index != p.current_floor: continue
		var time_to_go: float = attack.warning_delay + maxf(0.0, attack.warning_duration - attack.warning_elapsed)
		if time_to_go < 0.75: areas.append_array(attack.area_segments())
	for projectile: HazardProjectile in game.projectiles.entries:
		if projectile.active and projectile.attack != null and projectile.attack.is_area() and projectile.attack.floor_index == p.current_floor and projectile.attack.kind != HazardAttack.Kind.WHIRLPOOL:
			areas.append_array(projectile.attack.area_segments())
	var x: float = p.global_position.x
	var inside: bool = false
	for area: Rect2 in areas:
		if x > area.position.x - 16.0 and x < area.end.x + 16.0: inside = true
	if not inside: return false
	var best: float = NAN
	for area: Rect2 in areas:
		for candidate: float in [area.position.x - 34.0, area.end.x + 34.0]:
			if candidate < b.interior_left() + 24.0 or candidate > b.interior_right() - 24.0: continue
			var clear: bool = true
			for other: Rect2 in areas:
				if candidate > other.position.x - 16.0 and candidate < other.end.x + 16.0: clear = false
			if clear and (is_nan(best) or absf(candidate - x) < absf(best - x)): best = candidate
	if is_nan(best):
		if _roulette_running(): return false
		var up: bool = p.current_floor < b.floor_count - 1 and (p.current_floor == 0 or rng.randf() < 0.6)
		_go_floor(p.current_floor + (1 if up else -1))
	else:
		walk_to(best, 8.0)
		if absf(best - x) > 160.0 and _can_dash() and rng.randf() < 0.5: dash(Vector2(signf(best - x), 0))
	return true

## No threat: keep moving like a player who reads the next attack — runs, hops,
## swaps floors and throws the occasional flourish dash.
func _wander() -> void:
	var p: SiegePlayer = game.player
	if clock >= _wander_at:
		var x: float = p.global_position.x
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		if x - x_band.x < 260.0: side = 1.0
		elif x_band.y - x < 260.0: side = -1.0
		walk_to(clampf(x + side * rng.randf_range(150.0, 430.0), x_band.x, x_band.y), 14.0)
		_wander_at = clock + rng.randf_range(0.25, 0.55)
	if clock >= _hop_at and p.is_on_floor() and not p.is_dashing:
		tap(&"jump", rng.randi_range(2, 6))
		_hop_at = clock + rng.randf_range(0.45, 0.95)
	if floor_changes and clock >= _floor_at and p.is_on_floor() and not _roulette_running():
		var options: Array[int] = []
		for f: int in [p.current_floor - 1, p.current_floor + 1]:
			if f in floors_allowed: options.append(f)
		if not options.is_empty(): _go_floor(options[rng.randi_range(0, options.size() - 1)])
		_floor_at = clock + rng.randf_range(1.3, 2.4)
	if clock >= _flourish_at and _can_dash():
		var dir_x: float = signf(target_x - p.global_position.x) if not is_nan(target_x) else p.facing
		dash(Vector2(dir_x if dir_x != 0.0 else p.facing, -1.0 if rng.randf() < 0.45 else 0.0))
		_flourish_at = clock + rng.randf_range(0.55, 1.15)
