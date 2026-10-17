class_name UpgradeDossier
extends Button
## The real Button owns keyboard focus and scaled mouse hit testing.
var accent: Color = FieldUI.AMBER
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
	var edge: Color = accent if lit else Color("485453")
	draw_rect(Rect2(0,0,size.x,5),accent.darkened(.18))
	draw_rect(Rect2(18,52,size.x-36,154),Color("10191d"))
	for x: int in range(34,int(size.x)-24,26):
		draw_line(Vector2(x,66),Vector2(x,192),Color("708480",.09),1)
	for y: int in range(66,193,26):
		draw_line(Vector2(34,y),Vector2(size.x-34,y),Color("708480",.09),1)
	draw_arc(Vector2(size.x*.5,129),62,0,TAU,32,Color(accent,.16),1)
	draw_line(Vector2(24,305),Vector2(size.x-24,305),Color("58645c",.45),1)
	draw_rect(Rect2(18,426,size.x-36,90),Color("0c1518",.6))
	FieldUI.grain(self,Rect2(8,8,size.x-16,size.y-16),105)
	draw_colored_polygon(PackedVector2Array([Vector2(size.x-18,0),Vector2(size.x,0),Vector2(size.x,18)]),FieldUI.INK)
	draw_line(Vector2(size.x-18,0),Vector2(size.x,18),edge,1)
	for x: float in [12.0,size.x-12]:
		draw_circle(Vector2(x,15),2,Color("778079"))
	draw_line(Vector2(22,size.y-42),Vector2(size.x-22,size.y-42),edge,1)
	if lit: draw_rect(Rect2(0,0,4,size.y),accent)
