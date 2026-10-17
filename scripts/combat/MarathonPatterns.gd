class_name MarathonPatterns
extends RefCounted
## Water/fire patterns share the original frozen-warning contract and fixed pool.

static func flood(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	match index % 5:
		0:
			for floor_id: int in range(2 if index % 10 == 5 else 1):
				zone(w, HazardAttack.Kind.FLOOD_ZONE, floor_id, Rect2(w.building.interior_left(), w.building.floor_y(floor_id) - 28, w.building.building_width - 48, 28), 3.5, 2, HazardAttack.Pattern.RISING_FLOOD)
			return "YÜKSELEN TAŞKIN · ÜST KATLARA ÇIK"
		1:
			for side: int in range(2):
				var f: int = (floor_index + side * 2) % 4
				var wall: HazardAttack = shot(w, HazardAttack.Kind.TIDAL_WALL, f, side, 920, 2, HazardAttack.Pattern.BILATERAL_TIDE, 92)
				wall.row_height = 174
				wall.radius = 16
				w.plan_attack(wall, 1.0)
				var blade: HazardAttack = shot(w, HazardAttack.Kind.WATER_BLADE, (f + 1) % 4, side, 740, 2, HazardAttack.Pattern.BILATERAL_TIDE, 72)
				w.plan_attack(blade, .75)
			return "ÇİFT CEPHE GELGİTİ · İŞARETLİ KATLARDAN ÇIK"
		2:
			for side: int in range(2):
				var a: HazardAttack = shot(w, HazardAttack.Kind.HYDRO_ORB, (floor_index + side) % 4, side, 680, 2, HazardAttack.Pattern.HYDRO_BOUNCE, 95)
				a.velocity.y = -310 if side == 0 else 330
				a.radius = 23
				a.splits = true
				var b: ApartmentBuilding = w.building
				a.reflect_in(Rect2(b.interior_left() + a.radius, a.floor_y - 180 + a.radius, b.building_width - 48 - a.radius * 2, 180 - a.radius * 2))
				w.plan_attack(a, .75)
			return "BASINÇ KÜRELERİ · 3 SEKME / 6 PARÇA"
		3:
			var b: ApartmentBuilding = w.building
			var center: Vector2 = Vector2(b.center_x() + (200 if index % 2 == 0 else -200), b.floor_y(floor_index) - 90)
			zone(w, HazardAttack.Kind.WHIRLPOOL, floor_index, Rect2(center - Vector2(280,85), Vector2(560,170)), 2.2, 2, HazardAttack.Pattern.WHIRLPOOL_PULL)
			for i: int in range(7):
				var a: HazardAttack = shot(w, HazardAttack.Kind.HARPOON, floor_index, index % 2, 790, 2, HazardAttack.Pattern.WHIRLPOOL_PULL, 90)
				a.velocity = a.velocity.rotated((i - 3) * .035)
				a.lifetime = w._flight_time(a)
				w.plan_attack(a, .75)
			return "GİRDAP ÇEKİMİ + ZIPKIN YELPAZESİ"
		_:
			for i: int in range(8):
				var a: HazardAttack = shot(w, HazardAttack.Kind.FLOATING_DEBRIS, (floor_index + i / 2) % 4, i % 2, 650 + (i % 3) * 40, 2, HazardAttack.Pattern.DEBRIS_CROSS, 70 + (i % 2) * 55)
				a.motion = HazardAttack.Motion.WAVE
				a.amplitude = 32
				a.frequency = 8 + i % 3
				w.plan_attack(a, .75)
			return "SÜRÜKLENEN ENKAZ · VARİL / KÜTÜK / KABLO"

static func fire(w: DisasterWaveManager, index: int, floor_index: int) -> String:
	var b: ApartmentBuilding = w.building
	match index % 6:
		0:
			for i: int in range(10):
				var f: int = 0 if i%2 == 0 else (floor_index+i/3)%4
				var x: float = b.interior_left() + 70 + fmod(index * 97 + i * 163, b.building_width - 200)
				var a: HazardAttack = w._attack(HazardAttack.Kind.METEOR, f, Vector2(x, b.floor_y(f) - 177), Vector2(190 if i % 2 == 0 else -190, 360))
				if i%2 == 0:
					a.origin.y = b.global_position.y-45
					a.cross_floor = true
					a.velocity.x = 190 if x < b.center_x() else -190
				a.source = 3
				a.pattern = HazardAttack.Pattern.METEOR_SHOWER
				a.motion = HazardAttack.Motion.ARC
				a.gravity = 680
				a.splits = true
				a.lifetime = w._flight_time(a)
				w.plan_attack(a, .75)
			return "PİROKLASTİK METEOR YAĞMURU"
		1:
			for i: int in range(3):
				var a: HazardAttack = shot(w, HazardAttack.Kind.METEOR, (floor_index + i) % 4, index % 2, 720, 3, HazardAttack.Pattern.NAPALM, 150)
				a.velocity.y = 160
				a.motion = HazardAttack.Motion.ARC
				a.gravity = 380
				a.leaves_fire = true
				a.origin.x = b.interior_left() + 180 + fmod(index * 131 + i * 431, b.building_width - 360)
				a.lifetime = w._flight_time(a)
				w.plan_attack(a, .75)
			return "NAPALM · ZEMİNDE 3 SANİYE ALEV"
		2:
			for f: int in [floor_index, (floor_index + 2) % 4]:
				for arm: int in range(2):
					for i: int in range(7):
						var a: HazardAttack = shot(w, HazardAttack.Kind.FIREBALL, f, index % 2, 810 + i * 24, 3, HazardAttack.Pattern.DOUBLE_HELIX, 96)
						a.motion = HazardAttack.Motion.HELIX
						a.amplitude = 57
						a.frequency = 7.5
						a.spiral_angle = arm * PI
						a.warning_delay = i * .12
						w.plan_attack(a, .75)
			return "ÇİFT SARMAL · ALEV KORİDORLARI"
		3:
			for i: int in range(5):
				var f: int = (floor_index + i) % 4
				var center: Vector2 = Vector2(b.interior_left() + 110 + fmod(index * 107 + i * 317, b.building_width - 250), b.floor_y(f) - 95)
				# The ring itself is the full one-second warning; all eight rays are frozen now.
				for ray: int in range(8):
					var a: HazardAttack = w._attack(HazardAttack.Kind.FIRE_DART, f, center, Vector2.from_angle(ray * TAU / 8) * 680)
					a.source = 3
					a.pattern = HazardAttack.Pattern.EMBER_DETONATION
					a.lead = ray == 0
					a.lifetime = w._flight_time(a)
					w.plan_attack(a, 1.0)
			return "KOR ÇEKİRDEKLERİ · HALKA DOLUNCA 8 YÖN"
		4:
			zone(w, HazardAttack.Kind.WHIRLPOOL, floor_index, Rect2(b.interior_left(), b.floor_y(floor_index)-180, b.building_width-48, 180), .9, 3, HazardAttack.Pattern.BACKDRAFT)
			var beam: HazardAttack = shot(w, HazardAttack.Kind.FIRE_BEAM, floor_index, index % 2, 2100, 3, HazardAttack.Pattern.BACKDRAFT, 88)
			beam.row_height = 174
			beam.warning_delay = .9
			w.plan_attack(beam, 1.0)
			for offset: int in [-1,1]:
				var f: int = floor_index + offset
				if f < 0 or f > 3: continue
				var a: HazardAttack = shot(w, HazardAttack.Kind.LOW_FLAME, f, (index + 1) % 2, 670, 3, HazardAttack.Pattern.BACKDRAFT, 12)
				a.radius = 12
				w.plan_attack(a, .75)
			return "TERMAL VAKUM → ALEV DUVARI · KAT DEĞİŞTİR"
		_:
			for side: int in range(2):
				for i: int in range(5):
					var a: HazardAttack = shot(w, HazardAttack.Kind.FIREBALL, (floor_index + side * 2) % 4, side, 940, 3, HazardAttack.Pattern.DOUBLE_HELIX, 100)
					a.velocity = a.velocity.rotated((i - 2) * .04)
					a.lifetime = w._flight_time(a)
					w.plan_attack(a, .75)
			return "KOR TİTANI · ÇİFT CEPHE ALEV HÜCUMU"

static func shot(w: DisasterWaveManager, kind: HazardAttack.Kind, f: int, side: int, speed: float, source: int, pattern: HazardAttack.Pattern, height: float) -> HazardAttack:
	var b: ApartmentBuilding = w.building
	var a: HazardAttack = w._attack(kind, f, Vector2(b.interior_left()+30 if side == 0 else b.interior_right()-30, b.floor_y(f)-height), Vector2(speed if side == 0 else -speed,0))
	a.source = source
	a.pattern = pattern
	a.lifetime = w._flight_time(a)
	return a

static func zone(w: DisasterWaveManager, kind: HazardAttack.Kind, f: int, area: Rect2, duration: float, source: int, pattern: HazardAttack.Pattern) -> void:
	var a: HazardAttack = w._attack(kind, f, area.get_center(), Vector2.ZERO)
	a.source = source
	a.pattern = pattern
	a.area = area
	a.lifetime = duration
	a.effect_strength = 125.0 if kind == HazardAttack.Kind.WHIRLPOOL else .35
	w.plan_attack(a, 1.0 if kind == HazardAttack.Kind.FLOOD_ZONE else .75)

static func split(w: DisasterWaveManager, parent: HazardAttack, point: Vector2) -> void:
	var water: bool = parent.kind == HazardAttack.Kind.HYDRO_ORB
	var count: int = 6 if water else 4
	for i: int in range(count):
		var a: HazardAttack = w._attack(HazardAttack.Kind.WATER_SHARD if water else HazardAttack.Kind.FIRE_DART, parent.floor_index, point, Vector2.from_angle(i * TAU / count + (PI if not water else .2)) * (590 if water else 620))
		a.source = parent.source
		a.pattern = HazardAttack.Pattern.SPLINTER
		a.lifetime = minf(.9, w._flight_time(a))
		w.plan_attack(a, .55)

static func ignite(w: DisasterWaveManager, parent: HazardAttack, point: Vector2) -> void:
	var room: RoomDiorama = w.building.room_at_point(parent.floor_index, point.x)
	zone(w, HazardAttack.Kind.FIRE_ZONE, parent.floor_index, Rect2(room.global_position.x+24, parent.floor_y-28, room.room_size.x-48, 28), 3.0, 3, HazardAttack.Pattern.NAPALM)
