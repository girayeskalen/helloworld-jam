class_name BossPatterns
extends RefCounted
## Pattern authors only describe paths. All damaging activations go through warn().

static func fan(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	var count: int = 7 if serial % 2 == 0 else 5
	var origin: Vector2 = Vector2(w.building.global_position.x + 65, w.building.floor_y(floor_index) - 92)
	for i: int in range(count):
		var angle: float = (i - (count - 1) * .5) * .115 + sin(serial * 1.7) * .035
		var kind: HazardAttack.Kind = HazardAttack.Kind.GLASS if i % 2 == 0 else HazardAttack.Kind.WIND_ORB
		var shot: HazardAttack = w._attack(kind, floor_index, origin, Vector2.from_angle(angle) * 470)
		shot.pattern = HazardAttack.Pattern.FAN
		shot.lifetime = w._flight_time(shot)
		w.plan_attack(shot, .65)

static func furniture(w: DisasterWaveManager, floor_index: int) -> void:
	for i: int in range(2):
		var a: HazardAttack = w._attack(HazardAttack.Kind.POT if i == 0 else HazardAttack.Kind.CHAIR, floor_index, Vector2(w.building.global_position.x + 75, w.building.floor_y(floor_index) - 85), Vector2(450, -150 if i == 0 else 0))
		a.pattern = HazardAttack.Pattern.FURNITURE
		a.motion = HazardAttack.Motion.ARC if i == 0 else HazardAttack.Motion.WAVE
		a.gravity = 460
		a.amplitude = 24
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .7)
	var blade: HazardAttack = w._attack(HazardAttack.Kind.WIND_BLADE, floor_index, Vector2(w.building.global_position.x + 30, w.building.floor_y(floor_index) - 46), Vector2(620, 0))
	blade.pattern = HazardAttack.Pattern.FURNITURE
	blade.lifetime = w._flight_time(blade)
	w.plan_attack(blade, .75)

## Girdap halkası: a mini-tornado eye opens inside a room and releases a rotating,
## expanding ring of glass and wind orbs. The ring is squashed to its floor's band.
static func vortex(w: DisasterWaveManager, floor_index: int, serial: int, count: int = 10) -> void:
	var b: ApartmentBuilding = w.building
	var columns: Array[float] = [0.5, 1.5, 2.5, 3.5]
	var x: float = b.global_position.x + b.room_width * columns[serial % columns.size()]
	# Never open the eye on top of the player: shift a full room away if too close.
	if floor_index == w.player.current_floor and absf(x - w.player.global_position.x) < 240.0:
		x += b.room_width * (1.0 if x < b.center_x() else -1.0)
	var center: Vector2 = Vector2(x, b.floor_y(floor_index) - 94)
	var spin: float = 1.15 if serial % 2 == 0 else -1.15
	for i: int in range(count):
		var a: HazardAttack = w._attack(HazardAttack.Kind.GLASS if i % 2 == 0 else HazardAttack.Kind.WIND_ORB, floor_index, center, Vector2.ZERO)
		a.pattern = HazardAttack.Pattern.VORTEX
		a.motion = HazardAttack.Motion.SPIRAL
		a.radius = 9
		a.damage = 9
		a.amplitude = 70
		a.spiral_angle = TAU * float(i) / float(count) + serial * 0.4
		a.spiral_spin = spin
		a.spiral_speed = 290
		a.spiral_start = 60
		a.lead = i == 0
		a.lifetime = w._spiral_time(a, 2.6)
		w.plan_attack(a, .7)

## Çapraz yaylım: shallow diagonals from the window side and the roof/right air
## current cross in an X, plus a mid-height blade and a thrown pot.
static func crossfire(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	var b: ApartmentBuilding = w.building
	var y0: float = b.floor_y(floor_index)
	# Both volleys start in the same band and climb (or dive) toward each other,
	# so their paths genuinely cross mid-floor; the next volley mirrors vertically.
	var low: bool = serial % 2 == 0
	for side: int in range(2):
		var from_left: bool = side == 0
		var x: float = b.global_position.x + (50.0 if from_left else b.building_width - 50.0)
		var origin: Vector2 = Vector2(x, y0 - (34.0 if low else 160.0))
		for i: int in range(2):
			var slope: float = 0.085 + i * 0.05
			var direction: Vector2 = Vector2(1.0 if from_left else -1.0, -slope if low else slope).normalized()
			var kind: HazardAttack.Kind = HazardAttack.Kind.WIND_BLADE if i == 0 and not low else HazardAttack.Kind.GLASS
			var a: HazardAttack = w._attack(kind, floor_index, origin, direction * 560)
			a.pattern = HazardAttack.Pattern.CROSSFIRE
			if kind == HazardAttack.Kind.WIND_BLADE:
				a.radius = 20
				a.damage = 14
				a.structure_damage = 0.6
			a.lifetime = w._flight_time(a)
			w.plan_attack(a, .7)
	# A flying pot from the window, arcing over the X.
	var pot: HazardAttack = w._attack(HazardAttack.Kind.POT, floor_index, Vector2(b.global_position.x + 75, y0 - 120), Vector2(380, -60))
	pot.pattern = HazardAttack.Pattern.CROSSFIRE
	pot.motion = HazardAttack.Motion.ARC
	pot.gravity = 300
	pot.lifetime = w._flight_time(pot)
	w.plan_attack(pot, .75)

## Hortum koridoru: a full-floor sweep on the player's floor, while the floors one
## up and one down get low rolling debris/pots that must be jumped after escaping.
static func corridor(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	full_row(w, floor_index, 0)
	for offset: int in [-1, 1]:
		var other: int = floor_index + offset
		if other < 0 or other >= w.building.floor_count:
			continue
		var from_left: bool = (other + serial) % 2 == 0
		var kind: HazardAttack.Kind = HazardAttack.Kind.DEBRIS if offset > 0 else HazardAttack.Kind.POT
		var x: float = w.building.global_position.x + (40.0 if from_left else w.building.building_width - 40.0)
		var a: HazardAttack = w._attack(kind, other, Vector2(x, w.building.floor_y(other) - 16), Vector2(430 if from_left else -430, 0))
		a.pattern = HazardAttack.Pattern.CORRIDOR_WAVE
		a.radius = 16
		a.damage = 12
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .75)

static func ground_wave(w: DisasterWaveManager, floor_index: int, outward: bool) -> void:
	for side: int in range(2 if outward else 1):
		var x: float = w.building.center_x() if outward else w.building.global_position.x + w.building.building_width - 40
		var direction: float = (-1.0 if side == 0 else 1.0)
		var a: HazardAttack = w._attack(HazardAttack.Kind.SHOCKWAVE, floor_index, Vector2(x, w.building.floor_y(floor_index) - 12), Vector2(direction * 520, 0))
		a.source = 1
		a.starts_slam = side == 0
		a.pattern = HazardAttack.Pattern.GROUND_WAVE
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .7)

