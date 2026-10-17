class_name DisasterWaveManager
extends Node

signal phase_changed
signal attack_launched(attack: HazardAttack)
## The four elements collide during the final boss entry (camera shake + sky flash).
signal fusion_burst
signal intro_beat(mode_id: int, beat: int)
## A graze the player actually cashed in (energy granted); drives FX and sound.
signal grazed(world_position: Vector2)

enum State { PREPARATION_PHASE, SIEGE_PHASE, BUILD_PREPARATION_PHASE, VICTORY, WAVE_INTRO, WAVE_OUTRO }
enum Mode { STORM, EARTHQUAKE, FLOOD, CATACLYSM }
const TOTAL_WAVES: int = 4
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
@export var build_duration: float = 5.0
@export var secondary_damage_rate: float = 0.15
@export var siege_duration: float = 50.0
@export var autoplay: bool = true
@export var storm_interval: float = 1.95
@export var quake_interval: float = 2.8
@export var gust_strength: float = 150.0
@export var gust_duration: float = 2.2
## HP per second that damaged/critical rooms keep losing during a siege.
@export var room_erosion: float = 0.25
## Every room on the slammed floor loses this much when the golem hits.
@export var slam_tremor: float = 1.0

const INTRO_DURATION: float = 2.5
## Kataklizma Titanı: the four element energies need a longer fusion entry.
const FINAL_INTRO_DURATION: float = 2.8
const FUSION_IMPACT: float = 0.55
const OUTRO_DURATION: float = 1.0
## Step 7 tempo ramp (seconds into the fight): a calm warm-up, a linear build and a
## readable climax. Cadence scales with the full tempo; bullet travel only with half
## of the excess above 1.0 so paths stay dodgeable.
const WARMUP_END: float = 15.0
const RAMP_END: float = 35.0
const WARMUP_TEMPO: float = 0.9
const RAMP_TOP: float = 1.25
const CLIMAX_TEMPO: float = 1.45
## Short eases at both seams so the cadence never jumps within one frame.
const TEMPO_EASE: float = 1.0
## Final phase already has the nova; it takes half of the ramp on top of it.
const FINAL_RAMP_SHARE: float = 0.5
## Light geometric bullets chip rooms less than heavy debris (index: pattern).
const PATTERN_ROOM_DAMAGE: Dictionary = {
	HazardAttack.Pattern.PINWHEEL: 0.45, HazardAttack.Pattern.SINE_TUNNEL: 0.4, HazardAttack.Pattern.CYCLONE_RING: 0.4,
	HazardAttack.Pattern.SCISSOR: 1.2, HazardAttack.Pattern.SAFE_FLOOR: 1.5, HazardAttack.Pattern.TECTONIC_RING: 0.5,
	HazardAttack.Pattern.FAULT_WAVE: 1.5, HazardAttack.Pattern.BOULDER_STAMPEDE: 2.5,
}
## Room HP per second while a ceiling collapse covers a room (~1.1 per crush).
const ROCKFALL_ROOM_RATE: float = 3.0
## The titan overloads (Kataklizma Nova) during the last 15 seconds of its fight.
const NOVA_WINDOW: float = 15.0
var transition_remaining: float = 0.0
var debug_enabled: bool = false
var state: State = State.PREPARATION_PHASE
var fail_reason: FailReason = FailReason.NONE
var mode: Mode = Mode.STORM
var wave_number: int = 0
var preparation_remaining: float = 8.0
var siege_remaining: float = 50.0
var boss_endurance: float = 100.0
var failed: bool = false
var victory: bool = false
var upgrades: SiegeUpgrades
var loot: LootSystem
var upgrade_pending: bool:
	get: return upgrades != null and upgrades.pending
