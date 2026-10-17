class_name DisasterBoss
extends Node2D
## Multi-segment procedural bosses. The rig functions return every segment transform
## (also used by tests); _draw only paints what the rig computed.

enum Kind { STORM, EARTHQUAKE }
const SLAM_TIME: float = 0.4
const STORM_RINGS: int = 12

@export var kind: Kind = Kind.STORM
@export var boss_sprite: Texture2D
@export var custom_sprite: Texture2D
var retreat: float = 0.0
var _home: Vector2
var pattern_label: String = ""
var _clock: float = 0.0
var _charge_left: float = 0.0
var _charge_total: float = 0.7
var _slam_left: float = 0.0
var _arrival: float = 0.0
var _smoke_clock: float = 0.0
var _particles: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Grimdark palettes.
const INK: Color = Color("111518")
const BASALT: Color = Color("4b504a")
const BASALT_LIGHT: Color = Color("6e7266")
const BASALT_DARK: Color = Color("2f3532")
const PLATE: Color = Color("5d6157")
const LAVA: Color = Color("ff6a2a")
const LAVA_HOT: Color = Color("ffc15a")
const STORM_DARK: Color = Color("2b3a46")
const STORM_MID: Color = Color("3a4d5a")
const ELECTRIC: Color = Color("8fd8ff")

func _ready() -> void:
	_home = position
	_rng.seed = 4401 + kind * 17

func plan_pattern(waves: DisasterWaveManager, index: int, floor_index: int) -> void:
	var floors: int = waves.building.floor_count
	if kind == Kind.STORM:
		# Bullet-hell cycle: every beat is telegraphed; one corridor beat forces a floor change.
		match index % 6:
			0:
				pattern_label = "GİRDAP HALKASI"
				BossPatterns.vortex(waves, floor_index, index, 12 if (index / 6) % 2 == 1 else 10)
			1:
				pattern_label = "ÇAPRAZ YAYLIM"
				BossPatterns.crossfire(waves, floor_index, index)
			2:
				pattern_label = "RÜZGÂR KÜKREMESİ"
				waves.storm_gust()
				BossPatterns.fan(waves, floor_index, index)
			3:
				pattern_label = "HORTUM KORİDORU"
				BossPatterns.corridor(waves, waves.player.current_floor, index)
			4:
				pattern_label = "SAVRULAN EŞYALAR"
				BossPatterns.furniture(waves, floor_index)
				BossPatterns.vortex(waves, (floor_index + 2) % floors, index, 8)
			5:
				pattern_label = "CAM YELPAZESİ"
				BossPatterns.fan(waves, floor_index, index)
	else:
		match index % 3:
			0:
				pattern_label = "ZEMİN ŞOKU"
				BossPatterns.ground_wave(waves, floor_index, index % 2 == 1)
				BossPatterns.cluster(waves, (floor_index + 1) % floors, index)
			1:
				pattern_label = "PARÇALANAN ENKAZ"
				BossPatterns.cluster(waves, floor_index, index)
			2:
				pattern_label = "YIKIM TÜNELİ"
				BossPatterns.full_row(waves, floor_index, 1)
		BossPatterns.room_objects(waves, index)
	cue_attack((1.0 if pattern_label in ["HORTUM KORİDORU", "YIKIM TÜNELİ"] else .7) + waves.telegraphs.warning_bonus)

func set_active(value: bool) -> void:
	visible = value
	position = _home
	scale = Vector2.ONE
	modulate = Color.WHITE
	retreat = 0.0
	_charge_left = 0.0
	_slam_left = 0.0
	_arrival = 0.0
	_particles.clear()

## Wave manager owns transition time: the full combat clock starts after entry.
func transition_pose(progress: float, exiting: bool) -> void:
	var t: float = smoothstep(0.0, 1.0, clampf(progress, 0.0, 1.0))
	_arrival = 1.0
	retreat = t if exiting else 0.0
	var displaced: float = t if exiting else 1.0 - t
	position = _home + Vector2(0, (-850.0 if kind == Kind.STORM else 650.0) * displaced)
	scale = Vector2(1.0 - displaced * 0.85, 1.0 + displaced * 0.18) if kind == Kind.STORM else Vector2.ONE
	modulate.a = 1.0 - smoothstep(0.65, 1.0, displaced)
	if exiting and kind == Kind.EARTHQUAKE:
		position.x += sin(progress * 95.0) * 12.0 * (1.0 - t)
	queue_redraw()

