class_name SiegeMechanics
extends Node2D
## Nine real modules share the swept projectile pool; effects never spawn attacks.
@export var custom_sprite: Texture2D
const CYAN: Color = Color("71e5e1")
const AMBER: Color = Color("ffc17a")
const DOME_RECHARGE: float = 6.0
const TIME_RADIUS: float = 220.0
const ORBIT_RADIUS: float = 73.0
const ORBIT_SIZE: float = 15.0
signal blocked(point: Vector2)
signal activated(id: int, point: Vector2)
var game: MainGame
var drone_position: Vector2
var drone_target: RoomDiorama
var drone_clock: float = 6.5
var drone_repairs: int = 0
var shock_clears: int = 0
var armor_blocks: int = 0
var dome_ready: bool = false
var dome_cooldown: float = 0.0
var stationary_time: float = 0.0
var bag_used: bool = false
var bag_activations: int = 0
var repulse_remaining: float = 0.0
var time_remaining: float = 0.0
var freeze_remaining: float = 0.0
var floor_guard: bool = false
var landing_target: int = -1
var slow_remaining: float = 0.0 # Compatibility: global slow motion is no longer used.
var _clock: float = 0.0
var _dust_clock: float = 0.0
var _was_dashing: bool = false
var _wave_token: int = -1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var particles: Array[Dictionary] = []
var beams: Array[Dictionary] = []
var rings: Array[Dictionary] = []
var trails: Array[Dictionary] = []

func configure(owner_game: MainGame) -> void:
	game = owner_game
	z_index = 25
	process_physics_priority = 4
	_rng.randomize()
	drone_position = game.player.global_position + Vector2(45,-110)
	game.player.mechanics = self
	game.player.floor_transition_started.connect(_floor_transition)
	game.player.landed.connect(_landed)
	game.loot.repaired.connect(_repaired)
	game.loot.collected.connect(_collected)
	game.waves.grazed.connect(_grazed)

func has_card(id: int) -> bool:
	return game != null and game.upgrades.has_upgrade(id)

func active_battle() -> bool:
	return game != null and game.waves.state == DisasterWaveManager.State.SIEGE_PHASE and not game.waves.failed and not game.waves.victory and not game.upgrades.pending

func reset() -> void:
	cancel_time_slow()
	dome_ready = false
	dome_cooldown = 0.0
	stationary_time = 0.0
	bag_used = false
	bag_activations = 0
	drone_clock = 6.5
	drone_repairs = 0
	armor_blocks = 0
	shock_clears = 0
	_wave_token = -1
	_was_dashing = false
	drone_target = null
	particles.clear()
	beams.clear()
	rings.clear()
	trails.clear()
	if game != null:
		game.player.energy_regen_multiplier = 1.0
		drone_position = game.player.global_position + Vector2(45,-110)
	queue_redraw()

func begin_wave() -> void:
	if _wave_token == game.waves.wave_number: return
	_wave_token = game.waves.wave_number
	bag_used = false
	drone_clock = 6.5

func upgrade_added(id: int) -> void:
	if id == SiegeUpgrades.Kind.AUTO_DRONE:
		drone_position = game.player.global_position + Vector2(45,-110)
	burst(game.player.global_position + Vector2(0,-50),CYAN,16)

func cancel_time_slow() -> void:
	slow_remaining = 0.0
	time_remaining = 0.0
	freeze_remaining = 0.0
	repulse_remaining = 0.0
	floor_guard = false
	landing_target = -1
	drone_target = null
	_was_dashing = false
	Engine.time_scale = 1.0

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _physics_process(delta: float) -> void:
	advance(delta, delta)

