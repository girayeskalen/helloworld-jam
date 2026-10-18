extends SceneTree
## Step 9 (18 Oct 2026, jam rubric): earthquake-first campaign, Hazırlık tasks with
## real payoffs (bolted furniture, shutters, gas, mains, bag), the tremor drill
## (Çök-Kapan-Tutun, toppling furniture, window glass, gas leaks, no stairs while
## shaking, patterns hold), the learn-by-doing tutorial, the karne and the new sounds.
## With -- --capture=DIR it also saves native 1920x1080 frames of every new screen.
var game: MainGame
var checks: int = 0
var failures: int = 0
var capture_dir: String = ""
const STEP: float = 1.0 / 60.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): capture_dir = argument.trim_prefix("--capture=")
	if capture_dir != "" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920, 1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	await _frames(20)
	# Deterministic: the test drives waves, telegraphs, preparation and the tutorial.
	for node: Node in [game.loot, game.mechanics, game.preparedness, game.tutorial, game.telegraphs, game.projectiles, game.player]:
		node.set_physics_process(false)
	game.sound.bake_all_now()
	await _campaign()
	await _preparation()
	await _bag_and_power()
	await _tremor()
	await _tremor_hazards()
	await _cover_input()
	await _tutorial()
	await _karne()
	await _polish()
	print("STEP9_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await _frames(2)
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

# -------------------------------------------------------------- helpers ----

func _battle(mode: int) -> DisasterWaveManager:
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	w.start_siege(mode as DisasterWaveManager.Mode, true)
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	game.telegraphs.clear()
	game.projectiles.clear()
	# Bullet patterns out of the way unless a check asks for them.
	w._quake_clock = 999.0
	w._storm_clock = 999.0
	w._marathon_clock = 999.0
	return w

## Drive the fight clock, telegraphs and preparation in fixed steps.
func _tick(seconds: float) -> void:
	var elapsed: float = 0.0
	while elapsed < seconds - 0.00001:
		game.waves.advance_wave(STEP)
		game.telegraphs._physics_process(STEP)
		game.preparedness.advance(STEP)
		elapsed += STEP

## Tick until `condition` holds (fails the run after `limit` seconds).
func _until(condition: Callable, limit: float = 20.0) -> bool:
	var elapsed: float = 0.0
	while not condition.call():
		if elapsed > limit:
			_check(false, "Timed out waiting for a tremor state")
			return false
		_tick(STEP)
		elapsed += STEP
	return true

func _shaking_past(seconds: float) -> bool:
	return game.tremor.active() and game.tremor.elapsed >= seconds

func _task(kind: int, prop_kind: int = -1) -> Dictionary:
	for task: Dictionary in game.preparedness.tasks:
		if int(task["kind"]) != kind: continue
		if prop_kind >= 0 and (task["prop"] == null or (task["prop"] as BuildingProp).kind != prop_kind): continue
		return task
	return {}

func _prop(kind: int) -> BuildingProp:
	for prop: BuildingProp in game.building.props:
		if prop.kind == kind: return prop
	return null

func _place(floor_index: int, x: float) -> void:
	var p: SiegePlayer = game.player
	p.current_floor = floor_index
	p.global_position = Vector2(x, game.building.floor_y(floor_index) - 0.5)
	p.velocity = Vector2.ZERO
	p.hit_invulnerability = 0.0

func _stand_at(task: Dictionary) -> void:
	_place(game.preparedness.task_floor(task), game.preparedness.anchor_x(task))

func _room(kind: int) -> RoomDiorama:
	return game.building.rooms[kind]

# ------------------------------------------------------------- campaign ----

func _campaign() -> void:
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	_check(w.boss_name() == "DEPREM" and is_equal_approx(w.preparation_total, 15.0) and not w.prep_hold, "Campaign opens with the earthquake and a 15 s preparation (tutorial off in the bare scene)")
	var order: Array[int] = []
	var build_ok: bool = true
	for step: int in range(4):
		w.start_next_wave()
		order.append(w.mode)
		build_ok = build_ok and w.wave_number == step + 1
		w.advance_wave(w.intro_duration())
		w.finish_wave()
		w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
		if game.upgrades.pending:
			build_ok = build_ok and is_equal_approx(w.preparation_total, 10.0) and w.boss_name() == ["FIRTINA", "SEL", "AFET"][step]
			game.upgrades.choose(0)
	_check(order == [DisasterWaveManager.Mode.EARTHQUAKE, DisasterWaveManager.Mode.STORM, DisasterWaveManager.Mode.FLOOD, DisasterWaveManager.Mode.CATACLYSM] and w.victory, "Campaign order: DEPREM -> FIRTINA -> SEL -> final, then survival")
	_check(build_ok, "Wave numbers follow the campaign; each later preparation is 10 s and names the next disaster")
	game.select_section(0)
	_check(w.mode == DisasterWaveManager.Mode.EARTHQUAKE and w.wave_number == 1 and w.completed_waves == 0, "Section 1 opens the earthquake (campaign step 1)")
	game.reset_game()

# ---------------------------------------------------------- preparation ----

func _preparation() -> void:
	game.reset_game()
	var prep: Preparedness = game.preparedness
	var kinds: Dictionary = {}
	for task: Dictionary in prep.pending():
		kinds[int(task["kind"])] = int(kinds.get(int(task["kind"]), 0)) + 1
	_check(kinds == {Preparedness.Task.SECURE: 4, Preparedness.Task.GAS: 1, Preparedness.Task.BAG: 1}, "First preparation: four tall pieces, the gas valve and the emergency bag (%s)" % str(kinds))
	var wardrobe: Dictionary = _task(Preparedness.Task.SECURE, BuildingProp.Kind.WARDROBE)
	var prop: BuildingProp = wardrobe["prop"]
	var room: RoomDiorama = wardrobe["room"]
	_stand_at(wardrobe)
	var plays: int = game.sound.plays("secure")
	_check(prep.in_reach() == wardrobe and prep.interact() and game.player.work_time > 0.0, "E next to the wardrobe starts the bolting animation")
	await _rendered()
	_check(game.labels.keys_drawn.has("E") and game.labels.task_markers == 6, "Task chevrons mark all six tasks; the E key shows the work in reach")
	await _save("prep-work.png")
	prep.advance(0.2)
	_check(not wardrobe["done"], "Bolting takes a short moment (0.35 s)")
	prep.advance(0.2)
	_check(wardrobe["done"] and prop.secured and prop.condition == BuildingProp.Condition.REINFORCED and game.sound.plays("secure") == plays + 1, "The wardrobe is bolted: L-brackets and a ratchet sound")
	room.apply_damage(45)
	_check(prop.condition == BuildingProp.Condition.REINFORCED and not prop.toppled and is_zero_approx(prop.tilt), "A bolted piece stays bolted and upright in a damaged room")
	room.repair(100)
	var gas: Dictionary = _task(Preparedness.Task.GAS)
	_stand_at(gas)
	game.sound.advance(1.0)
	var safety: int = game.sound.plays("safety")
	prep.interact()
	prep.advance(0.4)
	var isolated: bool = prep.gas_off and (gas["prop"] as BuildingProp).secured
	for each: RoomDiorama in game.building.rooms: isolated = isolated and each.utilities_isolated
	_check(isolated and game.sound.plays("safety") == safety + 1, "Turning off the gas isolates utilities in every room (valve tag + hiss)")
	var kitchen: RoomDiorama = _room(RoomDiorama.Kind.KITCHEN)
	kitchen.apply_damage(40)
	var before: float = kitchen.hp
	game.building.secondary_damage(1.0, 0.15)
	_check(is_equal_approx(kitchen.hp, before), "With the gas off a damaged room takes no secondary gas/electric damage")
	kitchen.repair(100)
	var bag: Dictionary = _task(Preparedness.Task.BAG)
	_stand_at(bag)
	prep.interact()
	prep.advance(0.4)
	_check(prep.bag_ready and bag["done"], "The emergency bag waits by the lobby exit and is packed with E")
	for task: Dictionary in prep.pending():
		prep.complete(task)
	_check(prep.auto_start_left > 0.0 and game.waves.state == DisasterWaveManager.State.PREPARATION_PHASE, "Every task done: the disaster comes after a short beat")
	prep.advance(1.3)
	_check(game.waves.state == DisasterWaveManager.State.WAVE_INTRO and game.waves.mode == DisasterWaveManager.Mode.EARTHQUAKE, "...and the earthquake starts early")
	game.reset_game()
	_check(not prop.secured and not prep.bag_ready and not prep.gas_off and prep.pending().size() == 6, "R resets bolts, valves and the bag")
	game.waves.completed_waves = 1
	_check(prep.pending().size() == 10 and _task(Preparedness.Task.SHUTTER) in prep.pending(), "From the second preparation four window shutters unlock")
	game.waves.completed_waves = 2
	_check(prep.pending().size() == 11 and _task(Preparedness.Task.POWER) in prep.pending(), "Before the flood the mains panel unlocks")
	var shutter: Dictionary = _task(Preparedness.Task.SHUTTER, BuildingProp.Kind.WINDOW)
	prep.complete(shutter)
	var shuttered: RoomDiorama = shutter["room"]
	_check(shuttered.has_reinforcement(RoomDiorama.Reinforcement.SHUTTER) and (shutter["prop"] as BuildingProp).condition == BuildingProp.Condition.REINFORCED and is_equal_approx(shuttered.damage_factor(0), 0.5), "A shutter halves storm damage to its room and shows on the window")
	game.reset_game()

func _bag_and_power() -> void:
	_battle(DisasterWaveManager.Mode.FLOOD)
	var prep: Preparedness = game.preparedness
	var p: SiegePlayer = game.player
	prep.complete(_task(Preparedness.Task.BAG))
	p.health = 50.0
	game.sound.advance(1.0)
	var heals: int = game.sound.plays("heal")
	p.take_damage(20.0)
	_check(is_equal_approx(p.health, 65.0) and prep.bag_spent and prep.phase_stats["bag_used"] and game.sound.plays("heal") == heals + 1, "Packed bag: first aid +35 once when health drops under 35%")
	p.hit_invulnerability = 0.0
	p.take_damage(40.0)
	_check(is_equal_approx(p.health, 25.0), "The bag helps only once per fight")
	var water: HazardAttack = game.waves._attack(HazardAttack.Kind.FLOOD_ZONE, 0, Vector2.ZERO, Vector2.ZERO)
	_check(is_equal_approx(prep.hit_factor(water), Preparedness.ELECTRIC_FACTOR), "With the mains on, flood water hurts 1.5x (electrified)")
	prep.complete(_task(Preparedness.Task.POWER))
	_check(prep.power_off and is_equal_approx(prep.hit_factor(water), 1.0), "Cutting the mains makes the water ordinary again")
	game.reset_game()

# ---------------------------------------------------------------- tremor ----

func _tremor() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.EARTHQUAKE)
	var t: TremorSystem = game.tremor
	var p: SiegePlayer = game.player
	var b: ApartmentBuilding = game.building
	var bookcase: BuildingProp = _prop(BuildingProp.Kind.BOOKCASE)
	bookcase.secured = true
	(bookcase.get_parent() as RoomDiorama)._refresh_state(true)
	var lobby: RoomDiorama = _room(RoomDiorama.Kind.LOBBY)
	_place(0, lobby.global_position.x + 250.0)
	game.sound.advance(2.0)
	var rumbles: int = game.sound.plays("tremor")
	_tick(1.9)
	_check(not t.busy(), "No tremor in the first two seconds of the quake")
	_until(func() -> bool: return t.warning())
	_check(absf(w.fight_elapsed() - TremorSystem.FIRST_DELAY) < 0.05 and is_equal_approx(game.telegraphs.tremor_warning_total, TremorSystem.WARNING) and game.sound.plays("tremor") == rumbles + 1 and not p.shaking, "The first tremor is telegraphed at 2 s, 1.0 s ahead, with a rumble")
	await _rendered()
	_check(game.labels.keys_drawn.has("C") and game.labels.tremor_edges, "During the warning the C key and an amber screen edge appear")
	await _save("tremor-warning.png")
	w._quake_clock = 0.01
	var pending: int = game.telegraphs.pending.size()
	_tick(0.5)
	_check(game.telegraphs.pending.size() == pending and is_equal_approx(w._quake_clock, 0.01), "Bullet patterns hold while a tremor is announced")
	w._quake_clock = 999.0
	_until(func() -> bool: return t.active())
	_check(p.shaking and b.tremor > 0.0, "The building shakes for 1.4 s")
	_check(not p.try_floor_shift(1) and int(t.stats["stair_attempts"]) == 1, "No floor change while shaking (and the attempt is remembered)")
	p.velocity = Vector2.ZERO
	_check(is_equal_approx(p._run_velocity(1.0, 1.0), p.run_speed * SiegePlayer.SHAKE_SPEED), "Steps are slow while the building shakes")
	var kitchen: RoomDiorama = _room(RoomDiorama.Kind.KITCHEN)
	var kitchen_before: float = kitchen.hp
	game.sound.advance(1.0)
	var crashes: int = game.sound.plays("topple")
	_until(func() -> bool: return _shaking_past(TremorSystem.TOPPLE_AT + 0.02))
	var loose: int = 0
	for prop: BuildingProp in b.props:
		if prop.kind in Preparedness.TALL_KINDS and prop.toppled: loose += 1
	_check(loose == 3 and not bookcase.toppled and int(t.stats["topples"]) == 3 and game.sound.plays("topple") >= crashes + 1, "The three loose tall pieces topple; the bolted bookcase stays")
	_check(is_equal_approx(p.health, p.max_health), "Standing clear of furniture and windows, nothing hits before the ceiling")
	_until(func() -> bool: return _shaking_past(TremorSystem.DEBRIS_AT + 0.02))
	_check(is_equal_approx(p.health, p.max_health - TremorSystem.DEBRIS_DAMAGE) and int(t.stats["debris_hits"]) == 1, "Standing through the peak: falling plaster hurts (no Çök-Kapan-Tutun)")
	_until(func() -> bool: return not t.busy())
	_check(not p.shaking and is_zero_approx(b.tremor), "The shake ends and steps return to normal")
	_check(is_equal_approx(kitchen_before - kitchen.hp, TremorSystem.TOPPLE_ROOM_DAMAGE + TremorSystem.ROOM_TREMOR + TremorSystem.GAS_LEAK_DAMAGE) and int(t.stats["gas_leaks"]) == 1, "Kitchen damage: toppled fridge + tremor + gas leak (gas left on)")
	await _frames(25)
	var fridge: BuildingProp = _prop(BuildingProp.Kind.FRIDGE)
	_check(absf(absf(fridge.rotation) - BuildingProp.TOPPLE_ANGLE) < 0.01 and fridge.condition == BuildingProp.Condition.DAMAGED, "A toppled piece lies on its side")
	p.covering = true
	p.visual_scale = Vector2(1.16, 0.64)
	p.queue_redraw()
	var health: float = p.health
	_until(func() -> bool: return _shaking_past(0.9))
	await _rendered()
	await _save("tremor-cover.png")
	_until(func() -> bool: return _shaking_past(TremorSystem.DEBRIS_AT + 0.02))
	_check(is_equal_approx(p.health, health) and int(t.stats["covered"]) == 1 and int(t.stats["shakes"]) == 2, "Çök-Kapan-Tutun through the peak: no damage")
	p.covering = false
	p.visual_scale = Vector2.ONE
	_until(func() -> bool: return not t.busy())
	game.preparedness.complete(_task(Preparedness.Task.GAS))
	var leaks: int = int(t.stats["gas_leaks"])
	_until(func() -> bool: return _shaking_past(TremorSystem.DEBRIS_AT + 0.02))
	_check(int(t.stats["gas_leaks"]) == leaks and int(t.stats["shakes"]) == 3, "With the gas off, tremors cause no leak")
	game.waves.fail_siege()
	_check(not p.shaking and not t.busy(), "Defeat stops any tremor")
	game.reset_game()
	_check(not fridge.toppled and is_zero_approx(fridge.rotation) and not bookcase.secured, "R stands toppled furniture back up and clears bolts")

