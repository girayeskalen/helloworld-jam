class_name FieldUI
extends RefCounted
## Painted metal, paper and restrained safety colours. No external assets.
const INK: Color = Color("0a1014")
const PAPER: Color = Color("e4dfcc")
const MUTED: Color = Color("9ca9a7")
const AMBER: Color = Color("c7a36c")

static func label(parent: Control, text: String, rect: Rect2, font_size: int, color: Color = PAPER) -> Label:
	var item: Label = Label.new()
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.clip_text = true
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",color)
	item.text = text
	item.position = rect.position
	item.size = rect.size
	parent.add_child(item)
	return item

static func button(parent: Control, text: String, rect: Rect2, action: Callable, primary: bool = false) -> Button:
	var item: Button = Button.new()
	item.text = text
	item.position = rect.position
	item.size = rect.size
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	item.add_theme_font_size_override("font_size",28)
	for state: String in ["normal","hover","pressed","focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("26302e",.7) if primary else Color("111b1e",.65)
		if state != "normal": style.bg_color = Color("39423b",.95)
		style.border_color = AMBER if state != "normal" or primary else Color("53605c")
		style.border_width_bottom = 1
		style.border_width_left = 3 if state != "normal" or primary else 1
		style.content_margin_left = 26
		item.add_theme_stylebox_override(state,style)
	for state: String in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		item.add_theme_color_override(state,PAPER)
	item.pressed.connect(action)
	parent.add_child(item)
	return item

static func grain(canvas: CanvasItem, rect: Rect2, count: int = 90) -> void:
	# Fixed marks never flicker or touch gameplay RNG.
	for i: int in range(count):
		var p: Vector2 = rect.position+Vector2(fmod(i*137.7,rect.size.x),fmod(i*i*19.3,rect.size.y))
		canvas.draw_line(p,p+Vector2(2+i%9,0),Color("c5c6af",.035),1)
