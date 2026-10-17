extends SceneTree
## Actual warning/pool integration, boundary physics, resistance and native rendering.
var game: MainGame
var checks: int = 0
var failures: int = 0
var launches: Array[HazardAttack] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	game.intro_enabled = false
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(4)
	game.loot.set_physics_process(false)
	game.mechanics.set_physics_process(false)
	game.waves.attack_launched.connect(func(a: HazardAttack) -> void: launches.append(a))
	await _patterns()
	await _hazards()
	await _movement()
	await _controls_and_enrage()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("MARATHON_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _fresh(mode: DisasterWaveManager.Mode = DisasterWaveManager.Mode.FLOOD) -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.waves.start_siege(mode,true)

	game.building.pacing_enabled = false
	game.loot.set_physics_process(false)
	game.mechanics.set_physics_process(false)
	game.player.controls_locked = true
	game.player.set_physics_process(false)
	game.player.health = 100
	game.projectiles.clear()
	game.telegraphs.clear()
	launches.clear()

func _patterns() -> void:
	for mode: int in [DisasterWaveManager.Mode.FLOOD,DisasterWaveManager.Mode.CATACLYSM]:
		_fresh(mode as DisasterWaveManager.Mode)
		var labels: Dictionary = {}
		var count: int = 5 if mode == DisasterWaveManager.Mode.FLOOD else 4
		var boss: DisasterBoss = game.flood if count == 5 else game.titan
		for index: int in range(count):
			game.projectiles.clear()
			game.telegraphs.clear()
			launches.clear()
			boss.plan_pattern(game.waves,index,1)
			labels[boss.pattern_label] = true
			_check(not game.telegraphs.pending.is_empty() and game.projectiles.active_count() == 0,"Mode %d pattern %d warns before activation" % [mode,index])
			var frozen: bool = true
			for a: HazardAttack in game.telegraphs.pending:
				frozen = frozen and (a.source == 2 if mode == DisasterWaveManager.Mode.FLOOD else a.source in [0,1,2]) and not a.warning_confirmed and a.warning_duration >= a.minimum_warning()
				for sample: int in range(11):
					var p: Vector2 = a.point_at(a.lifetime*sample/10.0)
					frozen = frozen and is_finite(p.x) and is_finite(p.y)
			_check(frozen,"All new trajectories and warning intervals are valid")
			game.telegraphs._physics_process(.54)
			_check(game.projectiles.active_count() == 0,"No new pattern can damage during first .54 seconds")
			for tick: int in range(150):
				game.telegraphs._physics_process(1.0/60)
			_check(launches.size() > 0,"Pattern launches real armed pool entries")
			var armed: bool = true
			for a: HazardAttack in launches: armed = armed and a.is_armed()
			_check(armed,"Every launch carries completed warning evidence")
		_check(labels.size() == count,"Distinct attack cycle contains %d patterns" % count)
	_check(game.waves.nova_interval < game.waves.flood_interval and game.waves.flood_interval < game.waves.quake_interval,"Flood and final nova retain distinct attack tempos")
	_fresh()
	game.flood.plan_pattern(game.waves,5,2)
	_check(game.telegraphs.pending.size() == 2 and game.telegraphs.pending[0].floor_index == 0 and game.telegraphs.pending[1].floor_index == 1,"Alternate flood surge covers ground and first floor with upper escape floors")

func _hazards() -> void:
	_fresh()
	var w: DisasterWaveManager = game.waves
	game.flood.plan_pattern(w,2,0)
	var orb: HazardAttack = game.telegraphs.pending[0]
	_check(orb.path_points.size() == 5 and orb.path_times.size() == 5,"Hydro-orb stores exactly three rebounds and final split travel")
	var isolated: HazardAttack = orb.frozen_copy()
	var first: Vector2 = isolated.path_points[1]
	orb.path_points[1] += Vector2(99,99)
	_check(isolated.path_points[1] == first,"Snapshot owns isolated bounce vertices")
	var reflects: bool = true
	for index: int in range(1,4):
		var before: Vector2 = isolated.point_at(isolated.path_times[index]-.001)
		var at: Vector2 = isolated.point_at(isolated.path_times[index])
		var after: Vector2 = isolated.point_at(isolated.path_times[index]+.001)
		var vin: Vector2 = at-before
		var vout: Vector2 = after-at
		reflects = reflects and (vin.x*vout.x < 0 or vin.y*vout.y < 0) and before.distance_to(at) < 2 and after.distance_to(at) < 2
	_check(reflects,"Every wall/floor rebound changes direction continuously")
	game.telegraphs.clear()
	w._on_projectile_impacted(isolated,isolated.point_at(isolated.lifetime))
	_check(game.telegraphs.pending.size() == 6 and game.projectiles.active_count() == 0,"Third bounce termination creates six separately warned water shards")
	var center: Vector2 = isolated.point_at(isolated.lifetime)
	var radial: bool = true
	for a: HazardAttack in game.telegraphs.pending: radial = radial and a.origin.is_equal_approx(center) and a.kind == HazardAttack.Kind.WATER_SHARD and not a.splits
	_check(radial,"Six fragments share the actual impact centre and do not recurse")
	_fresh()
	game.flood.plan_pattern(w,0,0)
	var zone: HazardAttack = game.telegraphs.pending[0]
	_check(zone.lifetime == 3.5 and zone.warning_duration == 1.0,"Flood remains exactly 3.5s after a full one-second warning")
	game.telegraphs._physics_process(.999)
	_check(game.projectiles.active_count() == 0,"Flood cannot activate early")
	game.telegraphs._physics_process(.001)
	var live: HazardProjectile = game.projectiles.entries[0]
	var p: SiegePlayer = game.player
	p.controls_locked = false
	p.current_floor = 0
	p.global_position = Vector2(w.building.center_x(),w.building.floor_y(0))
	p.previous_position = p.global_position
	p.hit_invulnerability = 0
	_check(live.crosses_player(p,live.global_position),"Flood overlaps the real grounded capsule")
	game.projectiles._physics_process(.01)
	_check(p.health == 84 and is_equal_approx(p.hazard_drag,.35),"Flood really damages and slows the grounded player")
	game.projectiles._physics_process(.1)
	_check(p.health == 84,"Existing one-second hit immunity also gates lingering zones")
	p.hit_invulnerability = 0
	game.projectiles._physics_process(.01)
	_check(p.health == 68,"Lingering zone can hurt again after hit immunity expires")
	p.global_position.y -= 100
	p.previous_position = p.global_position
	_check(not live.crosses_player(p,live.global_position),"Jumping clears a floor-only flood")
	live.advance(3.5)
	game.projectiles._physics_process(.001)
	_check(not live.active and p.hazard_drag == 0,"Flood expires and removes movement penalty")
	_fresh()
	var f: int = 1
	var area: Rect2 = Rect2(w.building.interior_left(),w.building.floor_y(f)-170,600,165)
	MarathonPatterns.zone(w,HazardAttack.Kind.WHIRLPOOL,f,area,2.2,2,HazardAttack.Pattern.WHIRLPOOL_PULL)
	game.telegraphs._physics_process(.75)
	p.current_floor = f
	p.global_position = Vector2(area.position.x+50,area.end.y)
	p.previous_position = p.global_position
	game.projectiles._physics_process(.01)
	_check(p.hazard_pull > 0 and p.health == 100,"Warned whirlpool applies real centre-directed pull without direct damage")
	w.finish_wave()
	_check(p.hazard_pull == 0 and p.hazard_drag == 0,"Outro clears environmental forces")
	_fresh(DisasterWaveManager.Mode.CATACLYSM)
	game.titan.plan_pattern(w,3,1)
	var cores: int = 0
	for a: HazardAttack in game.telegraphs.pending:
		if a.lead: cores += 1
	_check(cores == 4 and game.telegraphs.pending.size() == 20,"Four corner emitters combine three disaster sources with twenty rays")
	game.telegraphs._physics_process(.999)
	_check(game.projectiles.active_count() == 0,"Corner seal remains harmless at .999s")
	game.telegraphs._physics_process(.001)
	_check(game.projectiles.active_count() == 20,"All seal rays activate at exactly 1.0 seconds")
	_fresh(DisasterWaveManager.Mode.CATACLYSM)
	game.titan.plan_pattern(w,0,0)
	var roof_count: int = 0
	for a: HazardAttack in game.telegraphs.pending:
		if a.cross_floor and a.origin.y < game.building.global_position.y and a.floor_index in [0,1]: roof_count += 1
	_check(roof_count == 3,"Three delayed quake rocks fall from the roof into lower-floor water")
	# Isolated legacy fire-helper coverage, outside final-only difficulty tuning.
	_fresh(DisasterWaveManager.Mode.FLOOD)
	var meteor: HazardAttack = w._attack(HazardAttack.Kind.METEOR,0,Vector2.ZERO,Vector2.ZERO)
	meteor.source = 3
	meteor.leaves_fire = true
	var point: Vector2 = Vector2(w.building.center_x(),w.building.floor_y(0))
	w._on_projectile_impacted(meteor,point)
	var fire_zone: HazardAttack = game.telegraphs.pending[0]
	_check(fire_zone.kind == HazardAttack.Kind.FIRE_ZONE and fire_zone.lifetime == 3.0,"Napalm impact leaves a warned three-second room fire")
	var room: RoomDiorama = w.building.room_at_point(0,point.x)
	var hp: float = room.hp
	w._on_zone_tick(fire_zone,1.0)
	_check(room.hp < hp-3 and room.heat == 30,"Room fire increases temperature and real room damage")
	var other: RoomDiorama = w.building.room_at(0,0)
	_check(other.heat == 0,"Fire damage stays inside the impacted room")
	var copy: HazardAttack = game.upgrades.prepare_attack(fire_zone)
	_check(copy.damage == fire_zone.damage and copy.lifetime == fire_zone.lifetime,"Retired fire passive no longer changes hazard stats")
	var water: HazardAttack = w._attack(HazardAttack.Kind.FLOOD_ZONE,0,point,Vector2.ZERO)
	water.effect_strength = .35
	var unmodified: HazardAttack = game.upgrades.prepare_attack(water)
	_check(unmodified.damage == water.damage and unmodified.effect_strength == .35,"Retired drainage passive no longer changes water stats")
	game.reset_game()
	_check(room.heat == 0 and not game.upgrades.has_upgrade(9) and p.hazard_drag == 0,"Reset clears heat, resistances and environment")

func _movement() -> void:
	_fresh()
	# The final titan is anchored around the building; it is covered by Step49Smoke.
	for boss: DisasterBoss in [game.storm,game.earthquake,game.flood]:
		boss.set_active(true)
		boss.set_active(true)
		var initial: Vector2 = boss.position
		boss.reposition(game.waves,0,3)
		for i: int in range(60): boss.advance(1.0/60)
		_check(absf(boss.position.y-initial.y)>20,"Boss %d follows targeted floors rather than a fixed Y" % boss.kind)
	_fresh()
	game.flood.reposition(game.waves,1,1)
	for i: int in range(60): game.flood.advance(1.0/60)
	_check(game.flood.position.x > game.building.interior_right(),"Hydra surges onto the right facade")
	game.flood.reposition(game.waves,2,2)
	for i: int in range(60): game.flood.advance(1.0/60)
	_check(game.flood.position.x < game.building.interior_left(),"Hydra returns onto the left facade")
	var heads: Array = game.flood.hydra_rig()["heads"]
	game.flood.advance(.25)
	_check(game.flood.hydra_rig()["heads"] != heads,"Three hydra heads animate independently")
	_fresh(DisasterWaveManager.Mode.CATACLYSM)
	for index: int in range(3):
		game.titan.reposition(game.waves,index,index)
		for i: int in range(60): game.titan.advance(1.0/60)
		_check(absf(game.titan.position.x-game.building.center_x()) < 100 and game.titan.z_index < 0,"Final body remains behind the apartment through anchor %d" % index)
	var arms: Array = game.titan.cataclysm_rig()["vortex"]
	game.titan.advance(.25)
	_check(game.titan.cataclysm_rig()["vortex"].size() == 6 and game.titan.cataclysm_rig()["vortex"] != arms,"Final storm sleeve has six independently animated rings")

func _controls_and_enrage() -> void:
	game.player.set_physics_process(true)
	game.reset_game()
	game.waves.autoplay = false
	await _tap(KEY_3)
	_check(not game.waves.debug_enabled and game.waves.mode == DisasterWaveManager.Mode.FLOOD and game.waves.wave_number == 3,"Key 3 selects flood directly")
	await _tap(KEY_5)
	_check(game.waves.mode == DisasterWaveManager.Mode.FLOOD,"Removed key 5 cannot launch a fire phase")
	await _tap(KEY_4)

	game.waves.siege_remaining = 15.01
	game.waves.advance_wave(.02,.02)
	_check(game.waves.nova and game.titan.enraged,"Final combined boss keeps its last-fifteen-second overload")
	game._apply_atmosphere()
	_check(game.weather.inferno == 0.0 and game.weather.storminess > 0.0,"Final atmosphere contains storm and water, with no inferno")
	game.waves.finish_wave()
	game.waves.advance_wave(1.0)
	_check(game.waves.victory and game.waves.completed_waves == 4 and not game.upgrades.pending,"Fourth retreat ends the campaign in victory")
	_check(game.projectiles.active_count() == 0 and game.telegraphs.pending.is_empty() and Engine.time_scale == 1.0,"Victory cleans all attacks, delayed warnings and time scale")

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920,1080)
	await _frames(10)
	for mode: int in range(4):
		_fresh(mode as DisasterWaveManager.Mode)
		for boss: DisasterBoss in game.waves.bosses():
			boss.set_process(false)
			if boss.visible: boss.advance(.5)
		await _save(directory,"direct-start-%d.png" % (mode+1))

		if mode < 2:
			if mode == 0: game.waves.storm_burst()
			elif mode == 1: game.waves.quake_burst()
			await _save(directory,"battle-%d.png" % (mode+1))
		else:
			var boss: DisasterBoss = game.flood if mode == 2 else game.titan
			var count: int = 6 if mode == 2 else 4
			for pattern: int in range(count):
				game.projectiles.clear()
				game.telegraphs.clear()
				boss.plan_pattern(game.waves,pattern,pattern%4)
				for i: int in range(60): boss.advance(.02)
				await _save(directory,"wave-%d-pattern-%d-warning.png" % [mode+1,pattern+1])
				for i: int in range(90):
					game.telegraphs._physics_process(1.0/60)
					game.projectiles._physics_process(1.0/60)
				await _save(directory,"wave-%d-pattern-%d-live.png" % [mode+1,pattern+1])
			if mode == 4:
				game.waves.siege_remaining = 9
				game.waves.advance_wave(.01)
				game._apply_atmosphere()
				boss.reposition(game.waves,1,2)
				for i: int in range(30): boss.advance(.02)
				await _save(directory,"fire-enrage.png")
		game.waves.finish_wave()
		game.waves.advance_wave(.5)
		await _save(directory,"outro-%d.png" % (mode+1))
	_fresh(DisasterWaveManager.Mode.CATACLYSM)
	game.waves.finish_wave()
	game.waves.advance_wave(1.0)
	await _save(directory,"victory-six-waves.png")
	_fresh()
	game.waves.debug_enabled = true
	game.waves.test_upgrades()
	game.upgrades.offers.assign([0,4,6])
	game.upgrade_overlay._refresh()
	await _frames(25)
	await _save(directory,"cards-fire-flood.png")
	var font_fits: bool = true
	for card: Button in game.upgrade_overlay.cards:
		for child: Node in card.get_children():
			if child is Label: font_fits = font_fits and child.get_minimum_size().y <= child.size.y
	_check(font_fits,"New card text fits its allocated height")
	root.unresizable = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280,720)
	await _frames(6)
	var point: Vector2 = game.upgrade_overlay.cards[1].get_global_rect().get_center()
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event,true)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	root.push_input(event,true)
	_check(game.upgrades.has_upgrade(4) and not game.upgrades.pending,"Scaled window card hit testing selects drone")
	await _save(directory,"scaled-window.png",Vector2i(root.get_texture().get_size()))

func _save(directory: String, name: String, size: Vector2i = Vector2i(1920,1080)) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	var saved: Error = picture.save_png(directory.path_join(name))
	_check(picture.get_size() == size and saved == OK,"Native render %s (%s)" % [name,picture.get_size()])

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _tap(key: int) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(2)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(1)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
