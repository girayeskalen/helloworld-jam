class_name DisasterWaveManager
extends Node

signal phase_changed
signal attack_launched(attack: HazardAttack)

enum State { PREPARATION_PHASE, SIEGE_PHASE, BUILD_PREPARATION_PHASE, VICTORY, WAVE_INTRO, WAVE_OUTRO }
enum Mode { STORM, EARTHQUAKE, CHAOS }
enum FailReason { NONE, PLAYER, BUILDING }
const BUILDING_FAIL_TEXT: String = "BİNA ÇÖKTÜ! ODALARI ZAMANINDA ONARAMADIN"
## Room HP removed when a hazard ends (impacts) inside a room. Heavy debris hurts most;
## a full-floor sweep hits all four rooms of its floor.
const ROOM_DAMAGE: Dictionary = {
	HazardAttack.Kind.GLASS: 0.8, HazardAttack.Kind.WIND_ORB: 0.8, HazardAttack.Kind.SHARD: 0.6,
	HazardAttack.Kind.BOOK: 0.8, HazardAttack.Kind.KNIFE: 0.8, HazardAttack.Kind.PLATE: 0.8,
	HazardAttack.Kind.TOOL: 1.0, HazardAttack.Kind.TOY: 0.6, HazardAttack.Kind.SAW: 1.2,
	HazardAttack.Kind.POT: 2.0, HazardAttack.Kind.CHAIR: 2.5, HazardAttack.Kind.DEBRIS: 1.5,
	HazardAttack.Kind.BRICK: 2.5, HazardAttack.Kind.SHOCKWAVE: 2.0, HazardAttack.Kind.WIND_BLADE: 3.5,
	HazardAttack.Kind.CONCRETE: 6.0, HazardAttack.Kind.CHANDELIER: 6.0, HazardAttack.Kind.WARDROBE: 6.0,
	HazardAttack.Kind.ROW_SWEEP: 4.0,
}
@export var preparation_duration: float = 8.0
@export var build_duration: float = 15.0
@export var secondary_damage_rate: float = 0.15
@export var siege_duration: float = 90.0
@export var autoplay: bool = true
@export var storm_interval: float = 1.95
@export var quake_interval: float = 2.8
@export var gust_strength: float = 150.0
@export var gust_duration: float = 2.2
## HP per second that damaged/critical rooms keep losing during a siege.
@export var room_erosion: float = 0.25
## Every room on the slammed floor loses this much when the golem hits.
@export var slam_tremor: float = 1.0

const INTRO_DURATION: float = 1.5
const OUTRO_DURATION: float = 2.5
var transition_remaining: float = 0.0
var debug_enabled: bool = false
var state: State = State.PREPARATION_PHASE
var fail_reason: FailReason = FailReason.NONE
var mode: Mode = Mode.STORM
var wave_number: int = 0
var preparation_remaining: float = 8.0
var siege_remaining: float = 90.0
var boss_endurance: float = 100.0
var failed: bool = false
var victory: bool = false
var upgrades: SiegeUpgrades
var loot: LootSystem
var upgrade_pending: bool:
	get: return upgrades != null and upgrades.pending
const VICTORY_TEXT: String = "AFET KUŞATMASI BAŞARIYLA ATLATILDI - BİNANIZ HAYATTA KALDI!"
var dodge_count: int = 0
var completed_waves: int = 0
var building: ApartmentBuilding
var player: SiegePlayer
var camera: GameCamera
var telegraphs: TelegraphSystem
var pool: ProjectilePool
var storm: DisasterBoss
var earthquake: DisasterBoss
var _next_mode: Mode = Mode.STORM
var _storm_clock: float = 0.0
var _quake_clock: float = 0.0
var _storm_pattern: int = 0
var _quake_pattern: int = 0

func _ready() -> void:
	process_physics_priority = 5

