class_name UIStyle
extends RefCounted
## One quiet visual language for every screen: the game's own pixel capitals
## (PixelFont), two text tones and a soft drop shadow instead of outlines, plates or
## boxes. Sizes are whole multiples of the font's 12 px base (crisp 2x-6x pixels);
## nothing is smaller than SMALL because the default 1280x720 window scales by 2/3.

const SMALL: int = 24
const MEDIUM: int = 36
const LARGE: int = 48
const TITLE: int = 72
const TEXT: Color = Color("e8e3d3")
const MUTED: Color = Color("8a938e")
const FAINT: Color = Color("3c4644")
const TROUGH: Color = Color(0.03, 0.04, 0.05, 0.7)
const SHADOW: Color = Color(0.0, 0.0, 0.0, 0.6)
const HEALTH: Color = Color("e0564a")
const ENERGY: Color = Color("e9c45c")
const ENERGY_FULL: Color = Color("9fe0ff")
const SAFE: Color = Color("7dffb2")
const ALERT: Color = Color("ffb04a")
const DANGER: Color = Color("ff5a4a")
## Boss neon, shared with bullets and telegraphs (storm, quake, flood, final).
const BOSS: Array[Color] = [Color("00f0ff"), Color("ff9500"), Color("2b7fff"), Color("e9f4f2")]

static func font() -> Font:
	return PixelFont.font()

static func width(message: String, size: int) -> float:
	return font().get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

## One line with a small drop shadow; point.y is the baseline. Returns the drawn rect.
static func text(canvas: CanvasItem, point: Vector2, message: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Rect2:
	var line_width: float = width(message, size)
	if align == HORIZONTAL_ALIGNMENT_CENTER: point.x -= line_width * 0.5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT: point.x -= line_width
	point = point.round()
	var drop: float = maxf(2.0, floorf(size / 12.0))
	canvas.draw_string(font(), point + Vector2(drop, drop), message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(SHADOW, SHADOW.a * color.a))
	canvas.draw_string(font(), point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
	return Rect2(point.x, point.y - size, line_width, size)

## Pixel font + size + colour on any Control (Label, Button).
static func dress(control: Control, size: int, color: Color = TEXT) -> void:
	control.add_theme_font_override("font", font())
	control.add_theme_font_size_override("font_size", size)
	control.add_theme_color_override("font_color", color)
	control.add_theme_color_override("font_shadow_color", SHADOW)
	control.add_theme_constant_override("shadow_offset_x", maxi(2, size / 12))
	control.add_theme_constant_override("shadow_offset_y", maxi(2, size / 12))

static func label(parent: Control, message: String, rect: Rect2, size: int, color: Color = TEXT, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var item: Label = Label.new()
	item.text = message
	item.horizontal_alignment = align
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.clip_text = true
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dress(item, size, color)
	parent.add_child(item)
	# Size last: Godot 4.3 grows a Label to the minimum size it reports while the
	# default font is still in place and never shrinks it back.
	item.position = rect.position
	item.size = rect.size
	return item

## Text-only menu entry: muted at rest, bright with a small marker when focused.
static func item(parent: Control, message: String, rect: Rect2, action: Callable, size: int = MEDIUM, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> MenuItem:
	var entry: MenuItem = MenuItem.new()
	entry.text = message
	entry.alignment = align
	entry.focus_mode = Control.FOCUS_ALL
	entry.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	dress(entry, size, MUTED)
	for state: String in ["font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		entry.add_theme_color_override(state, TEXT)
	var empty: StyleBoxEmpty = StyleBoxEmpty.new()
	empty.content_margin_left = 28.0 if align == HORIZONTAL_ALIGNMENT_LEFT else 0.0
	for state: String in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		entry.add_theme_stylebox_override(state, empty)
	entry.pressed.connect(action)
	parent.add_child(entry)
	entry.position = rect.position
	entry.size = rect.size
	return entry
