extends SceneTree
## Real Godot input/physics checks, with optional GPU screenshots.

var _failures: int = 0
var _checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		push_error("MainGame scene could not load")
		quit(1)
		return
	var game: MainGame = packed.instantiate() as MainGame
	game.intro_enabled = false
	root.add_child(game)
	# Isolate movement regressions from automatic combat; Step2Smoke covers waves.
	game.waves.autoplay = false
	await _frames(3)
	# Native windows can clear held input while receiving their initial focus.
	# Wait for that OS event before injecting test keys; headless has no focus event.
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
		await create_timer(0.6).timeout
	var player: SiegePlayer = game.player
	var building: ApartmentBuilding = game.building
	_check(building.rooms.size() == 16 and building.floor_count == 4, "Sixteen diorama rooms on four floors")
	var pillar_count: int = 0
	var ids: Dictionary = {}
	for prop: BuildingProp in building.props:
		if prop.kind == BuildingProp.Kind.PILLAR:
			pillar_count += 1
		ids[prop.object_id] = true
		_check(prop.state_record().has("condition"), "State record: " + String(prop.object_id))
	_check(pillar_count == 5, "Five continuous structural pillars")
	_check(ids.size() == building.props.size(), "Every prop has a unique id")
	_check(player.is_on_floor(), "Player stands on the ground-floor collider")
	var initial_x: float = player.position.x
	_key(KEY_D, true)
	await _frames(24)
	_key(KEY_D, false)
	_check(player.position.x > initial_x + 50, "Physical D key moves right with acceleration (distance=%.1f)" % (player.position.x - initial_x))
	await _frames(12)
	_check(absf(player.velocity.x) < 1.0, "Character brakes after release")
	# No stairwell: floors change anywhere via W,W (up) and S (down).
	player.reset_player()
	await _frames(2)
	_check(not player.try_floor_shift(-1), "Cannot drop below the ground floor")
	player.global_position.x = building.position.x + 130.0
	await _frames(2)
	_tap(KEY_W)
	await _frames(8)
	_key(KEY_W, true)
	await _frames(2)
	# Step 3-B: the floor jump is a physical arc; only the upper slab is ignored while rising.
	_check(player.is_shifting and player.collision_mask == 1 and player.get_collision_exceptions().has(building.floor_bodies[1]) and not player.try_dash(Vector2.RIGHT), "Dash cannot interrupt a floor jump; only the upper slab is ignored")
	_key(KEY_W, false)
	await _landing(player)
	_check(player.current_floor == 1 and not player.is_shifting and player.is_on_floor() and player.get_collision_exceptions().is_empty(), "W then W in the air climbs to floor 1 at a side room")
	await _frames(4)
	_tap(KEY_UP)
	await _frames(8)
	_tap(KEY_UP)
	await _landing(player)
	_check(player.current_floor == 2 and player.is_on_floor(), "Up arrow double jump climbs to floor 2")
	await _frames(4)
	_tap(KEY_W)
	await _frames(8)
	_tap(KEY_W)
	await _landing(player)
	_check(player.current_floor == 3 and player.is_on_floor(), "Double jump climbs to the top floor 3")
	await _frames(4)
	_tap(KEY_W)
	await _frames(8)
	_tap(KEY_W)
	await _frames(4)
	_check(player.current_floor == 3 and not player.is_shifting and player.global_position.y >= building.floor_y(3) - player.ceiling_clearance - 0.01, "Cannot climb above the roof")
	await _frames(60)
	_tap(KEY_S)
	await _frames(20)
	_check(player.current_floor == 2 and player.collision_mask == 1 and player.is_on_floor(), "S descends and restores physical collision")
	_check(absf(player.global_position.y - building.floor_y(2)) < 2.0, "Floor phase endpoint aligns with floor collider")
	player.reset_player()
	await _frames(2)
	_key(KEY_D, true)
	_key(KEY_SHIFT, true)
	await _frames(2)
	_key(KEY_SHIFT, false)
	_check(player.invulnerable, "Shift starts dash and i-frames")
	_check(is_equal_approx(player.stamina, 68.0), "Dash consumes 32 stamina exactly once")
	var dash_x: float = player.position.x
	_check(not player.take_damage(20), "Dash rejects damage")
	await _frames(6)
	_check(player.position.x > dash_x + 70, "Dash is faster than running")
	_check(not player.try_dash(Vector2.RIGHT), "Cannot stack dash while invulnerable")
	_check(player._ghosts.size() > 0 and player._dust.size() > 0, "Dash creates afterimages and dust")
	await _frames(9)
	_key(KEY_D, false)
	_check(not player.invulnerable, "Invulnerability expires after 0.25 seconds")
	_check(player.take_damage(20) and player.health == 80.0, "Damage applies outside i-frames")
	player.reset_player()
	player.stamina = 0
	_check(not player.try_dash(Vector2.RIGHT), "Empty stamina blocks dash")
	await _frames(40)
	_check(player.stamina > 10, "Stamina regenerates")
	player.reset_player()
	await _frames(2)
	_key(KEY_SPACE, true)
	await _frames(2)
	_key(KEY_SPACE, false)
	_check(player.invulnerable and is_equal_approx(player.stamina, 68.0) and player.velocity.y >= 0, "Space starts the i-frame dash instead of jumping")
	await _frames(20)
	player.reset_player()
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	mouse.pressed = true
	Input.parse_input_event(mouse)
	Input.flush_buffered_events()
	await _frames(2)
	_check(player.invulnerable, "Right mouse button maps to dash")
	mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	mouse.pressed = false
	Input.parse_input_event(mouse)
	Input.flush_buffered_events()
	player.reset_player()
	player.position.x = building.position.x + 29
	_key(KEY_A, true)
	await _frames(20)
	_key(KEY_A, false)
	_check(player.position.x >= building.position.x + 20, "Left boundary blocks escape from apartment")
	player.reset_player()
	_key(KEY_T, true)
	await _frames(3)
	_key(KEY_T, false)
	_check(game.game_camera.offset.length() > 0.01, "T produces camera shake")
	await create_timer(0.8).timeout
	_check(game.game_camera.offset.length() < 0.01, "Camera returns exactly to its rest offset")
	_key(KEY_R, true)
	await _frames(2)
	_key(KEY_R, false)
	_check(player.health == player.max_health and player.current_floor == 0, "R resets player")
	var image: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	building.props[0].custom_sprite = texture
	await process_frame
	_check(building.props[0].custom_sprite == texture, "Custom sprite is assignable at runtime")
	building.props[0].custom_sprite = null
	var assets: SiegeArtAssets = SiegeArtAssets.new()
	assets.bookcase = texture
	_check(assets.texture_for_prop(BuildingProp.Kind.BOOKCASE, &"sample") == texture, "Persistent art profile selects the object's texture")
	assets.object_overrides["sample"] = texture
	_check(assets.texture_for_prop(BuildingProp.Kind.TABLE, &"sample") == texture, "Individual sprite override takes precedence")
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(game, argument.trim_prefix("--capture="))
	print("STEP1_RESULT checks=%d failures=%d" % [_checks, _failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if _failures == 0 else 1)

func _capture(game: MainGame, directory: String) -> void:
	if DisplayServer.get_name() == "headless":
		_check(false, "Capture needs a real display renderer")
		return
	DirAccess.make_dir_recursive_absolute(directory)
	game.player.reset_player()
	await _frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("apartment.png"))
	game.player.try_dash(Vector2.RIGHT)
	await _frames(6)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("dash.png"))
	await _frames(20)
	game.player.try_floor_shift(1)
	await _frames(9)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join("floor-phase.png"))
	print("CAPTURES " + directory)

func _frames(count: int) -> void:
	for i: int in range(count):
		await physics_frame

func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	# Windowed runs buffer input until the next idle frame; short taps must arrive now.
	Input.flush_buffered_events()

## Waits until a floor jump has peaked and the player has landed (max 1.5 s).
func _landing(player: SiegePlayer) -> void:
	await _frames(4)
	for i: int in range(90):
		if player.is_on_floor() and not player.is_shifting:
			return
		await _frames(1)

func _tap(code: int) -> void:
	_key(code, true)
	await _frames(2)
	_key(code, false)

func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		print("PASS " + message)
	else:
		_failures += 1
		push_error("FAIL " + message)