func configure(home: ApartmentBuilding, actor: SiegePlayer, view: GameCamera, warnings: TelegraphSystem, projectiles: ProjectilePool, storm_boss: DisasterBoss, quake_boss: DisasterBoss) -> void:
	building = home
	player = actor
	camera = view
	telegraphs = warnings
	pool = projectiles
	storm = storm_boss
	earthquake = quake_boss
	pool.player = player
	telegraphs.attack_ready.connect(Callable(self, "_on_attack_ready"))
	telegraphs.gust_ready.connect(Callable(self, "_on_gust_ready"))
	# Room damage comes from every impact (see _on_projectile_impacted); the old
	# building-wide structure_hit signal is no longer consumed.
	pool.projectile_impacted.connect(Callable(self, "_on_projectile_impacted"))
	pool.dodged.connect(Callable(self, "_on_dodged"))
	reset_cycle()

func reset_cycle() -> void:
	_clear_attacks()
	if upgrades != null: upgrades.reset()
	if loot != null: loot.reset()
	victory = false
	debug_enabled = false
	transition_remaining = 0.0
	player.controls_locked = false
	state = State.PREPARATION_PHASE
	_next_mode = Mode.STORM
	mode = Mode.STORM
	wave_number = 0
	completed_waves = 0
	dodge_count = 0
	failed = false
	fail_reason = FailReason.NONE
	preparation_remaining = preparation_duration
	siege_remaining = siege_duration
	boss_endurance = 100.0
	building.restore_integrity()
	phase_changed.emit()

func start_next_wave() -> void:
	if failed or victory or upgrade_pending or state not in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE]:
		return
	start_siege(clampi(completed_waves, 0, 2) as Mode)

func start_siege(requested_mode: Mode, test_shortcut: bool = false) -> void:
	if not test_shortcut and (upgrade_pending or failed or victory or state not in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE]):
		return
	if not test_shortcut:
		requested_mode = clampi(completed_waves, 0, 2) as Mode
	_clear_attacks()
	if test_shortcut:
		if upgrades != null: upgrades.reset()
		if loot != null: loot.reset()
		for room: RoomDiorama in building.rooms:
			room.max_hp = RoomDiorama.MAX_HP
		player.reset_player()
		building.restore_integrity()
		failed = false
		fail_reason = FailReason.NONE
	victory = false
	player.controls_locked = false
	wave_number = int(requested_mode) + 1
	if test_shortcut: completed_waves = wave_number - 1
	mode = requested_mode
	state = State.WAVE_INTRO
	transition_remaining = INTRO_DURATION
	siege_remaining = siege_duration
	boss_endurance = 100.0
	_storm_clock = 0.3
	_quake_clock = 0.5
	_storm_pattern = 0
	_quake_pattern = 0
	storm.set_active(mode != Mode.EARTHQUAKE)
	earthquake.set_active(mode != Mode.STORM)
	for boss: DisasterBoss in [storm, earthquake]:
		if boss.visible: boss.transition_pose(0.0, false)
	building.begin_siege_pacing()
	phase_changed.emit()

func finish_wave() -> void:
	if state != State.SIEGE_PHASE or failed or victory:
		return
	if player.health <= 0.0:
		fail_siege(FailReason.PLAYER)
		return
	if building.is_failing():
		collapse_building()
		return
	state = State.WAVE_OUTRO
	transition_remaining = OUTRO_DURATION
	building.pacing_enabled = false
	telegraphs.clear()
	pool.dissolve_all()
	player.clear_wind()
	if upgrades != null: upgrades.game.mechanics.cancel_time_slow()
	for prop: BuildingProp in building.props: prop.stop_shaking()
	for boss: DisasterBoss in [storm, earthquake]:
		if boss.visible: boss.transition_pose(0.0, true)
	phase_changed.emit()

func _complete_outro() -> void:
	_clear_attacks()
	completed_waves = wave_number
	if completed_waves == 3:
		if loot != null: loot.clear_drops()
		victory = true
		state = State.VICTORY
		player.controls_locked = true
	else:
		_next_mode = completed_waves as Mode
		state = State.BUILD_PREPARATION_PHASE
		preparation_remaining = build_duration
		if upgrades != null: upgrades.open_selection()
	phase_changed.emit()