func _tremor_hazards() -> void:
	_battle(DisasterWaveManager.Mode.EARTHQUAKE)
	var t: TremorSystem = game.tremor
	var p: SiegePlayer = game.player
	var dining: RoomDiorama = _room(RoomDiorama.Kind.DINING)
	_place(1, dining.global_position.x + 300.0)
	p.covering = true
	_until(func() -> bool: return _shaking_past(TremorSystem.TOPPLE_AT + 0.02))
	_check(is_equal_approx(p.health, p.max_health - TremorSystem.TOPPLE_DAMAGE) and int(t.stats["topple_hits"]) == 1, "A loose vitrine falls on the player even in Çök-Kapan-Tutun: secure it beforehand")
	p.covering = false
	_until(func() -> bool: return not t.busy())
	var living: RoomDiorama = _room(RoomDiorama.Kind.LIVING)
	_place(1, living.global_position.x + 100.0)
	p.health = p.max_health
	game.sound.advance(1.0)
	var glass: int = game.sound.plays("impact_glass")
	_until(func() -> bool: return _shaking_past(TremorSystem.TOPPLE_AT + 0.02))
	_check(is_equal_approx(p.health, p.max_health - Preparedness.GLASS_DAMAGE) and int(game.preparedness.phase_stats["glass"]) == 1 and game.sound.plays("impact_glass") == glass + 1, "Next to an unshuttered window the tremor showers glass")
	_until(func() -> bool: return not t.busy())
	living.reinforce(RoomDiorama.Reinforcement.SHUTTER)
	_place(1, living.global_position.x + 100.0)
	p.health = p.max_health
	p.covering = true
	_until(func() -> bool: return _shaking_past(TremorSystem.DEBRIS_AT + 0.02))
	_check(is_equal_approx(p.health, p.max_health), "With the shutter down (and Çök-Kapan-Tutun) the same spot is safe")
	p.covering = false
	game.reset_game()
	var storm: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM)
	_place(1, living.global_position.x + 100.0)
	storm._on_gust_ready(1.0, 100.0, 0.5)
	_check(is_equal_approx(p.health, p.max_health - Preparedness.GLASS_DAMAGE) and int(game.tremor.stats["shakes"]) == 0, "A storm gust bursts an unshuttered window next to the player; storms have no tremors")
	game.reset_game()

