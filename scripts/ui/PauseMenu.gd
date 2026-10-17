class_name PauseMenu
extends CanvasLayer
## ESC / P pauses the whole tree. This layer keeps PROCESS_MODE_ALWAYS so its
## buttons, M mute and -/+ volume work while everything else is frozen.

const INK: Color = Color("111518")
const DIM: Color = Color(0.043, 0.055, 0.078, 0.78)
const PANEL: Rect2 = Rect2(400, 112, 1120, 856)
## [icon, keycaps, description]
const ROWS: Array = [
	["run", ["A / D", "← / →"], "SAĞA / SOLA KOŞ"],
	["jump", ["W", "↑"], "ZIPLA · HAVADA 2x W: ÜST KATA ÇIK"],
	["down", ["S", "↓"], "ALT KATA İN · ZEMİN KATTA HAVADA: HIZLI İNİŞ"],
	["dash", ["SHIFT", "SPACE", "SAĞ TIK"], "8 YÖNLÜ TAKLA · DOKUNULMAZ KAÇIŞ"],
	["repair", ["E"], "HASARLI ODAYI ONAR [!] · HAZIRLIKTA GÜÇLENDİR"],
	["start", ["F"], "HAZIRLIĞI GEÇ · DALGAYI HEMEN BAŞLAT"],
	["boss", ["1 – 4"], "1 FIRTINA · 2 DEPREM · 3 SEL · 4 FİNAL"],
	["help", ["TAB", "H"], "KÜÇÜK KONTROL KARTI (BASILI TUT)"],
	["restart", ["R"], "YENİDEN BAŞLAT"],
	["sound", ["M"], "SESİ KAPAT / AÇ"],
	["pause", ["ESC", "P"], "DEVAM ET"],
]

var game: MainGame
var sound: SoundManager
var is_open: bool = false
var screen: Control
var board: Control
var buttons: Dictionary = {}

func configure(owner_game: MainGame) -> void:
	game = owner_game
	sound = game.sound
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	screen = Control.new()
	screen.name = "PauseScreen"
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(screen)
	var dim: ColorRect = ColorRect.new()
	dim.color = DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(dim)
	board = Control.new()
	board.name = "PausePanel"
	board.position = PANEL.position
	board.size = PANEL.size
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.draw.connect(_draw_board)
	screen.add_child(board)
	var y: float = PANEL.size.y - 104
	_button("resume", "[ESC / P] DEVAM ET", Rect2(44, y, 262, 58), resume)
	_button("mute", "[M] SES: AÇIK", Rect2(322, y, 230, 58), _toggle_mute)
	_button("quieter", "-", Rect2(568, y, 58, 58), _change_volume.bind(-1))
	_button("louder", "+", Rect2(830, y, 58, 58), _change_volume.bind(1))
	_button("restart", "[R] YENİDEN BAŞLAT", Rect2(904, y, 172, 58), restart)
	(buttons["restart"] as Button).add_theme_font_size_override("font_size", 15)
	sound.settings_changed.connect(_refresh)
	visible = false
	_refresh()

