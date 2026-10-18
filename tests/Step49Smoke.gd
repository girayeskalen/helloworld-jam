extends SceneTree
## Step 4.9: minimal HUD, 60-second waves, direct 1-6 shortcuts and the sixth-wave
## Kataklizma Titanı (2 s fusion entry, five combos, steam interaction, nova
## supplies), a real 60-second final fight and native 1920x1080 captures.
var game: MainGame
var checks: int = 0
var failures: int = 0
var launches: Array[HazardAttack] = []
var fusions: int = 0

const REMOVED_HUD: Array[String] = ["AFET KUŞATMASI", "DISASTER SIEGE", "AFETE HAZIRLIK / BÖLÜM 01", "KUŞATMA ALTINDA", "HAZIRLIK ALANI", "KAT 00", "A / D", "KAÇINIŞ  00", "TAKLA ENERJİSİ", "BİNA DAYANIKLILIĞI"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	if DisplayServer.get_name() != "headless":
		root.unfocusable = true
		root.mouse_passthrough = true
	await _frames(4)
	game.waves.attack_launched.connect(func(a: HazardAttack) -> void: launches.append(a))
	game.waves.fusion_burst.connect(func() -> void: fusions += 1)
	await _hud()
	_timing()
	await _shortcuts()
	_patterns()
	_steam()
	_nova()
	_art()
	await _final_fight()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP49_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await process_frame
	await process_frame
	# Drain the audio driver after deferred scene destruction.
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _quiet() -> void:
	game.waves.autoplay = false
	for node: Node in [game.loot, game.mechanics, game.player]: node.set_physics_process(false)
	game.player.controls_locked = true

func _final() -> void:
	game.reset_game()
	_quiet()
	game.waves.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	game.waves.advance_wave(DisasterWaveManager.FINAL_INTRO_DURATION)
	game.building.pacing_enabled = false
	game.projectiles.clear()
	game.telegraphs.clear()
	launches.clear()

# ------------------------------------------------------------------ HUD ----

func _hud() -> void:
	game.reset_game()
	_quiet()
	var hud: GameHUD = game.hud
	await _rendered()
	var removed: bool = true
	for text: String in REMOVED_HUD: removed = removed and not hud.drawn_texts.has(text)
	_check(removed, "Old title, right-hand status box and bottom control table are gone")
	_check(hud.drawn_texts == PackedStringArray(["DEPREM", "1 Deprem", " · ", "2 Fırtına", " · ", "3 Sel", " · ", "4 Afet"]), "Preparation HUD prints the coming boss and section shortcuts (%s)" % ", ".join(hud.drawn_texts))
	_check(hud.room_color(game.building.rooms[0]) == GameHUD.ROOM_INTACT and hud.slot_count(0) == 0 and hud.slot_count(1) == 0 and hud.slot_count(2) == 0, "Health, rooms and empty kit slots are bars, cells and icons without numbers")
	var clean: bool = true
	for rect: Rect2 in hud.drawn_rects:
		if rect.end.y > 700.0: clean = clean and (rect.end.x <= hud.slot_rect(2).end.x + 30.0 or rect.position.x >= GameHUD.BOSS_BAR.position.x-120)
	_check(clean, "Bottom equipment slots and the centred boss bar occupy separate lanes")
	_check(hud.slot_rect(2).end.x < 300.0 and hud.slot_rect(0).position.y > 940.0, "Three compact slots sit in the bottom-left corner")
	Input.action_press(&"controls_help")
	await _rendered()
	_check(hud.drawn_texts.has("A D") and hud.drawn_texts.has("SHIFT") and hud.drawn_texts.has("1-4") and not hud.drawn_texts.has("KONTROLLER"), "Holding Tab/H shows the compact key list")
	Input.action_release(&"controls_help")
	await _rendered()
	_check(not hud.drawn_texts.has("A D"), "Releasing Tab/H hides the help again")
	game.waves.start_next_wave()
	game.waves.advance_wave(game.waves.intro_duration())
	game.building.pacing_enabled = false
	game.player.health = 85
	game.loot.column_kits = 2
	game.loot.barricade_kits = 1
	game.loot.activate_safety(game.building.rooms[5])
	game.building.rooms[3].apply_damage(44)
	await _rendered()
	_check(hud.drawn_texts.has("DEPREM") and hud.drawn_texts.has("2") and hud.drawn_texts.has("1"), "Siege HUD shows the boss name and plain kit counts (%s)" % ", ".join(hud.drawn_texts))
	var words: bool = true
	for text: String in hud.drawn_texts: words = words and (text == "DEPREM" or text.is_valid_int())
	_check(words, "No health, seconds or percentage numbers are printed during the siege")
	_check(hud.room_color(game.building.rooms[3]) == UIStyle.ALERT and hud.room_color(game.building.rooms[0]) == GameHUD.ROOM_INTACT, "Building state reads from the room mini-map (damaged room turns amber)")
	_check(hud.slot_count(0) == 2 and hud.slot_count(1) == 1 and hud.slot_count(2) == 1, "Slots count column kits, fixing kits and protected rooms")
	var top_ok: bool = true
	for rect: Rect2 in hud.drawn_rects:
		if rect.end.y < 140.0: top_ok = top_ok and (rect.end.x < 420.0 or (rect.position.x > 600.0 and rect.end.x < 1360.0) or rect.position.x > 1450.0)
	_check(top_ok, "Top HUD is only the left status stack, the centre strip and a tiny help hint")
	game.player.health = 100

# --------------------------------------------------------------- timing ----

func _timing() -> void:
	var w: DisasterWaveManager = game.waves
	_check(w.siege_duration == 40.0 and w.build_duration == 10.0 and DisasterWaveManager.TOTAL_WAVES == 4 and DisasterWaveManager.Mode.size() == 4, "Four phases of 40 seconds, with 10-second Hazırlık")
	game.reset_game()
	_quiet()
	var flashes: int = game.weather.flash_count
	fusions = 0
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	_check(w.wave_number == 4 and w.state == DisasterWaveManager.State.WAVE_INTRO and is_equal_approx(w.transition_remaining, 2.8) and game.titan.visible and game.titan.fusion == 0.0, "Fourth phase opens a 2.8-second three-disaster fusion")
	_check(not game.storm.visible and not game.earthquake.visible and not game.flood.visible, "Only the combined boss enters the final phase")
	w.advance_wave(1.539)
	_check(fusions == 0 and game.projectiles.active_count() == 0, "Energies are still converging at 1.099 s")
	w.advance_wave(.002)
	_check(fusions == 1 and game.weather.flash_count > flashes and game.game_camera.shake_strength() > 10.0, "At 55% the four energies collide: lightning flash and heavy shake")
	w.advance_wave(1.258)
	_check(w.state == DisasterWaveManager.State.WAVE_INTRO and is_equal_approx(w.siege_remaining, w.siege_duration), "Fusion cannot end before 2.0 s nor spend fight time")
	w.advance_wave(.001)
	_check(w.state == DisasterWaveManager.State.SIEGE_PHASE and game.titan.fusion == 1.0 and fusions == 1, "Titan is formed exactly at 2.0 s; the collision fires once")
	_check(w.boss_name() == "AFET" and w.phase_label() == "AFET KUŞATMASI", "Exact plain final boss name and siege label")
	w.advance_wave(27.999)
	_check(not w.nova, "No nova before the final 12 seconds")
	w.advance_wave(.002)
	_check(w.nova and w.phase_label() == "SON 12 SANİYE · KATAKLİZMA NOVA", "Nova begins in the last 12 seconds")
	w.advance_wave(12.0)
	_check(w.state == DisasterWaveManager.State.WAVE_OUTRO and not w.nova, "40 s ends the final fight and clears the overload")
	w.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	_check(w.victory and w.completed_waves == 4, "Fourth retreat is the campaign victory")

# ------------------------------------------------------------ shortcuts ----

func _shortcuts() -> void:
	var w: DisasterWaveManager = game.waves
	game.reset_game()
	_quiet()
	game.player.set_physics_process(true)
	game.player.controls_locked = false
	await _tap(KEY_4)
	_check(not w.debug_enabled and w.mode == DisasterWaveManager.Mode.CATACLYSM and w.wave_number == 4 and w.completed_waves == 3 and w.state == DisasterWaveManager.State.WAVE_INTRO, "Key 4 starts the final boss directly")
	var keys: Array[int] = [KEY_1, KEY_2, KEY_3]
	for mode: int in range(3):
		await _tap(keys[mode])
		_check(w.mode == DisasterWaveManager.CAMPAIGN[mode] and w.wave_number == mode + 1 and not game.titan.visible, "Key %d starts its campaign section with a fresh world" % (mode + 1))
	w.state = DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	game.upgrades.open_selection()
	var offered: int = game.upgrades.offers[2]
	await _tap(KEY_6)
	_check(game.upgrades.pending and w.mode == DisasterWaveManager.Mode.FLOOD, "Inside the card modal the removed key 6 cannot restart a boss")
	await _tap(KEY_3)
	_check(not game.upgrades.pending and game.upgrades.has_upgrade(offered) and w.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE, "Inside the modal key 3 still picks the third card")
	await _tap(KEY_U)
	_check(not game.upgrades.pending, "U card test remains gated behind F9")
	game.player.set_physics_process(false)

# ------------------------------------------------------------- patterns ----

func _patterns() -> void:
	_final()
	var w: DisasterWaveManager = game.waves
	var titan: DisasterBoss = game.titan
	var labels: Dictionary = {}
	for index: int in range(4):
		game.projectiles.clear()
		game.telegraphs.clear()
		launches.clear()
		titan.plan_pattern(w, index, 1)
		labels[titan.pattern_label] = true
		var valid: bool = not game.telegraphs.pending.is_empty() and game.projectiles.active_count() == 0
		for a: HazardAttack in game.telegraphs.pending:
			valid = valid and not a.warning_confirmed and a.warning_duration >= a.minimum_warning() and a.source >= 0 and a.source <= 2
			for sample: int in range(9):
				var p: Vector2 = a.point_at(a.lifetime * sample / 8.0)
				valid = valid and is_finite(p.x) and is_finite(p.y)
		_check(valid and titan.is_charging(), "Combo %d (%s) is fully telegraphed, frozen and announced by the titan" % [index + 1, titan.pattern_label])
		game.telegraphs._physics_process(.54)
		_check(game.projectiles.active_count() == 0, "Combo %d cannot hurt during the first .54 s" % (index + 1))
		for tick: int in range(150): game.telegraphs._physics_process(1.0 / 60)
		var armed: bool = launches.size() > 0
		for a: HazardAttack in launches: armed = armed and a.is_armed()
		_check(armed, "Combo %d launches only armed pool entries (%d)" % [index + 1, launches.size()])
	# Combo details.
	game.telegraphs.clear()
	titan.plan_pattern(w, 0, 1)
	var floods: Array[int] = []
	var meteors: int = 0
	for a: HazardAttack in game.telegraphs.pending:
		if a.kind == HazardAttack.Kind.FLOOD_ZONE: floods.append(a.floor_index)
		if a.kind == HazardAttack.Kind.CONCRETE and a.cross_floor and a.splits and a.source == 1 and a.warning_delay > 0.0: meteors += 1
	floods.sort()
	_check(floods == [0, 1] and meteors == 3, "Skill 1: flood on both lower floors plus three delayed roof rocks")
	game.telegraphs.clear()
	titan.plan_pattern(w, 1, 2)
	var spiral: int = 0
	var blades: Array[float] = []
	for a: HazardAttack in game.telegraphs.pending:
		if a.kind in [HazardAttack.Kind.WIND_ORB,HazardAttack.Kind.WATER_SHARD] and a.motion == HazardAttack.Motion.SPIRAL and a.floor_index == 2: spiral += 1
		if a.kind == HazardAttack.Kind.WIND_BLADE and a.source == 0: blades.append(signf(a.velocity.x))
	_check(spiral == 14 and blades.size() == 1, "Skill 2: two seven-shot water/wind rings and a wind blade on one floor")
	_check(game.telegraphs.gust_warning_left > 0.0 and game.telegraphs.gust_direction < 0.0, "Skill 2 warns a wind pull toward the titan's vortex arm")
	game.telegraphs.clear()
	titan.plan_pattern(w, 2, 1)
	var parts: Dictionary = {}
	var jumpable: bool = true
	for a: HazardAttack in game.telegraphs.pending:
		parts[a.kind] = int(parts.get(a.kind, 0)) + 1
		if a.kind == HazardAttack.Kind.SHOCKWAVE: jumpable = jumpable and a.radius <= 12.0 and a.floor_y - a.origin.y <= 12.0
		if a.kind == HazardAttack.Kind.HYDRO_ORB: jumpable = jumpable and a.motion == HazardAttack.Motion.REFLECT and a.splits and a.path_points.size() == 5
		if a.kind == HazardAttack.Kind.TIDAL_WALL: jumpable = jumpable and is_equal_approx(a.warning_duration,1.2) and a.floor_index == 3
	_check(parts.get(HazardAttack.Kind.TIDAL_WALL, 0) == 1 and parts.get(HazardAttack.Kind.SHOCKWAVE, 0) == 1 and parts.get(HazardAttack.Kind.HYDRO_ORB, 0) == 1 and parts.has(HazardAttack.Kind.CONCRETE), "Skill 3: tidal wall, seismic waves, window orbs and ceiling debris together")
	_check(jumpable, "Skill 3 ground waves hug the floor, orbs rebound three times, the wall gets 1.2 s")
	game.telegraphs.clear()
	game.projectiles.clear()
	titan.plan_pattern(w, 3, 1)
	var corners: Dictionary = {}
	var nearest: Dictionary = {}
	var converge: bool = true
	var center: Vector2 = Vector2(w.building.center_x(), (w.building.floor_y(3) - 140 + w.building.floor_y(0) - 60) * .5)
	for a: HazardAttack in game.telegraphs.pending:
		if a.lead: corners[a.source] = a.origin
		var miss: float = Geometry2D.get_closest_point_to_segment(center, a.origin, a.point_at(a.lifetime)).distance_to(center)
		nearest[a.source] = minf(float(nearest.get(a.source, INF)), miss)
		converge = converge and is_equal_approx(a.warning_duration, HazardAttack.SEAL_WARNING+CataclysmPatterns.WARNING_EXTRA)
	for source: int in nearest: converge = converge and float(nearest[source]) < 40.0
	var quadrants: bool = corners.size() == 3 and Vector2(corners[0]).x < center.x and Vector2(corners[2]).y > center.y and Vector2(corners[1]).x > center.x
	_check(game.telegraphs.pending.size() == 20 and quadrants, "Skill 4: 20 shots from four corners using only storm/quake/flood")
	_check(converge, "Seal nets converge through the centre after exactly 1.0 s")
	game.telegraphs._physics_process(.999)
	_check(game.projectiles.active_count() == 0, "Seal is harmless at .999 s")
	game.telegraphs._physics_process(.001)
	_check(game.projectiles.active_count() == 20, "All 20 seal bullets launch at 1.0 s")
	w.nova = true
	game.telegraphs.clear()
	titan.plan_pattern(w, 0, 1)
	labels[titan.pattern_label] = true
	w.nova = false
	_check(labels.size() == 5, "Five distinct final-boss skills: %s" % ", ".join(PackedStringArray(labels.keys())))

func _steam() -> void:
	_final()
	var w: DisasterWaveManager = game.waves
	game.titan.plan_pattern(w, 0, 1)
	game.telegraphs._physics_process(1.2)
	var water: int = 0
	for shot: HazardProjectile in game.projectiles.entries:
		if shot.active and shot.attack.kind == HazardAttack.Kind.FLOOD_ZONE: water += 1
	game.telegraphs.clear()
	var meteor: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE, 0, Vector2.ZERO, Vector2.ZERO)
	meteor.source = 1
	meteor.pattern = HazardAttack.Pattern.STEAM_TSUNAMI
	meteor.splits = true
	var point: Vector2 = Vector2(w.building.center_x() + 40, w.building.floor_y(0))
	w._on_projectile_impacted(meteor, point)
	var kinds: Dictionary = {}
	var upward: bool = true
	for a: HazardAttack in game.telegraphs.pending:
		kinds[[a.kind, a.source]] = int(kinds.get([a.kind, a.source], 0)) + 1
		upward = upward and a.velocity.y <= .001 and is_equal_approx(a.warning_duration, .75)
	_check(water == 2 and kinds.get([HazardAttack.Kind.STEAM_COLUMN, 2], 0) == 1 and kinds.get([HazardAttack.Kind.WATER_SHARD, 2], 0) == 2 and kinds.get([HazardAttack.Kind.SHARD, 1], 0) == 2, "Rock in live flood makes a pressure column and four rock/water shards")
	_check(upward, "Steam orbs get their own .75 s warning and never fire into the slab")
	game.telegraphs.clear()
	var dry: HazardAttack = meteor.frozen_copy()
	dry.floor_index = 2
	dry.floor_y = w.building.floor_y(2)
	w._on_projectile_impacted(dry, Vector2(point.x, dry.floor_y))
	var steam: bool = false
	for a: HazardAttack in game.telegraphs.pending: steam = steam or a.kind == HazardAttack.Kind.STEAM_COLUMN
	_check(not steam and game.telegraphs.pending.size() == 2, "A dry concrete impact creates the two reduced-density rock splinters")
	game.telegraphs.clear()
	game.projectiles.clear()
	game.titan.plan_pattern(w, 0, 1)
	game.telegraphs._physics_process(1.2)
	game.telegraphs.clear()
	w._on_projectile_impacted(meteor, point)
	game.telegraphs._physics_process(.95)
	var column: HazardProjectile
	for shot: HazardProjectile in game.projectiles.entries:
		if shot.active and shot.attack.kind == HazardAttack.Kind.STEAM_COLUMN: column = shot
	var p: SiegePlayer = game.player
	p.current_floor = 0
	p.global_position = Vector2(point.x, point.y)
	p.previous_position = p.global_position
	p.hit_invulnerability = 0
	p.health = 100
	_check(column != null and column.crosses_player(p, column.global_position), "Steam column is a real vertical hazard over the impact")
	game.projectiles._physics_process(.01)
	_check(p.health < 100, "Standing in the steam column hurts")
	p.health = 100
	p.hit_invulnerability = 0

