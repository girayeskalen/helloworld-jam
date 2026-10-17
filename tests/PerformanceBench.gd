extends SceneTree
## Same native scene/workload before and after optimisation; uncapped rendering.
## No wall-clock FPS assertions: GPU, desktop compositor and driver affect results.
var game: MainGame
var capture_dir: String = ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(1920,1080)
	root.unfocusable = true
	root.mouse_passthrough = true
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture_dir = arg.trim_prefix("--capture=")
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	game.sound.bake_all_now()
	game.player.set_physics_process(false)
	game.loot.set_physics_process(false)
	game.mechanics.set_physics_process(false)
	game.telegraphs.set_physics_process(false)
	game.projectiles.set_physics_process(false)
	await _measure("preparation")
	game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM,true)
	game.waves.advance_wave(game.waves.intro_duration())
	for i: int in range(3): game.building.rooms[i].apply_damage(42)
	for i: int in range(64):
		var f: int = i % 4
		var a: HazardAttack = game.waves._attack(HazardAttack.Kind.WIND_ORB if i % 2 == 0 else HazardAttack.Kind.WATER_SHARD, f, Vector2(game.building.interior_left()+60+(i/4)*92,game.building.floor_y(f)-90),Vector2.ZERO)
		a.source = 0 if i % 2 == 0 else 2
		a.lifetime = 10000
		a.motion = HazardAttack.Motion.WAVE
		a.amplitude = 30
		a.warning_id = i+1
		a.warning_confirmed = true
		a.warning_elapsed = 1
		a.warning_duration = .65
		game.projectiles.spawn(a)
	for i: int in range(24):
		var a: HazardAttack = game.waves._attack(HazardAttack.Kind.GLASS,i%4,Vector2(game.building.interior_left(),game.building.floor_y(i%4)-50-i*3),Vector2(400,0))
		game.telegraphs.warn(a,.65)
	await _measure("final_64shots_24warnings")
	if OS.get_cmdline_user_args().has("--live"):
		game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM,true)
		game.waves.advance_wave(game.waves.intro_duration())
		game.waves.autoplay = true
		game.player.max_health = 10000
		game.player.health = 10000
		game.projectiles.set_physics_process(true)
		game.telegraphs.set_physics_process(true)
		await _measure("live_final",false)
		game.waves.siege_remaining = 15
		await _measure("live_nova",false)
	if OS.get_cmdline_user_args().has("--breakdown"):
		game.telegraphs.hide()
		await _measure("final_64shots_without_warnings")
		game.titan.hide()
		await _measure("64shots_without_boss")
	game.queue_free()
	await process_frame
	await process_frame
	OS.delay_msec(80)
	quit()

func _measure(label: String, drive_shots: bool = true) -> void:
	var times: Array[float] = []
	var processes: float = 0
	var draws: float = 0
	var primitives: float = 0
	var started: int = Time.get_ticks_usec()
	var previous: int = started
	var n: int = 0
	while Time.get_ticks_usec()-started < 5000000:
		if drive_shots:
			for shot: HazardProjectile in game.projectiles.entries:
				if shot.active: shot.advance(1.0/60.0)
		await process_frame
		var now: int = Time.get_ticks_usec()
		if now-started > 1000000:
			times.append((now-previous)/1000.0)
			processes += Performance.get_monitor(Performance.TIME_PROCESS)*1000
			draws += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			primitives += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
			n += 1
		previous = now
	var total: float = 0
	for t: float in times: total += t
	times.sort()
	print("PERF_BENCH ",JSON.stringify({"scenario":label,"engine":Engine.get_version_info().string,"frames":n,"mean_ms":total/maxi(1,n),"p95_ms":times[int(times.size()*.95)],"fps":1000.0/(total/maxi(1,n)),"process_ms":processes/maxi(1,n),"draw_calls":draws/maxi(1,n),"primitives":primitives/maxi(1,n)}))
	if capture_dir != "" and DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute(capture_dir)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