const VICTORY_TEXT: String = "4 AFET FAZI ATLATILDI! BİNANIZ HAYATTA KALDI!"
var dodge_count: int = 0
var graze_count: int = 0
var completed_waves: int = 0
var building: ApartmentBuilding
var player: SiegePlayer
var camera: GameCamera
var telegraphs: TelegraphSystem
var pool: ProjectilePool
var storm: DisasterBoss
var flood: DisasterBoss
var enrage: bool = false
var _marathon_clock: float = 0.5
var _marathon_pattern: int = 0
@export var flood_interval: float = 1.8
var earthquake: DisasterBoss
var titan: DisasterBoss
@export var cataclysm_interval: float = 2.1
@export var nova_interval: float = 1.15
## Extra column kits and emergency bags while the nova rages.
@export var nova_supply_interval: float = 3.5
var nova: bool = false
var nova_supplies: int = 0
var _nova_supply_clock: float = 0.0
var _fusion_fired: bool = false
var _intro_beats: int = 0
var _next_mode: Mode = Mode.STORM
var _storm_clock: float = 0.0
var _quake_clock: float = 0.0
var _storm_pattern: int = 0
var _quake_pattern: int = 0

func _ready() -> void:
	process_physics_priority = 5

func configure(home: ApartmentBuilding, actor: SiegePlayer, view: GameCamera, warnings: TelegraphSystem, projectiles: ProjectilePool, storm_boss: DisasterBoss, quake_boss: DisasterBoss, flood_boss: DisasterBoss, final_boss: DisasterBoss) -> void:
	building = home
	player = actor
	camera = view
	telegraphs = warnings
	pool = projectiles
	storm = storm_boss
	earthquake = quake_boss
	flood = flood_boss
	titan = final_boss
	pool.player = player
	pool.zone_tick.connect(_on_zone_tick)
	telegraphs.attack_ready.connect(Callable(self, "_on_attack_ready"))
	telegraphs.gust_ready.connect(Callable(self, "_on_gust_ready"))
	# Room damage comes from every impact (see _on_projectile_impacted); the old
	# building-wide structure_hit signal is no longer consumed.
	pool.projectile_impacted.connect(Callable(self, "_on_projectile_impacted"))
	pool.dodged.connect(Callable(self, "_on_dodged"))
	pool.grazed.connect(Callable(self, "_on_grazed"))
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
	graze_count = 0
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
	start_siege(clampi(completed_waves, 0, TOTAL_WAVES - 1) as Mode)

func start_siege(requested_mode: Mode, test_shortcut: bool = false) -> void:
	if int(requested_mode) < 0 or int(requested_mode) >= TOTAL_WAVES: return
	if not test_shortcut and (upgrade_pending or failed or victory or state not in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE]):
		return
	if not test_shortcut:
		requested_mode = clampi(completed_waves, 0, TOTAL_WAVES - 1) as Mode
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
	player.controls_locked = true
	wave_number = int(requested_mode) + 1
	if test_shortcut: completed_waves = wave_number - 1
	mode = requested_mode
	state = State.WAVE_INTRO
	transition_remaining = intro_duration()
	siege_remaining = siege_duration
	boss_endurance = 100.0
	_storm_clock = 0.3
	_quake_clock = 0.5
	_storm_pattern = 0
	_quake_pattern = 0
	storm.set_active(mode == Mode.STORM)
	earthquake.set_active(mode == Mode.EARTHQUAKE)
	flood.set_active(mode == Mode.FLOOD)
	titan.set_active(mode == Mode.CATACLYSM)
	enrage = false
	nova = false
	nova_supplies = 0
	_fusion_fired = false
	_intro_beats = 0
	_marathon_clock = 0.45
	_marathon_pattern = 0
	if mode in [Mode.EARTHQUAKE, Mode.FLOOD]: camera.apply_shake(7.0, INTRO_DURATION)
	if mode == Mode.CATACLYSM: camera.apply_shake(5.0, FINAL_INTRO_DURATION)
	for boss: DisasterBoss in bosses():
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
	nova = false
	building.pacing_enabled = false
	telegraphs.clear()
	pool.dissolve_all()
	player.clear_wind()
	if upgrades != null: upgrades.game.mechanics.cancel_time_slow()
	for prop: BuildingProp in building.props: prop.stop_shaking()
	for boss: DisasterBoss in bosses():
		if boss.visible: boss.transition_pose(0.0, true)
	phase_changed.emit()

