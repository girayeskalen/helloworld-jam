class_name SiegeMechanics
extends Node2D
## Run-scoped active equipment and bounded procedural VFX. Physics is shared with
## the real projectile pool; no simulated UI-only card effects or extra bullets.
@export var custom_sprite: Texture2D
const CYAN: Color = Color("71e5e1")
const AMBER: Color = Color("ffc17a")
## The deflector turbine stopped a projectile at a reinforced window.
signal blocked(point: Vector2)
var game: MainGame
var drone_position: Vector2
var drone_target: RoomDiorama
var drone_clock: float = 12.0
var turret_clock: float = 3.0
var slow_remaining: float = 0.0
var fragment_count: int = 0
var drone_repairs: int = 0
var turret_shots: int = 0
var deflections: int = 0
var perfect_dodges: int = 0
var dash_repairs: int = 0
var shock_clears: int = 0
var _clock: float = 0.0
var _dust_clock: float = 0.0
var _trail_clock: float = 0.0
var _beam_clock: float = 0.0
var _visited: Dictionary = {}
var particles: Array[Dictionary] = []
var beams: Array[Dictionary] = []
var rings: Array[Dictionary] = []
var trails: Array[Dictionary] = []

func configure(owner_game: MainGame) -> void:
	game = owner_game
	z_index = 25
	process_physics_priority = 4
	drone_position = game.player.global_position + Vector2(45, -110)
	game.player.dash_started.connect(_dash_started)
	game.player.floor_transition_started.connect(_floor_transition)
	game.loot.manual_action.connect(_manual_repair)
	game.loot.collected.connect(_collected)

func has_card(id: int) -> bool:
	return game != null and game.upgrades.has_upgrade(id)

func reset() -> void:
	cancel_time_slow()
	drone_target = null
	drone_clock = 12.0
	turret_clock = 3.0
	fragment_count = 0
	drone_repairs = 0
	turret_shots = 0
	deflections = 0
	perfect_dodges = 0
	dash_repairs = 0
	shock_clears = 0
	particles.clear()
	beams.clear()
	rings.clear()
	trails.clear()
	_visited.clear()
	drone_position = game.player.global_position + Vector2(45, -110)
	queue_redraw()

func upgrade_added(id: int) -> void:
	if id == SiegeUpgrades.Kind.AUTO_DRONE:
		drone_position = game.player.global_position + Vector2(45, -110)
	burst(game.player.global_position + Vector2(0,-50), CYAN, 18)
	game.loot._message(game.player.global_position + Vector2(-120,-150), "MODÜL AKTİF · " + String(SiegeUpgrades.CATALOG[id]["tag"]), CYAN)

func cancel_time_slow() -> void:
	slow_remaining = 0.0
	Engine.time_scale = 1.0

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _physics_process(delta: float) -> void:
	advance(delta, 1.0 / float(Engine.physics_ticks_per_second))

func advance(delta: float, real_delta: float) -> void:
	if game == null: return
	_clock += delta
	_animate_fx(delta)
	if slow_remaining > 0.0:
		slow_remaining = maxf(0.0, slow_remaining - real_delta)
		if slow_remaining < 0.000001: cancel_time_slow()
	if game.waves.failed or game.waves.victory or game.upgrades.pending:
		cancel_time_slow()
		queue_redraw()
		return
	var battle: bool = game.waves.state == DisasterWaveManager.State.SIEGE_PHASE
	if has_card(SiegeUpgrades.Kind.AUTO_DRONE): _drone(delta, battle)
	if has_card(SiegeUpgrades.Kind.LOOT_MAGNET): _magnet(delta)
	if battle:
		if game.player.dashing_this_tick:
			if has_card(SiegeUpgrades.Kind.DASH_REPAIR): _dash_repair()
			if has_card(SiegeUpgrades.Kind.GRAPPLE_DASH):
				_trail_clock -= delta
				if _trail_clock <= 0.0:
					trails.append({"a": game.player.previous_position + Vector2(0,-24), "b": game.player.global_position + Vector2(0,-24), "life": 0.9})
					_trail_clock = 0.025
		if has_card(SiegeUpgrades.Kind.ROOF_TURRET):
			turret_clock -= delta
			if turret_clock <= 0.0 and fire_turret(): turret_clock = 3.0
		_dust_clock -= delta
		if _dust_clock <= 0.0:
			_dust_clock = 0.3
			var edge: float = game.building.global_position.x + (0.0 if int(_clock * 10) % 2 == 0 else game.building.building_width)
			burst(Vector2(edge, game.building.global_position.y + fmod(_clock * 173.0, 850.0)), Color("80766a"), 3)
	queue_redraw()

