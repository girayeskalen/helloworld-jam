extends SceneTree
## Step 7: 50 s phases with a 0.90 -> 1.25 -> 1.45 tempo ramp, 5 s construction,
## the five storm and four quake choreographies, exact 0.55 s telegraphs with a white
## final flash, high-contrast bullets, dimmed furniture, graze rewards and BGM climax.
var game: MainGame
var checks: int = 0
var failures: int = 0
var launched: Array[HazardAttack] = []
var cues: Array[Dictionary] = []
const DT: float = 1.0 / 60.0
const FURNITURE: Array[int] = [HazardAttack.Kind.BOOK, HazardAttack.Kind.KNIFE, HazardAttack.Kind.PLATE, HazardAttack.Kind.SAW, HazardAttack.Kind.TOOL, HazardAttack.Kind.TOY, HazardAttack.Kind.POT, HazardAttack.Kind.CHAIR, HazardAttack.Kind.CHANDELIER, HazardAttack.Kind.WARDROBE]
const FIRE: Array[int] = [HazardAttack.Kind.FIREBALL, HazardAttack.Kind.FIRE_DART, HazardAttack.Kind.FIRE_BEAM, HazardAttack.Kind.FIRE_ZONE, HazardAttack.Kind.LOW_FLAME, HazardAttack.Kind.METEOR]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	root.unfocusable = true
	root.mouse_passthrough = true
	for node: Node in [game.player, game.waves, game.loot, game.mechanics, game.projectiles, game.telegraphs]: node.set_physics_process(false)
	await _frames(4)
	game.sound.bake_all_now()
	game.waves.attack_launched.connect(func(a: HazardAttack) -> void: launched.append(a))
	for boss: DisasterBoss in game.waves.bosses():
		boss.cued.connect(_on_cued.bind(boss))
	_ramp()
	_storm()
	_quake()
	_telegraphs_and_bullets()
	_graze()
	await _furniture_dim()
	_bgm_climax()
	for mode: int in range(4): _fight(mode)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): await _capture(argument.trim_prefix("--capture="))
	print("STEP7_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await _frames(2)
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _on_cued(_seconds: float, boss: DisasterBoss) -> void:
	cues.append({"time": game.waves.fight_elapsed(), "label": boss.pattern_label})

# ------------------------------------------------------------- helpers ----

func _battle(mode: int, floor_index: int = 1, x: float = 1000.0) -> DisasterWaveManager:
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	w.autoplay = false
	w.start_siege(mode as DisasterWaveManager.Mode, true)
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	game.telegraphs.clear()
	game.projectiles.clear()
	game.telegraphs.warning_bonus = 0.0
	_place(floor_index, x)
	launched.clear()
	cues.clear()
	return w

func _place(floor_index: int, x: float) -> void:
	var p: SiegePlayer = game.player
	p.current_floor = floor_index
	p.global_position = Vector2(x, game.building.floor_y(floor_index) - .5)
	p.previous_position = p.global_position
	p.velocity = Vector2.ZERO
	p.health = p.max_health
	p.hit_invulnerability = 0.0
	p.dash_remaining = 0.0
	p._graze_cooldown = 0.0

## Telegraphs + pool only (no new boss attacks), one fixed tick at a time.
func _simulate(seconds: float) -> void:
	for i: int in range(roundi(seconds / DT)):
		game.player.previous_position = game.player.global_position
		game.telegraphs._physics_process(DT)
		game.projectiles._physics_process(DT)

func _shot(origin: Vector2, velocity: Vector2, radius: float = 10.0, kind: HazardAttack.Kind = HazardAttack.Kind.WIND_ORB, source: int = 0) -> HazardProjectile:
	var a: HazardAttack = game.waves._attack(kind, game.player.current_floor, origin, velocity)
	a.radius = radius
	a.source = source
	a.lifetime = 1.4
	a.warning_confirmed = true
	a.warning_id = 1
	a.warning_duration = HazardAttack.STANDARD_WARNING
	a.warning_elapsed = HazardAttack.STANDARD_WARNING
	return game.projectiles.spawn(a)

## Probe-only collision test with an inactive pool entry (never launched).
func _hits(attack: HazardAttack, lift: float) -> bool:
	var p: SiegePlayer = game.player
	var probe: HazardProjectile = game.projectiles.entries[game.projectiles.entries.size() - 1]
	var standing: Vector2 = p.global_position
	p.global_position.y -= lift
	p.previous_position = p.global_position
	probe.attack = attack
	probe.contacted_player = false
	probe.global_position = Vector2(p.global_position.x, attack.origin.y)
	var hit: bool = probe.crosses_player(p, probe.global_position)
	probe.deactivate()
	p.global_position = standing
	p.previous_position = standing
	return hit

# ---------------------------------------------------------------- ramp ----

func _ramp() -> void:
	var w: DisasterWaveManager = game.waves
	_check(w.siege_duration == 50.0 and w.build_duration == 4.0 and w.preparation_duration == 4.0 and DisasterWaveManager.TOTAL_WAVES == 4, "Four 50-second phases, 4-second construction, 4-second first preparation")
	_check(is_equal_approx(DisasterWaveManager.tempo_at(0.0), .9) and is_equal_approx(DisasterWaveManager.tempo_at(13.9), .9), "0-15 s warm-up runs at 0.90x")
	_check(is_equal_approx(DisasterWaveManager.tempo_at(15.0), 1.0) and is_equal_approx(DisasterWaveManager.tempo_at(25.0), 1.125) and absf(DisasterWaveManager.tempo_at(33.99) - 1.2374) < .002, "15-35 s rises linearly from 1.00x toward 1.25x")
	_check(is_equal_approx(DisasterWaveManager.tempo_at(35.0), 1.45) and is_equal_approx(DisasterWaveManager.tempo_at(49.99), 1.45), "35-50 s climax holds 1.45x")
	var rising: bool = true
	var smooth: bool = true
	var previous: float = DisasterWaveManager.tempo_at(0.0)
	for i: int in range(1, 3001):
		var t: float = DisasterWaveManager.tempo_at(i * DT)
		rising = rising and t >= previous - .000001
		smooth = smooth and t - previous < .008
		previous = t
	_check(rising and smooth, "Tempo never drops and never jumps within one frame")
	w = _battle(DisasterWaveManager.Mode.STORM)
	_check(is_equal_approx(w.tempo(), .9) and is_equal_approx(w.bullet_tempo(), 1.0) and not w.is_climax(), "Fight start: 0.90x cadence and authored bullet speed")
	w.siege_remaining = w.siege_duration - 40.0
	_check(w.is_climax() and is_equal_approx(w.tempo(), 1.45) and is_equal_approx(w.bullet_tempo(), 1.225), "Climax: 1.45x cadence and bullets 1.225x faster")
	var raw: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB, 1, Vector2(700, 800), Vector2(400, 0))
	raw.lifetime = 2.0
	w.plan_attack(raw)
	var fast: HazardAttack = game.telegraphs.pending[0]
	_check(is_equal_approx(fast.velocity.x, 490.0) and is_equal_approx(fast.lifetime, 2.0 / 1.225) and fast.point_at(fast.lifetime).distance_to(raw.point_at(raw.lifetime)) < .01 and is_equal_approx(fast.warning_duration, .55), "Faster climax bullets keep their exact endpoint and the 0.55 s warning")
	game.telegraphs.clear()
	w.siege_remaining = w.siege_duration
	w._storm_clock = 1.0
	w.advance_wave(.1, .1)
	_check(is_equal_approx(w._storm_clock, 1.0 - .1 * .9), "Warm-up attack clock runs at 0.90x")
	w.siege_remaining = 10.0
	w._storm_clock = 1.0
	w.advance_wave(.1, .1)
	_check(is_equal_approx(w._storm_clock, 1.0 - .1 * 1.45), "Climax attack clock runs at 1.45x")
	w = _battle(DisasterWaveManager.Mode.CATACLYSM)
	w.siege_remaining = 10.0
	_check(is_equal_approx(w.final_tempo(), 1.225) and is_equal_approx(w.bullet_tempo(), 1.1125), "Final phase takes half of the ramp on top of its nova")

