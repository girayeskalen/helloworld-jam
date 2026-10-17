extends SceneTree
## Real physics and collision checks for the movement rules (updated for Step 3:
## 4x4 apartment, W jump / 2x W floor up, S floor down, Space dash) and pattern primitives.
var checks: int = 0
var failures: int = 0
var game: MainGame
var launched: Array[HazardAttack] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	game.intro_enabled = false
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(4)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
		await create_timer(.6).timeout
	game.waves.attack_launched.connect(func(a: HazardAttack) -> void: launched.append(a))
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var w: DisasterWaveManager = game.waves
	var identities: Dictionary = {}
	var palettes: Dictionary = {}
	var names: Dictionary = {}
	for room: RoomDiorama in b.rooms:
		identities[room.room_kind] = true
		palettes[room.wall_color] = true
		names[room.room_name()] = true
	_check(b.rooms.size() == 16 and identities.size() == 16 and palettes.size() == 16 and names.size() == 16, "Sixteen rooms have unique identities, names and palettes")
	_check(b.room_at(0, 0).room_kind == RoomDiorama.Kind.WORKSHOP and b.room_at(3, 3).room_kind == RoomDiorama.Kind.ROOF_CONTROL, "Room order runs floor 00 A to floor 03 D")
	var expected: Array = [
		[0, BuildingProp.Kind.BOILER, BuildingProp.Kind.WORKBENCH, BuildingProp.Kind.TOOL_CABINET, BuildingProp.Kind.TOOLBOX],
		[1, BuildingProp.Kind.ENTRY_DOOR, BuildingProp.Kind.MAILBOXES, BuildingProp.Kind.FIRE_CABINET, BuildingProp.Kind.ELECTRICAL],
		[2, BuildingProp.Kind.FRIDGE, BuildingProp.Kind.STOVE, BuildingProp.Kind.HOOD, BuildingProp.Kind.KITCHEN, BuildingProp.Kind.SHELF],
		[3, BuildingProp.Kind.WASHER, BuildingProp.Kind.GAS_VALVE],
		[4, BuildingProp.Kind.SOFA, BuildingProp.Kind.TV, BuildingProp.Kind.COFFEE_TABLE, BuildingProp.Kind.CHANDELIER],
		[5, BuildingProp.Kind.DINING_TABLE, BuildingProp.Kind.DINING_CHAIR, BuildingProp.Kind.VITRINE],
		[6, BuildingProp.Kind.COMPUTER, BuildingProp.Kind.SWIVEL_CHAIR, BuildingProp.Kind.BOOKCASE, BuildingProp.Kind.CORKBOARD],
		[7, BuildingProp.Kind.PIANO, BuildingProp.Kind.TURNTABLE, BuildingProp.Kind.SPEAKER],
		[8, BuildingProp.Kind.BED, BuildingProp.Kind.NIGHTSTAND, BuildingProp.Kind.WARDROBE, BuildingProp.Kind.CURTAINS],
		[9, BuildingProp.Kind.BATHTUB, BuildingProp.Kind.SINK_MIRROR],
		[10, BuildingProp.Kind.BUNK_BED, BuildingProp.Kind.TOY_SHELF, BuildingProp.Kind.AIRCON, BuildingProp.Kind.POSTER],
		[11, BuildingProp.Kind.BED, BuildingProp.Kind.SUITCASE],
		[12, BuildingProp.Kind.PLANTER_RACK, BuildingProp.Kind.SKYLIGHT, BuildingProp.Kind.PLANT],
		[13, BuildingProp.Kind.TREADMILL, BuildingProp.Kind.WEIGHT_RACK, BuildingProp.Kind.PUNCH_BAG],
		[14, BuildingProp.Kind.EASEL, BuildingProp.Kind.PAINT_TABLE],
		[15, BuildingProp.Kind.HVAC_UNIT, BuildingProp.Kind.VENT_MOTOR, BuildingProp.Kind.ELECTRICAL]]
	for list: Array in expected:
		for index: int in range(1, list.size()):
			_check(_room_has(list[0], list[index]), "Authored room object room=%d kind=%d" % [list[0], list[index]])
	var signatures: Dictionary = {}
	for room: RoomDiorama in b.rooms:
		var kinds: Array = []
		for child: Node in room.get_children():
			if child is BuildingProp:
				kinds.append((child as BuildingProp).kind)
		kinds.sort()
		signatures[str(kinds)] = true
	_check(signatures.size() == 16, "Every room has a different furniture set")
	_check(_prop(0, BuildingProp.Kind.ELECTRICAL) != null and _prop(0, BuildingProp.Kind.FIRE_CABINET) != null and _prop(3, BuildingProp.Kind.VENT_MOTOR) != null, "Service fixtures moved into real lobby and roof-control rooms")
	var decks: bool = not (b.floor_bodies[0].get_child(0) as CollisionShape2D).one_way_collision
	for index: int in range(1, 4):
		decks = decks and (b.floor_bodies[index].get_child(0) as CollisionShape2D).one_way_collision
	_check(b.floor_bodies.size() == 4 and decks, "Upper decks are one-way; bottom floor remains solid")
	# Jump height depends on actual key hold, not a timer pretending to jump.
	p.reset_player()
	await _frames(3)
	var floor_y: float = b.floor_y(0)
	_key(KEY_W, true)
	await _frames(3)
	_key(KEY_W, false)
	var short_height: float = 0.0
	for tick: int in range(60):
		await _frames(1)
		short_height = maxf(short_height, floor_y - p.global_position.y)
	_check(short_height > 30 and p.is_on_floor(), "Tap jump rises and lands through real gravity")
	p.reset_player()
	await _frames(3)
	_key(KEY_W, true)
	var full_height: float = 0.0
	for tick: int in range(60):
		await _frames(1)
		full_height = maxf(full_height, floor_y - p.global_position.y)
	_key(KEY_W, false)
	_check(full_height > 95 and full_height > short_height * 1.6, "Held jump is higher than tap (tap=%.1f hold=%.1f)" % [short_height, full_height])
	_check(full_height <= p.ceiling_clearance + 0.5 and p.current_floor == 0, "A single held jump stays under its own ceiling and never changes floor")
	await _frames(6)
	for x: float in [b.global_position.x + 200, b.center_x(), b.global_position.x + 1400]:
		for key: int in [KEY_W, KEY_UP]:
			p.reset_player()
			p.global_position.x = x
			await _frames(3)
			_key(key, true)
			await _frames(3)
			_check(p.velocity.y < 0 and not p.is_shifting, "W/Up jumps anywhere in the floor, x=%.0f key=%d" % [x - b.global_position.x, key])
			_key(key, false)
	p.reset_player()
	await _frames(3)
	_key(KEY_D, true)
	_key(KEY_W, true)
	_key(KEY_SHIFT, true)
	await _frames(3)
	_check(p.is_dashing and p.velocity.x > 0 and p.velocity.y < 0 and not p.is_shifting, "Physical W+D+Shift chooses a diagonal dash before the jump")
	_key(KEY_D, false)
	_key(KEY_W, false)
	_key(KEY_SHIFT, false)
	p.reset_player()
	await _frames(3)
	_key(KEY_SPACE, true)
	await _frames(3)
	_check(p.is_dashing and p.velocity.y == 0 and absf(p.velocity.x) > 900, "Space dashes in the facing direction and never jumps")
	_key(KEY_SPACE, false)
	p.reset_player()
	await _frames(3)
	_key(KEY_W, true)
	await _frames(8)
	_check(not p.try_jump(), "No repeated ground jump while airborne")
	_key(KEY_S, true)
	await _frames(2)
	_check(p.velocity.y >= p.fast_fall_speed - 1 and p.current_floor == 0, "S on floor 00 converts an ascending jump into fast fall")
	_key(KEY_S, false)
	_key(KEY_W, false)
	await _frames(15)
	_check(p.is_on_floor() and not p._fast_falling, "Fast fall lands and clears its state")
	# Coyote time after physically stepping off a temporary test-only platform.
	var platform: StaticBody2D = StaticBody2D.new()
	platform.position = Vector2(b.global_position.x + 150, floor_y - 60)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(100, 20)
	shape.shape = rectangle
	platform.add_child(shape)
	# The world lives in the pixel SubViewport's own physics space.
	b.get_parent().add_child(platform)
	p.global_position = platform.position + Vector2(35, -11)
	p.velocity = Vector2.ZERO
	await _frames(4)
	_check(p.is_on_floor(), "Player stands on the temporary coyote platform")
	_key(KEY_D, true)
	var walked_off: bool = false
	for tick: int in range(30):
		await _frames(1)
		if not p.is_on_floor():
			walked_off = true
			break
	_check(walked_off and p._coyote_remaining > 0 and p.try_jump(), "0.1-second coyote jump works after leaving a real platform")
	_key(KEY_D, false)
	await _frames(10)
	_check(not p.try_jump(), "Coyote jump expires and cannot become infinite ground jumps")
	platform.queue_free()
	# Double jump = floor up, from any column: a physical arc that ignores only the upper
	# slab while rising, re-arms it at the apex and lands on it.
	for x: float in [b.global_position.x + 150, b.center_x(), b.global_position.x + 1450]:
		p.reset_player()
		p.global_position.x = x
		await _frames(3)
		await _tap(KEY_W)
		await _frames(6)
		await _tap(KEY_W)
		var through_slab: bool = p.is_shifting and p.get_collision_exceptions().has(b.floor_bodies[1]) and p.collision_mask == 1
		for frame: int in range(90):
			await _frames(1)
			if p.is_on_floor() and not p.is_shifting:
				break
		_check(through_slab and p.current_floor == 1 and p.is_on_floor() and p.get_collision_exceptions().is_empty() and absf(p.global_position.y - b.floor_y(1)) < 2.0, "2x W arcs up one floor at x=%.0f" % (x - b.global_position.x))
	# S drops one floor from any column, grounded or airborne.
	for x: float in [b.global_position.x + 120, b.center_x() + 210, b.global_position.x + 1480]:
		p.reset_player()
		p.current_floor = 2
		p.global_position = Vector2(x, b.floor_y(2) - .5)
		await _frames(3)
		await _tap(KEY_S)
		await _frames(16)
		_check(p.current_floor == 1 and p.is_on_floor() and p.collision_mask == 1 and p.get_collision_exceptions().is_empty(), "S phases down one floor at x=%.0f" % (x - b.global_position.x))
	p.reset_player()
	p.current_floor = 2
	p.global_position = Vector2(b.center_x(), b.floor_y(2) - .5)
	await _frames(3)
	await _tap(KEY_W)
	await _frames(5)
	await _tap(KEY_S)
	await _frames(20)
	_check(p.current_floor == 1 and p.is_on_floor(), "S in mid-air on an upper floor also drops a floor")
	# Top floor: the second W is only an air jump, capped under the roof slab.
	p.reset_player()
	p.current_floor = 3
	p.global_position = Vector2(b.center_x(), b.floor_y(3) - .5)
	await _frames(3)
	await _tap(KEY_W)
	await _frames(6)
	await _tap(KEY_W)
	_check(not p.is_shifting and p.velocity.y < 0 and p.current_floor == 3, "Top-floor double jump is a plain air jump")
	_check(not p.try_air_jump(), "Only one air jump per airtime")
	await _frames(60)
	_check(p.is_on_floor() and p.current_floor == 3 and absf(p.global_position.y - b.floor_y(3)) < 2.0, "Top-floor air jump lands back on floor 03")
	# Every directional dash uses the same speed and protects a genuine air move.
	for dir: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
		p.reset_player()
		await _frames(3)
		p.global_position.y -= 60
		p.velocity = Vector2.ZERO
		await _frames(2)
		var origin: Vector2 = p.global_position
		var started: bool = p.try_dash(dir)
		# Two frames at 1150 px/s stay below the 116 px ceiling cap and above the floor.
		await _frames(2)
		var delta: Vector2 = p.global_position - origin
		_check(started and p.invulnerable and delta.normalized().dot(dir.normalized()) > .99 and absf(p.velocity.length() - p.dash_speed) < 1, "Air dash direction %s is normalized and invulnerable" % dir)
		_check(not p.take_damage(20) and p.stamina == 68, "Air dash consumes stamina once and rejects damage")
	p.reset_player()
	p.current_floor = 3
	p.global_position = Vector2(b.global_position.x + 900, b.floor_y(3) - .5)
	await _frames(3)
	p.try_dash(Vector2.UP)
	await _frames(26)
	_check(not p.is_on_floor() and not p.try_dash(Vector2.RIGHT), "Only one air dash before landing, even after cooldown")
	_check(p.global_position.y >= b.floor_y(3) - p.ceiling_clearance - .01, "An upward dash bonks under the roof slab")
	await _frames(90)
	_check(p.is_on_floor() and p.try_dash(Vector2.RIGHT), "Landing replenishes the air dash")
	# Pattern primitives and immutable warnings.
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)

	w.building.pacing_enabled = false
	BossPatterns.fan(w, 0, 0)
	_check(game.telegraphs.pending.size() == 7, "Seven-shot radial fan")
	var angles: Dictionary = {}
	for a: HazardAttack in game.telegraphs.pending:
		angles[a.velocity.angle()] = true
	_check(angles.size() == 7, "Fan shots use separate angles with actual dodge gaps")
	game.telegraphs.clear()
	BossPatterns.fan(w, 0, 1)
	_check(game.telegraphs.pending.size() == 5, "Alternate five-shot fan rotates its emission angle")
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	w.building.pacing_enabled = false
	BossPatterns.ground_wave(w, 0, true)
	_check(game.telegraphs.pending.size() == 2 and game.telegraphs.pending[0].velocity.x < 0 and game.telegraphs.pending[1].velocity.x > 0, "Ground waves travel horizontally outward, not vertically")
	# Compare jumping and standing against the same armed low hitbox.
	var low: HazardProjectile = game.projectiles.entries[0]
	low.attack = w._attack(HazardAttack.Kind.SHOCKWAVE, 0, p.global_position + Vector2(0, -12), Vector2.ZERO)
	low.global_position = low.attack.origin
	p.previous_position = p.global_position
	_check(low.crosses_player(p, low.global_position), "Ground wave hits a grounded player")
	p.global_position.y -= 85
	p.previous_position = p.global_position
	_check(not low.crosses_player(p, low.global_position), "Jumping over the low wave clears its collision")
	low.deactivate()
	p.reset_player()
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	BossPatterns.full_row(w, 0, 0)
	_check(game.telegraphs.pending[0].warning_duration == 1.0, "Full-row warning reserves a complete 1.0 second")
	await _frames(55)
	_check(game.projectiles.active_count() == 0, "Full-row danger cannot start early at 0.9 seconds")
	var premature: HazardAttack = row_probe()
	_check(game.projectiles.spawn(premature) == null, "Pool rejects forged short-warning activation of a full-row attack")
	await _frames(8)
	_check(game.projectiles.active_count() == 1, "Full-row wall starts only after one second")
	var wall: HazardProjectile = game.projectiles.entries[0]
	wall.global_position = Vector2(p.global_position.x, b.floor_y(0) - 82)
	p.previous_position = p.global_position
	_check(wall.crosses_player(p, wall.global_position), "Tall sweep hits at ground height")
	p.global_position.y -= 110
	p.previous_position = p.global_position
	_check(wall.crosses_player(p, wall.global_position), "A small jump cannot bypass the tall sweep")
	p.global_position.y = b.floor_y(1)
	p.previous_position = p.global_position
	_check(not wall.crosses_player(p, wall.global_position), "A sweep cannot hit the neighboring floor")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	var row: HazardAttack = w._attack(HazardAttack.Kind.ROW_SWEEP, 0, p.global_position + Vector2(-80, -82), Vector2(1900, 0))
	row.pattern = HazardAttack.Pattern.FULL_ROW
	row.lifetime = .6
	w.plan_attack(row, 1)
	await _frames(58)
	p.try_dash(Vector2.LEFT)
	var dodges: int = w.dodge_count
	await _frames(12)
	_check(p.health == 100 and w.dodge_count == dodges + 1, "Timed i-frame dash passes through a real full-row wall")
	# Impact -> warning -> 3 hopping splinters, never instant unannounced damage.
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	w.building.pacing_enabled = false
	launched.clear()
	BossPatterns.cluster(w, 0, 0)
	await _frames(86)
	var child_warnings: int = 0
	for a: HazardAttack in game.telegraphs.pending:
		if a.pattern == HazardAttack.Pattern.SPLINTER:
			child_warnings += 1
	_check(child_warnings == 6, "Two concrete impacts each create three separately warned splinters")
	var child_launches: int = 0
	for a: HazardAttack in launched:
		if a.pattern == HazardAttack.Pattern.SPLINTER:
			child_launches += 1
	_check(child_launches == 0, "Splinters are non-damaging throughout the impact warning")
	await _frames(37)
	var split_directions: Dictionary = {}
	for a: HazardAttack in launched:
		if a.pattern == HazardAttack.Pattern.SPLINTER:
			child_launches += 1
			split_directions[signf(a.velocity.x)] = true
			_check(a.warning_elapsed >= .55 and not a.splits and a.point_at(.15).y < a.floor_y - 18, "Splinter warns, hops above the floor and cannot split recursively")
	_check(child_launches == 6 and split_directions.has(-1.0) and split_directions.has(1.0), "Cluster shards bounce left and right after warning")
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	w.building.pacing_enabled = false
	BossPatterns.room_objects(w, 0)
	var room_kinds: Dictionary = {}
	for a: HazardAttack in game.telegraphs.pending:
		room_kinds[a.kind] = true
		_check(a.room_source != &"", "Room hazard retains its actual furniture source")
	for kind: int in [HazardAttack.Kind.WARDROBE, HazardAttack.Kind.CHANDELIER, HazardAttack.Kind.KNIFE, HazardAttack.Kind.PLATE, HazardAttack.Kind.SAW, HazardAttack.Kind.TOOL, HazardAttack.Kind.BOOK, HazardAttack.Kind.TOY]:
		_check(room_kinds.has(kind), "Room-specific hazard kind=%d" % kind)
	_check(game.telegraphs.pending.size() == 8, "16 rooms keep the same 8 room-object hazards (quake balance preserved)")
	var wardrobe: BuildingProp = _prop(2, BuildingProp.Kind.WARDROBE)
	wardrobe.condition = BuildingProp.Condition.REINFORCED
	game.telegraphs.clear()
	BossPatterns.room_objects(w, 1)
	var protected_source: bool = true
	for a: HazardAttack in game.telegraphs.pending:
		protected_source = protected_source and a.room_source != wardrobe.object_id
	_check(protected_source, "Reinforced furniture does not generate unsecured-object hazards")
	wardrobe.condition = BuildingProp.Condition.UNSECURED
	w.reset_cycle()
	p.reset_player()
	_check(game.telegraphs.pending.is_empty() and game.projectiles.active_count() == 0 and p.get_collision_exceptions().is_empty() and not p.is_shifting, "Reset cancels chained hazards and movement state")
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(argument.trim_prefix("--capture="))
	print("STEP25_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless":
		_check(false, "Capture requires native renderer")
		return
	DirAccess.make_dir_recursive_absolute(directory)
	game.waves.reset_cycle()
	game.player.reset_player()
	await _frames(4)
	await _save(directory, "sixteen-rooms.png")
	_key(KEY_W, true)
	await _frames(13)
	await _save(directory, "jump.png")
	game.player.try_dash(Vector2(1, -1))
	await _frames(5)
	await _save(directory, "air-dash.png")
	_key(KEY_W, false)
	await _frames(40)
	game.player.try_floor_shift(1)
	await _frames(8)
	await _save(directory, "floor-up-phase.png")
	await _frames(30)
	game.player.try_floor_shift(-1)
	await _frames(7)
	await _save(directory, "floor-down-phase.png")
	game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)

	game.waves.building.pacing_enabled = false
	BossPatterns.fan(game.waves, 0, 0)
	BossPatterns.ground_wave(game.waves, 1, true)
	await _frames(24)
	await _save(directory, "fan-ground-warning.png")
	await _frames(39)
	await _save(directory, "fan-ground-projectiles.png")
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	game.waves.building.pacing_enabled = false
	BossPatterns.cluster(game.waves, 0, 0)
	await _frames(86)
	await _save(directory, "split-warning.png")
	await _frames(44)
	await _save(directory, "bouncing-splinters.png")
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	game.waves.building.pacing_enabled = false
	BossPatterns.room_objects(game.waves, 0)
	await _frames(25)
	await _save(directory, "room-object-warning.png")
	await _frames(24)
	await _save(directory, "room-objects.png")

func _room_has(room_index: int, kind: int) -> bool:
	for child: Node in game.building.rooms[room_index].get_children():
		if child is BuildingProp and (child as BuildingProp).kind == kind:
			return true
	return false

func _prop(floor_index: int, kind: int) -> BuildingProp:
	for prop: BuildingProp in game.building.props:
		if prop.floor_index == floor_index and prop.kind == kind:
			return prop
	return null

func row_probe() -> HazardAttack:
	var a: HazardAttack = HazardAttack.new()
	a.pattern = HazardAttack.Pattern.FULL_ROW
	a.kind = HazardAttack.Kind.ROW_SWEEP
	a.warning_id = 999
	a.warning_confirmed = true
	a.warning_duration = .65
	a.warning_elapsed = .65
	return a

func _save(directory: String, filename: String) -> void:
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Rendered " + filename)

func _frames(count: int) -> void:
	for tick: int in range(count):
		await physics_frame

func _tap(code: int) -> void:
	_key(code, true)
	await _frames(2)
	_key(code, false)

func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
