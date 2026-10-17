extends SceneTree
## Step 5: ESC/P pause menu (keyboard + mouse), M mute and -/+ volume, and the
## procedural SoundManager: synthesis quality, mix rules, throttling, every game
## event hook, the dynamic music bed/pulse and native 1920x1080 captures.
var game: MainGame
var sound: SoundManager
var checks: int = 0
var failures: int = 0

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
	await _frames(3)
	sound = game.sound
	var started: int = Time.get_ticks_msec()
	sound.bake_all_now()
	print("SOUND_BAKE waited=%d ms streams=%d" % [Time.get_ticks_msec() - started, sound.streams.size()])
	_synthesis()
	await _pause_menu()
	await _events()
	_music()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP5_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _quiet() -> void:
	game.waves.autoplay = false
	for node: Node in [game.loot, game.mechanics, game.player]: node.set_physics_process(false)

func _siege(mode: int) -> void:
	game.reset_game()
	_quiet()
	game.waves.start_siege(mode as DisasterWaveManager.Mode, true)

	game.building.pacing_enabled = false
	game.telegraphs.clear()
	game.projectiles.clear()

# ------------------------------------------------------------ synthesis ----

func _synthesis() -> void:
	var recipes: Dictionary = SoundRecipes.all()
	_check(sound.is_baked() and recipes.size() == SoundRecipes.ORDER.size(), "Every recipe is baked into a stream (%d sounds, no audio files)" % sound.streams.size())
	var mixed: bool = true
	for key: String in SoundRecipes.ORDER: mixed = mixed and SoundManager.MIX.has(key)
	_check(mixed, "Every sound has an explicit mix level, bus and throttle")
	var format_ok: bool = true
	var levels_ok: bool = true
	var clicks_ok: bool = true
	var dark_ok: bool = true
	var loops_ok: bool = true
	var report: PackedStringArray = PackedStringArray()
	for key: String in SoundRecipes.ORDER:
		var stream: AudioStreamWAV = sound.streams[key]
		var loop: bool = SoundRecipes.LOOPS.has(key)
		format_ok = format_ok and stream.format == AudioStreamWAV.FORMAT_16_BITS and stream.mix_rate == SoundSynth.RATE and not stream.stereo
		var s: PackedFloat32Array = SoundSynth.from_pcm16(stream.data)
		var expected: float = float(recipes[key]["length"]) - (float(recipes[key].get("xfade", 0.0)) if loop else 0.0)
		format_ok = format_ok and absf(s.size() / float(SoundSynth.RATE) - expected) < 0.01
		var peak: float = 0.0
		var energy: float = 0.0
		var diff: float = 0.0
		var mean: float = 0.0
		for i: int in range(s.size()):
			peak = maxf(peak, absf(s[i]))
			energy += s[i] * s[i]
			mean += s[i]
			if i > 0: diff += (s[i] - s[i - 1]) * (s[i] - s[i - 1])
		var bright: float = sqrt(diff / maxf(energy, 0.000001))
		levels_ok = levels_ok and peak >= 0.3 and peak <= 0.93 and absf(mean / s.size()) < 0.01
		if loop:
			loops_ok = loops_ok and stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_end == s.size() and absf(s[s.size() - 1] - s[0]) < 0.05
			dark_ok = dark_ok and bright < 0.3
		else:
			# A click is an instant onset/cut: the first 0.5 ms and last 2 ms must be near silent.
			var step: float = 0.0
			for i: int in range(11): step = maxf(step, absf(s[i]))
			var tail: float = 0.0
			for i: int in range(s.size() - 44, s.size()): tail = maxf(tail, absf(s[i]))
			clicks_ok = clicks_ok and absf(s[0]) < 0.005 and step < 0.15 and tail < 0.02 and absf(s[s.size() - 1]) < 0.005
			if step >= 0.15 or tail >= 0.02: print("CLICK %s onset %.3f tail %.3f" % [key, step, tail])
			dark_ok = dark_ok and bright < 0.95
		if bright > 0.6: report.append("%s %.2f" % [key, bright])
	_check(format_ok, "16-bit mono 22.05 kHz PCM with the exact recipe lengths")
	_check(levels_ok, "Peaks stay between -10 and -0.6 dBFS with no DC offset")
	_check(clicks_ok, "Soft attack (no start click) and a release that ends in silence")
	_check(dark_ok, "Filtered, dark spectrum: no fizzy or harsh sound (bright: %s)" % ", ".join(report))
	_check(loops_ok, "Rain, drone and siege pad loop seamlessly")
	var unique: Dictionary = {}
	for keys: Array in SoundManager.INTROS + SoundManager.OUTROS:
		for key: String in keys: unique[key] = true
	_check(unique.size() == 8, "Four active bosses retain distinct entry and retreat sounds")
	_check(SoundManager.MIX["whoosh"][0] == SoundManager.SFX_REFERENCE_DB - 8.0 and SoundManager.MIX["impact_stone"][0] == SoundManager.MIX["cast_quake"][0] - 8.0, "Projectile launch/impact sounds sit 8 dB under the main effects")
	_check(SoundManager.MIX["whoosh"][2] >= 0.09 and SoundManager.MIX["whoosh"][2] <= 0.14 and SoundManager.MIX["impact_glass"][2] >= 0.09 and SoundManager.MIX["impact_glass"][2] <= 0.14, "Projectile throttles are inside the 0.09-0.14 s window")
	var master: int = 0
	_check(AudioServer.get_bus_index(SoundManager.BUS_MUSIC) > 0 and AudioServer.get_bus_index(SoundManager.BUS_SFX) > 0 and AudioServer.get_bus_index(SoundManager.BUS_UI) > 0 and AudioServer.get_bus_effect_count(master) >= 1, "Music / SFX / UI buses with a limiter on Master")