static func cluster(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	var left: float = w.building.global_position.x
	var span: float = w.building.building_width - 230
	for i: int in range(3):
		var x: float = left + 110 + fmod(serial * 173 + i * 319, span)
		if i == 0:
			x = clampf(w.player.global_position.x, left + 65, left + w.building.building_width - 65)
		var a: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE if i < 2 else HazardAttack.Kind.BRICK, floor_index, Vector2(x, w.building.floor_y(floor_index) - 172), Vector2(0, 70))
		a.source = 1
		a.starts_slam = i == 0
		a.pattern = HazardAttack.Pattern.CLUSTER
		a.splits = i < 2
		a.motion = HazardAttack.Motion.ARC
		a.gravity = 630
		a.lifetime = w._flight_time(a)
		w.plan_attack(a, .7)

static func full_row(w: DisasterWaveManager, floor_index: int, source: int) -> void:
	var width: float = w.building.building_width
	var start_x: float = w.building.global_position.x + (27 if source == 0 else width - 27)
	var a: HazardAttack = w._attack(HazardAttack.Kind.ROW_SWEEP, floor_index, Vector2(start_x, w.building.floor_y(floor_index) - 82), Vector2(1900 if source == 0 else -1900, 0))
	a.source = source
	a.pattern = HazardAttack.Pattern.FULL_ROW
	a.starts_slam = source == 1
	a.lifetime = (width - 54.0) / 1900.0
	w.plan_attack(a, 1.0)

static func room_objects(w: DisasterWaveManager, serial: int) -> void:
	for prop: BuildingProp in w.building.props:
		if prop.condition != BuildingProp.Condition.UNSECURED:
			continue
		var room: RoomDiorama = prop.get_parent() as RoomDiorama
		if room != null and (room.is_collapsed() or room.has_reinforcement(RoomDiorama.Reinforcement.ANCHOR)):
			continue
		var kinds: Array[int] = []
		match prop.kind:
			BuildingProp.Kind.WARDROBE: kinds = [HazardAttack.Kind.WARDROBE]
			BuildingProp.Kind.CHANDELIER: kinds = [HazardAttack.Kind.CHANDELIER]
			BuildingProp.Kind.KITCHEN: kinds = [HazardAttack.Kind.KNIFE, HazardAttack.Kind.PLATE]
			BuildingProp.Kind.WORKBENCH: kinds = [HazardAttack.Kind.SAW, HazardAttack.Kind.TOOL]
			BuildingProp.Kind.BOOKCASE: kinds = [HazardAttack.Kind.BOOK]
			BuildingProp.Kind.TOY_SHELF: kinds = [HazardAttack.Kind.TOY]
		if kinds.is_empty():
			continue
		prop.shake_unsecured(.9)
		for i: int in range(kinds.size()):
			var a: HazardAttack = w._attack(kinds[i] as HazardAttack.Kind, prop.floor_index, prop.global_position + Vector2(0, -minf(prop.prop_size.y * .65, 115)), Vector2(-210 if serial % 2 == 0 else 210, -100 - i * 65))
			a.source = 1
			a.pattern = HazardAttack.Pattern.ROOM_OBJECT
			a.room_source = prop.object_id
			a.motion = HazardAttack.Motion.ARC
			a.gravity = 580
			if a.kind in [HazardAttack.Kind.WARDROBE, HazardAttack.Kind.CHANDELIER]:
				a.velocity = Vector2(0, 60)
				a.splits = true
			a.lifetime = w._flight_time(a)
			w.plan_attack(a, .7)

static func splinters(w: DisasterWaveManager, parent: HazardAttack, impact: Vector2) -> void:
	# Impact opens a new, non-damaging 0.55 s warning, then 3 shards hop away.
	# This is intentionally not an unannounced same-frame secondary collision.
	var pieces: int = CataclysmPatterns.count(3) if w.mode == DisasterWaveManager.Mode.CATACLYSM else 3
	for i: int in range(pieces):
		var a: HazardAttack = w._attack(HazardAttack.Kind.SHARD, parent.floor_index, Vector2(impact.x, parent.floor_y - 8), Vector2(lerpf(-300,240,float(i)/maxi(1,pieces-1)), 0))
		a.source = parent.source
		a.pattern = HazardAttack.Pattern.SPLINTER
		a.motion = HazardAttack.Motion.BOUNCE
		a.amplitude = 43 + i * 17
		a.frequency = 2.8 + i * .4
		a.lifetime = minf(1.8, w._flight_time(a))
		a.room_source = parent.room_source
		w.plan_attack(a, .55)
