class_name SiegeFrontEnd
extends CanvasLayer
## Main menu over the live apartment: primary entries and four section choices on a shaded left
## side, the real building lit by rain and lamps on the right. Gameplay is gated
## explicitly; weather, lighting and the existing score keep going.
signal exit_requested
var game: MainGame
var active: bool = true
var settings_open: bool = false
var launching: bool = false
var selected_section: int = -1
var settings_path: String = "user://siege-settings.cfg"
var screen: Control
var board: Control
var home: Control
var options: Control
var buttons: Dictionary = {}
var volume: HSlider
var volume_text: Label
var clock: float = 0.0
var _loading: bool = true
var _quitting: bool = false
const LEFT: float = 148.0
## One line of theme under the title: preparation is the game.
const TAGLINE: String = "Hazırlık hayat kurtarır"

func configure(owner_game: MainGame, preferences_path: String) -> void:
	game = owner_game
	game.hitstop_enabled = true
	settings_path = preferences_path
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	screen = Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(screen)
	board = Control.new()
	board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.draw.connect(_draw_board)
	screen.add_child(board)
	home = Control.new()
	home.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	home.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(home)
	buttons["play"] = UIStyle.item(home, "Başla", Rect2(LEFT - 28, 536, 460, 52), start_run)
	buttons["settings"] = UIStyle.item(home, "Ayarlar", Rect2(LEFT - 28, 596, 460, 52), show_settings)
	buttons["exit"] = UIStyle.item(home, "Çıkış", Rect2(LEFT - 28, 656, 460, 52), quit_game)
	UIStyle.label(home, "Bölüm seç", Rect2(LEFT, 748, 460, 32), UIStyle.SMALL, UIStyle.MUTED)
	for index: int in range(GameHUD.SECTION_LABELS.size()):
		buttons["section_%d" % index] = UIStyle.item(home, GameHUD.SECTION_LABELS[index], Rect2(LEFT - 28, 790 + index * 42, 460, 38), start_section.bind(index), UIStyle.SMALL)
	_build_settings()
	_load_settings()
	_loading = false
	game.sound.settings_changed.connect(_settings_changed)
	game.pause_menu.add_main_menu_action(open)
	open()

func _build_settings() -> void:
	options = Control.new()
	options.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	options.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(options)
	UIStyle.label(options, "Ses", Rect2(LEFT, 580, 120, 40), UIStyle.MEDIUM, UIStyle.MUTED)
	volume = HSlider.new()
	volume.position = Vector2(LEFT + 128, 586)
	volume.size = Vector2(240, 24)
	volume.min_value = 0
	volume.max_value = SoundManager.MAX_LEVEL
	volume.step = 1
	_dress_slider(volume)
	options.add_child(volume)
	volume.value_changed.connect(_volume_changed)
	volume_text = UIStyle.label(options, "", Rect2(LEFT + 384, 580, 72, 40), UIStyle.MEDIUM, UIStyle.TEXT, HORIZONTAL_ALIGNMENT_RIGHT)
	buttons["mute"] = UIStyle.item(options, "", Rect2(LEFT - 28, 640, 500, 52), game.sound.toggle_mute)
	buttons["fullscreen"] = UIStyle.item(options, "", Rect2(LEFT - 28, 700, 500, 52), _toggle_fullscreen)
	buttons["tutorial"] = UIStyle.item(options, "", Rect2(LEFT - 28, 760, 500, 52), _toggle_tutorial)
	buttons["back"] = UIStyle.item(options, "Geri", Rect2(LEFT - 28, 844, 500, 52), show_home)

## Flat track and a small square knob in the UI palette instead of the stock look.
static func _dress_slider(slider: HSlider) -> void:
	var track: StyleBoxFlat = StyleBoxFlat.new()
	track.bg_color = UIStyle.FAINT
	track.content_margin_top = 2
	track.content_margin_bottom = 2
	var filled: StyleBoxFlat = StyleBoxFlat.new()
	filled.bg_color = UIStyle.TEXT
	filled.content_margin_top = 2
	filled.content_margin_bottom = 2
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", filled)
	slider.add_theme_stylebox_override("grabber_area_highlight", filled)
	var knob: Image = Image.create(10, 18, false, Image.FORMAT_RGBA8)
	knob.fill(UIStyle.TEXT)
	var texture: ImageTexture = ImageTexture.create_from_image(knob)
	for icon: String in ["grabber", "grabber_highlight", "grabber_disabled"]:
		slider.add_theme_icon_override(icon, texture)
	var focus: StyleBoxEmpty = StyleBoxEmpty.new()
	slider.add_theme_stylebox_override("focus", focus)

func open() -> void:
	game.clear_hitstop()
	game.pause_menu.set_open(false)
	game.reset_game()
	active = true
	launching = false
	screen.visible = true
	screen.modulate = Color.WHITE
	game.set_frontend_active(true)
	show_home()

func show_settings() -> void:
	settings_open = true
	home.visible = false
	options.visible = true
	_refresh()
	volume.grab_focus()
	game.sound.play("ui_open")

func show_home() -> void:
	settings_open = false
	home.visible = true
	options.visible = false
	(buttons["play"] as Button).grab_focus()
	board.queue_redraw()

func start_run() -> void:
	_launch(-1)

func start_section(index: int) -> void:
	if index >= 0 and index < DisasterWaveManager.CAMPAIGN.size(): _launch(index)

func _launch(section: int) -> void:
	if launching or not active: return
	selected_section = section
	launching = true
	game.sound.play("ui_confirm")
	var tween: Tween = create_tween()
	tween.tween_property(screen,"modulate:a",0.0,.22)
	tween.tween_callback(_begin_run)