# ----------------------------------------------------------------- pause ----

func _pause_menu() -> void:
	var menu: PauseMenu = game.pause_menu
	var w: DisasterWaveManager = game.waves
	game.reset_game()
	w.start_next_wave()

	game.building.pacing_enabled = false
	w.autoplay = true
	game.player.set_physics_process(true)
	await _frames(5)
	_check(menu.process_mode == Node.PROCESS_MODE_ALWAYS and not menu.visible and not paused, "Pause menu exists, hidden, and always processes")
	await _tap(KEY_ESCAPE)
	var clock: float = w.siege_remaining
	var spot: Vector2 = game.player.global_position
	_check(paused and menu.is_open and menu.visible, "ESC pauses the whole tree and opens the panel")
	await _frames(20)
	_check(w.siege_remaining == clock and game.player.global_position == spot, "While paused the wave clock and the player are frozen")
	var music_bus: int = AudioServer.get_bus_index(SoundManager.BUS_MUSIC)
	_check(sound.paused_view and AudioServer.is_bus_effect_enabled(music_bus, 0), "Pause muffles the music bed with a low-pass")
	await _tap(KEY_M)
	_check(sound.muted and AudioServer.is_bus_mute(0) and (menu.buttons["mute"] as Button).text == "[M] SES: KAPALI", "M mutes inside the pause menu and the button says KAPALI")
	await _tap(KEY_M)
	_check(not sound.muted and not AudioServer.is_bus_mute(0) and (menu.buttons["mute"] as Button).text == "[M] SES: AÇIK", "M unmutes again")
	var level: int = sound.volume_level
	await _tap(KEY_MINUS, 45)
	_check(sound.volume_level == level - 1, "- lowers the volume one step")
	await _tap(KEY_EQUAL, 43)
	_check(sound.volume_level == level and is_equal_approx(AudioServer.get_bus_volume_db(0), sound.level_db()), "+ raises it back; Master follows the level")
	await _rendered()
	_click(menu.buttons["louder"])
	_check(sound.volume_level == level + 1, "Mouse click on + raises the volume")
	_click(menu.buttons["quieter"])
	_click(menu.buttons["mute"])
	_check(sound.volume_level == level and sound.muted, "Mouse click on - and on the sound button work")
	_click(menu.buttons["mute"])
	_click(menu.buttons["resume"])
	_check(not paused and not menu.visible and not sound.paused_view and not AudioServer.is_bus_effect_enabled(music_bus, 0), "Mouse click on DEVAM ET resumes and restores the music")
	await _frames(10)
	_check(w.siege_remaining < clock, "The fight continues after resuming")
	await _tap(KEY_P)
	_check(paused, "P also pauses")
	await _tap(KEY_P)
	_check(not paused, "P resumes")
	await _tap(KEY_ESCAPE)
	await _tap(KEY_R)
	_check(not paused and w.wave_number == 0 and w.state == DisasterWaveManager.State.PREPARATION_PHASE, "R inside the pause menu restarts the campaign and unpauses")
	w.autoplay = false
	w.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.upgrades.open_selection()
	await _tap(KEY_ESCAPE)
	_check(paused and game.upgrades.pending, "ESC can pause on top of the card screen without choosing a card")
	await _tap(KEY_ESCAPE)
	_check(not paused and game.upgrades.pending, "Resuming returns to the untouched card choice")
	game.upgrades.choose(0)
	await _tap(KEY_M)
	await _rendered()
	_check(sound.muted and game.hud.drawn_texts.has("[M] SES KAPALI") and game.hud.drawn_texts.has("[H] YARDIM   [ESC] DURAKLAT"), "M works in play; HUD corner shows [ESC] DURAKLAT and the muted speaker")
	await _tap(KEY_M)
	await _rendered()
	_check(not sound.muted and game.hud.drawn_texts.has("[M] SES"), "HUD speaker returns to [M] SES")
	game.player.set_physics_process(false)

