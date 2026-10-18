class_name FeelFX
extends Node2D
## Bounded, wordless success effects on the world's existing pixel grid.
signal room_recovered(room: RoomDiorama)
const LIMIT: int = 8
@export var custom_sprite: Texture2D
var game: MainGame
var task_bursts: Array[Dictionary] = []
var repair_pluses: Array[Dictionary] = []
var safe_rings: Array[Dictionary] = []
var _room_states: Dictionary = {}

func configure(owner_game: MainGame) -> void:
	game = owner_game
	z_index = 7
	game.preparedness.task_done.connect(func(kind: int, point: Vector2) -> void: task_burst(point, Preparedness.COLORS[kind]))
	game.tremor.debris.connect(_on_debris)
	room_recovered.connect(game.labels.on_room_recovered)
	for room: RoomDiorama in game.building.rooms:
		_room_states[room] = room.state()
		room.state_changed.connect(_on_room_state)

func _add(pool: Array[Dictionary], data: Dictionary) -> void:
	if pool.size() >= LIMIT: pool.pop_front()
	pool.append(data)
	queue_redraw()

func task_burst(point: Vector2, color: Color) -> void:
	_add(task_bursts, {"point": point, "color": color, "age": 0.0, "life": .6})

func _on_room_state(room: RoomDiorama, state: int) -> void:
	var previous: int = int(_room_states.get(room, room.state()))
	_room_states[room] = state
	if game.resetting: return
	if previous in [RoomDiorama.RoomState.DAMAGED, RoomDiorama.RoomState.CRITICAL] and state in [RoomDiorama.RoomState.INTACT, RoomDiorama.RoomState.FORTIFIED]:
		_add(repair_pluses, {"point": room.global_position + Vector2(0, room.room_size.y - 26), "width": room.room_size.x, "age": 0.0, "life": .6})
		room_recovered.emit(room)

func _on_debris(covered: bool) -> void:
	if covered: _add(safe_rings, {"point": game.player.global_position + Vector2(0, -48), "age": 0.0, "life": .55})

func clear() -> void:
	task_bursts.clear()
	repair_pluses.clear()
	safe_rings.clear()
	queue_redraw()

func _process(delta: float) -> void:
	advance(delta / maxf(.001, Engine.time_scale))

func advance(delta: float) -> void:
	if task_bursts.is_empty() and repair_pluses.is_empty() and safe_rings.is_empty(): return
	for pool: Array[Dictionary] in [task_bursts, repair_pluses, safe_rings]:
		for index: int in range(pool.size() - 1, -1, -1):
			pool[index]["age"] = float(pool[index]["age"]) + delta
			if float(pool[index]["age"]) >= float(pool[index]["life"]): pool.remove_at(index)
	queue_redraw() # Includes the last expired frame; no scene/cache mutations.

func _draw() -> void:
	for data: Dictionary in task_bursts:
		var age: float = data["age"]
		var point: Vector2 = data["point"]
		if custom_sprite != null:
			draw_texture_rect(custom_sprite, Rect2(point - Vector2(32, 32), Vector2(64, 64)), false, Color(1, 1, 1, 1.0 - age / .6))
		elif age < .5:
			var t: float = age / .5
			for ray: int in range(12):
				var direction: Vector2 = Vector2.from_angle(TAU * ray / 12.0)
				var start: Vector2 = point + direction * lerpf(8, 40, t)
				draw_line(start, start + direction * lerpf(6, 14, t), Color(data["color"], 1.0 - t), 3.0)
		var scale_pop: float = lerpf(0, 1.2, smoothstep(0, .12, age)) if age < .12 else lerpf(1.2, 1.0, smoothstep(.12, .24, age))
		draw_set_transform(point + Vector2(0, -20), 0, Vector2.ONE * maxf(.001, scale_pop))
		Debrief.draw_mark(self, Vector2.ZERO, true, 1.0 - smoothstep(.35, .6, age))
		draw_set_transform(Vector2.ZERO)
	for data: Dictionary in repair_pluses:
		var t: float = float(data["age"]) / .6
		for index: int in range(8):
			var point: Vector2 = Vector2(data["point"]) + Vector2((index + .5) * float(data["width"]) / 8.0, -30 * t - (index % 3) * 8)
			var color: Color = Color(UIStyle.SAFE, 1.0 - t)
			draw_line(point - Vector2(4, 0), point + Vector2(4, 0), color, 3)
			draw_line(point - Vector2(0, 4), point + Vector2(0, 4), color, 3)
	for data: Dictionary in safe_rings:
		var age: float = data["age"]
		var point: Vector2 = data["point"]
		draw_arc(point, lerpf(18, 64, age / .55), 0, TAU, 32, Color(UIStyle.SAFE, 1 - age / .55), 4)
		if age < .4: draw_arc(point + Vector2(0, -42), 30, PI, TAU, 20, Color(UIStyle.SAFE, 1 - age / .4), 3)
