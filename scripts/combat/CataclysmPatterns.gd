class_name CataclysmPatterns
extends RefCounted
## Kataklizma Titanı combos. Every shot keeps its own element source (0 storm,
## 1 quake, 2 flood, 3 fire), so warnings, shutters, steel and resistance cards
## keep working. All paths are frozen through the normal warn() contract.

const ELEMENT_KINDS: Array[int] = [HazardAttack.Kind.WIND_ORB, HazardAttack.Kind.SHARD, HazardAttack.Kind.WATER_SHARD]
## Combos with their own one-time room-damage weight; individual fragments stay light.
const LIGHT_PATTERNS: Array[int] = [HazardAttack.Pattern.STEAM_BURST, HazardAttack.Pattern.QUADRANT_SEAL, HazardAttack.Pattern.CATACLYSM_NOVA]
const COOLDOWN_SCALE: float = 1.3
const DENSITY_SCALE: float = .7
const SPEED_SCALE: float = .8
const DAMAGE_SCALE: float = .7
const WARNING_EXTRA: float = .2

static func count(base: int) -> int:
	return maxi(1,roundi(base*DENSITY_SCALE))

static func tune(a: HazardAttack) -> void:
	if a.final_tuned: return
	a.final_tuned = true
	a.damage *= DAMAGE_SCALE
	a.structure_damage *= DAMAGE_SCALE
	a.difficulty_damage_scale = DAMAGE_SCALE
	a.warning_extension = WARNING_EXTRA
	a.scale_travel_speed(SPEED_SCALE)

static func plan(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	if w.nova: return nova(w, index, floor_index)
	match index % 4:
		0: return steam_tsunami(w, index)
		1: return firenado(w, index, floor_index)
		2: return seismic_tide(w, index, floor_index)
	return quadrant_seal(w, index)

## Wind-up time of the titan art; equals the longest warning it announces.
static func cue_seconds(w: DisasterWaveManager, index: int) -> float:
	if w.nova: return HazardAttack.STANDARD_WARNING+WARNING_EXTRA
	return [1.0, HazardAttack.STANDARD_WARNING, 1.0, HazardAttack.SEAL_WARNING][index % 4]+WARNING_EXTRA

## SKILL 1 — flood on both lower floors, roof meteors fall into that water.
static func steam_tsunami(w: DisasterWaveManager, index: int) -> String:
	var b: ApartmentBuilding = w.building
	for f: int in range(2):
		MarathonPatterns.zone(w, HazardAttack.Kind.FLOOD_ZONE, f, Rect2(b.interior_left(), b.floor_y(f) - 28, b.building_width - 48, 28), 3.2, 2, HazardAttack.Pattern.STEAM_TSUNAMI)
	for i: int in range(count(4)):
		var f: int = i % 2
		var x: float = b.interior_left() + 150 + fmod(index * 151 + i * 377, b.building_width - 320)
		var a: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE, f, Vector2(x, b.global_position.y - 45), Vector2(120 if x < b.center_x() else -120, 360))
		a.source = 1
		a.pattern = HazardAttack.Pattern.STEAM_TSUNAMI
		a.motion = HazardAttack.Motion.ARC
		a.gravity = 680
		a.cross_floor = true
		a.splits = true
		# Launch while the flood is live, so meteors really hit water.
		a.warning_delay = .35 + (i / 2) * .3
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .75)
	return "TSUNAMİ · KAYA YAĞMURU"

## A meteor that lands in live flood water becomes a steam column and six orbs.
static func steam_burst(w: DisasterWaveManager, parent: HazardAttack, point: Vector2) -> bool:
	var f: int = parent.floor_index
	var b: ApartmentBuilding = w.building
	if not flooded(w, f, point.x): return false
	var column: HazardAttack = w._attack(HazardAttack.Kind.STEAM_COLUMN, f, Vector2(point.x, b.floor_y(f) - 91), Vector2.ZERO)
	column.source = 2
	column.pattern = HazardAttack.Pattern.STEAM_BURST
	column.area = Rect2(point.x - 34, b.floor_y(f) - 182, 68, 182)
	column.lifetime = 1.2
	column.damage = 12
	w.plan_attack(column, .55)
	# Two along the floor, two shallow and two steep: six directions, never into the slab.
	for i: int in range(count(6)):
		var angle: float = [-PI*.08,-PI*.36,-PI*.64,-PI*.92][i]
		var water: bool = i % 2 == 0
		var a: HazardAttack = w._attack(HazardAttack.Kind.WATER_SHARD if water else HazardAttack.Kind.SHARD, f, Vector2(point.x, b.floor_y(f) - 46), Vector2.from_angle(angle) * 560)
		a.source = 2 if water else 1
		a.pattern = HazardAttack.Pattern.STEAM_BURST
		_ray(w, a)
		w.plan_attack(a, .55)
	return true

static func flooded(w: DisasterWaveManager, f: int, x: float) -> bool:
	for shot: HazardProjectile in w.pool.entries:
		if shot.active and shot.attack.kind == HazardAttack.Kind.FLOOD_ZONE and shot.attack.floor_index == f and shot.attack.contains_area_point(Vector2(x, w.building.floor_y(f) - 10)):
			return true
	return false

