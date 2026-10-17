extends SceneTree
## Startup-only fallback, real OGV decode/EOF, skip/fade/pause and direct bosses.
var game: MainGame
var checks: int = 0
var failures: int = 0
var completions: int = 0
var capture_dir: String = ""

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	game.intro.set_process(false)
	game.intro.finished.connect(func() -> void: completions += 1)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture_dir = arg.trim_prefix("--capture=")
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
		if not capture_dir.is_empty():
			DirAccess.make_dir_recursive_absolute(capture_dir)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			root.size = Vector2i(1920,1080)
	await _frames(4)
	game.sound.bake_all_now()
	_check(game.intro_enabled and game.intro.active() and game.waves.intro_active,"Normal launch enters only the startup intro")
	await _fallback()
	await _inputs()
	await _campaign()
	await _video()
	print("VIDEO_INTRO_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await process_frame
	await process_frame
	OS.delay_msec(100)
	quit(0 if failures == 0 else 1)

func _start(path: String = "user://missing-intro.ogv") -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.waves.intro_active = true
	game.world_container.process_mode = Node.PROCESS_MODE_DISABLED
	game.player.controls_locked = true
	game.intro.video_path = path
	game.intro.begin(game.sound)
	game.intro.set_process(false)

func _fallback() -> void:
	_start()
	var intro: IntroOverlay = game.intro
	_check(intro.state == IntroOverlay.State.CARD and not intro.video.visible and intro.video.stream == null,"Missing video shows only a clean text card")
	_check(intro.title.text == IntroOverlay.CREDIT,"Credit matches the exact requested university, department and name")
	var font: Font = intro.title.get_theme_font("font")
	var glyphs: bool = true
	for letter: String in ["Ö","Ğ","Ü","İ","Ş","Ç","•"]: glyphs = glyphs and font.has_char(letter.unicode_at(0))
	_check(glyphs and font is FontFile,"Real pixel font contains Turkish credit glyphs")
	_check(game.world_container.process_mode == Node.PROCESS_MODE_DISABLED and game.player.controls_locked and not paused,"Only the game world is disabled during startup")
	game.waves.advance_wave(100)
	_check(game.waves.preparation_remaining == 8 and game.waves.wave_number == 0,"Intro cannot consume preparation or launch a wave")
	intro.advance(.8)
	await _save("01-credit.png")
	intro.advance(2.0)
	_check(intro.state == IntroOverlay.State.BULLETIN and intro.title.text == "AFETE HAZIR OL.","Card flows into a calm, date-free bulletin")
	intro.advance(.8)
	await _save("02-bulletin.png")
	intro.advance(1.8)
	_check(intro.state == IntroOverlay.State.FADING and game.waves.intro_active,"Bulletin starts the same guarded fade")
	intro.advance(.225)
	_check(is_equal_approx(intro.surface.modulate.a,.5) and intro.visible,"Fade gradually reveals the apartment")
	await _save("03-fade.png")
	var count: int = completions
	intro.advance(.225)
	_check(not intro.active() and not intro.visible and completions == count+1,"Intro completes exactly once")
	_check(not game.waves.intro_active and not game.player.controls_locked and game.world_container.process_mode == Node.PROCESS_MODE_INHERIT,"World and controls resume without snapshot controllers")
	_check(game.waves.preparation_remaining == 8 and game.waves.mode == DisasterWaveManager.Mode.STORM and game.sound.bgm_player.volume_db == -5,"Full storm preparation and original BGM level are restored")
	intro.skip()
	intro.advance(100)
	_check(completions == count+1,"Repeated skips cannot finish or restart twice")
	await _save("04-preparation.png")

func _inputs() -> void:
	for key: Key in [KEY_SPACE,KEY_ENTER,KEY_KP_ENTER]:
		_start()
		_key(KEY_F)
		_key(KEY_4)
		_check(game.waves.wave_number == 0,"Gameplay shortcuts are blocked behind the intro")
		_key(key)
		_check(game.intro.state == IntroOverlay.State.FADING,"Real skip key %d starts fade" % key)
		game.intro.advance(.45)
		_check(not game.player.controls_locked and game.player.dash_remaining == 0 and not Input.is_action_pressed("dash"),"Skip does not leak Space into a dash")
	_start()
	game.intro.set_process(true)
	_key(KEY_ESCAPE)
	var time: float = game.intro.elapsed
	await _frames(4)
	_check(paused and game.intro.elapsed == time and game.intro.video.paused,"ESC pauses overlay and decoder")
	_key(KEY_M)
	_check(game.sound.muted,"M still works during paused intro")
	_key(KEY_M)
	_key(KEY_ESCAPE)
	await _rendered()
	_check(not paused and game.intro.elapsed > time and not game.intro.video.paused,"Continue resumes the same intro")
	game.intro.set_process(false)
	_key(KEY_R)
	_check(not game.intro.active() and not game.waves.intro_active and game.waves.wave_number == 0,"R restarts directly without replaying intro")
	_check(not InputMap.has_action("story_replay") and not InputMap.has_action("victory_preview") and not InputMap.has_action("defeat_preview"),"I/V/K cinematic actions are removed")
	for suffix: String in ["ogv","webm"]:
		var path: String = "user://invalid-intro."+suffix
		var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
		file.store_string("invalid video fixture")
		file.close()
		_start(path)
		_check(game.intro.state == IntroOverlay.State.CARD and not game.intro.fallback_reason.is_empty(),"Unsupported or invalid %s falls back without a load error" % suffix)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.reset_game()

func _campaign() -> void:
	_check(DisasterWaveManager.State.size() == 4,"Only preparation, siege, construction and victory remain")
	_check(game.find_child("CutsceneDirector",true,false) == null and game.find_child("BossCinematic",true,false) == null,"No legacy cinematic controllers remain")
	for mode: int in range(4):
		game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
		var boss: DisasterBoss = game.waves.bosses()[mode]
		_check(game.waves.state == DisasterWaveManager.State.SIEGE_PHASE and boss.visible and not game.player.controls_locked and game.waves.siege_remaining == 50,"Boss %d starts combat immediately" % mode)
		_check(boss.position == boss._home and boss.scale == Vector2.ONE and boss.is_processing(),"Original boss %d rig and animation remain active" % mode)
		_check(game.game_camera.zoom == Vector2.ONE*game.base_zoom/game.pixel_scale,"Boss leaves normal camera framing intact")
		await _save("06-boss-%d-direct.png" % mode)
		game.waves.finish_wave()
		_check(not boss.visible and (game.waves.victory if mode == 3 else game.upgrades.pending),"Wave %d proceeds immediately to cards or victory" % mode)
	game.reset_game()
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE,true)
	game.player.health = 0
	game.waves.advance_wave(.01)
	_check(game.waves.failed and not game.intro.active(),"Player death uses existing result HUD")
	game.reset_game()
	game.waves.collapse_building()
	_check(game.waves.failed and game.building.collapsed_building and not game.intro.active(),"Structural failure still works without cinematic drawing")
	game.reset_game()

