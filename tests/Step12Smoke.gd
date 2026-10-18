extends SceneTree
var game: MainGame
var sound: SoundManager
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = load("res://scenes/MainGame.tscn").instantiate() as MainGame
	root.add_child(game)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	sound = game.sound
	sound.set_process(false)
	sound.bake_all_now()
	_assets()
	_fallback()
	_mixing()
	_events()
	_music()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _native(argument.trim_prefix("--capture="))
	print("STEP12_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	await process_frame
	OS.delay_msec(100)
	quit(0 if failures == 0 else 1)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func _assets() -> void:
	_check(not sound.library.manifest.is_empty(), "Manifest loads")
	var total: int = 0
	for row: Dictionary in sound.library.manifest.get("outputs", []):
		var path: String = "res://assets/audio/" + str(row["file"])
		var data: PackedByteArray = FileAccess.get_file_as_bytes(path)
		total += data.size()
		var channels: int = data.decode_u16(22)
		var rate: int = data.decode_u32(24)
		var n: int = (data.size()-44)/2
		var peak: float = 0.0
		var sums: Array[float] = [0.0, 0.0]
		var energy: float = 0.0
		for i: int in range(n):
			var value: float = data.decode_s16(44+i*2)/32768.0
			peak = maxf(peak, absf(value))
			sums[i%channels] += value
			energy += value*value
		var dc: float = maxf(absf(sums[0]), absf(sums[1]))/(n/channels)
		var seam: float = 0.0
		for c: int in range(channels):
			seam = maxf(seam, absf(float(data.decode_s16(44+c*2)-data.decode_s16(data.size()-channels*2+c*2)))/32768.0)
		var loop: bool = row["loop"]
		_check(sound.library.has(row["key"]), "Sample loaded: " + str(row["name"]))
		_check(peak <= db_to_linear(-1.0)+.0001 and peak > .01 and dc < .001, "Actual PCM peak/DC: " + str(row["name"]))
		_check(rate in [32000,44100] and channels == (2 if loop else 1) and float(n/channels)/rate <= float(row["max_seconds"])+.001, "Rate/channels/duration: " + str(row["name"]))
		_check(seam < .001, "Fades/seam: " + str(row["name"]))
		var wav: AudioStreamWAV = sound.library.pick(row["key"]) as AudioStreamWAV
		_check(wav != null and wav.format == AudioStreamWAV.FORMAT_QOA and wav.loop_mode == (AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED), "QOA and forced loop flags: " + str(row["name"]))
		if loop:
			_check(wav.loop_end == int(row["frames"]) and absf(linear_to_db(sqrt(energy/n))+24.0) < .2, "Loop end and -24 dBFS RMS: " + str(row["name"]))
	_check(total <= 25000000 and total == int(sound.library.manifest["total_bytes"]), "Actual derivative payload <=25 MB")
	var first: AudioStream = sound.library.pick("thunder")
	_check(sound.library.pick("thunder") != first, "Variant selection avoids immediate repetition")

func _fallback() -> void:
	sound.library.enabled = false
	var keys: Dictionary = SoundManager.MIX.duplicate()
	for row: Dictionary in sound.library.manifest["outputs"]: keys[row["key"]] = true
	for key: String in keys:
		sound.clock += 10.0
		_check(sound.play(key) and not sound.history.back()["sample"], "Synth fallback: " + key)
	sound.library.enabled = true
	for child: Node in sound.get_children():
		if child is AudioStreamPlayer and child.name != "BGM" and child.name != "BGM_Layer": child.stop()

func _mixing() -> void:
	sound._ducks.clear()
	sound._shaking = false
	sound._shake_duck = 0.0
	sound.duck(-6,.05,.15,.4)
	sound._update_mix(.05)
	var music: int = AudioServer.get_bus_index("Music")
	var ambience: int = AudioServer.get_bus_index("Ambience")
	var sfx: int = AudioServer.get_bus_index("SFX")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(music),-6) and is_equal_approx(AudioServer.get_bus_volume_db(ambience),-6) and AudioServer.get_bus_volume_db(sfx) == 0.0, "Duck affects Music/Ambience only")
	sound._update_mix(.6)
	_check(is_zero_approx(AudioServer.get_bus_volume_db(music)) and is_zero_approx(AudioServer.get_bus_volume_db(ambience)), "Duck recovers")
	for state: String in AmbienceDirector.STATES:
		sound.ambience.set_state(state)
		sound.ambience.advance(1.5,sound.library,sound.streams)
		var correct: bool = true
		for key: String in AmbienceDirector.KEYS:
			correct = correct and is_equal_approx(sound.ambience.players[key].volume_db,float(AmbienceDirector.STATES[state].get(key,-80.0)))
		_check(correct,"Ambience state: "+state)
	sound.play("slam",0.0,-.4)
	_check(sound.history.back()["pan"] < 0.0 and (AudioServer.get_bus_effect(AudioServer.get_bus_index("WorldLeft"),0) as AudioEffectPanner).pan == -.5,"Left world source routes to left panner")
	sound.clock += 3.0
	sound.musical_feedback()
	var note: int = sound.combo_note
	sound.clock += .2
	sound.musical_feedback()
	_check(sound.combo_note > note and sound.combo_note in SoundManager.PENTATONIC,"Two-second combo ascends D minor pentatonic")
	sound.clock += 2.01
	sound.musical_feedback()
	_check(sound.combo_note == 62,"Combo resets after two seconds")
	for degree: int in range(6):
		sound.musical_feedback(degree)
		_check(sound.combo_note == SoundManager.PENTATONIC[degree],"Preparation task note %d" % (degree+1))

