class_name UpgradeDossier
extends Button
## A plain dark card. Focus or hover lights its border and a thin top bar in the
## slot's accent colour. The real Button owns keyboard focus and mouse hit testing.
var accent: Color = UIStyle.TEXT
var highlighted: bool = false

func _ready() -> void:
	mouse_entered.connect(_highlight.bind(true))
	mouse_exited.connect(_highlight.bind(false))
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

func _highlight(value: bool) -> void:
	highlighted = value
	queue_redraw()

func _draw() -> void:
	var lit: bool = highlighted or has_focus()
	var area: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(area, Color(0.06, 0.08, 0.09, 0.94))
	draw_rect(area, accent if lit else UIStyle.FAINT, false, 2.0 if lit else 1.0)
	if lit: draw_rect(Rect2(0, 0, size.x, 4), accent)
