extends SceneTree
## Step 4.8: real inventory, damage, timed hazards, upgrades, input and native art.
var game: MainGame
var checks: int = 0
var failures: int = 0

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(3)
	for node: Node in [game.loot,game.mechanics,game.player,game.projectiles,game.telegraphs]: node.set_physics_process(false)
	for boss: DisasterBoss in game.waves.bosses(): boss.set_process(false)
	_equipment()
	_awareness()
	await _action()
	_offers()
	_framing()
	_reset()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): await _capture(arg.trim_prefix("--capture="))
	print("STEP48_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _fresh() -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.waves.start_next_wave()
	game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false
	game.player.controls_locked = false
	game.telegraphs.clear()
	game.projectiles.clear()

func _equipment() -> void:
	_fresh()
	var l: LootSystem = game.loot
	var p: SiegePlayer = game.player
	var r: RoomDiorama = l.current_room()
	_check(LootSystem.Kind.size() == 4 and l.loot_lifetime == 4 and l.max_active == 3,"Exactly four equipment types, base four-second lifetime, cap three")
	for kind: int in range(4):
		l.spawn(kind,8)
		l.collect(0)
		_check(LootSystem.purpose(kind).length()>8 and l.messages.back()["text"].begins_with("+"),"Equipment %d describes its actual purpose on pickup" % kind)
	_check(l.column_kits == 1 and l.barricade_kits == 1 and game.building.rooms[8].auto_protection and not r.auto_protection,"Remote safety pickup installs in original room, other kits enter inventory")
	p.health = 40
	p.stamina = 3
	l.spawn(2,8)
	l.collect(0)
	_check(p.health == 65 and p.stamina == 100,"Emergency bag restores exactly 25 HP and full energy")
	_check(l.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED and r.reinforcement_level == 0,"Healthy siege E still spends nothing")
	r.apply_damage(60)
	_check(l.repair_current_room() == LootSystem.RepairResult.REPAIRED and r.hp == 85 and r.reinforcement_level == 1,"Column kit heals 45 and installs steel / FRP")
	_check(is_equal_approx(r.apply_damage(20,1),10) and is_equal_approx(r.apply_damage(20,0),20),"Column support halves quake damage without reducing storm damage")
	r.apply_damage(20)
	_check(l.repair_current_room() == LootSystem.RepairResult.REINFORCED and r.reinforcement_level == 3 and l.barricade_kits == 0,"Combined barricade kit installs shutter plus anchors in alerted room")
	for source: int in [0,2,3]: _check(is_equal_approx(r.apply_damage(4,source),2),"Barrier halves source %d room damage" % source)
	for source: int in [0,2,3]:
		game.projectiles.clear()
		p.health = 100
		p.hit_invulnerability = 0
		var shot: HazardAttack = HazardAttack.new()
		shot.source = source
		shot.origin = p.global_position-Vector2(0,30)
		shot.damage = 20
		shot.warning_id = 999
		shot.warning_duration = .65
		shot.warning_elapsed = .65
		shot.warning_confirmed = true
		game.projectiles.spawn(shot)
		game.projectiles._physics_process(.01)
		_check(p.health == 90,"Actual barrier halves source %d projectile damage to player" % source)
	game.projectiles.clear()
	game.telegraphs.clear()
	BossPatterns.room_objects(game.waves,0)
	var secured: bool = true
	for attack: HazardAttack in game.telegraphs.pending:
		for prop: BuildingProp in r.props(): secured = secured and attack.room_source != prop.object_id
	_check(secured,"Anchored furniture cannot emit hazards")
	game.telegraphs.clear()
	var floor_index: int = r.floor_index
	var zone: HazardAttack = _zone(floor_index)
	game.waves.plan_attack(zone,1)
	game.telegraphs._physics_process(1)
	var live: HazardProjectile = game.projectiles.entries[0]
	_check(live.active and live.crosses_player(p,live.global_position),"Unprotected floor flood intersects player")
	l.activate_safety(r)
	_check(live.active and not live.crosses_player(p,live.global_position),"Safety removes only protected room from live flood capsule hits")
	var neighbor: RoomDiorama = game.building.room_at(floor_index,(game.building.column_at(r.global_position.x+180)+1)%4)
	_check(live.attack.contains_area_point(Vector2(neighbor.global_position.x+180,game.building.floor_y(floor_index)-12)),"Neighbor remains flooded after local safety installation")
	game.waves.plan_attack(zone,1)
	_check(not game.telegraphs.pending.back().contains_area_point(p.global_position-Vector2(0,12)),"Future flood warnings preserve installed local protection")
	var isolated: HazardAttack = live.attack.frozen_copy()
	live.attack.safe_areas.clear()
	_check(isolated.safe_areas.size() == 1,"Safety regions are isolated in frozen attack copies")
	r.hp = 50
	neighbor.hp = 50
	r.heat = 90
	l.activate_safety(r)
	game.building.secondary_damage(1,10)
	_check(r.hp == 50 and r.heat == 0 and neighbor.hp == 40,"Safety clears heat and utility damage only in its own room")
	var fire: HazardAttack = _zone(floor_index)
	fire.kind = HazardAttack.Kind.FIRE_ZONE
	fire.source = 3
	var before: float = r.hp
	game.waves._on_zone_tick(fire,1)
	_check(r.hp == before,"Automatic safety blocks future floor-fire room damage")
	var installations: int = l.safety_installs
	l.activate_safety(r)
	_check(l.safety_installs == installations,"Repeated safety pickup does not overcount protected rooms")
	game.telegraphs.clear()
	fire.area = Rect2(neighbor.global_position.x,game.building.floor_y(floor_index)-35,neighbor.room_size.x,35)
	game.waves.plan_attack(fire,.65)
	_check(game.telegraphs.pending.size() == 1,"Unprotected neighbor has a real pending fire warning")
	l.activate_safety(neighbor)
	_check(game.telegraphs.pending.is_empty(),"Safety instantly removes a fully neutralised pending warning")
	_fresh()
	l._next_spawn = 999
	l.spawn(0,8)
	l.advance(.45)
	l.advance(3.999)
	_check(l.items.size() == 1,"Base loot remains at 3.999 seconds on floor")
	l.advance(.001)
	_check(l.items.is_empty(),"Base loot expires at exactly four grounded seconds")

func _zone(floor_index: int) -> HazardAttack:
	var a: HazardAttack = HazardAttack.new()
	a.kind = HazardAttack.Kind.FLOOD_ZONE
	a.source = 2
	a.floor_index = floor_index
	a.area = Rect2(game.building.interior_left(),game.building.floor_y(floor_index)-54,1600,54)
	a.origin = a.area.get_center()
	a.damage = 16
	a.lifetime = 3.5
	a.effect_strength = .35
	return a

func _awareness() -> void:
	_fresh()
	var u: SiegeUpgrades = game.upgrades
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	u.apply_upgrade(SiegeUpgrades.Kind.AWARE_BAG)
	_check(p.max_health == 130 and p.health == 130,"72-hour package raises max HP by 30 and fully heals")
	p.health = 50
	u._rewarded_wave = 0
	u.begin_wave()
	u.begin_wave()
	_check(p.health == 65,"Bag wave heal is 15 exactly once per wave")
	u.apply_upgrade(SiegeUpgrades.Kind.AWARE_ANCHOR)
	var anchored: int = 0
	for r: RoomDiorama in b.rooms: anchored += 1 if r.has_reinforcement(RoomDiorama.Reinforcement.ANCHOR) else 0
	_check(anchored == 4,"Awareness package anchors exactly four distinct standing rooms")
	var a: HazardAttack = HazardAttack.new()
	a.source = 1
	a.pattern = HazardAttack.Pattern.ROOM_OBJECT
	_check(is_equal_approx(u.prepare_attack(a).damage,a.damage*.6),"Falling furniture player damage drops by 40 percent")
	b.rooms[0].hp = 80
	b.rooms[1].hp = 40
	b.rooms[2].hp = 0
	u.apply_upgrade(SiegeUpgrades.Kind.AWARE_STRUCTURE)
	_check(b.rooms[0].hp == 115 and b.rooms[1].hp == 75 and b.rooms[2].hp == 0 and b.rooms[2].max_hp == 130,"Structure package adds 30 max HP, heals even light damage by 35, never revives rubble")
	a.pattern = HazardAttack.Pattern.FAN
	_check(is_equal_approx(u.prepare_attack(a).damage,a.damage*.65) and b.structural_factor == .65,"Structure package reduces quake and structural damage by 35 percent")
	b.rooms[1].hp = 50
	b.erode(1,10)
	_check(is_equal_approx(b.rooms[1].hp,43.5),"Actual structural erosion uses the 35-percent reduction")
	u.apply_upgrade(SiegeUpgrades.Kind.AWARE_UTILITIES)
	b.secondary_damage(1,10)
	_check(is_equal_approx(b.rooms[1].hp,38) and b.secondary_factor == .55,"Actual secondary utility damage drops by 45 percent")
	a.kind = HazardAttack.Kind.FIRE_ZONE
	a.source = 3
	_check(is_equal_approx(u.prepare_attack(a).damage,a.damage*.55),"Floor-fire player damage drops by 45 percent")
	var fire_before: float = b.rooms[1].hp
	a.area = Rect2(b.rooms[1].global_position,b.rooms[1].room_size)
	a.floor_index = 0
	game.waves._on_zone_tick(a,1)
	_check(is_equal_approx(b.rooms[1].hp,fire_before-2.2),"Floor-fire room damage also drops by exactly 45 percent")
	u.apply_upgrade(SiegeUpgrades.Kind.AWARE_FLOOD)
	a = _zone(0)
	_check(u.prepare_attack(a).effect_strength == 0,"Flood awareness package removes floor-water slowing")
	var r: RoomDiorama = b.rooms[0]
	r.reinforce(RoomDiorama.Reinforcement.SHUTTER)
	_check(is_equal_approx(r.damage_factor(0),.3) and is_equal_approx(r.damage_factor(2),.3) and is_equal_approx(r.damage_factor(3),.5),"Flood barrier increases storm/water block by 40 percent, keeps fire block at 50 percent")

func _action() -> void:
	_fresh()
	var p: SiegePlayer = game.player
	var u: SiegeUpgrades = game.upgrades
	var l: LootSystem = game.loot
	u.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	_check(l.loot_lifetime == 7 and l.pickup_radius == 90,"Drone extends life to seven seconds and ordinary pickup reach by 2.5x")
	l._next_spawn = 999
	l.spawn(0,8)
	l.advance(.45)
	l.advance(6.999)
	_check(l.items.size() == 1,"Drone loot exists at grounded age 6.999")
	l.advance(.001)
	_check(l.items.is_empty(),"Drone loot expires exactly at seven grounded seconds")
	u.apply_upgrade(SiegeUpgrades.Kind.LOOT_MAGNET)
	_check(l.loot_lifetime == 8,"Existing eight-second magnet is never downgraded by drone synergy")
	u.apply_upgrade(SiegeUpgrades.Kind.RESCUE_BOOTS)
	_check(is_equal_approx(p.run_speed,403*1.18) and is_equal_approx(p.dash_cooldown,.304*.7) and p.dash_duration == .35,"Boots apply +18% run, -30% cooldown and .35-second dash")
	p.set_physics_process(true)
	await _frames(4)
	_check(p.try_dash(Vector2.RIGHT),"Upgraded dash starts through real movement API")
	await _frames(18)
	_check(p.is_dashing and not p.take_damage(10),"Dash is still genuinely invulnerable after .30 seconds")
	await _frames(6)
	_check(not p.is_dashing and p.take_damage(10),"Extended dash ends and damage is possible again")
	p.set_physics_process(false)
	_fresh()
	u.apply_upgrade(SiegeUpgrades.Kind.EPOXY_SHIELD)
	var r: RoomDiorama = l.current_room()
	r.hp = 10
	l.column_kits = 1
	_check(l.repair_current_room() == LootSystem.RepairResult.REPAIRED and r.hp == 95 and p.repair_shield == 2.5,"Actual E repair heals 85 and supplies a 2.5-second shield")
	_check(not p.take_damage(20),"Repair shield actually rejects incoming damage")
	_fresh()
	u.apply_upgrade(SiegeUpgrades.Kind.EARLY_WARNING)
	for boss: DisasterBoss in game.waves.bosses():
		game.telegraphs.clear()
		game.telegraphs.warning_bonus = 0
		boss.plan_pattern(game.waves,0,1)
		var base_duration: float = game.telegraphs.pending[0].warning_duration
		game.telegraphs.clear()
		game.telegraphs.warning_bonus = .25
		boss.plan_pattern(game.waves,0,1)
		var duration: float = game.telegraphs.pending[0].warning_duration
		_check(is_equal_approx(duration,base_duration+.25),"Boss %d receives full additional .25-second warning" % boss.kind)
	game.telegraphs.clear()
	var a: HazardAttack = HazardAttack.new()
	a.origin = p.global_position+Vector2(250,-100)
	a.velocity = Vector2.RIGHT*100
	game.waves.plan_attack(a,.65)
	_check(is_equal_approx(game.telegraphs.pending[0].warning_duration,.9),"Normal .65 warning becomes .90 seconds")
	game.telegraphs._physics_process(.899)
	_check(game.projectiles.active_count() == 0,"Radar warning cannot launch one millisecond early")
	game.telegraphs._physics_process(.001)
	var shot: HazardProjectile = game.projectiles.entries[0]
	game.projectiles._physics_process(.1)
	_check(is_equal_approx(shot.age,.088) and shot.global_position.is_equal_approx(a.point_at(.088)),"Radar slows actual path clock 12 percent without retargeting geometry")
	var zone: HazardAttack = _zone(0)
	game.projectiles.clear()
	game.telegraphs.clear()
	game.waves.plan_attack(zone,1)
	game.telegraphs._physics_process(1.25)
	var field: HazardProjectile = game.projectiles.entries[0]
	game.projectiles._physics_process(.5)
	_check(is_equal_approx(field.age,.5),"Radar does not lengthen stationary floor-hazard lifetimes")
	u._rewarded_wave = 0
	u.begin_wave()
	u.begin_wave()
	_check(l.column_kits == 1 and l.barricade_kits == 1,"Radar grants exactly two construction kits once per wave")
	_fresh()

func _offers() -> void:
	var correct: bool = true
	for seed_value: int in range(50):
		_fresh()
		game.upgrades._rng.seed = seed_value
		for wave: int in range(5):
			game.upgrades.open_selection()
			var offers: Array[int] = game.upgrades.offers
			correct = correct and offers.size() == 3 and SiegeUpgrades.is_awareness(offers[0]) and not SiegeUpgrades.is_awareness(offers[1]) and not SiegeUpgrades.is_awareness(offers[2]) and offers[1] != offers[2]
			correct = correct and not game.upgrades.selected.has(offers[0]) and not game.upgrades.selected.has(offers[1]) and not game.upgrades.selected.has(offers[2])
			game.upgrades.choose((seed_value+wave)%3)
	_check(correct,"250 selections across 50 runs (five card screens) guarantee left awareness, two distinct unowned action cards")
	var text: bool = SiegeUpgrades.CATALOG.size() == 19
	for card: Dictionary in SiegeUpgrades.CATALOG: text = text and card["effect"].length()>20 and card["note"].length()>20
	_check(text,"All nineteen cards retain an effect plus a short awareness note")

func _framing() -> void:
	_fresh()
	for boss: DisasterBoss in game.waves.bosses():
		boss.set_active(true)
		boss.transition_pose(1.0,false)
		boss.cue_attack(1.0)
		var fits: bool = true
		# Step 4.9 HUD: the titan's crown may rise into the old header area, but never
		# into the thin boss strip; every other boss keeps the stricter old 165 px line.
		var top_limit: float = 70.0 if boss.kind == DisasterBoss.Kind.CATACLYSM else 165.0
		var extent: Rect2 = Rect2()
		for tick: int in range(60):
			boss.advance(1.0/60)
			var box: Rect2 = boss.pose_bounds()
			var left: Vector2 = game.world_to_screen(boss.to_global(box.position))
			var right: Vector2 = game.world_to_screen(boss.to_global(box.end))
			# BossGroundMask intentionally hides every painted part below ground.
			right.y = minf(right.y,game.world_to_screen(Vector2(0,game.backdrop.ground_y)).y)
			fits = fits and left.x >= 0 and right.x <= 1920 and left.y >= top_limit and right.y <= 990
			extent = Rect2(left, right - left) if tick == 0 else extent.merge(Rect2(left, right - left))
		_check(fits,"Boss %d artwork stays within frame through the whole charge %s" % [boss.kind, extent])
		boss.set_active(false)

func _reset() -> void:
	_fresh()
	for id: int in range(19): game.upgrades.apply_upgrade(id)
	game.loot.activate_safety(game.building.rooms[0])
	game.reset_game()
	var clean: bool = game.player.max_health == 100 and game.player.run_speed == 403 and game.player.dash_duration == .25 and game.loot.loot_lifetime == 4 and game.loot.pickup_radius == 36 and game.loot.repair_amount == 45 and game.telegraphs.warning_bonus == 0 and game.building.secondary_factor == 1 and game.building.structural_factor == 1
	for r: RoomDiorama in game.building.rooms: clean = clean and r.max_hp == 100 and r.hp == 100 and r.flood_barrier_bonus == 0 and not r.auto_protection and not r.utilities_isolated
	_check(clean and game.upgrades.selected.is_empty() and game.player.gear_offset == Vector2.ZERO,"R resets every new modifier, room installation and weighted equipment pose")

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920,1080)
	# A fixed native viewport keeps evidence at design resolution even if the desktop tiles the window.
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_size = Vector2i(1920,1080)
	await _frames(15)
	for mode: int in [0,1,3,4]:
		_fresh()
		game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
		game.waves.advance_wave(1.2)
		game.building.pacing_enabled = false
		var boss: DisasterBoss = [game.storm,game.earthquake,game.flood,game.titan][[0,1,3,4].find(mode)]
		boss.advance(.45)
		await _save(directory,"boss-%d-idle.png" % boss.kind)
		boss.cue_attack(.75)
		boss.advance(.52)
		await _save(directory,"boss-%d-charge.png" % boss.kind)
	_fresh()
	game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.loot.column_kits = 3
	game.loot.barricade_kits = 2
	game.loot.repair_current_room()
	game.loot.repair_current_room()
	game.loot.activate_safety(game.loot.current_room())
	for kind: int in range(3): game.loot.spawn(kind,kind+8)
	game.loot.advance(.45)
	await _save(directory,"loot-three-kits-hud.png")
	var separated: bool = true
	for i: int in range(game.labels.feedback_rects.size()):
		for j: int in range(i): separated = separated and not game.labels.feedback_rects[i].intersects(game.labels.feedback_rects[j])
	_check(separated,"Rapid installation feedback has no overlapping text bounds")
	game.loot.clear_drops()
	game.loot.spawn(3,9)
	game.loot.advance(.45)
	await _save(directory,"loot-safety-installed.png")
	game.loot.messages.clear()
	# Closeups use the real game renderer and player physics, only the camera zoom changes.
	game.player.set_physics_process(true)
	await _frames(4)
	var camera_position: Vector2 = game.game_camera.position
	var camera_zoom: Vector2 = game.game_camera.zoom
	game.game_camera.zoom = Vector2.ONE*2.3
	game.game_camera.position = game.player.global_position+Vector2(0,-40)
	await _save(directory,"rescue-specialist-idle.png")
	Input.action_press("move_right")
	await _frames(8)
	game.game_camera.position = game.player.global_position+Vector2(0,-40)
	await _save(directory,"rescue-specialist-run.png")
	Input.action_release("move_right")
	game.player.try_jump()
	await _frames(5)
	game.game_camera.position = game.player.global_position+Vector2(0,-40)
	await _save(directory,"rescue-specialist-jump.png")
	game.player.try_dash(Vector2.RIGHT)
	await _frames(3)
	game.game_camera.position = game.player.global_position+Vector2(0,-40)
	await _save(directory,"rescue-specialist-dash.png")
	game.player.set_physics_process(false)
	game.game_camera.position = camera_position
	game.game_camera.zoom = camera_zoom
	var action_ids: Array[int] = []
	for id: int in range(19):
		if not SiegeUpgrades.is_awareness(id): action_ids.append(id)
	for group: int in range(7):
		_fresh()
		game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
		game.upgrades.pending = true
		game.upgrades.offers.assign([SiegeUpgrades.AWARENESS[group%5],action_ids[group*2],action_ids[group*2+1]])
		game.upgrade_overlay._refresh()
		await _frames(25)
		await _save(directory,"upgrade-cards-%02d.png" % (group+1))
		var fits: bool = true
		for card: Button in game.upgrade_overlay.cards:
			for child: Node in card.get_children():
				if child is Label: fits = fits and child.get_minimum_size().y <= child.size.y and child.position.y+child.size.y <= card.size.y
		_check(fits,"Card group %d text fits every title/effect/awareness field" % group)
	# Native keyboard and real mouse hit testing at design and scaled sizes.
	await _tap(KEY_1)
	_check(not game.upgrades.pending and game.upgrades.has_upgrade(12),"Native key 1 selects the visible left awareness card")
	game.upgrades.open_selection()
	var id: int = game.upgrades.offers[2]
	await _frames(25)
	_click(2)
	_check(not game.upgrades.pending and game.upgrades.has_upgrade(id),"Native 1920x1080 mouse selects right card")
	game.upgrades.open_selection()
	root.unresizable = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280,720)
	await _frames(8)
	print("SCALED_WINDOW physical=",DisplayServer.window_get_size()," viewport=",root.get_texture().get_size()," transform=",root.get_final_transform())
	await _save(directory,"scaled-card-layout.png",Vector2i(root.get_texture().get_size()))
	id = game.upgrades.offers[1]
	_click(1)
	_check(not game.upgrades.pending and game.upgrades.has_upgrade(id),"Scaled window mouse still selects middle card")

func _click(slot: int) -> void:
	var e: InputEventMouseButton = InputEventMouseButton.new()
	e.position = root.get_final_transform()*game.upgrade_overlay.cards[slot].get_global_rect().get_center()
	e.global_position = e.position
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	root.push_input(e,false)
	e = e.duplicate() as InputEventMouseButton
	e.pressed = false
	root.push_input(e,false)

func _save(directory: String, filename: String, size: Vector2i = Vector2i(1920,1080)) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == size and picture.save_png(directory.path_join(filename)) == OK,"Native capture %s (%s)" % [filename,picture.get_size()])

func _tap(key: int) -> void:
	var e: InputEventKey = InputEventKey.new()
	e.physical_keycode = key
	e.keycode = key
	e.pressed = true
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await _frames(2)
	e = e.duplicate() as InputEventKey
	e.pressed = false
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await _frames(1)

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