func _cover_input() -> void:
	game.reset_game()
	var p: SiegePlayer = game.player
	p.set_physics_process(true)
	await _frames(6)
	game.sound.advance(1.0)
	var rustle: int = game.sound.plays("cover")
	Input.action_press(&"cover")
	await _frames(4)
	_check(p.covering and game.sound.plays("cover") == rustle + 1, "Holding C on the floor drops into Çök-Kapan-Tutun")
	Input.action_press(&"move_right")
	var x: float = p.global_position.x
	await _frames(10)
	_check(absf(p.global_position.x - x) < 2.0, "While covering the player holds still")
	Input.action_release(&"move_right")
	Input.action_release(&"cover")
	await _frames(4)
	_check(not p.covering, "Releasing C stands back up")
	p.set_physics_process(false)
	game.reset_game()

# -------------------------------------------------------------- tutorial ----

func _tutorial() -> void:
	game.tutorial.enabled = true
	game.reset_game()
	var tut: TutorialGuide = game.tutorial
	var w: DisasterWaveManager = game.waves
	var prep: Preparedness = game.preparedness
	var p: SiegePlayer = game.player
	tut.advance(STEP)
	_check(w.prep_hold and tut.hint_keys == PackedStringArray(["A", "D"]), "Tutorial starts with A D; the prep clock waits")
	var clock: float = w.preparation_remaining
	w.advance_wave(5.0)
	_check(is_equal_approx(w.preparation_remaining, clock) and w.state == DisasterWaveManager.State.PREPARATION_PHASE, "Nothing starts while the player is still learning to move")
	await _rendered()
	_check(game.labels.keys_drawn == PackedStringArray(["A", "D"]) and game.labels.task_markers == 0 and not game.preparedness.available(), "A and D key caps float over the player; tasks stay dark until moving is learned")
	await _save("tutorial-move.png")
	p.global_position.x += 240.0
	tut.advance(STEP)
	tut.advance(STEP)
	_check(tut.step == TutorialGuide.Step.JUMP and tut.hint_keys == PackedStringArray(["W"]), "After running: W")
	p.jumped.emit(false)
	_check(tut.step == TutorialGuide.Step.PREPARE and not w.prep_hold and is_equal_approx(w.preparation_total, TutorialGuide.TASK_TIME) and prep.available() and prep.pending().size() == 6, "After jumping the tasks light up and the 30 s preparation clock starts")
	for kind: int in [Preparedness.Task.BAG, Preparedness.Task.GAS]:
		prep.complete(_task(kind))
	prep.complete(_task(Preparedness.Task.SECURE, BuildingProp.Kind.FRIDGE))
	_place(0, _room(RoomDiorama.Kind.LOBBY).global_position.x + 250.0)
	tut.advance(STEP)
	_check(tut.hint_keys == PackedStringArray(["W", "W"]), "Ground floor done: W W points up a floor")
	await _rendered()
	await _save("tutorial-up.png")
	_place(3, _room(RoomDiorama.Kind.ROOF_CONTROL).global_position.x + 100.0)
	tut.advance(STEP)
	_check(tut.hint_keys == PackedStringArray(["S"]), "Above the tasks: S points down")
	_place(1, _room(RoomDiorama.Kind.LIVING).global_position.x + 100.0)
	tut.advance(STEP)
	_check(tut.hint_keys.is_empty() and tut.arrow == 1, "Same floor: an arrow points toward the next task")
	w.start_next_wave()
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	_check(is_equal_approx(game.hazard_scale(), TutorialGuide.EASING) and is_equal_approx(w._quake_clock, TutorialGuide.FIRST_PATTERN), "The tutorial quake is gentler (60% damage) and opens with the tremor drill")
	w._quake_clock = 999.0
	_tick(2.05)
	tut.advance(STEP)
	_check(tut.hint_keys == PackedStringArray(["C"]) and is_equal_approx(game.telegraphs.tremor_warning_total, TremorSystem.WARNING + TutorialGuide.TREMOR_EXTRA) and tut.objective_text.contains("Çök-Kapan-Tutun"), "First tremor: C and an objective line, announced 1.8 s ahead")
	p.covering = true
	tut.advance(STEP)
	_check(tut.hint_keys.is_empty(), "Covering hides the C hint")
	p.covering = false
	_until(func() -> bool: return not game.tremor.busy())
	var a: HazardAttack = w._attack(HazardAttack.Kind.SHOCKWAVE, 0, Vector2(1200, game.building.floor_y(0) - 13), Vector2(-500, 0))
	a.lifetime = 1.0
	w.plan_attack(a)
	tut.advance(STEP)
	_check(tut.hint_keys == PackedStringArray(["SHIFT"]) and tut.objective_text.contains("SHIFT"), "First telegraphed attack: SHIFT")
	w.finish_wave()
	w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	game.upgrades.choose(0)
	tut.advance(STEP)
	_check(tut.hint_keys.is_empty() and is_equal_approx(game.hazard_scale(), 1.0) and not tut.first_phase() and (tut.objective_text == "" or tut.objective_text.begins_with("Hazırlık")), "After the first disaster the tutorial steps aside (only the prep line remains)")
	game.tutorial.enabled = false
	game.reset_game()
	_check(not w.prep_hold and tut.step == TutorialGuide.Step.DONE, "Tutorial off: no hold, no hints")