# --------------------------------------------------------------- storm ----

func _storm() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM, 1, 1000.0)
	var b: ApartmentBuilding = game.building
	var storm: DisasterBoss = game.storm
	var p: SiegePlayer = game.player
	# --- A: İkiz Girdap Çarkı.
	storm.plan_pattern(w, 0, 1)
	var arms: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var center: Vector2 = BossPatterns.core_point(b)
	var shape_ok: bool = arms.size() == 36
	var clockwise: bool = true
	var timed: bool = true
	var leads: int = 0
	for i: int in range(arms.size()):
		var a: HazardAttack = arms[i]
		var k: int = i / 4
		var arm: int = i % 4
		leads += 1 if a.lead else 0
		shape_ok = shape_ok and a.origin.distance_to(center) < .01 and a.pattern == HazardAttack.Pattern.PINWHEEL and a.source == 0
		shape_ok = shape_ok and absf(angle_difference(arms[k * 4].velocity.angle() + arm * PI * .5, a.velocity.angle())) < .001
		timed = timed and is_equal_approx(a.warning_delay, k * .1) and is_equal_approx(a.warning_duration, .55)
		if k > 0 and arm == 0:
			clockwise = clockwise and absf(angle_difference(arms[(k - 1) * 4].velocity.angle(), a.velocity.angle()) - deg_to_rad(11.0)) < .001
	_check(shape_ok and leads == 1 and storm.pattern_label == BossPatterns.STORM_LABELS[0], "A: four arms 90 degrees apart from one storm eye at the building centre")
	_check(clockwise and timed, "A: the arms turn clockwise 11 degrees per 0.1 s step, every step warned for exactly 0.55 s")
	_check(is_equal_approx(storm.next_delay, BossPatterns.STORM_BEATS[0]), "A: the choreography sets its own recovery beat")
	# --- B: Güvenli Kat Ruleti.
	game.telegraphs.clear()
	_place(1, 1000.0)
	storm.plan_pattern(w, 1, 1)
	var walls: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var safe: Array[int] = storm.safe_floors.duplicate()
	_check(safe.size() == 2 and absi(safe[0] - 1) == 1 and absi(safe[1] - safe[0]) == 1, "B: the first safe floor is next to the player, the second next to the first %s" % [safe])
	var first_wave: Dictionary = {}
	var second_wave: Dictionary = {}
	var walls_ok: bool = walls.size() == 6
	for a: HazardAttack in walls:
		walls_ok = walls_ok and a.kind == HazardAttack.Kind.ROW_SWEEP and a.pattern == HazardAttack.Pattern.SAFE_FLOOR and is_equal_approx(a.warning_duration, HazardAttack.SAFE_FLOOR_WARNING)
		if a.warning_delay <= 0.0:
			first_wave[a.floor_index] = true
		else:
			second_wave[a.floor_index] = true
	var travel: float = walls[0].lifetime
	var second_delay: float = walls[walls.size() - 1].warning_delay
	_check(walls_ok and first_wave.size() == 3 and not first_wave.has(safe[0]) and second_wave.size() == 3 and not second_wave.has(safe[1]), "B: wind corridors cover the three other floors with a 0.65 s warning")
	_check(second_delay >= HazardAttack.SAFE_FLOOR_WARNING + travel, "B: the second roulette starts only after the first sweep has passed")
	_simulate(.3)
	_place(safe[0], 1000.0)
	_simulate(.35 + travel + .1)
	var after_first: float = p.health
	_place(safe[1], 1000.0)
	_simulate(second_delay + .1)
	_check(after_first == p.max_health and p.health == p.max_health, "B: reaching each safe floor in time avoids both corridor sweeps")
	game.telegraphs.clear()
	game.projectiles.clear()
	_place(1, 1000.0)
	storm.plan_pattern(w, 1, 1)
	_simulate(HazardAttack.SAFE_FLOOR_WARNING + travel + .1)
	_check(p.health < p.max_health, "B: staying on a swept floor is hit")
	game.telegraphs.clear()
	game.projectiles.clear()
	# --- C: Sinüs Rüzgâr Tüneli.
	_place(1, 1000.0)
	storm.plan_pattern(w, 2, 1)
	var lower: Array[HazardAttack] = []
	var upper: Array[HazardAttack] = []
	for a: HazardAttack in game.telegraphs.pending:
		if a.origin.y > b.floor_y(1) - 60.0:
			lower.append(a)
		else:
			upper.append(a)
	var stream_ok: bool = lower.size() == 9 and upper.size() == 9
	for i: int in range(mini(lower.size(), upper.size())):
		stream_ok = stream_ok and lower[i].motion == HazardAttack.Motion.WAVE and lower[i].velocity.x > 0 and lower[i].velocity.y == 0 and lower[i].floor_index == 1 and is_equal_approx(lower[i].warning_delay, i * .075)
		stream_ok = stream_ok and lower[i].point_at(.7).distance_to(lower[0].point_at(.7)) < .01 and upper[i].point_at(.7).distance_to(upper[0].point_at(.7)) < .01
	_check(stream_ok, "C: two parallel 9-shot sine streams flow left to right on the player's floor along shared paths")
	var lo: HazardAttack = lower[0]
	var hi: HazardAttack = upper[0]
	var crest_x: float = 0.0
	var crest_y: float = INF
	var trough_x: float = 0.0
	var trough_y: float = -INF
	var tunnel: float = INF
	var x: float = b.interior_left() + 40.0
	while x < b.interior_right() - 40.0:
		var t: float = (x - lo.origin.x) / lo.velocity.x
		var low_y: float = lo.point_at(t).y
		tunnel = minf(tunnel, (low_y - lo.radius) - (hi.point_at(t).y + hi.radius))
		if low_y < crest_y:
			crest_y = low_y
			crest_x = x
		if low_y > trough_y:
			trough_y = low_y
			trough_x = x
		x += 4.0
	var standing_clear: float = b.floor_y(1) - .5 - 36.0 - lo.radius - 12.0
	_check(crest_y < standing_clear and trough_y > standing_clear, "C: crests pass over a standing player, troughs force a jump")
	_check(tunnel >= 60.0, "C: the tunnel between both streams stays %.0f px tall (capsule 48 px)" % tunnel)
	game.telegraphs.clear()
	_place(1, crest_x)
	storm.plan_pattern(w, 2, 1)
	_simulate(.55 + 8 * .075 + lo.lifetime + .1)
	var under_crest: float = p.health
	game.telegraphs.clear()
	game.projectiles.clear()
	_place(1, trough_x)
	storm.plan_pattern(w, 2, 1)
	_simulate(.55 + 8 * .075 + lo.lifetime + .1)
	_check(under_crest == p.max_health and p.health < p.max_health, "C: standing under a crest is safe, standing in a trough is hit")
	game.telegraphs.clear()
	game.projectiles.clear()
	# --- D: Çapraz Rüzgâr Makası.
	_place(1, 1400.0)
	storm.plan_pattern(w, 3, 1)
	var blades: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var target: Vector2 = Vector2(clampf(1400.0, b.interior_left() + 260.0, b.interior_right() - 60.0), b.floor_y(1) - 60.0)
	var aimed: bool = blades.size() == 12
	var crossing: bool = true
	var spreads: Array[float] = []
	for group: int in range(4 if blades.size() == 12 else 0):
		var middle: HazardAttack = blades[group * 3 + 1]
		var offset: Vector2 = target - middle.origin
		aimed = aimed and absf(offset.cross(middle.velocity.normalized())) < 1.0 and offset.length() / middle.velocity.length() <= middle.lifetime + .001
		spreads.append(absf(angle_difference(blades[group * 3].velocity.angle(), blades[group * 3 + 2].velocity.angle())))
		crossing = crossing and (middle.velocity.y > 0) == (group % 2 == 0)
		for i: int in range(3):
			var blade: HazardAttack = blades[group * 3 + i]
			aimed = aimed and blade.pattern == HazardAttack.Pattern.SCISSOR and blade.kind == HazardAttack.Kind.WIND_BLADE and is_equal_approx(blade.warning_delay, .45 if group >= 2 else 0.0)
	_check(aimed, "D: top-left and bottom-left blades converge on the player's room")
	_check(crossing, "D: the two corner fans cross in an X")
	_check(spreads.size() == 4 and spreads[2] < spreads[0] * .6 and spreads[3] < spreads[1] * .6, "D: the second X follows 0.45 s later and is narrower")
	game.telegraphs.clear()
	# --- E: Siklon Halkası & İtme.
	_place(1, 1000.0)
	storm.plan_pattern(w, 4, 1)
	_check(game.telegraphs.gust_warning_left > 0.0 and game.telegraphs.gust_direction > 0.0 and is_equal_approx(game.telegraphs.gust_strength, w.gust_strength * .7), "E: a gentle telegraphed push opens the cyclone")
	var rings: Array = [[], [], []]
	for a: HazardAttack in game.telegraphs.pending:
		(rings[clampi(roundi(a.warning_delay / .5), 0, 2)] as Array).append(a)
	var floor_line: float = b.floor_y(1)
	var low_ok: bool = (rings[0] as Array).size() == 6
	var head_ok: bool = (rings[1] as Array).size() == 6
	var away: bool = true
	for a: HazardAttack in rings[0]:
		away = away and absf(a.origin.x - 1000.0) >= b.room_width
		for s: int in range(21):
			var y: float = a.point_at(a.lifetime * s / 20.0).y
			low_ok = low_ok and y >= floor_line - 24.0 and y <= floor_line - 4.0
	for a: HazardAttack in rings[1]:
		for s: int in range(21):
			var y: float = a.point_at(a.lifetime * s / 20.0).y
			head_ok = head_ok and y <= floor_line - 74.0 and y >= floor_line - 94.0
	var angles: Array[float] = []
	for a: HazardAttack in rings[2]: angles.append(fposmod(a.spiral_angle, TAU))
	angles.sort()
	var gaps: int = 0
	for i: int in range(angles.size()):
		var next: float = angles[(i + 1) % angles.size()] + (TAU if i == angles.size() - 1 else 0.0)
		gaps += 1 if next - angles[i] > deg_to_rad(45.0) else 0
	_check(low_ok and away, "E: ring 1 skims the floor (jump it) and opens a room away from the player")
	_check(head_ok, "E: ring 2 passes at head height (stay on the ground)")
	_check(angles.size() == 8 and gaps == 4, "E: ring 3 is a full ring with four gaps")
	game.telegraphs.clear()
	# --- Movement: swoop, tall vs compact tornado core, framing.
	w = _battle(DisasterWaveManager.Mode.STORM, 2, 1000.0)
	storm.plan_pattern(w, 2, 2)
	for i: int in range(30): storm.advance(DT)
	var core: Vector2 = Vector2(storm._home.x + 40.0, b.floor_y(2) + 30.0)
	var rig_rings: Array = storm.storm_rig()["rings"]
	var height: float = Vector2(rig_rings[0]["center"]).y - Vector2(rig_rings[rig_rings.size() - 1]["center"]).y
	_check(storm.focus > .99 and storm.position.distance_to(core) < 30.0 and height < 200.0, "Tunnel beat condenses the storm into a one-floor tornado core at that floor (%.0f px tall)" % height)
	storm.plan_pattern(w, 3, 2)
	var start: Vector2 = storm.position
	var goal: Vector2 = storm._target
	storm.advance(.15)
	_check(start.distance_to(goal) > 150.0 and storm.position.distance_to(goal) < start.distance_to(goal) * .1 + 1.0, "The storm swoops to its next post in 0.15 s")
	for i: int in range(30): storm.advance(DT)
	_check(storm.focus < .01, "Other beats stretch the storm back to full height")
	var framed: bool = true
	for setup: Vector2i in [Vector2i(4, 0), Vector2i(4, 3), Vector2i(0, 3), Vector2i(0, 0)]:
		game.telegraphs.clear()
		storm.plan_pattern(w, setup.x, setup.y)
		for i: int in range(40): storm.advance(DT)
		var box: Rect2 = storm.pose_bounds()
		var screen: Rect2 = _screen_rect(Rect2(storm.global_position + box.position, box.size))
		framed = framed and screen.position.x >= 0 and screen.end.x <= 1920 and screen.position.y >= 70 and screen.end.y <= GameHUD.BOSS_BAR.position.y
	_check(framed, "Tall and compact storm poses stay inside the frame and above the boss bar")
	game.telegraphs.clear()