func advance(delta: float, _real_delta: float) -> void:
	if game == null: return
	_clock += delta
	_animate_fx(delta)
	game.player.energy_regen_multiplier = 1.0
	if not active_battle():
		# The modal/cinematics freeze module clocks. Phase cleanup clears transient FX.
		queue_redraw()
		return
	time_remaining = maxf(0.0,time_remaining-delta)
	freeze_remaining = maxf(0.0,freeze_remaining-delta)
	repulse_remaining = maxf(0.0,repulse_remaining-delta)
	if time_remaining < .000001: time_remaining = 0.0
	if freeze_remaining < .000001: freeze_remaining = 0.0
	if repulse_remaining < .000001: repulse_remaining = 0.0
	if has_card(SiegeUpgrades.Kind.DOME):
		stationary_time = stationary_time + delta if game.player.global_position.distance_to(game.player.previous_position) < .1 and not game.player.is_shifting and not game.player.is_dashing else 0.0
		var was_charging: bool = dome_cooldown > 0.0
		dome_cooldown = maxf(0.0,dome_cooldown-delta)
		if not dome_ready and dome_cooldown <= .000001 and (was_charging or stationary_time >= .35): dome_ready = true
	if has_card(SiegeUpgrades.Kind.AWARE_STRUCTURE):
		var room: RoomDiorama = game.loot.current_room()
		if room != null and room.bullet_armor and not room.is_collapsed(): game.player.energy_regen_multiplier = 2.0
	if has_card(SiegeUpgrades.Kind.AUTO_DRONE): _drone(delta)
	if has_card(SiegeUpgrades.Kind.SONIC_DASH) and _was_dashing and not game.player.is_dashing:
		ring(game.player.global_position+Vector2(0,-24),CYAN)
	_was_dashing = game.player.is_dashing
	queue_redraw()

func on_player_hurt() -> void:
	if not active_battle() or not has_card(SiegeUpgrades.Kind.AWARE_BAG) or bag_used or game.player.health >= game.player.max_health*.45: return
	bag_used = true
	bag_activations += 1
	game.projectiles.dissolve_all()
	game.player.health = minf(game.player.max_health,game.player.health+40.0)
	game.player.speed_boost = maxf(game.player.speed_boost,4.0)
	ring(game.player.global_position+Vector2(0,-30),Color("71e5ac"))
	activated.emit(SiegeUpgrades.Kind.AWARE_BAG,game.player.global_position)
	game.loot._message(game.player.global_position+Vector2(-95,-130),"ACİL ÇANTA! +40 CAN",Color("71e5ac"))

func _collected(kind: int) -> void:
	if has_card(SiegeUpgrades.Kind.AWARE_BAG) and kind == LootSystem.Kind.EMERGENCY_BAG:
		repulse_remaining = 2.0
		ring(game.player.global_position+Vector2(0,-24),Color("71e5ac"))
		activated.emit(SiegeUpgrades.Kind.AWARE_BAG,game.player.global_position)

func _repaired(room: RoomDiorama) -> void:
	if has_card(SiegeUpgrades.Kind.AWARE_STRUCTURE) and not room.is_collapsed(): room.set_bullet_armor(true)

func _grazed(_point: Vector2) -> void:
	if not active_battle() or not has_card(SiegeUpgrades.Kind.GRAZE_TIME): return
	time_remaining = 2.5
	activated.emit(SiegeUpgrades.Kind.GRAZE_TIME,game.player.global_position)

func projectile_speed(shot: HazardProjectile) -> float:
	if freeze_remaining > 0.0: return 0.0
	if shot.attack.is_area(): return 1.0
	if time_remaining > 0.0 and shot.global_position.distance_to(game.player.global_position+Vector2(0,-24)) <= TIME_RADIUS: return .45
	return 1.0

func orbital_positions(at_time: float = -1.0, player_position: Vector2 = Vector2.INF) -> PackedVector2Array:
	var center: Vector2 = (game.player.global_position if player_position == Vector2.INF else player_position)+Vector2(0,-24)
	var clock: float = _clock if at_time < 0.0 else at_time
	var positions: PackedVector2Array = PackedVector2Array()
	for i: int in range(2): positions.append(center+Vector2.from_angle(clock*2.5+i*PI)*ORBIT_RADIUS)
	return positions

func _segment_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
	return Geometry2D.get_closest_point_to_segment(center,a,b).distance_squared_to(center) <= radius*radius

func _segment_room(a: Vector2, b: Vector2, room: RoomDiorama) -> bool:
	var rect: Rect2 = Rect2(room.global_position,room.room_size)
	if rect.has_point(a) or rect.has_point(b): return true
	var points: PackedVector2Array = PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
	for i: int in range(4):
		if Geometry2D.segment_intersects_segment(a,b,points[i],points[(i+1)%4]) != null: return true
	return false