func _complete_outro() -> void:
	_clear_attacks()
	completed_waves = wave_number
	if completed_waves == TOTAL_WAVES:
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

func intro_duration() -> float:
	return FINAL_INTRO_DURATION if mode == Mode.CATACLYSM else INTRO_DURATION

## U is a deliberate practice shortcut, never an extra completed wave.
func test_upgrades() -> void:
	if not debug_enabled or failed or victory or upgrade_pending:
		return
	_clear_attacks()
	if loot != null: loot.clear_drops()
	_next_mode = clampi(completed_waves, 0, TOTAL_WAVES - 1) as Mode
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
		var progress: float = 1.0 - transition_remaining / (OUTRO_DURATION if outro else intro_duration())
		if not outro:
			for beat: int in range(3):
				if progress >= [0.18, 0.46, 0.78][beat] and (_intro_beats & (1 << beat)) == 0:
					_intro_beats |= 1 << beat
					intro_beat.emit(mode, beat)
					if mode == Mode.EARTHQUAKE:
						camera.apply_shake(18.0 if beat == 2 else 12.0, .4)
						if beat > 0: earthquake.strike()
		for boss: DisasterBoss in bosses():
			if boss.visible: boss.transition_pose(progress, outro)
		if mode == Mode.CATACLYSM and not outro and not _fusion_fired and progress >= FUSION_IMPACT:
			_fusion_fired = true
			camera.apply_shake(22.0, 0.7)
			fusion_burst.emit()
		if upgrades != null: upgrades.game.mechanics.retreat_dust(delta)
		if transition_remaining <= 0.000001:
			if outro: _complete_outro()
			else:
				state = State.SIEGE_PHASE
				player.controls_locked = false
				building.pacing_enabled = true
				if loot != null: loot.begin_wave()
				if upgrades != null: upgrades.begin_wave()
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
	if mode == Mode.CATACLYSM:
		if not nova and siege_remaining <= NOVA_WINDOW: _begin_nova()
		_marathon_clock -= combat_delta * final_tempo()
		if _marathon_clock <= 0.0:
			cataclysm_burst()
			_marathon_clock += (nova_interval if nova else cataclysm_interval)*CataclysmPatterns.COOLDOWN_SCALE
		if nova:
			_nova_supply_clock -= delta
			if _nova_supply_clock <= 0.000001:
				_nova_supply_clock += nova_supply_interval
				_drop_nova_supply()
		return
	if mode == Mode.FLOOD:
		_marathon_clock -= combat_delta * tempo()
		if _marathon_clock <= 0.0:
			marathon_burst()
			_marathon_clock += flood_interval
		return
	if mode != Mode.EARTHQUAKE:
		_storm_clock -= combat_delta * tempo()
		if _storm_clock <= 0:
			storm_burst()
			_storm_clock += storm.next_delay if storm.next_delay > 0.0 else storm_interval
	if mode != Mode.STORM:
		_quake_clock -= combat_delta * tempo()
		if _quake_clock <= 0:
			quake_burst()
			_quake_clock += earthquake.next_delay if earthquake.next_delay > 0.0 else quake_interval

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
	if state == State.WAVE_INTRO and mode == Mode.CATACLYSM and not failed: return "ÜÇ AFET BİRLEŞİYOR"
	if state == State.WAVE_INTRO and not failed: return "AFET YAKLAŞIYOR · HAZIR OL"
	if victory: return "DÖRT AFET FAZI ATLATILDI"
	if upgrade_pending: return "AFET HAZIRLIK BÜLTENİ · 1 ÖNLEM SEÇ"
	if state == State.BUILD_PREPARATION_PHASE: return "AFETE HAZIRLIK & GÜÇLENDİRME · F: HAZIRIM"
	if enrage: return "SON 10 SANİYE · KOR TİTANI CİNNETİ +%25"
	if nova: return "SON 15 SANİYE · KATAKLİZMA NOVA"
	return "HAZIRLIK EVRESİ" if state == State.PREPARATION_PHASE else "AFET KUŞATMASI"

