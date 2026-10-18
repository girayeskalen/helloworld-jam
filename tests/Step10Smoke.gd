extends SceneTree
## Section-entry checkpoints, retry vs new game, campaign shortcuts and native UI.
var game: MainGame
var checks: int = 0
var failures: int = 0
var captures: String = ""
var preferences: String

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	preferences = "user://step10-%d.cfg" % Time.get_ticks_usec()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): captures = argument.trim_prefix("--capture=")
	if captures != "" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920, 1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	game.show_main_menu = true
	game.menu_settings_path = preferences
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(15)
	game.sound.bake_all_now()
	await _menu()
	_quiet()
	for section: int in range(4):
		await _retry(section, false)
		await _retry(section, true)
	await _tutorial()
	await _shortcuts()
	await _hud()
	await _new_games()
	print("STEP10_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await _frames(3)
	DirAccess.remove_absolute(preferences)
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _quiet() -> void:
	for node: Node in [game.player, game.loot, game.telegraphs, game.projectiles, game.mechanics, game.preparedness, game.tutorial]:
		node.set_physics_process(false)

func _menu() -> void:
	var menu: SiegeFrontEnd = game.front_end
	_check(menu.active and menu.home.visible, "Launch opens the home menu")
	for index: int in range(4):
		var entry: MenuItem = menu.buttons["section_%d" % index]
		_check(entry.text == GameHUD.SECTION_LABELS[index] and entry.get_theme_font_size("font_size") >= UIStyle.SMALL, "Menu section %d uses the pixel font and readable size" % (index + 1))
		_check(entry.get_global_rect().end.y < 1080, "Menu section %d is on screen" % (index + 1))
	await _save("main-menu.png")
	_key(KEY_F)
	_key(KEY_R)
	_check(menu.active and not menu.launching and game.waves.wave_number == 0, "F and R stay isolated in the menu")
	# Real scaled GUI mouse events and the physical number keys each select all four.
	for index: int in range(4):
		_click(menu.buttons["section_%d" % index])
		await _frames(20)
		_check(not menu.active and game.waves.mode == DisasterWaveManager.CAMPAIGN[index] and game.waves.wave_number == index + 1 and game.waves.state == DisasterWaveManager.State.WAVE_INTRO, "Mouse launches section %d with its retained boss entry" % (index + 1))
		_check(game.phase_checkpoint != null and game.phase_checkpoint.completed_waves == index, "Menu section %d also captures a checkpoint" % (index + 1))
		menu.open()
		_key(KEY_1 + index)
		await _frames(20)
		_check(not menu.active and game.waves.wave_number == index + 1 and game.waves.mode == DisasterWaveManager.CAMPAIGN[index], "Menu number key launches campaign section %d" % (index + 1))
		menu.open()
	# Keyboard focus reaches every section after the three primary menu entries.
	for tick: int in range(3):
		_key(KEY_DOWN)
		await _frames(1)
	for index: int in range(4):
		_check((menu.buttons["section_%d" % index] as Button).has_focus(), "Arrow navigation reaches section %d" % (index + 1))
		if index < 3:
			_key(KEY_DOWN)
			await _frames(1)
	_key(KEY_ENTER)
	await _frames(20)
	_check(not menu.active and game.waves.mode == DisasterWaveManager.Mode.CATACLYSM, "Enter launches the focused section")
	menu.open()
	menu.show_settings()
	_key(KEY_2)
	_check(menu.active and menu.settings_open and not menu.launching, "Number keys do not launch a hidden section from settings")
	menu.show_home()
	menu.start_run()
	await _frames(20)
	_check(game.waves.wave_number == 0 and game.waves.state == DisasterWaveManager.State.PREPARATION_PHASE, "Normal Start still opens first preparation, without a forced boss")

func _retry(section: int, collapse: bool) -> void:
	game.tutorial.enabled = false
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	w.completed_waves = section
	w._next_mode = DisasterWaveManager.CAMPAIGN[section]
	w.state = DisasterWaveManager.State.PREPARATION_PHASE if section == 0 else DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	for id: int in [SiegeUpgrades.Kind.DOME, SiegeUpgrades.Kind.AWARE_STRUCTURE, SiegeUpgrades.Kind.AUTO_DRONE]: game.upgrades.apply_upgrade(id)
	for task: Dictionary in game.preparedness.pending(): game.preparedness.complete(task)
	game.loot.column_kits = 4
	game.loot.barricade_kits = 2
	game.loot.activate_safety(game.building.rooms[5])
	var room: RoomDiorama = game.building.rooms[6]
	room.max_hp = 140.0
	room.hp = 83.0
	room.reinforce(RoomDiorama.Reinforcement.STEEL)
	room.reinforce(RoomDiorama.Reinforcement.ANCHOR)
	room.set_bullet_armor(true)
	room.shutter_block = .65
	room.flood_barrier_bonus = .12
	room.chain_support = true
	var prop: BuildingProp = game.building.props[-1]
	prop.secured = false
	prop.set_toppled(true, -1, true)
	game.tutorial.repairs_done = 2
	w.start_next_wave()
	var saved: PhaseCheckpoint = game.phase_checkpoint
	_check(saved != null and saved.completed_waves == section and saved.mode == DisasterWaveManager.CAMPAIGN[section] and saved.selected.size() == 3 and not saved.pending, "Boss entry snapshots world and selected cards for section %d" % (section + 1))
	w.advance_wave(w.intro_duration())
	# Mutate the live attempt, including nested arrays, inventories and task flags.
	room.hp = 12.0
	room.max_hp = 200.0
	room.reinforcements.clear()
	room.bullet_armor = false
	game.loot.column_kits = 0
	game.loot.barricade_kits = 0
	game.loot.safety_installs = 0
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.ORBITALS)
	game.mechanics.freeze_remaining = 1.0
	game.mechanics.bag_used = true
	game.preparedness.gas_off = false
	game.preparedness.power_off = false
	game.preparedness.bag_ready = false
	for task: Dictionary in game.preparedness.tasks: task["done"] = false
	prop.set_toppled(false, 1, true)
	game.tutorial.repairs_done = 9
	game.loot.spawn(LootSystem.Kind.COLUMN_KIT, 0)
	var hazard: HazardAttack = w._attack(HazardAttack.Kind.GLASS, 0, game.player.global_position, Vector2(100, 0))
	game.telegraphs.warn(hazard, .55)
	if collapse:
		for index: int in range(4): game.building.rooms[index].hp = 0.0
		w.collapse_building()
	else:
		game.player.take_damage(10000.0)
	_check(w.failed and w.fail_reason == (DisasterWaveManager.FailReason.BUILDING if collapse else DisasterWaveManager.FailReason.PLAYER), "Real %s triggers defeat in section %d" % ["collapse" if collapse else "player death", section + 1])
	if section == 1 and collapse:
		await _rendered()
		_check(game.hud.drawn_texts[-1] == "R  Bölümü tekrar dene", "Defeat offers a section retry and retains the karne")
		await _save("defeat.png")
	game.sound.advance(1.0)
	var confirms: int = game.sound.plays("ui_confirm")
	_key(KEY_R)
	_check(not w.failed and not w.victory and w.fail_reason == DisasterWaveManager.FailReason.NONE and not game.building.collapsed_building and game.building.collapse_time == 0.0, "Retry clears failure and the building collapse animation")
	_check(w.completed_waves == section and w.mode == saved.mode and w._next_mode == saved.mode and w.boss_name() == ["DEPREM", "FIRTINA", "SEL", "AFET"][section], "Retry keeps campaign progress and names the same boss")
	_check(w.state == (DisasterWaveManager.State.PREPARATION_PHASE if section == 0 else DisasterWaveManager.State.BUILD_PREPARATION_PHASE) and w.preparation_remaining == (w.preparation_duration if section == 0 else w.build_duration) and not w.prep_hold, "Retry grants the proper full preparation clock")
	_check(game.player.health == game.player.max_health and game.player.stamina == 100.0 and not game.player.controls_locked and game.player.collision_mask == 1, "Retry restores a healthy, playable character")
	_check(game.upgrades.selected == saved.selected and game.upgrades.offers == saved.offers and not game.upgrades.pending and not game.upgrade_overlay.visible, "Owned cards survive without offering new cards")
	_check(game.loot.column_kits == 4 and game.loot.barricade_kits == 2 and game.loot.safety_installs == saved.kits[2] and game.loot.items.is_empty(), "Checkpoint inventories survive; ground loot does not")
	var restored: PhaseCheckpoint = PhaseCheckpoint.capture(game)
	_check(restored.rooms == saved.rooms and room.hp == 83.0 and room.max_hp == 140.0 and room.reinforcements.size() == 2, "All room HP, reinforcement arrays, armor and safety fields restore exactly")
	_check(restored.props == saved.props and prop.toppled and prop.topple_direction == -1, "Furniture security, topple state and direction restore exactly")
	_check(restored.tasks_done == saved.tasks_done and restored.gas_off == saved.gas_off and restored.power_off == saved.power_off and restored.bag_ready == saved.bag_ready and game.tutorial.repairs_done == 2, "Tasks, gas, mains, emergency bag and tutorial repairs restore")
	_check(game.projectiles.active_count() == 0 and game.telegraphs.pending.is_empty() and not game.tremor.busy() and game.game_camera.shake_strength() == 0.0, "Retry clears projectiles, warnings, tremor and camera shake")
	_check(game.mechanics.freeze_remaining == 0.0 and not game.mechanics.bag_used and game.mechanics.drone_clock == 6.5 and Engine.time_scale == 1.0, "Temporary card mechanics reset while ownership survives")
	_check(game.sound.plays("ui_confirm") == confirms + 1, "Retry plays the UI confirmation")
	# New preparation work must be included in the next entry snapshot.
	game.loot.column_kits += 1
	_key(KEY_F)
	_check(w.state == DisasterWaveManager.State.WAVE_INTRO and w.mode == saved.mode and game.phase_checkpoint != saved and game.phase_checkpoint.kits[0] == 5, "F starts that same boss and refreshes its entry checkpoint")
	game.loot.column_kits = 0
	w.fail_siege()
	_key(KEY_R)
	_check(game.loot.column_kits == 5 and w.completed_waves == section, "A second retry uses the latest preparation, with no inventory duplication")
	w.advance_wave(w.preparation_remaining)
	_check(w.state == DisasterWaveManager.State.WAVE_INTRO and w.mode == saved.mode, "Preparation timeout also restarts the same boss")

