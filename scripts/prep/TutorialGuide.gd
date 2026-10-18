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
var guide_dir: Vector2i = Vector2i.ZERO
var guide_color: Color = UIStyle.TEXT
var target_task: Dictionary = {}
var entry_left: float = 0.0
var entry_count: int = 0
var reminder_left: float = 0.0
var reminder_count: int = 0
var text_blend: float = 1.0
var _previous_text: String = ""
var _phase_key: int = -1
var _previous_step: int = -1
var _task_completed: bool = false
var _idle: float = 0.0
var _reminder_at: float = 6.0
var _clock: float = 0.0
var _click_at: float = -100.0
var _repair_at: float = -100.0
var _repair_left: float = 0.0
var _repair_mask: int = 0
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
	game.preparedness.task_done.connect(func(_kind: int, _point: Vector2) -> void: _task_completed = true)
	game.player.dash_started.connect(func() -> void: shift_hint_left = 0.0)
	game.loot.repaired.connect(func(_room: RoomDiorama) -> void: repairs_done += 1)
	reset()

func reset() -> void:
	guide_dir = Vector2i.ZERO
	target_task = {}
	entry_left = 0.0
	reminder_left = 0.0
	reminder_count = 0
	_phase_key = -1
	_previous_step = -1
	_previous_text = ""
	_task_completed = false
	_idle = 0.0
	_reminder_at = 6.0
	_repair_mask = 0
	_repair_left = 0.0
	_repair_at = -100.0
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

func cues_visible() -> bool:
	var w: DisasterWaveManager = game.waves
	return not game.get_tree().paused and not game.player.controls_locked and not w.failed and not w.victory and not w.upgrade_pending and w.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE, DisasterWaveManager.State.SIEGE_PHASE]

func advance(delta: float) -> void:
	if not cues_visible():
		hint_keys = PackedStringArray()
		guide_dir = Vector2i.ZERO
		arrow = 0
		guide_loot = -1
		objective_text = ""
		_last_x = game.player.global_position.x
		return
	_clock += delta
	entry_left = maxf(0.0, entry_left - delta)
	reminder_left = maxf(0.0, reminder_left - delta)
	_repair_left = maxf(0.0, _repair_left - delta)
	_update_guidance(delta)
	var preparing: bool = game.waves.state != DisasterWaveManager.State.SIEGE_PHASE
	var key: int = game.waves.completed_waves * 10 + game.waves.state
	var new_phase: bool = key != _phase_key
	if new_phase:
		_phase_key = key
		reminder_count = 0
		_idle = 0.0
		_reminder_at = 6.0
	if (new_phase and preparing) or _task_completed or (_previous_step != step and first_phase()): _enter_objective()
	if objective_text != "": _previous_step = step
	if _task_completed or not game.preparedness.working.is_empty():
		_idle = 0.0
		_reminder_at = 6.0
	elif preparing and not target_task.is_empty():
		_idle += delta
		if _idle >= _reminder_at and reminder_count < 3:
			reminder_count += 1
			reminder_left = .5
			_reminder_at += 5.0
	_task_completed = false
	if objective_text != _previous_text:
		text_blend = 0.0
		_previous_text = objective_text
	else: text_blend = minf(1.0, text_blend + delta / .15)

func _enter_objective() -> void:
	if objective_text == "": return
	entry_left = .8
	entry_count += 1
	if _clock - _click_at >= 1.5:
		_click_at = _clock
		game.sound.play("ui_hover") # Existing UI click is -24 dB; separate 1.5 s cap.

func _update_guidance(delta: float) -> void:
	hint_keys = PackedStringArray()
	arrow = 0
	guide_dir = Vector2i.ZERO
	target_task = {}
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
		_point_to_task()
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
	elif w.state == DisasterWaveManager.State.SIEGE_PHASE:
		if first_phase() and game.tremor.busy():
			if not player.covering: hint_keys = PackedStringArray(["C"])
			_set_objective("Sarsıntı! C basılı tut: Çök-Kapan-Tutun", UIStyle.ALERT)
		elif first_phase() and not shift_taught and not w.telegraphs.pending.is_empty():
			shift_taught = true
			shift_hint_left = SHIFT_HINT
		var mask: int = 0
		for i: int in range(game.building.rooms.size()):
			if game.loot.repair_alert(game.building.rooms[i]): mask |= 1 << i
		if (mask & ~_repair_mask) != 0 and _clock - _repair_at >= 15.0:
			_repair_at = _clock
			_repair_left = 4.0
			if not game.tremor.busy():
				_set_objective("Hasarlı odaya git: E ile onar" if game.loot.column_kits > 0 else "Oda hasarlı: kolon kiti topla", UIStyle.ALERT)
				_enter_objective()
		_repair_mask = mask
		if objective_text == "" and mask != 0 and not game.tremor.busy() and not player.is_dashing and not player.dashing_this_tick:
			_guide_repair()
			if not (enabled and repairs_done == 0) and _repair_left <= 0.0: objective_text = ""
		if enabled and hint_keys.is_empty() and objective_text == "" and shift_hint_left > 0.0:
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
	guide_color = UIStyle.ALERT
	if loot.column_kits > 0:
		_set_objective("Hasarlı odaya git: E ile onar", UIStyle.ALERT)
		if loot.can_offer_repair(): return
		var target: RoomDiorama = null
		for room: RoomDiorama in game.building.rooms:
			if loot.repair_alert(room) and (target == null or room.hp < target.hp): target = room
		if target != null and target != game.building.room_at_point(game.player.current_floor, game.player.global_position.x): _point_to(target.floor_index, target.global_position.x + target.room_size.x * 0.5)
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
	if target_floor > player.current_floor: guide_dir = Vector2i.UP
	elif target_floor < player.current_floor: guide_dir = Vector2i.DOWN
	elif absf(x - player.global_position.x) > 60.0: guide_dir = Vector2i.RIGHT if x > player.global_position.x else Vector2i.LEFT
	arrow = guide_dir.x
	if first_phase() and guide_dir.y != 0:
		hint_keys = PackedStringArray(["W", "W"] if guide_dir.y < 0 else ["S"])

func _point_to_task() -> void:
	var prep: Preparedness = game.preparedness
	target_task = prep.objective_task()
	if not prep.working.is_empty() or not prep.in_reach().is_empty(): return
	var task: Dictionary = target_task
	if task.is_empty(): return
	guide_color = Preparedness.COLORS[int(task["kind"])]
	_point_to(prep.task_floor(task), prep.anchor_x(task))
