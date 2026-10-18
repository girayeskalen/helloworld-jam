extends SceneTree
## Four-phase campaign, real continuous music, harmless cinematic framing and
## native bottom-HUD/intro screenshots. Complements the full campaign soak.
var game: MainGame
var checks: int = 0
var failures: int = 0
const NAMES: Array[String] = ["FIRTINA","DEPREM","SEL","AFET"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	_check(game.sound.bgm_player.playing and game.sound.bgm_player.stream is AudioStreamSynchronized and game.sound.streams.is_empty(),"Baked BGM is already playing before the first SFX finishes baking")
	for node: Node in [game.player,game.loot,game.mechanics]: node.set_physics_process(false)
	await _frames(3)
	await _phases()
	await _music()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP55_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _phases() -> void:
	var w: DisasterWaveManager = game.waves
	_check(DisasterWaveManager.Mode.size() == 4 and DisasterBoss.Kind.size() == 4 and w.bosses().size() == 4,"Exactly four campaign modes and four boss anatomies remain")
	_check(game.find_child("FireBoss",true,false) == null and not InputMap.has_action("fire_test") and not InputMap.has_action("chaos_test"),"Old fire boss node and old fire/double shortcut actions are removed")
	for mode: int in range(4):
		game.reset_game()
		w.autoplay = false
		w.start_siege(mode as DisasterWaveManager.Mode,true)
		_check(w.boss_name() == NAMES[mode] and w.wave_number == DisasterWaveManager.CAMPAIGN.find(mode)+1,"Exact boss name/number for phase %d" % (mode+1))
		_check(w.intro_duration() >= 2.2 and w.intro_duration() <= 2.8 and game.player.controls_locked,"Cinematic intro lasts 2.2–2.8s and locks gameplay")
		w.plan_attack(w._attack(HazardAttack.Kind.GLASS,0,Vector2.ZERO,Vector2.RIGHT))
		w.advance_wave(w.intro_duration()*.5)
		game.cinematic._process(0)
		_check(game.cinematic.letterbox > .99 and game.game_camera.cinematic_offset.length() > 1 and game.game_camera.zoom.x > game.base_zoom/game.pixel_scale,"Mid-intro letterbox and gentle camera focus are active")
		_check(game.telegraphs.pending.is_empty() and game.projectiles.active_count() == 0 and w.siege_remaining == w.siege_duration and game.player.health == 100,"Intro cannot launch hazards or spend player HP/fight seconds")
		w.advance_wave(w.transition_remaining)
		game.cinematic._process(0)
		_check(w.state == DisasterWaveManager.State.SIEGE_PHASE and not game.player.controls_locked and game.cinematic.letterbox == 0 and game.game_camera.cinematic_offset == Vector2.ZERO,"Battle starts once, restores input/framing and removes cinema bars")
		await _rendered()
		var title_found: bool = false
		var top_clear: bool = true
		for i: int in range(game.hud.drawn_texts.size()):
			if game.hud.drawn_texts[i] == NAMES[mode]:
				title_found = game.hud.drawn_rects[i].position.y > 950
			if game.hud.drawn_rects[i].position.y < 180 and game.hud.drawn_rects[i].position.x > 500 and game.hud.drawn_rects[i].end.x < 1400: top_clear = false
		_check(title_found and top_clear and is_equal_approx(GameHUD.BOSS_BAR.get_center().x,960),"Plain boss name and centred HP/time bar occupy the bottom; top centre is clear")
		var separated: bool = true
		for i: int in range(3): separated = separated and not game.hud.slot_rect(i).grow(25).intersects(GameHUD.BOSS_BAR.grow(20))
		_check(separated,"All three material slots stay separate from the bottom boss bar")
		var count: int = 4 if mode == 3 else 6
		for pattern: int in range(count):
			game.telegraphs.clear()
			game.projectiles.clear()
			w.bosses()[mode].plan_pattern(w,pattern,1)
			var fire_free: bool = not game.telegraphs.pending.is_empty()
			for a: HazardAttack in game.telegraphs.pending:
				fire_free = fire_free and a.source in [0,1,2] and a.kind not in [HazardAttack.Kind.FIREBALL,HazardAttack.Kind.FIRE_DART,HazardAttack.Kind.FIRE_BEAM,HazardAttack.Kind.METEOR,HazardAttack.Kind.FIRE_ZONE,HazardAttack.Kind.LOW_FLAME]
			_check(fire_free,"Phase %d pattern %d contains no fire source or flame/meteor hazard" % [mode+1,pattern])
		game._apply_atmosphere()
		_check(game.weather.inferno == 0.0,"No fire atmosphere in phase %d" % (mode+1))
		if mode == 3:
			w.nova = true
			game.telegraphs.clear()
			game.titan.plan_pattern(w,0,1)
			var elements: Dictionary = {}
			for a: HazardAttack in game.telegraphs.pending: elements[a.source] = true
			_check(elements.size() == 3 and not elements.has(3) and CataclysmArt.ELEMENTS.size() == 3,"Final nova and fusion art contain exactly storm, quake and flood")
			w.nova = false
	game.reset_game()
	for key: int in range(KEY_1,KEY_4+1):
		await _tap(key)
		_check(w.mode == DisasterWaveManager.CAMPAIGN[key-KEY_1] and w.wave_number == key-KEY_1+1 and w.state == DisasterWaveManager.State.WAVE_INTRO,"Physical shortcut %d selects its campaign section" % (key-KEY_1+1))
	var saved: int = w.mode
	await _tap(KEY_5)
	await _tap(KEY_6)
	_check(w.mode == saved,"Removed keys 5/6 cannot launch extra boss phases")
	game.reset_game()

func _music() -> void:
	var sound: SoundManager = game.sound
	var wav: AudioStreamWAV = sound.score.stems["pad_bass"] as AudioStreamWAV
	_check(wav != null and wav.format == AudioStreamWAV.FORMAT_16_BITS and not wav.stereo and wav.mix_rate == 22050,"Dedicated BGM uses baked 22.05 kHz 16-bit mono PCM")
	_check(wav.loop_mode == AudioStreamWAV.LOOP_FORWARD and wav.loop_begin == 0 and wav.loop_end == wav.data.size()/2,"Music loops by sample frames, never byte length")
	_check(MusicScore.BPM == 120 and MusicScore.BARS == 8 and is_equal_approx(wav.get_length(),16),"Eight 4/4 bars at 120 BPM form an exact 16-second score")
	var samples: PackedFloat32Array = SoundSynth.from_pcm16(wav.data)
	var peak: float = 0
	var energy: float = 0
	var dc: float = 0
	var max_jump: float = 0
	for i: int in range(samples.size()):
		peak = maxf(peak,absf(samples[i]))
		energy += samples[i]*samples[i]
		dc += samples[i]
		if i > 0: max_jump = maxf(max_jump,absf(samples[i]-samples[i-1]))
	var rms: float = sqrt(energy/samples.size())
	print("BGM_PCM peak=%.4f rms=%.4f dc=%.6f max_jump=%.4f bake_ms=%.2f" % [peak,rms,dc/samples.size(),max_jump,MusicScore.bake_usec/1000.0])
	_check(peak < .95 and rms > .10 and absf(dc/samples.size()) < .003,"Music PCM has audible energy, headroom and negligible DC")
	_check(absf(samples[-1]-samples[0]) < .003,"Actual loop last-to-first sample is click free")
	_check(sound.bgm_player.bus == "Music" and sound.bgm_player.stream is AudioStreamSynchronized and sound.bgm_player.process_mode == Node.PROCESS_MODE_ALWAYS,"BGM owns one always-processing synchronized player on duckable Music")
	var stream_id: int = wav.get_instance_id()
	for mode: int in range(4):
		game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
		game.waves.advance_wave(game.waves.intro_duration())
		sound.advance(.1)
		_check(sound.bgm_player.playing and sound.score.stems["pad_bass"].get_instance_id() == stream_id,"Phase %d preserves the same playing PCM loop" % (mode+1))
	game.reset_game()
	sound.bgm_player.stop()
	sound.advance(0)
	_check(sound.bgm_player.playing and sound.bgm_restarts == 1,"Watchdog recovers an unexpected BGM stop")
	sound.toggle_mute()
	sound.bgm_player.stop()
	sound.advance(0)
	_check(not sound.bgm_player.playing and AudioServer.is_bus_mute(0),"Watchdog respects intentional mute")
	sound.toggle_mute()
	sound.advance(0)
	_check(sound.bgm_player.playing,"Unmute recovers a stopped music player")
	paused = true
	await _frames(3)
	_check(sound.bgm_player.playing,"BGM continues through tree pause")
	paused = false
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audio="):
			wav.save_to_wav(argument.trim_prefix("--audio="))

func _save_audio(samples: PackedVector2Array, path: String) -> void:
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples.size()*4)
	for i: int in range(samples.size()):
		bytes.encode_s16(i*4,int(samples[i].x*32767))
		bytes.encode_s16(i*4+2,int(samples[i].y*32767))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.mix_rate = MusicScore.RATE
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = true
	stream.data = bytes
	_check(stream.save_to_wav(path) == OK,"Exported actual calm/combat/final music PCM for listening")

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920,1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_size = Vector2i(1920,1080)
	await _frames(20)
	for mode: int in range(4):
		game.reset_game()
		game.waves.autoplay = false
		game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
		for p: float in [.25,.55,.78]:
			game.waves.transition_remaining = game.waves.intro_duration()*(1.0-p)
			game.waves.advance_wave(0)
			game.cinematic._process(0)
			await _save(directory,"intro-%d-%02d.png" % [mode+1,int(p*100)])
		game.waves.advance_wave(game.waves.transition_remaining)
		game.waves.bosses()[mode].advance(.4)
		await _save(directory,"battle-%d-bottom-hud.png" % (mode+1))
	game.pause_menu.set_open(true)
	await _save(directory,"pause-with-music.png")
	game.pause_menu.set_open(false)

func _save(directory: String, filename: String) -> void:
	await _rendered()
	_check(root.get_texture().get_image().save_png(directory.path_join(filename)) == OK,"Native capture " + filename)

func _rendered() -> void:
	for i: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for i: int in range(count): await physics_frame

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