func _begin_run() -> void:
	game.reset_game()
	active = false
	launching = false
	screen.visible = false
	game.set_frontend_active(false)
	if selected_section >= 0: game.select_section(selected_section)
	get_viewport().gui_release_focus()

func quit_game() -> void:
	game.clear_hitstop()
	if _quitting: return
	_quitting = true
	_save_settings()
	exit_requested.emit()
	# Let the mixer consume SoundManager's stop/free commands before engine shutdown.
	# Especially important for 4.3's headless Dummy audio driver.
	_finish_exit(game,get_tree())

static func _finish_exit(current_game: MainGame, tree: SceneTree) -> void:
	# A static coroutine survives the UI being freed. Use a real audio-driver block,
	# since --fixed-fps can run simulated timers much faster than the mixer thread.
	current_game.queue_free()
	await tree.process_frame
	await tree.process_frame
	OS.delay_msec(80)
	tree.quit()

func _input(event: InputEvent) -> void:
	if not active or not event is InputEventKey or not event.is_pressed() or event.is_echo(): return
	var key: InputEventKey = event as InputEventKey
	if launching:
		get_viewport().set_input_as_handled()
		return
	if key.physical_keycode == KEY_ESCAPE:
		if settings_open: show_home()
	elif key.is_action_pressed("mute_toggle"):
		game.sound.toggle_mute()
	elif PauseMenu._volume_step(key) != 0:
		game.sound.change_volume(PauseMenu._volume_step(key))
	elif key.physical_keycode == KEY_F11:
		_toggle_fullscreen()
	elif not settings_open and key.physical_keycode >= KEY_1 and key.physical_keycode <= KEY_4:
		start_section(key.physical_keycode - KEY_1)
	else: return
	get_viewport().set_input_as_handled()

func _volume_changed(value: float) -> void:
	game.sound.change_volume(int(value)-game.sound.volume_level)

func _fullscreen() -> bool:
	return DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN,DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]

func _toggle_fullscreen() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if _fullscreen() else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_save_settings()
	_refresh()

## The first preparation and disaster teach by doing; on by default, remembered.
func _toggle_tutorial() -> void:
	game.tutorial.set_enabled(not game.tutorial.enabled)
	game.sound.play("ui_toggle")
	_save_settings()
	_refresh()

func _settings_changed() -> void:
	_refresh()
	if not _loading: _save_settings()

func _refresh() -> void:
	volume.set_value_no_signal(game.sound.volume_level)
	volume_text.text = str(game.sound.volume_level)
	(buttons["mute"] as Button).text = "Ses kapalı" if game.sound.muted else "Ses açık"
	(buttons["fullscreen"] as Button).text = "Tam ekran" if _fullscreen() else "Pencere"
	(buttons["tutorial"] as Button).text = "Öğretici açık" if game.tutorial.enabled else "Öğretici kapalı"
	board.queue_redraw()

func _load_settings() -> void:
	game.tutorial.enabled = true
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_path) != OK: return
	game.tutorial.enabled = bool(config.get_value("game","tutorial",true))
	var target: int = clampi(int(config.get_value("audio","volume",8)),0,SoundManager.MAX_LEVEL)
	if target != game.sound.volume_level: game.sound.change_volume(target-game.sound.volume_level)
	if bool(config.get_value("audio","muted",false)) != game.sound.muted: game.sound.toggle_mute()
	if DisplayServer.get_name() != "headless" and config.has_section_key("display","fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if config.get_value("display","fullscreen") else DisplayServer.WINDOW_MODE_WINDOWED)

func _save_settings() -> void:
	if _loading: return
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio","volume",game.sound.volume_level)
	config.set_value("audio","muted",game.sound.muted)
	config.set_value("display","fullscreen",_fullscreen())
	config.set_value("game","tutorial",game.tutorial.enabled)
	var error: Error = config.save(settings_path)
	if error != OK: push_warning("Ayarlar kaydedilemedi: %s" % error_string(error))

func _process(delta: float) -> void:
	if not active: return
	clock += delta
	board.queue_redraw()

func _draw_board() -> void:
	# The left is painted shadow; the right keeps the real apartment's depth.
	board.draw_rect(Rect2(0,0,1920,1080),Color("080f14",.20))
	for i: int in range(48):
		var x: float = i*30.0
		var opacity: float = lerpf(.98,0.0,smoothstep(490,1440,x))
		board.draw_rect(Rect2(x,0,31,1080),Color(.025,.042,.049,opacity))
	for i: int in range(14):
		board.draw_rect(Rect2(0,i*12,1920,12),Color("050b10",.65*(1.0-i/14.0)))
		board.draw_rect(Rect2(0,1068-i*12,1920,12),Color("050b10",.8*(1.0-i/14.0)))
	# Faint rain on the glass between viewer and building.
	for i: int in range(28):
		var x: float = 812+fmod(i*137,1010)
		var y: float = fposmod(i*83+clock*(14+i%6*6),1150)-100
		board.draw_line(Vector2(x,y),Vector2(x-3,y+25+i%5*12),Color("a0b9bd",.05),1)
	UIStyle.text(board, Vector2(LEFT, 392), "AFET", UIStyle.TITLE, UIStyle.TEXT)
	UIStyle.text(board, Vector2(LEFT, 484), "KUŞATMASI", UIStyle.TITLE, UIStyle.TEXT)
	if settings_open:
		UIStyle.text(board, Vector2(LEFT, 552), "Ayarlar", UIStyle.MEDIUM, UIStyle.MUTED)
	else:
		UIStyle.text(board, Vector2(LEFT, 522), TAGLINE, UIStyle.SMALL, UIStyle.MUTED)
