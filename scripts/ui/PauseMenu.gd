class_name PauseMenu
extends CanvasLayer
## ESC / P pauses the whole tree. This layer keeps PROCESS_MODE_ALWAYS so its
## entries, M mute and -/+ volume work while everything else is frozen.
## Layout: one centred column (continue, restart, main menu, sound) and a two-line
## key reminder at the bottom. No panel, icons or explanatory sentences.

const DIM: Color = Color(0.02, 0.03, 0.04, 0.82)
const COLUMN: Rect2 = Rect2(710, 392, 500, 48)
const STEP: float = 56.0
const METER: Rect2 = Rect2(853, 638, 214, 14)
const CONTROLS: Array = [
	[["A D", "Koş"], ["W", "Zıpla"], ["W W", "Üst kat"], ["S", "Alt kat"], ["SHIFT", "Takla"]],
	[["C", "Çök"], ["E", "Kullan"], ["F", "Başlat"], ["R", "Yeniden"], ["M", "Ses"], ["1-4", "Bölüm"]],
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
	board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.draw.connect(_draw_board)
	screen.add_child(board)
	_entry("resume", "Devam", 0, resume)
	_entry("restart", "Yeniden başla", 1, restart)
	_entry("mute", "Ses açık", 3, _toggle_mute)
	buttons["quieter"] = UIStyle.item(board, "-", Rect2(METER.position.x - 56, METER.get_center().y - 22, 44, 44), _change_volume.bind(-1), UIStyle.MEDIUM, HORIZONTAL_ALIGNMENT_CENTER)
	buttons["louder"] = UIStyle.item(board, "+", Rect2(METER.end.x + 12, METER.get_center().y - 22, 44, 44), _change_volume.bind(1), UIStyle.MEDIUM, HORIZONTAL_ALIGNMENT_CENTER)
	sound.settings_changed.connect(_refresh)
	visible = false
	_refresh()

func _entry(id: String, text: String, row: int, action: Callable) -> void:
	var rect: Rect2 = Rect2(COLUMN.position + Vector2(0, row * STEP), COLUMN.size)
	var entry: MenuItem = UIStyle.item(board, text, rect, action, UIStyle.MEDIUM, HORIZONTAL_ALIGNMENT_CENTER)
	entry.name = "Button_" + id
	buttons[id] = entry

func add_main_menu_action(action: Callable) -> void:
	_entry("home", "Ana menü", 2, action)

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
	if value: game.clear_hitstop()
	visible = value
	get_tree().paused = value
	sound.set_paused_view(value)
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
	(buttons["mute"] as Button).text = "Ses kapalı" if sound.muted else "Ses açık"
	board.queue_redraw()

# ----------------------------------------------------------------- draw ----

func _draw_board() -> void:
	UIStyle.text(board, Vector2(960, 344), "Duraklatıldı", UIStyle.LARGE, UIStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	for s: int in range(SoundManager.MAX_LEVEL):
		var cell: Rect2 = Rect2(METER.position.x + s * 22.0, METER.position.y, 16, METER.size.y)
		var lit: bool = s < sound.volume_level and not sound.muted
		board.draw_rect(cell, UIStyle.TEXT if lit else UIStyle.FAINT)
	for line: int in range(CONTROLS.size()):
		_controls_line(CONTROLS[line], 872.0 + line * 36.0)

## "KEY action   KEY action ..." centred, keys bright and actions muted.
func _controls_line(pairs: Array, y: float) -> void:
	var gap: float = 48.0
	var total: float = -gap
	for pair: Array in pairs:
		total += UIStyle.width(String(pair[0]) + " ", UIStyle.SMALL) + UIStyle.width(String(pair[1]), UIStyle.SMALL) + gap
	var x: float = 960.0 - total * 0.5
	for pair: Array in pairs:
		var key: String = String(pair[0]) + " "
		UIStyle.text(board, Vector2(x, y), key, UIStyle.SMALL, UIStyle.TEXT)
		x += UIStyle.width(key, UIStyle.SMALL)
		UIStyle.text(board, Vector2(x, y), String(pair[1]), UIStyle.SMALL, UIStyle.MUTED)
		x += UIStyle.width(String(pair[1]), UIStyle.SMALL) + gap