func _nova() -> void:
	_final()
	var w: DisasterWaveManager = game.waves
	var l: LootSystem = game.loot
	l.clear_drops()
	l.messages.clear()
	w.siege_remaining = 12.012
	w._marathon_clock = 5.0
	w.advance_wave(.01, .01)
	_check(not w.nova and l.items.is_empty(), "Overload waits for the last 15 seconds")
	w.advance_wave(.01, .01)
	var kinds: Array[int] = []
	for item: Dictionary in l.items: kinds.append(int(item["kind"]))
	_check(w.nova and game.titan.enraged and kinds.has(LootSystem.Kind.COLUMN_KIT) and kinds.has(LootSystem.Kind.EMERGENCY_BAG), "Nova drops an extra repair kit and a first-aid bag at once")
	w.advance_wave(.36, .36)
	var rings: int = 0
	var elements: Dictionary = {}
	for a: HazardAttack in game.telegraphs.pending:
		if a.pattern == HazardAttack.Pattern.CATACLYSM_NOVA:
			rings += 1
			elements[a.source] = true
	_check(rings == 22 and elements.size() == 3 and game.titan.pattern_label.begins_with("KATAKLİZMA NOVA"), "Nova fires two warned 11-bullet rings mixing only three disaster elements")
	_check(game.titan._relocate > 0.0 and not game.titan._target.is_equal_approx(game.titan._home), "Overloaded titan blinks to a new anchor around the building")
	_check(w._marathon_clock > 0.0 and w._marathon_clock <= w.nova_interval*CataclysmPatterns.COOLDOWN_SCALE and w.nova_interval < w.cataclysm_interval, "Nova beat is faster than the normal combo beat")
	var lead: HazardAttack
	for a: HazardAttack in game.telegraphs.pending:
		if a.pattern == HazardAttack.Pattern.CATACLYSM_NOVA and a.lead and a.warning_delay == 0.0: lead = a
	var room: RoomDiorama = w.building.room_at(int(String(lead.room_source).trim_prefix("nova_")), w.building.column_at(lead.origin.x))
	var before: float = room.hp
	_check(is_equal_approx(room.hp, before), "Room is untouched while the ring is still a warning")
	game.telegraphs._physics_process(.95)
	_check(room.hp < before, "Ring launch visibly cracks the overloaded room")
	var supplies: int = w.nova_supplies
	w.advance_wave(3.5, 3.5)
	_check(w.nova_supplies > supplies, "Nova keeps dropping supplies every %.1f s" % w.nova_interval)
	_check(game.projectiles.get_child_count() == 128, "Nova never grows the 128-entry pool")

