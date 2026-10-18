class_name CombatFeedback
extends Node2D
## Word-free hit feedback in world space: a gold six-ray burst over the player
## on DODGE and a turquoise/yellow spark ring at each graze.

@export var custom_sprite: Texture2D
var texts: Array[Dictionary] = []
## Step 7 grazes: a turquoise/yellow spark ring at the near miss.
var grazes: Array[Dictionary] = []
const GRAZE_LIFE: float = 0.55
const GRAZE_TEAL: Color = Color("3ff6e6")
const GRAZE_GOLD: Color = Color("ffe25a")

func show_dodge(point: Vector2) -> void:
	texts.append({"position": point + Vector2(-40, -123), "life": 0.75})

func show_graze(point: Vector2) -> void:
	if grazes.size() >= 6: grazes.remove_at(0)
	grazes.append({"point": point, "position": point + Vector2(-58, -58), "life": GRAZE_LIFE})

func clear() -> void:
	texts.clear()
	grazes.clear()
	queue_redraw()

func _process(delta: float) -> void:
	for i: int in range(texts.size() - 1, -1, -1):
		texts[i]["life"] = float(texts[i]["life"]) - delta
		texts[i]["position"] = Vector2(texts[i]["position"]) + Vector2(0, -34) * delta
		if float(texts[i]["life"]) <= 0.0:
			texts.remove_at(i)
	for i: int in range(grazes.size() - 1, -1, -1):
		grazes[i]["life"] = float(grazes[i]["life"]) - delta
		grazes[i]["position"] = Vector2(grazes[i]["position"]) + Vector2(0, -46) * delta
		if float(grazes[i]["life"]) <= 0.0:
			grazes.remove_at(i)
	queue_redraw()

func _draw() -> void:
	for text: Dictionary in texts:
		var point: Vector2 = Vector2(text["position"])
		var alpha: float = minf(1.0, float(text["life"]) * 3.0)
		for i: int in range(6):
			var ray: Vector2 = Vector2.from_angle(i * TAU / 6.0 + 0.25)
			var center: Vector2 = point + Vector2(46, -9)
			draw_line(center + ray * 58, center + ray * 72, Color(Color("f5d986"), alpha * 0.35), 8, true)
			draw_line(center + ray * 58, center + ray * 72, Color(CelArt.GOLD, alpha), 3, true)
	for graze: Dictionary in grazes:
		var t: float = 1.0 - float(graze["life"]) / GRAZE_LIFE
		var at: Vector2 = graze["point"]
		var fade: float = 1.0 - t
		draw_arc(at, 10.0 + t * 30.0, 0.0, TAU, 16, Color(GRAZE_TEAL, fade), 3.0)
		draw_arc(at, 6.0 + t * 20.0, 0.0, TAU, 12, Color(GRAZE_GOLD, fade * .8), 2.0)
		for i: int in range(8):
			var ray: Vector2 = Vector2.from_angle(i * TAU / 8.0 + .2)
			draw_line(at + ray * (12.0 + t * 28.0), at + ray * (20.0 + t * 40.0), GRAZE_GOLD if i % 2 == 0 else GRAZE_TEAL, 2.0)