# ----------------------------------------------------------------- karne ----

func _karne() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.EARTHQUAKE)
	var t: TremorSystem = game.tremor
	var prep: Preparedness = game.preparedness
	t.stats["shakes"] = 3
	t.stats["covered"] = 2
	t.stats["topples"] = 1
	var rows: Array[Dictionary] = Debrief.rows(game, DisasterWaveManager.Mode.EARTHQUAKE)
	var supported: bool = true
	for row: Dictionary in rows: supported = supported and PixelFont.supports(row["fact"]) and PixelFont.supports(row["tip"])
	_check(rows.size() == 3 and not rows[0]["ok"] and rows[0]["fact"] == "Çök-Kapan-Tutun 2/3" and rows[1]["fact"] == "1 eşya devrildi" and String(rows[0]["tip"]) != "" and supported, "Karne: misses first, each with a short habit tip (%s)" % str(rows))
	t.stats["covered"] = 3
	t.stats["topples"] = 0
	for task: Dictionary in prep.tasks:
		if int(task["kind"]) in [Preparedness.Task.SECURE, Preparedness.Task.GAS, Preparedness.Task.BAG]: prep.complete(task)
	rows = Debrief.rows(game, DisasterWaveManager.Mode.EARTHQUAKE)
	var facts: Array[String] = []
	for row: Dictionary in rows: facts.append(row["fact"])
	_check(rows.size() == 3 and rows[0]["ok"] and rows[1]["ok"] and rows[2]["ok"] and facts == ["Çök-Kapan-Tutun 3/3", "Eşyalar sabitti", "Gaz vanası kapalıydı"], "A well-prepared quake shows three ticks (%s)" % str(facts))
	rows = Debrief.rows(game, DisasterWaveManager.Mode.FLOOD)
	_check(rows[0]["fact"] == "Sigortalar açık kaldı" and rows[0]["tip"] == "Sel öncesi sigortaları kapat.", "Flood karne asks for the mains to be cut")
	w.completed_waves = 1
	rows = Debrief.rows(game, DisasterWaveManager.Mode.STORM)
	_check(rows[0]["fact"] == "Kepenkler 0/4" and not rows[0]["ok"], "Storm karne counts shutters")
	w.completed_waves = 0
	t.stats["covered"] = 1
	w.finish_wave()
	w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	await _frames(25)
	await _rendered()
	var overlay: UpgradeOverlay = game.upgrade_overlay
	_check(overlay.visible and overlay.karne_rows.size() >= 1 and overlay.karne_texts.has("Karne") and overlay.karne_texts.has("Çök-Kapan-Tutun 1/3"), "The card screen opens with the karne above the cards")
	await _save("karne-cards.png")
	game.upgrades.choose(0)
	w.start_next_wave()
	w.advance_wave(w.intro_duration())
	w.fail_siege(DisasterWaveManager.FailReason.BUILDING)
	await _rendered()
	var texts: PackedStringArray = game.hud.drawn_texts
	_check(texts.size() >= 3 and texts[0] == "Bina çöktü" and texts[-1] == "R  Bölümü tekrar dene", "Defeat: title, karne lines, one hint (%s)" % ", ".join(texts))
	await _save("karne-defeat.png")
	game.reset_game()
	game.waves.victory = true
	game.waves.state = DisasterWaveManager.State.VICTORY
	await _rendered()
	_check(game.hud.drawn_texts[0] == "Hayatta kaldın" and game.hud.drawn_texts[-1] == "R  Yeni oyun", "Victory: Hayatta kaldın")
	game.reset_game()

