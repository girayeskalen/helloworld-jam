class_name AudioPreview
extends Node
## Opt-in native listening fixture, never part of an ordinary run.
## Records actual Master output for 75 wall-clock seconds, without fixed-fps.
var game: MainGame
var path: String
var recorder: AudioEffectRecord
var started: int = 0
var stage: int = -1
var finished: bool = false
var section: int = 0

func configure(owner_game: MainGame, output: String) -> void:
	game = owner_game
	path = output
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	call_deferred("_begin")

func _begin() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Audio preview requires a desktop audio driver; run without --headless.")
		return
	get_tree().root.unfocusable = true
	get_tree().root.mouse_passthrough = true
	if game.front_end == null:
		game.front_end = SiegeFrontEnd.new()
		game.add_child(game.front_end)
		game.front_end.configure(game, "user://audio-preview-unused.cfg")
	game.front_end.open()
	game.tutorial.enabled = false
	game.hitstop_enabled = false
	game.sound.bake_all_now()
	game.sound.muted = false
	game.sound.volume_level = 8
	game.sound._apply_settings()
	# Ten seconds menu + twelve preparation + two preview intro + forty combat
	# + one outro + ten cards = 75. Only this fixture skips .5 s of the intro.
	game.sound.advance(0.0)
	recorder = AudioEffectRecord.new()
	recorder.format = AudioStreamWAV.FORMAT_16_BITS
	AudioServer.add_bus_effect(0, recorder)
	recorder.set_recording_active(true)
	started = Time.get_ticks_msec()
	set_process(true)
	print("AUDIO_PREVIEW_BEGIN driver=%s output=%s" % [AudioServer.output_device, path])

func _process(_delta: float) -> void:
	if finished: return
	var elapsed: float = (Time.get_ticks_msec()-started)/1000.0
	if elapsed >= 10.0 and section == 0:
		section = 1
		game.front_end.selected_section = -1
		game.front_end._begin_run()
		game.tutorial.enabled = false
		game.waves.prep_hold = false
		game.waves.set_preparation(12.0)
		game.player.max_health = 10000.0
		game.player.health = 10000.0
		print("AUDIO_PREVIEW_STAGE preparation at=%.3f" % elapsed)
	if elapsed >= 22.0 and section == 1:
		section = 2
		game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
		game.waves.advance_wave(.5)
		print("AUDIO_PREVIEW_STAGE intro at=%.3f" % elapsed)
	if elapsed >= 24.0 and section == 2:
		section = 3
		if game.waves.state == DisasterWaveManager.State.WAVE_INTRO:
			game.waves.advance_wave(game.waves.transition_remaining)
		print("AUDIO_PREVIEW_STAGE earthquake at=%.3f" % elapsed)
	if elapsed >= 64.0 and section == 3:
		section = 4
		game.waves.finish_wave()
		print("AUDIO_PREVIEW_STAGE outro at=%.3f" % elapsed)
	if elapsed >= 65.0 and section == 4:
		section = 5
		if game.waves.state == DisasterWaveManager.State.WAVE_OUTRO:
			game.waves.advance_wave(game.waves.transition_remaining)
		print("AUDIO_PREVIEW_STAGE cards at=%.3f pending=%s" % [elapsed, game.upgrades.pending])
	var second: int = int(elapsed - 24.0)
	if section == 3 and second != stage:
		stage = second
		match second:
			1: game.weather.trigger_flash(.9)
			5, 17, 27: game.sound._on_collect(LootSystem.Kind.COLUMN_KIT)
			8, 24: game.sound.play_at("repair", game.player.global_position)
			12: game.player.take_damage(30.0)
			20: game.sound.play_at("impact_metal", game.player.global_position)
			30: game.player.health = 2800.0
			34: game.sound._on_collect(LootSystem.Kind.EMERGENCY_BAG)
	Input.action_press("cover") if game.tremor.busy() else Input.action_release("cover")
	if elapsed >= 75.0: _finish()

func _finish() -> void:
	finished = true
	set_process(false)
	Input.action_release("cover")
	recorder.set_recording_active(false)
	var wav: AudioStreamWAV = recorder.get_recording()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var result: Error = wav.save_to_wav(path) if wav != null else ERR_CANT_CREATE
	var energy: float = 0.0
	var peak: float = 0.0
	if wav != null:
		var bytes: PackedByteArray = wav.data
		for i: int in range(0,bytes.size(),2):
			var value: float = bytes.decode_s16(i)/32768.0
			energy += value*value
			peak = maxf(peak,absf(value))
		energy = sqrt(energy/maxi(1,bytes.size()/2))
	print("AUDIO_PREVIEW_RESULT error=%d duration=%.3f rms=%.6f peak=%.6f path=%s" % [result, wav.get_length() if wav != null else 0.0, energy, peak, path])
	var bed: MusicDirector.Track = game.sound.director.tracks["bed"]
	print("AUDIO_PREVIEW_FLOW tremor=%d safe=%d bed_starts=%d bed_wraps=%d failed=%s cards=%s" % [game.sound.plays("tremor"), game.sound.plays("safe"), bed.starts, bed.wraps, game.waves.failed, game.upgrades.pending])
	for i: int in range(AudioServer.get_bus_effect_count(0)-1,-1,-1):
		if AudioServer.get_bus_effect(0,i) == recorder: AudioServer.remove_bus_effect(0,i)
	recorder = null
	wav = null
	SiegeFrontEnd._finish_exit(game, get_tree())