func boss_name() -> String:
	var active_mode: Mode = _next_mode if state in [State.PREPARATION_PHASE, State.BUILD_PREPARATION_PHASE] else mode
	match active_mode:
		Mode.STORM: return "FIRTINA"
		Mode.EARTHQUAKE: return "DEPREM"
		Mode.FLOOD: return "SEL"
	return "DEPREM • SEL • FIRTINA"

func bosses() -> Array[DisasterBoss]:
	return [storm, earthquake, flood, titan]

func cataclysm_burst() -> void:
	titan.plan_pattern(self, _marathon_pattern, player.current_floor)
	_marathon_pattern += 1

## Final 15 seconds: faster combos, relocation and guaranteed survival supplies.
func _begin_nova() -> void:
	nova = true
	titan.enraged = true
	_marathon_clock = minf(_marathon_clock, 0.35)
	_nova_supply_clock = nova_supply_interval
	camera.apply_shake(12.0, 0.6)
	_drop_nova_supply()
	_drop_nova_supply()

func _drop_nova_supply() -> void:
	if loot == null: return
	var kind: int = LootSystem.Kind.COLUMN_KIT if nova_supplies % 2 == 0 else LootSystem.Kind.EMERGENCY_BAG
	if loot.emergency_drop(kind): nova_supplies += 1

func marathon_burst() -> void:
	flood.plan_pattern(self, _marathon_pattern, player.current_floor)
	_marathon_pattern += 1

func chaos_burst() -> void:
	var target: int = player.current_floor
	storm.plan_pattern(self, _storm_pattern, target)
	earthquake.plan_pattern(self, _quake_pattern, (target + 2) % building.floor_count)
	_storm_pattern += 1
	_quake_pattern += 1

## Step 7 choreographies aim at the player's own floor (the storm dives there).
func storm_burst() -> void:
	storm.plan_pattern(self, _storm_pattern, player.current_floor)
	_storm_pattern += 1

## The roar announces a whole-building gust that drifts the player away from the storm.
## The final titan reuses it as a telegraphed pull toward its vortex arm.
func storm_gust(direction: float = 1.0, strength: float = -1.0) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	var floors: PackedFloat32Array = PackedFloat32Array()
	for index: int in range(building.floor_count):
		floors.append(building.floor_y(index))
	var area: Rect2 = Rect2(building.global_position, Vector2(building.building_width, building.floor_count * building.floor_height))
	telegraphs.warn_gust(area, floors, direction, gust_strength if strength < 0.0 else strength, gust_duration, .65, CataclysmPatterns.WARNING_EXTRA if mode == Mode.CATACLYSM else 0.0)

func quake_burst() -> void:
	earthquake.plan_pattern(self, _quake_pattern, player.current_floor)
	_quake_pattern += 1

func _on_projectile_impacted(attack: HazardAttack, point: Vector2) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	var amount: float = room_damage(attack) * (upgrades.damage_multiplier(attack) if upgrades != null else 1.0)
	if attack.is_area(): return
	if attack.is_wall():
		for column: int in range(ApartmentBuilding.COLUMN_COUNT):
			building.damage_room(attack.floor_index, column, amount,attack.source)
	else:
		building.damage_room_at(attack.floor_index, point.x, amount,attack.source)
	if building.is_failing():
		collapse_building()
		return
	if attack.leaves_fire: MarathonPatterns.ignite(self, attack, point)
	if attack.splits:
		# Meteors falling into live final-boss flood water become steam columns.
		if attack.pattern == HazardAttack.Pattern.STEAM_TSUNAMI and attack.kind == HazardAttack.Kind.CONCRETE and CataclysmPatterns.steam_burst(self, attack, point): return
		if attack.source >= 2: MarathonPatterns.split(self, attack, point)
		else: BossPatterns.splinters(self, attack, point)

