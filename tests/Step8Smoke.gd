extends SceneTree
## Behavior tests for all nine modules: real pool hits, actual player physics,
## run/phase cleanup, earthquake geometry, card input and renderer evidence.
var game: MainGame
var checks: int = 0
var failures: int = 0
var m: SiegeMechanics
var p: SiegePlayer

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(4)
	m = game.mechanics
	p = game.player
	for node: Node in [p,m,game.loot,game.projectiles,game.telegraphs]: node.set_physics_process(false)
	for boss: DisasterBoss in game.waves.bosses(): boss.set_process(false)
	_quake()
	_cards()
	_dome()
	_bag()
	_armor()
	_sonic()
	_drone()
	_time()
	_orbitals()
	await _boots()
	_crane()
	_cleanup()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): await _capture(arg.trim_prefix("--capture="))
	print("STEP8_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await process_frame
	await process_frame
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _fresh(id: int = -1, mode: int = 0) -> void:
	game.reset_game()
	game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.autoplay = false
	game.building.pacing_enabled = false
	p.controls_locked = false
	p.set_physics_process(false)
	game.projectiles.clear()
	game.telegraphs.clear()
	if id >= 0: game.upgrades.apply_upgrade(id)

func _shot(point: Vector2, velocity: Vector2 = Vector2.ZERO) -> HazardProjectile:
	var a: HazardAttack = game.waves._attack(HazardAttack.Kind.GLASS,p.current_floor,point,velocity)
	a.lifetime = 10
	a.cross_floor = true
	a.warning_id = 800
	a.warning_duration = .55
	a.warning_elapsed = .55
	a.warning_confirmed = true
	return game.projectiles.spawn(a)

func _quake() -> void:
	_fresh(-1,1)
	var w: DisasterWaveManager = game.waves
	for index: int in range(4):
		game.telegraphs.clear()
		game.earthquake.plan_pattern(w,index,1)
		_check(is_equal_approx(game.earthquake.next_delay,BossPatterns.QUAKE_BEATS[index]*1.1),"Quake cadence %d is exactly 10 percent longer" % index)
	var boulder: HazardAttack = game.telegraphs.pending[0]
	_check(boulder.velocity == Vector2(-540,0),"Quake boulder speed is 600 to 540")
	var endpoint: Vector2 = boulder.point_at(boulder.lifetime)
	_check(absf(endpoint.x-(game.building.global_position.x+18)) < .1,"Slower quake boulder retains its frozen endpoint")
	game.telegraphs.clear()
	BossPatterns.fault_wave(w,0)
	_check(game.telegraphs.pending[0].velocity == Vector2(-504,0),"Quake fault speed is 560 to 504")
	game.telegraphs.clear()
	BossPatterns.checker_crush(w,0)
	var cols: Array[HazardAttack] = game.telegraphs.pending
	var width: float = cols[0].area.size.x
	var base_gap: float = 2*game.building.room_width-(game.building.room_width-28)
	_check(is_equal_approx((2*game.building.room_width-width)/base_gap,1.1),"Checker escape corridor is exactly 10 percent wider")
	game.telegraphs.clear()
	BossPatterns.tectonic_rings(w,0)
	var shot: HazardAttack = game.telegraphs.pending[0]
	var spacing: float = 400*sin(PI/12)
	_check(is_equal_approx((spacing-shot.radius*2)/(spacing-24),1.1),"Ring edge gap is exactly 10 percent wider at 200 world pixels")
	_check(is_equal_approx(shot.velocity.length(),324),"Ring speed is 360 to 324")
	var warned: bool = true
	for a: HazardAttack in game.telegraphs.pending: warned = warned and a.warning_duration == .55 and not a.is_armed()
	_check(warned,"Quake tuning never removes warnings or arms attacks early")
	_fresh(-1,0)
	for index: int in range(5):
		game.storm.plan_pattern(game.waves,index,1)
		_check(game.storm.next_delay == BossPatterns.STORM_BEATS[index],"Storm cadence %d is unchanged" % index)
	_fresh(-1,2)
	var a: HazardAttack = game.waves._attack(HazardAttack.Kind.CONCRETE,0,Vector2(100,100),Vector2(-600,0))
	a.source = 1
	game.waves.plan_attack(a)
	_check(game.telegraphs.pending[0].velocity.x == -600,"Quake reduction does not leak into another phase")

func _cards() -> void:
	_check(SiegeUpgrades.CATALOG.size() == 9 and SiegeUpgrades.AWARENESS.size() == 3,"Catalogue is exactly three awareness and six action mechanics")
	for data: Dictionary in SiegeUpgrades.CATALOG:
		_check(String(data["effect"]).split(" ",false).size() <= 12 and not String(data["effect"]).contains("%") and not String(data["note"]).contains("yıkımını önler"),"Card is concise, mechanical and avoids an engineering guarantee: "+String(data["title"]))
	var grouped: bool = true
	for seed_value: int in range(100):
		_fresh()
		game.upgrades._rng.seed = seed_value
		for wave: int in range(3):
			grouped = grouped and game.upgrades.open_selection()
			var offers: Array[int] = game.upgrades.offers
			grouped = grouped and offers.size() == 3 and SiegeUpgrades.is_awareness(offers[0]) and not SiegeUpgrades.is_awareness(offers[1]) and not SiegeUpgrades.is_awareness(offers[2]) and offers[1] != offers[2]
			for id: int in offers: grouped = grouped and not game.upgrades.selected.has(id)
			game.upgrades.choose((seed_value+wave)%3)
	_check(grouped,"300 campaign selections keep one green awareness and two distinct unowned actions")

func _dome() -> void:
	_fresh(SiegeUpgrades.Kind.DOME)
	m.advance(.349,.349)
	_check(not m.dome_ready,"Dome does not open before 0.35 seconds stationary")
	m.advance(.001,.001)
	_check(m.dome_ready,"Dome opens after 0.35 stationary seconds")
	var bullet: HazardProjectile = _shot(p.global_position+Vector2(0,-24))
	game.projectiles._physics_process(.01)
	_check(not bullet.active and p.health == 100 and m.dome_cooldown == 6 and not m.dome_ready,"Dome destroys the first real contacting projectile with zero HP loss")
	_shot(p.global_position+Vector2(0,-24))
	game.projectiles._physics_process(.01)
	_check(p.health == 90,"A second projectile can hurt while the dome recharges")
	m.advance(5.999,5.999)
	_check(not m.dome_ready,"Dome cannot recharge early")
	m.advance(.001,.001)
	_check(m.dome_ready,"Dome recharges at six seconds")
	_fresh(SiegeUpgrades.Kind.DOME)
	p.previous_position = p.global_position-Vector2(10,0)
	m.advance(.5,.5)
	_check(not m.dome_ready,"Walking does not grant the initial stationary shield")

func _bag() -> void:
	_fresh(SiegeUpgrades.Kind.AWARE_BAG)
	var bullet: HazardProjectile = _shot(p.global_position+Vector2(100,-24))
	p.health = 50
	p.take_damage(5)
	_check(p.health == 45 and not m.bag_used,"Emergency bag waits until strictly below 45 percent")
	p.hit_invulnerability = 0
	p.take_damage(1)
	_check(p.health == 84 and m.bag_used and not bullet.active and p.speed_boost == 4,"Low-health bag heals 40, clears the pool and gives four seconds of speed")
	p.hit_invulnerability = 0
	p.health = 20
	p.take_damage(1)
	_check(p.health == 19 and m.bag_activations == 1,"Bag activates only once per phase")
	game.waves.wave_number += 1
	game.upgrades.begin_wave()
	p.hit_invulnerability = 0
	p.take_damage(30)
	_check(p.health == 40 and not game.waves.failed and m.bag_activations == 2,"New phase rearms bag and a lethal hit is rescued before defeat callbacks")
	game.upgrades.begin_wave()
	_check(m.bag_used,"Repeated begin-wave callback cannot rearm the same phase")
	game.loot.spawn(LootSystem.Kind.EMERGENCY_BAG,8)
	game.loot.collect(0)
	bullet = _shot(p.global_position+Vector2(90,-24))
	game.projectiles._physics_process(.01)
	_check(m.repulse_remaining == 2 and not bullet.active,"Medical pickup grants a visible bullet-repelling perimeter")

func _armor() -> void:
	_fresh(SiegeUpgrades.Kind.AWARE_STRUCTURE)
	var room: RoomDiorama = game.loot.current_room()
	room.hp = 40
	game.loot.column_kits = 1
	game.loot.repair_current_room()
	_check(room.bullet_armor and room.hp == 85,"Repair creates persistent steel-energy room armor")
	p.previous_position = p.global_position
	m.advance(.01,.01)
	_check(p.energy_regen_multiplier == 2,"Armored room doubles the real stamina regeneration multiplier")
	var center: Vector2 = room.global_position+Vector2(90,90)
	m._rng.seed = 86421
	var destroyed: int = 0
	var no_retry: bool = true
	for i: int in range(1000):
		var bullet: HazardProjectile = _shot(center)
		if m.intercept(bullet,center): destroyed += 1
		else:
			for step: int in range(4): no_retry = no_retry and not m.intercept(bullet,center)
		game.projectiles.clear()
	_check(destroyed >= 400 and destroyed <= 500,"Seeded 1000-entry armor sample reflects the 45 percent probability (%d blocks)" % destroyed)
	_check(no_retry,"A bullet cannot reroll room armor every frame")
	var bullet: HazardProjectile = _shot(room.global_position+Vector2(room.room_size.x+5,80))
	m.intercept(bullet,room.global_position+Vector2(-5,80))
	_check(bullet.armor_checked.has(room.get_instance_id()) or not bullet.active,"Armor also checks high-speed crossings of an entire room")
	game.projectiles.clear()
	bullet = _shot(center)
	_check(bullet.armor_checked.is_empty(),"Pool reuse clears per-room interception history")
	room.hp = 0
	m.advance(.01,.01)
	_check(p.energy_regen_multiplier == 1,"Collapsed armor does not regenerate energy")

func _sonic() -> void:
	_fresh(SiegeUpgrades.Kind.SONIC_DASH)
	p.dash_remaining = .2
	p.dashing_this_tick = true
	var bullet: HazardProjectile = _shot(p.global_position+Vector2(100,-24),Vector2.LEFT*10000)
	game.projectiles._physics_process(.02)
	_check(not bullet.active and p.health == 100,"Sonic dash uses relative swept collision even when a bullet crosses in one frame")
	m._was_dashing = true
	p.dash_remaining = 0
	p.dashing_this_tick = false
	m.advance(.01,.01)
	_check(not m.rings.is_empty(),"Sonic dash ends with a visible shock ring")
	bullet = _shot(p.global_position+Vector2(0,-24))
	game.projectiles._physics_process(.01)
	_check(bullet.active and p.health == 90,"Sonic module is not a permanent invulnerability cheat")

func _drone() -> void:
	_fresh(SiegeUpgrades.Kind.AUTO_DRONE)
	game.building.rooms[15].hp = 10
	game.building.rooms[14].hp = 40
	m.advance(6.499,6.499)
	_check(game.building.rooms[15].hp == 10,"Drone has a full 6.5 second repair interval")
	m.advance(.001,.001)
	_check(game.building.rooms[15].hp == 55 and game.building.rooms[14].hp == 40 and game.loot.materials() == 0 and not m.beams.is_empty(),"Drone repairs the weakest distant room with a real free laser")
	game.loot.spawn(0,8)
	game.loot.items[0]["drop"] = 1.0
	game.loot.items[0]["position"] = p.global_position+Vector2(300,-26)
	var first: Vector2 = game.loot.items[0]["position"]
	m.advance(.1,.1)
	_check(Vector2(game.loot.items[0]["position"]).distance_to(p.global_position) < first.distance_to(p.global_position),"Drone visibly pulls a landed drop toward the player")
	m.advance(.5,.5)
	_check(game.loot.items.is_empty() and game.loot.column_kits == 1,"Attracted loot enters actual inventory")
	_check(game.loot.loot_lifetime == 4,"Drone does not silently retain an obsolete passive lifetime bonus")

func _time() -> void:
	_fresh(SiegeUpgrades.Kind.GRAZE_TIME)
	game.waves._on_grazed(p.global_position+Vector2(35,-24))
	_check(m.time_remaining == 2.5 and Engine.time_scale == 1,"A rewarded graze opens a 2.5 second local dome without slowing player/time")
	var center: Vector2 = p.global_position+Vector2(0,-24)
	var near: HazardProjectile = _shot(center+Vector2(100,0),Vector2.RIGHT*100)
	var far: HazardProjectile = _shot(center+Vector2(400,0),Vector2.RIGHT*100)
	game.projectiles._physics_process(.1)
	_check(is_equal_approx(near.age,.045) and is_equal_approx(far.age,.1),"Only bullets within the 220px dome travel 55 percent slower")
	_check(near.global_position.distance_to(near.attack.point_at(.045)) < .01,"Slow motion follows the original warned path")
	m.advance(2.499,2.499)
	_check(m.time_remaining > 0,"Time dome lasts until 2.5 seconds")
	m.advance(.001,.001)
	_check(is_zero_approx(m.time_remaining) and m.projectile_speed(near) == 1,"Time dome expires with no lingering speed modifier")

func _orbitals() -> void:
	_fresh(SiegeUpgrades.Kind.ORBITALS)
	var positions: PackedVector2Array = m.orbital_positions()
	_check(positions.size() == 2 and positions[0].distance_to(positions[1]) > 145,"Exactly two opposing steel satellites orbit the player")
	var bullet: HazardProjectile = _shot(positions[0])
	game.projectiles._physics_process(.001)
	_check(not bullet.active and p.health == 100,"Contact with an orbital destroys a real bullet before the player")
	bullet = _shot(p.global_position+Vector2(0,-24))
	game.projectiles._physics_process(.001)
	_check(bullet.active and p.health == 90,"Bullets can still pass between orbitals")
	var before: Vector2 = m.orbital_positions()[0]
	m.advance(.2,.2)
	_check(before.distance_to(m.orbital_positions()[0]) > 20,"Orbitals actually rotate over time")

func _boots() -> void:
	_fresh(SiegeUpgrades.Kind.SLAM_SHIELD)
	p.set_physics_process(true)
	await _frames(4)
	var x: float = p.global_position.x
	var target: RoomDiorama = game.building.room_at_point(1,x)
	var neighbor: RoomDiorama = game.building.room_at(1,(game.building.column_at(x)+1)%4)
	target.hp = 50
	var hit: HazardProjectile = _shot(Vector2(x,game.building.floor_y(1)-40))
	var spare: HazardProjectile = _shot(neighbor.global_position+Vector2(80,90))
	_check(p.try_floor_shift(1) and m.floor_guard and not p.take_damage(20),"Upper-floor parabola grants transition invulnerability")
	_check(hit.active and target.hp == 50,"Boots wait for actual landing rather than clearing at takeoff")
	await _frames(55)
	_check(p.current_floor == 1 and not p.is_shifting and not m.floor_guard and target.hp == 70 and not hit.active and spare.active,"Physical landing heals 20 and clears only the destination room")
	var lower: RoomDiorama = game.building.room_at_point(0,p.global_position.x)
	lower.hp = 50
	_check(p.try_floor_shift(-1) and m.floor_guard and not p.take_damage(10),"S drop also grants transition invulnerability")
	await _frames(15)
	_check(p.current_floor == 0 and lower.hp == 70 and not m.floor_guard and p.collision_mask == 1,"Downstairs landing repairs once and restores normal collision")
	p.set_physics_process(false)

func _crane() -> void:
	_fresh(SiegeUpgrades.Kind.REMOTE_CRANE)
	game.building.rooms[15].hp = 10
	game.building.rooms[14].hp = 30
	game.building.rooms[13].hp = 40
	game.loot.column_kits = 1
	var bullet: HazardProjectile = _shot(p.global_position+Vector2(0,-24))
	_check(game.loot.repair_current_room() == LootSystem.RepairResult.REPAIRED,"Remote E works from a healthy room")
	_check(game.building.rooms[15].hp == 55 and game.building.rooms[14].hp == 75 and game.building.rooms[13].hp == 40 and game.loot.materials() == 0,"Crane repairs exactly the two weakest rooms for a single material")
	game.projectiles._physics_process(.5)
	_check(bullet.age == 0 and p.health == 100,"Crane freeze stops lifetime, collision and movement")
	m.advance(.999,.999)
	game.projectiles._physics_process(.01)
	_check(bullet.age == 0,"Freeze cannot expire before one second")
	m.advance(.001,.001)
	game.projectiles._physics_process(.01)
	_check(bullet.age > 0 and p.health == 90,"Freeze releases movement and collision at one second")
	_check(not m.remote_repair(),"Crane never repairs without stock")
	game.loot.column_kits = 1
	for room: RoomDiorama in game.building.rooms: room.hp = room.max_hp
	_check(not m.remote_repair() and game.loot.column_kits == 1,"Crane spends nothing when every room is intact")
	game.building.rooms[15].hp = 0
	_check(not m.remote_repair(),"Crane cannot resurrect a collapsed room")

func _cleanup() -> void:
	for id: int in range(9):
		_fresh(id)
		_check(not game.upgrades.apply_upgrade(id),"Module %d cannot be selected twice" % id)
	_fresh()
	for id: int in range(9): game.upgrades.apply_upgrade(id)
	m.time_remaining = 2
	m.freeze_remaining = 1
	m.floor_guard = true
	game.loot.current_room().set_bullet_armor(true)
	game.reset_game()
	_check(game.upgrades.selected.is_empty() and m.time_remaining == 0 and m.freeze_remaining == 0 and not m.floor_guard and p.energy_regen_multiplier == 1 and not game.loot.current_room().bullet_armor and Engine.time_scale == 1,"R clears all nine modules and transient protection")
	_fresh(SiegeUpgrades.Kind.GRAZE_TIME)
	m.time_remaining = 2.5
	m.freeze_remaining = 1
	game.waves.finish_wave()
	_check(m.time_remaining == 0 and m.freeze_remaining == 0 and Engine.time_scale == 1,"Phase exit clears all local time effects")

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920,1080)
	await _frames(20)
	for group: int in range(3):
		_fresh()
		game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
		game.upgrades.pending = true
		game.upgrades.offers.assign([group,3+group*2,4+group*2])
		game.upgrade_overlay._refresh()
		await _frames(25)
		await _save(directory,"cards-%d.png" % group)
		var fits: bool = true
		for card: Button in game.upgrade_overlay.cards:
			var icons: int = 0
			for child: Node in card.get_children():
				if child is UpgradeIcon: icons += 1
				if child is Label:
					fits = fits and child.get_visible_line_count() == child.get_line_count()
					fits = fits and child.position.y+child.size.y <= card.size.y and child.position.x+child.size.x <= card.size.x
					fits = fits and child.get_minimum_size().y <= child.size.y
			fits = fits and icons == 1
		_check(fits,"Native card group %d has one large icon and unclipped text" % group)
	var chosen: int = game.upgrades.offers[2]
	_click(2)
	_check(game.upgrades.has_upgrade(chosen) and not game.upgrades.pending,"Native mouse chooses the displayed card")
	game.upgrades.open_selection()
	chosen = game.upgrades.offers[0]
	_key(KEY_1)
	_check(game.upgrades.has_upgrade(chosen) and not game.upgrades.pending,"Native key 1 selects a card without triggering a boss shortcut")
	_fresh()
	for id: int in range(9): game.upgrades.apply_upgrade(id)
	m.dome_ready = true
	m.time_remaining = 2.5
	m.repulse_remaining = 2
	m.drone_position = p.global_position+Vector2(65,-110)
	game.loot.current_room().set_bullet_armor(true)
	m.beam(m.drone_position,game.building.rooms[10].global_position+Vector2(180,100),Color("71e5ac"))
	m.queue_redraw()
	await _save(directory,"active-modules.png")
	var camera_position: Vector2 = game.game_camera.position
	game.cinematic.set_process(false)
	game.game_camera.zoom = Vector2.ONE*1.8
	game.game_camera.position = p.global_position+Vector2(0,-50)
	await _save(directory,"active-modules-close.png")
	game.game_camera.zoom = Vector2.ONE*game.base_zoom/game.pixel_scale
	game.game_camera.position = camera_position
	game.cinematic.set_process(true)
	_fresh(SiegeUpgrades.Kind.REMOTE_CRANE)
	game.building.rooms[15].hp = 20
	game.building.rooms[10].hp = 30
	game.loot.column_kits = 1
	_key(KEY_E)
	_check(game.building.rooms[15].hp == 65 and game.building.rooms[10].hp == 75 and game.loot.column_kits == 0,"Real E input triggers both remote repair beams")
	m.queue_redraw()
	await _save(directory,"remote-crane.png")
	_fresh(-1,1)
	game.earthquake.plan_pattern(game.waves,2,1)
	game.telegraphs._physics_process(.55)
	game.projectiles._physics_process(.5)
	await _save(directory,"quake-rings.png")
	# Exercise mouse transformation in a scaled real window too.
	_fresh()
	game.upgrades.open_selection()
	root.unresizable = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280,720)
	await _frames(15)
	chosen = game.upgrades.offers[1]
	_click(1)
	_check(game.upgrades.has_upgrade(chosen) and not game.upgrades.pending,"Scaled 1280x720 mouse still selects the intended card")

func _click(slot: int) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = root.get_final_transform()*game.upgrade_overlay.cards[slot].get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event,false)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	root.push_input(event,false)

func _key(code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event,true)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	root.push_input(event,true)

func _save(directory: String, filename: String) -> void:
	for tick: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920,1080) and picture.save_png(directory.path_join(filename)) == OK,"Native capture "+filename)

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _check(ok: bool, label: String) -> void:
	checks += 1
	if ok: print("PASS "+label)
	else:
		failures += 1
		push_error("FAIL "+label)