## Wind-up lasts exactly as long as the attack's warning.
func cue_attack(seconds: float) -> void:
	_charge_total = maxf(seconds, 0.01)
	_charge_left = _charge_total

func is_charging() -> bool:
	return _charge_left > 0.0

## Called when the warned attack actually launches: slam / burst.
func strike() -> void:
	# A whole ring launches in one frame; only the first shot plays the impact.
	var fresh: bool = _slam_left < SLAM_TIME - 0.05
	_charge_left = 0.0
	_slam_left = SLAM_TIME
	if fresh:
		_impact_effects()

func charge_progress() -> float:
	return 1.0 - _charge_left / _charge_total if _charge_left > 0.0 else 0.0

## 0..1 through the slam/burst, or -1 when not striking.
func slam_progress() -> float:
	return 1.0 - _slam_left / SLAM_TIME if _slam_left > 0.0 else -1.0

func _process(delta: float) -> void:
	if not visible:
		return
	advance(delta)

func advance(delta: float) -> void:
	_clock += delta
	_arrival = minf(1.0, _arrival + delta * 3.0)
	_charge_left = maxf(0.0, _charge_left - delta)
	_slam_left = maxf(0.0, _slam_left - delta)
	_update_particles(delta)
	if kind == Kind.EARTHQUAKE:
		var rig: Dictionary = golem_rig()
		_smoke_clock -= delta
		if float(rig["jaw"]) > 0.3 and _smoke_clock <= 0.0:
			_smoke_clock = 0.12
			var mouth: Vector2 = Vector2(rig["head"]) + Vector2(0, 52).rotated(float(rig["head_rot"]))
			var ember: bool = _rng.randf() < 0.3
			_particles.append({"p": mouth, "v": Vector2(_rng.randf_range(-25, 25), _rng.randf_range(-95, -60)), "life": 1.1, "max": 1.1,
				"r": 4.0 if ember else 7.0, "grow": 2.0 if ember else 16.0, "color": LAVA_HOT if ember else Color(0.22, 0.22, 0.22, 0.55), "line": false})
	queue_redraw()

func _update_particles(delta: float) -> void:
	for i: int in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		p["life"] = float(p["life"]) - delta
		if float(p["life"]) <= 0.0:
			_particles.remove_at(i)
			continue
		p["p"] = Vector2(p["p"]) + Vector2(p["v"]) * delta
		p["v"] = Vector2(p["v"]) * exp(-2.2 * delta) + Vector2(0, 40.0 * delta if not bool(p["line"]) else 0.0)

func _impact_effects() -> void:
	if kind == Kind.EARTHQUAKE:
		# Planted fists blast a dust cloud and rock chips along the ground.
		for target: Vector2 in [Vector2(-200, -30), Vector2(-60, -44)]:
			for i: int in range(14):
				_particles.append({"p": target + Vector2(_rng.randf_range(-20, 20), 10), "v": Vector2(_rng.randf_range(-320, 200), _rng.randf_range(-220, -40)),
					"life": _rng.randf_range(0.5, 0.9), "max": 0.9, "r": _rng.randf_range(8, 14), "grow": 18.0, "color": Color(0.36, 0.33, 0.29, 0.75), "line": false})
			for i: int in range(5):
				_particles.append({"p": target, "v": Vector2(_rng.randf_range(-260, 120), _rng.randf_range(-360, -160)),
					"life": 0.7, "max": 0.7, "r": 5.0, "grow": 0.0, "color": BASALT_LIGHT, "line": false})
	else:
		# Roaring burst: wind streaks shoot toward the building.
		var rig: Dictionary = storm_rig()
		for i: int in range(14):
			var ring: Dictionary = rig["rings"][2 + i % 9]
			_particles.append({"p": Vector2(ring["center"]) + Vector2(float(ring["width"]) * 0.6, 0), "v": Vector2(_rng.randf_range(620, 940), _rng.randf_range(-80, 80)),
				"life": 0.35, "max": 0.35, "r": 3.0, "grow": 0.0, "color": Color(0.75, 0.9, 1.0, 0.8), "line": true})

# ----------------------------------------------------------------- rigs ----