func _art() -> void:
	_final()
	var t: DisasterBoss = game.titan
	var b: ApartmentBuilding = game.building
	t.advance(.5)
	var rig: Dictionary = t.cataclysm_rig()
	var head: Vector2 = t.to_global(Vector2(rig["head"]))
	var tip: Vector2 = t.to_global(Vector2(rig["tip"]))
	var claw: Vector2 = t.to_global(Vector2(rig["claw"]))
	_check(rig["vortex"].size() == 6 and rig["flow"].size() == 3 and rig["crests"].size() == 8, "Rig owns a six-ring sleeve, three pressure balls and eight tide crests")
	_check(head.y < b.global_position.y and absf(head.x - b.center_x()) < 120.0, "Basalt head rises over the roof centre")
	_check(tip.x < b.global_position.x and claw.x > b.global_position.x + b.building_width, "Vortex arm and magma claw stay outside the facade")
	_check(not t.z_as_relative and t.z_index < b.z_index and t.front_layer.z_index > b.z_index and t.front_layer.z_index < game.projectiles.z_index, "Body sits behind the apartment, head layer above roof but under projectiles")
	var box: Rect2 = t.pose_bounds()
	var a: Vector2 = game.world_to_screen(t.to_global(box.position))
	var z: Vector2 = game.world_to_screen(t.to_global(box.end))
	_check(a.x >= 0 and z.x <= 1920 and a.y >= 70.0 and game.world_to_screen(Vector2(0,game.backdrop.ground_y)).y < GameHUD.BOSS_BAR.position.y-20, "Final body fits between the top margin and the bottom boss bar (%s)" % Rect2(a, z - a))
	var head_screen: Vector2 = game.world_to_screen(head)
	var arm_screen: Vector2 = game.world_to_screen(t.to_global(Vector2(rig["shoulder_l"])))
	_check(head_screen.x > 420.0 and head_screen.x < 1500.0 and arm_screen.y > 140.0, "Head and arms never cover the left status stack")
	var previous: Dictionary = rig
	t.advance(.25)
	rig = t.cataclysm_rig()
	_check(rig["head"] != previous["head"] and rig["tip"] != previous["tip"] and rig["claw"] != previous["claw"] and rig["crests"] != previous["crests"], "Head, vortex arm, claw and tides animate independently")
	var jaw: float = rig["jaw"]
	t.cue_attack(1.0)
	t.advance(.8)
	_check(float(t.cataclysm_rig()["jaw"]) > jaw and t.cataclysm_rig()["claw"] != rig["claw"], "Wind-up opens the jaw and draws the claw back")
	var particles: int = t._particles.size()
	t.strike()
	_check(t.slam_progress() >= 0.0 and t._particles.size() > particles, "Strike bursts lightning, lava and rock from both hands")
	game.waves.finish_wave()
	game.waves.advance_wave(.5)
	_check(t.retreat > .4 and t.position.y > t._home.y and t.self_modulate.a < 1.0, "Retreat sinks the titan into its tide and fades it")
	_check(t.front_layer.z_index < b.z_index and not t.is_charging(), "While sinking, the head drops behind the facade and no attack plate lingers")
	t.set_active(true)
	_check(t.front_layer.z_index == DisasterBoss.FRONT_Z, "Re-activation restores the head layer above the roof")