## SKILL 2 — wind pull toward the vortex arm, two fire-vortex rings, crossing blades.
static func firenado(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	var b: ApartmentBuilding = w.building
	var toward: float = -1.0 if (index / 4) % 2 == 0 else 1.0
	w.storm_gust(toward, w.gust_strength * 1.15)
	for ring: int in range(2):
		var x: float = b.global_position.x + b.room_width * (0.5 + ring * 2 + (index / 4) % 2)
		if floor_index == w.player.current_floor and absf(x - w.player.global_position.x) < 240.0:
			x += b.room_width * (1.0 if x < b.center_x() else -1.0)
		var center: Vector2 = Vector2(x, b.floor_y(floor_index) - 94)
		var shots: int = count(10)
		for i: int in range(shots):
			var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB if i % 2 == 0 else HazardAttack.Kind.WATER_SHARD, floor_index, center, Vector2.ZERO)
			a.source = 0 if i % 2 == 0 else 2
			a.pattern = HazardAttack.Pattern.FIRENADO
			a.motion = HazardAttack.Motion.SPIRAL
			a.radius = 11
			a.damage = 12
			a.amplitude = 70
			a.spiral_angle = TAU * i / float(shots) + ring * .3
			a.spiral_spin = 1.3 if ring == 0 else -1.3
			a.spiral_speed = 265
			a.spiral_start = 50
			a.lead = i == 0
			a.warning_delay = ring * .3
			a.lifetime = w._spiral_time(a, 2.4)
			w.plan_attack(a, .7)
	var y0: float = b.floor_y(floor_index)
	for side: int in range(count(2)):
		var from_left: bool = side == 0
		var origin: Vector2 = Vector2(b.global_position.x + (50.0 if from_left else b.building_width - 50.0), y0 - (36.0 if from_left else 158.0))
		var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_BLADE, floor_index, origin, Vector2(1.0 if from_left else -1.0, -.13 if from_left else .13).normalized() * 600)
		a.source = 0
		a.pattern = HazardAttack.Pattern.FIRENADO
		a.radius = 20
		a.damage = 14
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .75)
	return "SU KASIRGASI · RÜZGÂR ÇEKİMİ"

## SKILL 3 — rock fist tremor, a tidal wall, jumpable seismic waves, window orbs, ceiling debris.
static func seismic_tide(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	var b: ApartmentBuilding = w.building
	var wall_floor: int = (floor_index + 2) % b.floor_count
	var wall: HazardAttack = MarathonPatterns.shot(w, HazardAttack.Kind.TIDAL_WALL, wall_floor, index % 2, 920, 2, HazardAttack.Pattern.SEISMIC_TIDE, 92)
	wall.row_height = 174
	wall.radius = 16
	w.plan_attack(wall, 1.0)
	for side: int in range(count(2)):
		var x: float = b.interior_left() + 16 if side == 0 else b.interior_right() - 16
		var wave: HazardAttack = w._attack(HazardAttack.Kind.SHOCKWAVE, floor_index, Vector2(x, b.floor_y(floor_index) - 12), Vector2(480 if side == 0 else -480, 0))
		wave.source = 1
		wave.starts_slam = side == 0
		wave.pattern = HazardAttack.Pattern.SEISMIC_TIDE
		wave.lifetime = w._flight_time(wave)
		w.plan_attack(wave, .7)
	for side: int in range(count(2)):
		var f: int = (floor_index + 1 + side) % b.floor_count
		# Pressurised orbs burst in through the facade windows and bounce three times.
		var orb: HazardAttack = MarathonPatterns.shot(w, HazardAttack.Kind.HYDRO_ORB, f, side, 620, 2, HazardAttack.Pattern.SEISMIC_TIDE, 112)
		orb.velocity.y = -300 if side == 0 else 300
		orb.radius = 21
		orb.splits = true
		orb.reflect_in(Rect2(b.interior_left() + orb.radius, orb.floor_y - 180 + orb.radius, b.building_width - 48 - orb.radius * 2, 180 - orb.radius * 2))
		w.plan_attack(orb, .75)
	for i: int in range(count(2)):
		var x: float = clampf(w.player.global_position.x + (0.0 if i == 0 else (420.0 if w.player.global_position.x < b.center_x() else -420.0)), b.interior_left() + 50, b.interior_right() - 50)
		var debris: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE if i == 0 else HazardAttack.Kind.BRICK, floor_index, Vector2(x, b.floor_y(floor_index) - 172), Vector2(0, 70))
		debris.source = 1
		debris.pattern = HazardAttack.Pattern.SEISMIC_TIDE
		debris.splits = i == 0
		debris.motion = HazardAttack.Motion.ARC
		debris.gravity = 630
		debris.lifetime = w._flight_time(debris)
		w.plan_attack(debris, .7)
	return "SİSMİK GELGİT ÇEKİCİ"

