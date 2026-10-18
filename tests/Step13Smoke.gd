extends SceneTree
## Recording identity, source-clock A/B seams and the real menu/retry/result flow.
var game: MainGame
var sound: SoundManager
var director: MusicDirector
var checks: int = 0
var failures: int = 0
const EXPECTED: Dictionary = {
	"menu": [189.0, 190.0, "8fe1e07fa6edf38fa75ef9fd4a8e7ecee36dbdc6dbbc40638bdcdcca222a8180"],
	"bed": [54.0, 55.5, "c78a433139ace4a050b5d4a1b9b94bcf1f04d059345c849c7c234a2fe0eda102"],
	"prep": [56.0, 58.0, "d5862627e6d0c424fc157eaffaa5421bae4f0bb177e7628d520bfb6a45aa9676"],
	"final": [56.0, 58.0, "f8c36b37cac782f0d2b23b52b2c2736af3a748360b829212b415c07fc5d504e5"],
	"victory": [5.0, 7.0, "9acde356c84b1d326a3e7b813e43e8849596a285796144f7fabed898f2c21007"],
}

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	game = load("res://scenes/MainGame.tscn").instantiate() as MainGame
	game.show_main_menu = true
	game.menu_settings_path = "user://step13-unused-%d.cfg" % Time.get_ticks_usec()
	root.add_child(game)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	sound = game.sound
	sound.set_process(false)
	sound.bake_all_now()
	director = sound.director
	_assets()
	_seams()
	_states()
	_missing()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _native(argument.trim_prefix("--capture="))
	print("STEP13_RESULT checks=%d failures=%d" % [checks, failures])
	paused = false
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

func _tick(seconds: float) -> void:
	var left: float = seconds
	while left > .0000001:
		var step: float = minf(left, .05)
		sound.advance(step)
		left -= step

func _assets() -> void:
	_check(director.tracks.size() == 5, "Five continuous-music tracks exist")
	var total: int = 0
	for key: String in EXPECTED:
		var track: MusicDirector.Track = director.tracks[key]
		var path: String = MusicDirector.ROOT + MusicDirector.TRACKS[key]["file"]
		_check(director.has(key) and track.stream.get_length() >= EXPECTED[key][0] and track.stream.get_length() <= EXPECTED[key][1], "Loads expected duration: " + key)
		print("MUSIC_ASSET key=%s seconds=%.6f" % [key, track.stream.get_length()])
		_check(FileAccess.get_sha256(path) == EXPECTED[key][2], "Unmodified CC0 recording SHA-256: " + key)
		_check(not track.stream.get("loop") and "loop=false" in FileAccess.get_file_as_string(path + ".import"), "Import and runtime automatic looping disabled: " + key)
		_check(track.crossfade == 0.0 or (track.loop_end < track.stream.get_length() and track.loop_start >= 0.0 and track.loop_start + track.crossfade < track.loop_end - track.crossfade), "Loop and crossfade lie inside source: " + key)
		_check(track.players.size() == 2 and track.players[0].bus == "Music" and track.players[1].bus == "Music" and track.players[0].process_mode == Node.PROCESS_MODE_ALWAYS and track.players[1].process_mode == Node.PROCESS_MODE_ALWAYS, "Two fixed ALWAYS Music voices: " + key)
		total += FileAccess.get_file_as_bytes(path).size()
	_check(total == 6375116, "Only the five requested originals (6,375,116 bytes)")

func _dispose(extra: MusicDirector, owner_node: Node) -> void:
	for key: String in extra.tracks:
		for player: AudioStreamPlayer in extra.tracks[key].players: player.stop()
	OS.delay_msec(40)
	for key: String in extra.tracks:
		for player: AudioStreamPlayer in extra.tracks[key].players: player.stream = null
	extra.release()
	owner_node.free()