func _events() -> void:
	sound._pending.clear()
	sound.clock += 10.0
	var before: int = sound.plays("thunder")
	game.weather.trigger_flash(.8)
	_check(sound.plays("thunder") == before and sound._pending.size() == 1,"Flash schedules, does not immediately play thunder")
	var delay: float = sound._pending[0]["at"]-sound.clock
	_check(delay >= .2 and delay <= 1.2,"Thunder delay .2–1.2 s")
	sound.advance(delay+.001)
	_check(sound.plays("thunder") == before+1,"Delayed thunder plays")
	game.weather.trigger_flash(1.0)
	_check(sound._pending.is_empty(),"Four-second lightning throttle")
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	game.waves.advance_wave(game.waves.intro_duration())
	sound.clock += 10.0
	game.tremor.warned.emit(1.0)
	_check(sound.history.back()["key"] == "tremor" and not sound.history.back()["sample"],"Tremor uses synth early warning")
	var layers: Array = SoundRecipes.all()["tremor"]["layers"]
	_check(layers[0]["dur"] == .12 and layers[1]["start"] == .2,"Two short clear warning beeps")
	game.tremor.shaking_changed.emit(true)
	sound.advance(1.5)
	_check(sound.ambience.target["amb_quake"] == -10.0 and sound.duck_db <= -8 and is_equal_approx(sound._music_cutoff,600.0),"Shake elevates quake bed, ducks and low-passes Music")
	var safe: int = sound.plays("safe")
	game.tremor.debris.emit(true)
	_check(sound.plays("safe") == safe+1,"Correct cover uses safe sample")
	sound.clock += 2.0
	game.tremor.toppled.emit(game.building.props[0])
	_check(sound.history.back()["key"] == "topple" and sound.history.back()["sample"],"Real topple signal uses recording")
	game.preparedness.window_shattered.emit(game.player.global_position)
	_check(sound.history.back()["key"] == "impact_glass" and sound.history.back()["sample"],"Window signal uses glass recording")
	game.tremor.shaking_changed.emit(false)
	sound.advance(.6)
	_check(is_zero_approx(sound._shake_duck) and sound._music_cutoff >= 19999.0,"Shake mix opens over .6 seconds")