## Sismik Golem skeleton in local space (feet on y = 0, building on the -x side).
func golem_rig() -> Dictionary:
	var t: float = _clock
	var wind: float = smoothstep(0.0, 1.0, charge_progress())
	var s: float = slam_progress()
	var plant: float = 0.0
	var lift: float = wind
	if s >= 0.0:
		if s < 0.18:
			plant = pow(s / 0.18, 2.0)
			lift = 1.0 - plant
		elif s < 0.55:
			plant = 1.0
			lift = 0.0
		else:
			plant = 1.0 - smoothstep(0.0, 1.0, (s - 0.55) / 0.45)
			lift = 0.0
	var roar: float = 1.0 - s if s >= 0.0 else 0.0
	var breath: float = sin(t * 1.6)
	var lean_x: float = 14.0 * wind - 40.0 * plant
	var hips: Vector2 = Vector2(lean_x * 0.5, -150.0 + breath * 3.0 + plant * 40.0)
	var torso_rot: float = 0.10 * wind - 0.16 * plant + sin(t * 0.8) * 0.02
	var torso: Vector2 = hips + Vector2(lean_x, -170.0 - breath * 9.0 - wind * 10.0 + plant * 50.0)
	var shoulder_l: Vector2 = torso + Vector2(-92, -60).rotated(torso_rot) + Vector2(0, -sin(t * 1.6 + 0.6) * 5.0 - wind * 14.0)
	var shoulder_r: Vector2 = torso + Vector2(92, -60).rotated(torso_rot) + Vector2(0, -sin(t * 1.6 + 1.2) * 5.0 - wind * 14.0)
	var head: Vector2 = torso + Vector2(0, -128).rotated(torso_rot) + Vector2(sin(t * 0.9 - 0.5) * 4.0, sin(t * 1.6 - 0.5) * 4.0 - wind * 6.0 + plant * 10.0)
	var head_rot: float = sin(t * 0.9) * 0.05 + 0.08 * wind - 0.12 * plant
	var jaw: float = clampf(0.2 + 0.25 * maxf(0.0, sin(t * 0.8)) + 0.5 * wind + roar, 0.0, 1.0)
	# Hands: idle swing -> raised & pulled back (anticipation) -> planted at the building.
	var hand_l: Vector2 = shoulder_l + Vector2(-28 + sin(t * 1.6 + 0.3) * 8.0, 255)
	var hand_r: Vector2 = shoulder_r + Vector2(28 + sin(t * 1.6 + 1.5) * 8.0, 255)
	# Raised arms stay nearly straight (no wide elbow flare); the body lean sells the pull-back.
	hand_l = hand_l.lerp(shoulder_l + Vector2(25, -262), lift).lerp(Vector2(-200, -36), plant)
	hand_r = hand_r.lerp(shoulder_r + Vector2(-25, -262), lift).lerp(Vector2(-60, -44), plant)
	head += Vector2(40, -110) * retreat
	shoulder_l += Vector2(-90, 35) * retreat
	shoulder_r += Vector2(90, 35) * retreat
	hand_l += Vector2(-100, 60) * retreat
	hand_r += Vector2(100, 60) * retreat
	var arm_l: Array[Vector2] = _ik(shoulder_l, hand_l, 140.0, 135.0, -1.0)
	var arm_r: Array[Vector2] = _ik(shoulder_r, hand_r, 140.0, 135.0, 1.0)
	var rocks: Array[Vector3] = []
	var burst: float = roar
	for i: int in range(6):
		var angle: float = t * 0.7 + i * TAU / 6.0 + sin(t * 0.5 + i) * 0.2
		var radius: float = (150.0 + sin(t * 1.3 + i * 1.7) * 14.0) * (1.0 - 0.35 * wind) * (1.0 + 0.15 * burst)
		var p: Vector2 = torso + Vector2(cos(angle) * radius, sin(angle) * radius * 0.42 + sin(t * 2.0 + i) * 8.0)
		rocks.append(Vector3(p.x, p.y, sin(angle)))
	return {"hips": hips, "torso": torso, "torso_rot": torso_rot, "breath": breath,
		"shoulder_l": shoulder_l, "shoulder_r": shoulder_r, "elbow_l": arm_l[0], "elbow_r": arm_r[0],
		"fist_l": arm_l[1], "fist_r": arm_r[1], "head": head, "head_rot": head_rot, "jaw": jaw,
		"eye_glow": 0.35 + 0.15 * sin(t * 3.0) + 0.8 * wind + 0.6 * roar, "rocks": rocks,
		"lift": lift, "plant": plant, "wind": wind}

