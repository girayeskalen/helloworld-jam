class_name AdaptiveMusic
extends RefCounted
## AudioStreamSynchronized shares one playback clock/pitch across all five stems.
## State changes are committed on the next 4/4 bar; the shake is an immediate
## interruption, with drums returning on the next quarter-note after release.
const SILENT: float = -60.0
var stream: AudioStreamSynchronized
var stems: Dictionary = {}
var levels: Dictionary = {}
var targets: Dictionary = {}
var requested: Dictionary = {}
var transport: float = 0.0
var commits: Array[float] = []
var _resume_beat: bool = false
var _was_shaking: bool = false
var _result_pending: String = ""
var _result_delay: float = -1.0
var _result_seen: String = ""
var _last_mix_position: float = -1.0
var _result_completed_at: float = -100.0

func _init() -> void:
	stems = MusicScore.make_stems()
	stream = AudioStreamSynchronized.new()
	stream.stream_count = MusicScore.STEMS.size()
	for i: int in range(MusicScore.STEMS.size()):
		var key: String = MusicScore.STEMS[i]
		stream.set_sync_stream(i,stems[key])
		levels[key] = -16.0 if key == "pad_bass" else SILENT
		targets[key] = levels[key]
		stream.set_sync_stream_volume(i,levels[key])

func wanted(game: MainGame) -> Dictionary:
	var out: Dictionary = {"pad_bass":-16.0,"drums":SILENT,"lead_arp":SILENT,"climax":SILENT,"tension":SILENT}
	var w: DisasterWaveManager = game.waves
	if game.front_end != null and game.front_end.active: return out
	if w.failed or w.victory:
		for key: String in out: out[key] = SILENT
		if _result_pending == "" and _result_seen != "" and transport-_result_completed_at >= 4.0: out["pad_bass"] = -20.0
		return out
	if game.upgrades.pending or w.state == DisasterWaveManager.State.WAVE_OUTRO: return out
	if w.state != DisasterWaveManager.State.SIEGE_PHASE:
		out["pad_bass"] = -12.0
		out["tension"] = -20.0
		return out
	var elapsed: float = w.fight_elapsed()
	out["pad_bass"] = -9.0 if w.mode == DisasterWaveManager.Mode.FLOOD else -12.0
	out["drums"] = -5.0 if w.mode == DisasterWaveManager.Mode.EARTHQUAKE else -9.0
	if elapsed >= 10.0: out["lead_arp"] = -6.0 if w.mode == DisasterWaveManager.Mode.STORM else -11.0
	if elapsed >= 28.0 or w.nova: out["climax"] = -12.0
	if w.siege_remaining <= 10.0 or w.nova: out["climax"] = -8.0
	if game.player.health < game.player.max_health*.3: out["tension"] = -10.0
	return out

func advance(delta: float, game: MainGame, player: AudioStreamPlayer, shaking: bool, frozen: bool) -> String:
	var previous: float = transport
	transport += delta*player.pitch_scale
	# Native audio clock is authoritative; manual/headless tests use the same
	# grid integrated above. Hitstop must not slow a real audio mixer.
	if DisplayServer.get_name() != "headless" and player.playing and game.sound.is_processing():
		var at: float = player.get_playback_position()+AudioServer.get_time_since_last_mix()*player.pitch_scale
		if _last_mix_position >= 0.0:
			var distance: float = fposmod(at-_last_mix_position,MusicScore.LENGTH)
			if distance < .5: transport = previous+distance
		_last_mix_position = at
	requested = wanted(game)
	var result: String = "defeat" if game.waves.failed else ("victory" if game.waves.victory else "")
	if result != _result_seen:
		_result_seen = result
		_result_pending = result
		_result_delay = -1.0
	var boundary: bool = int(previous/2.0) != int(transport/2.0)
	if boundary and not frozen:
		targets = requested.duplicate()
		commits.append(floorf(transport/2.0)*2.0)
		if commits.size() > 32: commits.remove_at(0)
		if _result_pending != "": _result_delay = .6
	if _was_shaking and not shaking and game.waves.state == DisasterWaveManager.State.SIEGE_PHASE: _resume_beat = true
	if game.waves.state != DisasterWaveManager.State.SIEGE_PHASE: _resume_beat = false
	_was_shaking = shaking
	if _resume_beat and int(previous/.5) != int(transport/.5) and not frozen:
		_resume_beat = false
		targets = requested.duplicate()
		game.sound.play("slam",-6.0)
	for i: int in range(MusicScore.STEMS.size()):
		var key: String = MusicScore.STEMS[i]
		var target: float = targets[key]
		if shaking or _resume_beat:
			if key in ["drums","lead_arp","climax"]: target = SILENT
			if key == "tension": target = -10.0
		var speed: float = 500.0 if shaking and key in ["drums","lead_arp","climax"] else 100.0
		levels[key] = move_toward(levels[key],target,delta*speed)
		stream.set_sync_stream_volume(i,levels[key])
	if _result_delay >= 0.0 and not frozen:
		_result_delay -= delta
		if _result_delay <= 0.0:
			_result_delay = -1.0
			var completed: String = _result_pending
			_result_pending = ""
			_result_completed_at = transport
			return completed
	return ""
