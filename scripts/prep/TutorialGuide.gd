class_name TutorialGuide
extends Node
## Öğretici: the first preparation and the first disaster teach by doing, with key
## caps over the player and one short objective line at the top of the screen. Run (A D) -> jump (W) -> walk to the
## glowing preparedness tasks (W W up a floor, S down, an arrow on the same floor,
## E at the target) -> in the first quake: C (Çök-Kapan-Tutun) on every tremor and
## SHIFT when the first attack is telegraphed. The first fight is also gentler.
## The prep clock waits while the player learns to move; F still starts at once.

enum Step { MOVE, JUMP, PREPARE, DONE }
## Prep time once the movement basics are done (the clock is frozen before that).
const TASK_TIME: float = 25.0
const MOVE_DISTANCE: float = 220.0
const SHIFT_HINT: float = 2.6
## Player damage scale during the tutorial fight.
const EASING: float = 0.6
## Bullet patterns come 10% less often in the tutorial fight, and only after the
## first tremor (announced 0.8 s longer) has taught C.
const CADENCE: float = 0.9
const FIRST_PATTERN: float = 5.0
const TREMOR_EXTRA: float = 0.8

var game: MainGame
## Off in the bare MainGame test scene; the front end turns it on from settings.
var enabled: bool = false
var step: int = Step.DONE
var moved: float = 0.0
## Key caps to draw over the player this frame ("A", "D", "W", "S", "C", "SHIFT").
var hint_keys: PackedStringArray = PackedStringArray()
## -1/+1: an arrow beside the player toward a same-floor target; 0: none.
var arrow: int = 0
var shift_taught: bool = false
var shift_hint_left: float = 0.0
## One short line at the top of the screen (empty = none) and its accent colour.
var objective_text: String = ""
var objective_color: Color = UIStyle.TEXT
## Repairs done this run: the repair guidance stays until the first one.
var repairs_done: int = 0
## Ground loot index the repair guidance points at (a column kit), or -1.
var guide_loot: int = -1
var _last_x: float = 0.0
var _jumped_early: bool = false

func configure(owner_game: MainGame) -> void:
	game = owner_game
	process_physics_priority = 6
	game.player.jumped.connect(_on_jumped)
	game.player.dash_started.connect(func() -> void: shift_hint_left = 0.0)
	game.loot.repaired.connect(func(_room: RoomDiorama) -> void: repairs_done += 1)
	reset()

func reset() -> void:
	step = Step.MOVE if enabled else Step.DONE
	moved = 0.0
	repairs_done = 0
	guide_loot = -1
	objective_text = ""
	_jumped_early = false
	shift_taught = false
	shift_hint_left = 0.0
	hint_keys = PackedStringArray()
	arrow = 0
	_last_x = game.player.global_position.x
	if game.waves != null: game.waves.prep_hold = enabled

func set_enabled(value: bool) -> void:
	enabled = value
	if game.waves.completed_waves == 0 and game.waves.state == DisasterWaveManager.State.PREPARATION_PHASE:
		reset()
		if not enabled: game.waves.set_preparation(game.waves.preparation_duration)

## The first campaign disaster (and its preparation) while the tutorial is on.
func first_phase() -> bool:
	var w: DisasterWaveManager = game.waves
	return enabled and w.completed_waves == 0 and not w.failed and not w.victory

## While the player is still learning to run and jump the tasks stay dark, so one
## prompt at a time appears; they light up together with the prep clock.
func blocks_tasks() -> bool:
	return first_phase() and step in [Step.MOVE, Step.JUMP] and game.waves.state == DisasterWaveManager.State.PREPARATION_PHASE

func easing() -> float:
	return EASING if first_phase() and game.waves.state == DisasterWaveManager.State.SIEGE_PHASE else 1.0

func cadence() -> float:
	return CADENCE if first_phase() and game.waves.state == DisasterWaveManager.State.SIEGE_PHASE else 1.0

func _on_jumped(_air: bool) -> void:
	if game.waves.state != DisasterWaveManager.State.PREPARATION_PHASE: return
	if step == Step.JUMP: _begin_tasks()
	elif step == Step.MOVE: _jumped_early = true

func _begin_tasks() -> void:
	step = Step.PREPARE
	game.waves.prep_hold = false
	game.waves.set_preparation(TASK_TIME)