## U is a deliberate practice shortcut, never an extra completed wave.
func test_upgrades() -> void:
	if not debug_enabled or failed or victory or upgrade_pending:
		return
	_clear_attacks()
	if loot != null: loot.clear_drops()
	_next_mode = clampi(completed_waves, 0, 2) as Mode
	state = State.BUILD_PREPARATION_PHASE
	preparation_remaining = build_duration
	if upgrades != null: upgrades.open_selection()
	phase_changed.emit()

func damage_boss_endurance(amount: float) -> void:
	if not debug_enabled or state != State.SIEGE_PHASE or failed or amount <= 0:
		return
	boss_endurance = maxf(0.0, boss_endurance - amount)
	if boss_endurance <= 0.0:
		finish_wave()

func _physics_process(delta: float) -> void:
	if autoplay:
		advance_wave(1.0 / float(Engine.physics_ticks_per_second), delta)

func advance_wave(delta: float, simulation_delta: float = -1.0) -> void:
	if building == null or failed or victory or upgrade_pending:
		return
	if player.health <= 0:
		fail_siege(FailReason.PLAYER)
		return
	if building.is_failing():
		collapse_building()
		return
	if state in [State.WAVE_INTRO, State.WAVE_OUTRO]:
		transition_remaining = maxf(0.0, transition_remaining - delta)
		var outro: bool = state == State.WAVE_OUTRO
		var progress: float = 1.0 - transition_remaining / (OUTRO_DURATION if outro else INTRO_DURATION)
		for boss: DisasterBoss in [storm, earthquake]:
			if boss.visible: boss.transition_pose(progress, outro)
		if outro and upgrades != null: upgrades.game.mechanics.retreat_dust(delta)
		if transition_remaining <= 0.000001:
			if outro: _complete_outro()
			else:
				state = State.SIEGE_PHASE
				building.pacing_enabled = true
				if loot != null: loot.begin_wave()
				phase_changed.emit()
		return
	if state in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE]:
		preparation_remaining = maxf(0.0, preparation_remaining - delta)
		if preparation_remaining <= 0.000001:
			start_next_wave()
		return
	siege_remaining = maxf(0.0, siege_remaining - delta)
	boss_endurance = minf(boss_endurance, 100.0 * siege_remaining / siege_duration)
	if siege_remaining <= 0.000001 or boss_endurance <= 0:
		finish_wave()
		return
	building.advance_wear(delta)
	building.erode(delta, room_erosion)
	building.secondary_damage(delta, secondary_damage_rate)
	if building.is_failing():
		collapse_building()
		return
	var combat_delta: float = delta if simulation_delta < 0.0 else simulation_delta
	if mode == Mode.CHAOS:
		# Shared beat, complementary target floors: both bosses attack together,
		# but never reserve all four floors with simultaneous full-row sweeps.
		_storm_clock -= combat_delta
		if _storm_clock <= 0.0:
			chaos_burst()
			_storm_clock += quake_interval
		return
	if mode != Mode.EARTHQUAKE:
		_storm_clock -= combat_delta
		if _storm_clock <= 0:
			storm_burst()
			_storm_clock += storm_interval
	if mode != Mode.STORM:
		_quake_clock -= combat_delta
		if _quake_clock <= 0:
			quake_burst()
			_quake_clock += quake_interval

func fail_siege(reason: FailReason = FailReason.PLAYER) -> void:
	if victory or failed:
		return
	failed = true
	player.controls_locked = true
	if loot != null: loot.clear_drops()
	fail_reason = reason
	_clear_attacks()
	phase_changed.emit()

## 4+ collapsed rooms (or 0% integrity): the apartment comes down and the siege is lost.
func collapse_building() -> void:
	if failed:
		return
	building.start_collapse()
	if camera != null:
		camera.apply_shake(26.0, 1.4)
	fail_siege(FailReason.BUILDING)

