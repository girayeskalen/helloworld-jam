class_name BossPatterns
extends RefCounted
## Pattern authors only describe paths. All damaging activations go through warn().
## Step 7: the storm and quake bosses use the geometric choreographies at the end of
## this file (no random clutter, no room furniture). The older helpers above remain
## for compatibility tests and are not part of the normal boss cycles.

## Base recovery after each choreography (divided by the live tempo). Index = pattern.
const STORM_BEATS: Array[float] = [2.7, 2.9, 2.4, 2.0, 2.5]
const QUAKE_BEATS: Array[float] = [2.0, 1.8, 2.5, 2.1]
const QUAKE_COOLDOWN_SCALE: float = 1.1
const QUAKE_SPEED_SCALE: float = .9
const QUAKE_GAP_SCALE: float = 1.1
## Circular corridors are measured edge-to-edge at this world radius.
const QUAKE_RING_REFERENCE: float = 200.0

static func quake_gap_scale(w: DisasterWaveManager) -> float:
	return QUAKE_GAP_SCALE if w.mode == DisasterWaveManager.Mode.EARTHQUAKE else 1.0

static func quake_ring_radius(w: DisasterWaveManager) -> float:
	var spacing: float = 2.0*QUAKE_RING_REFERENCE*sin(PI/12.0)
	return (spacing-(spacing-24.0)*quake_gap_scale(w))*.5
const STORM_LABELS: Array[String] = ["İKİZ GİRDAP ÇARKI", "GÜVENLİ KAT RULETİ", "SİNÜS RÜZGÂR TÜNELİ", "ÇAPRAZ RÜZGÂR MAKASI", "SİKLON HALKASI & İTME"]
const QUAKE_LABELS: Array[String] = ["DAMA TAHTASI SÜTUN ÇÖKMESİ", "YÜRÜYEN SİSMİK FAY DALGASI", "SİSMİK MERKEZ HALKALARI", "KAT EZİCİ BALYOZ"]

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

# ============================================================ Step 7: storm ====

## Building centre used by the pinwheel and the tectonic rings.
static func core_point(b: ApartmentBuilding) -> Vector2:
	return Vector2(b.center_x(), (b.floor_y(3) + b.floor_y(0)) * .5 - 100.0)

## A: four continuous spiral arms turning clockwise around a storm eye at the centre.
static func pinwheel(w: DisasterWaveManager, serial: int) -> void:
	var center: Vector2 = core_point(w.building)
	var steps: int = 9
	var turn: float = deg_to_rad(11.0)
	var base: float = (serial % 2) * PI / 4.0
	for k: int in range(steps):
		for arm: int in range(4):
			var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB, 0, center, Vector2.from_angle(base + arm * PI * .5 + k * turn) * 330.0)
			a.source = 0
			a.pattern = HazardAttack.Pattern.PINWHEEL
			a.radius = 10
			a.damage = 10
			a.lead = k == 0 and arm == 0
			a.warning_delay = k * .1
			CataclysmPatterns._ray(w, a)
			w.plan_attack(a)

## B: three floors are swept by wind corridors, one adjacent floor stays safe; then
## a second safe floor next to the first. Returns both safe floors.
static func safe_floor_roulette(w: DisasterWaveManager, serial: int) -> Array[int]:
	var b: ApartmentBuilding = w.building
	var current: int = w.player.current_floor
	var up: bool = current == 0 or (current < b.floor_count - 1 and serial % 2 == 0)
	var first: int = current + (1 if up else -1)
	var step: int = 1 if up else -1
	var second: int = first + step if first + step >= 0 and first + step < b.floor_count else first - step
	var sweep: float = 2400.0
	var travel: float = (b.building_width - 54.0) / sweep
	for wave: int in range(2):
		var safe: int = first if wave == 0 else second
		var from_left: bool = wave == 0
		for f: int in range(b.floor_count):
			if f == safe: continue
			var a: HazardAttack = w._attack(HazardAttack.Kind.ROW_SWEEP, f, Vector2(b.global_position.x + (27.0 if from_left else b.building_width - 27.0), b.floor_y(f) - 87.0), Vector2(sweep if from_left else -sweep, 0))
			a.source = 0
			a.pattern = HazardAttack.Pattern.SAFE_FLOOR
			a.row_height = 174.0
			a.radius = 12
			a.damage = 18
			a.lifetime = travel
			a.room_source = StringName("safe_%d" % safe)
			a.lead = f == (0 if safe != 0 else 1)
			# The second corridor set appears only after the first one has passed.
			a.warning_delay = 0.0 if wave == 0 else HazardAttack.SAFE_FLOOR_WARNING + travel + .05
			w.plan_attack(a, HazardAttack.SAFE_FLOOR_WARNING)
	return [first, second]