## Two-bone IK; returns [elbow, hand]. The elbow always bends toward `outward`
## (-1 = the building side, +1 = away), whether the arm hangs or is raised.
static func _ik(shoulder: Vector2, target: Vector2, upper: float, fore: float, outward: float) -> Array[Vector2]:
	var to_target: Vector2 = target - shoulder
	var distance: float = clampf(to_target.length(), absf(upper - fore) + 1.0, upper + fore - 1.0)
	var direction: Vector2 = to_target.normalized() if to_target.length() > 0.01 else Vector2.DOWN
	var angle: float = acos(clampf((upper * upper + distance * distance - fore * fore) / (2.0 * upper * distance), -1.0, 1.0))
	var elbow_a: Vector2 = shoulder + direction.rotated(angle) * upper
	var elbow_b: Vector2 = shoulder + direction.rotated(-angle) * upper
	var elbow: Vector2 = elbow_a if (elbow_a.x - shoulder.x) * outward >= (elbow_b.x - shoulder.x) * outward else elbow_b
	return [elbow, shoulder + direction * distance]

## Yıkıcı Fırtına spine: 12 rings with a travelling S-wave, breathing widths,
## contraction + lightning on wind-up and a forward lunge on the burst.
func storm_rig() -> Dictionary:
	var t: float = _clock
	var wind: float = smoothstep(0.0, 1.0, charge_progress())
	var s: float = slam_progress()
	var burst: float = sin(clampf(s, 0.0, 1.0) * PI) if s >= 0.0 else 0.0
	var rings: Array[Dictionary] = []
	for i: int in range(STORM_RINGS):
		var h: float = float(i) / float(STORM_RINGS - 1)
		var amplitude: float = (6.0 + i * 2.6) * (1.0 - 0.55 * wind)
		var x: float = sin(t * 2.2 - i * 0.55) * amplitude + sin(t * 1.1 + i * 0.3) * 4.0 * (1.0 - wind) + burst * 55.0 * h
		var width: float = (24.0 + i * 8.6) * (1.0 + 0.1 * sin(t * 3.0 + i * 0.7)) * (1.0 - 0.35 * wind) * (1.0 + 0.28 * burst)
		rings.append({"center": Vector2(x, -30.0 - i * 44.0), "width": width})
	var arcs: Array[PackedVector2Array] = []
	if wind > 0.05:
		var frame: int = int(t * 14.0)
		for k: int in range(3):
			var a: int = (frame * 7 + k * 5) % (STORM_RINGS - 3) + 1
			var b: int = mini(STORM_RINGS - 1, a + 2)
			var side: float = 1.0 if (frame + k) % 2 == 0 else -1.0
			var from: Vector2 = Vector2(rings[a]["center"]) + Vector2(side * float(rings[a]["width"]) * 0.8, -10)
			var to: Vector2 = Vector2(rings[b]["center"]) + Vector2(-side * float(rings[b]["width"]) * 0.6, -14)
			var bolt: PackedVector2Array = PackedVector2Array([from])
			for step: int in range(1, 5):
				var p: Vector2 = from.lerp(to, step / 5.0)
				bolt.append(p + Vector2(sin(frame * 3.1 + step * 2.3 + k) * 16.0, cos(frame * 2.7 + step) * 8.0))
			bolt.append(to)
			arcs.append(bolt)
	return {"rings": rings, "face": Vector2(rings[7]["center"]) + Vector2(0, 20), "wind": wind, "burst": burst, "arcs": arcs}

## Local bounding box of the current pose (both bosses), for framing checks.
func pose_bounds() -> Rect2:
	var box: Rect2 = Rect2(Vector2(-60, -40), Vector2(120, 70))
	if kind == Kind.EARTHQUAKE:
		# Margins match the painted extents: torso polygon, pauldrons, limb half-widths, fists.
		var rig: Dictionary = golem_rig()
		var torso: Vector2 = rig["torso"]
		box = box.expand(torso + Vector2(-106, -122)).expand(torso + Vector2(110, 122))
		box = box.expand(Vector2(rig["hips"]) + Vector2(-100, -40)).expand(Vector2(rig["hips"]) + Vector2(100, 40))
		for key: String in ["shoulder_l", "shoulder_r"]:
			box = box.expand(Vector2(rig[key]) + Vector2(-56, -48)).expand(Vector2(rig[key]) + Vector2(56, 48))
		for key: String in ["elbow_l", "elbow_r"]:
			box = box.expand(Vector2(rig[key]) + Vector2(-36, -36)).expand(Vector2(rig[key]) + Vector2(36, 36))
		for key: String in ["fist_l", "fist_r"]:
			box = box.expand(Vector2(rig[key]) + Vector2(-48, -48)).expand(Vector2(rig[key]) + Vector2(48, 48))
		box = box.expand(Vector2(rig["head"]) + Vector2(-80, -100)).expand(Vector2(rig["head"]) + Vector2(80, 110))
		for rock: Vector3 in rig["rocks"]:
			box = box.expand(Vector2(rock.x - 28, rock.y - 28)).expand(Vector2(rock.x + 28, rock.y + 28))
	else:
		for ring: Dictionary in storm_rig()["rings"]:
			var c: Vector2 = ring["center"]
			var w: float = ring["width"]
			box = box.expand(c + Vector2(-w - 12, -60)).expand(c + Vector2(w + 12, 30))
	box.position.y += (1.0 - _arrival) * 80.0
	return box