func intercept(shot: HazardProjectile, previous: Vector2) -> bool:
	if not active_battle() or shot.attack.is_area(): return false
	if has_card(SiegeUpgrades.Kind.SONIC_DASH) and (game.player.is_dashing or game.player.dashing_this_tick) and shot.crosses_player(game.player,previous):
		_destroy(shot,"PARÇALANDI!",CYAN,SiegeUpgrades.Kind.SONIC_DASH)
		return true
	if repulse_remaining > 0.0 and _segment_circle(previous,shot.global_position,game.player.global_position+Vector2(0,-24),105+shot.attack.radius):
		_destroy(shot,"",Color("71e5ac"),SiegeUpgrades.Kind.AWARE_BAG)
		return true
	if has_card(SiegeUpgrades.Kind.ORBITALS):
		var now: PackedVector2Array = orbital_positions()
		var before: PackedVector2Array = orbital_positions(maxf(0,_clock-get_physics_process_delta_time()),game.player.previous_position)
		for i: int in range(2):
			var pair: PackedVector2Array = Geometry2D.get_closest_points_between_segments(previous-before[i],shot.global_position-now[i],Vector2.ZERO,Vector2.ZERO)
			if pair[0].length_squared() <= pow(ORBIT_SIZE+shot.attack.radius,2):
				_destroy(shot,"",Color("bda4ff"),SiegeUpgrades.Kind.ORBITALS)
				return true
	if has_card(SiegeUpgrades.Kind.AWARE_STRUCTURE):
		for room: RoomDiorama in game.building.rooms:
			if not room.bullet_armor or room.is_collapsed() or shot.armor_checked.has(room.get_instance_id()): continue
			if not _segment_room(previous,shot.global_position,room): continue
			shot.armor_checked[room.get_instance_id()] = true
			if _rng.randf() < .45:
				armor_blocks += 1
				_destroy(shot,"ZIRH BLOKLADI!",AMBER,SiegeUpgrades.Kind.AWARE_STRUCTURE)
				return true
	return false

func block_hit(shot: HazardProjectile) -> bool:
	if not active_battle() or not dome_ready or not has_card(SiegeUpgrades.Kind.DOME) or game.player.invulnerable or game.player.dashing_this_tick: return false
	dome_ready = false
	dome_cooldown = DOME_RECHARGE
	stationary_time = 0.0
	ring(game.player.global_position+Vector2(0,-24),Color("b7e97b"))
	_destroy(shot,"KALKAN!",Color("b7e97b"),SiegeUpgrades.Kind.DOME)
	return true

func _destroy(shot: HazardProjectile, text: String, color: Color, id: int) -> void:
	var point: Vector2 = shot.global_position
	game.projectiles.dissolve(shot)
	blocked.emit(point)
	activated.emit(id,point)
	if not text.is_empty(): game.loot._message(point+Vector2(-65,-40),text,color)

func _floor_transition(target: int) -> void:
	if not active_battle() or not has_card(SiegeUpgrades.Kind.SLAM_SHIELD): return
	floor_guard = true
	landing_target = target

func _landed(_impact: float) -> void:
	if not floor_guard or not active_battle() or game.player.current_floor != landing_target: return
	var room: RoomDiorama = game.loot.current_room()
	floor_guard = false
	landing_target = -1
	if room == null: return
	shock_clears += game.projectiles.clear_room(room)
	if not room.is_collapsed():
		room.repair(20.0)
		_repaired(room)
	ring(game.player.global_position,AMBER)
	activated.emit(SiegeUpgrades.Kind.SLAM_SHIELD,game.player.global_position)

func remote_repair() -> bool:
	if game.waves.failed or game.waves.victory or game.upgrades.pending or game.waves.state not in [DisasterWaveManager.State.SIEGE_PHASE,DisasterWaveManager.State.BUILD_PREPARATION_PHASE]: return false
	var targets: Array[RoomDiorama] = []
	for room: RoomDiorama in game.building.rooms:
		if not room.is_collapsed() and room.hp < room.max_hp: targets.append(room)
	targets.sort_custom(func(a: RoomDiorama,b: RoomDiorama) -> bool: return a.hp/a.max_hp < b.hp/b.max_hp)
	if targets.is_empty() or not game.loot.consume_construction(): return false
	for i: int in range(mini(2,targets.size())):
		var room: RoomDiorama = targets[i]
		room.repair(game.loot.repair_amount)
		_repaired(room)
		game.loot.repaired.emit(room)
		beam(game.player.global_position+Vector2(0,-30),room.global_position+room.room_size*.5,CYAN)
	freeze_remaining = 1.0
	activated.emit(SiegeUpgrades.Kind.REMOTE_CRANE,game.player.global_position)
	return true