static func room_damage(attack: HazardAttack) -> float:
	var base: float = 0.6 if attack.pattern in CataclysmPatterns.LIGHT_PATTERNS else float(ROOM_DAMAGE.get(attack.kind, 3.0 if attack.source >= 2 else 0.8))
	if PATTERN_ROOM_DAMAGE.has(attack.pattern): base = float(PATTERN_ROOM_DAMAGE[attack.pattern])
	return base*attack.difficulty_damage_scale

func plan_attack(attack: HazardAttack, warning_seconds: float = 0.65) -> void:
	if state == State.SIEGE_PHASE and not failed:
		var prepared: HazardAttack = attack.frozen_copy()
		if mode == Mode.CATACLYSM: CataclysmPatterns.tune(prepared)
		if mode == Mode.EARTHQUAKE and prepared.source == 1: prepared.scale_travel_speed(BossPatterns.QUAKE_SPEED_SCALE)
		# Ramp: later in the fight bullets travel a little faster (same endpoints).
		var travel: float = bullet_tempo()
		if travel > 1.0001: prepared.scale_travel_speed(travel)
		if upgrades != null: prepared = upgrades.prepare_attack(prepared)
		if prepared.kind in [HazardAttack.Kind.FLOOD_ZONE,HazardAttack.Kind.FIRE_ZONE]:
			for room: RoomDiorama in building.rooms:
				if room.auto_protection and room.floor_index == prepared.floor_index: prepared.safe_areas.append(Rect2(room.global_position,room.room_size))
			if prepared.area_segments().is_empty(): return
		telegraphs.warn(prepared,warning_seconds)

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
	if kind >= HazardAttack.Kind.FLOOD_ZONE:
		attack.radius = 13
		attack.damage = 16
		if kind in [HazardAttack.Kind.METEOR, HazardAttack.Kind.HYDRO_ORB]: attack.radius = 23; attack.damage = 20
		if kind in [HazardAttack.Kind.WATER_SHARD, HazardAttack.Kind.FIRE_DART]: attack.radius = 8; attack.damage = 10
		if kind in [HazardAttack.Kind.TIDAL_WALL, HazardAttack.Kind.FIRE_BEAM]: attack.damage = 24
		if kind == HazardAttack.Kind.WHIRLPOOL: attack.damage = 0
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
		(titan if mode == Mode.CATACLYSM else earthquake).strike()
		camera.apply_shake(14, 0.45)
		# The slam rattles every room on that floor.
		for column: int in range(ApartmentBuilding.COLUMN_COUNT):
			building.damage_room(attack.floor_index, column, slam_tremor*building.structural_factor*attack.difficulty_damage_scale,1)
	else:
		var source_boss: DisasterBoss = titan if mode == Mode.CATACLYSM else [storm, earthquake, flood][clampi(attack.source, 0, 2)]
		source_boss.strike()
	if attack.pattern == HazardAttack.Pattern.CATACLYSM_NOVA and attack.lead: CataclysmPatterns.overload_rooms(self, attack)
	attack_launched.emit(attack)
	if building.is_failing():
		collapse_building()

func _on_zone_tick(attack: HazardAttack, delta: float) -> void:
	if state != State.SIEGE_PHASE or failed or attack.kind == HazardAttack.Kind.WHIRLPOOL: return
	var factor: float = (upgrades.damage_multiplier(attack) if upgrades != null else 1.0)*attack.difficulty_damage_scale
	for room: RoomDiorama in building.rooms:
		if room.auto_protection or room.floor_index != attack.floor_index or not attack.area.intersects(Rect2(room.global_position, room.room_size)): continue
		if attack.kind == HazardAttack.Kind.FIRE_ZONE:
			room.heat = minf(100.0, room.heat + delta * 30.0 * factor)
		var rate: float = 4.0 if attack.kind == HazardAttack.Kind.FIRE_ZONE else (ROCKFALL_ROOM_RATE if attack.kind == HazardAttack.Kind.ROCKFALL else 1.0)
		room.apply_damage(delta * rate * factor,attack.source)