# ------------------------------------------------------- full final fight ----

func _final_fight() -> void:
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	var p: SiegePlayer = game.player
	p.max_health = 100000
	p.health = 100000
	game.loot.set_physics_process(true)
	game.mechanics.set_physics_process(true)
	game.telegraphs.set_physics_process(true)
	game.projectiles.set_physics_process(true)
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	p.max_health = 100000
	p.health = 100000
	w.autoplay = true
	launches.clear()
	var peak: int = 0
	var bad: int = 0
	var patterns: Dictionary = {}
	var kinds: Dictionary = {}
	var ticks: int = 0
	var siege_ticks: int = 0
	while not w.victory and not w.failed and ticks < 4300:
		await physics_frame
		ticks += 1
		if w.state == DisasterWaveManager.State.SIEGE_PHASE: siege_ticks += 1
		peak = maxi(peak, game.projectiles.active_count())
		# Integration driver: spend earned kits on the weakest alerted room.
		if ticks % 240 == 0 and game.loot.column_kits > 0:
			for room: RoomDiorama in game.building.rooms:
				if room.needs_repair():
					p.current_floor = room.floor_index
					p.global_position = room.global_position + Vector2(200, 199.5)
					game.loot.repair_current_room()
					break
		for i: int in range(game.loot.items.size() - 1, -1, -1):
			if float(game.loot.items[i]["drop"]) >= 1.0: game.loot.collect(i)
	for a: HazardAttack in launches:
		patterns[a.pattern] = true
		kinds[a.kind] = true
		var required: float = a.minimum_warning()
		if not a.is_armed() or a.warning_elapsed < required - .00001 or a.warning_elapsed > a.warning_duration + .017: bad += 1
	w.autoplay = false
	print("FINAL_FIGHT ticks=%d siege=%d launches=%d peak=%d supplies=%d integrity=%.1f" % [ticks, siege_ticks, launches.size(), peak, w.nova_supplies, game.building.integrity])
	_check(w.victory and not w.failed and absi(siege_ticks - 2400) <= 2, "A real 40-second final fight runs to victory (%d siege ticks)" % siege_ticks)
	var all_combos: bool = true
	for pattern: int in [HazardAttack.Pattern.STEAM_TSUNAMI, HazardAttack.Pattern.STEAM_BURST, HazardAttack.Pattern.FIRENADO, HazardAttack.Pattern.SEISMIC_TIDE, HazardAttack.Pattern.QUADRANT_SEAL, HazardAttack.Pattern.CATACLYSM_NOVA]:
		all_combos = all_combos and patterns.has(pattern)
	_check(all_combos and kinds.has(HazardAttack.Kind.STEAM_COLUMN), "Real scheduling reaches every combo, including steam from meteors in water")
	_check(bad == 0 and launches.size() > 300, "Every final-boss launch had its exact telegraph (%d launches)" % launches.size())
	_check(peak < 128 and game.projectiles.rejected_count == 0 and game.projectiles.get_child_count() == 128, "Final fight peaks at %d live hazards in the fixed 128 pool" % peak)
	_check(w.nova_supplies >= 4, "Nova delivered %d extra repair/first-aid supplies" % w.nova_supplies)
	_check(game.projectiles.active_count() == 0 and game.telegraphs.pending.is_empty(), "Victory clears every final hazard")
	game.reset_game()
	_quiet()

