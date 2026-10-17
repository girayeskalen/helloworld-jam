extends SceneTree
## Step 3: 4x4 apartment framing and the storm boss bullet-hell patterns
## (vortex ring, X crossfire, corridor + jump waves, telegraphed wind gust).
var checks: int = 0
var failures: int = 0
var game: MainGame
var launched: Array[HazardAttack] = []

const HUD_TOP: float = 165.0
const HUD_BOTTOM: float = 990.0

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
	# --- Framing: whole 4x4 building and both bosses fit between the HUD bars.
	var building_box: Rect2 = Rect2(b.global_position + Vector2(-82, -100), Vector2(b.building_width + 112, b.floor_count * b.floor_height + 130))
	var building_screen: Rect2 = _screen_rect(building_box)
	_check(building_screen.position.x >= 0 and building_screen.end.x <= 1920 and building_screen.position.y >= HUD_TOP and building_screen.end.y <= HUD_BOTTOM, "4x4 building fits between HUD bars %s" % building_screen)
	for boss: DisasterBoss in [game.storm, game.earthquake]:
		# Idle pose of the articulated rig (Step 2.7 bosses move; measure the real pose).
		boss.set_active(true)
		boss.advance(1.0)
		var extent: Rect2 = _screen_rect(Rect2(boss.global_position + boss.pose_bounds().position, boss.pose_bounds().size))
		_check(extent.position.x >= 0 and extent.end.x <= 1920 and extent.position.y >= HUD_TOP and extent.end.y <= HUD_BOTTOM, "Boss %d fits on screen %s" % [boss.kind, extent])
		_check(not extent.intersects(_screen_rect(Rect2(b.global_position, Vector2(b.building_width, b.floor_count * b.floor_height)))), "Boss %d idles outside the facade" % boss.kind)
		boss.set_active(false)
	var backdrop: WorldBackdrop = game.backdrop
	_check(backdrop.view_size.x * game.game_camera.zoom.x * game.pixel_scale >= 1919.0 and backdrop.view_size.y * game.game_camera.zoom.y * game.pixel_scale >= 1079.0, "Backdrop covers the zoomed-out view")
	_check(absf(backdrop.ground_y - (b.global_position.y + b.floor_count * b.floor_height + 37)) < 1.0, "Backdrop ground meets the building plinth")
	# --- Storm cycle: new patterns are in rotation, labels and density.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	var labels: Dictionary = {}
	var total: int = 0
	for index: int in range(5):
		game.telegraphs.clear()
		game.storm.plan_pattern(w, index, 1)
		labels[game.storm.pattern_label] = true
		total += game.telegraphs.pending.size()
	game.telegraphs.clear()
	for label: String in BossPatterns.STORM_LABELS:
		_check(labels.has(label), "Storm cycle contains " + label)
	# Step 7 storm: five geometric choreographies over their authored beats (tempo 1.0).
	var cycle_seconds: float = 0.0
	for beat: float in BossPatterns.STORM_BEATS: cycle_seconds += beat
	var density: float = float(total) / cycle_seconds
	_check(density > 4.0 and density < 9.0 and density * DisasterWaveManager.CLIMAX_TEMPO < 12.0, "Storm bullet density is dense but bounded, also at the climax (%.2f shots/s)" % density)
	# --- Earthquake difficulty untouched.
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)

	w.building.pacing_enabled = false
	var quake_labels: Array = []
	var beats: float = 0.0
	for index: int in range(4):
		game.telegraphs.clear()
		game.earthquake.plan_pattern(w, index, 0)
		quake_labels.append(game.earthquake.pattern_label)
		beats += game.earthquake.next_delay
	game.telegraphs.clear()
	_check(quake_labels == Array(BossPatterns.QUAKE_LABELS) and beats / 4.0 > 1.7 and beats / 4.0 < 2.5, "Seismic golem runs its four Step 7 choreographies in order (mean beat %.2f s)" % (beats / 4.0))
	# --- a) Vortex ring.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	p.current_floor = 1
	p.global_position = Vector2(b.global_position.x + 200, b.floor_y(1) - .5)
	await _frames(3)
	BossPatterns.vortex(w, 1, 0, 10)
	var ring: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var leads: int = 0
	var starts: Dictionary = {}
	var contained: bool = true
	var rotating: bool = true
	var threatens: int = 0
	var floor_line: float = b.floor_y(1)
	for a: HazardAttack in ring:
		leads += 1 if a.lead else 0
		starts[snappedf(a.spiral_angle, 0.001)] = true
		var t: float = 0.0
		var low: bool = false
		while t <= a.lifetime:
			var q: Vector2 = a.point_at(t)
			contained = contained and q.y > floor_line - 183 and q.y < floor_line - 12 and q.x > b.global_position.x and q.x < b.global_position.x + b.building_width
			low = low or q.y > floor_line - 57
			t += .05
		threatens += 1 if low else 0
		var d0: Vector2 = a.point_at(0) - a.origin
		var d1: Vector2 = a.point_at(.5) - a.origin
		rotating = rotating and absf(angle_difference(d0.angle(), d1.angle())) > .2 and d1.length() > d0.length()
	_check(ring.size() == 10 and leads == 1 and starts.size() == 10, "Vortex ring: 10 evenly spaced shots and one eye")
	_check(absf(ring[0].origin.x - p.global_position.x) >= 240, "Vortex eye never opens on top of the player")
	_check(rotating, "Vortex shots rotate while the ring expands")
	_check(contained, "Vortex ring stays inside its own floor and the building walls")
	_check(threatens >= 5, "Vortex sweeps low enough to threaten a standing player (%d/10)" % threatens)
	game.telegraphs.clear()
	BossPatterns.vortex(w, 1, 1, 12)
	var reverse: bool = game.telegraphs.pending.size() == 12 and signf(game.telegraphs.pending[0].spiral_spin) != signf(ring[0].spiral_spin)
	_check(reverse, "Alternate vortex fires 12 shots spinning the other way")
	launched.clear()
	await _frames(30)
	_check(launched.size() == 0 and game.projectiles.active_count() == 0, "Vortex is harmless during its warning")
	await _frames(6)
	_check(launched.size() == 12, "Vortex launches the complete ring after its 0.55 s warning")
	# --- b) Crossfire X.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	BossPatterns.crossfire(w, 2, 0)
	var cross: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var from_window: Array[HazardAttack] = []
	var from_roof: Array[HazardAttack] = []
	var in_band: bool = true
	var floor2: float = b.floor_y(2)
	for a: HazardAttack in cross:
		if a.pattern != HazardAttack.Pattern.CROSSFIRE:
			in_band = false
		if a.motion == HazardAttack.Motion.LINEAR:
			if a.velocity.x > 0:
				from_window.append(a)
			else:
				from_roof.append(a)
		for s: int in range(11):
			var q: Vector2 = a.point_at(a.lifetime * s / 10.0)
			in_band = in_band and q.y >= floor2 - 190 and q.y <= floor2
	var crossings: int = 0
	var rising: bool = true
	for a: HazardAttack in from_window:
		rising = rising and a.velocity.y < 0
		for c: HazardAttack in from_roof:
			rising = rising and c.velocity.y < 0
			if Geometry2D.segment_intersects_segment(a.origin, a.point_at(a.lifetime), c.origin, c.point_at(c.lifetime)) != null:
				crossings += 1
	_check(cross.size() == 5 and from_window.size() == 2 and from_roof.size() == 2, "Crossfire: window shots, roof-current shots and a thrown pot")
	_check(crossings >= 3, "Window and roof-current paths intersect in an X (%d crossings)" % crossings)
	_check(in_band, "Crossfire never leaves its floor band")
	game.telegraphs.clear()
	BossPatterns.crossfire(w, 2, 1)
	var falling: bool = true
	for a: HazardAttack in game.telegraphs.pending:
		if a.motion == HazardAttack.Motion.LINEAR:
			falling = falling and a.velocity.y > 0
	_check(rising and falling, "Alternate crossfire mirrors the X from rising to diving")
	# --- c) Corridor sweep + jump waves on the escape floors.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	p.reset_player()
	p.current_floor = 1
	p.global_position = Vector2(b.center_x(), b.floor_y(1) - .5)
	await _frames(3)
	launched.clear()
	BossPatterns.corridor(w, 1, 0)
	var row_floor: int = -1
	var wave_floors: Dictionary = {}
	var low_waves: bool = true
	for a: HazardAttack in game.telegraphs.pending:
		if a.pattern == HazardAttack.Pattern.FULL_ROW:
			row_floor = a.floor_index
			_check(a.warning_duration == 1.0, "Corridor sweep keeps the 1.0 s evacuation warning")
		elif a.pattern == HazardAttack.Pattern.CORRIDOR_WAVE:
			wave_floors[a.floor_index] = true
			low_waves = low_waves and absf(a.origin.y - (a.floor_y - 16)) < .1 and a.velocity.y == 0
	_check(row_floor == 1 and wave_floors.has(0) and wave_floors.has(2) and low_waves, "Corridor sweeps the player's floor; floors above and below get low rolling waves")
	await _tap(KEY_W)
	await _frames(6)
	await _tap(KEY_W)
	await _frames(22)
	_check(p.current_floor == 2 and game.projectiles.active_count() == 0, "2x W escapes to the upper floor before the sweep arms")
	await _frames(85)
	_check(p.health == p.max_health, "Escaping by double jump avoids the corridor sweep")
	var debris_launched: bool = false
	for a: HazardAttack in launched:
		debris_launched = debris_launched or (a.kind == HazardAttack.Kind.DEBRIS and a.floor_index == 2)
	var probe: HazardProjectile = game.projectiles.entries[game.projectiles.entries.size() - 1]
	probe.attack = w._attack(HazardAttack.Kind.DEBRIS, 2, Vector2(p.global_position.x, b.floor_y(2) - 16), Vector2.ZERO)
	probe.global_position = probe.attack.origin
	p.previous_position = p.global_position
	_check(probe.crosses_player(p, probe.global_position), "Rolling debris hits a grounded player")
	p.global_position.y -= 60
	p.previous_position = p.global_position
	_check(not probe.crosses_player(p, probe.global_position), "A normal jump clears the rolling debris")
	probe.deactivate()
	_check(debris_launched, "Rolling debris was launched on the escape floor")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	p.current_floor = 2
	p.global_position = Vector2(b.center_x(), b.floor_y(2) - .5)
	await _frames(3)
	BossPatterns.corridor(w, 2, 1)
	await _tap(KEY_S)
	await _frames(20)
	_check(p.current_floor == 1, "S escapes the corridor downward")
	await _frames(95)
	_check(p.health == p.max_health, "Escaping by S avoids the corridor sweep")
	# --- d) Telegraphed wind gust.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	p.current_floor = 0
	p.global_position = Vector2(b.center_x() - 300, b.floor_y(0) - .5)
	await _frames(3)
	w.storm_gust()
	_check(game.telegraphs.gust_warning_left >= .55 and game.telegraphs.gust_warning_left <= .75, "Gust is announced with a 0.55-0.75 s warning")
	var before: float = p.global_position.x
	await _frames(36)
	_check(absf(p.wind_velocity) < .001 and absf(p.global_position.x - before) < 1, "Gust does not push during its warning")
	await _frames(10)
	before = p.global_position.x
	await _frames(30)
	var drift: float = p.global_position.x - before
	_check(drift > 40, "Idle player drifts with the gust (%.1f px in 0.5 s)" % drift)
	before = p.global_position.x
	_key(KEY_A, true)
	await _frames(30)
	_key(KEY_A, false)
	var against: float = before - p.global_position.x
	# Windless running covers run_speed * 0.5 s; the gust must take a real bite out of it.
	_check(against > 20 and against < p.run_speed * 0.5 * 0.75, "Running into the gust still makes slower progress (%.1f px)" % against)
	p.try_dash(Vector2.LEFT)
	await _frames(1)
	_check(is_equal_approx(p.velocity.x, -p.dash_speed), "Dash keeps full speed against the gust")
	await _frames(150)
	_check(absf(p.wind_velocity) < .001, "Gust fades after its duration")
	w.storm_gust()
	await _frames(50)
	_key(KEY_R, true)
	await _frames(2)
	_key(KEY_R, false)
	_check(absf(p.wind_velocity) < .001 and game.telegraphs.gust_warning_left == 0 and game.telegraphs.gust_active_left == 0, "R clears an active gust")
	# --- Full storm beat-cycle keeps every shot warned and the pool bounded.
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	p.max_health = 10000
	p.health = 10000
	launched.clear()
	for index: int in range(6):
		w.storm_burst()
		await _frames(int(w.storm_interval * 60))
	var bad: int = 0
	for a: HazardAttack in launched:
		var minimum: float = 1.0 if a.pattern == HazardAttack.Pattern.FULL_ROW else .55
		if a.warning_elapsed < minimum - .00001:
			bad += 1
	_check(launched.size() > 30 and bad == 0 and game.projectiles.rejected_count == 0, "One full storm cycle: %d warned launches, pool peak %d" % [launched.size(), game.projectiles.peak_active])
	p.max_health = 100
	w.reset_cycle()
	p.reset_player()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(argument.trim_prefix("--capture="))
	print("STEP3_RESULT checks=%d failures=%d" % [checks, failures])
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
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	await _frames(40)
	var w: DisasterWaveManager = game.waves
	w.reset_cycle()
	game.player.reset_player()
	await _frames(4)
	await _save(directory, "apartment-4x4.png")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	game.player.global_position.x += 500
	BossPatterns.vortex(w, 0, 0, 12)
	await _frames(28)
	await _save(directory, "vortex-warning.png")
	await _frames(40)
	await _save(directory, "vortex-ring.png")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	BossPatterns.crossfire(w, 1, 0)
	await _frames(28)
	await _save(directory, "crossfire-warning.png")
	await _frames(50)
	await _save(directory, "crossfire.png")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	BossPatterns.corridor(w, 0, 0)
	await _frames(40)
	await _save(directory, "corridor-warning.png")
	await _frames(32)
	await _save(directory, "corridor-sweep.png")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)

	w.building.pacing_enabled = false
	w.storm_gust()
	BossPatterns.fan(w, 1, 0)
	await _frames(25)
	await _save(directory, "gust-warning.png")
	await _frames(40)
	await _save(directory, "gust-active.png")
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)

	w.building.pacing_enabled = false
	w.storm_burst()
	w.quake_burst()
	await _frames(55)
	await _save(directory, "chaos-4x4.png")

## World rect -> 1920x1080 screen rect through the camera and the pixel upscale.
func _screen_rect(world: Rect2) -> Rect2:
	var a: Vector2 = game.world_to_screen(world.position)
	return Rect2(a, game.world_to_screen(world.end) - a)

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