## C: two parallel sine streams form a tunnel that flows right along one floor.
## All bullets of a stream share one frozen path, so its laser reads as one wave.
static func sine_tunnel(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	var b: ApartmentBuilding = w.building
	var speed: float = 520.0
	var x0: float = b.interior_left() + 10.0
	var low: float = b.floor_y(floor_index) - 47.0
	var phase: float = PI if serial % 2 == 1 else 0.0
	for stream: int in range(2):
		for k: int in range(9):
			var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB, floor_index, Vector2(x0, low - stream * TUNNEL_GAP), Vector2(speed, 0))
			a.source = 0
			a.pattern = HazardAttack.Pattern.SINE_TUNNEL
			a.motion = HazardAttack.Motion.WAVE
			a.amplitude = 33.0
			a.frequency = TAU * speed / 420.0
			a.spiral_angle = phase
			a.radius = 9
			a.damage = 10
			a.lead = k == 0 and stream == 0
			a.warning_delay = k * .075
			a.lifetime = (b.interior_right() - 10.0 - x0) / speed
			w.plan_attack(a)

## Vertical distance between the two tunnel streams.
const TUNNEL_GAP: float = 96.0

## D: blades from the top-left and bottom-left corners cross in an X at the player's
## room, then a narrower second X follows.
static func scissor(w: DisasterWaveManager, serial: int) -> Vector2:
	var b: ApartmentBuilding = w.building
	var target: Vector2 = Vector2(clampf(w.player.global_position.x, b.interior_left() + 260.0, b.interior_right() - 60.0), b.floor_y(w.player.current_floor) - 60.0)
	var corners: Array[Vector2] = [Vector2(b.interior_left() + 18.0, b.floor_y(3) - 168.0), Vector2(b.interior_left() + 18.0, b.floor_y(0) - 34.0)]
	for cut: int in range(2):
		var spread: float = .09 if cut == 0 else .045
		for corner: Vector2 in corners:
			var aim: float = (target - corner).angle()
			for i: int in range(3):
				var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_BLADE, 0, corner, Vector2.from_angle(aim + (i - 1) * spread) * (640.0 if cut == 0 else 720.0))
				a.source = 0
				a.pattern = HazardAttack.Pattern.SCISSOR
				a.radius = 14
				a.damage = 14
				a.cross_floor = true
				a.lead = i == 1 and cut == 0 and corner == corners[0]
				a.warning_delay = .45 * cut
				CataclysmPatterns._ray(w, a)
				w.plan_attack(a)
	return target

## E: a gentle push plus three expanding rings: low (jump), head height (stay down),
## and a full gapped ring (find the gap or dash).
static func cyclone_rings(w: DisasterWaveManager, floor_index: int, serial: int) -> void:
	var b: ApartmentBuilding = w.building
	w.storm_gust(1.0, w.gust_strength * .7)
	# Two columns away from the player, so most of each ring stays inside the building.
	var column: int = (b.column_at(w.player.global_position.x) + 2) % ApartmentBuilding.COLUMN_COUNT
	var x: float = b.global_position.x + b.room_width * (column + .5)
	var y0: float = b.floor_y(floor_index)
	var rings: Array = [[y0 - 14.0, 8.0, [0.0, .35, -.35, PI, PI - .35, PI + .35]], [y0 - 84.0, 8.0, [0.0, .35, -.35, PI, PI - .35, PI + .35]], [y0 - 60.0, 60.0, []]]
	for slot: int in range(12):
		if slot % 3 != 2: (rings[2][2] as Array).append(slot * TAU / 12.0)
	for ring: int in range(3):
		var angles: Array = rings[ring][2]
		for i: int in range(angles.size()):
			var a: HazardAttack = w._attack(HazardAttack.Kind.WIND_ORB, floor_index, Vector2(x, float(rings[ring][0])), Vector2.ZERO)
			a.source = 0
			a.pattern = HazardAttack.Pattern.CYCLONE_RING
			a.motion = HazardAttack.Motion.SPIRAL
			a.radius = 9
			a.damage = 10
			a.amplitude = float(rings[ring][1])
			a.spiral_angle = float(angles[i]) + (serial % 2) * .13
			a.spiral_spin = .55 if ring == 2 else 0.0
			a.spiral_speed = 400.0
			a.spiral_start = 18.0
			a.lead = i == 0
			a.warning_delay = ring * .5
			a.lifetime = w._spiral_time(a, 3.2)
			w.plan_attack(a)