func _dash_repair() -> void:
	var a: Vector2 = game.player.previous_position + Vector2(0,-25)
	var b: Vector2 = game.player.global_position + Vector2(0,-25)
	for room: RoomDiorama in game.building.rooms:
		if _visited.has(room) or not game.loot.repair_alert(room): continue
		var area: Rect2 = Rect2(room.global_position + Vector2(12,20), room.room_size - Vector2(24,40))
		var crossed: bool = area.has_point(a) or area.has_point(b)
		for point: Vector2 in [area.position, area.position + Vector2(area.size.x,0), area.end, area.position + Vector2(0,area.size.y)]:
			if Geometry2D.get_closest_point_to_segment(point, a, b).distance_to(point) < 22.0: crossed = true
		# A horizontal/diagonal dash can cross an entire room between samples.
		if not crossed:
			var corners: Array[Vector2] = [area.position, area.position + Vector2(area.size.x,0), area.end, area.position + Vector2(0,area.size.y)]
			for i: int in range(4):
				if Geometry2D.segment_intersects_segment(a,b,corners[i],corners[(i+1)%4]) != null: crossed = true
		if crossed and game.loot.consume_construction():
			_visited[room] = true
			room.repair(game.loot.repair_amount)
			game.player.stamina = 100.0
			dash_repairs += 1
			beam(game.player.global_position, room.global_position + room.room_size * 0.5, AMBER)
			game.loot._message(room.global_position + Vector2(50,80), "TAKLA ONARIMI +45", AMBER)

func _dash_started() -> void:
	_visited.clear()
	if not has_card(SiegeUpgrades.Kind.ADRENALINE_REFLEX) or game.waves.state != DisasterWaveManager.State.SIEGE_PHASE: return
	if impending_hit():
		perfect_dodges += 1
		slow_remaining = 1.5
		Engine.time_scale = 0.5
		game.loot.reflex_drop()
		rings.append({"p": game.player.global_position + Vector2(0,-30), "life": 0.7, "color": Color("e9a0dd")})
		game.loot._message(game.player.global_position + Vector2(-100,-150), "PERFECT DODGE!", Color("e9a0dd"))

## Predict the stationary capsule against each frozen path. Nearby/receding shots
## and shots that already contacted the player cannot trigger a perfect dodge.
func impending_hit() -> bool:
	var head: Vector2 = game.player.global_position + Vector2(0,-36)
	var feet: Vector2 = game.player.global_position + Vector2(0,-12)
	for shot: HazardProjectile in game.projectiles.entries:
		if not shot.active or shot.contacted_player: continue
		var attack: HazardAttack = shot.attack
		if attack.floor_index != game.player.current_floor and not attack.cross_floor: continue
		if attack.is_wall():
			var distance: float = absf(shot.global_position.x - head.x) - attack.radius - 12
			if distance > 0 and distance <= absf(attack.velocity.x) * 0.15 and (head.x - shot.global_position.x) * attack.velocity.x > 0: return true
			continue
		var radius: float = attack.radius + 12.0
		if Geometry2D.get_closest_point_to_segment(shot.global_position, head, feet).distance_to(shot.global_position) <= radius: continue
		var previous: Vector2 = shot.global_position
		for step: int in range(1,10):
			var t: float = step / 60.0
			if shot.age + t * projectile_speed(shot) > attack.lifetime: break
			var point: Vector2 = attack.point_at(shot.age + t * projectile_speed(shot))
			var pair: PackedVector2Array = Geometry2D.get_closest_points_between_segments(previous, point, head, feet)
			if pair[0].distance_to(pair[1]) <= radius: return true
			previous = point
	return false

func _floor_transition(target: int) -> void:
	if not has_card(SiegeUpgrades.Kind.SLAM_SHIELD) or game.waves.state != DisasterWaveManager.State.SIEGE_PHASE: return
	shock_clears += game.projectiles.clear_floor(target)
	rings.append({"p": Vector2(game.player.global_position.x, game.building.floor_y(target)-45), "life": 0.7, "color": AMBER})
	beam(Vector2(game.building.interior_left(), game.building.floor_y(target)-40), Vector2(game.building.interior_right(),game.building.floor_y(target)-40), AMBER)