func _tutorial() -> void:
	game.tutorial.enabled = true
	game.reset_game()
	_check(game.tutorial.step == TutorialGuide.Step.MOVE and game.waves.prep_hold, "New tutorial run still starts with movement teaching")
	game.waves.start_next_wave()
	game.waves.fail_siege()
	_key(KEY_R)
	_check(game.tutorial.step == TutorialGuide.Step.PREPARE and not game.waves.prep_hold and not game.tutorial.blocks_tasks(), "First-phase retry skips A D/W and releases preparedness tasks")
	game.tutorial.enabled = false

func _shortcuts() -> void:
	for index: int in range(4):
		_key(KEY_1 + index)
		_check(game.waves.mode == DisasterWaveManager.CAMPAIGN[index] and game.waves.wave_number == index + 1 and game.waves.completed_waves == index and game.upgrades.selected.is_empty(), "Physical 1-4 shortcut %d starts a fresh campaign section" % (index + 1))
	game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.upgrades.open_selection()
	var offered: int = game.upgrades.offers[1]
	_key(KEY_2)
	_check(game.upgrades.has_upgrade(offered) and not game.upgrades.pending and game.waves.mode == DisasterWaveManager.Mode.CATACLYSM, "Card-modal key 2 selects a card without starting section 2")

func _hud() -> void:
	game.reset_game()
	game.loot.column_kits = 2
	game.tutorial.advance(0.0)
	await _rendered()
	for label: String in GameHUD.SECTION_LABELS:
		var index: int = game.hud.drawn_texts.find(label)
		_check(index >= 0 and PixelFont.supports(label), "Preparation shows section label " + label)
		if index < 0: continue
		var rect: Rect2 = game.hud.drawn_rects[index]
		_check(rect.position.y > 900 and rect.end.y < GameHUD.BOSS_BAR.position.y - 24 and rect.position.x > game.hud.slot_rect(2).end.x and rect.end.x < 1920, "Section label fits above boss name and beside equipment")
		for other: int in range(game.hud.drawn_rects.size()):
			if other != index: _check(not rect.intersects(game.hud.drawn_rects[other]), "Section text does not overlap other HUD text")
	await _save("preparation.png")
	game.waves.start_next_wave()
	game.waves.advance_wave(game.waves.intro_duration())
	await _rendered()
	_check(not game.hud.drawn_texts.has("1 Deprem"), "Section shortcut row is hidden during combat")
	game.select_section(3)
	_check(game.waves.boss_name() == "AFET", "Final boss uses the exact name AFET")
	game.reset_game()
	game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.upgrades.open_selection()
	await _rendered()
	_check(not game.hud.drawn_texts.has("1 Deprem"), "Section row stays hidden behind a card modal")