# -------------------------------------------------------------- drawing ----

func _root() -> Vector2:
	return Vector2(0, (1.0 - _arrival) * 80.0)

func _draw() -> void:
	var root: Vector2 = _root()
	var texture: Texture2D = boss_sprite if boss_sprite != null else custom_sprite
	if texture != null:
		_draw_sprite(texture, root)
	elif kind == Kind.STORM:
		_draw_storm(storm_rig(), root)
	else:
		_draw_golem(golem_rig(), root)
	draw_set_transform(root)
	for p: Dictionary in _particles:
		var life: float = float(p["life"]) / float(p["max"])
		var color: Color = p["color"]
		color.a *= clampf(life * 1.5, 0.0, 1.0)
		if bool(p["line"]):
			draw_line(Vector2(p["p"]), Vector2(p["p"]) - Vector2(p["v"]) * 0.06, color, 3.0, true)
		else:
			draw_circle(Vector2(p["p"]), float(p["r"]) + float(p["grow"]) * (1.0 - life), color)
	draw_set_transform(Vector2.ZERO)

## Hand-made sprites still breathe, wind up and strike.
func _draw_sprite(texture: Texture2D, root: Vector2) -> void:
	var wind: float = smoothstep(0.0, 1.0, charge_progress())
	var s: float = slam_progress()
	var hit: float = sin(clampf(s, 0.0, 1.0) * PI) if s >= 0.0 else 0.0
	var breath: float = sin(_clock * 1.6)
	var scale_v: Vector2 = Vector2(1.0 + breath * 0.015, 1.0 - breath * 0.015)
	var offset: Vector2 = Vector2.ZERO
	var rotation_v: float = 0.0
	if kind == Kind.STORM:
		scale_v *= Vector2(1.0 - 0.25 * wind + 0.25 * hit, 1.0 + 0.08 * wind - 0.06 * hit)
		offset.x = hit * 40.0 + sin(_clock * 2.2) * 6.0
	else:
		scale_v *= Vector2(1.0, 1.0 - 0.1 * hit)
		offset.x = -30.0 * hit + 12.0 * wind
		rotation_v = -0.08 * hit + 0.06 * wind
	draw_set_transform(root + offset, rotation_v, scale_v)
	draw_texture_rect(texture, Rect2(-146, -550, 292, 550), false)
	draw_set_transform(Vector2.ZERO)

