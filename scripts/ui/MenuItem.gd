class_name MenuItem
extends Button
## Text-only menu entry. A small square marks the focused/hovered entry; the real
## Button keeps keyboard focus and scaled mouse hit testing.
var accent: Color = UIStyle.TEXT
var _hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	focus_entered.connect(_focus_sound)
	focus_exited.connect(queue_redraw)

func _set_hovered(value: bool) -> void:
	if value: _focus_sound()
	_hovered = value
	queue_redraw()

func _draw() -> void:
	if not (_hovered or has_focus()): return
	var y: float = size.y * 0.5
	if alignment == HORIZONTAL_ALIGNMENT_LEFT:
		draw_rect(Rect2(4, y - 4, 8, 8), accent)
	else:
		var half: float = UIStyle.width(text, get_theme_font_size("font_size")) * 0.5
		draw_rect(Rect2(size.x * 0.5 - half - 24, y - 4, 8, 8), accent)

func _focus_sound() -> void:
	queue_redraw()
	var sound: Node = get_tree().get_first_node_in_group("siege_audio")
	if sound != null: sound.play("ui_hover")
