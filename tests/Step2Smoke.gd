extends SceneTree

var _failures: int = 0
var _checks: int = 0
var _launch_types: Dictionary = {}
var _minimum_warning: float = 100.0
var _maximum_warning: float = 0.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: MainGame = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(3)
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
		await create_timer(0.6).timeout
	game.waves.attack_launched.connect(Callable(self, "_record_launch"))
	var waves: DisasterWaveManager = game.waves
	var pool: ProjectilePool = game.projectiles
	var player: SiegePlayer = game.player
	_check(waves.state == DisasterWaveManager.State.PREPARATION_PHASE and waves.preparation_remaining == 8, "Starts with 8-second preparation")
	_check(pool.entries.size() == 128 and pool.active_count() == 0, "128 inactive preallocated projectiles")
	var first_pool_id: int = pool.entries[0].get_instance_id()
	var unwarned: HazardAttack = HazardAttack.new()
	_check(pool.spawn(unwarned) == null, "Unwarned projectile cannot enter the pool")
	_key(KEY_F, true)
	await _frames(2)
	_key(KEY_F, false)
	waves.advance_wave(waves.intro_duration())
	waves.building.pacing_enabled = false
	_check(waves.state == DisasterWaveManager.State.SIEGE_PHASE and waves.mode == DisasterWaveManager.Mode.STORM, "Physical F skips preparation and starts storm")
	_check(game.storm.visible and not game.earthquake.visible, "Storm boss occupies left margin only")
	# Step 3 reordered the storm cycle; the fan primitive is exercised directly.
	BossPatterns.fan(waves, 0, 0)
	_check(game.telegraphs.pending.size() == 7, "Seven-shot fan is fully warned before any projectile")
	await _frames(30)
	_check(pool.active_count() == 0 and player.health == player.max_health, "Warnings do not hurt or spawn before their deadline")
	await _frames(10)
	_check(pool.active_count() == 7, "Seven-shot fan activates after warning")
	# The 4x4 facade is 1600 px wide: a 470 px/s fan needs ~3.3 s to reach the far wall.
	await _frames(210)
	_check(pool.active_count() == 0, "Projectiles return to the pool at impact")
	player.reset_player()
	BossPatterns.furniture(waves, 0)
	await _frames(45)
	_check(_launch_types.has(HazardAttack.Kind.POT) and _launch_types.has(HazardAttack.Kind.CHAIR), "Parabolic pot and oscillating chair launch")
	BossPatterns.furniture(waves, 1)
	await _frames(48)
	_check(_launch_types.has(HazardAttack.Kind.WIND_BLADE), "Sweeping wind blade launches")
	pool.clear()
	game.telegraphs.clear()
	# Clamp both ends of the warning interval and freeze the authored trajectory.
	var probe: HazardAttack = _probe(Vector2(50, 200), Vector2.ZERO, 0.15)
	game.telegraphs.warn(probe, 0.01)
	var queued: HazardAttack = game.telegraphs.pending[0]
	probe.origin = Vector2(999, 999)
	_check(queued.warning_duration == 0.55 and queued.origin == Vector2(50, 200), "Warning clamps to 0.55 seconds and freezes its path")
	await _frames(35)
	_check(pool.active_count() == 1, "Minimum warning arms normally")
	pool.clear()
	game.telegraphs.warn(_probe(Vector2(50, 200), Vector2.ZERO, 0.15), 9.0)
	_check(game.telegraphs.pending[0].warning_duration == 0.75, "Warning clamps to 0.75 seconds")
	await _frames(42)
	_check(pool.active_count() == 0, "Maximum warning is still non-damaging at 0.7 seconds")
	await _frames(6)
	_check(pool.active_count() == 1, "Maximum warning then activates")
	pool.clear()
	game.telegraphs.clear()
	# Actual contact, red feedback and one-second hurt immunity.
	player.reset_player()
	game.telegraphs.warn(_probe(player.global_position + Vector2(0, -24), Vector2.ZERO, 0.2), 0.55)
	await _frames(35)
	_check(player.health == 86, "Normal projectile contact reduces HP")
	_check(player.hit_invulnerability > 0.9 and game.hud.hit_flash > 0 and game.game_camera._remaining > 0, "Contact gives blink immunity, hit flash and camera shake")
	_check(not player.take_damage(14), "Hurt immunity blocks repeated damage")
	await _frames(30)
	_check(player.hit_invulnerability > 0 and not player.take_damage(14), "Hurt immunity survives half a second")
	await _frames(35)
	_check(player.hit_invulnerability == 0 and player.take_damage(14), "Damage becomes possible after one second")
	player.reset_player()
	pool.clear()
	# Dash through a real armed projectile, rather than merely pressing dodge nearby.
	var dodges_before: int = waves.dodge_count
	game.telegraphs.warn(_probe(player.global_position + Vector2(90, -24), Vector2.ZERO, 0.8), 0.55)
	await _frames(35)
	var dash_start_x: float = player.global_position.x
	var dash_started: bool = player.try_dash(Vector2.RIGHT)
	await _frames(7)
	_check(player.health == 100 and waves.dodge_count == dodges_before + 1, "Crossing a projectile during dash gives DODGE without damage (started=%s hp=%.0f dx=%.1f dodges=%d)" % [dash_started, player.health, player.global_position.x - dash_start_x, waves.dodge_count - dodges_before])
	_check(game.feedback.texts.size() > 0, "DODGE floating text is visible")
	await _frames(3)
	_check(waves.dodge_count == dodges_before + 1, "One projectile grants DODGE only once")
	pool.clear()
	player.reset_player()
	# A segment sweep catches crossings that endpoint-only collision would miss.
	var swept: HazardProjectile = pool.entries[0]
	swept.contacted_player = false
	swept.attack = _probe(Vector2(850, 836), Vector2.ZERO, 1)
	swept.global_position = swept.attack.origin
	player.previous_position = Vector2(700, 860)
	player.global_position = Vector2(1000, 860)
	_check(swept.crosses_player(player, swept.global_position), "Swept collision catches an entire fast crossing")
	swept.global_position.y = 600
	_check(not swept.crosses_player(player, swept.global_position), "A distant near-miss never grants DODGE")
	swept.deactivate()
	player.reset_player()
	# All new keyboard shortcuts clean up the previous fight.
	waves.debug_enabled = true
	for key: int in [KEY_1, KEY_2, KEY_3]:
		_key(key, true)
		await _frames(2)
		_key(key, false)
		var expected: int = key - KEY_1
		_check(waves.mode == expected and not waves.failed, "Boss shortcut %d changes mode" % (expected + 1))
		_check(pool.active_count() == 0 and game.telegraphs.pending.is_empty(), "Mode switch cancels obsolete hazards")
	_check(game.flood.visible and not game.storm.visible and not game.earthquake.visible, "Key 3 selects only the flood boss")
	waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	waves.advance_wave(waves.intro_duration())
	waves.building.pacing_enabled = false
	var bookcase: BuildingProp
	for prop: BuildingProp in game.building.props:
		if prop.kind == BuildingProp.Kind.BOOKCASE and prop.floor_index == 1:
			bookcase = prop
			break
	waves.quake_burst()
	_check(bookcase != null and bookcase._shake_left > 0, "Unsecured furniture trembles during quake warning")
	await _frames(46)
	_check(game.game_camera._remaining > 0 and game.earthquake._slam_left > 0, "Golem impact is synchronized to camera shake")
	await _frames(60)
	_check(game.building.integrity < 100 and game.building.integrity > 90, "Heavy debris slowly erodes building integrity")
	for kind: int in [HazardAttack.Kind.BRICK, HazardAttack.Kind.CONCRETE, HazardAttack.Kind.CHANDELIER, HazardAttack.Kind.SHOCKWAVE, HazardAttack.Kind.BOOK]:
		_check(_launch_types.has(kind), "Quake hazard type launched: %d" % kind)
	_check(_minimum_warning >= 0.55 - 0.00001 and _maximum_warning <= 0.75 + 0.017, "Every launched pattern had a full 0.55–0.75 second warning")
	waves.reset_cycle()
	player.reset_player()
	waves.advance_wave(7.9)
	_check(waves.state == DisasterWaveManager.State.PREPARATION_PHASE, "Preparation does not end early")
	waves.advance_wave(0.11)
	_check(waves.mode == DisasterWaveManager.Mode.STORM and waves.siege_remaining == 60, "Automatic first wave is a 60-second storm")
	waves.advance_wave(waves.intro_duration())
	waves.advance_wave(60.0)
	waves.advance_wave(2.5)
	_check(waves.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE and waves.upgrade_pending and game.telegraphs.pending.is_empty() and pool.active_count() == 0, "Wave completion clears attacks and returns to preparation")
	game.upgrades.offers.assign([SiegeUpgrades.Kind.DASH_REPAIR, SiegeUpgrades.Kind.AUTO_DRONE, SiegeUpgrades.Kind.SLAM_SHIELD])
	game.upgrades.choose(0 if game.upgrades.selected.is_empty() else 1)
	waves.advance_wave(15.0)
	waves.advance_wave(waves.intro_duration())
	_check(waves.mode == DisasterWaveManager.Mode.EARTHQUAKE and waves.wave_number == 2, "Second automatic wave is earthquake")
	waves.debug_enabled = true
	waves.damage_boss_endurance(100)
	waves.advance_wave(2.5)
	_check(waves.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE, "Debug endurance shortcut finishes only in explicitly enabled test mode")
	game.upgrades.offers.assign([SiegeUpgrades.Kind.DASH_REPAIR, SiegeUpgrades.Kind.AUTO_DRONE, SiegeUpgrades.Kind.SLAM_SHIELD])
	game.upgrades.choose(0 if game.upgrades.selected.is_empty() else 1)
	waves.advance_wave(15.0)
	waves.advance_wave(waves.intro_duration())
	_check(waves.mode == DisasterWaveManager.Mode.FLOOD and waves.wave_number == 3, "Third wave is flood, before the combined finale")
	# Exhaust the fixed pool, then reuse it; no combat-time node growth.
	for i: int in range(pool.capacity + 2):
		game.telegraphs.warn(_probe(Vector2(-300, -300), Vector2.ZERO, 0.4), 0.55)
	await _frames(35)
	_check(pool.active_count() == pool.capacity and pool.get_child_count() == pool.capacity, "Pool stays bounded under a saturated attack batch")
	await _frames(30)
	_check(pool.active_count() == 0 and pool.entries[0].get_instance_id() == first_pool_id, "Expired pool entries are reused, not freed or replaced")
	player.reset_player()
	player.take_damage(1000)
	_check(waves.failed and game.telegraphs.pending.is_empty() and pool.active_count() == 0, "Death ends hazards instead of continuing hidden damage")
	_key(KEY_R, true)
	await _frames(2)
	_key(KEY_R, false)
	_check(not waves.failed and player.health == 100 and game.building.integrity == 100, "R restores player, building and preparation cycle")
	_check(game.building.rooms.size() == 16 and is_equal_approx(player.run_speed, 310.0 * 1.3) and player.dash_duration == 0.25, "4x4 architecture, Step 2.7 run speed (+30%) and the 0.25 s dash window")
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await _capture(game, argument.trim_prefix("--capture="))
	print("STEP2_RESULT checks=%d failures=%d" % [_checks, _failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if _failures == 0 else 1)

func _probe(origin: Vector2, velocity: Vector2, life: float) -> HazardAttack:
	var attack: HazardAttack = HazardAttack.new()
	attack.origin = origin
	attack.velocity = velocity
	attack.lifetime = life
	attack.radius = 10
	attack.damage = 14
	return attack

func _record_launch(attack: HazardAttack) -> void:
	_launch_types[attack.kind] = true
	_minimum_warning = minf(_minimum_warning, attack.warning_elapsed)
	_maximum_warning = maxf(_maximum_warning, attack.warning_elapsed)

func _capture(game: MainGame, directory: String) -> void:
	if DisplayServer.get_name() == "headless":
		_check(false, "Screenshots need a real renderer")
		return
	DirAccess.make_dir_recursive_absolute(directory)
	game.waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.building.pacing_enabled = false
	BossPatterns.fan(game.waves, 0, 0)
	await _frames(23)
	await _save(directory, "storm-warning.png")
	await _frames(22)
	await _save(directory, "storm-projectiles.png")
	BossPatterns.furniture(game.waves, 0)
	await _frames(48)
	await _save(directory, "storm-furniture.png")
	BossPatterns.furniture(game.waves, 1)
	await _frames(52)
	await _save(directory, "storm-blade.png")
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.building.pacing_enabled = false
	game.waves.quake_burst()
	await _frames(23)
	await _save(directory, "quake-warning.png")
	await _frames(23)
	await _save(directory, "quake-slam.png")
	await _frames(20)
	await _save(directory, "quake-debris.png")
	game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.building.pacing_enabled = false
	game.waves.storm_burst()
	game.waves.quake_burst()
	await _frames(24)
	await _save(directory, "chaos-warning.png")
	await _frames(24)
	await _save(directory, "chaos.png")
	game.waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.building.pacing_enabled = false
	game.feedback.clear()
	game.telegraphs.warn(_probe(game.player.global_position + Vector2(90, -24), Vector2.ZERO, 1.0), 0.55)
	await _frames(35)
	game.player.try_dash(Vector2.RIGHT)
	await _frames(6)
	await _save(directory, "dodge.png")
	game.waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	game.waves.advance_wave(game.waves.intro_duration())
	game.waves.building.pacing_enabled = false
	game.feedback.clear()
	game.telegraphs.warn(_probe(game.player.global_position + Vector2(0, -24), Vector2.ZERO, 0.15), 0.55)
	await _frames(35)
	await _save(directory, "hit.png")
	print("CAPTURES " + directory)

func _save(directory: String, filename: String) -> void:
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png(directory.path_join(filename))
	_check(error == OK, "Rendered " + filename)

func _frames(count: int) -> void:
	for i: int in range(count):
		await physics_frame

func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		print("PASS " + message)
	else:
		_failures += 1
		push_error("FAIL " + message)