func _music() -> void:
	game.reset_game()
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.upgrades.pending = false
	var score: AdaptiveMusic = sound.score
	_check(sound.bgm_player.stream is AudioStreamSynchronized and score.stream.stream_count == 5, "Five stems use AudioStreamSynchronized")
	for key: String in MusicScore.STEMS:
		var wav: AudioStreamWAV = score.stems[key]
		_check(wav.mix_rate == 22050 and not wav.stereo and wav.loop_end == MusicScore.SAMPLE_COUNT and wav.data.size() == MusicScore.SAMPLE_COUNT*2 and wav.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Identical stem length/rate/loop: "+key)
		var data: PackedFloat32Array = SoundSynth.from_pcm16(wav.data)
		var mean: float = 0.0
		var peak: float = 0.0
		var energy: float = 0.0
		for value: float in data:
			mean += value
			peak = maxf(peak,absf(value))
			energy += value*value
		_check(peak <= .6 and absf(mean/data.size()) < .003 and energy/data.size() > .0004 and absf(data[0]-data[-1]) < .003, "Stem energy, headroom, DC and seam: "+key)
	_check(MusicScore.bake_count == 1 and MusicScore.bake_usec < 6000000, "All five stems generated once in under six seconds (%.1f ms)" % (MusicScore.bake_usec/1000.0))
	print("STEMS_BAKE milliseconds=%.1f count=%d" % [MusicScore.bake_usec/1000.0,MusicScore.bake_count])
	score.transport = 0.0
	score._resume_beat = false
	score._was_shaking = false
	sound._shaking = false
	for key: String in MusicScore.STEMS:
		score.levels[key] = -60.0
		score.targets[key] = -60.0
	sound.advance(1.9)
	_check(score.levels["drums"] == -60.0, "Combat stem waits for next bar")
	sound.advance(.1)
	_check(score.targets["drums"] == -5.0 and score.levels["drums"] < -5.0, "At 2 s the heavy earthquake drums begin a smooth fade")
	sound.advance(.8)
	_check(score.levels["drums"] == -5.0 and score.levels["lead_arp"] == -60.0, "0–10 s: pad and drums only")
	for seconds: float in [10.0,28.0,30.0,36.0]:
		game.waves.siege_remaining = 40.0-seconds
		sound.advance(2.8)
		var expected: float = -8.0 if seconds >= 30 else (-12.0 if seconds >= 28 else -60.0)
		_check(score.levels["lead_arp"] == -11.0 and score.levels["climax"] == expected, "Fight orchestration at %.0f seconds" % seconds)
	for mode: int in range(3):
		game.waves.mode = mode as DisasterWaveManager.Mode
		game.waves.siege_remaining = 20.0
		sound.advance(2.8)
		_check(score.levels["pad_bass"] == (-9.0 if mode == 2 else -12.0) and score.levels["lead_arp"] == (-6.0 if mode == 0 else -11.0) and score.levels["drums"] == (-5.0 if mode == 1 else -9.0), "Boss stem colour %d" % mode)
	sound._on_shaking(true)
	sound.advance(.12)
	_check(score.levels["drums"] == -60.0 and score.levels["lead_arp"] == -60.0 and score.levels["tension"] > -60.0, "Shake removes drums/lead and exposes tension")
	score.transport = 5.0
	sound._on_shaking(false)
	var slams: int = sound.plays("slam")
	sound.clock += 2.0
	sound.advance(.2)
	_check(score.levels["drums"] == -60.0 and sound.plays("slam") == slams, "Drums wait for a beat after shake release")
	sound.advance(.3)
	sound.advance(.8)
	_check(score.levels["drums"] > -60.0 and sound.plays("slam") == slams+1, "Drums return on next beat with exactly one slam")
	game.player.health = 25.0
	sound.advance(2.8)
	_check(score.levels["tension"] == -10.0 and sound._music_cutoff <= 2400.0, "Low health adds tension and a mild low-pass")
	var low_count: int = sound.plays("health_low")
	game.player.health = 100.0
	sound.advance(1.0)
	game.player.health = 25.0
	sound.advance(1.0)
	_check(sound.plays("health_low") == low_count, "Low-health sting fires only on first crossing of this fight")
	var defeat: int = sound.plays("defeat")
	score.transport = .1
	game.waves.fail_siege()
	_check(sound.plays("defeat") == defeat, "Defeat sting waits for musical fade")
	for i: int in range(180): sound.advance(1.0/60.0)
	_check(sound.plays("defeat") == defeat+1 and score.levels["drums"] == -60.0, "Result fades on a bar before its sting")
	game.reset_game()
	sound.advance(2.8)
	_check(score.levels["pad_bass"] == -12.0 and score.levels["tension"] == -20.0 and score.levels["drums"] == -60.0, "Preparation uses pad and tension")
	game.upgrades.pending = true
	sound.advance(2.8)
	_check(score.levels["pad_bass"] == -16.0 and score.levels["tension"] == -60.0, "Card/debrief uses quiet pad")
	_check(MusicScore.bake_count == 1 and score.stream == sound.bgm_player.stream, "Ordinary transitions never rebake or replace the synchronized stream")
	var grid: bool = true
	for at: float in score.commits: grid = grid and is_zero_approx(fmod(at,2.0))
	_check(grid, "All orchestration commits lie on 2-second bars")

func _native(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.content_scale_size = Vector2i(1920,1080)
	game.reset_game()
	game.upgrades.pending = false
	for mode: int in [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.STORM, DisasterWaveManager.Mode.FLOOD]:
		game.waves.start_siege(mode as DisasterWaveManager.Mode, true)
		game.waves.advance_wave(game.waves.intro_duration())
		game.waves.siege_remaining = 8.0
		sound.advance(2.8)
		game.weather.advance(.7)
		game._apply_atmosphere()
		game.hud.queue_redraw()
		for i: int in range(3): await process_frame
		await RenderingServer.frame_post_draw
		_check(game.hud.drawn_texts.has(game.waves.boss_name()), "Captured HUD names the current boss")
		var img: Image = root.get_texture().get_image()
		_check(img.get_size() == Vector2i(1920,1080) and img.save_png(directory.path_join("audio-stage-%d.png" % mode)) == OK,"Native stage screenshot 1920x1080")
	# Real mixer, isolate SFX panning from centred music/ambience. No headless
	# amplitude claims: capture the rendered stereo bus after the panner.
	var bus: int = AudioServer.get_bus_index("WorldLeft")
	var capture: AudioEffectCapture = AudioEffectCapture.new()
	AudioServer.add_bus_effect(bus,capture)
	sound.clock += 10.0
	var left_point: Vector2 = game.world_viewport.get_canvas_transform().affine_inverse()*Vector2(120,270)
	sound.play_at("slam",left_point)
	await create_timer(.35).timeout
	var frames: PackedVector2Array = capture.get_buffer(capture.get_frames_available())
	var energy: Vector2 = Vector2.ZERO
	for frame: Vector2 in frames: energy += Vector2(frame.x*frame.x,frame.y*frame.y)
	_check(energy.x > energy.y*1.2 and energy.x > .0001,"Real left-panned output has greater left energy")
	print("STEREO_LIVE frames=%d left=%.6f right=%.6f" % [frames.size(),energy.x,energy.y])
	AudioServer.remove_bus_effect(bus,AudioServer.get_bus_effect_count(bus)-1)
