extends SceneTree
## Rendering cache invalidation, actual loop playback, final-only tuning and paths.
var game: MainGame
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	root.unfocusable = true
	root.mouse_passthrough = true
	for node: Node in [game.player,game.waves,game.loot,game.mechanics,game.projectiles,game.telegraphs]: node.set_physics_process(false)
	await _frames(5)
	await _caches()
	_pool_and_weather()
	_tuning()
	await _bgm()
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--audio-live": await _live_audio()
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP6_RESULT checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await _frames(2)
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _caches() -> void:
	var revisions: Array[int] = []
	for room: RoomDiorama in game.building.rooms: revisions.append(room.static_revision)
	var furniture: BuildingProp = game.building.rooms[0].props()[0]
	var furniture_revision: int = furniture.static_revision
	var node_count: int = get_node_count()
	await _frames(90)
	var unchanged: bool = true
	for i: int in range(16): unchanged = unchanged and game.building.rooms[i].static_revision == revisions[i]
	_check(unchanged and furniture.static_revision == furniture_revision,"Ninety idle frames do not redraw any room or static furniture")
	_check(get_node_count() == node_count,"Steady rendering does not allocate more scene nodes")
	var room: RoomDiorama = game.building.rooms[0]
	room.apply_damage(40)
	await _frames(3)
	_check(room.static_revision == revisions[0]+1 and game.building.rooms[1].static_revision == revisions[1],"Damage crossing a health tier invalidates only the changed room")
	var damaged_revision: int = room.static_revision
	room.apply_damage(.2)
	await _frames(3)
	_check(room.static_revision == damaged_revision,"Damage within the same visual tier retains heavy wall geometry")
	room.repair(100,true)
	await _frames(3)
	_check(room.static_revision == damaged_revision+1 and room._supports != null and room.reinforcement_level == 3,"Repair and retrofit refresh the room and independent static braces")
	var prop_revision: int = furniture.static_revision
	furniture.condition = BuildingProp.Condition.DAMAGED
	await _frames(3)
	_check(furniture.static_revision == prop_revision+1,"Furniture condition invalidates its own cached silhouette")
	var lamp: BuildingProp
	for p: BuildingProp in game.building.props:
		if p.kind == BuildingProp.Kind.LAMP: lamp = p; break
	var lamp_revision: int = lamp.static_revision
	game.building.lighting.tremor = 1
	game.building.lighting.advance(.15)
	await _frames(3)
	_check(lamp.static_revision == lamp_revision,"Lamp pendulum motion does not rebake lamp or room artwork")
	furniture.condition = BuildingProp.Condition.UNSECURED
	furniture.shake_unsecured(.1)
	_check(furniture.is_processing(),"Only shaking furniture enables its process callback")
	furniture._process(.2)
	_check(not furniture.is_processing(),"Furniture disables processing immediately after its shake")
	var image: Image = Image.create(4,4,false,Image.FORMAT_RGBA8)
	image.fill(Color("f07b57"))
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	room.custom_sprite = texture
	furniture.custom_sprite = texture
	await _frames(3)
	_check((room._static_cache.get_child(0) as RoomDiorama).custom_sprite == texture and (furniture._static_cache.get_child(0) as BuildingProp).custom_sprite == texture,"Runtime sprite replacement reaches both cached painters")
	room.custom_sprite = null
	furniture.custom_sprite = null
	game.building.restore_integrity()
	await _frames(3)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var idle: bool = true
		for cache: Node in game.find_children("StaticArtCache*","SubViewport",true,false):
			if (cache as SubViewport).render_target_update_mode not in [SubViewport.UPDATE_ONCE,SubViewport.UPDATE_DISABLED]:
				idle = false
				print("CACHE_PENDING ",cache.get_path()," mode=",(cache as SubViewport).render_target_update_mode)
		# The server consumes ONCE, but the scene property can continue to read ONCE.
		# Actual frame draw calls catch accidentally persistent cache rendering.
		var calls: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		_check(idle and calls < 1000,"Static caches use one-shot updates; actual steady frame stays below 1000 draw calls (%.0f)" % calls)

