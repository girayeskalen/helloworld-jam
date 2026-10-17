extends SceneTree
var game: MainGame
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(3)
	game.loot.set_physics_process(false)
	game.mechanics.set_physics_process(false)
	_timing()
	_pacing()
	await _equipment()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP45_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _fresh(battle: bool = true) -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.mechanics.set_physics_process(false)
	game.loot.set_physics_process(false)
	if battle:
		game.waves.start_next_wave()
		game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false

func _timing() -> void:
	_fresh(false)
	var w: DisasterWaveManager = game.waves
	_check(game.earthquake.get_parent() is Control and game.earthquake.get_parent().clip_contents and game.earthquake.get_parent().size.y == game.backdrop.ground_y, "Boss entrance/retreat is occluded below the actual ground line")
	_check(w.siege_duration == 50.0 and w.build_duration == 5.0, "Exact 50s battle / 5s construction defaults (Step 7)")
	for wave: int in range(4):
		w.start_next_wave()
		_check(w.wave_number == wave+1 and w.mode == wave and w.state == DisasterWaveManager.State.WAVE_INTRO, "Campaign has locked boss order %d and a distinct entry phase" % (wave+1))
		var boss: DisasterBoss = [game.storm,game.earthquake,game.flood,game.titan][wave]
		var intro: float = w.intro_duration()
		var entry_y: float = boss.position.y
		w.advance_wave(.6)
		# The titan does not rise: its entry is the visible four-element fusion.
		var moved: bool = boss.fusion > 0.0 if wave == 3 else boss.position.y != entry_y
		_check(moved and w.siege_remaining == 50 and game.projectiles.active_count() == 0, "Entry visibly moves boss without spending fight time or attacking")
		w.advance_wave(intro - .601)
		_check(w.state == DisasterWaveManager.State.WAVE_INTRO, "Entry cannot finish before %.1fs" % intro)
		w.advance_wave(.001)
		_check(w.state == DisasterWaveManager.State.SIEGE_PHASE and boss.position.is_equal_approx(boss._home), "Entry lands exactly on authored boss rig position")
		w.start_siege(DisasterWaveManager.Mode.STORM)
		w.test_upgrades()
		_check(w.mode == wave and not game.upgrades.pending, "Normal API / U cannot restart or rewind active wave")
		w.damage_boss_endurance(100)
		_check(w.boss_endurance == 100 and w.state == DisasterWaveManager.State.SIEGE_PHASE, "Normal combat cannot end early through a debug endurance shortcut")
		w.advance_wave(49.999)
		_check(w.state == DisasterWaveManager.State.SIEGE_PHASE, "Battle remains active until 50 seconds")
		var shot: HazardProjectile = _shot(Vector2(500,600), Vector2.ZERO)
		w.advance_wave(.001)
		_check(w.state == DisasterWaveManager.State.WAVE_OUTRO and not shot.active and game.mechanics.particles.size() > 0, "50s starts outro and dissolves bullets into visible particles")
		_check(boss.visible and not game.upgrades.pending and w.phase_label().begins_with("AFET DALGASI PÜSKÜRTÜLDÜ"), "Retreat keeps boss visible, defers cards and shows defeat heading")
		w.advance_wave(.5)
		_check(boss.retreat > 0.4 and (boss.scale.x < .7 if wave == 0 else boss.position.y > boss._home.y), "Retreat narrows/ascends storm or sinks the other bosses")
		w.advance_wave(.499)
		_check(w.state == DisasterWaveManager.State.WAVE_OUTRO and not game.upgrades.pending, "Outro remains uninterrupted for 1.0s")
		w.advance_wave(.001)
		if wave < 3:
			_check(game.upgrades.pending and not boss.visible and game.upgrade_overlay.modulate.a == 0, "Cards begin fade-in only after boss exits")
			game.upgrade_overlay._process(.175)
			_check(game.upgrade_overlay.modulate.a > 0 and game.upgrade_overlay.modulate.a < 1, "Card opacity fades instead of popping")
			w.advance_wave(200)
			_check(w.preparation_remaining == 5, "Selection does not consume the 5-second construction window")
			game.upgrades.offers.assign([wave,wave+1,wave+2])
			game.upgrades.choose(0)
			w.advance_wave(4.999)
			_check(w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE, "Build window remains usable at 4.999 seconds")
			w.advance_wave(.001)
			_check(w.state == DisasterWaveManager.State.WAVE_INTRO and w.mode == wave+1, "Exactly 5 seconds triggers the next boss once")
			# Next loop continues the already-started entry, F is deliberately idempotent.
		else:
			_check(w.victory and w.completed_waves == 4 and not game.upgrades.pending, "Fourth outro ends in victory, no fifth wave or card")
			w.start_next_wave()
			_check(w.victory and w.wave_number == 4, "Victory cannot loop back to storm")

