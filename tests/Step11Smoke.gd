extends SceneTree
## Presentation-only success moments, hitstop cleanup, bounded pools and PCM layer.
var game: MainGame
var checks: int = 0
var failures: int = 0
var captures: String = ""

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): captures = argument.trim_prefix("--capture=")
	if captures != "" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920, 1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(8)
	for node: Node in [game.player, game.loot, game.mechanics, game.preparedness, game.tutorial, game.projectiles, game.telegraphs]: node.set_physics_process(false)
	for node: Node in [game.hud, game.labels, game.feel_fx, game.upgrade_overlay, game.sound]: node.set_process(false)
	game.sound.bake_all_now()
	_check(not game.hitstop_enabled and game.feel_fx.get_parent() == game.world_viewport and game.feel_fx.z_index == 7, "Bare scene keeps hitstop off; FeelFX uses the existing pixelated world")
	await _tasks()
	await _repairs()
	await _safe()
	await _hits()
	await _loot()
	await _karne()
	_music()
	# A scene freed during a stop must never leave the next scene slowed down.
	Engine.time_scale = .05
	game.queue_free()
	await _frames(3)
	_check(Engine.time_scale == 1.0, "Scene exit forces normal time scale")
	print("STEP11_RESULT checks=%d failures=%d" % [checks, failures])
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _battle(mode: int = DisasterWaveManager.Mode.STORM) -> void:
	game.hitstop_enabled = false
	game.reset_game()
	game.waves.start_siege(mode as DisasterWaveManager.Mode, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false
	game.tremor.next_left = 999.0
	game.telegraphs.clear()
	game.projectiles.clear()

func _place(room: RoomDiorama) -> void:
	game.player.current_floor = room.floor_index
	game.player.global_position = room.global_position + Vector2(room.room_size.x * .5, room.room_size.y - 20.5)
	game.player.velocity = Vector2.ZERO

func _tasks() -> void:
	game.reset_game()
	var task: Dictionary = game.preparedness.pending()[0]
	var point: Vector2 = game.preparedness.marker(task)
	game.preparedness.complete(task)
	game.tutorial.advance(0)
	_check(game.feel_fx.task_bursts.size() == 1 and game.feel_fx.task_bursts[0]["point"] == point and game.hud.objective_pulse == .5, "A real completed task creates one burst and a half-second objective tick")
	game.feel_fx.advance(.12)
	game.hud.advance_feel(.12)
	await _save("task-success.png")
	for remaining: Dictionary in game.preparedness.pending(): game.preparedness.complete(remaining)
	game.tutorial.advance(0)
	_check(game.hud.objective_pulse == .8 and game.tutorial.objective_text == "Hazırsın", "Finishing all tasks gives the longer ready pulse without new text")
	for index: int in range(30): game.feel_fx.task_burst(point, UIStyle.SAFE)
	_check(game.feel_fx.task_bursts.size() == FeelFX.LIMIT, "Task burst pool discards oldest entries at eight")
	game.feel_fx.advance(.61)
	_check(game.feel_fx.task_bursts.is_empty(), "Task rays and pop ticks expire without new nodes")

func _repairs() -> void:
	_battle()
	var room: RoomDiorama = game.building.rooms[6]
	_place(room)
	room.apply_damage(45)
	game.loot.column_kits = 1
	_check(game.loot.repair_current_room() == LootSystem.RepairResult.REPAIRED and game.labels.recovery_frames.size() == 1 and game.feel_fx.repair_pluses.size() == 1, "Column repair crosses the damaged boundary and creates exactly one green frame and plus burst")
	game.labels.advance_feel(.12)
	game.feel_fx.advance(.12)
	await _save("room-recovered.png")
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.AUTO_DRONE)
	game.building.rooms[7].apply_damage(45)
	game.mechanics.drone_clock = 0.0
	game.mechanics.advance(.01, .01)
	_check(game.labels.recovery_frames.size() == 2, "Real drone repair uses the same room-state recovery signal")
	game.upgrades.apply_upgrade(SiegeUpgrades.Kind.REMOTE_CRANE)
	game.building.rooms[8].apply_damage(45)
	game.building.rooms[9].apply_damage(45)
	game.loot.column_kits = 1
	_check(game.mechanics.remote_repair() and game.labels.recovery_frames.size() == 4, "Remote crane repair marks both recovered rooms")
	var count: int = game.labels.recovery_frames.size()
	game.building.rooms[0].reinforce(RoomDiorama.Reinforcement.SHUTTER)
	_check(game.labels.recovery_frames.size() == count, "An intact-room installation does not masquerade as a repair")
	game.building.rooms[10].apply_damage(65)
	game.building.rooms[10].repair(5)
	_check(game.labels.recovery_frames.size() == count, "Critical-to-damaged or partial repairs do not mark a fully recovered room")
	await _rendered()
	var revisions: Array[int] = []
	for item: RoomDiorama in game.building.rooms: revisions.append(item.static_revision)
	var nodes: int = game.world_viewport.get_child_count()
	game.feel_fx.task_burst(room.global_position + Vector2(200, 80), UIStyle.SAFE)
	game.tremor.debris.emit(true)
	for tick: int in range(10): game.feel_fx.advance(.02)
	await _rendered()
	var same: bool = nodes == game.world_viewport.get_child_count()
	for index: int in range(revisions.size()): same = same and revisions[index] == game.building.rooms[index].static_revision
	_check(same, "Visual success animation neither allocates world nodes nor dirties room caches")
	game.labels.advance_feel(.8)
	game.feel_fx.advance(.7)
	_check(game.labels.recovery_frames.is_empty() and game.feel_fx.repair_pluses.is_empty(), "Recovery frame and plus groups expire after .7/.6 seconds")
	game.reset_game()
	_check(game.labels.recovery_frames.is_empty() and game.feel_fx.repair_pluses.is_empty(), "Full reset does not produce false repair celebrations")