func _seams() -> void:
	var holder: Node = Node.new()
	root.add_child(holder)
	var loops: MusicDirector = MusicDirector.new()
	loops.configure(holder)
	for key: String in ["bed", "menu", "prep", "final"]:
		var track: MusicDirector.Track = loops.tracks[key]
		track.pitch = MusicDirector.BED_PITCH * 1.05 if key == "bed" else 1.05
		track.level.set_target(-16.0, 0.0)
		track.start(track.loop_end - track.crossfade - .5)
		track.advance(.5 / track.pitch)
		_check(track.crossing and is_equal_approx(track.positions[1], track.loop_start) and track.players[0].playing and track.players[1].playing, "At end-crossfade the other voice starts at loop_start: " + key)
		track.advance(track.crossfade * .5 / track.pitch)
		_check(absf(track.weights.length_squared() - 1.0) < .00001 and absf(track.weights.x - track.weights.y) < .00001, "Half-seam gains preserve equal power: " + key)
		var actual_power: float = pow(db_to_linear(track.players[0].volume_db + 16.0), 2.0) + pow(db_to_linear(track.players[1].volume_db + 16.0), 2.0)
		_check(absf(actual_power - 1.0) < .0001, "Actual A/B player gains preserve power: " + key)
		track.advance(track.crossfade * .5 / track.pitch)
		_check(track.active == 1 and not track.crossing and track.wraps == 1 and is_equal_approx(track.positions[1], track.loop_start + track.crossfade), "Incoming head was consumed during seam, no repeated head: " + key)
		_check(not track.players[0].playing and track.players[1].playing, "Outgoing decoder stops after takeover: " + key)
		var period: float = (track.loop_end - track.loop_start - track.crossfade) / track.pitch
		track.advance(period * 3.0)
		_check(track.wraps == 4 and absf(track.positions[track.active] - track.loop_start - track.crossfade) < .0001, "Large clock step crosses three loops at source seconds/pitch: " + key)
		track.players[track.active].stop()
		var before: float = track.positions[track.active]
		track.advance(.1)
		_check(track.players[track.active].playing and absf(track.positions[track.active] - before - .1 * track.pitch) < .0001 and track.starts == 1, "Decoder recovery preserves source position: " + key)
	_dispose(loops, holder)

func _battle(mode: DisasterWaveManager.Mode) -> void:
	game.front_end.active = false
	game.reset_game()
	game.waves.start_siege(mode, true)
	game.waves.advance_wave(game.waves.intro_duration())

