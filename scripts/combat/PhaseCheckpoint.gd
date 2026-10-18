class_name PhaseCheckpoint
extends RefCounted
## Value-only snapshot taken after preparation, before a boss entry. References to
## live room/task dictionaries would let a failed attempt mutate its own checkpoint.
const ROOM_FIELDS: Array[String] = ["hp", "max_hp", "reinforcements", "fortified",
	"utilities_isolated", "auto_protection", "shutter_block", "flood_barrier_bonus",
	"chain_support", "bullet_armor"]
var completed_waves: int
var mode: DisasterWaveManager.Mode
var selected: Array[int] = []
var offers: Array[int] = []
var pending: bool = false
var kits: Array[int] = []
var rooms: Array[Dictionary] = []
var props: Array[Dictionary] = []
var tasks_done: Array[bool] = []
var gas_off: bool
var power_off: bool
var bag_ready: bool
var tutorial_step: int
var repairs_done: int

static func capture(game: MainGame) -> PhaseCheckpoint:
	var saved: PhaseCheckpoint = PhaseCheckpoint.new()
	saved.completed_waves = game.waves.completed_waves
	saved.mode = game.waves.mode
	saved.selected.assign(game.upgrades.selected)
	saved.offers.assign(game.upgrades.offers)
	saved.pending = game.upgrades.pending
	saved.kits.assign([game.loot.column_kits, game.loot.barricade_kits, game.loot.safety_installs])
	for room: RoomDiorama in game.building.rooms:
		var data: Dictionary = {}
		for field: String in ROOM_FIELDS: data[field] = room.get(field)
		saved.rooms.append(data.duplicate(true))
	for prop: BuildingProp in game.building.props:
		saved.props.append({"secured": prop.secured, "toppled": prop.toppled,
			"direction": prop.topple_direction, "condition": prop.condition, "tilt": prop.tilt})
	for task: Dictionary in game.preparedness.tasks: saved.tasks_done.append(task["done"])
	saved.gas_off = game.preparedness.gas_off
	saved.power_off = game.preparedness.power_off
	saved.bag_ready = game.preparedness.bag_ready
	saved.tutorial_step = game.tutorial.step
	saved.repairs_done = game.tutorial.repairs_done
	return saved

## Called only after reset_cycle/reset_player have cleaned the failed attempt.
func restore(game: MainGame) -> void:
	var w: DisasterWaveManager = game.waves
	w.completed_waves = completed_waves
	w.wave_number = completed_waves + 1
	w.mode = mode
	w._next_mode = mode
	w.state = DisasterWaveManager.State.PREPARATION_PHASE if completed_waves == 0 else DisasterWaveManager.State.BUILD_PREPARATION_PHASE
	w.set_preparation(w.preparation_duration if completed_waves == 0 else w.build_duration)
	w.prep_hold = false
	for id: int in selected: game.upgrades.apply_upgrade(id)
	game.upgrades.offers.assign(offers)
	# A boss-entry snapshot has no pending choice. Retrying never grants a new one.
	game.upgrades.pending = false
	game.mechanics.reset()
	game.upgrades.selection_changed.emit()
	game.loot.column_kits = kits[0]
	game.loot.barricade_kits = kits[1]
	game.loot.safety_installs = kits[2]
	for index: int in range(rooms.size()):
		var room: RoomDiorama = game.building.rooms[index]
		var data: Dictionary = rooms[index].duplicate(true)
		for field: String in ROOM_FIELDS:
			if field == "reinforcements": room.reinforcements.assign(data[field])
			else: room.set(field, data[field])
		room._refresh_state(true)
	# Room refresh derives furniture conditions; restore each saved prop afterwards.
	for index: int in range(props.size()):
		var prop: BuildingProp = game.building.props[index]
		var data: Dictionary = props[index]
		prop.secured = data["secured"]
		prop.tilt = data["tilt"]
		prop.condition = data["condition"]
		prop.set_toppled(data["toppled"], data["direction"], true)
	for index: int in range(tasks_done.size()): game.preparedness.tasks[index]["done"] = tasks_done[index]
	game.preparedness.gas_off = gas_off
	game.preparedness.power_off = power_off
	game.preparedness.bag_ready = bag_ready
	game.preparedness.queue_redraw()
	game.tutorial.step = TutorialGuide.Step.PREPARE if game.tutorial.enabled and completed_waves == 0 else tutorial_step
	game.tutorial.repairs_done = repairs_done
	game.tutorial.advance(0.0)
