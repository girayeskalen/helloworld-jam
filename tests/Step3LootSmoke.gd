extends SceneTree
## Step 3-B: natural 2x W floor-jump arc, per-room HP with visual states and the
## 4-room collapse rule, random-room loot and E repair/fortify.
var checks: int = 0
var failures: int = 0
var game: MainGame

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
	var loot: LootSystem = game.loot
	# Loot is advanced by hand below so drops and pickups are deterministic.
	loot.set_physics_process(false)
	loot.reset()
	await _arc_checks(p, b)
	_room_state_checks(b, w)
	await _attack_damage_checks(p, b, w)
	await _collapse_checks(p, b, w, loot)
	_loot_spawn_checks(p, b, loot)
	await _pickup_checks(p, b, loot)
	await _repair_checks(p, b, w, loot)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(argument.trim_prefix("--capture="))
	print("STEP3LOOT_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)

# ------------------------------------------------------------- 1. arc jump ----

func _arc_checks(p: SiegePlayer, b: ApartmentBuilding) -> void:
	for wait: int in [2, 6, 11]:
		p.reset_player()
		await _frames(3)
		await _tap(KEY_W)
		await _frames(wait)
		await _tap(KEY_W)
		var deck: float = b.floor_y(1)
		var ignored_while_rising: bool = p.is_shifting and p.get_collision_exceptions().has(b.floor_bodies[1])
		var highest: float = -INF
		var passed_deck_rising: bool = false
		var apex_ok: bool = false
		var landed_squash: float = 2.0
		var dust_at_landing: int = 0
		var was_shifting: bool = true
		var falls_after_apex: bool = false
		var last_y: float = p.global_position.y
		for frame: int in range(90):
			await _frames(1)
			highest = maxf(highest, deck - p.global_position.y)
			if p.global_position.y < deck and p.velocity.y < 0.0:
				passed_deck_rising = true
			if was_shifting and not p.is_shifting:
				# The frame the launch ends: speed zeroed, deck re-armed, feet above it.
				apex_ok = absf(p.velocity.y) < 30.0 and p.get_collision_exceptions().is_empty() and p.global_position.y < deck - 20.0 and p.current_floor == 1
			if not p.is_shifting and p.global_position.y > last_y + 0.1:
				falls_after_apex = true
			was_shifting = p.is_shifting
			last_y = p.global_position.y
			if p.is_on_floor() and not p.is_shifting:
				landed_squash = p.visual_scale.y
				dust_at_landing = p._dust.size()
				break
		_check(ignored_while_rising and passed_deck_rising, "Launch passes up through the ignored upper slab (second W after %d frames)" % wait)
		_check(highest >= 28.0 and highest <= 36.0, "Arc peaks 28-36 px above the upper floor, no snap (%.1f px)" % highest)
		_check(apex_ok, "At the apex the vertical speed is zero and the deck collision is re-armed")
		_check(falls_after_apex and p.is_on_floor() and p.current_floor == 1 and absf(p.global_position.y - deck) < 2.0, "Then falls under gravity and lands on floor 01")
		_check(landed_squash < 0.95 and dust_at_landing > 0, "Soft landing squash (%.2f) with dust" % landed_squash)
	# Releasing W never cuts the launch; dash is blocked while rising, free on the way down.
	p.reset_player()
	await _frames(3)
	p.try_floor_shift(1)
	await _frames(2)
	_check(not p.try_dash(Vector2.RIGHT), "No dash while launching through the slab")
	for frame: int in range(40):
		await _frames(1)
		if not p.is_shifting:
			break
	_check(p.try_dash(Vector2.RIGHT), "Air dash is available again once the arc turns down")
	await _frames(60)
	p.reset_player()
	p.current_floor = 3
	p.global_position = Vector2(b.center_x(), b.floor_y(3) - .5)
	await _frames(3)
	await _tap(KEY_W)
	await _frames(6)
	await _tap(KEY_W)
	_check(not p.is_shifting and p.current_floor == 3, "Top floor: the second W stays a plain air jump")
	await _frames(70)

# ------------------------------------------------------ 2. room HP & states ----

func _room_state_checks(b: ApartmentBuilding, w: DisasterWaveManager) -> void:
	w.reset_cycle()
	var study: RoomDiorama = b.room_at(1, 2)
	_check(study.hp == 100.0 and study.state() == RoomDiorama.RoomState.INTACT, "Rooms start intact at 100 HP")
	study.hp = 70.0
	_check(study.state() == RoomDiorama.RoomState.INTACT, "70 HP is still intact")
	study.hp = 69.9
	_check(study.state() == RoomDiorama.RoomState.DAMAGED, "Below 70 HP the room is damaged")
	study.hp = 35.0
	_check(study.state() == RoomDiorama.RoomState.DAMAGED, "35 HP is still damaged")
	study.hp = 34.9
	_check(study.state() == RoomDiorama.RoomState.CRITICAL, "Below 35 HP the room is critical")
	study.restore()
	study.apply_damage(35.0)
	var window: BuildingProp = _prop_in(study, BuildingProp.Kind.WINDOW)
	var leaning: int = 0
	for prop: BuildingProp in study.props():
		leaning += 1 if absf(prop.rotation) > 0.03 else 0
	_check(study.state() == RoomDiorama.RoomState.DAMAGED and window.condition == BuildingProp.Condition.DAMAGED and leaning >= 2, "Damaged: glass breaks and loose furniture leans (%d props)" % leaning)
	var study_light: Dictionary = _light_in(b, study)
	var intact_light: Dictionary = _light_in(b, b.room_at(1, 1))
	var flicker: Vector2 = _dim_fraction(b, study_light, intact_light, 600)
	_check(flicker.x > flicker.y + 0.05, "Damaged room lamp flickers like a faulty bulb (%.0f%% vs %.0f%% dim)" % [flicker.x * 100.0, flicker.y * 100.0])
	study.apply_damage(35.0)
	b.lighting.advance(0.0)
	_check(study.state() == RoomDiorama.RoomState.CRITICAL and Color(study_light["color_now"]).is_equal_approx(RoomLighting.EMERGENCY), "Critical: the lamp turns emergency red")
	var bright: bool = false
	var dark: bool = false
	for i: int in range(120):
		b.lighting.advance(1.0 / 60.0)
		bright = bright or float(study_light["level"]) > 0.5
		dark = dark or float(study_light["level"]) < 0.2
	_check(bright and dark, "Critical: the red lamp blinks on and off")
	study.apply_damage(40.0)
	b.lighting.advance(1.0 / 60.0)
	_check(study.is_collapsed() and study.state() == RoomDiorama.RoomState.COLLAPSED and float(study_light["level"]) == 0.0, "0 HP: the room collapses and its lamp dies")
	_check(not study.repair(45.0, true) and study.hp == 0.0, "A collapsed room cannot be patched up mid-siege")
	game.telegraphs.clear()
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	b.room_at(1, 2).hp = 0.0
	b.room_at(1, 2)._refresh_state()
	BossPatterns.room_objects(w, 0)
	var buried: bool = true
	for attack: HazardAttack in game.telegraphs.pending:
		buried = buried and attack.kind != HazardAttack.Kind.BOOK
	_check(buried, "Furniture buried in a collapsed room stops throwing hazards")
	w.reset_cycle()
	var lobby: RoomDiorama = b.room_at(0, 1)
	lobby.repair(0.0, true)
	var bolted: bool = true
	for prop: BuildingProp in lobby.props():
		if prop.kind != BuildingProp.Kind.LAMP:
			bolted = bolted and prop.condition == BuildingProp.Condition.REINFORCED and prop.rotation == 0.0
	_check(lobby.state() == RoomDiorama.RoomState.FORTIFIED and bolted, "Fortified: furniture L-bracketed upright (state FORTIFIED)")
	_check(is_equal_approx(lobby.apply_damage(20.0), 10.0) and is_equal_approx(lobby.hp, 90.0), "Column support halves quake damage")
	var master: RoomDiorama = b.room_at(2, 0)
	master.repair(0.0, true)
	_check(_prop_in(master, BuildingProp.Kind.WINDOW).condition == BuildingProp.Condition.REINFORCED, "Fortified window gets shutters and sandbags")
	var total: float = 0.0
	for room: RoomDiorama in b.rooms:
		total += room.hp
	_check(is_equal_approx(b.integrity, total / 16.0), "Building integrity is the average of the 16 room HP values (%.1f)" % b.integrity)
	b.room_at(3, 1).hp = 60.0
	b.room_at(3, 1)._refresh_state()
	var before: float = b.room_at(3, 2).hp
	b.erode(4.0, w.room_erosion)
	_check(is_equal_approx(b.room_at(3, 1).hp, 59.0) and b.room_at(3, 2).hp == before, "Damaged rooms keep crumbling slowly; intact ones do not")
	w.reset_cycle()
	var restored: bool = master.hp == 100.0 and not master.fortified and _prop_in(master, BuildingProp.Kind.WINDOW).condition == BuildingProp.Condition.DAMAGED
	for room: RoomDiorama in b.rooms:
		restored = restored and room.hp == 100.0 and not room.fortified
	_check(restored, "Reset restores every room and the authored prop states")

# ------------------------------------------------- 3. damage from attacks ----

func _attack_damage_checks(p: SiegePlayer, b: ApartmentBuilding, w: DisasterWaveManager) -> void:
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	var target: RoomDiorama = b.room_at(2, 3)
	var x: float = target.global_position.x + 200.0
	var brick: HazardAttack = w._attack(HazardAttack.Kind.BRICK, 2, Vector2(x, b.floor_y(2) - 172), Vector2(0, 70))
	brick.motion = HazardAttack.Motion.ARC
	brick.gravity = 630
	brick.lifetime = w._flight_time(brick)
	w.plan_attack(brick, .6)
	await _frames(int((0.6 + brick.lifetime) * 60.0) + 4)
	var untouched: bool = true
	for room: RoomDiorama in b.rooms:
		if room != target:
			untouched = untouched and room.hp == 100.0
	_check(is_equal_approx(target.hp, 100.0 - DisasterWaveManager.room_damage(brick)) and untouched, "A falling brick damages only the room it lands in (%.1f HP)" % target.hp)
	target.repair(0.0, true)
	var fortified_before: float = target.hp
	w.plan_attack(brick, .6)
	await _frames(int((0.6 + brick.lifetime) * 60.0) + 4)
	_check(is_equal_approx(fortified_before - target.hp, DisasterWaveManager.room_damage(brick) * 0.5), "The same brick does 50% damage to a fortified room")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	p.current_floor = 0
	BossPatterns.full_row(w, 1, 0)
	await _frames(115)
	var swept: bool = true
	for column: int in range(4):
		swept = swept and is_equal_approx(b.room_at(1, column).hp, 100.0 - DisasterWaveManager.ROOM_DAMAGE[HazardAttack.Kind.ROW_SWEEP])
	_check(swept and b.room_at(0, 0).hp == 100.0, "A full-floor sweep wears down all four rooms of that floor")
	w.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	BossPatterns.ground_wave(w, 3, false)
	await _frames(46)
	var rattled: bool = true
	for column: int in range(4):
		rattled = rattled and b.room_at(3, column).hp <= 100.0 - w.slam_tremor + 0.001
	_check(rattled and b.room_at(2, 0).hp == 100.0, "A golem slam rattles every room on the struck floor")
	w.reset_cycle()

# -------------------------------------------------------- 4. collapse rule ----

func _collapse_checks(p: SiegePlayer, b: ApartmentBuilding, w: DisasterWaveManager, loot: LootSystem) -> void:
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	for index: int in [2, 7, 9]:
		b.rooms[index].apply_damage(500.0)
	w.advance_wave(1.0 / 60.0)
	_check(b.collapsed_count() == 3 and not w.failed, "Three collapsed rooms: the building still stands")
	b.rooms[12].apply_damage(500.0)
	w.advance_wave(1.0 / 60.0)
	_check(w.failed and w.fail_reason == DisasterWaveManager.FailReason.BUILDING and b.collapsed_building, "A 4th collapsed room brings the whole building down")
	_check(w.phase_label() == "BİNA ÇÖKTÜ! ODALARI ZAMANINDA ONARAMADIN", "Failure message: BİNA ÇÖKTÜ! ODALARI ZAMANINDA ONARAMADIN")
	_check(game.telegraphs.pending.is_empty() and game.projectiles.active_count() == 0 and game.game_camera.shake_strength() > 10.0, "Collapse clears the hazards and shakes the screen")
	loot.column_kits = 1
	b.room_at(0, 1).hp = 50.0
	b.room_at(0, 1)._refresh_state()
	_check(not loot.can_offer_repair() and loot.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED and loot.column_kits == 1, "No repairs once the building has fallen")
	for i: int in range(120):
		b.lighting.advance(1.0 / 60.0)
	var lit: int = 0
	for light: Dictionary in b.lighting.lights:
		lit += 1 if float(light["level"]) > 0.0 else 0
	_check(lit == 0, "After the collapse every light goes dark")
	loot.column_kits = 3
	_key(KEY_R, true)
	await _frames(2)
	_key(KEY_R, false)
	var fresh: bool = not w.failed and not b.collapsed_building and b.collapsed_count() == 0 and b.integrity == 100.0
	_check(fresh and loot.materials() == 0 and loot.items.is_empty(), "R rebuilds the apartment and clears loot")
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	b.damage_integrity(100.0)
	w.advance_wave(1.0 / 60.0)
	_check(w.failed and w.fail_reason == DisasterWaveManager.FailReason.BUILDING, "0% building integrity is also a collapse")
	w.reset_cycle()
	p.reset_player()

# ------------------------------------------------------------- 5. loot drops ----

func _loot_spawn_checks(p: SiegePlayer, b: ApartmentBuilding, loot: LootSystem) -> void:
	game.waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	game.waves.advance_wave(DisasterWaveManager.INTRO_DURATION)
	game.waves.building.pacing_enabled = false
	loot.reset()
	p.reset_player()
	var player_room: int = loot.player_room_index()
	b.rooms[5].apply_damage(500.0)
	var times: Array[float] = []
	var clock: float = 0.0
	var kinds: Dictionary = {}
	var rooms_seen: Dictionary = {}
	var repeat: bool = false
	var bad_room: bool = false
	var bad_spot: bool = false
	var previous: int = -1
	while times.size() < 40 and clock < 300.0:
		var count: int = loot.spawn_count
		loot.advance(1.0 / 60.0)
		clock += 1.0 / 60.0
		if loot.spawn_count > count:
			times.append(clock)
			var item: Dictionary = loot.items[loot.items.size() - 1]
			var index: int = item["room"]
			var room: RoomDiorama = b.rooms[index]
			kinds[int(item["kind"])] = true
			rooms_seen[index] = true
			repeat = repeat or index == previous
			bad_room = bad_room or index == player_room or room.is_collapsed()
			var spot: Vector2 = item["position"]
			bad_spot = bad_spot or spot.x < room.global_position.x + 60.0 or spot.x > room.global_position.x + 340.0 or not is_equal_approx(spot.y, b.floor_y(room.floor_index) - 26.0)
			previous = index
			if loot.items.size() >= 3:
				loot.items.pop_front()
	var spacing: bool = times[0] >= 5.5 and times[0] <= 6.52
	for i: int in range(1, times.size()):
		var gap: float = times[i] - times[i - 1]
		spacing = spacing and gap >= 5.5 - 0.02 and gap <= 6.5 + 0.02
	_check(times.size() == 40 and spacing, "Every drop, including the first, waits 5.5-6.5 s")
	_check(not repeat, "Each drop lands in a different room than the previous one")
	_check(not bad_room, "Drops avoid the player's room and collapsed rooms")
	_check(rooms_seen.size() >= 10, "Drops spread across the building (%d rooms)" % rooms_seen.size())
	_check(kinds.size() == 4, "All four equipment kinds drop")
	_check(not bad_spot, "Drops rest on the floor inside the room interior")
	loot.reset()
	for i: int in range(60 * 40):
		loot.advance(1.0 / 60.0)
	_check(loot.items.size() <= 1 and loot.expired_count >= 4, "Uncollected drops expire before the next normal spawn")
	loot.clear_drops()
	for i: int in range(3): loot.spawn(i, i + 6)
	_check(loot.items.size() == 3 and not loot.spawn(0, 10), "Hard cap: a fourth drop is refused")
	b.rooms[5].restore()
	loot.reset()
	loot.spawn(LootSystem.Kind.COLUMN_KIT, 7)
	b.rooms[7].apply_damage(500.0)
	loot.advance(1.0 / 60.0)
	_check(loot.items.is_empty(), "A drop is lost under the rubble when its room collapses")
	b.rooms[7].restore()
	loot.reset()

# ---------------------------------------------------------------- 6. pickup ----

func _pickup_checks(p: SiegePlayer, b: ApartmentBuilding, loot: LootSystem) -> void:
	game.waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	game.waves.advance_wave(DisasterWaveManager.INTRO_DURATION)
	game.waves.building.pacing_enabled = false
	p.reset_player()
	await _frames(3)
	var here: int = loot.player_room_index()
	loot.spawn(LootSystem.Kind.COLUMN_KIT, here)
	var spot: Vector2 = loot.items[0]["position"]
	loot.items[0]["position"] = Vector2(p.global_position.x + 120.0, spot.y)
	loot.advance(0.1)
	p.global_position.x = loot.items[0]["position"].x
	loot.advance(0.0)
	_check(loot.items.size() == 1 and loot.column_kits == 0, "A drop still falling from the ceiling cannot be grabbed")
	loot.advance(0.5)
	_check(loot.items.is_empty() and loot.column_kits == 1, "Walking over a landed drop collects it")
	_check(not loot.messages.is_empty() and String(loot.messages[loot.messages.size() - 1]["text"]).begins_with("+1"), "Pickup floats '+1 ...' feedback")
	p.health = 50.0
	p.stamina = 10.0
	loot.spawn(LootSystem.Kind.EMERGENCY_BAG, here)
	loot.items[0]["position"] = Vector2(p.global_position.x, loot.items[0]["position"].y)
	loot.advance(0.5)
	_check(is_equal_approx(p.health, 50.0 + loot.medkit_heal) and p.stamina == 100.0, "Medkit: +%d HP (2 health units) and a full dash meter" % int(loot.medkit_heal))
	loot.spawn(LootSystem.Kind.BARRICADE_KIT, 6)
	loot.items[0]["position"] = Vector2(p.global_position.x, b.floor_y(1) - 26.0)
	loot.advance(0.5)
	# (The loot clock kept running, so a regular timed drop may also be waiting elsewhere.)
	var upstairs: int = 0
	for item: Dictionary in loot.items:
		upstairs += 1 if int(item["kind"]) == LootSystem.Kind.BARRICADE_KIT and int(item["room"]) == 6 else 0
	_check(upstairs == 1 and loot.barricade_kits == 0, "Drops on another floor are not collected through the ceiling")
	loot.reset()
	p.reset_player()

# ---------------------------------------------------------------- 7. repair ----

func _repair_checks(p: SiegePlayer, b: ApartmentBuilding, w: DisasterWaveManager, loot: LootSystem) -> void:
	w.start_siege(DisasterWaveManager.Mode.STORM, true)
	w.advance_wave(DisasterWaveManager.INTRO_DURATION)
	w.building.pacing_enabled = false
	await _frames(3)
	var room: RoomDiorama = loot.current_room()
	_check(room == b.room_at(0, 1), "Current room resolves from floor and column")
	loot.column_kits = 2
	loot.barricade_kits = 1
	await _tap(KEY_E)
	_check(room.hp == 100 and not room.fortified and loot.column_kits == 2 and loot.messages.is_empty(), "Healthy siege room: E is silent, spends nothing and never fortifies")
	room.apply_damage(60.0)
	var integrity_before: float = b.integrity
	loot.column_kits = 0
	_check(loot.repair_alert(room) and not loot.can_offer_repair(), "Damaged room keeps its visible warning even without cement")
	await _tap(KEY_E)
	_check(room.hp == 40 and loot.barricade_kits == 0 and room.reinforcement_level == 2, "Barrier kit anchors and barricades an alerted room without healing it")
	await _tap(KEY_E)
	_check(loot.messages.back()["text"] == "ONARIM KİTİ YOK · KOLON KİTİ TOPLA", "Repair explains the missing column kit")
	loot.column_kits = 1
	_check(loot.can_offer_repair(), "Damaged room plus cement enables repair")
	await _rendered()
	_check(game.labels.repair_markers == 1, "Damaged room has exactly one ONAR marker")
	await _tap(KEY_E)
	await _frames(1)
	_check(room.hp == 85 and room.reinforcement_level == 3 and loot.column_kits == 0 and loot.barricade_kits == 0, "Siege column kit: +45 HP and structural support; barrier remains installed")
	_check(is_equal_approx(b.integrity, integrity_before + 45.0 / 16.0), "Room repair increases building integrity")
	await _rendered()
	_check(not loot.repair_alert(room) and game.labels.repair_markers == 0, "Repair eligibility and visible warning disappear together")
	loot.column_kits = 1
	var message_count: int = loot.messages.size()
	_check(loot.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED and loot.column_kits == 1 and loot.messages.size() == message_count, "INTACT 85 HP room cannot be repaired again during siege")
	room.apply_damage(500)
	_check(loot.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED and loot.column_kits == 1, "Collapsed siege room is not a repair target")
	var critical: RoomDiorama = b.room_at(2,2)
	critical.apply_damage(80)
	await _rendered()
	_check(game.labels.repair_markers == 1, "Critical rooms show the same actionable marker")
	w.finish_wave()
	w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	game.upgrades.offers.assign([0,1,2])
	game.upgrades.choose(0)
	p.global_position.x = b.room_at(0,2).global_position.x + 200
	await _frames(2)
	_check(loot.can_build() and loot.repair_current_room() == LootSystem.RepairResult.REINFORCED and b.room_at(0,2).reinforcement_level == 1, "Build phase permits reinforcing a healthy room with the column kit")
	w.reset_cycle()
	p.reset_player()

# ------------------------------------------------------------- captures ----

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless":
		_check(false, "Capture requires native renderer")
		return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	await _frames(40)
	var b: ApartmentBuilding = game.building
	var p: SiegePlayer = game.player
	var loot: LootSystem = game.loot
	game.waves.reset_cycle()
	loot.reset()
	p.reset_player()
	# Showcase: one row per state, drops of every kind and a repairable room.
	b.room_at(3, 0).repair(0.0, true)
	b.room_at(3, 2).apply_damage(45.0)
	b.room_at(3, 3).apply_damage(80.0)
	b.room_at(2, 1).apply_damage(500.0)
	b.room_at(2, 3).apply_damage(40.0)
	b.room_at(1, 0).repair(0.0, true)
	b.room_at(1, 3).apply_damage(70.0)
	b.room_at(0, 1).apply_damage(40.0)
	loot.spawn(LootSystem.Kind.COLUMN_KIT, 2)
	loot.spawn(LootSystem.Kind.BARRICADE_KIT, 6)
	loot.spawn(LootSystem.Kind.EMERGENCY_BAG, 13)
	loot.column_kits = 2
	loot.barricade_kits = 1
	for i: int in range(40):
		loot.advance(1.0 / 60.0)
		await _frames(1)
	await _save(directory, "room-states-loot.png")
	await _tap(KEY_E)
	await _frames(6)
	await _save(directory, "repair-fortify.png")
	await _frames(40)
	await _tap(KEY_W)
	await _frames(6)
	await _tap(KEY_W)
	await _frames(9)
	await _save(directory, "arc-rise.png")
	for frame: int in range(30):
		if not p.is_shifting:
			break
		await _frames(1)
	await _save(directory, "arc-apex.png")
	for frame: int in range(40):
		await _frames(1)
		if p.is_on_floor():
			break
	await _frames(1)
	await _save(directory, "arc-land.png")
	game.waves.start_siege(DisasterWaveManager.Mode.CHAOS, true)
	game.waves.advance_wave(DisasterWaveManager.INTRO_DURATION)
	game.waves.building.pacing_enabled = false
	for i: int in range(240):
		loot.advance(1.0 / 60.0)
		await _frames(1)
	await _save(directory, "siege-damage.png")
	# Room 9 is already down from the showcase: three more make four.
	for index: int in [8, 10, 11]:
		b.rooms[index].apply_damage(500.0)
	game.waves.advance_wave(1.0 / 60.0)
	await _frames(20)
	await _save(directory, "building-collapse.png")
	game.waves.reset_cycle()
	loot.reset()

# ---------------------------------------------------------------- helpers ----

func _prop_in(room: RoomDiorama, kind: int) -> BuildingProp:
	for prop: BuildingProp in room.props():
		if prop.kind == kind:
			return prop
	return null

func _light_in(b: ApartmentBuilding, room: RoomDiorama) -> Dictionary:
	for light: Dictionary in b.lighting.lights:
		if light["room"] == room:
			return light
	return {}

## Fraction of frames each lamp is dimmed (<0.5) over the same stretch of time.
func _dim_fraction(b: ApartmentBuilding, first: Dictionary, second: Dictionary, frames: int) -> Vector2:
	var a: int = 0
	var c: int = 0
	for i: int in range(frames):
		b.lighting.advance(1.0 / 60.0)
		a += 1 if float(first["level"]) < 0.5 else 0
		c += 1 if float(second["level"]) < 0.5 else 0
	return Vector2(float(a) / frames, float(c) / frames)

func _save(directory: String, filename: String) -> void:
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Rendered " + filename)

## Screen labels are rebuilt when a frame is drawn; in a real window several physics
## steps can pass between draws, so wait for actual rendered frames (headless: process).
func _rendered() -> void:
	for i: int in range(3):
		await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw

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