func _states() -> void:
	var menu: MusicDirector.Track = director.tracks["menu"]
	var bed: MusicDirector.Track = director.tracks["bed"]
	var prep: MusicDirector.Track = director.tracks["prep"]
	var final_track: MusicDirector.Track = director.tracks["final"]
	var victory: MusicDirector.Track = director.tracks["victory"]
	var voices: int = sound.get_child_count()
	var bake_count: int = MusicScore.bake_count
	sound.advance(0.0)
	_check(director.state == "menu" and menu.level.db == -10.0 and menu.positions[0] == 0.0 and menu.starts == 1, "First menu starts Blackout from its rising intro at -10 dB")
	_check(sound.bgm_player.volume_db == MusicDirector.SILENT and not bed.running and prep.level.db == MusicDirector.SILENT, "Menu has only Blackout, no bed or procedural score")
	_tick(1.0)
	_check(menu.players[menu.active].volume_db <= MusicDirector.MENU_CEILING_DB, "Blackout level remains below the -6 dB ceiling")
	game.front_end._begin_run()
	game.tutorial.enabled = false
	_tick(1.25)
	_check(menu.level.db > MusicDirector.SILENT and menu.level.db < -10.0 and bed.level.db > MusicDirector.SILENT and bed.level.db < -16.0, "Start crossfades in both directions over 2.5 seconds")
	_tick(1.25)
	_check(menu.level.db == MusicDirector.SILENT and bed.level.db == -16.0 and prep.level.db == -20.0 and sound.bgm_player.volume_db == 0.0, "At 2.5 s: bed + Sector + existing preparation score")
	_check(is_equal_approx(bed.players[bed.active].pitch_scale, MusicDirector.BED_PITCH), "Bed shifts C to D by two semitones")
	var starts: int = bed.starts
	for mode: DisasterWaveManager.Mode in [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.STORM, DisasterWaveManager.Mode.FLOOD]:
		_battle(mode)
		_tick(2.8)
		_check(director.state == "combat" and bed.level.db == -16.0 and prep.level.db == -40.0 and sound.bgm_player.volume_db == 0.0 and sound.score.levels["drums"] > -60.0, "Normal boss keeps adaptive score over bed: %d" % mode)
		_check(bed.starts == starts and not final_track.running, "Phase transition never restarts bed or plays Urgent: %d" % mode)
	game.waves.fail_siege()
	_tick(1.5)
	_check(bed.level.db == -30.0 and bed.running, "Defeat lowers but never stops the bed")
	var at: float = bed.positions[bed.active]
	game.retry_phase()
	_check(not game.waves.failed and game.waves.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE], "Actual checkpoint retry succeeds")
	sound.advance(0.0)
	_check(is_equal_approx(bed.positions[bed.active], at) and bed.starts == starts, "Actual retry preserves bed position, not the file start")
	_tick(2.5)
	_check(bed.level.db == -16.0 and prep.level.db == -20.0, "Retry restores preparation levels")
	game.upgrades.pending = true
	_tick(1.5)
	_check(director.state == "cards" and bed.level.db == -16.0 and prep.level.db == -20.0, "Card/debrief continues bed with Sector")
	game.upgrades.pending = false
	game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	_tick(1.5)
	_check(not final_track.running and prep.level.db == -40.0, "Early final intro ducks Sector but does not start Urgent yet")
	game.waves.advance_wave(1.8)
	_tick(.05)
	_check(final_track.running and director.state == "final" and sound.bgm_player.volume_db == MusicDirector.SILENT, "Final intro's last second starts Urgent and silences all code stems")
	game.waves.advance_wave(1.0)
	_tick(1.0)
	_check(final_track.level.db == -11.0 and bed.level.db == -16.0 and prep.level.db == MusicDirector.SILENT, "Final contains only bed and Urgent")
	game.waves.nova = true
	game.waves.siege_remaining = 10.0
	_tick(1.1)
	_check(final_track.level.db == -8.0 and is_equal_approx(final_track.pitch, 1.05) and is_equal_approx(bed.pitch, MusicDirector.BED_PITCH * 1.05), "Nova -8 dB, shared 1.05 multiplier for bed/Urgent/score")
	_check(menu.pitch == 1.0 and victory.pitch == 1.0, "Blackout and victory never inherit the multiplier")
	sound._on_shaking(true)
	_tick(.3)
	_check(bed.level.db == -12.0 and sound.duck_db <= -8.0 and AudioServer.is_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0), "Shake swells bed by 4 dB before the existing bus duck/filter")
	_tick(.3)
	_check(is_equal_approx(sound._music_cutoff, 600.0), "Existing shake low-pass reaches 600 Hz")
	sound._on_shaking(false)
	_tick(.6)
	_check(bed.level.db == -16.0 and is_zero_approx(sound._shake_duck), "Shake releases bed and bus over .6 seconds")
	at = bed.positions[bed.active]
	game.pause_menu.set_open(true)
	_tick(.5)
	_check(bed.positions[bed.active] > at and bed.running and AudioServer.is_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0), "Pause keeps the source clock moving with low-pass")
	game.pause_menu.set_open(false)
	_tick(.6)
	game.front_end.open()
	_tick(1.25)
	_check(menu.level.db > MusicDirector.SILENT and bed.level.db > MusicDirector.SILENT, "Return to menu reverses the crossfade")
	_tick(1.25)
	_check(menu.level.db == -10.0 and bed.level.db == MusicDirector.SILENT and sound.bgm_player.volume_db == MusicDirector.SILENT and not final_track.running, "At 2.5 seconds main menu has only Blackout again")
	game.front_end._begin_run()
	_battle(DisasterWaveManager.Mode.CATACLYSM)
	_tick(3.0)
	var wins: int = sound.plays("victory")
	game.waves.finish_wave()
	game.waves.advance_wave(1.0)
	_tick(.5)
	_check(sound.plays("victory") == wins and not victory.running and bed.level.db < -16.0, "Victory first fades the other music for one second")
	_tick(.55)
	_check(victory.running and victory.starts == 1 and sound.plays("victory") == wins + 1 and bed.level.db == MusicDirector.SILENT, "CC0 victory plays once after fade, replacing the old victory sting")
	_tick(victory.stream.get_length() + .05)
	_check(director.closing and menu.running and menu.level.target == -16.0 and menu.positions[menu.active] >= 42.0 and menu.positions[menu.active] < 42.3, "After victory Blackout returns at its 42-second steady section")
	_tick(4.0)
	_check(menu.level.db == -16.0 and sound.bgm_player.volume_db == MusicDirector.SILENT and sound.plays("victory") == wins + 1, "Four-second closing fade, no duplicate victory or procedural pad")
	sound.toggle_mute()
	_check(AudioServer.is_bus_mute(0), "Master mute includes all recording voices")
	sound.toggle_mute()
	var db: float = AudioServer.get_bus_volume_db(0)
	sound.change_volume(-1)
	_check(AudioServer.get_bus_volume_db(0) < db, "Master minus affects recordings")
	sound.change_volume(1)
	_check(is_equal_approx(AudioServer.get_bus_volume_db(0), db), "Master plus restores level")
	_check(sound.get_child_count() == voices and MusicScore.bake_count == bake_count, "All transitions reuse fixed nodes and existing baked stems")