# ---------------------------------------------------------------- events ----

func _events() -> void:
	var w: DisasterWaveManager = game.waves
	game.reset_game()
	_quiet()
	sound.history.clear()
	for mode: int in range(4):
		sound.advance(1.0)
		w.start_siege(mode as DisasterWaveManager.Mode, true)
		var intro: bool = true
		for key: String in SoundManager.INTROS[mode]: intro = intro and sound.history.back()["key"] == key or _played_recently(key)

		sound.advance(1.0)
		w.finish_wave()
		var outro: bool = true
		for key: String in SoundManager.OUTROS[mode]: outro = outro and _played_recently(key)
		_check(intro and outro, "Boss mode %d plays its own entry and retreat sounds" % mode)
	_check(sound.plays("titan_fuse") == 0 and sound.plays("titan_in") > 0,"The final boss keeps its original entry sound without a fusion cutscene")
	_siege(DisasterWaveManager.Mode.CATACLYSM)
	sound.advance(1.0)
	sound.history.clear()
	game.titan.plan_pattern(w, 3, 1)
	_check(sound.plays("warn") == 1, "A boss wind-up plays one radar warning tone")
	var attack: HazardAttack = w._attack(HazardAttack.Kind.FIREBALL, 1, Vector2(800, 700), Vector2(400, 0))
	attack.source = 3
	for i: int in range(20): w.attack_launched.emit(attack)
	_check(sound.plays("whoosh") == 1 and sound.plays("cast_fire") == 1, "Twenty launches in one frame make one whoosh and one cast (spam guard)")
	sound.advance(0.08)
	w.attack_launched.emit(attack)
	_check(sound.plays("whoosh") == 1, "Still throttled 0.08 s later")
	sound.advance(0.06)
	w.attack_launched.emit(attack)
	_check(sound.plays("whoosh") == 2, "A new whoosh is allowed after the 0.12 s window")
	var whoosh: Dictionary = {}
	var cast: Dictionary = {}
	for entry: Dictionary in sound.history:
		if entry["key"] == "whoosh": whoosh = entry
		if entry["key"] == "cast_fire": cast = entry
	_check(is_equal_approx(float(cast["volume_db"]) - float(whoosh["volume_db"]), 8.0), "Launch whoosh plays exactly 8 dB under the fire cast")
	var expected: Dictionary = {HazardAttack.Kind.GLASS: "impact_glass", HazardAttack.Kind.CHAIR: "impact_wood", HazardAttack.Kind.CONCRETE: "impact_stone", HazardAttack.Kind.SAW: "impact_metal", HazardAttack.Kind.HYDRO_ORB: "impact_water", HazardAttack.Kind.FIRE_DART: "impact_fire"}
	var impacts: bool = true
	for kind: int in expected:
		sound.advance(0.2)
		var hit: HazardAttack = w._attack(kind as HazardAttack.Kind, 1, Vector2(600, 700), Vector2.ZERO)
		hit.source = 1
		sound._on_impact(hit, Vector2(600, 700))
		impacts = impacts and sound.history.back()["key"] == expected[kind]
	_check(impacts, "Impacts sound like glass, wood, stone, metal, water or fire by projectile type")
	var shutter: RoomDiorama = game.building.room_at_point(1, 600)
	shutter.reinforce(RoomDiorama.Reinforcement.SHUTTER)
	sound.advance(0.2)
	var gust: HazardAttack = w._attack(HazardAttack.Kind.GLASS, 1, Vector2(600, 700), Vector2.ZERO)
	gust.source = 0
	sound._on_impact(gust, Vector2(600, 700))
	_check(sound.history.back()["key"] == "block", "A storm hit on a shuttered room plays the BLOKLANDI block")
	sound.advance(0.2)
	game.mechanics.blocked.emit(Vector2.ZERO)
	_check(sound.history.back()["key"] == "block", "Active shield and orbital interceptions play the block")
	for pair: Array in [[SiegeUpgrades.Kind.AWARE_BAG,"heal"],[SiegeUpgrades.Kind.AUTO_DRONE,"repair"]]:
		sound.advance(.3)
		game.mechanics.activated.emit(pair[0],Vector2.ZERO)
		_check(sound.history.back()["key"] == pair[1],"Active module event %d plays %s through the bounded SFX pool" % pair)
	sound.advance(0.2)
	game.projectiles.dodged.emit(Vector2.ZERO)
	_check(sound.history.back()["key"] == "dodge", "DODGE! plays the reflex chime")
	sound.advance(0.2)
	game.player.hit_invulnerability = 0.0
	game.projectiles.grazed.emit(game.player.global_position)
	_check(sound.history.back()["key"] == "graze", "A real graze (energy granted) plays the soft electric tick")
	# Real player actions.
	_siege(DisasterWaveManager.Mode.STORM)
	var p: SiegePlayer = game.player
	p.set_physics_process(true)
	await _frames(4)
	sound.advance(0.2)
	_check(p.try_jump() and sound.history.back()["key"] == "jump", "Ground jump plays the springy jump")
	await _frames(8)
	sound.advance(0.2)
	_check(p.try_air_jump() and sound.history.back()["key"] == "floor_up", "Second W (upper floor arc) plays the rising sweep")
	await _frames(40)
	sound.advance(0.2)
	var before: int = sound.plays("drop_land")
	_check(p.try_floor_shift(-1), "S drop starts")
	await _frames(12)
	_check(sound.plays("drop_land") > before, "Landing from the S drop plays a footstep thud")
	await _frames(20)
	sound.advance(0.2)
	_check(p.try_dash(Vector2.RIGHT) and sound.history.back()["key"] == "dash", "Dash plays the air cut")
	await _frames(20)
	sound.advance(0.2)
	p.hit_invulnerability = 0
	_check(p.take_damage(10) and sound.history.back()["key"] == "hurt", "Taking a hit plays the dull hurt thud")
	sound.advance(0.2)
	_check(_played_recently("heartbeat"), "A short heartbeat follows the hit")
	p.set_physics_process(false)
	_quiet()
	var l: LootSystem = game.loot
	l._next_spawn = 999.0
	l.spawn(LootSystem.Kind.COLUMN_KIT, 8)
	sound.advance(0.2)
	l.advance(0.46)
	_check(sound.history.back()["key"] == "loot_drop", "Supply touching the floor plays a soft drop")
	sound.advance(0.2)
	l.collect(0)
	_check(sound.history.back()["key"] == "pickup", "Collecting a kit plays the equip sound")
	for pair: Array in [[LootSystem.Kind.EMERGENCY_BAG, "heal"], [LootSystem.Kind.SAFETY_KIT, "safety"]]:
		l.spawn(pair[0], 9)
		sound.advance(0.2)
		l.collect(l.items.size() - 1)
		_check(sound.history.back()["key"] == pair[1], "Collecting kind %d plays %s" % pair)
	var room: RoomDiorama = l.current_room()
	room.apply_damage(50)
	l.column_kits = 1
	sound.advance(0.3)
	_check(l.repair_current_room() == LootSystem.RepairResult.REPAIRED and sound.history.back()["key"] == "repair", "E repair plays clank, hydraulic lock and the engineering confirm tone")
	w.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	sound.advance(0.3)
	game.upgrades.open_selection()
	_check(sound.history.back()["key"] == "ui_open", "Card screen opening plays the UI open sound")
	sound.advance(0.3)
	game.upgrades.choose(0)
	_check(sound.history.back()["key"] == "ui_confirm", "Choosing a card plays the UI confirm")
	_siege(DisasterWaveManager.Mode.EARTHQUAKE)
	sound.advance(0.5)
	game.building.rooms[3].apply_damage(1000)
	_check(sound.history.back()["key"] == "collapse_room", "A collapsing room plays a destruction rumble")
	sound.advance(0.6)
	w.collapse_building()
	_check(_played_recently("collapse_building"), "A collapsing building plays the big collapse")
	_siege(DisasterWaveManager.Mode.CATACLYSM)
	sound.advance(0.6)
	w.finish_wave()
	w.advance_wave(1.0)
	_check(w.victory and _played_recently("victory"), "Victory plays the warm final chord")
	var pitches: Dictionary = {}
	var pitch_ok: bool = true
	for entry: Dictionary in sound.history:
		pitch_ok = pitch_ok and float(entry["pitch"]) >= SoundManager.PITCH_MIN and float(entry["pitch"]) <= SoundManager.PITCH_MAX
		pitches[snappedf(float(entry["pitch"]), 0.001)] = true
	_check(pitch_ok and pitches.size() > 10, "Every play is pitched randomly inside 0.94-1.06 (%d distinct)" % pitches.size())
	var voices: int = sound.get_child_count()
	for i: int in range(60):
		sound.advance(0.2)
		sound.play("impact_stone")
	_check(sound.get_child_count() == voices and sound.voice_count() == SoundManager.SFX_VOICES + SoundManager.BEAT_VOICES + SoundManager.UI_VOICES, "Sixty plays reuse the fixed voice pool")