func phase_label() -> String:
	if failed:
		if fail_reason == FailReason.BUILDING:
			return BUILDING_FAIL_TEXT
		return "KUŞATMA KAYBEDİLDİ · R İLE YENİDEN DENE"
	if state == State.WAVE_OUTRO and not failed: return "AFET DALGASI PÜSKÜRTÜLDÜ! BİNANI HAZIRLA..."
	if state == State.WAVE_INTRO and not failed: return "AFET YAKLAŞIYOR · HAZIR OL"
	if victory: return "ÜÇ AFET DALGASI ATLATILDI"
	if upgrade_pending: return "AFET HAZIRLIK BÜLTENİ · 1 ÖNLEM SEÇ"
	if state == State.BUILD_PREPARATION_PHASE: return "AFETE HAZIRLIK & GÜÇLENDİRME · F: HAZIRIM"
	return "HAZIRLIK EVRESİ" if state == State.PREPARATION_PHASE else "AFET KUŞATMASI"

func boss_name() -> String:
	var active_mode: Mode = _next_mode if state in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE] else mode
	match active_mode:
		Mode.STORM: return "YIKICI FIRTINA · KATEGORİ 5"
		Mode.EARTHQUAKE: return "SİSMİK GOLEM · 7.4"
	return "ÇİFTE FELAKET · FIRTINA & ARTÇI DEPREM"

func chaos_burst() -> void:
	var target: int = player.current_floor
	storm.plan_pattern(self, _storm_pattern, target)
	earthquake.plan_pattern(self, _quake_pattern, (target + 2) % building.floor_count)
	_storm_pattern += 1
	_quake_pattern += 1

func storm_burst() -> void:
	var target: int = (player.current_floor + _storm_pattern / 6) % building.floor_count
	storm.plan_pattern(self, _storm_pattern, target)
	_storm_pattern += 1

## The roar announces a whole-building gust that drifts the player away from the storm.
func storm_gust() -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	var floors: PackedFloat32Array = PackedFloat32Array()
	for index: int in range(building.floor_count):
		floors.append(building.floor_y(index))
	var area: Rect2 = Rect2(building.global_position, Vector2(building.building_width, building.floor_count * building.floor_height))
	telegraphs.warn_gust(area, floors, 1.0, gust_strength, gust_duration, .65)

func quake_burst() -> void:
	var target: int = (player.current_floor + _quake_pattern / 3) % building.floor_count
	earthquake.plan_pattern(self, _quake_pattern, target)
	_quake_pattern += 1

func _on_projectile_impacted(attack: HazardAttack, point: Vector2) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	var amount: float = room_damage(attack) * (upgrades.damage_multiplier(attack) if upgrades != null else 1.0)
	if attack.kind == HazardAttack.Kind.ROW_SWEEP:
		for column: int in range(ApartmentBuilding.COLUMN_COUNT):
			building.damage_room(attack.floor_index, column, amount)
	else:
		building.damage_room_at(attack.floor_index, point.x, amount)
	if building.is_failing():
		collapse_building()
		return
	if attack.splits:
		BossPatterns.splinters(self, attack, point)

static func room_damage(attack: HazardAttack) -> float:
	return float(ROOM_DAMAGE.get(attack.kind, 0.8))

func plan_attack(attack: HazardAttack, warning_seconds: float = 0.65) -> void:
	if state == State.SIEGE_PHASE and not failed:
		telegraphs.warn(upgrades.prepare_attack(attack) if upgrades != null else attack, warning_seconds)