func _missing() -> void:
	var holder: Node = Node.new()
	root.add_child(holder)
	var missing: MusicDirector = MusicDirector.new()
	missing.configure(holder, "res://assets/audio/not_present/")
	sound.director = missing
	for key: String in MusicDirector.TRACKS: _check(not missing.has(key), "Missing recording skips silently: " + key)
	game.front_end.open()
	_tick(3.0)
	_check(sound.bgm_player.volume_db == 0.0 and sound.bgm_player.playing and sound.score.levels["pad_bass"] > -60.0, "Missing menu recording falls back to original code music")
	_battle(DisasterWaveManager.Mode.CATACLYSM)
	game.waves.nova = true
	_tick(3.0)
	_check(sound.bgm_player.volume_db == 0.0 and sound.score.levels["climax"] == -8.0, "Missing Urgent preserves adaptive final score")
	var wins: int = sound.plays("victory")
	game.waves.finish_wave()
	game.waves.advance_wave(1.0)
	_tick(4.0)
	_check(sound.plays("victory") == wins + 1, "Missing victory retains existing sampled/synth victory fallback")
	sound.director = director
	_dispose(missing, holder)

func _native(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.content_scale_size = Vector2i(1920, 1080)
	# Exercise real Vorbis decoders through a seam. No fixed-fps or silent
	# headless claim: capture the Music bus and verify uninterrupted energy.
	game.front_end.active = false
	game.front_end.screen.visible = false
	game.set_frontend_active(false)
	_battle(DisasterWaveManager.Mode.EARTHQUAKE)
	_tick(3.0)
	var bed: MusicDirector.Track = director.tracks["bed"]
	bed.start(bed.loop_end - bed.crossfade - .25)
	var before: int = bed.wraps
	AudioServer.add_bus()
	var bus: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus, "MusicLoopCheck")
	AudioServer.set_bus_send(bus, "Music")
	for player: AudioStreamPlayer in bed.players: player.bus = "MusicLoopCheck"
	var capture: AudioEffectCapture = AudioEffectCapture.new()
	capture.buffer_length = 6.0
	AudioServer.add_bus_effect(bus, capture)
	sound.set_process(true)
	await create_timer(4.0).timeout
	sound.set_process(false)
	var frames: PackedVector2Array = capture.get_buffer(capture.get_frames_available())
	var energy: float = 0.0
	for frame: Vector2 in frames: energy += frame.length_squared()
	_check(bed.wraps > before and bed.players[bed.active].playing and frames.size() > 44100 and energy / maxf(1.0, frames.size()) > .000001, "Native A/B seam keeps decoded Music output alive")
	var lowest: float = INF
	var block_energy: float = 0.0
	var block: int = maxi(1, int(AudioServer.get_mix_rate() * .25))
	for index: int in range(frames.size()):
		block_energy += frames[index].length_squared()
		if (index + 1) % block == 0:
			lowest = minf(lowest, block_energy / block)
			block_energy = 0.0
	_check(lowest > .00000001, "Every quarter-second of the isolated bed seam has decoded audio")
	print("MUSIC_CLOCK source=%.6f decoder=%.6f pitch=%.6f" % [bed.positions[bed.active], bed.players[bed.active].get_playback_position(), bed.pitch])
	_check(absf(bed.players[bed.active].get_playback_position() - bed.positions[bed.active]) < .2, "Native decoder remains within 200 ms of the independent source clock")
	print("MUSIC_LIVE frames=%d mean_energy=%.8f wraps=%d" % [frames.size(), energy / maxf(1.0, frames.size()), bed.wraps - before])
	for player: AudioStreamPlayer in bed.players: player.bus = "Music"
	AudioServer.remove_bus(bus)
	game._apply_atmosphere()
	game.hud.queue_redraw()
	for i: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	_check(image.get_size() == Vector2i(1920, 1080) and image.save_png(directory.path_join("continuous-music.png")) == OK, "Native 1920x1080 game capture")