func _draw_golem(rig: Dictionary, root: Vector2) -> void:
	draw_set_transform(root)
	CelArt.ellipse(self, Vector2(0, 4), Vector2(150, 28), Color(0, 0, 0, 0.5), 0)
	var glow: float = rig["eye_glow"]
	var plant: float = rig["plant"]
	for rock: Vector3 in rig["rocks"]:
		if rock.z < 0.0:
			_floating_rock(rock, glow * 0.5)
	# Legs: hip -> knee -> foot, rock plates on the joints.
	for side: float in [-1.0, 1.0]:
		var hip: Vector2 = Vector2(rig["hips"]) + Vector2(side * 52, 0)
		var foot: Vector2 = Vector2(side * 60, -4)
		var knee: Vector2 = hip.lerp(foot, 0.5) + Vector2(side * (14.0 + plant * 16.0), 0)
		CelArt.line(self, hip, knee, INK, 64)
		CelArt.line(self, hip, knee, BASALT_DARK, 52)
		CelArt.line(self, knee, foot, INK, 56)
		CelArt.line(self, knee, foot, BASALT, 44)
		_rock(knee, Vector2(30, 30), PLATE)
		_rock(foot + Vector2(side * 6, -14), Vector2(58, 26), BASALT_LIGHT)
	# Torso breathes as its own segment, with glowing lava seams.
	var breath: float = rig["breath"]
	draw_set_transform(root + Vector2(rig["torso"]), float(rig["torso_rot"]), Vector2(1.0 + breath * 0.025, 1.0 - breath * 0.02))
	CelArt.poly(self, PackedVector2Array([Vector2(-93, -86), Vector2(-44, -116), Vector2(55, -109), Vector2(104, -67), Vector2(84, 61), Vector2(42, 116), Vector2(-60, 105), Vector2(-98, 39)]), BASALT)
	CelArt.poly(self, PackedVector2Array([Vector2(-93, -86), Vector2(-44, -116), Vector2(55, -109), Vector2(69, -60), Vector2(-42, -36)]), BASALT_LIGHT)
	CelArt.poly(self, PackedVector2Array([Vector2(69, -60), Vector2(104, -67), Vector2(84, 61), Vector2(42, 116), Vector2(30, 7)]), BASALT_DARK)
	for point: Vector2 in [Vector2(-52, -2), Vector2(11, 57), Vector2(48, -27)]:
		_rock(point, Vector2(30, 35), PLATE)
	var seam: PackedVector2Array = PackedVector2Array([Vector2(-14, -98), Vector2(-30, -57), Vector2(-7, -29), Vector2(-17, 10), Vector2(5, 32), Vector2(-4, 70)])
	draw_polyline(seam, Color(LAVA, 0.25 * glow), 14.0, true)
	draw_polyline(seam, INK, 7.0, true)
	draw_polyline(seam, LAVA.lerp(LAVA_HOT, clampf(glow - 0.5, 0.0, 1.0)), 3.0, true)
	draw_set_transform(root)
	var flash: bool = plant > 0.95 and slam_progress() < 0.3
	_arm(Vector2(rig["shoulder_r"]), Vector2(rig["elbow_r"]), Vector2(rig["fist_r"]), -1.0, flash, root)
	_arm(Vector2(rig["shoulder_l"]), Vector2(rig["elbow_l"]), Vector2(rig["fist_l"]), 1.0, flash, root)
	# Head and a separately hinged jaw with a lava-lit throat.
	var jaw: float = rig["jaw"]
	var wind: float = rig["wind"]
	draw_set_transform(root + Vector2(rig["head"]), float(rig["head_rot"]))
	CelArt.poly(self, PackedVector2Array([Vector2(-40, 30), Vector2(40, 30), Vector2(36, 44 + jaw * 26), Vector2(-34, 46 + jaw * 26)]), Color("1a1210"))
	for i: int in range(3):
		CelArt.ellipse(self, Vector2(0, 40 + jaw * 12), Vector2(30 - i * 8, 6 + jaw * 8 - i * 2), Color(LAVA, (0.25 + i * 0.2) * jaw), 0)
	var jaw_drop: Vector2 = Vector2(0, jaw * 26)
	CelArt.poly(self, PackedVector2Array([Vector2(-44, 34) + jaw_drop, Vector2(44, 34) + jaw_drop, Vector2(36, 72) + jaw_drop, Vector2(-30, 74) + jaw_drop]), BASALT_DARK)
	for i: int in range(4):
		CelArt.poly(self, PackedVector2Array([Vector2(-27 + i * 16, 36) + jaw_drop, Vector2(-17 + i * 16, 36) + jaw_drop, Vector2(-22 + i * 16, 26) + jaw_drop]), Color("bdb59a"), 1)
	CelArt.poly(self, PackedVector2Array([Vector2(-74, -30), Vector2(-56, -70), Vector2(-10, -80), Vector2(40, -74), Vector2(76, -36), Vector2(70, 20), Vector2(46, 38), Vector2(-46, 38), Vector2(-72, 16)]), Color("6a6d60"))
	CelArt.poly(self, PackedVector2Array([Vector2(-74, -30), Vector2(-56, -70), Vector2(-10, -80), Vector2(40, -74), Vector2(10, -40), Vector2(-40, -30)]), Color("85887a"), 1.5)
	CelArt.poly(self, PackedVector2Array([Vector2(-72, -43), Vector2(-54, -86), Vector2(-28, -66), Vector2(-9, -93), Vector2(20, -70), Vector2(57, -80), Vector2(74, -35)]), Color("515a51"))
	for i: int in range(5):
		CelArt.poly(self, PackedVector2Array([Vector2(-30 + i * 14, 36), Vector2(-20 + i * 14, 36), Vector2(-25 + i * 14, 48)]), Color("cfc6a6"), 1)
	for side: float in [-1.0, 1.0]:
		var eye: Vector2 = Vector2(side * 33, 4)
		draw_circle(eye, 22.0 * (0.6 + glow * 0.5), Color(LAVA, 0.22 * glow))
		CelArt.poly(self, PackedVector2Array([eye + Vector2(-side * 23, -12), eye + Vector2(side * 23, 0 + wind * 4.0), eye + Vector2(side * 15, 12), eye + Vector2(-side * 17, 8)]), INK)
		CelArt.ellipse(self, eye, Vector2(14, 6), LAVA_HOT.lerp(Color(1, 1, 0.92), clampf(glow - 0.8, 0.0, 1.0)), 0)
		CelArt.line(self, eye + Vector2(-side * 28, -26), eye + Vector2(side * 22, -10 + wind * 6.0), INK, 9)
	draw_set_transform(root)
	for rock: Vector3 in rig["rocks"]:
		if rock.z >= 0.0:
			_floating_rock(rock, glow * 0.5)
	var s: float = slam_progress()
	if s >= 0.18:
		var ring: float = (s - 0.18) / 0.82
		for target: Vector2 in [Vector2(-200, -20), Vector2(-60, -30)]:
			draw_set_transform(root + target, 0, Vector2(1, 0.24))
			draw_arc(Vector2.ZERO, 50 + ring * 120, 0, TAU, 40, Color(LAVA_HOT, 1.0 - ring), 9, true)
			draw_set_transform(root)
		if s < 0.3:
			# Impact frame: a hot flash where the fists meet the building.
			draw_circle(Vector2(-140, -40), 90.0, Color(1.0, 0.85, 0.6, 0.35 * (1.0 - (s - 0.18) / 0.12)))