func _attack(kind: HazardAttack.Kind, floor_index: int, origin: Vector2, velocity: Vector2) -> HazardAttack:
	var attack: HazardAttack = HazardAttack.new()
	attack.kind = kind
	attack.floor_index = floor_index
	attack.floor_y = building.floor_y(floor_index)
	attack.origin = origin
	attack.velocity = velocity
	match kind:
		HazardAttack.Kind.GLASS: attack.radius = 8; attack.damage = 10
		HazardAttack.Kind.POT: attack.radius = 18; attack.damage = 14
		HazardAttack.Kind.CHAIR: attack.radius = 22; attack.damage = 16
		HazardAttack.Kind.WIND_BLADE: attack.radius = 28; attack.damage = 18; attack.structure_damage = 1.5
		HazardAttack.Kind.BRICK: attack.radius = 13; attack.damage = 12
		HazardAttack.Kind.CONCRETE: attack.radius = 27; attack.damage = 22; attack.structure_damage = 1.8
		HazardAttack.Kind.CHANDELIER: attack.radius = 25; attack.damage = 18; attack.structure_damage = 0.9
		HazardAttack.Kind.SHOCKWAVE: attack.radius = 12; attack.damage = 16
		HazardAttack.Kind.BOOK: attack.radius = 14; attack.damage = 8
		HazardAttack.Kind.WIND_ORB: attack.radius = 12; attack.damage = 10
		HazardAttack.Kind.SHARD: attack.radius = 8; attack.damage = 8
		HazardAttack.Kind.ROW_SWEEP: attack.radius = 12; attack.damage = 22; attack.structure_damage = 2
		HazardAttack.Kind.WARDROBE: attack.radius = 26; attack.damage = 20; attack.structure_damage = 0.5
		HazardAttack.Kind.KNIFE: attack.radius = 10; attack.damage = 12
		HazardAttack.Kind.PLATE: attack.radius = 13; attack.damage = 9
		HazardAttack.Kind.SAW: attack.radius = 15; attack.damage = 13
		HazardAttack.Kind.TOOL: attack.radius = 12; attack.damage = 10
		HazardAttack.Kind.TOY: attack.radius = 11; attack.damage = 7
		HazardAttack.Kind.DEBRIS: attack.radius = 16; attack.damage = 12
	return attack

## Spiral rings live until they first leave the building interior or `maximum`.
func _spiral_time(attack: HazardAttack, maximum: float) -> float:
	var left: float = building.global_position.x + 18
	var right: float = building.global_position.x + building.building_width - 18
	var t: float = 0.0
	while t < maximum:
		var x: float = attack.point_at(t).x
		if x < left or x > right:
			return maxf(0.1, t)
		t += 1.0 / 60.0
	return maximum

func _flight_time(attack: HazardAttack) -> float:
	var life: float = 3.0
	if not is_zero_approx(attack.velocity.x):
		var edge: float = building.global_position.x + building.building_width - 18 if attack.velocity.x > 0 else building.global_position.x + 18
		life = (edge - attack.origin.x) / attack.velocity.x
	var fall_distance: float = attack.floor_y - attack.radius - attack.origin.y
	if attack.motion == HazardAttack.Motion.ARC and attack.gravity > 0:
		var impact_time: float = (-attack.velocity.y + sqrt(attack.velocity.y * attack.velocity.y + 2 * attack.gravity * maxf(0, fall_distance))) / attack.gravity
		life = minf(life, impact_time)
	elif attack.velocity.y > 0:
		life = minf(life, fall_distance / attack.velocity.y)
	elif attack.velocity.y < 0 and attack.motion == HazardAttack.Motion.LINEAR:
		life = minf(life, (attack.floor_y - 183 + attack.radius - attack.origin.y) / attack.velocity.y)
	return maxf(0.1, life)

func _on_attack_ready(attack: HazardAttack) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	if pool.spawn(attack) == null:
		return
	if attack.starts_slam:
		earthquake.strike()
		camera.apply_shake(14, 0.45)
		# The slam rattles every room on that floor.
		for column: int in range(ApartmentBuilding.COLUMN_COUNT):
			building.damage_room(attack.floor_index, column, slam_tremor)
	elif attack.source == 0:
		storm.strike()
	attack_launched.emit(attack)
	if building.is_failing():
		collapse_building()

func _on_gust_ready(direction: float, strength: float, duration: float) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	player.apply_wind(direction * strength, duration)
	storm.strike()
	camera.apply_shake(5.0, 0.3)

func _on_dodged(_point: Vector2) -> void:
	dodge_count += 1

func _clear_attacks() -> void:
	if building != null: building.pacing_enabled = false
	if upgrades != null and upgrades.game.mechanics != null: upgrades.game.mechanics.cancel_time_slow()
	if telegraphs != null:
		telegraphs.clear()
	if pool != null:
		pool.clear()
	if player != null:
		player.clear_wind()
	if storm != null:
		storm.set_active(false)
	if earthquake != null:
		earthquake.set_active(false)
	if building != null:
		for prop: BuildingProp in building.props:
			prop.stop_shaking()