# --------------------------------------------------------------- quake ----

func _quake() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.EARTHQUAKE, 1, 1031.0)
	var b: ApartmentBuilding = game.building
	var golem: DisasterBoss = game.earthquake
	var p: SiegePlayer = game.player
	# --- 1: Dama Tahtası Sütun Çökmesi.
	golem.plan_pattern(w, 0, 1)
	var crush: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var columns_ok: bool = crush.size() == 16
	var first: Dictionary = {}
	var second: Dictionary = {}
	for a: HazardAttack in crush:
		var column: int = b.column_at(a.area.get_center().x)
		var room: RoomDiorama = b.room_at(a.floor_index, column)
		columns_ok = columns_ok and a.kind == HazardAttack.Kind.ROCKFALL and a.source == 1 and Rect2(room.global_position, room.room_size).encloses(a.area) and is_equal_approx(a.warning_duration, .55) and TelegraphSystem.warning_color(a) == TelegraphSystem.QUAKE_WARNING
		if a.warning_delay <= 0.0:
			first[column] = int(first.get(column, 0)) + 1
		else:
			second[column] = int(second.get(column, 0)) + 1
			columns_ok = columns_ok and is_equal_approx(a.warning_delay, .5)
	_check(columns_ok and first.size() == 2 and int(first.get(0, 0)) == 4 and int(first.get(2, 0)) == 4 and second.size() == 2 and int(second.get(1, 0)) == 4 and int(second.get(3, 0)) == 4, "1: orange room columns A+C collapse on every floor, B+D 0.5 s later")
	var trembling: bool = false
	for prop: BuildingProp in b.props: trembling = trembling or prop._shake_left > 0.0
	_check(trembling and golem.pattern_label == BossPatterns.QUAKE_LABELS[0], "1: unsecured furniture only trembles (visual) during the wind-up")
	_simulate(1.0)
	var during_first: float = p.health
	_place(1, b.global_position.x + b.room_width * .5)
	_simulate(1.0)
	_check(during_first == p.max_health and p.health == p.max_health, "1: waiting in column B, then stepping into cleared column A is safe")
	game.telegraphs.clear()
	game.projectiles.clear()
	_place(1, 1031.0)
	golem.plan_pattern(w, 0, 1)
	_simulate(2.0)
	_check(p.health < p.max_health, "1: staying in column B is crushed by the second strike")
	game.telegraphs.clear()
	game.projectiles.clear()
	# --- 2: Yürüyen Sismik Fay Dalgası.
	_place(1, 1031.0)
	golem.plan_pattern(w, 1, 1)
	var faults: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var fault_ok: bool = faults.size() == 4
	var floors: Dictionary = {}
	var slams: int = 0
	for i: int in range(faults.size()):
		var a: HazardAttack = faults[i]
		floors[a.floor_index] = true
		slams += 1 if a.starts_slam else 0
		fault_ok = fault_ok and a.kind == HazardAttack.Kind.SHOCKWAVE and a.velocity.x < 0 and a.velocity.y == 0 and absf(a.origin.x - (b.interior_right() - 10.0)) < .1 and absf(a.origin.y - (b.floor_y(a.floor_index) - 13.0)) < .1 and is_equal_approx(a.warning_delay, i * .16)
	_check(fault_ok and floors.size() == 4 and slams == 1, "2: one planted fist sends a right-to-left spike wave along every floor in turn")
	var floor1: HazardAttack = faults[1] if faults.size() == 4 else null
	_check(floor1 != null and _hits(floor1, 0.0) and not _hits(floor1, 60.0), "2: the spike wave hits a standing player and a jump clears it")
	game.telegraphs.clear()
	# --- 3: Sismik Merkez Halkaları.
	golem.plan_pattern(w, 2, 1)
	var ring: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var center: Vector2 = BossPatterns.core_point(b)
	var aligned: bool = ring.size() == 36
	for i: int in range(ring.size()):
		var a: HazardAttack = ring[i]
		var index: int = i / 12
		var slot: int = i % 12
		aligned = aligned and a.kind == HazardAttack.Kind.SHARD and a.origin.distance_to(center) < .01 and is_equal_approx(a.warning_delay, index * .45)
		aligned = aligned and absf(angle_difference(ring[slot].velocity.angle(), a.velocity.angle())) < .001
		aligned = aligned and absf(angle_difference(ring[index * 12].velocity.angle() + slot * TAU / 12.0, a.velocity.angle())) < .001
	_check(aligned, "3: three symmetric 12-rock rings from the centre column keep the same open corridors")
	game.telegraphs.clear()
	# --- 4: Kat Ezici Balyoz.
	_place(1, 1031.0)
	golem.plan_pattern(w, 3, 1)
	var rocks: Array[HazardAttack] = game.telegraphs.pending.duplicate()
	var boulders_ok: bool = rocks.size() == 4
	var by_floor: Dictionary = {}
	for a: HazardAttack in rocks:
		var lift: float = b.floor_y(a.floor_index) - a.origin.y
		boulders_ok = boulders_ok and a.kind == HazardAttack.Kind.CONCRETE and a.motion == HazardAttack.Motion.LINEAR and a.velocity == Vector2(-540, 0) and (is_equal_approx(lift, 24.0) or is_equal_approx(lift, 98.0))
		if not by_floor.has(a.floor_index): by_floor[a.floor_index] = []
		(by_floor[a.floor_index] as Array).append(lift)
	var swapped: bool = by_floor.size() == 2
	for f: int in by_floor:
		var lifts: Array = by_floor[f]
		swapped = swapped and lifts.size() == 2 and not is_equal_approx(float(lifts[0]), float(lifts[1]))
	_check(boulders_ok and by_floor.has(1) and (by_floor.has(0) or by_floor.has(2)), "4: boulders roll right-to-left on the player's floor and the adjacent one")
	_check(swapped and rocks.size() == 4 and is_equal_approx(rocks[2].warning_delay, .62) and is_equal_approx(rocks[3].warning_delay, .62), "4: each floor gets one low and one high boulder; the second pair swaps 0.62 s later")
	var low: HazardAttack = null
	var high: HazardAttack = null
	for a: HazardAttack in rocks:
		if a.floor_index != 1: continue
		if is_equal_approx(b.floor_y(1) - a.origin.y, 24.0): low = a
		else: high = a
	_check(low != null and _hits(low, 0.0) and not _hits(low, 60.0), "4: the low boulder must be jumped")
	_check(high != null and not _hits(high, 0.0) and _hits(high, 60.0), "4: stay on the ground under the high boulder")
	game.telegraphs.clear()