func _on_gust_ready(direction: float, strength: float, duration: float) -> void:
	if state != State.SIEGE_PHASE or failed:
		return
	player.apply_wind(direction * strength, duration)
	(titan if mode == Mode.CATACLYSM else storm).strike()
	camera.apply_shake(5.0, 0.3)

func _on_dodged(_point: Vector2) -> void:
	dodge_count += 1

## Near miss: the player gains dash energy (their own cooldown filters bursts).
func _on_grazed(point: Vector2) -> void:
	if state != State.SIEGE_PHASE or failed: return
	if player.graze(point):
		graze_count += 1
		grazed.emit(point)

## Seconds since the current fight started (0 outside a siege).
func fight_elapsed() -> float:
	return clampf(siege_duration - siege_remaining, 0.0, siege_duration) if state == State.SIEGE_PHASE else 0.0

## Tempo at `elapsed` fight seconds: 0.90 warm-up, 1.00 -> 1.25 build, 1.45 climax.
static func tempo_at(elapsed: float) -> float:
	if elapsed < WARMUP_END - TEMPO_EASE: return WARMUP_TEMPO
	if elapsed < WARMUP_END: return lerpf(WARMUP_TEMPO, 1.0, smoothstep(WARMUP_END - TEMPO_EASE, WARMUP_END, elapsed))
	if elapsed < RAMP_END - TEMPO_EASE: return lerpf(1.0, RAMP_TOP, (elapsed - WARMUP_END) / (RAMP_END - WARMUP_END))
	if elapsed < RAMP_END:
		var edge: float = lerpf(1.0, RAMP_TOP, (RAMP_END - TEMPO_EASE - WARMUP_END) / (RAMP_END - WARMUP_END))
		return lerpf(edge, CLIMAX_TEMPO, smoothstep(RAMP_END - TEMPO_EASE, RAMP_END, elapsed))
	return CLIMAX_TEMPO

func tempo() -> float:
	return tempo_at(fight_elapsed()) if state == State.SIEGE_PHASE else 1.0

func final_tempo() -> float:
	return 1.0 + (tempo() - 1.0) * FINAL_RAMP_SHARE

## Bullet travel multiplier: never slower than authored, half of the cadence excess.
func bullet_tempo() -> float:
	var live: float = final_tempo() if mode == Mode.CATACLYSM else tempo()
	return maxf(1.0, 1.0 + (live - 1.0) * 0.5)

func is_climax() -> bool:
	return state == State.SIEGE_PHASE and not failed and fight_elapsed() >= RAMP_END

func _clear_attacks() -> void:
	enrage = false
	nova = false
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
	if flood != null: flood.set_active(false)
	if titan != null: titan.set_active(false)
	if building != null:
		for prop: BuildingProp in building.props:
			prop.stop_shaking()

## Local safety kits neutralise only floor fire/flood, including warnings already queued.
func protect_room(room: RoomDiorama) -> void:
	var region: Rect2 = Rect2(room.global_position,room.room_size)
	for attack: HazardAttack in telegraphs.pending.duplicate():
		if attack.kind in [HazardAttack.Kind.FLOOD_ZONE,HazardAttack.Kind.FIRE_ZONE] and attack.floor_index == room.floor_index:
			attack.safe_areas.append(region)
			if attack.area_segments().is_empty(): telegraphs.pending.erase(attack)
	for shot: HazardProjectile in pool.entries:
		if not shot.active: continue
		if shot.attack.kind in [HazardAttack.Kind.FLOOD_ZONE,HazardAttack.Kind.FIRE_ZONE] and shot.attack.floor_index == room.floor_index:
			shot.attack.safe_areas.append(region)
			if shot.attack.area_segments().is_empty(): pool.dissolve(shot)
	telegraphs.queue_redraw()
	if loot != null and loot.current_room() == room:
		player.hazard_drag = 0.0
		player.hazard_pull = 0.0