## SKILL 4 — four element corner orbs weave converging nets after 0.8 s.
static func quadrant_seal(w: DisasterWaveManager, index: int) -> String:
	var b: ApartmentBuilding = w.building
	var top: float = b.floor_y(3) - 140
	var bottom: float = b.floor_y(0) - 60
	var center: Vector2 = Vector2(b.center_x(), (top + bottom) * .5)
	# TL storm, TR fire, BL flood, BR quake.
	var corners: Array = [[0, Vector2(b.interior_left() + 70, top)], [1, Vector2(b.interior_right() - 70, top)], [2, Vector2(b.interior_left() + 70, bottom)], [1, Vector2(b.interior_right() - 70, bottom)]]
	var spread: float = .17 if index % 8 < 4 else .21
	for corner: Array in corners:
		var source: int = corner[0]
		var origin: Vector2 = corner[1]
		var aim: float = (center - origin).angle()
		var shots: int = count(7)
		for i: int in range(shots):
			var a: HazardAttack = w._attack(ELEMENT_KINDS[source] as HazardAttack.Kind, floor_at(b, origin.y), origin, Vector2.from_angle(aim + (i - (shots-1)*.5) * spread*7.0/shots) * 500)
			a.source = source
			a.pattern = HazardAttack.Pattern.QUADRANT_SEAL
			a.radius = 10
			a.damage = 12
			a.lead = i == 0
			_ray(w, a)
			w.plan_attack(a, HazardAttack.SEAL_WARNING)
	return "ELEMENTAL KIYAMET MÜHRÜ"

## SKILL 5 — last 15 s: the overloaded titan relocates and fires fast double rings.
static func nova(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	var b: ApartmentBuilding = w.building
	var side: int = index % 3
	var f: int = floor_index if side < 2 else b.floor_count - 1
	var x: float = [b.interior_left() + 130, b.interior_right() - 130, b.center_x()][side]
	if f == w.player.current_floor and absf(x - w.player.global_position.x) < 220.0:
		x += 300.0 * (1.0 if x < b.center_x() else -1.0)
	var center: Vector2 = Vector2(x, b.floor_y(f) - 95)
	for ring: int in range(2):
		var shots: int = count(16)
		for i: int in range(shots):
			var element: int = i % 3
			var a: HazardAttack = w._attack(ELEMENT_KINDS[element] as HazardAttack.Kind, f, center, Vector2.from_angle(TAU * i / float(shots) + ring * PI / float(shots) + index * .2) * (560.0 - ring * 90.0))
			a.source = element
			a.pattern = HazardAttack.Pattern.CATACLYSM_NOVA
			a.radius = 9
			a.damage = 11
			a.lead = i == 0
			a.warning_delay = ring * .3
			_ray(w, a)
			# The ring centre, not the ray end, is the overloaded room cracked at launch.
			if a.lead: a.room_source = StringName("nova_%d" % f)
			w.plan_attack(a, .75)
	return "KATAKLİZMA NOVA · AŞIRI YÜKLEME"

## Called only when a warned nova ring actually launches: the burst cracks its room
## and the neighbour toward the building centre (shared pacing gate still applies).
static func overload_rooms(w: DisasterWaveManager, attack: HazardAttack) -> void:
	var b: ApartmentBuilding = w.building
	var f: int = int(String(attack.room_source).trim_prefix("nova_"))
	var column: int = b.column_at(attack.origin.x)
	for c: int in [column, clampi(column + (1 if attack.origin.x < b.center_x() else -1), 0, ApartmentBuilding.COLUMN_COUNT - 1)]:
		var room: RoomDiorama = b.room_at(f, c)
		if room.is_collapsed(): continue
		b.damage_room(f, c, 1.5*attack.difficulty_damage_scale, 1)
		if w.upgrades != null and w.upgrades.game.mechanics != null:
			w.upgrades.game.mechanics.burst(room.global_position + room.room_size * .5, Color("e9d6b5"), 14)

## Linear ray: lives until it leaves the building box; room damage lands where it ends.
static func _ray(w: DisasterWaveManager, a: HazardAttack) -> void:
	var b: ApartmentBuilding = w.building
	var box: Rect2 = Rect2(b.global_position.x + 18, b.global_position.y + 12, b.building_width - 36, b.floor_y(0) - b.global_position.y - 12)
	var life: float = 4.0
	if absf(a.velocity.x) > .001: life = minf(life, ((box.end.x if a.velocity.x > 0 else box.position.x) - a.origin.x) / a.velocity.x)
	if absf(a.velocity.y) > .001: life = minf(life, ((box.end.y if a.velocity.y > 0 else box.position.y) - a.origin.y) / a.velocity.y)
	a.lifetime = maxf(.1, life)
	a.floor_index = floor_at(b, a.point_at(a.lifetime).y)
	a.floor_y = b.floor_y(a.floor_index)

static func floor_at(b: ApartmentBuilding, y: float) -> int:
	return clampi(b.floor_count - 1 - int(floor((y - b.global_position.y + 20.0) / b.floor_height)), 0, b.floor_count - 1)