func _new_games() -> void:
	game.select_section(2)
	_key(KEY_R)
	_check(_is_new_game(), "R outside defeat fully resets the campaign and clears the checkpoint")
	game.select_section(3)
	game.waves.fail_siege()
	game.pause_menu.set_open(true)
	_click(game.pause_menu.buttons["restart"])
	_check(not paused and _is_new_game(), "Pause Restart fully resets even from defeat")
	game.select_section(3)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.finish_wave()
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	_check(game.waves.victory, "Final survival reaches victory")
	_key(KEY_R)
	_check(_is_new_game(), "Victory R starts a new campaign instead of retrying the final")

func _is_new_game() -> bool:
	return game.phase_checkpoint == null and game.waves.completed_waves == 0 and game.waves.wave_number == 0 and not game.waves.failed and not game.waves.victory and game.upgrades.selected.is_empty() and game.loot.materials() == 0 and game.preparedness.count(Preparedness.Task.SECURE) == 0

func _key(code: int) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	root.push_input(event, true)

func _click(control: Control) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = root.get_final_transform() * control.get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, false)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	root.push_input(event, false)

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	if captures == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(captures)
	await _rendered()
	var frame: Image = root.get_texture().get_image()
	_check(frame.get_size() == Vector2i(1920, 1080) and frame.save_png(captures.path_join(name)) == OK, "Native 1920x1080 capture " + name)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)