func _pacing() -> void:
	_fresh()
	var b: ApartmentBuilding = game.building
	b.begin_siege_pacing()
	b.pacing_enabled = true
	var cap_ok: bool = true
	var first: float = -1
	var grace_ok: bool = true
	var snapshots: Dictionary = {}
	for tick: int in range(90*60):
		b.advance_wear(1.0/60.0)
		# Pathological simultaneous sixteen-room slam: exercise the shared gate.
		if tick % 6 == 0:
			for room: RoomDiorama in b.rooms: room.apply_damage(1000)
		cap_ok = cap_ok and b.repair_count() <= 3
		for room: RoomDiorama in b.rooms:
			if room.needs_repair() and not snapshots.has(room):
				snapshots[room] = [tick,room.hp]
				if first < 0: first = tick/60.0
			if snapshots.has(room) and tick-int(snapshots[room][0]) < 599:
				grace_ok = grace_ok and is_equal_approx(room.hp,float(snapshots[room][1]))
	_check(cap_ok, "Even sixteen simultaneous massive impacts never exceed three actual damaged rooms")
	_check(grace_ok and first >= 7.0, "Damage budget prevents instant critical rooms and gives every alert ten seconds grace")
	_check(b.collapsed_count() > 0, "Ignoring warnings eventually destroys rooms; cap is not permanent invincibility")
	_fresh()
	b.begin_siege_pacing()
	b.pacing_enabled = true
	for tick: int in range(22*60): b.advance_wear(1.0/60.0)
	_check(b.repair_count() >= 1 and b.repair_count() <= 3, "Storm passive wear alone produces a reachable repair objective within 22 seconds")
	var room: RoomDiorama = b.rooms[0]
	room.repair(45)
	_check(not room.needs_repair(), "One standard cement repair clears the first passive warning")
	var body_before: Vector2 = b.floor_bodies[0].position
	var floor_before: float = b.floor_y(0)
	b._process(.1)
	_check(b.sway.length() > 0.0 and b.floor_y(0) == floor_before and b.floor_bodies[0].position == body_before, "Cosmetic sway leaves physics floors fixed")

func _equipment() -> void:
	_fresh()
	var m: SiegeMechanics = game.mechanics
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	game.building.rooms[15].hp = 40
	m.advance(6.499,6.499)
	_check(m.drone_repairs == 0,"Drone waits until 6.5 seconds")
	m.advance(.001,.001)
	_check(m.drone_repairs == 1 and game.building.rooms[15].hp == 85 and game.loot.materials() == 0,"Drone beams free repair into the weakest remote room")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.SONIC_DASH)
	await _frames(3)
	game.player.try_dash(Vector2.RIGHT)
	var bullet: HazardProjectile = _shot(game.player.global_position+Vector2(0,-24),Vector2.ZERO)
	game.projectiles._physics_process(.001)
	_check(not bullet.active and game.player.health == 100,"Sonic dash destroys an intersecting real bullet without damage")
	_fresh(false)
	_check(Engine.time_scale == 1 and m.time_remaining == 0 and m.freeze_remaining == 0 and not m.floor_guard,"Reset clears local time and transition guards")

func _shot(point: Vector2, velocity: Vector2, floor_index: int = 0) -> HazardProjectile:
	var a: HazardAttack = HazardAttack.new()
	a.origin = point
	a.velocity = velocity
	a.floor_index = floor_index
	a.floor_y = game.building.floor_y(floor_index)
	a.lifetime = 10.0
	# Explicit armed fixture; warning rejection is covered separately by Step2Smoke.
	a.warning_confirmed = true
	a.warning_id = 99
	a.warning_elapsed = .65
	return game.projectiles.spawn(a)

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	await _frames(30)
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.ORBITALS)
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.DOME)
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AWARE_BAG)
	game.loot.messages.clear()
	game.building.rooms[4].repair(0,true)
	game.building.rooms[8].repair(0,true)
	game.building.rooms[9].chain_support = true
	game.building.rooms[9]._refresh_state(true)
	game.building.wear_clock = 45
	var debris: HazardProjectile = _shot(Vector2(1550,600),Vector2.ZERO,2)
	debris.attack.radius = 27
	debris.attack.kind = HazardAttack.Kind.CONCRETE
	game.projectiles.dissolve(debris)
	game.mechanics.beam(game.mechanics.drone_position,game.player.global_position+Vector2(180,-26),SiegeMechanics.CYAN)
	await _save(directory,"01-active-equipment.png")
	game.waves.finish_wave()
	game.waves.advance_wave(1.25)
	await _save(directory,"02-storm-retreat.png")
	game.waves.advance_wave(1.25)
	for group: int in range(3):
		game.upgrades.offers.assign([group,3+group*2,4+group*2])
		game.upgrade_overlay._refresh()
		await _frames(25)
		await _save(directory,"03-cards-%d.png" % group)
	game.upgrades.pending = false
	game.upgrade_overlay.hide()
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE,true)
	game.waves.advance_wave(.75)
	await _save(directory,"04-golem-entry.png")
	game.waves.advance_wave(.75)
	game.waves.finish_wave()
	game.waves.advance_wave(1.1)
	game.mechanics.retreat_dust(.1)
	game.mechanics.advance(.35,.35)
	await _save(directory,"05-golem-retreat.png")

func _save(directory: String, name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(directory.path_join(name)) == OK,"Native capture " + name)

func _frames(count: int) -> void:
	for i: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