func _button(id: String, text: String, rect: Rect2, action: Callable) -> void:
	var button: Button = Button.new()
	button.name = "Button_" + id
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 18)
	for state_name: String in ["normal", "hover", "pressed", "focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("18242a") if state_name == "normal" else (Color("2c4249") if state_name == "pressed" else Color("22343b"))
		style.border_color = INK if state_name == "normal" else CelArt.GOLD
		style.set_border_width_all(3)
		style.set_corner_radius_all(2)
		style.shadow_color = Color(0, 0, 0, 0.45)
		style.shadow_size = 6
		button.add_theme_stylebox_override(state_name, style)
	for color_name: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		button.add_theme_color_override(color_name, CelArt.PAPER if color_name == "font_color" else Color("ffe2a8"))
	button.pressed.connect(action)
	board.add_child(button)
	buttons[id] = button

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: InputEventKey = event as InputEventKey
	if key.is_action_pressed(&"pause_toggle"):
		toggle()
	elif key.is_action_pressed(&"mute_toggle"):
		_toggle_mute()
	elif _volume_step(key) != 0:
		_change_volume(_volume_step(key))
	elif is_open and key.is_action_pressed(&"reset_player"):
		restart()
	else:
		return
	get_viewport().set_input_as_handled()

## -/+ by the typed character (any keyboard layout) or the numpad keys.
static func _volume_step(key: InputEventKey) -> int:
	if key.physical_keycode == KEY_KP_ADD or key.unicode in [43, 61]: return 1
	if key.physical_keycode == KEY_KP_SUBTRACT or key.unicode in [45, 95]: return -1
	return 0

func toggle() -> void:
	set_open(not is_open)

func set_open(value: bool) -> void:
	if is_open == value: return
	is_open = value
	visible = value
	get_tree().paused = value
	sound.set_paused_view(value)
	if game.intro.active(): game.intro.video.paused = value or game.intro.state == IntroOverlay.State.FADING
	_refresh()
	if value: (buttons["resume"] as Button).grab_focus()

func resume() -> void:
	set_open(false)

func restart() -> void:
	set_open(false)
	game.reset_game()

func _toggle_mute() -> void:
	sound.toggle_mute()

func _change_volume(step: int) -> void:
	sound.change_volume(step)

func _refresh() -> void:
	if buttons.is_empty(): return
	(buttons["mute"] as Button).text = "[M] SES: KAPALI" if sound.muted else "[M] SES: AÇIK"
	board.queue_redraw()

# ----------------------------------------------------------------- draw ----

func _draw_board() -> void:
	var size: Vector2 = PANEL.size
	board.draw_rect(Rect2(Vector2(8, 10), size), Color(0, 0, 0, 0.45))
	board.draw_rect(Rect2(Vector2.ZERO, size), Color("0f1519"))
	board.draw_rect(Rect2(Vector2(6, 6), size - Vector2(12, 12)), Color("2b3a40"), false, 2.0)
	board.draw_rect(Rect2(Vector2.ZERO, size), INK, false, 5.0)
	board.draw_rect(Rect2(Vector2(5, 5), Vector2(size.x - 10, 6)), Color(CelArt.GOLD, 0.8))
	_text(Vector2(44, 76), "OYUN DURAKLATILDI", 44, CelArt.PAPER)
	_text(Vector2(44 + _width("OYUN DURAKLATILDI", 44) + 18, 76), "(PAUSE)", 22, Color("8fa69b"))
	_text(Vector2(44, 124), "KONTROLLER & TUŞ REHBERİ", 16, CelArt.GOLD)
	board.draw_line(Vector2(44, 136), Vector2(size.x - 44, 136), Color("2b3a40"), 2.0)
	for i: int in range(ROWS.size()):
		var row: Array = ROWS[i]
		var y: float = 172 + i * 50
		if i % 2 == 0: board.draw_rect(Rect2(36, y - 24, size.x - 72, 46), Color(1, 1, 1, 0.025))
		_icon(String(row[0]), Vector2(64, y))
		var x: float = 92.0
		for cap: String in row[1]:
			x += _keycap(Vector2(x, y), cap) + 8.0
		_text(Vector2(468, y + 7), String(row[2]), 18, Color("d5dfd9"))
	var actions_y: float = size.y - 140
	board.draw_line(Vector2(44, actions_y - 10), Vector2(size.x - 44, actions_y - 10), Color("2b3a40"), 2.0)
	_text(Vector2(44, actions_y + 16), "SES & AKSİYONLAR", 16, CelArt.GOLD)
	_text(Vector2(size.x - 44 - _width("Süre, saldırılar ve oyuncu donar · ses ayarı bu oturum boyunca geçerli", 13), actions_y + 16), "Süre, saldırılar ve oyuncu donar · ses ayarı bu oturum boyunca geçerli", 13, Color("7f948f"))
	# Volume meter between the − and + buttons: ten segments, INK framed.
	var meter: Rect2 = Rect2(636, size.y - 104, 184, 58)
	board.draw_rect(meter, Color("121a1e"))
	board.draw_rect(meter, INK, false, 3.0)
	for s: int in range(SoundManager.MAX_LEVEL):
		var cell: Rect2 = Rect2(meter.position.x + 10 + s * 16.4, meter.position.y + 30, 12, 18)
		var lit: bool = s < sound.volume_level and not sound.muted
		board.draw_rect(cell, Color("4fd6c4") if lit else Color("26333a"))
	var label: String = "SES KAPALI" if sound.muted else "SES %%%d" % (sound.volume_level * 10)
	_text(Vector2(meter.get_center().x - _width(label, 14) * 0.5, meter.position.y + 22), label, 14, Color("ff8a7a") if sound.muted else CelArt.PAPER)

func _keycap(origin: Vector2, text: String) -> float:
	var width: float = maxf(42.0, _width(text, 16) + 24.0)
	var cap: Rect2 = Rect2(origin + Vector2(0, -18), Vector2(width, 34))
	board.draw_rect(Rect2(cap.position + Vector2(0, 4), cap.size), Color(0, 0, 0, 0.5))
	board.draw_rect(cap, Color("27323a"))
	board.draw_rect(Rect2(cap.position + Vector2(3, 3), Vector2(cap.size.x - 6, 3)), Color("3f4d57"))
	board.draw_rect(cap, INK, false, 3.0)
	_text(Vector2(cap.position.x + (width - _width(text, 16)) * 0.5, cap.position.y + 24), text, 16, Color("ffd36b"))
	return width

## Tiny pixel glyphs that tag each row.
func _icon(kind: String, c: Vector2) -> void:
	var color: Color = Color("8fd8ff")
	match kind:
		"run":
			board.draw_polyline(PackedVector2Array([c + Vector2(-10, 0), c + Vector2(10, 0)]), color, 3.0)
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(13, 0), c + Vector2(6, -6), c + Vector2(6, 6)]), color)
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(-13, 0), c + Vector2(-6, -6), c + Vector2(-6, 6)]), color)
		"jump":
			for k: int in range(2): board.draw_polyline(PackedVector2Array([c + Vector2(-8, 6 - k * 8), c + Vector2(0, -2 - k * 8), c + Vector2(8, 6 - k * 8)]), color, 3.0)
		"down":
			board.draw_polyline(PackedVector2Array([c + Vector2(-8, -4), c + Vector2(0, 4), c + Vector2(8, -4)]), color, 3.0)
			board.draw_line(c + Vector2(-10, 9), c + Vector2(10, 9), color, 3.0)
		"dash":
			for k: int in range(3): board.draw_line(c + Vector2(-12 + k * 3, -6 + k * 6), c + Vector2(4 + k * 3, -6 + k * 6), Color(color, 1.0 - k * 0.25), 3.0)
		"repair":
			color = CelArt.GOLD
			board.draw_line(c + Vector2(-8, 8), c + Vector2(4, -4), color, 4.0)
			board.draw_arc(c + Vector2(6, -6), 5.0, PI * 0.2, PI * 1.8, 10, color, 3.0)
		"start":
			color = Color("4fd6c4")
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(-6, -9), c + Vector2(9, 0), c + Vector2(-6, 9)]), color)
		"boss":
			color = Color("ff9160")
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(-10, 4), c + Vector2(-7, -8), c + Vector2(-2, 0), c + Vector2(0, -10), c + Vector2(2, 0), c + Vector2(7, -8), c + Vector2(10, 4)]), color)
			board.draw_rect(Rect2(c + Vector2(-10, 5), Vector2(20, 4)), color)
		"help":
			board.draw_rect(Rect2(c + Vector2(-9, -8), Vector2(18, 16)), color, false, 2.5)
			board.draw_line(c + Vector2(-5, -2), c + Vector2(5, -2), color, 2.0)
			board.draw_line(c + Vector2(-5, 3), c + Vector2(3, 3), color, 2.0)
		"restart":
			board.draw_arc(c, 8.0, PI * 0.3, PI * 1.9, 14, color, 3.0)
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(8, -6), c + Vector2(11, 2), c + Vector2(3, 0)]), color)
		"sound":
			board.draw_colored_polygon(PackedVector2Array([c + Vector2(-10, -4), c + Vector2(-5, -4), c + Vector2(1, -9), c + Vector2(1, 9), c + Vector2(-5, 4), c + Vector2(-10, 4)]), color)
			board.draw_arc(c + Vector2(2, 0), 7.0, -PI * 0.3, PI * 0.3, 6, color, 2.0)
		"pause":
			board.draw_rect(Rect2(c + Vector2(-7, -8), Vector2(5, 16)), color)
			board.draw_rect(Rect2(c + Vector2(2, -8), Vector2(5, 16)), color)

func _text(point: Vector2, message: String, size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	board.draw_string_outline(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, maxi(4, size / 5), INK)
	board.draw_string(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

static func _width(message: String, size: int) -> float:
	return ThemeDB.fallback_font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