func _manual_repair(room: RoomDiorama) -> void:
	if not has_card(SiegeUpgrades.Kind.CHAIN_REPAIR): return
	var col: int = int(room.room_kind) % 4
	for offset: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
		var f: int = room.floor_index + offset.y
		var c: int = col + offset.x
		if f < 0 or f > 3 or c < 0 or c > 3: continue
		var neighbor: RoomDiorama = game.building.room_at(f,c)
		if neighbor.is_collapsed(): continue
		neighbor.repair(game.loot.repair_amount * 0.5)
		neighbor.chain_support = true
		neighbor._refresh_state(true)
		beam(room.global_position + room.room_size * 0.5, neighbor.global_position + neighbor.room_size * 0.5, CYAN)

func _drone(delta: float, battle: bool) -> void:
	if battle:
		drone_clock -= delta
		if drone_clock <= 0.0 and drone_target == null:
			var weakest: float = 1.0
			for room: RoomDiorama in game.building.rooms:
				if not room.is_collapsed() and room.hp / room.max_hp < weakest:
					weakest = room.hp / room.max_hp
					drone_target = room
			if drone_target != null: drone_clock = 12.0
	var destination: Vector2 = game.player.global_position + Vector2(65 * cos(_clock*2.0), -115 + 15*sin(_clock*2.4))
	if drone_target != null:
		destination = drone_target.global_position + drone_target.room_size * 0.5
	drone_position = drone_position.move_toward(destination, delta * 1050.0)
	if drone_target != null and drone_position.distance_to(destination) < 15.0:
		if not drone_target.is_collapsed():
			drone_target.repair(45.0)
			drone_repairs += 1
			beam(drone_position, destination + Vector2(0,70), CYAN)
			game.loot._message(destination, "DRON ONARIMI +45", CYAN)
		drone_target = null
	_beam_clock -= delta
	if _beam_clock <= 0.0:
		for i: int in range(game.loot.items.size()-1,-1,-1):
			var item: Dictionary = game.loot.items[i]
			if float(item["drop"]) >= 1.0 and drone_position.distance_to(item["position"]) < maxf(430.0,game.loot.pickup_radius*2.5):
				beam(drone_position, item["position"], CYAN)
				game.loot.collect(i)
				_beam_clock = 0.25
				break

func _magnet(delta: float) -> void:
	var target: Vector2 = game.player.global_position + Vector2(0,-26)
	for i: int in range(game.loot.items.size()-1,-1,-1):
		var item: Dictionary = game.loot.items[i]
		if float(item["drop"]) < 1.0: continue
		var point: Vector2 = item["position"]
		if point.distance_to(target) > 580.0: continue
		item["position"] = point.move_toward(target, 650.0 * delta)
		if Vector2(item["position"]).distance_to(target) < 30.0: game.loot.collect(i)

func _collected(_kind: int) -> void:
	if has_card(SiegeUpgrades.Kind.LOOT_MAGNET):
		game.player.speed_boost = 2.0
		game.player.repair_shield = maxf(2.0, game.player.repair_shield)

func projectile_speed(shot: HazardProjectile) -> float:
	if shot.attack.is_area(): return 1.0
	for trail: Dictionary in trails:
		if Geometry2D.get_closest_point_to_segment(shot.global_position, trail["a"], trail["b"]).distance_to(shot.global_position) < 65.0:
			return 0.4 * (.88 if has_card(SiegeUpgrades.Kind.EARLY_WARNING) else 1.0)
	return .88 if has_card(SiegeUpgrades.Kind.EARLY_WARNING) else 1.0

func intercept(shot: HazardProjectile, previous: Vector2) -> bool:
	if not has_card(SiegeUpgrades.Kind.DEFLECTOR): return false
	for prop: BuildingProp in game.building.props:
		if prop.kind != BuildingProp.Kind.WINDOW or prop.condition != BuildingProp.Condition.REINFORCED: continue
		if prop.floor_index != shot.attack.floor_index: continue
		var center: Vector2 = prop.global_position - Vector2(0, prop.prop_size.y * 0.5)
		if Geometry2D.get_closest_point_to_segment(center, previous, shot.global_position).distance_to(center) <= 42.0 + shot.attack.radius:
			beam(center, shot.global_position, CYAN)
			blocked.emit(shot.global_position)
			game.projectiles.dissolve(shot)
			game.player.stamina = minf(100.0, game.player.stamina + 6.0)
			fragment_count += 1
			deflections += 1
			if fragment_count >= 3:
				fragment_count -= 3
				game.loot.grant(LootSystem.Kind.COLUMN_KIT)
				game.loot._message(center, "3 PARÇA → +1 ÇİMENTO", CYAN)
			return true
	return false