func _arm(shoulder: Vector2, elbow: Vector2, fist: Vector2, side: float, flash: bool, root: Vector2) -> void:
	CelArt.line(self, shoulder, elbow, INK, 66)
	CelArt.line(self, shoulder, elbow, Color("555a52"), 54)
	CelArt.line(self, elbow, fist, INK, 56)
	CelArt.line(self, elbow, fist, Color("62665b"), 44)
	CelArt.line(self, elbow, elbow + (elbow - shoulder).normalized().rotated(side * 0.6) * 22.0, Color("a0603a"), 4)
	_rock(shoulder + Vector2(side * -6, -6), Vector2(50, 42), PLATE)
	draw_set_transform(root + fist, (fist - elbow).angle() - PI * 0.5)
	_rock(Vector2.ZERO, Vector2(44, 46), Color("fff0d0") if flash else BASALT_LIGHT)
	CelArt.line(self, Vector2(-24, 10), Vector2(22, 6), INK, 3)
	CelArt.line(self, Vector2(-20, 24), Vector2(20, 20), INK, 3)
	draw_polyline(PackedVector2Array([Vector2(-10, -30), Vector2(-4, -6), Vector2(-12, 14)]), Color(LAVA, 0.8), 3.0, true)
	draw_set_transform(root)

func _floating_rock(rock: Vector3, glow: float) -> void:
	var center: Vector2 = Vector2(rock.x, rock.y)
	var size: float = 16.0 + fmod(absf(rock.x) * 0.07, 10.0)
	draw_circle(center, size * 1.4, Color(LAVA, 0.12 * glow))
	_rock(center, Vector2(size, size * 0.9), BASALT if rock.z >= 0.0 else BASALT_DARK)

