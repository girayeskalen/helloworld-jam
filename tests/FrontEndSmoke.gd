extends SceneTree
## Exercises the actual launch scene and native GUI events, including real exit.
var game: MainGame
var checks: int = 0
var failures: int = 0
var captures: String = ""
var preferences: String

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	preferences = "user://frontend-test-%d.cfg" % Time.get_ticks_usec()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): captures = arg.trim_prefix("--capture=")
	if DisplayServer.get_name() != "headless":
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		root.content_scale_size = Vector2i(1920,1080)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920,1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	await _load_game()
	var menu: SiegeFrontEnd = game.front_end
	_check(menu != null and menu.active and menu.screen.visible,"Project entry opens the main menu")
	_check(game.hitstop_enabled, "Normal front-end entry enables the short nonlethal hitstop")
	var point: Vector2 = game.player.global_position
	await _frames(45)
	_check(game.waves.preparation_remaining == game.waves.preparation_duration and game.player.global_position == point and game.projectiles.spawn_count == 0,"Menu freezes countdown, player and hazards while weather runs")
	_check(game.tutorial.enabled and game.waves.prep_hold,"The normal launch has the tutorial on by default")
	_check(menu.clock > 0 and game.sound.bgm_player.playing,"Menu animation and the existing score continue")
	_check(not game.hud.visible and not game.labels.visible,"Gameplay HUD and repair labels stay behind the menu")
	for key: Key in [KEY_F,KEY_R]: _key(key)
	await _frames(3)
	_check(menu.active and game.waves.wave_number == 0 and game.player.global_position == point,"F and R cannot leak through the menu (1-4 deliberately select sections)")
	await _save("main-menu.png")
	_key(KEY_DOWN)
	await _frames(2)
	_check((menu.buttons["settings"] as Button).has_focus(),"Arrow down moves keyboard focus to settings")
	_key(KEY_ENTER)
	await _frames(2)
	_check(menu.settings_open and menu.options.visible and not paused,"Enter opens settings without opening game pause")
	_key(KEY_M)
	_check(game.sound.muted and AudioServer.is_bus_mute(0),"M toggles the real Master mute from settings")
	var before: int = game.sound.volume_level
	_key(KEY_MINUS,45)
	_check(game.sound.volume_level == before-1,"Minus changes actual audio volume")
	menu.volume.grab_focus()
	_key(KEY_RIGHT)
	_check(game.sound.volume_level == before and int(menu.volume.value) == before,"Slider keyboard input updates the mixer and displayed value")
	_click(menu.buttons["mute"])
	_check(not game.sound.muted,"Mouse operates the sound toggle")
	if DisplayServer.get_name() != "headless":
		var was_full: bool = menu._fullscreen()
		_click(menu.buttons["fullscreen"])
		await _frames(6)
		_check(menu._fullscreen() != was_full,"Fullscreen button changes the real native window")
		_click(menu.buttons["fullscreen"])
		await _frames(6)
	_click(menu.buttons["tutorial"])
	var off: ConfigFile = ConfigFile.new()
	_check(not game.tutorial.enabled and (menu.buttons["tutorial"] as Button).text == "Öğretici kapalı" and off.load(preferences) == OK and not off.get_value("game","tutorial"),"Tutorial toggle switches it off and saves the choice")
	_click(menu.buttons["tutorial"])
	_check(game.tutorial.enabled and (menu.buttons["tutorial"] as Button).text == "Öğretici açık","...and back on")
	await _save("settings.png")
	var config: ConfigFile = ConfigFile.new()
	_check(config.load(preferences) == OK and config.get_value("audio","volume") == before and not config.get_value("audio","muted"),"Settings are written to an isolated real config file")
	_key(KEY_ESCAPE)
	_check(not menu.settings_open and menu.active and not game.pause_menu.is_open,"Escape returns to the menu without pausing gameplay")
	game.queue_free()
	await _frames(3)
	await _load_game()
	menu = game.front_end
	_check(game.sound.volume_level == before and not game.sound.muted and game.tutorial.enabled,"Fresh entry restores saved audio and tutorial preferences")
	_key(KEY_ENTER)
	await _frames(20)
	_check(not menu.active and not menu.screen.visible and game.player.is_physics_processing(),"Enter starts a playable run after the short visual fade")
	_check(game.waves.prep_hold and game.waves.preparation_remaining == game.waves.preparation_duration and game.tutorial.hint_keys == PackedStringArray(["A","D"]),"The run opens with the tutorial: A D shown, the Hazırlık clock waits")
	_check(game.hud.visible and game.labels.visible and game.game_camera.cinematic_offset == Vector2.ZERO,"Start restores gameplay HUD and camera framing")
	game.waves.autoplay = false
	game.player.global_position.x += 240.0
	await _frames(2)
	game.player.jumped.emit(false)
	_check(not game.waves.prep_hold and is_equal_approx(game.waves.preparation_remaining, TutorialGuide.TASK_TIME) and game.preparedness.available(),"After running and jumping the tasks light up with a 30 s clock")
	game.waves.advance_wave(TutorialGuide.TASK_TIME - 0.01)
	_check(game.waves.state == DisasterWaveManager.State.PREPARATION_PHASE,"The earthquake does not arrive before the clock runs out")
	game.waves.advance_wave(.02)
	_check(game.waves.state == DisasterWaveManager.State.WAVE_INTRO and game.waves.mode == DisasterWaveManager.Mode.EARTHQUAKE and game.player.controls_locked,"The clock leads into the retained earthquake cinematic")
	game.waves.advance_wave(game.waves.intro_duration())
	_check(game.waves.state == DisasterWaveManager.State.SIEGE_PHASE and not game.player.controls_locked,"Boss cinematic still releases controls for the fight")
	await _save("battle.png")
	game.waves.advance_wave(game.waves.siege_duration)
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	await _frames(28)
	_check(game.upgrades.pending and game.waves.completed_waves == 1,"Real boss outro opens the themed supply dossiers")
	game.waves.advance_wave(8)
	_check(game.waves.preparation_remaining == game.waves.build_duration,"Card choice never consumes the 15-second Hazırlık window")
	await _save("stage-supply.png")
	var chosen: int = game.upgrades.offers[1]
	_click(game.upgrade_overlay.cards[1])
	_check(game.upgrades.has_upgrade(chosen) and not game.upgrades.pending,"Clicking the new dossier equips its actual gameplay module")
	_key(KEY_ESCAPE)
	_check(paused and game.pause_menu.is_open,"Normal ESC pause remains available during play")
	_click(game.pause_menu.buttons["home"])
	await _frames(3)
	_check(menu.active and not paused and game.waves.preparation_remaining == game.waves.preparation_duration and game.projectiles.active_count() == 0,"Pause menu returns to a clean main menu")
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		root.unresizable = true
		root.size = Vector2i(1280,720)
		await _frames(10)
		_click(menu.buttons["settings"])
		_check(menu.settings_open,"Scaled 1280x720 mouse still opens the intended menu action")
		_key(KEY_ESCAPE)
	game.waves.autoplay = true
	menu.exit_requested.connect(func() -> void:
		_check(true,"Exit button reaches the application quit action")
		DirAccess.remove_absolute(preferences)
		print("FRONTEND_RESULT checks=%d failures=%d" % [checks,failures])
	)
	_click(menu.buttons["exit"])
	if failures > 0: quit(1)

func _load_game() -> void:
	game = (load(ProjectSettings.get_setting("application/run/main_scene")) as PackedScene).instantiate() as MainGame
	game.menu_settings_path = preferences
	root.add_child(game)
	await _frames(4)

func _save(filename: String) -> void:
	if captures == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(captures)
	await _frames(6)
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920,1080) and picture.save_png(captures.path_join(filename)) == OK,"Native capture "+filename)

func _key(key: Key, unicode_value: int = 0) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.unicode = unicode_value
	event.pressed = true
	root.push_input(event,true)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	root.push_input(event,true)

func _click(control: Control) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = root.get_final_transform()*control.get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event,false)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	root.push_input(event,false)

func _frames(count: int) -> void:
	for i: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS "+message)
	else:
		failures += 1
		push_error("FAIL "+message)