func turret_origin() -> Vector2:
	return game.building.global_position + Vector2(game.building.building_width * 0.72, -100)

func fire_turret() -> bool:
	var target: HazardProjectile = null
	var best: float = -INF
	for shot: HazardProjectile in game.projectiles.entries:
		if not shot.active or shot.attack.radius < 18.0: continue
		var threat: float = shot.attack.damage * 5.0 + shot.attack.structure_damage * 20.0 + shot.attack.radius - shot.global_position.distance_to(game.player.global_position) * 0.08
		if threat > best:
			best = threat
			target = shot
	if target == null: return false
	beam(turret_origin(), target.global_position, Color("fff1a0"))
	burst(target.global_position, AMBER, 18)
	game.projectiles.dissolve(target)
	turret_shots += 1
	return true

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
		if bool(p.get("dust",false)):
			draw_circle(p["p"],size+(1.1-float(p["life"]))*30,Color(p["color"],minf(.4,float(p["life"])*.5)))
		else:
			draw_rect(Rect2(Vector2(p["p"])-Vector2.ONE*size, Vector2.ONE*size*2), Color(p["color"],minf(0.8,float(p["life"])*1.5)))
	for trail: Dictionary in trails:
		draw_line(trail["a"],trail["b"],Color(CYAN,float(trail["life"])*0.3),18.0)
		draw_line(trail["a"],trail["b"],Color(CYAN,float(trail["life"])),3.0)
	for b: Dictionary in beams:
		var alpha: float = float(b["life"]) / 0.38
		draw_line(b["a"],b["b"],Color(b["color"],alpha*0.25),12.0)
		draw_line(b["a"],b["b"],Color(b["color"],alpha),3.0)
	for ring: Dictionary in rings:
		var life: float = ring["life"]
		draw_arc(ring["p"],30+(0.7-life)*650,0,TAU,64,Color(ring["color"],life),5.0)
	if has_card(SiegeUpgrades.Kind.AUTO_DRONE): _draw_drone()
	if has_card(SiegeUpgrades.Kind.ROOF_TURRET): _draw_turret()
	if has_card(SiegeUpgrades.Kind.DEFLECTOR):
		for prop: BuildingProp in game.building.props:
			if prop.kind == BuildingProp.Kind.WINDOW and prop.condition == BuildingProp.Condition.REINFORCED:
				var center: Vector2 = prop.global_position - Vector2(0,prop.prop_size.y*0.5)
				draw_arc(center,31,0,TAU,24,Color(CYAN,0.35),4.0)
				for i: int in range(3):
					var tip: Vector2 = center + Vector2(25,0).rotated(_clock*9+i*TAU/3)
					CelArt.line(self,center,tip,Color("87a9b2"),7.0)
				CelArt.bolt(self,center,CYAN)
	if game.building.wear_clock > 0.0:
		for i: int in range(mini(24,int(game.building.wear_clock/3.0))):
			var point: Vector2 = game.building.global_position + Vector2((i%5)*400,40+(i%4)*220)
			draw_polyline(PackedVector2Array([point,point+Vector2(7,14),point+Vector2(2,24),point+Vector2(9,38)]),Color("242a2b"),2.0)
	if has_card(SiegeUpgrades.Kind.LOOT_MAGNET):
		var center: Vector2 = game.player.global_position + Vector2(0,-28)
		for i: int in range(2):
			draw_arc(center,48+i*14, _clock*2+i*PI, _clock*2+i*PI+2.0,16,Color(CYAN,0.45),2.0)

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

func _draw_turret() -> void:
	var p: Vector2 = turret_origin()
	CelArt.box(self,Rect2(p+Vector2(-36,48),Vector2(72,18)),Color("4d5e67"),Vector2(10,-8))
	CelArt.line(self,p+Vector2(-20,49),p+Vector2(0,10),Color("778e92"),9.0)
	CelArt.line(self,p+Vector2(20,49),p+Vector2(0,10),Color("778e92"),9.0)
	CelArt.box(self,Rect2(p+Vector2(-24,-4),Vector2(48,26)),Color("495c69"),Vector2(7,-7))
	CelArt.line(self,p,p+Vector2(0,-42),Color("c0d1c9"),5.0)
	draw_circle(p+Vector2(0,-42),10,Color("fff1a0"))
	draw_arc(p,30,-PI,0,24,Color("ffe58a"),3.0)
