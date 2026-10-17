class_name CombatFeedback
extends Node2D
## DODGE events in world space. The "DODGE!" word itself is drawn crisply by
## WorldLabels; this node draws the sparkle rays on the pixel grid.

@export var custom_sprite: Texture2D
var texts: Array[Dictionary] = []

func show_dodge(point: Vector2) -> void:
	texts.append({"position": point + Vector2(-40, -123), "life": 0.75})

func clear() -> void:
	texts.clear()
	queue_redraw()

func _process(delta: float) -> void:
	for i: int in range(texts.size() - 1, -1, -1):
		texts[i]["life"] = float(texts[i]["life"]) - delta
		texts[i]["position"] = Vector2(texts[i]["position"]) + Vector2(0, -34) * delta
		if float(texts[i]["life"]) <= 0.0:
			texts.remove_at(i)
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