func _drone(delta: float) -> void:
	var destination: Vector2 = game.player.global_position+Vector2(55*cos(_clock*2),-115+12*sin(_clock*2.4))
	drone_position = drone_position.move_toward(destination,delta*1050)
	drone_clock -= delta
	if drone_clock <= .000001:
		drone_clock += 6.5
		drone_target = null
		var weakest: float = 1.0
		for room: RoomDiorama in game.building.rooms:
			if not room.is_collapsed() and room.hp/room.max_hp < weakest:
				weakest = room.hp/room.max_hp
				drone_target = room
		if drone_target != null:
			drone_target.repair(45.0)
			_repaired(drone_target)
			drone_repairs += 1
			beam(drone_position,drone_target.global_position+drone_target.room_size*.5,Color("71e5ac"))
			activated.emit(SiegeUpgrades.Kind.AUTO_DRONE,drone_position)
	for i: int in range(game.loot.items.size()-1,-1,-1):
		var item: Dictionary = game.loot.items[i]
		if float(item["drop"]) < 1.0: continue
		var point: Vector2 = item["position"]
		var target: Vector2 = game.player.global_position+Vector2(0,-26)
		if point.distance_to(target) > 580: continue
		if _clock-float(item.get("beam_time",-1)) > .3: beam(drone_position,point,Color(CYAN,.35))
		if _clock-float(item.get("beam_time",-1)) > .3: item["beam_time"] = _clock
		item["position"] = point.move_toward(target,650*delta)
		if Vector2(item["position"]).distance_to(target) < 30: game.loot.collect(i)

func ring(point: Vector2, color: Color) -> void:
	if rings.size() >= 24: rings.pop_front()
	rings.append({"p":point,"life":.7,"color":color})

func retreat_dust(delta: float) -> void:
	_dust_clock -= delta
	if _dust_clock > 0.0: return
	_dust_clock = 0.06
	if game.earthquake.visible:
		burst(game.earthquake._home + Vector2(sin(_clock*17)*170,-20), Color("968475"), 10)
		for i: int in range(4):
			particles.append({"p": game.earthquake._home + Vector2(-150+i*90,-15), "v": Vector2(-55+i*35,-65), "life": 1.1, "color": Color("817e76"), "size": 18.0+i*3.0, "dust": true})
	if game.storm.visible:
		burst(game.storm.global_position + Vector2(cos(_clock*11)*90,-350), Color("8eafc1"), 5)
	if game.titan.visible:
		# The amalgam sinks into its own tide: four element sprays at once.
		for i: int in range(4):
			burst(game.titan.global_position + Vector2((i - 1.5) * 520.0 + sin(_clock*13+i)*60.0, -180.0 - (i % 2) * 520.0), CataclysmArt.ELEMENTS[i % 3], 5)
	for boss: DisasterBoss in [game.flood]:
		if not boss.visible: continue
		var color: Color = Color("72e9d7") if boss.kind == DisasterBoss.Kind.FLOOD else Color("ff8b43")
		burst(boss.global_position + Vector2(sin(_clock*13)*110,-150),color,10)

func burst(point: Vector2, color: Color, count: int) -> void:
	for i: int in range(count):
		if particles.size() >= 480: particles.pop_front()
		var angle: float = i * 2.399 + _clock
		particles.append({"p": point, "v": Vector2(cos(angle)*110, -60-absf(sin(angle))*140), "life": 0.65 + (i%4)*0.12, "color": color, "size": 2.0 + (i%4)*1.4, "dust": false})

func beam(a: Vector2, b: Vector2, color: Color) -> void:
	if beams.size() >= 64: beams.pop_front()
	beams.append({"a": a, "b": b, "life": 0.38, "color": color})

func _animate_fx(delta: float) -> void:
	for list: Array[Dictionary] in [particles, beams, rings, trails]:
		for i: int in range(list.size()-1,-1,-1):
			list[i]["life"] = float(list[i]["life"]) - delta
			if float(list[i]["life"]) <= 0.0:
				list.remove_at(i)
			elif list == particles:
				list[i]["p"] = Vector2(list[i]["p"]) + Vector2(list[i]["v"]) * delta
				list[i]["v"] = Vector2(list[i]["v"]) + Vector2(0,0 if bool(list[i].get("dust",false)) else 230)*delta