func _safe() -> void:
	_battle(DisasterWaveManager.Mode.EARTHQUAKE)
	game.sound.advance(1)
	var before: int = game.sound.plays("safe")
	game.tremor.debris.emit(false)
	_check(game.feel_fx.safe_rings.is_empty() and game.sound.plays("safe") == before, "Uncovered tremor debris gives no green safety feedback")
	game.sound.advance(.4)
	game.player.covering = true
	game.player.queue_redraw()
	game.tremor.debris.emit(true)
	_check(game.feel_fx.safe_rings.size() == 1 and game.sound.plays("safe") == before + 1, "Covered debris gives one safety ring and warm chime")
	var impact: Dictionary = game.sound.history[-2]
	_check(impact["key"] == "impact_stone" and impact["volume_db"] == SoundManager.MIX["impact_stone"][0] + 3.0, "Correct cover lowers the debris impact by three dB")
	game.feel_fx.advance(.1)
	await _save("safe-cover.png")
	for tick: int in range(30): game.tremor.debris.emit(true)
	_check(game.feel_fx.safe_rings.size() == FeelFX.LIMIT, "Safety ring pool is bounded at eight")
	game.feel_fx.advance(.56)
	_check(game.feel_fx.safe_rings.is_empty(), "Safety ring and helmet dome finish cleanly")