func _pool_and_weather() -> void:
	var idle: bool = true
	for shot: HazardProjectile in game.projectiles.entries:
		idle = idle and not shot.active and not shot.visible and not shot.is_processing() and not shot.is_physics_processing()
		shot.advance(.1)
		idle = idle and shot._trail.is_empty()
	_check(idle,"All 128 inactive projectiles are hidden, dormant and ignore advance")
	var a: HazardAttack = game.waves._attack(HazardAttack.Kind.WIND_ORB,0,Vector2(900,900),Vector2(300,0))
	a.warning_confirmed = true
	a.warning_id = 1
	a.warning_elapsed = 1
	var p: HazardProjectile = game.projectiles.spawn(a)
	for i: int in range(20): p.advance(1.0/60.0)
	_check(p._trail.size() == 4 and p._trail_line.size() == 4 and p.body_texture != null,"Active common shots reuse prewarmed bodies and at most four trail points")
	game.projectiles.clear()
	_check(game.projectiles.get_child_count() == 128 and game.projectiles.body_textures.size() == 12,"Artwork warming (4 shapes x 3 neons) leaves the fixed 128-entry pool intact")
	var weather: NightWeather = game.weather
	_check(weather._drops.size() == 40 and weather._ash.size() == 10 and weather._rain_segments.size() == 80,"Rain and ash total fifty particles with fixed line storage")
	for i: int in range(60): weather.advance(1.0/60.0)
	_check(weather._rain_segments.size() == 80,"Weather animation retains the same preallocated segment buffer")

func _battle(mode: int) -> void:
	game.reset_game()
	game.waves.autoplay = false
	game.waves.start_siege(mode as DisasterWaveManager.Mode,true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false

func _tuning() -> void:
	_check(CataclysmPatterns.COOLDOWN_SCALE == 1.3 and CataclysmPatterns.DENSITY_SCALE == .7 and CataclysmPatterns.SPEED_SCALE == .8 and CataclysmPatterns.DAMAGE_SCALE == .7,"Final tuning uses the exact requested interval/density/speed/damage factors")
	_check(CataclysmPatterns.count(10) == 7 and CataclysmPatterns.count(16) == 11 and CataclysmPatterns.count(7) == 5,"Integer salvos round 70 percent to 7/11/5 shots")
	for motion: int in range(HazardAttack.Motion.size()):
		var raw: HazardAttack = HazardAttack.new()
		raw.motion = motion as HazardAttack.Motion
		raw.origin = Vector2(700,800)
		raw.velocity = Vector2(400,-90)
		raw.gravity = 650
		raw.amplitude = 45
		raw.spiral_start = 50
		raw.spiral_speed = 210
		raw.spiral_spin = 1.4
		raw.floor_y = 900
		raw.damage = 20
		raw.structure_damage = 2
		if raw.motion == HazardAttack.Motion.REFLECT: raw.reflect_in(Rect2(500,650,700,240))
		var tuned: HazardAttack = raw.frozen_copy()
		CataclysmPatterns.tune(tuned)
		var same_path: bool = true
		for i: int in range(11): same_path = same_path and raw.point_at(raw.lifetime*i/10.0).distance_to(tuned.point_at(tuned.lifetime*i/10.0)) < .03
		_check(same_path and is_equal_approx(tuned.lifetime,raw.lifetime/.8),"Motion %d slows twenty percent without moving its path or endpoint" % motion)
		_check(is_equal_approx(tuned.damage,14) and is_equal_approx(tuned.structure_damage,1.4),"Motion %d player and structural hit amounts lose thirty percent" % motion)
		var copy: HazardAttack = tuned.frozen_copy()
		CataclysmPatterns.tune(copy)
		_check(is_equal_approx(copy.damage,14) and copy.final_tuned and copy.warning_extension == .2,"Frozen copies preserve final tuning without applying it twice")
	for mode: int in range(4):
		_battle(mode)
		var w: DisasterWaveManager = game.waves
		w.plan_attack(w._attack(HazardAttack.Kind.GLASS,0,Vector2(600,900),Vector2(500,0)),.65)
		var a: HazardAttack = game.telegraphs.pending[0]
		_check(is_equal_approx(a.velocity.x,400 if mode == 3 else 500) and is_equal_approx(a.damage,7 if mode == 3 else 10) and is_equal_approx(a.warning_duration,.75 if mode == 3 else .55),"Only phase %d has its intended speed/damage/extra-warning settings" % (mode+1))
		_check(not a.warning_lines.is_empty(),"Frozen warning paths contain precomputed dashed line geometry")
	_battle(3)
	var w: DisasterWaveManager = game.waves
	game.telegraphs.warning_bonus = .25
	var seal: HazardAttack = w._attack(HazardAttack.Kind.SHARD,0,Vector2(700,900),Vector2(500,0))
	seal.pattern = HazardAttack.Pattern.QUADRANT_SEAL
	w.plan_attack(seal,.8)
	_check(is_equal_approx(game.telegraphs.pending[0].warning_duration,1.25),"Final extra warning stacks with radar above the old clamp")
	game.telegraphs._physics_process(1.249)
	_check(game.projectiles.active_count() == 0,"Extended seal cannot launch early")
	game.telegraphs._physics_process(.001)
	_check(game.projectiles.active_count() == 1,"Extended seal launches exactly after its full warning")
	_battle(3)
	w._marathon_clock = 0
	w.advance_wave(.01,.01)
	_check(is_equal_approx(w._marathon_clock,w.cataclysm_interval*1.3-.01*w.final_tempo()),"Final scheduler extends the actual skill interval by 1.3x (clock runs at the final tempo)")
	game.telegraphs.clear()
	var room: RoomDiorama = game.building.rooms[0]
	var zone: HazardAttack = w._attack(HazardAttack.Kind.FLOOD_ZONE,0,room.global_position,Vector2.ZERO)
	zone.area = Rect2(room.global_position,room.room_size)
	zone.source = 2
	CataclysmPatterns.tune(zone)
	var before: float = room.hp
	w._on_zone_tick(zone,1)
	_check(is_equal_approx(before-room.hp,.7),"Final area effects also apply thirty percent less room damage")
	var raw: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE,0,room.global_position,Vector2(100,0))
	var base_room_damage: float = DisasterWaveManager.room_damage(raw)
	CataclysmPatterns.tune(raw)
	_check(is_equal_approx(DisasterWaveManager.room_damage(raw),base_room_damage*.7),"Final impact damage uses the same thirty-percent building reduction")
	game.reset_game()

