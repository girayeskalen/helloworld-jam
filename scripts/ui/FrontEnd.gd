class_name SiegeFrontEnd
extends CanvasLayer
## A live view of the authored apartment through a rain-streaked window.
## Gameplay is gated explicitly; weather, lighting and the existing score keep going.
signal exit_requested
var game: MainGame
var active: bool = true
var settings_open: bool = false
var launching: bool = false
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

func configure(owner_game: MainGame, preferences_path: String) -> void:
	game = owner_game
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
	buttons["play"] = FieldUI.button(home,"SAHAYA GİR",Rect2(148,560,540,78),start_run,true)
	buttons["settings"] = FieldUI.button(home,"AYARLAR",Rect2(148,654,540,72),show_settings)
	buttons["exit"] = FieldUI.button(home,"ÇIKIŞ",Rect2(148,742,540,72),quit_game)
	FieldUI.label(home,"Gece uzun. Bina ayakta kalmalı.",Rect2(148,431,650,44),25,FieldUI.PAPER)
	FieldUI.label(home,"FIRTINA  /  DEPREM  /  SEL",Rect2(150,493,600,28),13,FieldUI.MUTED)
	FieldUI.label(home,"Yön tuşlarıyla seç  ·  Enter ile başla",Rect2(150,854,650,28),15,FieldUI.MUTED)
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
	FieldUI.label(options,"AYARLAR",Rect2(148,428,600,50),32)
	FieldUI.label(options,"ANA SES",Rect2(150,513,200,28),14,FieldUI.MUTED)
	volume_text = FieldUI.label(options,"",Rect2(577,513,110,28),16,FieldUI.PAPER)
	volume_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	volume = HSlider.new()
	volume.position = Vector2(150,558)
	volume.size = Vector2(538,35)
	volume.min_value = 0
	volume.max_value = SoundManager.MAX_LEVEL
	volume.step = 1
	volume.add_theme_color_override("font_color",FieldUI.AMBER)
	options.add_child(volume)
	volume.value_changed.connect(_volume_changed)
	buttons["mute"] = FieldUI.button(options,"",Rect2(148,620,540,65),game.sound.toggle_mute)
	buttons["fullscreen"] = FieldUI.button(options,"",Rect2(148,703,540,65),_toggle_fullscreen)
	buttons["back"] = FieldUI.button(options,"GERİ",Rect2(148,813,540,65),show_home)
	FieldUI.label(options,"M: ses aç/kapat   ·   − / +: ses   ·   Esc: geri",Rect2(150,912,650,28),15,FieldUI.MUTED)

func open() -> void:
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
	if launching or not active: return
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
	get_viewport().gui_release_focus()

func quit_game() -> void:
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

func _settings_changed() -> void:
	_refresh()
	if not _loading: _save_settings()

func _refresh() -> void:
	volume.set_value_no_signal(game.sound.volume_level)
	volume_text.text = "%d / 10" % game.sound.volume_level
	(buttons["mute"] as Button).text = "SES  /  KAPALI" if game.sound.muted else "SES  /  AÇIK"
	(buttons["fullscreen"] as Button).text = "EKRAN  /  TAM EKRAN" if _fullscreen() else "EKRAN  /  PENCERE"
	board.queue_redraw()

func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_path) != OK: return
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
	var error: Error = config.save(settings_path)
	if error != OK: push_warning("Ayarlar kaydedilemedi: %s" % error_string(error))

func _process(delta: float) -> void:
	if not active: return
	clock += delta
	board.queue_redraw()

func _text(point: Vector2, text: String, font_size: int, color: Color) -> void:
	board.draw_string(ThemeDB.fallback_font,point,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)

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
	# A dark sill and water tracks place the viewer inside, looking into the rain.
	board.draw_rect(Rect2(0,1036,1920,44),Color("080e12"))
	board.draw_line(Vector2(0,1036),Vector2(1920,1036),Color("6b7875",.25),2)
	board.draw_rect(Rect2(1858,0,15,1036),Color("0b1419",.85))
	board.draw_line(Vector2(1857,0),Vector2(1857,1036),Color("697e86",.24),2)
	for i: int in range(28):
		var x: float = 812+fmod(i*137,1010)
		var y: float = fposmod(i*83+clock*(14+i%6*6),1150)-100
		board.draw_line(Vector2(x,y),Vector2(x-3,y+25+i%5*12),Color("a0b9bd",.05),1)
	FieldUI.grain(board,Rect2(110,110,640,800),150)
	board.draw_circle(Vector2(158,157),4,FieldUI.AMBER.darkened(.12+.1*sin(clock*.8)))
	_text(Vector2(178,163),"AFET MÜDAHALE BİRİMİ",15,FieldUI.AMBER)
	_text(Vector2(142,285),"AFET",100,FieldUI.PAPER)
	_text(Vector2(142,388),"KUŞATMASI",90,FieldUI.PAPER)
	# Thin worn paint across a few letter strokes, kept subtle for readability.
	board.draw_line(Vector2(150,270),Vector2(390,270),Color("101a1d",.35),1)
	board.draw_line(Vector2(270,368),Vector2(609,368),Color("101a1d",.3),1)
	_text(Vector2(150,1000),"BİR BİNA. DÖRT AFET DALGASI.",13,FieldUI.MUTED)
	_text(Vector2(1470,1000),"4 KAT   /   16 ODA",14,FieldUI.PAPER)