func _draw() -> void:
	if game == null: return
	for p: Dictionary in particles:
		var size: float = p["size"]
		if bool(p.get("dust",false)): draw_circle(p["p"],size+(1.1-float(p["life"]))*30,Color(p["color"],minf(.4,float(p["life"])*.5)))
		else: draw_rect(Rect2(Vector2(p["p"])-Vector2.ONE*size,Vector2.ONE*size*2),Color(p["color"],minf(.8,float(p["life"])*1.5)))
	for b: Dictionary in beams:
		var alpha: float = float(b["life"])/.38
		draw_line(b["a"],b["b"],Color(b["color"],alpha*.25),12)
		draw_line(b["a"],b["b"],Color(b["color"],alpha),3)
	for r: Dictionary in rings: draw_arc(r["p"],30+(.7-float(r["life"]))*320,0,TAU,24,Color(r["color"],r["life"]),4)
	if not active_battle(): return
	var center: Vector2 = game.player.global_position+Vector2(0,-24)
	if has_card(SiegeUpgrades.Kind.AUTO_DRONE): _draw_drone()
	if has_card(SiegeUpgrades.Kind.DOME):
		if dome_ready:
			draw_circle(center,55,Color(.67,.93,.4,.12))
			draw_arc(center,55,0,TAU,24,CelArt.INK,6)
			draw_arc(center,55,0,TAU,24,Color("b7e97b"),3)
			for i: int in range(4):
				var p: Vector2 = center+Vector2.from_angle(i*TAU/4+PI/4)*52
				draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),AMBER)
		elif dome_cooldown > 0: draw_arc(center,55,-PI/2,-PI/2+TAU*(1-dome_cooldown/6),20,Color("b7e97b"),2)
	if time_remaining > 0:
		draw_circle(center,TIME_RADIUS,Color(.2,.45,1,.08))
		draw_arc(center,TIME_RADIUS,0,TAU,40,Color(.4,.7,1,.7),3)
		for i: int in range(12):
			var p: Vector2 = center+Vector2.from_angle(i*TAU/12+_clock*.25)*TIME_RADIUS
			draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),Color("8cb9ff"))
	if has_card(SiegeUpgrades.Kind.ORBITALS):
		draw_arc(center,ORBIT_RADIUS,0,TAU,24,Color(.7,.6,1,.18),2)
		for orb: Vector2 in orbital_positions():
			CelArt.ellipse(self,orb,Vector2(ORBIT_SIZE,ORBIT_SIZE),Color("59697c"),3)
			CelArt.ellipse(self,orb-Vector2(3,3),Vector2(8,8),Color("c6c1ed"),0)
			draw_line(orb+Vector2(-6,0),orb+Vector2(6,0),Color("bda4ff"),3)
	if repulse_remaining > 0:
		draw_arc(center,105,0,TAU,24,Color(.4,1,.7,.75),4)
	if has_card(SiegeUpgrades.Kind.AWARE_BAG):
		var p: Vector2 = center+Vector2(-28*game.player.facing,-5)
		CelArt.box(self,Rect2(p-Vector2(11,14),Vector2(22,28)),Color("235347"),Vector2(3,-3))
		draw_rect(Rect2(p-Vector2(3,9),Vector2(6,18)),Color("9effba"))
		draw_rect(Rect2(p-Vector2(8,3),Vector2(16,6)),Color("9effba"))
	if floor_guard:
		draw_arc(center,46,0,TAU,20,AMBER,4)
	if has_card(SiegeUpgrades.Kind.SONIC_DASH) and game.player.is_dashing:
		draw_arc(center,42,-1.2+game.player._dash_direction.angle(),1.2+game.player._dash_direction.angle(),12,CYAN,5)
	if freeze_remaining > 0:
		for shot: HazardProjectile in game.projectiles.entries:
			if shot.active: draw_arc(shot.global_position,shot.attack.radius+5,0,TAU,8,Color(.6,.85,1,.6),2)

func _draw_drone() -> void:
	var p: Vector2 = drone_position
	if custom_sprite != null:
		draw_texture_rect(custom_sprite,Rect2(p-Vector2(28,20),Vector2(56,40)),false)
		return
	draw_circle(p,35,Color(CYAN,0.08))
	for side: float in [-1.0,1.0]:
		var arm: Vector2 = p + Vector2(side*30,-5)
		CelArt.line(self,p,arm,Color("5a6c77"),6.0)
		CelArt.line(self,arm+Vector2(-17,-6),arm+Vector2(17,-6),Color("afc6cc"),3.0)
		draw_arc(arm+Vector2(0,-6),17,0,TAU,12,Color(CYAN,0.3),2.0)
	CelArt.box(self,Rect2(p-Vector2(18,14),Vector2(36,26)),Color("40565e"),Vector2(5,-5))
	CelArt.rect(self,Rect2(p-Vector2(9,8),Vector2(18,8)),Color("97efe3"),2.0)
	CelArt.line(self,p+Vector2(0,13),p+Vector2(0,24),AMBER,3.0)