func _hits() -> void:
	_battle()
	game.player.take_damage(40)
	_check(Engine.time_scale == 1 and game.hud.hit_flash == .35 and game.hud.health_shake == .35 and game.hud._shown_health == 100, "Bare scene preserves timing while a hit starts edge flash, shake and lost-health trail")
	game.hud.advance_feel(.1)
	_check(game.hud._shown_health == 100, "White lost-health trail waits the first .12 seconds")
	game.hud.advance_feel(.1)
	_check(absf(game.hud._shown_health - 90.4) < .01, "Lost health then drains at 120 HP per second")
	await _save("hit-edge-health-trail.png")
	_check(game.hud.vignette_alpha > 0 and game.hud.vignette_alpha <= .45, "Six-band hit vignette remains bounded")
	game.player.health = 75
	game.hud.advance_feel(.01)
	_check(game.hud.heal_flash == .4 and game.hud._shown_health == 75, "A real health increase gives green segment feedback")
	game.player.health = 20
	game.hud.hit_flash = 0
	await _rendered()
	_check(game.hud.vignette_alpha >= .06 and game.hud.vignette_alpha <= .14, "Low health gives a gentle persistent edge pulse")
	_battle()
	game.hitstop_enabled = true
	game.player.take_damage(5)
	_check(game.hitstop_active and is_equal_approx(Engine.time_scale, .05), "Enabled nonlethal siege hit starts the short stop")
	var token: int = game._hitstop_generation
	game.hit_stop()
	_check(game._hitstop_generation == token, "No second hitstop begins while one is active")
	await create_timer(.09, true, false, true).timeout
	_check(not game.hitstop_active and Engine.time_scale == 1, "Ignore-time-scale timer restores normal speed after the stop")
	game.hit_stop()
	_check(Engine.time_scale == 1, "The .3 second real-time cooldown prevents immediate retrigger")
	# A real-time cooldown is intentionally measured on the OS clock, not fixed FPS.
	OS.delay_msec(310)
	game.hit_stop()
	_check(game.hitstop_active, "A new stop is allowed after .3 real seconds")
	game.pause_menu.set_open(true)
	_check(Engine.time_scale == 1 and not game.hitstop_active, "Opening pause cancels the stop")
	game.hit_stop()
	_check(Engine.time_scale == 1, "Paused gameplay cannot start a stop")
	game.pause_menu.set_open(false)
	game.reset_game()
	_check(Engine.time_scale == 1 and not game.hitstop_active, "New game cancels any outstanding timer")
	for action: String in ["reset", "fail", "finish", "collapse"]:
		_battle()
		game.hitstop_enabled = true
		game._hitstop_last_usec = -300000
		game.hit_stop()
		_check(game.hitstop_active, "Cleanup test starts a stop before " + action)
		match action:
			"reset": game.reset_game()
			"fail": game.waves.fail_siege()
			"finish": game.waves.finish_wave()
			"collapse": game.waves.collapse_building()
		_check(Engine.time_scale == 1 and not game.hitstop_active, action + " forces time scale one")
	_battle()
	game.hitstop_enabled = true
	game._hitstop_last_usec = -300000
	game.player.take_damage(1000)
	_check(game.waves.failed and Engine.time_scale == 1 and not game.hitstop_active, "A lethal hit goes straight to defeat without hitstop")
	await create_timer(.1, true, false, true).timeout
	_check(Engine.time_scale == 1, "Cancelled timers cannot revive or extend a stop after defeat")

func _loot() -> void:
	_battle()
	for kind: int in range(4):
		game.hud.reset_feel()
		game.loot.spawn(kind, 8)
		var position: Vector2 = game.loot.item_draw_position(game.loot.items[-1])
		game.loot.collect(game.loot.items.size() - 1)
		_check(game.hud.flying_icons.size() == 1, "Pickup signal creates a flight for equipment kind %d" % kind)
		var data: Dictionary = game.hud.flying_icons[0]
		var slot: int = GameHUD.SLOT_KINDS.find(kind)
		var target: Vector2 = game.hud.slot_rect(slot).get_center() if slot >= 0 else GameHUD.HEALTH_ORIGIN + Vector2(113.5, 5)
		_check(data["start"].is_equal_approx(game.world_to_screen(position)) and data["target"] == target, "Equipment flight uses the actual world pickup and correct HUD target")
		game.hud.advance_feel(.25)
		_check(slot < 0 or game.hud._slot_flash[slot] == 0, "A collected kit waits for arrival before its slot flashes")
		if kind == LootSystem.Kind.COLUMN_KIT:
			var expected: Vector2 = Vector2(data["start"]) * .25 + Vector2(data["control"]) * .5 + target * .25
			_check(GameHUD.flight_position(data).is_equal_approx(expected), "Halfway flight lies on the lifted quadratic Bezier")
			await _save("pickup-flight.png")
		game.hud.advance_feel(.25)
		_check(game.hud.flying_icons.is_empty(), "Equipment flight expires exactly at .5 seconds")
		_check(game.hud._slot_bounce[slot] == .28 and game.hud._slot_flash[slot] == .45 if slot >= 0 else game.hud.heal_flash == .4, "Arrival pops and flashes the slot, or lights the health bar")
	game.hud.reset_feel()
	game.loot.column_kits += 1
	game.hud.advance_feel(.01)
	_check(game.hud._slot_flash[0] > 0, "Non-pickup inventory gains retain the old immediate flash")
	for index: int in range(20): game.loot.picked_up.emit(LootSystem.Kind.COLUMN_KIT, game.player.global_position)
	_check(game.hud.flying_icons.size() == GameHUD.FLIGHT_LIMIT, "Flying icons discard the oldest at a fixed six")
	game.reset_game()
	_check(game.hud.flying_icons.is_empty(), "New game clears old flying icons")