# -------------------------------------------------- telegraphs/bullets ----

func _telegraphs_and_bullets() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM, 1, 1000.0)
	var b: ApartmentBuilding = game.building
	var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB, 1, Vector2(600, 900), Vector2(400, 0))
	a.lifetime = 2.0
	w.plan_attack(a, 2.0)
	var queued: HazardAttack = game.telegraphs.pending[0]
	_check(is_equal_approx(queued.warning_duration, .55) and queued.warning_lines.size() == 25, "Ordinary telegraphs last exactly 0.55 s and draw one thin laser polyline")
	queued.warning_elapsed = queued.warning_duration - .13
	var early: bool = TelegraphSystem.is_flashing(queued)
	queued.warning_elapsed = queued.warning_duration - .11
	var late: bool = TelegraphSystem.is_flashing(queued)
	queued.warning_delay = .3
	_check(not early and late and not TelegraphSystem.is_flashing(queued), "Telegraphs flash white only in their last 0.12 s (never while still queued)")
	game.telegraphs.clear()
	var zone: HazardAttack = w._attack(HazardAttack.Kind.ROCKFALL, 1, Vector2(650, 870), Vector2.ZERO)
	zone.area = Rect2(500, b.floor_y(1) - 196.0, 300, 196)
	zone.lifetime = .38
	zone.source = 1
	w.plan_attack(zone)
	var row: HazardAttack = w._attack(HazardAttack.Kind.ROW_SWEEP, 2, Vector2(458, b.floor_y(2) - 87.0), Vector2(2400, 0))
	row.row_height = 174
	row.lifetime = .6
	w.plan_attack(row)
	var pending: Array[HazardAttack] = game.telegraphs.pending
	_check(pending.size() == 2 and pending[0].warning_lines.is_empty() and pending[1].warning_lines.is_empty() and is_equal_approx(pending[0].warning_duration, .55) and is_equal_approx(pending[1].warning_duration, 1.0), "Room fills and floor bands need no laser; floor walls keep their 1.0 s evacuation warning")
	game.telegraphs.clear()
	_check(TelegraphSystem.STORM_WARNING == Color("00f0ff") and TelegraphSystem.QUAKE_WARNING == Color("ff9500") and TelegraphSystem.FLOOD_WARNING == Color("2b7fff") and TelegraphSystem.FLASH == Color.WHITE, "Telegraphs use the boss neon; the final flash is pure white")
	_check(HazardProjectile.OUTLINE == Color("05070a") and HazardProjectile.CORE == Color.WHITE and HazardProjectile.NEON[0] == Color("00f0ff") and HazardProjectile.NEON[1] == Color("ff9500") and HazardProjectile.NEON[2] == Color("2b7fff"), "Bullets: near-black #05070a rim, boss neon body, white core")
	_check(absf(HazardProjectile.OUTLINE_WIDTH * game.base_zoom - 3.0) < .25, "The rim is ~3 px on the 1920x1080 screen")
	var keys_ok: bool = game.projectiles.body_textures.size() == 12
	for shape: int in range(4):
		for source: int in range(3): keys_ok = keys_ok and game.projectiles.body_textures.has(shape * 10 + source)
	_check(keys_ok, "12 prewarmed body textures: 4 silhouettes x 3 boss neons")
	_check(HazardProjectile.shape_of(HazardAttack.Kind.WIND_BLADE) == HazardProjectile.Shape.BLADE and HazardProjectile.shape_of(HazardAttack.Kind.CONCRETE) == HazardProjectile.Shape.ROCK and HazardProjectile.shape_of(HazardAttack.Kind.SHOCKWAVE) == HazardProjectile.Shape.SPIKE and HazardProjectile.shape_of(HazardAttack.Kind.WIND_ORB) == HazardProjectile.Shape.ORB, "Blades, rocks, spikes and orbs keep distinct silhouettes")
	var shot: HazardProjectile = _shot(Vector2(700, 800), Vector2(300, 0), 14.0, HazardAttack.Kind.WIND_BLADE, 1)
	_check(shot != null and shot.body_texture == game.projectiles.body_textures[HazardProjectile.Shape.BLADE * 10 + 1] and shot.glow_color() == HazardProjectile.NEON[1], "A spawned shot draws the cached body of its own shape and neon")
	game.projectiles.clear()