func _physics_process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	hint_keys = PackedStringArray()
	arrow = 0
	guide_loot = -1
	objective_text = ""
	objective_color = UIStyle.TEXT
	var w: DisasterWaveManager = game.waves
	var player: SiegePlayer = game.player
	if player.controls_locked or w.failed or w.victory or w.upgrade_pending:
		_last_x = player.global_position.x
		return
	# Preparation tasks always get their objective line (tutorial or not).
	var prep_line: String = game.preparedness.objective()
	if prep_line != "":
		objective_text = prep_line
		objective_color = game.preparedness.objective_color()
	if first_phase() and w.state == DisasterWaveManager.State.PREPARATION_PHASE:
		match step:
			Step.MOVE:
				moved += absf(player.global_position.x - _last_x)
				if moved < MOVE_DISTANCE:
					hint_keys = PackedStringArray(["A", "D"])
					_set_objective("Koş: A D", UIStyle.TEXT)
				elif _jumped_early: _begin_tasks()
				else: step = Step.JUMP
			Step.JUMP:
				hint_keys = PackedStringArray(["W"])
				_set_objective("Zıpla: W", UIStyle.TEXT)
			Step.PREPARE:
				_point_to_task()
	elif enabled and w.state == DisasterWaveManager.State.SIEGE_PHASE:
		if first_phase() and game.tremor.busy():
			if not player.covering: hint_keys = PackedStringArray(["C"])
			_set_objective("Sarsıntı! C basılı tut: Çök-Kapan-Tutun", UIStyle.ALERT)
		elif first_phase() and not shift_taught and not w.telegraphs.pending.is_empty():
			shift_taught = true
			shift_hint_left = SHIFT_HINT
		if objective_text == "" and repairs_done == 0 and game.building.repair_count() > 0:
			_guide_repair()
		if hint_keys.is_empty() and objective_text == "" and shift_hint_left > 0.0:
			shift_hint_left = maxf(0.0, shift_hint_left - delta)
			hint_keys = PackedStringArray(["SHIFT"])
			_set_objective("Saldırıdan kaç: SHIFT ile takla", UIStyle.TEXT)
	_last_x = player.global_position.x

func _set_objective(text: String, color: Color) -> void:
	objective_text = text
	objective_color = color

## First repair of the run: fetch a column kit, then walk to the damaged room and E.
func _guide_repair() -> void:
	var loot: LootSystem = game.loot
	if loot.column_kits > 0:
		_set_objective("Hasarlı odaya git: E ile onar", UIStyle.ALERT)
		if loot.can_offer_repair(): return
		var target: RoomDiorama = null
		for room: RoomDiorama in game.building.rooms:
			if loot.repair_alert(room) and (target == null or room.hp < target.hp): target = room
		if target != null: _point_to(target.floor_index, target.global_position.x + target.room_size.x * 0.5)
		return
	_set_objective("Oda hasarlı: kolon kiti topla", UIStyle.ALERT)
	var best: float = INF
	for i: int in range(loot.items.size()):
		var item: Dictionary = loot.items[i]
		if int(item["kind"]) != LootSystem.Kind.COLUMN_KIT: continue
		var spot: Vector2 = item["position"]
		var cost: float = absf(spot.x - game.player.global_position.x) + absf(int(item["floor"]) - game.player.current_floor) * 420.0
		if cost < best:
			best = cost
			guide_loot = i
	if guide_loot >= 0:
		var chosen: Dictionary = loot.items[guide_loot]
		_point_to(int(chosen["floor"]), Vector2(chosen["position"]).x)

## W W / S / arrow toward a target on another or the same floor.
func _point_to(target_floor: int, x: float) -> void:
	var player: SiegePlayer = game.player
	if target_floor > player.current_floor: hint_keys = PackedStringArray(["W", "W"])
	elif target_floor < player.current_floor: hint_keys = PackedStringArray(["S"])
	elif absf(x - player.global_position.x) > 60.0: arrow = 1 if x > player.global_position.x else -1

func _point_to_task() -> void:
	var prep: Preparedness = game.preparedness
	if not prep.working.is_empty() or not prep.in_reach().is_empty(): return
	var task: Dictionary = prep.nearest_pending()
	if task.is_empty(): return
	_point_to(prep.task_floor(task), prep.anchor_x(task))