# ---------------------------------------------------------------- polish ----

func _polish() -> void:
	var w: DisasterWaveManager = game.waves
	var loot: LootSystem = game.loot
	var tut: TutorialGuide = game.tutorial
	var prep: Preparedness = game.preparedness
	var p: SiegePlayer = game.player
	_check(w.siege_duration == 40.0 and w.preparation_duration == 15.0 and w.build_duration == 10.0 and is_equal_approx(DisasterWaveManager.tempo_at(0.0), 1.0), "Pace: 40 s fights at full tempo from the start, 15/10 s preparations")
	_check(TremorSystem.WARNING == 1.0 and TremorSystem.DURATION == 1.4 and TremorSystem.EARTHQUAKE_INTERVAL == 8.0, "Shorter, more frequent tremors (1.0 s warning, 1.4 s shake, every 8 s)")
	_check(loot.loot_lifetime == 6.0 and is_equal_approx(6.0 / ((loot.spawn_interval.x + loot.spawn_interval.y) * 0.5), 1.2), "Supplies stay 6 s on the ground and drop 20% more often")
	# Objective line during a preparation (tutorial off as well).
	game.reset_game()
	tut.advance(STEP)
	_check(tut.objective_text.begins_with("Hazırlık 0/6 · ") and PixelFont.supports(tut.objective_text), "Preparation shows a top line with progress and the next task (%s)" % tut.objective_text)
	var wardrobe: Dictionary = _task(Preparedness.Task.SECURE, BuildingProp.Kind.WARDROBE)
	_stand_at(wardrobe)
	tut.advance(STEP)
	_check(tut.objective_text == "Hazırlık 0/6 · Gardırobu sabitle: devrilmesin" and tut.objective_color == Preparedness.COLORS[Preparedness.Task.SECURE], "Next to a task the line names it and why")
	await _rendered()
	_check("".join(game.hud.drawn_texts).contains(tut.objective_text), "The HUD draws the objective line at the top")
	await _save("objective-prep.png")
	for task: Dictionary in prep.pending(): prep.complete(task)
	tut.advance(STEP)
	_check(tut.objective_text == "Hazırsın", "All tasks done: Hazırsın")
	# Loot lifetime: a drop survives 5.9 s on the ground and is gone after 6 s.
	_battle(DisasterWaveManager.Mode.STORM)
	loot._next_spawn = 999.0
	loot.spawn(LootSystem.Kind.COLUMN_KIT, 9)
	loot.advance(LootSystem.DROP_TIME + 5.9)
	var alive: bool = loot.items.size() == 1
	loot.advance(0.15)
	_check(alive and loot.items.is_empty(), "A supply stays exactly six seconds on the ground")
	# Repair guidance (tutorial on, any phase until the first repair).
	tut.enabled = true
	game.reset_game()
	w.start_next_wave()
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	w._quake_clock = 999.0
	game.tremor.next_left = 999.0
	var room: RoomDiorama = _room(RoomDiorama.Kind.GUEST)
	game.sound.advance(1.0)
	var alarms: int = game.sound.plays("alarm")
	room.apply_damage(40)
	_check(game.sound.plays("alarm") == alarms + 1, "A room that starts needing repair plays one alert ping")
	_place(0, _room(RoomDiorama.Kind.LOBBY).global_position.x + 250.0)
	tut.advance(STEP)
	_check(tut.objective_text == "Oda hasarlı: kolon kiti topla" and tut.guide_loot == -1, "No kit yet: the line asks for a column kit")
	loot.spawn(LootSystem.Kind.COLUMN_KIT, RoomDiorama.Kind.KITCHEN)
	tut.advance(STEP)
	_check(tut.guide_loot == 0 and tut.arrow == 1, "A dropped kit is pointed at (arrow on the same floor)")
	await _rendered()
	_check(game.labels.repair_frames == 1 and game.labels.repair_markers == 1 and game.labels.loot_guides == 1 and game.hud.drawn_texts.has("Oda hasarlı: kolon kiti topla"), "The damaged room is framed and marked; a chevron marks the kit")
	await _save("repair-guide-kit.png")
	loot.items.clear()
	loot.column_kits = 1
	tut.advance(STEP)
	_check(tut.objective_text == "Hasarlı odaya git: E ile onar" and tut.hint_keys == PackedStringArray(["W", "W"]), "With a kit: go to the damaged room (W W up two floors)")
	_place(room.floor_index, room.global_position.x + 200.0)
	tut.advance(STEP)
	await _rendered()
	_check(tut.hint_keys.is_empty() and tut.arrow == 0 and game.labels.keys_drawn.has("E"), "In the damaged room only the E key remains")
	await _save("repair-guide-room.png")
	game.sound.advance(1.0)
	alarms = game.sound.plays("alarm")
	loot.repair_current_room()
	tut.advance(STEP)
	_check(tut.repairs_done == 1 and tut.objective_text == "" and game.sound.plays("alarm") == alarms, "After the first repair the guidance is done (repairing never pings)")
	room.apply_damage(40)
	tut.advance(STEP)
	_check(tut.objective_text == "", "Later repairs are left to the player")
	tut.enabled = false
	# A later preparation with nothing left to do (no task, no kit) shrinks to 3 s.
	for kits: int in [0, 1]:
		game.reset_game()
		w.start_next_wave()
		w.advance_wave(w.intro_duration())
		for task: Dictionary in prep.tasks:
			if int(Preparedness.UNLOCK[int(task["kind"])]) <= 1: prep.complete(task)
		w.finish_wave()
		w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
		game.upgrades.choose(0)
		loot.column_kits = kits
		prep.advance(STEP)
		if kits == 0: _check(is_equal_approx(w.preparation_remaining, Preparedness.IDLE_PREP), "Nothing left to prepare and no kit: the next disaster comes after 3 s")
		else: _check(is_equal_approx(w.preparation_remaining, w.build_duration), "With a kit to install the full 10 s preparation stays")
	game.reset_game()

# ---------------------------------------------------------------- runner ----

func _save(filename: String) -> void:
	if capture_dir == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(capture_dir.path_join(filename)) == OK, "Rendered " + filename)

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)