# --------------------------------------------------------------- graze ----

func _graze() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM, 0, 1000.0)
	var p: SiegePlayer = game.player
	var sound: SoundManager = game.sound
	var head: float = p.global_position.y - 36.0
	p.stamina = 40.0
	sound.advance(.2)
	var plays: int = sound.plays("graze")
	_shot(Vector2(800, head - 22.0 - 15.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 1 and is_equal_approx(p.stamina, 65.0) and p.health == p.max_health, "Graze: a 15 px near miss grants +25 dash energy once, without damage")
	_check(game.feedback.grazes.size() == 1 and sound.plays("graze") == plays + 1, "Graze: spark ring, floating label and electric tick")
	_check(WorldLabels.GRAZE_TEXT == "SIYRILDI! +ENERJİ", "Graze label reads SIYRILDI! +ENERJİ")
	_place(0, 1000.0)
	_shot(Vector2(800, head - 22.0 - 30.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 1, "Graze: a 30 px pass is outside the 18-26 px window")
	_place(0, 1000.0)
	_shot(Vector2(800, p.global_position.y - 24.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 1 and p.health < p.max_health, "Graze: a direct hit hurts and never counts")
	_place(0, 1000.0)
	_shot(Vector2(1000, head - 200.0), Vector2(0, 600))
	_simulate(.6)
	_check(w.graze_count == 1 and p.health < p.max_health, "Graze: a shot that enters the window and then hits pays nothing")
	_place(0, 1000.0)
	p.stamina = 10.0
	_shot(Vector2(800, head - 37.0), Vector2(600, 0))
	_shot(Vector2(1200, head - 37.0), Vector2(-600, 0))
	_simulate(.6)
	_check(w.graze_count == 2 and is_equal_approx(p.stamina, 35.0), "Graze: two simultaneous near misses pay once (0.12 s cooldown)")
	_place(0, 1000.0)
	p.dash_remaining = .25
	_shot(Vector2(800, head - 37.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 3, "Graze also pays out mid-dash")
	_place(0, 1000.0)
	p.global_position.y -= 70.0
	p.previous_position = p.global_position
	_shot(Vector2(800, p.global_position.y - 12.0 + 22.0 + 15.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 4, "Graze works while airborne (shot skims under the feet)")
	_place(0, 1000.0)
	p.hit_invulnerability = .8
	_shot(Vector2(800, head - 37.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 4, "No graze while blinking after a hit")
	_place(0, 1000.0)
	p.stamina = 90.0
	_shot(Vector2(800, head - 37.0), Vector2(600, 0))
	_simulate(.6)
	_check(w.graze_count == 5 and p.stamina == 100.0, "Graze energy caps at 100")
	game.projectiles.clear()
	game.feedback.clear()

# ------------------------------------------------------- furniture/BGM ----

func _furniture_dim() -> void:
	var b: ApartmentBuilding = game.building
	var sofa: BuildingProp = null
	var pillar: BuildingProp = null
	var window: BuildingProp = null
	for prop: BuildingProp in b.props:
		if sofa == null and prop.kind == BuildingProp.Kind.SOFA: sofa = prop
		if pillar == null and prop.kind == BuildingProp.Kind.PILLAR: pillar = prop
		if window == null and prop.kind == BuildingProp.Kind.WINDOW: window = prop
	game.reset_game()
	await _frames(40)
	_check(sofa != null and b.combat_dim == 0.0 and sofa.self_modulate == Color.WHITE, "Preparation shows furniture at full value")
	var revision: int = sofa.static_revision
	_battle(DisasterWaveManager.Mode.STORM)
	await _frames(40)
	var tint: Color = sofa.self_modulate
	_check(is_equal_approx(b.combat_dim, 1.0) and tint.is_equal_approx(ApartmentBuilding.COMBAT_DIM_TINT), "During a siege furniture eases to the matte combat tint")
	_check(tint.get_luminance() > .66 and tint.get_luminance() < .72, "Siege furniture tint %.2f lands ~25%% darker on screen under the additive lamps" % tint.get_luminance())
	_check((pillar == null or pillar.self_modulate == Color.WHITE) and (window == null or window.self_modulate == Color.WHITE), "Pillars and windows keep full value")
	_check(sofa.static_revision == revision, "Dimming never re-renders cached furniture")
	game.reset_game()
	await _frames(40)
	_check(b.combat_dim == 0.0 and sofa.self_modulate == Color.WHITE, "Furniture returns to full value between phases")

func _bgm_climax() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM)
	var sound: SoundManager = game.sound
	var stream: AudioStream = sound.bgm_player.stream
	sound.bgm_player.pitch_scale = 1.0
	w.siege_remaining = 30.0
	for i: int in range(60): sound.advance(DT)
	_check(is_equal_approx(sound.bgm_player.pitch_scale, 1.0), "Before the climax the score keeps its normal tempo")
	w.siege_remaining = 12.0
	var steady: bool = true
	var last: float = sound.bgm_player.pitch_scale
	for i: int in range(60):
		sound.advance(DT)
		steady = steady and sound.bgm_player.pitch_scale - last <= .0021
		last = sound.bgm_player.pitch_scale
	_check(is_equal_approx(sound.bgm_player.pitch_scale, SoundManager.CLIMAX_PITCH) and steady and sound.bgm_player.stream == stream, "Climax eases the same BGM stream to 1.05x without a jump")
	game.reset_game()
	for i: int in range(60): sound.advance(DT)
	_check(is_equal_approx(sound.bgm_player.pitch_scale, 1.0), "Outside the climax the score returns to normal tempo")

# ---------------------------------------------------------- full fights ----

func _fight(mode: int) -> void:
	var w: DisasterWaveManager = _battle(mode, 1, 1000.0)
	var title: String = ["storm", "quake", "flood", "final"][mode]
	game.building.pacing_enabled = true
	game.projectiles.peak_active = 0
	var rejected: int = game.projectiles.rejected_count
	var p: SiegePlayer = game.player
	var ticks: int = 0
	while w.state == DisasterWaveManager.State.SIEGE_PHASE and not w.failed and ticks < 3300:
		p.previous_position = p.global_position
		w.advance_wave(DT)
		game.telegraphs._physics_process(DT)
		game.projectiles._physics_process(DT)
		ticks += 1
	_check(not w.failed and w.state == DisasterWaveManager.State.WAVE_OUTRO and absi(ticks - 3000) <= 2, "%s: the real fight lasts exactly 50 s (%d ticks)" % [title, ticks])
	var early: Array[float] = []
	var late: Array[float] = []
	for cue: Dictionary in cues:
		var t: float = cue["time"]
		if t < DisasterWaveManager.WARMUP_END: early.append(t)
		elif t >= DisasterWaveManager.RAMP_END: late.append(t)
	var early_gap: float = (early.back() - early.front()) / maxf(1.0, early.size() - 1) if early.size() > 1 else 0.0
	var late_gap: float = (late.back() - late.front()) / maxf(1.0, late.size() - 1) if late.size() > 1 else 0.0
	_check(early.size() >= 3 and late.size() >= 3 and late_gap > 0.0 and late_gap < early_gap / 1.3, "%s: the climax changes patterns %.2fx as often (%.2f s -> %.2f s)" % [title, early_gap / maxf(.001, late_gap), early_gap, late_gap])
	if mode <= 1:
		var labels: Array = BossPatterns.STORM_LABELS if mode == 0 else BossPatterns.QUAKE_LABELS
		var ordered: bool = cues.size() >= 15
		for i: int in range(cues.size()): ordered = ordered and cues[i]["label"] == labels[i % labels.size()]
		_check(ordered, "%s: choreographies cycle in the authored order (%d beats)" % [title, cues.size()])
		var allowed: Array = [HazardAttack.Kind.WIND_ORB, HazardAttack.Kind.ROW_SWEEP, HazardAttack.Kind.WIND_BLADE] if mode == 0 else [HazardAttack.Kind.ROCKFALL, HazardAttack.Kind.SHOCKWAVE, HazardAttack.Kind.SHARD, HazardAttack.Kind.CONCRETE]
		var only: bool = not launched.is_empty()
		for a: HazardAttack in launched: only = only and a.kind in allowed
		_check(only, "%s: only the boss's own geometric attacks reach the screen (no room objects)" % title)
	if mode == 0:
		var slowest: float = INF
		var fastest: float = 0.0
		for a: HazardAttack in launched:
			if a.pattern != HazardAttack.Pattern.PINWHEEL: continue
			slowest = minf(slowest, a.velocity.length())
			fastest = maxf(fastest, a.velocity.length())
		_check(is_equal_approx(slowest, 330.0) and is_equal_approx(fastest, 330.0 * 1.225), "storm: pinwheel bullets speed up from 330 to %.0f px/s at the climax" % fastest)
	var bad: int = 0
	var exact: bool = true
	var furniture: int = 0
	var fire: int = 0
	for a: HazardAttack in launched:
		if not a.is_armed() or a.warning_elapsed < a.minimum_warning() - .00001: bad += 1
		exact = exact and is_equal_approx(a.warning_duration, maxf(HazardAttack.STANDARD_WARNING + a.warning_extension, a.minimum_warning()))
		furniture += 1 if a.kind in FURNITURE else 0
		fire += 1 if a.kind in FIRE else 0
	_check(bad == 0 and exact, "%s: all %d launches were telegraphed for exactly their rule (0.55 s standard)" % [title, launched.size()])
	_check(furniture == 0 and fire == 0, "%s: no thrown furniture and no fire/meteor attacks" % title)
	_check(game.projectiles.peak_active < 128 and game.projectiles.rejected_count == rejected, "%s: the 128 pool stays bounded (peak %d)" % [title, game.projectiles.peak_active])
	game.reset_game()

# ------------------------------------------------------------- capture ----

func _capture(directory: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(directory)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	for node: Node in [game.player, game.projectiles, game.telegraphs]: node.set_physics_process(true)
	await _frames(40)
	game.reset_game()
	await _frames(40)
	await _save(directory, "furniture-preparation.png")
	_battle(DisasterWaveManager.Mode.STORM, 0, 1000.0)
	await _frames(40)
	await _save(directory, "furniture-siege-dim.png")
	var shots: Array = [
		[0, 0, .42, "storm-a-pinwheel-warning.png"], [0, 0, 1.3, "storm-a-pinwheel.png"],
		[0, 1, .3, "storm-b-roulette-warning.png"], [0, 1, .58, "storm-b-roulette-flash.png"], [0, 1, .75, "storm-b-roulette-sweep.png"], [0, 1, 1.75, "storm-b-roulette-second.png"],
		[0, 2, .4, "storm-c-tunnel-warning.png"], [0, 2, 1.6, "storm-c-tunnel.png"],
		[0, 3, .35, "storm-d-scissor-warning.png"], [0, 3, 1.05, "storm-d-scissor.png"],
		[0, 4, 1.4, "storm-e-cyclone.png"],
		[1, 0, .3, "quake-1-checker-warning.png"], [1, 0, .72, "quake-1-checker-crush.png"],
		[1, 1, 1.1, "quake-2-fault-wave.png"], [1, 2, 1.3, "quake-3-tectonic-rings.png"], [1, 3, 1.2, "quake-4-boulders.png"],
		[2, 0, 1.0, "flood-neon-bullets.png"], [3, 1, 1.2, "final-neon-bullets.png"],
	]
	for shot: Array in shots:
		var w: DisasterWaveManager = _battle(int(shot[0]), 1, 1000.0)
		await _frames(30)
		var boss: DisasterBoss = w.bosses()[int(shot[0])]
		boss.plan_pattern(w, int(shot[1]), 1)
		await _frames(roundi(float(shot[2]) * 60.0))
		await _save(directory, String(shot[3]))
	_battle(DisasterWaveManager.Mode.STORM, 0, 1000.0)
	await _frames(20)
	_shot(Vector2(760, game.player.global_position.y - 36.0 - 37.0), Vector2(600, 0))
	await _frames(26)
	await _save(directory, "graze-spark.png")
	game.reset_game()

## World rect -> 1920x1080 screen rect through the camera and the pixel upscale.
func _screen_rect(world: Rect2) -> Rect2:
	var a: Vector2 = game.world_to_screen(world.position)
	return Rect2(a, game.world_to_screen(world.end) - a)

func _save(directory: String, filename: String) -> void:
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Rendered " + filename)

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)