func _bgm() -> void:
	var sound: SoundManager = game.sound
	var wav: AudioStreamWAV = sound.score.stems["pad_bass"] as AudioStreamWAV
	_check(wav.data.size() == MusicScore.SAMPLE_COUNT*2 and wav.loop_end == MusicScore.SAMPLE_COUNT,"BGM owns an exact sample-frame loop and complete sixteen-bit payload")
	var first: int = wav.get_instance_id()
	var bytes: PackedByteArray = wav.data
	for i: int in range(120): sound.advance(1.0/60.0)
	_check(sound.score.stems["pad_bass"].get_instance_id() == first and (sound.score.stems["pad_bass"] as AudioStreamWAV).data == bytes,"Ordinary frames never regenerate, refill or replace music PCM")
	var bgm_nodes: int = 0
	for child: Node in sound.get_children():
		if child.name == "BGM": bgm_nodes += 1
	_check(bgm_nodes == 1 and sound.bgm_player.bus == "Music" and sound.bgm_player.stream is AudioStreamSynchronized,"Exactly one synchronized BGM player exists on duckable Music")
	sound.bgm_player.stop()
	sound.advance(0)
	_check(sound.bgm_player.playing and sound.bgm_restarts > 0,"Music watchdog recovers an accidental stop")
	paused = true
	await _frames(3)
	_check(sound.bgm_player.playing,"Always-processing music survives tree pause")
	paused = false

func _live_audio() -> void:
	if DisplayServer.get_name() == "headless": return
	var capture: AudioEffectCapture = AudioEffectCapture.new()
	capture.buffer_length = .5
	AudioServer.add_bus_effect(0,capture)
	var effect_index: int = AudioServer.get_bus_effect_count(0)-1
	var sound: SoundManager = game.sound
	sound.bgm_player.play(MusicScore.LENGTH-.25)
	var previous: float = sound.bgm_player.get_playback_position()
	var wraps: int = 0
	var energy: float = 0
	var count: int = 0
	var started: int = Time.get_ticks_msec()
	while Time.get_ticks_msec()-started < 17000:
		await process_frame
		var current: float = sound.bgm_player.get_playback_position()
		if current+1 < previous: wraps += 1
		previous = current
		var data: PackedVector2Array = capture.get_buffer(capture.get_frames_available())
		for frame: Vector2 in data: energy += frame.length_squared()*.5
		count += data.size()
	_check(wraps >= 2 and sound.bgm_player.playing,"Real mixer crosses two loop seams without losing playback")
	var rms: float = sqrt(energy/maxi(1,count))
	print("BGM_LIVE wraps=%d rms=%.4f dbfs=%.1f frames=%d" % [wraps,rms,linear_to_db(rms),count])
	_check(rms > .04 and rms < .5,"Actual Master output contains clear music energy with headroom")
	var at: float = sound.bgm_player.get_playback_position()
	OS.delay_msec(300)
	_check(sound.bgm_player.playing and sound.bgm_player.get_playback_position() > at+.1,"Mixer keeps playing PCM during a deliberate 300 ms game-thread stall")
	AudioServer.remove_bus_effect(0,effect_index)

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	root.size = Vector2i(1920,1080)
	game.building.rooms[0].repair(100,true)
	game.building.rooms[1].apply_damage(45)
	await _frames(5)
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(directory.path_join("cached-rooms-repair-braces.png")) == OK,"Native cached-room damage/repair/retrofit screenshot saved")

func _frames(count: int) -> void:
	for i: int in range(count): await process_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ",message)
	else:
		failures += 1
		push_error("FAIL "+message)