func _karne() -> void:
	_battle()
	game.waves.finish_wave()
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	var overlay: UpgradeOverlay = game.upgrade_overlay
	var rows: Array[Dictionary] = [{"ok": true, "fact": "Eşyalar sabitti", "tip": ""}, {"ok": false, "fact": "Gaz kaçağı oldu", "tip": "Gazı kapat."}, {"ok": true, "fact": "Afet çantan işe yaradı", "tip": ""}]
	overlay.karne_rows = rows
	overlay.karne_reveal.reset()
	game.sound.advance(1)
	var ok_before: int = game.sound.plays("karne_ok")
	var miss_before: int = game.sound.plays("karne_miss")
	overlay._process(.19)
	_check(overlay.karne_revealed == 0 and is_equal_approx(overlay.modulate.a, smoothstep(0, 1, .19 / .3)), "Karne delay does not change the existing card fade")
	overlay._process(.02)
	_check(overlay.karne_revealed == 1 and game.sound.plays("karne_ok") == ok_before + 1, "First karne row starts after .2 seconds with its positive sound")
	game.sound.advance(.22)
	overlay._process(.22)
	_check(overlay.karne_revealed == 2 and game.sound.plays("karne_miss") == miss_before + 1, "Second row starts .22 seconds later with the gentle missing sound")
	if captures != "": overlay._process(.08) # Capture the second row halfway through its slide.
	await _save("karne-partial.png")
	_check(overlay.karne_texts.has("Eşyalar sabitti") and overlay.karne_texts.has("Afet çantan işe yaradı"), "Karne metadata preserves all expected text even while later rows are hidden")
	game.sound.advance(.22)
	overlay._process(.22)
	_check(overlay.karne_revealed == 3 and game.sound.plays("karne_ok") == ok_before + 2 and overlay.modulate.a == 1, "Third row and unchanged full card opacity complete the stagger")
	game.upgrades.choose(0)
	game.waves.start_next_wave()
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.fail_siege()
	game.hud.advance_feel(0)
	var actual: Array[Dictionary] = Debrief.rows(game, game.waves.mode)
	_check(game.hud.karne_revealed == 0 and game.hud.outcome_reveal.hint_progress(actual.size()) == 0, "Defeat begins with an unrevealed karne and last-place hint")
	for index: int in range(actual.size()):
		game.sound.advance(.23)
		game.hud.advance_feel(.2 if index == 0 else .22)
		_check(game.hud.karne_revealed == index + 1 and game.sound.history.back()["key"] == ("karne_ok" if actual[index]["ok"] else "karne_miss"), "Defeat karne reveals its next row with the correct sound")
	await _rendered()
	_check(game.hud.drawn_texts[0] == "Yaralandın" and game.hud.drawn_texts[-1] == "R  Bölümü tekrar dene", "Defeat title-karne-hint metadata order stays unchanged")
	game.hud.advance_feel(.5)
	_check(game.hud.outcome_reveal.hint_progress(actual.size()) == 1, "The retry hint becomes visible after the last row")
	game.reset_game()
	game.waves.victory = true
	game.hud.advance_feel(.3)
	_check(game.hud.outcome_reveal.clock == .3 and game.hud.karne_revealed == mini(1, Debrief.rows(game, game.waves.mode).size()), "Survival outcome uses the same real-time reveal sequence")