# --------------------------------------------------------------- capture ----

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	root.size = Vector2i(1920, 1080)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_size = Vector2i(1920, 1080)
	await _frames(20)
	game.reset_game()
	_quiet()
	await _save(directory, "01-hud-preparation.png")
	var w: DisasterWaveManager = game.waves
	w.start_next_wave()
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	game.player.health = 85
	game.loot.column_kits = 2
	game.loot.barricade_kits = 1
	game.loot.activate_safety(game.building.rooms[6])
	game.loot.messages.clear()
	game.building.rooms[3].apply_damage(40)
	w.advance_wave(12.0)
	await _save(directory, "02-hud-storm-siege.png")
	Input.action_press(&"controls_help")
	await _save(directory, "03-hud-help-held.png")
	Input.action_release(&"controls_help")
	game.reset_game()
	_quiet()
	w.start_siege(DisasterWaveManager.Mode.CATACLYSM, true)
	game.titan.set_process(false)
	for progress: float in [.2, .45, .58, .8]:
		w.state = DisasterWaveManager.State.WAVE_INTRO
		w.transition_remaining = DisasterWaveManager.FINAL_INTRO_DURATION * (1.0 - progress)
		w.advance_wave(0.0)
		game.titan.advance(.03)
		await _save(directory, "04-fusion-%02d.png" % int(progress * 100))
	game.titan.set_process(true)
	w.advance_wave(DisasterWaveManager.FINAL_INTRO_DURATION)
	game.building.pacing_enabled = false
	await _frames(30)
	await _save(directory, "05-titan-idle.png")
	game.telegraphs.set_physics_process(true)
	game.projectiles.set_physics_process(true)
	for index: int in range(4):
		game.projectiles.clear()
		game.telegraphs.clear()
		game.titan.plan_pattern(w, index, 1 if index != 1 else 2)
		await _frames(18)
		await _save(directory, "06-skill-%d-warning.png" % (index + 1))
		await _frames(48)
		await _save(directory, "06-skill-%d-live.png" % (index + 1))
	game.projectiles.clear()
	game.telegraphs.clear()
	game.loot.set_physics_process(true)
	w.siege_remaining = 12.2
	w.autoplay = true
	await _frames(40)
	await _save(directory, "07-nova-warning.png")
	await _frames(48)
	await _save(directory, "07-nova-live.png")
	w.autoplay = false
	w.finish_wave()
	w.advance_wave(.5)
	game.mechanics.retreat_dust(.1)
	await _save(directory, "08-titan-retreat.png")
	w.advance_wave(.5)
	await _save(directory, "09-victory.png")

func _save(directory: String, filename: String) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == Vector2i(1920, 1080) and picture.save_png(directory.path_join(filename)) == OK, "Native capture %s (%s)" % [filename, picture.get_size()])

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _tap(key: int) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(2)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(1)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS " + message)
	else:
		failures += 1
		push_error("FAIL " + message)