func _draw_storm(rig: Dictionary, root: Vector2) -> void:
	draw_set_transform(root)
	if position.is_equal_approx(_home):
		CelArt.ellipse(self, Vector2(0, 1), Vector2(117, 22), Color(0, 0, 0, 0.45), 0)
	var wind: float = rig["wind"]
	var burst: float = rig["burst"]
	var face: Vector2 = rig["face"]
	# Charge: lightning collects in the core before the volley.
	if wind > 0.02:
		for i: int in range(3):
			draw_circle(face, 70.0 + i * 45.0, Color(0.35, 0.65, 1.0, 0.07 * wind))
	var rings: Array = rig["rings"]
	for i: int in range(rings.size()):
		var c: Vector2 = rings[i]["center"]
		var width: float = rings[i]["width"]
		var y: float = c.y
		var color: Color = STORM_DARK if i % 2 == 0 else STORM_MID
		CelArt.poly(self, PackedVector2Array([Vector2(c.x - width, y - 19), Vector2(c.x - width * 0.72, y - 40), Vector2(c.x + width * 0.63, y - 44), Vector2(c.x + width, y - 20), Vector2(c.x + width * 0.89, y + 10), Vector2(c.x - width * 0.5, y + 25)]), color)
		CelArt.ellipse(self, Vector2(c.x, y - 22), Vector2(width * 0.92, 17), color.lightened(0.14))
		CelArt.line(self, Vector2(c.x - width * 0.7, y + 2), Vector2(c.x + width * 0.66, y - 5), Color("6f8995"), 3)
		var ribbon: float = sin(_clock * (6.0 + wind * 10.0) + i) * width * 0.7
		CelArt.line(self, Vector2(c.x + ribbon - 13, y - 24), Vector2(c.x + ribbon + 15, y - 27), Color("9fb4bd"), 3)
		if wind > 0.05:
			draw_arc(Vector2(c.x, y - 22), width * 0.92, PI, TAU, 16, Color(ELECTRIC, 0.55 * wind), 2.0, true)
	# Face rides ring 7 of the spine; the mouth tears open on the burst.
	var brow_drop: float = wind * 6.0
	for side: float in [-1.0, 1.0]:
		CelArt.poly(self, PackedVector2Array([face + Vector2(side * -73, -28), face + Vector2(side * -15, -12), face + Vector2(side * -23, 12), face + Vector2(side * -63, 1)]), INK)
		var eye: Vector2 = face + Vector2(side * -42, -6)
		draw_circle(eye, 26.0, Color(Color("ffd36b").lerp(ELECTRIC, wind), 0.18 + 0.2 * wind))
		CelArt.poly(self, PackedVector2Array([face + Vector2(side * -63, -18), face + Vector2(side * -25, -8), face + Vector2(side * -28, 1), face + Vector2(side * -57, -6)]), Color("ffd36b").lerp(Color(0.92, 0.97, 1.0), wind), 0)
		CelArt.line(self, face + Vector2(side * -81, -38 + brow_drop * 0.3), face + Vector2(side * -14, -18 + brow_drop), INK, 8)
	var open: float = 1.0 + burst * 1.6 + wind * 0.3
	CelArt.poly(self, PackedVector2Array([face + Vector2(-35, 37), face + Vector2(36, 31), face + Vector2(22, 31 + 27 * open), face + Vector2(-12, 31 + 30 * open)]), Color("16222a"))
	if burst > 0.05:
		CelArt.ellipse(self, face + Vector2(4, 31 + 15 * open), Vector2(16, 6 * open), Color(ELECTRIC, 0.7 * burst), 0)
	for i: int in range(14):
		var angle: float = _clock * (1.9 + i % 3 * 0.2) + float(i) * 2.4
		var ring_index: int = mini(STORM_RINGS - 1, i * STORM_RINGS / 14)
		var c: Vector2 = rings[ring_index]["center"]
		var x: float = c.x + cos(angle) * (float(rings[ring_index]["width"]) + 12.0)
		var leaf: Color = Color("7d6d48") if i % 2 == 0 else Color("566b5e")
		draw_set_transform(root + Vector2(x, c.y + sin(angle) * 15.0), angle)
		CelArt.poly(self, PackedVector2Array([Vector2(-8, 0), Vector2(0, -5), Vector2(10, 1), Vector2(1, 5)]), leaf, 2)
	draw_set_transform(root)
	for bolt: PackedVector2Array in rig["arcs"]:
		draw_polyline(bolt, Color(0.35, 0.65, 1.0, 0.35 * wind), 10.0, true)
		draw_polyline(bolt, Color(0.88, 0.97, 1.0, 0.95), 2.6, true)

func _rock(center: Vector2, size: Vector2, color: Color) -> void:
	CelArt.poly(self, PackedVector2Array([center + Vector2(-size.x, -size.y * 0.6), center + Vector2(-size.x * 0.5, -size.y), center + Vector2(size.x * 0.65, -size.y * 0.9), center + Vector2(size.x, -size.y * 0.1), center + Vector2(size.x * 0.73, size.y * 0.85), center + Vector2(-size.x * 0.65, size.y)]), color)
	CelArt.poly(self, PackedVector2Array([center + Vector2(-size.x, -size.y * 0.6), center + Vector2(-size.x * 0.5, -size.y), center + Vector2(size.x * 0.65, -size.y * 0.9), center + Vector2(size.x * 0.3, -size.y * 0.35)]), color.lightened(0.18), 1.5)