func _video() -> void:
	var fixture: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--fixture="): fixture = arg.trim_prefix("--fixture=")
	if fixture.is_empty():
		print("VIDEO_DECODE_SKIPPED no --fixture supplied")
		return
	_check(DirAccess.copy_absolute(fixture,ProjectSettings.globalize_path("user://intro-test.ogv")) == OK,"Generated test video stays outside the project")
	_start("user://intro-test.ogv")
	_check(game.intro.state == IntroOverlay.State.VIDEO and game.intro.video.is_playing() and game.intro.used_video_path == "user://intro-test.ogv","Actual OGV selects and starts VideoStreamPlayer")
	_check(game.sound.bgm_player.playing and game.sound.bgm_player.volume_db == -80,"Existing BGM stays alive while video audio has priority")
	await _rendered()
	var texture: Texture2D = game.intro.video.get_video_texture()
	var texture_deadline: int = Time.get_ticks_msec()+1500
	while (texture == null or texture.get_width() == 0) and Time.get_ticks_msec() < texture_deadline and game.intro.state == IntroOverlay.State.VIDEO:
		await process_frame
		texture = game.intro.video.get_video_texture()
	print("VIDEO_TEXTURE size=%s position=%.3f" % [texture.get_size() if texture != null else Vector2.ZERO,game.intro.video.stream_position])
	# 4.3 exposes Theora's 16-pixel padded height (368); 4.7 reports crop height 360.
	_check(texture != null and texture.get_width() == 640 and texture.get_height() in [360,368],"Theora decodes real 640-wide frames with valid crop/padded height")
	await _save("05-real-video.png")
	_key(KEY_ESCAPE)
	var position: float = game.intro.video.stream_position
	await _frames(8)
	_check(game.intro.video.paused and is_equal_approx(game.intro.video.stream_position,position),"Pause freezes actual video position")
	_key(KEY_ESCAPE)
	var deadline: int = Time.get_ticks_msec()+6000
	while game.intro.state == IntroOverlay.State.VIDEO and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(game.intro.state == IntroOverlay.State.FADING and game.waves.intro_active,"Real EOF signal starts fade before gameplay resumes")
	game.intro.advance(.45)
	_check(not game.intro.active() and game.intro.video.stream == null and game.waves.preparation_remaining == 8,"Video end releases decoder and restores full preparation")
	_start("user://intro-test.ogv")
	_key(KEY_ENTER)
	game.intro.advance(.45)
	_check(not game.intro.active() and not game.intro.video.is_playing(),"Enter skips a real playing video")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://intro-test.ogv"))
	game.reset_game()

func _key(code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event,true)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	root.push_input(event,true)

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	await _rendered()
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920,1080) and picture.save_png(capture_dir.path_join(name)) == OK,"Native screenshot "+name)
	_check(game.intro.title.get_line_count() <= 4 and game.intro.title.get_minimum_size().y <= game.intro.title.size.y,"Pixel title fits its on-screen block")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if ok: print("PASS "+label)
	else:
		failures += 1
		push_error("FAIL "+label)
