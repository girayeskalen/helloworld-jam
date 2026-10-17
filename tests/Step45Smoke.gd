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
	quit(0 if failures == 0 else 1)

func _fresh(battle: bool = true) -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.mechanics.set_physics_process(false)
	game.loot.set_physics_process(false)
	if battle:
		game.waves.start_next_wave()
		game.waves.advance_wave(1.5)
	game.building.pacing_enabled = false

func _timing() -> void:
	_fresh(false)
	var w: DisasterWaveManager = game.waves
	_check(game.earthquake.get_parent() is Control and game.earthquake.get_parent().clip_contents and game.earthquake.get_parent().size.y == game.backdrop.ground_y, "Boss entrance/retreat is occluded below the actual ground line")
	_check(w.siege_duration == 90.0 and w.build_duration == 7.0, "Exact 90s battle / 7s construction defaults")
	for wave: int in range(5):
		w.start_next_wave()
		_check(w.wave_number == wave+1 and w.mode == wave and w.state == DisasterWaveManager.State.WAVE_INTRO, "Campaign has locked boss order %d and a distinct entry phase" % (wave+1))
		var boss: DisasterBoss = [game.storm,game.earthquake,game.storm,game.flood,game.fire][wave]
		var entry_y: float = boss.position.y
		w.advance_wave(.6)
		_check(boss.position.y != entry_y and w.siege_remaining == 90 and game.projectiles.active_count() == 0, "Entry visibly moves boss without spending fight time or attacking")
		w.advance_wave(.599)
		_check(w.state == DisasterWaveManager.State.WAVE_INTRO, "Entry cannot finish before 1.2s")
		w.advance_wave(.001)
		_check(w.state == DisasterWaveManager.State.SIEGE_PHASE and boss.position.is_equal_approx(boss._home), "Entry lands exactly on authored boss rig position")
		w.start_siege(DisasterWaveManager.Mode.STORM)
		w.test_upgrades()
		_check(w.mode == wave and not game.upgrades.pending, "Normal API / U cannot restart or rewind active wave")
		w.damage_boss_endurance(100)
		_check(w.boss_endurance == 100 and w.state == DisasterWaveManager.State.SIEGE_PHASE, "Normal combat cannot end early through a debug endurance shortcut")
		w.advance_wave(89.999)
		_check(w.state == DisasterWaveManager.State.SIEGE_PHASE, "Battle remains active until 90 seconds")
		var shot: HazardProjectile = _shot(Vector2(500,600), Vector2.ZERO)
		w.advance_wave(.001)
		_check(w.state == DisasterWaveManager.State.WAVE_OUTRO and not shot.active and game.mechanics.particles.size() > 0, "90s starts outro and dissolves bullets into visible particles")
		_check(boss.visible and not game.upgrades.pending and w.phase_label().begins_with("AFET DALGASI PÜSKÜRTÜLDÜ"), "Retreat keeps boss visible, defers cards and shows defeat heading")
		w.advance_wave(.5)
		_check(boss.retreat > 0.4 and (boss.scale.x < .7 if wave in [0,2] else boss.position.y > boss._home.y), "Retreat narrows/ascends storm or sinks/shakes golem")
		w.advance_wave(.499)
		_check(w.state == DisasterWaveManager.State.WAVE_OUTRO and not game.upgrades.pending, "Outro remains uninterrupted for 1.0s")
		w.advance_wave(.001)
		if wave < 4:
			_check(game.upgrades.pending and not boss.visible and game.upgrade_overlay.modulate.a == 0, "Cards begin fade-in only after boss exits")
			game.upgrade_overlay._process(.175)
			_check(game.upgrade_overlay.modulate.a > 0 and game.upgrade_overlay.modulate.a < 1, "Card opacity fades instead of popping")
			w.advance_wave(200)
			_check(w.preparation_remaining == 7, "Selection does not consume the 7-second construction window")
			game.upgrades.offers.assign([wave,wave+1,wave+2])
			game.upgrades.choose(0)
			w.advance_wave(6.999)
			_check(w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE, "Build window remains usable at 6.999 seconds")
			w.advance_wave(.001)
			_check(w.state == DisasterWaveManager.State.WAVE_INTRO and w.mode == wave+1, "Exactly 7 seconds triggers the next boss once")
			# Next loop continues the already-started entry, F is deliberately idempotent.
		else:
			_check(w.victory and w.completed_waves == 5 and not game.upgrades.pending, "Fifth outro ends in victory, no sixth wave or card")
			w.start_next_wave()
			_check(w.victory and w.wave_number == 5, "Victory cannot loop back to storm")

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
	var p: SiegePlayer = game.player
	var m: SiegeMechanics = game.mechanics
	var loot: LootSystem = game.loot
	var room: RoomDiorama = loot.current_room()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.DASH_REPAIR)
	room.apply_damage(55)
	loot.column_kits = 1
	p.stamina = 40
	p.previous_position = p.global_position - Vector2(40,0)
	m._dash_started()
	m._dash_repair()
	_check(room.hp == 90 and loot.column_kits == 0 and p.stamina == 100 and m.dash_repairs == 1, "Dash repair consumes an actual kit, heals 45 and refills stamina")
	room.apply_damage(50)
	m._dash_repair()
	_check(room.hp == 40 and m.dash_repairs == 1, "One room cannot be repeatedly repaired by the same dash")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	game.building.rooms[15].apply_damage(60)
	m._drone(11.99,true)
	_check(m.drone_repairs == 0 and m.drone_target == null, "Drone never repairs before its twelve-second interval")
	m._drone(.02,true)
	_check(m.drone_target == game.building.rooms[15], "Drone selects the actual weakest room, not only the current room")
	for tick: int in range(240): m._drone(1.0/60.0,true)
	_check(m.drone_repairs == 1 and game.building.rooms[15].hp == 85 and loot.materials() == 0, "Visible drone flies to target and repairs free on arrival")
	loot.spawn(0,loot.player_room_index())
	loot.items[0]["drop"] = 1.0
	loot.items[0]["position"] = m.drone_position + Vector2(200,0)
	m._drone(.3,false)
	_check(loot.column_kits == 1 and loot.items.is_empty() and not m.beams.is_empty(), "Drone remotely collects a landed item using a visible beam")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.SLAM_SHIELD)
	var upper: HazardProjectile = _shot(Vector2(600,game.building.floor_y(1)-40),Vector2.ZERO,1)
	var lower: HazardProjectile = _shot(Vector2(600,game.building.floor_y(0)-40),Vector2.ZERO,0)
	_check(p.try_floor_shift(1) and not upper.active and lower.active and m.shock_clears == 1, "Actual upper-floor jump signal clears only the target floor")
	await _frames(60)
	var down: HazardProjectile = _shot(Vector2(600,game.building.floor_y(0)-40),Vector2.ZERO,0)
	_check(p.try_floor_shift(-1) and not down.active, "Actual S drop triggers another floor-clear ring")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.DEFLECTOR)
	var window: BuildingProp
	var kitchen: RoomDiorama = game.building.rooms[2]
	kitchen.reinforce(RoomDiorama.Reinforcement.SHUTTER)
	for prop: BuildingProp in kitchen.props():
		if prop.kind == BuildingProp.Kind.WINDOW: window = prop
	var center: Vector2 = window.global_position - Vector2(0,window.prop_size.y*.5)
	p.stamina = 50
	for i: int in range(3):
		var shot: HazardProjectile = _shot(center,Vector2.RIGHT*400,0)
		_check(m.intercept(shot,center-Vector2(100,0)) and not shot.active, "Shutter turbine intercepts a swept boss projectile %d" % i)
	_check(p.stamina == 68 and loot.column_kits == 1 and m.fragment_count == 0, "Three interceptions yield 18 energy and one construction supply")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.GRAPPLE_DASH)
	await _frames(3)
	var start: Vector2 = p.global_position
	_check(p.try_dash(Vector2.RIGHT), "Grapple dash starts with original control action")
	await _frames(15)
	_check(absf(p.global_position.x-start.x-460.0) < 1.0 and p.collision_mask == 1, "Grapple travels 60% farther and restores body collision after 0.25s")
	p.reset_player()
	await _frames(3)
	p.try_dash(Vector2.UP)
	await _frames(15)
	_check(p.current_floor >= 1 and p.global_position.y < game.building.floor_y(0)-220 and p.collision_mask == 1, "Grapple dash really phases through upper floor slabs")
	var slow: HazardProjectile = _shot(p.global_position,Vector2.RIGHT*300,p.current_floor)
	m.trails.append({"a":p.global_position-Vector2(50,0),"b":p.global_position+Vector2(50,0),"life":.9})
	game.projectiles._physics_process(.1)
	_check(is_equal_approx(slow.age,.04), "Electrical trail slows the real projectile clock without changing its path")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.CHAIN_REPAIR)
	p.current_floor = 1
	p.global_position = game.building.rooms[5].global_position + Vector2(200,200)
	for index: int in [1,4,5,6,9,10]: game.building.rooms[index].apply_damage(60)
	loot.column_kits = 1
	loot.repair_current_room()
	var linked: bool = true
	for index: int in [1,4,6,9]: linked = linked and game.building.rooms[index].hp == 62.5 and game.building.rooms[index].chain_support
	_check(linked and game.building.rooms[10].hp == 40 and loot.column_kits == 0, "E chains 22.5 HP and half support to four orthogonal neighbors only")
	_check(is_equal_approx(game.building.rooms[1].apply_damage(20),14.5) and not game.building.rooms[1].has_reinforcement(RoomDiorama.Reinforcement.ANCHOR), "Half support mitigates 27.5% without granting free full anchors")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.ADRENALINE_REFLEX)
	await _frames(3)
	var danger: HazardProjectile = _shot(p.global_position+Vector2(85,-24),Vector2.LEFT*500,0)
	_check(m.impending_hit(), "Incoming projectile within 0.15s predicts capsule contact")
	danger.attack.velocity = Vector2.RIGHT*500
	_check(not m.impending_hit(), "Equally near receding projectile never earns a perfect dodge")
	danger.attack.velocity = Vector2.LEFT*500
	p.try_dash(Vector2.RIGHT)
	_check(Engine.time_scale == .5 and m.slow_remaining == 1.5 and loot.items.size() == 1 and m.perfect_dodges == 1, "Real dash event triggers half-speed time and one actual material drop")
	m.advance(.7495,1.499)
	_check(Engine.time_scale == .5, "Bullet time persists for 1.499 real seconds")
	m.advance(.0005,.001)
	_check(Engine.time_scale == 1.0, "Bullet time restores normal clock at exactly 1.5 real seconds")
	var attack_clock: float = game.waves._storm_clock
	var fight_left: float = game.waves.siege_remaining
	Engine.time_scale = .5
	game.waves.autoplay = true
	game.waves._physics_process(1.0/120.0)
	game.waves.autoplay = false
	_check(is_equal_approx(fight_left-game.waves.siege_remaining,1.0/60.0), "Half-speed physics still consumes one real fixed tick of the 90s wave clock")
	_check(is_equal_approx(attack_clock-game.waves._storm_clock,1.0/120.0), "Bullet time also slows boss attack cadence while the round clock remains real-time")
	Engine.time_scale = 1.0
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.ROOF_TURRET)
	var small: HazardProjectile = _shot(Vector2(750,700),Vector2.ZERO)
	var heavy: HazardProjectile = _shot(Vector2(800,700),Vector2.ZERO)
	heavy.attack.radius = 27
	heavy.attack.damage = 22
	heavy.attack.kind = HazardAttack.Kind.CONCRETE
	heavy.attack.splits = true
	m.advance(2.999,2.999)
	_check(heavy.active, "Roof turret waits a full three seconds")
	m.advance(.001,.001)
	_check(not heavy.active and small.active and m.turret_shots == 1 and game.telegraphs.pending.is_empty(), "Roof laser destroys the dangerous large target without creating split hazards")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.LOOT_MAGNET)
	loot.spawn(0,2)
	loot.items[0]["drop"] = 1.0
	loot.items[0]["position"] = p.global_position + Vector2(250,-26)
	var old: Vector2 = loot.items[0]["position"]
	m._magnet(.1)
	_check(Vector2(loot.items[0]["position"]).distance_to(p.global_position) < old.distance_to(p.global_position), "Magnet visibly moves landed loot toward the player")
	m._magnet(.5)
	_check(loot.items.is_empty() and loot.column_kits == 1 and p.speed_boost == 2 and p.repair_shield == 2, "Magnetic pickup grants actual inventory, two-second speed and shield")
	_check(not p.take_damage(10) and p._run_velocity(1,1) > p.run_speed, "Pickup shield and speed affect actual damage and movement")
	await _frames(121)
	_check(p.speed_boost == 0 and p.repair_shield == 0 and p.take_damage(1), "Pickup speed and shield really expire after two seconds")
	loot._next_spawn = 100.0
	loot.spawn(1,15)
	loot.advance(.45)
	loot.advance(7.999)
	_check(loot.items.size() == 1, "Magnet doubles ground lifetime to eight seconds")
	loot.advance(.001)
	_check(loot.items.is_empty(), "Magnet loot still expires precisely at its new deadline")
	Engine.time_scale = .5
	m.slow_remaining = 1.0
	_fresh(false)
	_check(Engine.time_scale == 1 and not p.grapple_enabled and p.speed_boost == 0 and loot.loot_lifetime == 4 and m.trails.is_empty(), "Reset clears all mechanic state, time scale, phase collision and loot modifiers")

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
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.ROOF_TURRET)
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.DEFLECTOR)
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.LOOT_MAGNET)
	game.loot.messages.clear()
	game.building.rooms[4].repair(0,true)
	game.building.rooms[8].repair(0,true)
	game.building.rooms[9].chain_support = true
	game.building.rooms[9]._refresh_state(true)
	game.building.wear_clock = 45
	var debris: HazardProjectile = _shot(Vector2(1550,600),Vector2.ZERO,2)
	debris.attack.radius = 27
	debris.attack.kind = HazardAttack.Kind.CONCRETE
	game.mechanics.fire_turret()
	game.mechanics.beam(game.mechanics.drone_position,game.player.global_position+Vector2(180,-26),SiegeMechanics.CYAN)
	await _save(directory,"01-active-equipment.png")
	game.waves.finish_wave()
	game.waves.advance_wave(1.25)
	await _save(directory,"02-storm-retreat.png")
	game.waves.advance_wave(1.25)
	for group: int in range(3):
		game.upgrades.offers.assign([group*3,group*3+1,group*3+2])
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