func _played_recently(key: String) -> bool:
	for i: int in range(maxi(0, sound.history.size() - 4), sound.history.size()):
		if sound.history[i]["key"] == key: return true
	return false

# ----------------------------------------------------------------- music ----

func _music() -> void:
	var w: DisasterWaveManager = game.waves
	var music_stream: AudioStream = sound.bgm_player.stream
	_check(sound.bgm_player.playing and music_stream is AudioStreamWAV,"BGM starts immediately as a pre-baked PCM loop")
	game.reset_game()
	_quiet()
	sound.advance(.1)
	_check(sound.bpm == MusicScore.BPM*.5 and sound.bgm_player.playing,"Preparation retains uninterrupted BGM")
	_check((sound.music["rain"] as AudioStreamPlayer).playing and (sound.music["rain"] as AudioStreamPlayer).stream == sound.streams["rain"],"Quiet rain ambience remains underneath the dedicated BGM")
	_siege(DisasterWaveManager.Mode.STORM)
	sound.advance(.1)
	_check(sound.bpm == MusicScore.BPM and sound.bgm_player.stream == music_stream,"Siege reuses the same music without rebaking or restarting")
	var kicks: int = sound.plays("kick")
	var ticks: int = sound.plays("tick")
	for i: int in range(150): sound.advance(1.0/60.0)
	_check(sound.plays("kick") == kicks and sound.plays("tick") == ticks,"PCM score drums replace duplicate frame-scheduled pulses")
	_siege(DisasterWaveManager.Mode.CATACLYSM)
	w.siege_remaining = 14
	w.advance_wave(.01,.01)
	sound.advance(.1)
	_check(w.nova and sound.bgm_player.playing and sound.bgm_player.stream == music_stream,"Nova preserves audible continuous music")
	paused = true
	kicks = sound.plays("kick")
	for i: int in range(120): sound.advance(1.0/60.0)
	_check(sound.plays("kick") == kicks and sound.bgm_player.playing,"Pause freezes game events while the dedicated BGM keeps playing")
	paused = false

# --------------------------------------------------------------- capture ----

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_size = Vector2i(1920, 1080)
	await _frames(20)
	game.reset_game()
	game.waves.autoplay = false
	game.waves.start_siege(DisasterWaveManager.Mode.FLOOD, true)

	game.building.pacing_enabled = false
	game.flood.plan_pattern(game.waves, 2, 1)
	await _frames(30)
	await _save(directory, "01-hud-corner-hints.png")
	game.pause_menu.set_open(true)
	await _save(directory, "02-pause-menu.png")
	sound.toggle_mute()
	sound.change_volume(-3)
	await _save(directory, "03-pause-muted.png")
	sound.toggle_mute()
	sound.change_volume(3)
	game.pause_menu.set_open(false)

func _save(directory: String, filename: String) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920, 1080) and picture.save_png(directory.path_join(filename)) == OK, "Native capture %s (%s)" % [filename, picture.get_size()])

func _click(button: Button) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = root.get_final_transform() * button.get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, false)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	root.push_input(event, false)

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _tap(key: int, character: int = 0) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.unicode = character
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
