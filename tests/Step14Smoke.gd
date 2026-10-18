extends SceneTree
## Jam regression: recovery, lethal callbacks and unobtrusive guidance in every phase.
var game: MainGame
var checks: int = 0
var failures: int = 0
var captures: String = ""

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): captures = arg.trim_prefix("--capture=")
	if captures != "" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920,1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	game = load("res://scenes/MainGame.tscn").instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	for i: int in range(8): await physics_frame
	for node: Node in [game.player,game.loot,game.mechanics,game.preparedness,game.tutorial,game.projectiles,game.telegraphs]: node.set_physics_process(false)
	for node: Node in [game.hud,game.labels,game.feel_fx,game.upgrade_overlay,game.sound]: node.set_process(false)
	game.sound.bake_all_now()
	_recovery()
	_lethal()
	await _preparation()
	await _combat()
	await _window_capture()
	print("STEP14_RESULT checks=%d failures=%d" % [checks,failures])
	paused = false
	game.queue_free()
	await process_frame
	await process_frame
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func _battle(mode: int = DisasterWaveManager.Mode.EARTHQUAKE) -> void:
	game.tutorial.enabled = false
	game.reset_game()
	game.waves.start_siege(mode as DisasterWaveManager.Mode, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false
	game.tremor.next_left = 999.0
	game.telegraphs.clear()
	game.projectiles.clear()

func _place(floor_id: int, x: float) -> void:
	game.player.current_floor = floor_id
	game.player.global_position = Vector2(x,game.building.floor_y(floor_id)-1)
	game.player.velocity = Vector2.ZERO

func _tick(time: float) -> void:
	game.sound.advance(time)
	game.tutorial.advance(time)
	game.hud.advance_feel(time)

func _recovery() -> void:
	_battle()
	var room: RoomDiorama = game.building.rooms[0]
	room.apply_damage(45)
	room.reinforce(RoomDiorama.Reinforcement.SHUTTER)
	game.preparedness.complete(game.preparedness.tasks[0])
	game.loot.column_kits = 3
	game.loot.barricade_kits = 2
	game.player.health = 20
	game.player.stamina = 11
	game.player.hit_invulnerability = .7
	game.hud.on_damage()
	game.sound.advance(1)
	var heals: int = game.sound.plays("heal")
	var glows: int = game.hud.heal_glow_count
	var hp: float = room.hp
	game.waves.finish_wave()
	_check(game.player.health == 20, "Recovery waits until the outro completes")
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	_check(game.upgrades.pending and game.player.health == game.player.max_health and game.player.stamina == 100, "Card screen opens with full health and stamina")
	_check(game.player.hit_invulnerability == 0 and game.hud.hit_flash == 0 and game.hud.vignette_alpha == 0, "Hit protection/red edges are cleared")
	_check(game.sound.plays("heal") == heals+1 and game.hud.heal_glow_count == glows+1, "Exactly one heal sound and glow at intermission")
	game.hud.advance_feel(.1)
	_check(game.hud.heal_glow_count == glows+1, "Health observer does not duplicate intermission glow")
	_check(room.hp == hp and room.has_reinforcement(RoomDiorama.Reinforcement.SHUTTER), "Room damage and reinforcement persist")
	_check(game.loot.column_kits == 3 and game.loot.barricade_kits == 2 and game.preparedness.tasks[0]["done"], "Inventory and completed tasks persist")
	game.upgrades.choose(0)
	game.waves.start_next_wave()
	_check(game.player.health == game.player.max_health, "Next fight/checkpoint starts at full health")
	_battle(DisasterWaveManager.Mode.CATACLYSM)
	game.player.health = 20
	game.player.stamina = 11
	heals = game.sound.plays("heal")
	game.waves.finish_wave()
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	_check(game.waves.victory and game.player.health == 20 and game.player.stamina == 11 and game.sound.plays("heal") == heals, "Victory retains its existing behavior")

func _lethal() -> void:
	_battle(DisasterWaveManager.Mode.FLOOD)
	game.player.health = 1
	var attack: HazardAttack = game.waves._attack(HazardAttack.Kind.FLOOD_ZONE,0,game.player.global_position,Vector2.ZERO)
	attack.area = Rect2(game.player.global_position-Vector2(60,60),Vector2(120,120))
	attack.damage = 20
	attack.source = 2
	attack.warning_duration = 1
	attack.warning_elapsed = 2
	attack.warning_confirmed = true
	attack.warning_id = 1
	var projectile: HazardProjectile = game.projectiles.spawn(attack)
	_check(projectile != null, "Lethal water fixture uses an armed real projectile")
	var before: int = game.preparedness.phase_stats["water_hits"]
	game.projectiles._physics_process(.016)
	_check(game.waves.failed and game.player.health == 0 and projectile.attack == null, "Lethal callback clears the live projectile synchronously")
	_check(game.preparedness.phase_stats["water_hits"] == before+1, "Saved attack increments water_hits exactly once after death")
	game.preparedness.record_hit(null)
	_check(game.preparedness.phase_stats["water_hits"] == before+1, "Null bookkeeping is harmless")

func _preparation() -> void:
	game.reset_game()
	game.waves.completed_waves = 1
	game.waves._next_mode = DisasterWaveManager.Mode.STORM
	game.waves.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.waves.set_preparation(10)
	game.tutorial.enabled = false
	# Keep one real target so cardinal directions cannot switch to a nearer task.
	for task: Dictionary in game.preparedness.tasks: task["done"] = true
	var target: Dictionary = {}
	for task: Dictionary in game.preparedness.tasks:
		if int(task["kind"]) == Preparedness.Task.SECURE and game.preparedness.task_floor(task) == 1: target = task
	target["done"] = false
	var floor_id: int = game.preparedness.task_floor(target)
	var x: float = game.preparedness.anchor_x(target)
	_place(floor_id,x-170)
	_tick(.01)
	var entries: int = game.tutorial.entry_count
	_check(entries > 0 and game.tutorial.entry_left == .8, "Preparation begins with one objective entry")
	_check(game.tutorial.guide_dir == Vector2i.RIGHT and game.tutorial.guide_color == Preparedness.COLORS[int(target["kind"])], "Second phase tutorial-off guidance points right in the task color")
	_place(floor_id,x+170)
	_tick(.01)
	_check(game.tutorial.guide_dir == Vector2i.LEFT, "Same floor target to the left")
	_place(floor_id-1,x)
	_tick(.01)
	_check(game.tutorial.guide_dir == Vector2i.UP and game.tutorial.hint_keys.is_empty(), "Other floor uses upward glyph without tutorial keys")
	_place(floor_id+1,x)
	_tick(.01)
	_check(game.tutorial.guide_dir == Vector2i.DOWN, "Lower target uses downward glyph")
	_place(floor_id,x)
	_tick(.01)
	_check(game.tutorial.guide_dir == Vector2i.ZERO, "Target within reach hides direction")
	_place(floor_id-1,x)
	_tick(.3)
	await _rendered()
	_check(game.labels.arrows_drawn == 1 and game.labels.keys_drawn.is_empty(), "Only one direction beside character outside tutorial")
	_check(game.hud.objective_font_size == UIStyle.MEDIUM and game.hud.objective_band.position.x >= 280 and game.hud.objective_band.end.x < 1800 and game.hud.objective_band.position.y >= 24 and game.hud.objective_band.end.y <= 96, "Medium objective stays inside top band and clear of HUD")
	var second: Dictionary = game.preparedness.tasks.back()
	second["done"] = false
	await _rendered()
	_check(game.labels.target_marker_size > game.labels.task_sizes.min(), "Target task marker is larger than secondary markers")
	await _save("phase2-preparation.png")
	var sounds: int = game.sound.plays("ui_hover")
	_place(game.preparedness.task_floor(second), game.preparedness.anchor_x(second))
	_tick(.2)
	_check(game.tutorial.entry_count == entries and game.sound.plays("ui_hover") == sounds, "Walking between nearest tasks does not replay entry or click")
	_tick(1.5)
	game.preparedness.complete(second)
	_tick(.01)
	_check(game.tutorial.entry_count == entries+1 and game.hud.objective_pulse > 0, "Task completion retains tick/pop and triggers one entry")
	_check(game.sound.history.back()["volume_db"] <= -10, "Entry click stays quiet")
	_place(floor_id-1,x)
	_tick(5.9)
	_check(game.tutorial.reminder_count == 0, "No reminder before six idle seconds")
	_tick(.11)
	_check(game.tutorial.reminder_count == 1 and game.tutorial.reminder_left == .5, "Six idle seconds cause one silent reminder")
	sounds = game.sound.plays("ui_hover")
	_tick(5)
	_tick(5)
	_tick(10)
	_check(game.tutorial.reminder_count == 3 and game.sound.plays("ui_hover") == sounds, "Reminders stop at three and stay silent")
	game.tutorial.objective_text = "Hazırlık 5/10 · Gardırobu sabitle: devrilmesin ve yolu kapatmasın, sarsıntıda eşya düşmesin"
	await _rendered()
	_check(game.hud.objective_font_size == UIStyle.SMALL and game.hud.objective_band.position.x >= 280, "Long objective falls back to small without HUD overlap")
	game.tutorial.enabled = true
	game.waves.completed_waves = 0
	game.waves.state = DisasterWaveManager.State.PREPARATION_PHASE
	game.tutorial.step = TutorialGuide.Step.PREPARE
	_tick(.01)
	await _rendered()
	_check(game.tutorial.hint_keys.size() > 0 and game.labels.arrows_drawn == 0, "Tutorial vertical key caps take precedence over the chevron")
	game.tutorial.reset()
	_tick(.01)
	entries = game.tutorial.entry_count
	game.tutorial.moved = TutorialGuide.MOVE_DISTANCE
	_tick(.01)
	_tick(.01)
	_check(game.tutorial.entry_count == entries+1 and game.tutorial.objective_text == "Zıpla: W", "Movement-to-jump tutorial step enters once when its text becomes visible")

func _combat() -> void:
	for mode: int in [DisasterWaveManager.Mode.EARTHQUAKE,DisasterWaveManager.Mode.STORM]:
		_battle(mode)
		var room: RoomDiorama = game.building.rooms[9]
		room.apply_damage(50)
		game.loot.column_kits = 1
		_place(0,game.building.rooms[0].global_position.x+200)
		_tick(.01)
		_tick(.01)
		await _rendered()
		_check(game.tutorial.guide_dir == Vector2i.UP and game.labels.arrows_drawn == 1, "All battles point a kit holder toward the lowest-HP room")
		_check(game.labels.repair_brackets == 4 and game.labels.repair_markers == 1 and game.labels.texts_drawn == 0, "Repair brackets and exclamation are glyphs, no new world text")
		_check(game.hud.room_color(room) != UIStyle.ALERT, "Damaged minimap cell pulses")
		# Include real telegraphs to judge contrast against hazard colors.
		game.waves.quake_burst() if mode == DisasterWaveManager.Mode.EARTHQUAKE else game.waves.storm_burst()
		await _save("quake-repair.png" if mode == DisasterWaveManager.Mode.EARTHQUAKE else "storm-repair.png")
		_tick(4.1)
		_check(game.tutorial.objective_text == "" and game.tutorial.guide_dir != Vector2i.ZERO, "Four-second combat line expires while quiet direction persists")
		var entries: int = game.tutorial.entry_count
		game.building.rooms[10].apply_damage(45)
		_tick(.1)
		_check(game.tutorial.entry_count == entries, "New repair line is throttled for fifteen seconds")
		game.loot.column_kits = 0
		game.loot.spawn(LootSystem.Kind.COLUMN_KIT,2)
		_tick(.1)
		_check(game.tutorial.guide_loot == 0 and game.tutorial.guide_dir == Vector2i.RIGHT, "Kitless player follows the real dropped column kit")
		game.tremor.announce(game.waves)
		_tick(.01)
		await _rendered()
		_check(game.labels.arrows_drawn == 0 and game.labels.loot_guides == 0 and game.labels.keys_drawn.has("C"), "Tremor C warning overrides both guide glyphs")
		game.tremor.cancel()
		game.player.dash_remaining = .2
		_tick(.01)
		await _rendered()
		_check(game.labels.arrows_drawn == 0 and game.labels.loot_guides == 0, "Dash hides guidance")
		game.player.dash_remaining = 0
		game.loot.column_kits = 1
		_place(room.floor_index,room.global_position.x+200)
		_tick(.01)
		_check(game.tutorial.guide_dir == Vector2i.ZERO, "Inside a repairable room the direction yields to E")
		for hidden: String in ["pause","cards","intro","outro","failed","victory"]:
			var old_state: int = game.waves.state
			if hidden == "pause":
				game.pause_menu.set_open(true)
				for tick: int in range(3): await process_frame
				_check(game.labels.drawn == 0, "Real pause invalidates cached guidance even when processing stops")
			if hidden == "cards": game.upgrades.pending = true
			if hidden == "intro": game.waves.state = DisasterWaveManager.State.WAVE_INTRO
			if hidden == "outro": game.waves.state = DisasterWaveManager.State.WAVE_OUTRO
			if hidden == "failed": game.waves.failed = true
			if hidden == "victory": game.waves.victory = true
			await _rendered()
			_check(game.labels.drawn == 0 and game.hud.objective_band == Rect2(), "No guidance on " + hidden)
			game.pause_menu.set_open(false)
			paused = false
			game.upgrades.pending = false
			game.waves.failed = false
			game.waves.victory = false
			game.waves.state = old_state as DisasterWaveManager.State

func _rendered() -> void:
	game.hud.queue_redraw()
	game.labels.queue_redraw()
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	game._apply_atmosphere()
	game.game_camera.cinematic_offset = Vector2.ZERO
	game.game_camera.force_update_scroll()
	await _rendered()
	if captures == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(captures)
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920,1080) and picture.save_png(captures.path_join(name)) == OK, "Native capture " + name)

func _window_capture() -> void:
	if captures == "" or DisplayServer.get_name() == "headless": return
	_battle(DisasterWaveManager.Mode.EARTHQUAKE)
	game.building.rooms[9].apply_damage(55)
	game.loot.column_kits = 1
	_place(0,game.building.rooms[0].global_position.x+200)
	_tick(.01)
	_tick(.3)
	game.waves.quake_burst()
	root.min_size = Vector2i(1280,720)
	root.max_size = Vector2i(1280,720)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280,720))
	root.size = Vector2i(1280,720)
	for tick: int in range(12): await process_frame
	await _rendered()
	var picture: Image = root.get_texture().get_image()
	var result: Error = picture.save_png(captures.path_join("window-1280.png"))
	print("WINDOW_CAPTURE size=", picture.get_size())
	_check(picture.get_size() == Vector2i(1280,720) and result == OK, "Actual 1280x720 window capture")