# ========================================================== Step 7: quake ====

## 1: columns A+C then B+D collapse on every floor (room-sized ceiling rock falls).
static func checker_crush(w: DisasterWaveManager, serial: int) -> Array[int]:
	var b: ApartmentBuilding = w.building
	var first: Array[int] = [0, 2]
	var second: Array[int] = [1, 3]
	if serial % 2 == 1:
		first = [1, 3]
		second = [0, 2]
	for strike: int in range(2):
		for column: int in (first if strike == 0 else second):
			for f: int in range(b.floor_count):
				var room: RoomDiorama = b.room_at(f, column)
				var base_width: float = room.room_size.x-28.0
				var base_gap: float = 2*b.room_width-base_width
				var inset: float = base_gap*(quake_gap_scale(w)-1)*.5
				var area: Rect2 = Rect2(room.global_position.x+14+inset,b.floor_y(f)-196,base_width-2*inset,196)
				var a: HazardAttack = w._attack(HazardAttack.Kind.ROCKFALL, f, area.get_center(), Vector2.ZERO)
				a.source = 1
				a.pattern = HazardAttack.Pattern.CHECKER_CRUSH
				a.area = area
				a.lifetime = .38
				a.damage = 18
				a.lead = f == 0 and column == (first if strike == 0 else second)[0]
				a.starts_slam = a.lead and strike == 0
				a.warning_delay = .5 * strike
				w.plan_attack(a)
	var order: Array[int] = first.duplicate()
	order.append_array(second)
	return order

## 2: a fist plants and a spike wave runs right-to-left along every floor in turn.
static func fault_wave(w: DisasterWaveManager, serial: int) -> void:
	var b: ApartmentBuilding = w.building
	for f: int in range(b.floor_count):
		var order: int = f if serial % 2 == 0 else b.floor_count - 1 - f
		var a: HazardAttack = w._attack(HazardAttack.Kind.SHOCKWAVE, f, Vector2(b.interior_right() - 10.0, b.floor_y(f) - 13.0), Vector2(-560.0, 0))
		a.source = 1
		a.pattern = HazardAttack.Pattern.FAULT_WAVE
		a.radius = 13
		a.damage = 14
		a.starts_slam = order == 0
		a.lead = order == 0
		a.warning_delay = order * .16
		a.lifetime = w._flight_time(a)
		w.plan_attack(a)

## 3: the golem hits the central column; three aligned 12-rock rings expand, leaving
## the same clear corridors between rays every time.
static func tectonic_rings(w: DisasterWaveManager, serial: int) -> void:
	var center: Vector2 = core_point(w.building)
	var offset: float = deg_to_rad(15.0) if serial % 2 == 0 else 0.0
	for ring: int in range(3):
		for i: int in range(12):
			var a: HazardAttack = w._attack(HazardAttack.Kind.SHARD, 0, center, Vector2.from_angle(offset + i * TAU / 12.0) * 360.0)
			a.source = 1
			a.pattern = HazardAttack.Pattern.TECTONIC_RING
			a.radius = quake_ring_radius(w)
			a.damage = 12
			a.lead = i == 0
			a.starts_slam = i == 0 and ring == 0
			a.warning_delay = ring * .45
			CataclysmPatterns._ray(w, a)
			w.plan_attack(a)

## 4: boulders roll right-to-left across two floors: one low (jump it), one high
## (stay on the ground under it); the second pair swaps heights.
static func boulder_stampede(w: DisasterWaveManager, floor_index: int, serial: int) -> Array[int]:
	var b: ApartmentBuilding = w.building
	var other: int = floor_index + 1 if floor_index < b.floor_count - 1 else floor_index - 1
	var floors: Array[int] = [floor_index, other]
	for pair: int in range(2):
		for i: int in range(2):
			var f: int = floors[i]
			var high: bool = (i + pair + serial) % 2 == 1
			var a: HazardAttack = w._attack(HazardAttack.Kind.CONCRETE, f, Vector2(b.interior_right() - 30.0, b.floor_y(f) - (98.0 if high else 24.0)), Vector2(-600.0, 0))
			a.source = 1
			a.pattern = HazardAttack.Pattern.BOULDER_STAMPEDE
			a.radius = 22
			a.damage = 18
			a.lead = i == 0 and pair == 0
			a.starts_slam = a.lead
			a.warning_delay = pair * .62
			a.lifetime = w._flight_time(a)
			w.plan_attack(a)
	return floors
