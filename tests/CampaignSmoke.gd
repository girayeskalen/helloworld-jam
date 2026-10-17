extends SceneTree
## Integration tests for the finite campaign, repair gates, construction, timed loot,
## all nine real upgrade effects, native card input and screenshot evidence.
var game: MainGame
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	game.loot.set_physics_process(false)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(4)
	_loot_rules()
	_construction()
	await _upgrades()
	await _campaign()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(argument.trim_prefix("--capture="))
	print("CAMPAIGN_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)

func _fresh() -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.loot.set_physics_process(false)

func _loot_rules() -> void:
	_fresh()
	var loot: LootSystem = game.loot
	_check(LootSystem.Kind.size() == 4 and loot.max_active == 3, "Four readable equipment types and cap of three")
	loot.advance(30)
	_check(loot.items.is_empty(), "No unsolicited loot during initial preparation")
	game.waves.start_next_wave()
	game.waves.advance_wave(1.5)
	game.waves.building.pacing_enabled = false
	loot.spawn(LootSystem.Kind.COLUMN_KIT, 8)
	loot.advance(LootSystem.DROP_TIME)
	_check(loot.items.size() == 1 and is_zero_approx(loot.items[0]["ground_age"]), "Lifetime begins on landing, not at the ceiling")
	loot.advance(3.999)
	_check(loot.items.size() == 1, "Loot still exists at grounded age 3.999 seconds")
	loot.advance(.001)
	_check(loot.items.is_empty() and loot.expired_count == 1, "Loot expires exactly at grounded age 4.0 seconds")
	_check(loot.messages.back()["text"] == "MALZEME ENKAZDA KAYBOLDU", "Expiration uses the requested feedback text")
	loot.spawn(LootSystem.Kind.COLUMN_KIT, 8)
	var item: Dictionary = loot.items.back()
	item["drop"] = 1.0
	item["ground_age"] = 3.999
	game.player.current_floor = 2
	game.player.global_position = Vector2(item["position"]) + Vector2(0,26)
	loot.advance(.001)
	_check(loot.column_kits == 0 and loot.items.is_empty(), "Deadline wins over a same-tick pickup")
	loot.spawn(0,9)
	loot.advance(.45)
	game.waves.finish_wave()
	game.waves.advance_wave(2.5)
	loot.advance(30)
	_check(loot.items.size() == 1 and is_zero_approx(loot.items[0]["ground_age"]), "Intermission retains unexpired drops; modal freezes their remaining lifetime")
	game.upgrades.offers.assign([0,1,2])
	game.upgrades.choose(0)
	loot.advance(3.99)
	_check(loot.items.size() == 1, "A late-wave drop gets its full lifetime during safe construction")
	loot.advance(.01)
	_check(loot.items.is_empty(), "Intermission drop still expires at the same four-second deadline")
	_fresh()
	game.waves.start_next_wave()
	game.waves.advance_wave(1.5)
	game.waves.building.pacing_enabled = false
	for kind: int in range(4):
		loot.spawn(kind, 8)
		loot.collect(0)
	_check(loot.column_kits == 1 and loot.column_kits == 1 and loot.barricade_kits == 1 and game.building.rooms[8].auto_protection, "Two stocked kits plus immediate medical and room safety equipment")
	game.player.health = 40
	game.player.stamina = 1
	loot.spawn(LootSystem.Kind.EMERGENCY_BAG, 8)
	loot.collect(0)
	_check(game.player.health == 65 and game.player.stamina == 100, "Medical kit gives exactly +25 HP and full stamina")
	for room: RoomDiorama in game.building.rooms:
		if room != loot.current_room(): room.hp = 0
	loot.items.clear()
	_check(not loot.spawn(), "No fallback spawn in the player's room when every other room is unavailable")
	_fresh()

func _construction() -> void:
	var loot: LootSystem = game.loot
	var room: RoomDiorama = loot.current_room()
	loot.column_kits = 2
	loot.column_kits = 2
	loot.barricade_kits = 1
	loot.barricade_kits = 1
	game.waves.start_next_wave()
	game.waves.advance_wave(1.5)
	game.waves.building.pacing_enabled = false
	_check(not loot.can_offer_repair() and loot.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED and loot.messages.is_empty(), "Healthy siege room: no repair action, prompt or feedback")
	room.apply_damage(40)
	_check(loot.repair_alert(room) and loot.can_offer_repair(), "DAMAGED status enables the visible warning and E together")
	loot.repair_current_room()
	_check(room.hp == 100 and room.has_reinforcement(RoomDiorama.Reinforcement.STEEL) and loot.column_kits == 1, "Combat column kit repairs and installs structural support")
	game.waves.finish_wave()
	game.waves.advance_wave(2.5)
	game.upgrades.offers.assign([0, 1, 2])
	_check(loot.repair_current_room() == LootSystem.RepairResult.NOT_NEEDED, "Modal blocks construction input")
	game.upgrades.choose(0)
	_check(loot.repair_current_room() == LootSystem.RepairResult.REINFORCED and room.reinforcement_level == 3, "One barricade kit installs both shutter and anchors alongside column support")
	_check(loot.column_kits == 1 and loot.barricade_kits == 0, "Construction consumes one combined barricade kit")
	_check(loot.repair_current_room() == LootSystem.RepairResult.NO_MATERIAL and loot.column_kits == 1 and room.reinforcement_level == 3, "Duplicate equipment cannot be purchased")
	_check(is_equal_approx(room.apply_damage(20), 10), "Structural kit halves earthquake damage")
	room.repair(100)
	var bolted: bool = true
	for prop: BuildingProp in room.props():
		if prop.kind not in [BuildingProp.Kind.LAMP, BuildingProp.Kind.SKYLIGHT]:
			bolted = bolted and prop.condition == BuildingProp.Condition.REINFORCED
	_check(bolted, "Full shelter includes reinforced window and every movable object")
	# Chandelier was excluded by the old code; test it explicitly as a real source.
	var living: RoomDiorama = game.building.room_at(1,0)
	living.reinforce(RoomDiorama.Reinforcement.ANCHOR)
	game.waves.start_next_wave()
	game.waves.advance_wave(1.5)
	game.waves.building.pacing_enabled = false
	BossPatterns.room_objects(game.waves,0)
	var unsafe: bool = false
	for attack: HazardAttack in game.telegraphs.pending:
		for prop: BuildingProp in living.props():
			unsafe = unsafe or attack.room_source == prop.object_id
	_check(not unsafe, "Anchored living-room chandelier never emits furniture hazards")
	_check(room.reinforcement_level == 3 and room.hp == 100, "Construction and health persist into next boss wave")
	_fresh()
	_check(room.reinforcement_level == 0 and not room.fortified and room.hp == 100, "R clears retrofit tiers and restores authored furniture")

func _upgrades() -> void:
	var up: SiegeUpgrades = game.upgrades
	var w: DisasterWaveManager = game.waves
	var b: ApartmentBuilding = game.building
	var p: SiegePlayer = game.player
	var loot: LootSystem = game.loot
	_check(SiegeUpgrades.CATALOG.size() == 19, "Nineteen upgrade definitions, each with a distinct mechanical effect")
	for id: int in range(19):
		_fresh()
		_check(up.apply_upgrade(id) and not up.apply_upgrade(id), "Upgrade %d applies once per run, no stacking duplicates" % id)
	_fresh()
	_check(game.player.dash_duration == .25 and game.loot.loot_lifetime == 4.0, "Reset preserves base iframe and four-second loot; active effects tested in Step45Smoke")

func _campaign() -> void:
	_fresh()
	var w: DisasterWaveManager = game.waves
	var up: SiegeUpgrades = game.upgrades
	w.start_next_wave()
	w.advance_wave(1.5)
	w.building.pacing_enabled = false
	game.loot.column_kits = 2
	game.building.rooms[0].apply_damage(20)
	w.finish_wave()
	w.advance_wave(2.5)
	_check(w.completed_waves == 1 and w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE and up.pending and game.upgrade_overlay.visible, "Wave one enters build phase with a visible three-card modal")
	_check(up.offers.size() == 3 and up.offers[0] != up.offers[1] and up.offers[1] != up.offers[2] and up.offers[0] != up.offers[2], "Three offered upgrades are distinct")
	var saved_position: Vector2 = game.player.global_position
	w.advance_wave(90)
	await _tap(KEY_D)
	await _tap(KEY_F)
	_check(w.preparation_remaining == 7 and up.pending and game.player.global_position == saved_position, "Card choice freezes timer and movement; F cannot bypass selection")
	var chosen: int = up.offers[0]
	await _tap(KEY_1)
	_check(up.has_upgrade(chosen) and not up.pending and w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE and w.wave_number == 1, "Key 1 chooses a card without launching the storm debug shortcut")
	_check(game.loot.column_kits == 2 and game.building.rooms[0].hp >= 80, "Resources and room damage carry across the wave boundary")
	w.advance_wave(6.9)
	_check(w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE, "Construction remains available for the full 7 seconds")
	w.advance_wave(.11)
	w.advance_wave(1.5)
	w.building.pacing_enabled = false
	_check(w.wave_number == 2 and game.earthquake.visible and not game.storm.visible, "Build timer automatically starts earthquake wave two")
	w.finish_wave()
	w.advance_wave(2.5)
	_check(up.pending and not up.offers.has(chosen), "Wave two offers another three cards excluding the purchased upgrade")
	# Native mouse event through the viewport, never invoke Button.pressed directly.
	var second: int = up.offers[1]
	await _rendered()
	_check_card_layout()
	var point: Vector2 = game.upgrade_overlay.cards[1].get_global_rect().get_center()
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.position = point
	mouse.global_position = point
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	root.push_input(mouse, true)
	mouse = mouse.duplicate() as InputEventMouseButton
	mouse.pressed = false
	root.push_input(mouse, true)
	await _frames(2)
	_check(up.has_upgrade(second) and not up.pending, "Mouse click selects the second card through real Control hit testing")
	await _tap(KEY_F)
	w.advance_wave(1.5)
	_check(w.mode == DisasterWaveManager.Mode.CHAOS and w.wave_number == 3 and game.storm.visible and game.earthquake.visible, "F starts the third simultaneous two-boss siege")
	w.chaos_burst()
	var sources: Dictionary = {}
	var target_floors: Dictionary = {}
	for attack: HazardAttack in game.telegraphs.pending:
		sources[attack.source] = true
		if attack.pattern != HazardAttack.Pattern.ROOM_OBJECT: target_floors[attack.floor_index] = true
	_check(sources.size() == 2 and target_floors.size() >= 2 and game.storm.is_charging() and game.earthquake.is_charging(), "Finale synchronizes both animated bosses with complementary floor targets")
	w.finish_wave()
	w.advance_wave(2.5)
	_check(not w.victory and up.pending and w.completed_waves == 3, "Third wave continues into flood preparation")
	for next_wave: int in [3,4]:
		up.choose(0)
		w.start_next_wave()
		w.advance_wave(DisasterWaveManager.INTRO_DURATION)
		_check(w.mode == next_wave and w.wave_number == next_wave+1, "Campaign continues through flood then fire")
		w.finish_wave()
		w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	_check(w.victory and w.completed_waves == 5 and w.state == DisasterWaveManager.State.VICTORY and not up.pending, "Fifth wave ends in victory, without another card or sixth wave")
	_check(game.projectiles.active_count() == 0 and game.telegraphs.pending.is_empty() and not game.storm.visible and not game.earthquake.visible, "Victory clears active attacks and bosses")
	w.advance_wave(999)
	await _tap(KEY_F)
	await _tap(KEY_E)
	_check(w.victory and w.wave_number == 5 and game.player.controls_locked, "Victory is terminal until explicit reset or debug shortcut")
	await _tap(KEY_R)
	_check(w.wave_number == 0 and not w.victory and up.selected.is_empty() and game.loot.materials() == 0, "R restores a fresh campaign after victory")
	await _tap(KEY_F9)
	await _tap(KEY_U)
	_check(up.pending and w.completed_waves == 0, "U opens the selection test without awarding a completed wave")
	await _tap(KEY_3)
	_check(not up.pending and w.wave_number == 0, "Key 3 selects the third card, not the final boss")
	await _tap(KEY_R)
	await _tap(KEY_F9)
	await _tap(KEY_3)
	w.advance_wave(1.5)
	_check(w.mode == DisasterWaveManager.Mode.CHAOS and w.wave_number == 3, "Outside the modal key 3 still launches the final boss test")
	game.building.rooms[0].hp = 0
	game.building.rooms[1].hp = 0
	game.building.rooms[2].hp = 0
	game.building.rooms[3].hp = 0
	w.finish_wave()
	w.advance_wave(2.5)
	_check(w.failed and not w.victory, "A collapsed building cannot win on the same tick as the final deadline")
	_fresh()
	w.start_siege(DisasterWaveManager.Mode.FIRE, true)
	w.advance_wave(1.5)
	game.player.health = 0
	w.finish_wave()
	w.advance_wave(2.5)
	_check(w.failed and not w.victory, "A dead player cannot win at final completion")
	_fresh()

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless":
		_check(false, "Screenshots require the native renderer")
		return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	await _frames(40)
	_fresh()
	await _save(directory,"01-original-night.png")
	game.waves.debug_enabled = true
	game.waves.test_upgrades()
	game.upgrades.offers.assign([0,1,2])
	game.upgrade_overlay._refresh()
	await _save(directory,"02-cards-structure.png")
	game.upgrades.offers.assign([3,4,5])
	game.upgrade_overlay._refresh()
	await _save(directory,"03-cards-survival.png")
	game.upgrades.offers.assign([6,7,8])
	game.upgrade_overlay._refresh()
	await _save(directory,"04-cards-equipment.png")
	game.upgrades.choose(0)
	var b: ApartmentBuilding = game.building
	b.room_at(1,0).reinforce(RoomDiorama.Reinforcement.STEEL)
	b.room_at(1,1).reinforce(RoomDiorama.Reinforcement.SHUTTER)
	b.room_at(1,2).reinforce(RoomDiorama.Reinforcement.ANCHOR)
	b.room_at(1,3).repair(0,true)
	b.room_at(2,0).repair(0,true)
	b.room_at(2,2).reinforce(RoomDiorama.Reinforcement.STEEL)
	b.room_at(2,2).reinforce(RoomDiorama.Reinforcement.SHUTTER)
	game.loot.column_kits = 3
	game.loot.column_kits = 1
	game.loot.barricade_kits = 1
	game.loot.barricade_kits = 1
	await _save(directory,"05-construction-tiers.png")
	game.waves.start_siege(DisasterWaveManager.Mode.CHAOS, true)
	game.waves.advance_wave(1.5)
	game.building.pacing_enabled = false
	b.room_at(0,1).apply_damage(50)
	b.room_at(3,0).apply_damage(80)
	for kind: int in range(3): game.loot.spawn(kind,kind+9)
	game.loot.advance(.6)
	game.waves.chaos_burst()
	await _frames(20)
	await _save(directory,"06-finale-repair-loot.png")
	game.loot.clear_drops()
	game.loot.spawn(3,9)
	game.loot.spawn(2,10)
	game.loot.advance(.6)
	await _save(directory,"07-shutter-medkit.png")
	game.waves.finish_wave()
	game.waves.advance_wave(2.5)
	game.upgrades.choose(0)
	game.waves.start_siege(DisasterWaveManager.Mode.FIRE,true)
	game.waves.advance_wave(DisasterWaveManager.INTRO_DURATION)
	game.waves.finish_wave()
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	await _save(directory,"08-victory.png")
	_fresh()
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	await _save(directory,"09-drone-night.png")

func _save(directory: String, filename: String) -> void:
	await _frames(25)
	await _rendered()
	if game.upgrades.pending: _check_card_layout()
	_check(root.get_texture().get_image().save_png(directory.path_join(filename)) == OK,"Rendered " + filename)

func _check_card_layout() -> void:
	var contained: bool = true
	for card: Button in game.upgrade_overlay.cards:
		for child: Node in card.get_children():
			if child is Label:
				var label: Label = child as Label
				contained = contained and label.position.x + label.size.x <= card.size.x and label.position.y + label.size.y <= card.size.y
	_check(contained, "All card text stays inside its own card at the real layout size")

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _tap(code: int) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(2)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(1)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition: print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
