extends SceneTree
## Step 2.7: signage removal, blackout atmosphere (night sky, rain/ash, lightning,
## room lighting + AO, helmet beam), pixel render, sprite auto-loader, snappy movement
## with squash & stretch, multi-segment boss animation and neon projectiles.
var checks: int = 0
var failures: int = 0
var game: MainGame

const HUD_TOP: float = 165.0
const HUD_BOTTOM: float = 990.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(4)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
		await create_timer(.6).timeout
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var w: DisasterWaveManager = game.waves
	# --- 1. No signage: rooms are told by their furniture, names stay as data only.
	var plates: int = 0
	var names: Dictionary = {}
	for room: RoomDiorama in b.rooms:
		names[room.room_name()] = true
		for child: Node in room.get_children():
			if child.name == "NamePlate":
				plates += 1
	_check(plates == 0 and names.size() == 16, "Room name plates removed; 16 identities kept as data")
	# --- 2. Pixel render.
	_check(game.pixel_scale == 2 and game.world_container.stretch_shrink == 2 and game.world_viewport.size == Vector2i(960, 540), "World renders on a 960x540 pixel grid and is upscaled 2x")
	_check(game.world_container.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Upscale uses nearest filtering (crisp pixels)")
	var middle: Vector2 = game.world_to_screen(Vector2(b.center_x(), b.global_position.y))
	_check(absf(middle.x - 960.0) < 6.0, "world_to_screen centres the building (x=%.1f)" % middle.x)
	# --- 3. Night palette, weather and lightning.
	_check(WorldBackdrop.SKY_TOP.get_luminance() < 0.08 and WorldBackdrop.SKY_LOW.get_luminance() < 0.12, "Night sky palette #0b0e14 - #141923")
	var weather: NightWeather = game.weather
	_check(weather._drops.size() == 40 and weather._ash.size() == 10, "Fifty preallocated rain/ash particles retain the storm atmosphere")
	game._apply_atmosphere()
	var dark: Color = b.rooms[0].modulate
	_check(dark.r <= 0.56 and dark.g <= 0.6 and dark.b <= 0.66 and dark.v >= 0.4, "Rooms keep ~50%% of their painted brightness (%s)" % dark)
	var before: int = weather.flash_count
	for i: int in range(60 * 16):
		weather.advance(1.0 / 60.0)
	_check(weather.flash_count > before, "Ambient lightning strikes within 16 s")
	weather.trigger_flash(1.0)
	game._apply_atmosphere()
	_check(b.rooms[0].modulate.v > dark.v + 0.15, "Lightning briefly lights the blacked-out rooms")
	for i: int in range(60):
		weather.advance(1.0 / 60.0)
	game._apply_atmosphere()
	_check(weather.flash == 0.0 and b.rooms[0].modulate.is_equal_approx(dark), "Flash fades back to the blackout")
	# --- 4. Lamp cones: additive, amber + emergency red, sway and flicker on tremors.
	var lamp_count: int = 0
	for prop: BuildingProp in b.props:
		if prop.kind == BuildingProp.Kind.LAMP or prop.kind == BuildingProp.Kind.CHANDELIER:
			lamp_count += 1
	var red: int = 0
	for light: Dictionary in b.lighting.lights:
		red += 1 if bool(light["emergency"]) else 0
	_check(b.lighting.lights.size() == lamp_count and lamp_count >= 14, "Every ceiling lamp casts a light cone (%d)" % lamp_count)
	_check((b.lighting.material as CanvasItemMaterial).blend_mode == CanvasItemMaterial.BLEND_MODE_ADD, "Light cones are additive light, not paint")
	_check(red >= 3 and lamp_count - red >= 10, "Warm amber lamps plus emergency-red rooms (%d red)" % red)
	game.game_camera.clear_shake()
	await _frames(150)
	var calm: float = 0.0
	for light: Dictionary in b.lighting.lights:
		calm = maxf(calm, absf(float(light["sway"])))
	_check(calm < 0.02, "Lamps hang still without tremor (%.3f)" % calm)
	game.game_camera.apply_shake(14.0, 0.9)
	var swing: float = 0.0
	var dimmest: float = 1.0
	var linked: bool = true
	for frame: int in range(40):
		await _frames(1)
		for light: Dictionary in b.lighting.lights:
			swing = maxf(swing, absf(float(light["sway"])))
			dimmest = minf(dimmest, float(light["level"]))
			var prop: BuildingProp = light["prop"]
			if prop.kind == BuildingProp.Kind.LAMP:
				linked = linked and absf(prop.sway - float(light["sway"])) < 0.01
	_check(swing > 0.08, "A quake slam swings the lamps (%.2f rad)" % swing)
	_check(dimmest < 0.5, "Tremors make the lights flicker (min level %.2f)" % dimmest)
	_check(linked, "Lamp shade and its light cone swing together")
	game.game_camera.clear_shake()
	# --- 5. Helmet beam.
	p.reset_player()
	await _frames(3)
	var beam: Node2D = p.get_node("HelmetBeam") as Node2D
	_check(beam != null and beam.show_behind_parent and (beam.material as CanvasItemMaterial).blend_mode == CanvasItemMaterial.BLEND_MODE_ADD, "Helmet lamp is an additive beam behind the body")
	_check(_beam_side(p) > 0.0 and _beam_inside(p, b), "Beam points where the player faces and stays inside the room")
	await _tap(KEY_A)
	await _frames(2)
	_check(_beam_side(p) < 0.0, "Turning around swings the beam")
	p.global_position.x = b.interior_left() + 20
	await _frames(1)
	_check(_beam_inside(p, b), "Beam is clipped at the outer wall")
	# --- 6. Hand-made sprite auto-loader.
	var directory: String = "user://sprite_registry_test"
	DirAccess.make_dir_recursive_absolute(directory)
	var image: Image = Image.create(16, 22, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.2, 0.2))
	for file: String in AssetRegistry.FILES.values():
		image.save_png(directory.path_join(file))
	var found: Dictionary = AssetRegistry.load_textures(directory)
	_check(found.size() == 4, "player/boss_storm/boss_quake/tileset PNGs are detected (%d)" % found.size())
	AssetRegistry.apply(game, found)
	var tiles: bool = true
	for room: RoomDiorama in b.rooms:
		tiles = tiles and room.wall_texture == found["tileset"]
	_check(p.custom_sprite == found["player"] and game.storm.boss_sprite == found["boss_storm"] and game.earthquake.boss_sprite == found["boss_quake"] and tiles, "Dropped sprites replace the procedural player, bosses and room walls")
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	w.advance_wave(w.intro_duration())
	w.building.pacing_enabled = false
	# Direct sprite drawing fixture; campaign itself never starts a double phase.
	game.storm.set_active(true)
	game.earthquake.set_active(true)
	game.storm.cue_attack(0.5)
	await _frames(12)
	game.storm.strike()
	game.earthquake.strike()
	await _frames(6)
	_check(game.storm.visible and game.earthquake.visible, "Sprite bosses still animate (wind-up/strike) without errors")
	p.custom_sprite = null
	game.storm.boss_sprite = null
	game.earthquake.boss_sprite = null
	for room: RoomDiorama in b.rooms:
		room.wall_texture = null
	for file: String in AssetRegistry.FILES.values():
		DirAccess.remove_absolute(directory.path_join(file))
	_check(AssetRegistry.load_textures("user://sprite_registry_missing").is_empty() and game.sprite_overrides.is_empty(), "Without files the dark procedural art is used")
	w.reset_cycle()
	# --- 7. Snappy, faster movement.
	_check(is_equal_approx(p.run_speed, 310.0 * 1.3) and p.dash_speed >= 980.0 * 1.15 and is_equal_approx(p.dash_cooldown, 0.38 * 0.8) and p.dash_duration == 0.25, "Run +30%, faster dash, cooldown -20%, 0.25 s i-frames kept")
	p.reset_player()
	await _frames(3)
	_key(KEY_D, true)
	await _frames(3)
	_check(p.velocity.x >= p.run_speed * 0.9, "Reaches 90%% of run speed within 3 frames (%.0f)" % p.velocity.x)
	_key(KEY_D, false)
	_key(KEY_A, true)
	await _frames(2)
	_check(p.velocity.x < 0.0, "Turns around within 2 frames (%.0f)" % p.velocity.x)
	_key(KEY_A, false)
	await _frames(6)
	p.reset_player()
	await _frames(3)
	var dash_start: float = p.global_position.x
	p.try_dash(Vector2.RIGHT)
	await _frames(16)
	_check(p.global_position.x - dash_start > 245.0 * 1.1, "Dash covers more ground (%.0f px)" % (p.global_position.x - dash_start))
	p.reset_player()
	await _frames(3)
	# Step 3-B replaced the 0.13 s snap with a physical arc (detailed in Step3LootSmoke).
	var start_y: float = p.global_position.y
	p.try_floor_shift(1)
	await _frames(3)
	var early: float = (start_y - p.global_position.y) / (start_y - (b.floor_y(1) - 0.5))
	var frames_up: int = 3
	while p.is_shifting and frames_up < 40:
		await _frames(1)
		frames_up += 1
	_check(early > 0.2, "Floor jump launches hard (%.0f%% of the way after 3 frames)" % (early * 100.0))
	_check(frames_up <= 24 and p.current_floor == 1, "2x W peaks above floor 01 in ~0.35 s (%d frames)" % frames_up)
	var arrival: float = 2.0
	for frame: int in range(40):
		await _frames(1)
		if p.is_on_floor():
			arrival = p.visual_scale.y
			break
	_check(arrival < 0.95, "Arriving on the new floor squashes the body (%.2f)" % arrival)
	await _frames(4)
	p.try_floor_shift(-1)
	var frames_down: int = 0
	while p.is_shifting and frames_down < 30:
		await _frames(1)
		frames_down += 1
	_check(frames_down <= 8 and p.current_floor == 0, "S floor-down takes ~0.11 s (%d frames)" % frames_down)
	# --- 8. Squash & stretch, lean, air pose, cape.
	p.reset_player()
	await _frames(4)
	_key(KEY_W, true)
	# physics_frame resumes before that frame's _physics_process: the jump lands on frame 2.
	await _frames(2)
	_check(p.visual_scale.y > 1.12 and p.visual_scale.x < 0.9, "Jumping stretches the body (%s)" % p.visual_scale)
	await _frames(4)
	_key(KEY_W, false)
	_check(p.air_pose > 0.4, "Airborne pose tucks the legs")
	var squash: float = 2.0
	for frame: int in range(60):
		await _frames(1)
		if p.is_on_floor():
			squash = p.visual_scale.y
			break
	_check(squash < 0.95, "Landing squashes the body (%.2f)" % squash)
	_key(KEY_D, true)
	await _frames(10)
	_check(p.lean > 0.08 and p._cape.x < -10.0, "Running right leans forward and the cape trails behind")
	_key(KEY_D, false)
	_key(KEY_A, true)
	await _frames(12)
	_check(p.lean < -0.08 and p._cape.x > 10.0, "Running left mirrors the lean and cape")
	_key(KEY_A, false)
	await _frames(10)
	# --- 9. Multi-segment bosses.
	var golem: DisasterBoss = game.earthquake
	golem.set_active(true)
	golem.advance(1.0)
	var idle: Dictionary = golem.golem_rig()
	golem.advance(0.5)
	var later: Dictionary = golem.golem_rig()
	var head_move: Vector2 = Vector2(later["head"]) - Vector2(idle["head"])
	var fist_move: Vector2 = Vector2(later["fist_l"]) - Vector2(idle["fist_l"])
	var rock_move: Vector2 = Vector2(Vector3(later["rocks"][0]).x, Vector3(later["rocks"][0]).y) - Vector2(Vector3(idle["rocks"][0]).x, Vector3(idle["rocks"][0]).y)
	_check(head_move.length() > 0.5 and fist_move.length() > 0.5 and rock_move.length() > 5.0 and head_move.distance_to(fist_move) > 0.5, "Golem head, fists and floating rocks move independently")
	var jaw_min: float = 1.0
	var jaw_max: float = 0.0
	var torso_min: float = INF
	var torso_max: float = -INF
	var smoke: int = 0
	for i: int in range(90):
		golem.advance(1.0 / 15.0)
		smoke = maxi(smoke, golem._particles.size())
		var sample: Dictionary = golem.golem_rig()
		jaw_min = minf(jaw_min, float(sample["jaw"]))
		jaw_max = maxf(jaw_max, float(sample["jaw"]))
		torso_min = minf(torso_min, Vector2(sample["torso"]).y)
		torso_max = maxf(torso_max, Vector2(sample["torso"]).y)
	_check(jaw_max > 0.4 and jaw_min < 0.3 and smoke > 3, "Idle: the jaw opens and breathes out smoke (jaw %.2f-%.2f, %d puffs)" % [jaw_min, jaw_max, smoke])
	_check(torso_max - torso_min > 6.0, "Idle: heavy breathing lifts the torso (%.1f px)" % (torso_max - torso_min))
	idle = golem.golem_rig()
	_check(Vector2(idle["elbow_l"]).x < Vector2(idle["shoulder_l"]).x and Vector2(idle["elbow_r"]).x > Vector2(idle["shoulder_r"]).x, "Elbows bend outward")
	var bounds_ok: bool = _boss_on_screen(golem)
	golem.cue_attack(0.7)
	golem.advance(0.6)
	var windup: Dictionary = golem.golem_rig()
	_check(Vector2(windup["fist_l"]).y < Vector2(windup["shoulder_l"]).y and Vector2(windup["fist_r"]).y < Vector2(windup["shoulder_r"]).y, "Wind-up raises both fists above the shoulders")
	_check(float(windup["eye_glow"]) > float(idle["eye_glow"]) + 0.3 and Vector2(windup["torso"]).x > Vector2(idle["torso"]).x + 5.0, "Wind-up: eyes flare like embers and the body pulls back")
	_check(Vector2(windup["elbow_l"]).x < Vector2(windup["shoulder_l"]).x and Vector2(windup["elbow_r"]).x > Vector2(windup["shoulder_r"]).x, "Raised arms keep their elbows outward")
	bounds_ok = bounds_ok and _boss_on_screen(golem)
	golem._particles.clear()
	golem.strike()
	golem.advance(0.08)
	var slam: Dictionary = golem.golem_rig()
	_check(float(slam["plant"]) > 0.9 and Vector2(slam["fist_l"]).y > -110.0 and Vector2(slam["fist_l"]).x < -150.0, "Slam drives the fists into the ground at the building")
	_check(golem._particles.size() >= 20, "Impact frame throws a dust and rock burst (%d)" % golem._particles.size())
	bounds_ok = bounds_ok and _boss_on_screen(golem)
	golem.advance(0.5)
	_check(float(golem.golem_rig()["plant"]) == 0.0, "Golem recovers to idle after the slam")
	_check(bounds_ok, "Golem stays on screen in idle, wind-up and slam poses")
	var storm: DisasterBoss = game.storm
	storm.set_active(true)
	storm.advance(1.0)
	var calm_rig: Dictionary = storm.storm_rig()
	var calm_rings: Array = calm_rig["rings"]
	_check(calm_rings.size() >= 10 and calm_rings.size() <= 12, "Storm spine has 10-12 segments (%d)" % calm_rings.size())
	# S-shape = the spine's curvature (second difference along the rings) flips sign.
	var curves: int = 0
	for sample: int in range(12):
		storm.advance(0.13)
		var xs: Array = storm.storm_rig()["rings"]
		var flips: int = 0
		var last: float = 0.0
		for i: int in range(1, xs.size() - 1):
			var bend: float = Vector2(xs[i - 1]["center"]).x - 2.0 * Vector2(xs[i]["center"]).x + Vector2(xs[i + 1]["center"]).x
			if absf(bend) > 0.5:
				if last != 0.0 and signf(bend) != signf(last):
					flips += 1
				last = bend
		curves += 1 if flips >= 1 else 0
	_check(curves >= 10, "Spine bends in a living S-curve (%d/12 samples)" % curves)
	var calm_width: float = _mean_width(storm.storm_rig())
	storm.advance(0.37)
	_check(absf(_mean_width(storm.storm_rig()) - calm_width) > 0.5, "Rings breathe wider and narrower")
	bounds_ok = _boss_on_screen(storm)
	# Compare each pose with the same instant without the attack (the spine never rests).
	storm.cue_attack(0.7)
	storm.advance(0.6)
	var charged: Dictionary = storm.storm_rig()
	var saved_charge: float = storm._charge_left
	storm._charge_left = 0.0
	var uncharged: Dictionary = storm.storm_rig()
	storm._charge_left = saved_charge
	_check(_mean_width(charged) < _mean_width(uncharged) * 0.8 and Array(charged["arcs"]).size() > 0, "Wind-up: the vortex contracts and crackles with lightning")
	bounds_ok = bounds_ok and _boss_on_screen(storm)
	storm._particles.clear()
	storm.strike()
	storm.advance(0.2)
	var burst: Dictionary = storm.storm_rig()
	var saved_slam: float = storm._slam_left
	storm._slam_left = 0.0
	var still: Dictionary = storm.storm_rig()
	storm._slam_left = saved_slam
	_check(_mean_top_x(burst) > _mean_top_x(still) + 20.0 and _mean_width(burst) > _mean_width(still) * 1.1, "Burst: the funnel lunges toward the building and widens")
	_check(storm._particles.size() >= 10, "Burst roars out wind streaks (%d)" % storm._particles.size())
	bounds_ok = bounds_ok and _boss_on_screen(storm)
	_check(bounds_ok, "Storm stays on screen in idle, wind-up and burst poses")
	golem.set_active(false)
	storm.set_active(false)
	# --- 10. Neon projectiles, warnings and crisp labels.
	var glows: bool = true
	for projectile: HazardProjectile in game.projectiles.entries:
		glows = glows and projectile.glow != null and projectile.glow.show_behind_parent and (projectile.glow.material as CanvasItemMaterial).blend_mode == CanvasItemMaterial.BLEND_MODE_ADD
	_check(glows and game.projectiles.get_child_count() == 128, "All 128 pooled shots carry an additive glow (pool size unchanged)")
	var probe: HazardProjectile = game.projectiles.entries[0]
	probe.attack = w._attack(HazardAttack.Kind.GLASS, 0, Vector2.ZERO, Vector2.ZERO)
	var storm_glow: Color = probe.glow_color()
	probe.attack.source = 1
	var quake_glow: Color = probe.glow_color()
	probe.attack = null
	_check(storm_glow.b > storm_glow.r and quake_glow.r > quake_glow.b and HazardProjectile.CORE.r > 0.9 and HazardProjectile.CORE.g < 0.4, "Electric-blue storm rim, ember quake rim, bright red core")
	_check(HazardProjectile.TRAIL_LENGTH == 4, "Four-point motion trails bound projectile drawing cost")
	_check(TelegraphSystem.STORM_WARNING.b > TelegraphSystem.STORM_WARNING.r and TelegraphSystem.QUAKE_WARNING.r > TelegraphSystem.QUAKE_WARNING.b, "Warnings use neon storm-blue and ember colours")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(w.intro_duration())
	w.building.pacing_enabled = false
	p.current_floor = 1
	game.storm.plan_pattern(w, 3, 1)
	await _frames(3)
	_check(game.labels.drawn >= 2, "Corridor label and boss attack name are drawn in screen space (%d)" % game.labels.drawn)
	w.reset_cycle()
	p.reset_player()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(argument.trim_prefix("--capture="))
	print("STEP27_RESULT checks=%d failures=%d" % [checks, failures])
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
	# Exclusive fullscreen yields an exact 1920x1080 frame (borderless trims a few px).
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	await _frames(40)
	_check(Vector2i(root.get_texture().get_size()) == Vector2i(1920, 1080) or DisplayServer.screen_get_size() != Vector2i(1920, 1080), "Captures are full 1920x1080 frames (%s)" % root.get_texture().get_size())
	var w: DisasterWaveManager = game.waves
	var p: SiegePlayer = game.player
	w.reset_cycle()
	p.reset_player()
	await _frames(20)
	await _save(directory, "blackout-idle.png")
	game.weather.trigger_flash(1.0)
	await _frames(1)
	await _save(directory, "lightning.png")
	await _frames(40)
	_key(KEY_D, true)
	await _frames(10)
	await _save(directory, "run-lean-beam.png")
	_key(KEY_W, true)
	await _frames(3)
	await _save(directory, "jump-stretch.png")
	_key(KEY_W, false)
	await _frames(5)
	await _tap(KEY_W)
	await _frames(3)
	await _save(directory, "floor-up-phase.png")
	_key(KEY_D, false)
	await _frames(30)
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	w.advance_wave(w.intro_duration())
	w.building.pacing_enabled = false
	await _frames(30)
	w.storm_burst()
	w.quake_burst()
	await _frames(30)
	await _save(directory, "boss-windup.png")
	await _frames(13)
	await _save(directory, "boss-strike.png")
	await _frames(35)
	await _save(directory, "neon-bullets.png")
	game.game_camera.apply_shake(14.0, 0.8)
	await _frames(8)
	await _save(directory, "lamps-swing.png")

