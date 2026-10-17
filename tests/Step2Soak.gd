extends SceneTree
## Full 50-second fights at 60 simulated physics ticks/sec, not skipped phase timers.
## --headless --fixed-fps 60 disables wall-clock waiting without increasing delta.

var _failures: int = 0
var _types: Dictionary = {}
var _modes: Array[int] = []
var _bad_warning: int = 0
var _game: MainGame

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	_game.intro_enabled = false
	root.add_child(_game)
	_game.player.max_health = 10000
	_game.player.health = 10000
	_game.waves.attack_launched.connect(Callable(self, "_on_attack"))
	_game.waves.phase_changed.connect(Callable(self, "_on_phase"))
	var ticks: int = 0
	var max_alerts: int = 0
	var repairs: int = 0
	var supplies_collected: int = 0
	var phase_ticks: Dictionary = {}
	while not _game.waves.victory and not _game.waves.failed and ticks < 32000:
		var phase: int = _game.waves.state
		phase_ticks[phase] = int(phase_ticks.get(phase,0)) + 1
		max_alerts = maxi(max_alerts,_game.building.repair_count())
		if _game.upgrades.pending:
			_game.upgrades.offers.assign([_game.waves.completed_waves-1,3,4])
			_game.upgrades.choose(0)
		# Integration driver, not a human playability claim: collect actual drops
		# and walk the repair API using only earned cement. HP enlarged to isolate
		# scheduling/structure from the separate player collision tests.
		for i: int in range(_game.loot.items.size()-1,-1,-1):
			if float(_game.loot.items[i]["drop"]) >= 1.0 and float(_game.loot.items[i]["ground_age"]) > 1.0:
				_game.loot.collect(i)
				supplies_collected += 1
		if ticks % 300 == 0 and _game.loot.column_kits > 0 and phase == DisasterWaveManager.State.SIEGE_PHASE:
			var target: RoomDiorama = null
			for room: RoomDiorama in _game.building.rooms:
				if room.needs_repair() and (target == null or room.hp < target.hp): target = room
			if target != null:
				_game.player.current_floor = target.floor_index
				_game.player.global_position = target.global_position + Vector2(200,199.5)
				if _game.loot.repair_current_room() == LootSystem.RepairResult.REPAIRED: repairs += 1
		await physics_frame
		ticks += 1
	_report_rooms("after full campaign")
	_check(_modes == [0,1,2,3], "Campaign runs storm, quake, flood and three-disaster finale exactly once")
	_check(_game.waves.completed_waves == 4 and _game.waves.victory and not _game.waves.failed, "All four full 50-second battles complete with earned-resource repairs")
	_check(max_alerts <= 3, "Real attack scheduling never exceeds three simultaneous repair alerts")
	_check(abs(int(phase_ticks.get(DisasterWaveManager.State.SIEGE_PHASE,0))-12000) <= 3, "Four battles contain exactly 200 seconds of simulated fight time")
	_check(abs(int(phase_ticks.get(DisasterWaveManager.State.BUILD_PREPARATION_PHASE,0))-900) <= 3, "Three construction windows contain 15 seconds total")
	_check(_game.building.integrity < 100 and _game.building.integrity > 0 and repairs > 0, "Visible wear is managed with real collected supplies")
	print("SOAK_DRIVER ticks=%d repairs=%d collected=%d max_alerts=%d phases=%s" % [ticks,repairs,supplies_collected,max_alerts,phase_ticks])
	var fire_free: bool = true
	for kind: int in [HazardAttack.Kind.FIREBALL,HazardAttack.Kind.FIRE_DART,HazardAttack.Kind.FIRE_BEAM,HazardAttack.Kind.FIRE_ZONE,HazardAttack.Kind.LOW_FLAME,HazardAttack.Kind.METEOR]: fire_free = fire_free and not _types.has(kind)
	_check(fire_free and _types.has(HazardAttack.Kind.FLOOD_ZONE) and _types.has(HazardAttack.Kind.SHOCKWAVE) and _types.has(HazardAttack.Kind.WIND_ORB), "Whole real campaign contains all three disaster elements and no fire/meteor attacks")
	_check(_bad_warning == 0, "Every actual wave projectile was telegraphed for the required interval")
	_check(_game.projectiles.get_child_count() == 128 and _game.projectiles.peak_active < 128, "Long fights keep the fixed pool bounded with spare capacity")
	_check(_game.projectiles.rejected_count == 0, "Normal scheduling never exhausts the pool")
	_check(_game.projectiles.active_count() == 0 and _game.telegraphs.pending.is_empty(), "Chaos completion clears active and pending hazards")
	print("SOAK_STATS launches=%d peak=%d kinds=%d integrity=%.1f" % [_game.projectiles.spawn_count, _game.projectiles.peak_active, _types.size(), _game.building.integrity])
	print("STEP2_SOAK failures=%d" % _failures)
	_game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if _failures == 0 else 1)

## Scripted integration driver: how worn are the 16 rooms?
func _report_rooms(label: String) -> void:
	var states: Array[int] = [0, 0, 0, 0, 0]
	var lowest: float = 100.0
	var hp: Array[String] = []
	for room: RoomDiorama in _game.building.rooms:
		states[room.state()] += 1
		lowest = minf(lowest, room.hp)
		hp.append("%d" % roundi(room.hp))
	print("SOAK_ROOMS %s integrity=%.1f intact=%d damaged=%d critical=%d collapsed=%d lowest=%.1f hp=[%s]" % [label, _game.building.integrity, states[1], states[2], states[3], states[4], lowest, ",".join(hp)])

func _on_attack(attack: HazardAttack) -> void:
	_types[attack.kind] = true
	var required: float = attack.minimum_warning()
	# Compare to the actual frozen duration, including final +.2 and radar +.25.
	if not attack.is_armed() or attack.warning_elapsed < required - 0.00001 or attack.warning_elapsed > attack.warning_duration + 0.017:
		_bad_warning += 1

func _on_phase() -> void:
	if _game.waves.state == DisasterWaveManager.State.SIEGE_PHASE:
		_modes.append(_game.waves.mode)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS " + message)
	else:
		_failures += 1
		push_error("FAIL " + message)