func _music() -> void:
	_battle()
	var sound: SoundManager = game.sound
	var wav: AudioStreamWAV = sound.score.stems["climax"] as AudioStreamWAV
	_check(wav != null and wav.mix_rate == 22050 and wav.format == AudioStreamWAV.FORMAT_16_BITS and not wav.stereo and wav.loop_end == MusicScore.SAMPLE_COUNT and wav.loop_mode == AudioStreamWAV.LOOP_FORWARD and is_equal_approx(wav.get_length(), 16), "Layer matches the base loop format, grid, length and sample-count seam")
	_check(sound.bgm_player.playing and sound.bgm_player.bus == "Music" and sound.bgm_player.process_mode == Node.PROCESS_MODE_ALWAYS and sound.score.stream.stream_count == 5, "Five stems share the same always-processing Music player")
	var samples: PackedFloat32Array = SoundSynth.from_pcm16(wav.data)
	var peak: float = 0
	var dc: float = 0
	var energy: float = 0
	var jump: float = 0
	for index: int in range(samples.size()):
		peak = maxf(peak, absf(samples[index]))
		dc += samples[index]
		energy += samples[index] * samples[index]
		if index > 0: jump = maxf(jump, absf(samples[index] - samples[index - 1]))
	print("LAYER_PCM peak=%.5f dc=%.7f rms=%.5f max_jump=%.5f bake_ms=%.1f" % [peak, dc / samples.size(), sqrt(energy / samples.size()), jump, MusicScore.layer_bake_usec / 1000.0])
	_check(peak <= .6 and sqrt(energy / samples.size()) > .02 and absf(dc / samples.size()) < .003, "Layer has audible energy, bounded peak and negligible DC")
	_check(absf(samples[-1] - samples[0]) < .003 and jump < .2, "Layer starts/ends silently and contains no sample discontinuity")
	var id: int = wav.get_instance_id()
	var count: int = MusicScore.layer_bake_count
	_check(count == 1 and MusicScore.make_layer_stream().data == wav.data and MusicScore.layer_bake_count == count, "Layer PCM is generated exactly once and shared on later requests")
	for index: int in range(120): sound.advance(1.0 / 60.0)
	_check(sound.score.stems["climax"].get_instance_id() == id and MusicScore.layer_bake_count == count and float(sound.score.levels["climax"]) == -60, "Warm-up frames neither regenerate nor expose the extra layer")
	game.waves.siege_remaining = 10
	sound.score.transport = 1.9
	sound.advance(.1)
	_check(float(sound.score.levels["climax"]) > -60 and float(sound.score.levels["climax"]) < -8, "Layer begins a smooth fade at the next bar")
	sound.advance(2.8)
	_check(float(sound.score.levels["climax"]) == -8 and sound.score.stream == sound.bgm_player.stream, "Climax/last ten seconds bring the synchronized layer to minus eight dB")
	game.waves.fail_siege()
	sound.advance(2.8)
	_check(float(sound.score.levels["climax"]) == -60 and sound.bgm_player.playing, "Defeat fades the layer without stopping the clock")
	_battle(DisasterWaveManager.Mode.CATACLYSM)
	game.waves.nova = true
	sound.advance(2.8)
	_check(float(sound.score.levels["climax"]) == -8 and sound.bgm_player.volume_db == MusicDirector.SILENT and sound.director.tracks["final"].level.db == MusicDirector.NOVA_DB, "Final nova preserves the adaptive clock but exclusively exposes Urgent at minus eight dB")
	sound.bgm_player.stop()
	sound.advance(0)
	_check(sound.bgm_player.playing and sound.score.stream.stream_count == 5 and sound.score.transport == 0.0, "BGM watchdog restarts all synchronized stems together")
	sound.toggle_mute()
	_check(AudioServer.is_bus_mute(0) and sound.bgm_player.bus == "Music", "Master mute affects both synchronized players")
	sound.toggle_mute()
	game.reset_game()
	sound.advance(2.8)
	_check(float(sound.score.levels["climax"]) == -60 and MusicScore.layer_bake_count == count, "New game returns to the quiet layer without a rebake")

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _rendered() -> void:
	game.hud.queue_redraw()
	game.labels.queue_redraw()
	game.feel_fx.queue_redraw()
	game.upgrade_overlay.queue_redraw()
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	await _rendered()
	if captures == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(captures)
	var frame: Image = root.get_texture().get_image()
	_check(frame.get_size() == Vector2i(1920, 1080) and frame.save_png(captures.path_join(name)) == OK, "Native success-moment capture " + name)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)