func _boss_on_screen(boss: DisasterBoss) -> bool:
	var local: Rect2 = boss.pose_bounds()
	var a: Vector2 = game.world_to_screen(boss.global_position + local.position)
	var z: Vector2 = game.world_to_screen(boss.global_position + local.end)
	var ok: bool = a.x >= 0.0 and z.x <= 1920.0 and a.y >= HUD_TOP and z.y <= HUD_BOTTOM
	if not ok:
		print("BOSS_BOUNDS kind=%d %s .. %s" % [boss.kind, a, z])
	return ok

func _mean_width(rig: Dictionary) -> float:
	var total: float = 0.0
	for ring: Dictionary in rig["rings"]:
		total += float(ring["width"])
	return total / Array(rig["rings"]).size()

func _mean_top_x(rig: Dictionary) -> float:
	var rings: Array = rig["rings"]
	var total: float = 0.0
	for i: int in range(rings.size() / 2, rings.size()):
		total += Vector2(rings[i]["center"]).x
	return total / float(rings.size() - rings.size() / 2)

func _beam_side(p: SiegePlayer) -> float:
	var centroid: Vector2 = Vector2.ZERO
	var points: PackedVector2Array = p.beam_polygon()
	for point: Vector2 in points:
		centroid += point / points.size()
	return centroid.x - p.global_position.x

func _beam_inside(p: SiegePlayer, b: ApartmentBuilding) -> bool:
	var floor_line: float = b.floor_y(p.current_floor)
	for point: Vector2 in p.beam_polygon():
		if point.x < b.interior_left() - 0.01 or point.x > b.interior_right() + 0.01 or point.y < floor_line - 200.01 or point.y > floor_line + 0.01:
			return false
	return true

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
