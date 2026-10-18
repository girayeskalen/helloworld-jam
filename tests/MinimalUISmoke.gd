extends SceneTree
## Minimal UI: no words during play except the boss name and kit counts, word-free
## world cues (repair diamond, E key, safe-floor frame), one pixel font everywhere,
## short normal-case menus and cards, and native 1920x1080 captures of every screen.
var game: MainGame
var checks: int = 0
var failures: int = 0
var capture_dir: String = ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): capture_dir = argument.trim_prefix("--capture=")
	if capture_dir != "" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		root.size = Vector2i(1920, 1080)
		root.unfocusable = true
		root.mouse_passthrough = true
	game = (load("res://scenes/MainGame.tscn") as PackedScene).instantiate() as MainGame
	(game.get_node("DisasterWaveManager") as DisasterWaveManager).autoplay = false
	root.add_child(game)
	for node: Node in [game.loot, game.mechanics]: node.set_physics_process(false)
	await _frames(30)
	_check(UIStyle.font() == PixelFont.font() and PixelFont.font().get_height(UIStyle.SMALL) == UIStyle.SMALL, "The whole UI uses the game's own runtime pixel font")
	var turkish: bool = PixelFont.supports("AFET KUŞATMASI ÇĞİÖŞÜ çğıöşü 0123456789 .,:!?-+/%()•")
	_check(turkish and PixelFont.font().get_string_size("İ", HORIZONTAL_ALIGNMENT_LEFT, -1, UIStyle.SMALL).x == PixelFont.font().get_string_size("i", HORIZONTAL_ALIGNMENT_LEFT, -1, UIStyle.SMALL).x, "Turkish capitals have glyphs and lowercase input renders as the matching capital")
	await _preparation()
	await _fight()
	await _cues()
	await _menus()
	await _outcomes()
	print("MINIMAL_UI_RESULT checks=%d failures=%d" % [checks, failures])
	game.queue_free()
	await _frames(2)
	OS.delay_msec(80)
	quit(0 if failures == 0 else 1)

func _battle(mode: int) -> DisasterWaveManager:
	game.reset_game()
	var w: DisasterWaveManager = game.waves
	w.autoplay = false
	w.start_siege(mode as DisasterWaveManager.Mode, true)
	w.advance_wave(w.intro_duration())
	game.building.pacing_enabled = false
	game.telegraphs.clear()
	game.projectiles.clear()
	return w

## Every HUD string must be the boss name or a plain kit count.
func _hud_words_ok(boss: String) -> bool:
	for text: String in game.hud.drawn_texts:
		if text != boss and not text.is_valid_int(): return false
	return true

func _preparation() -> void:
	game.reset_game()
	await _rendered()
	var hud: GameHUD = game.hud
	var prep_words: bool = true
	for text: String in hud.drawn_texts: prep_words = prep_words and (text == game.waves.boss_name() or text == game.tutorial.objective_text or text == " · " or GameHUD.SECTION_LABELS.has(text))
	_check(prep_words and hud.drawn_texts.size() == 9 and game.tutorial.objective_text.begins_with("Hazırlık"), "Preparation HUD shows the coming boss, section shortcuts and one objective line (%s)" % ", ".join(hud.drawn_texts))
	await _save("hud-preparation.png")
	Input.action_press(&"controls_help")
	await _rendered()
	var rows: bool = hud.drawn_texts.has("SHIFT") and hud.drawn_texts.has("Takla")
	for text: String in hud.drawn_texts: rows = rows and (text == game.tutorial.objective_text or (text.split(" ", false).size() <= 2 and PixelFont.supports(text)))
	_check(rows, "Holding Tab/H shows a compact key list of one- or two-word actions")
	await _save("hud-help.png")
	Input.action_release(&"controls_help")
	await _rendered()
	_check(not hud.drawn_texts.has("Takla"), "Releasing Tab/H hides the key list")

func _fight() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM)
	var b: ApartmentBuilding = game.building
	var hud: GameHUD = game.hud
	game.loot.column_kits = 2
	game.loot.barricade_kits = 1
	b.rooms[5].apply_damage(40)
	b.rooms[10].apply_damage(80)
	game.player.health = 64
	game.storm.plan_pattern(w, 0, game.player.current_floor)
	game.telegraphs._physics_process(0.3)
	await _rendered()
	_check(_hud_words_ok("FIRTINA") and hud.drawn_texts.has("FIRTINA") and hud.drawn_texts.has("2") and hud.drawn_texts.has("1"), "Siege HUD words are only the boss name and kit counts (%s)" % ", ".join(hud.drawn_texts))
	var noisy: bool = false
	for text: String in hud.drawn_texts: noisy = noisy or text.contains("%") or text.contains("/") or text.contains("[") or text.ends_with("s")
	_check(not noisy, "No percentages, x/y counters, seconds or bracketed key hints in the HUD")
	_check(hud.room_color(b.rooms[0]) == GameHUD.ROOM_INTACT and hud.room_color(b.rooms[5]) == UIStyle.ALERT and hud.room_color(b.rooms[10]).r > 0.9, "Mini-map colours rooms by state: intact, damaged, critical")
	_check(game.labels.texts_drawn == 0 and game.labels.repair_markers == 2, "World cues: two repair diamonds and no words while hazards are telegraphed")
	_check(hud.slot_rect(2).end.x < 220.0 and GameHUD.BOSS_BAR.get_center().x == 960.0 and GameHUD.BOSS_BAR.size.y <= 8.0, "Kit icons sit in the corner; the boss/time line is thin and centred")
	await _save("hud-fight.png")
	game.feedback.show_dodge(game.player.global_position)
	game.feedback.show_graze(game.player.global_position + Vector2(20, -40))
	await _rendered()
	_check(game.labels.texts_drawn == 0, "DODGE and graze feedback are sparks only, no floating words")
	game.loot.items.clear()
	b.rooms[10].apply_damage(-1.0)
	b.rooms[10].hp = 0.0
	b.rooms[10]._refresh_state(true)
	await _rendered()
	_check(hud.room_color(b.rooms[10]) == GameHUD.ROOM_GONE, "A collapsed room turns dark on the mini-map")

func _cues() -> void:
	var w: DisasterWaveManager = _battle(DisasterWaveManager.Mode.STORM)
	var b: ApartmentBuilding = game.building
	var room: RoomDiorama = b.rooms[1]
	room.apply_damage(40)
	game.loot.column_kits = 1
	game.player.current_floor = room.floor_index
	game.player.global_position = room.global_position + Vector2(200, 199.5)
	await _rendered()
	_check(game.labels.texts_drawn == 1 and game.labels.repair_markers == 1, "Standing in a damaged room with a kit shows only the E key over the player")
	await _save("hud-repair-key.png")
	game.loot.column_kits = 0
	await _rendered()
	_check(game.labels.texts_drawn == 0, "Without a usable kit the E key disappears")
	room.repair(100, true)
	game.storm.plan_pattern(w, 1, game.player.current_floor)
	await _rendered()
	_check(game.labels.safe_frames == 1 and game.labels.texts_drawn == 0, "Safe-floor roulette frames the open floor in green, without a label")
	await _save("hud-roulette.png")
	game.telegraphs.clear()

func _menus() -> void:
	_battle(DisasterWaveManager.Mode.EARTHQUAKE)
	await _rendered()
	var pause: PauseMenu = game.pause_menu
	pause.set_open(true)
	await _rendered()
	var short: bool = true
	for id: String in pause.buttons:
		var entry: Button = pause.buttons[id]
		short = short and entry.text.split(" ", false).size() <= 2 and entry.get_theme_font("font") == UIStyle.font() and PixelFont.supports(entry.text) and not entry.text.contains("[")
	_check(short and pause.buttons.has("resume") and pause.buttons.has("restart") and pause.buttons.has("mute"), "Pause entries are short pixel-font words without key brackets")
	await _save("pause.png")
	pause.set_open(false)
	game.upgrades.reset()
	game.waves.finish_wave()
	game.waves.advance_wave(DisasterWaveManager.OUTRO_DURATION)
	await _frames(30)
	var overlay: UpgradeOverlay = game.upgrade_overlay
	var cards_ok: bool = overlay.visible and overlay.cards.size() == 3
	for card: Button in overlay.cards:
		var labels: Array[Label] = []
		for child: Node in card.get_children():
			if child is Label: labels.append(child as Label)
		cards_ok = cards_ok and labels.size() == 3 and labels[1].text.split(" ", false).size() <= 7
		for label: Label in labels:
			cards_ok = cards_ok and label.position.x + label.size.x <= card.size.x and label.position.y + label.size.y <= card.size.y and PixelFont.supports(label.text)
			if capture_dir != "": cards_ok = cards_ok and label.get_visible_line_count() == label.get_line_count()
	_check(cards_ok, "Each card has only a name, one short effect line and its key, all unclipped")
	await _save("cards.png")
	game.upgrades.choose(0)
	game.reset_game()
	game.waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	game.waves.advance_wave(1.1)
	await _rendered()
	_check(game.hud.drawn_texts.is_empty(), "During the boss intro only the cinematic title is on screen")
	await _save("boss-intro.png")

func _outcomes() -> void:
	_battle(DisasterWaveManager.Mode.FLOOD)
	game.waves.fail_siege(DisasterWaveManager.FailReason.BUILDING)
	await _rendered()
	var defeat: PackedStringArray = game.hud.drawn_texts
	_check(defeat.size() >= 2 and defeat.size() <= 8 and defeat[0] == "Bina çöktü" and defeat[-1] == "R  Bölümü tekrar dene", "Defeat shows one title, at most three karne lines and one hint (%s)" % ", ".join(defeat))
	await _save("defeat.png")
	game.reset_game()
	game.waves.victory = true
	game.waves.state = DisasterWaveManager.State.VICTORY
	await _rendered()
	var won: PackedStringArray = game.hud.drawn_texts
	_check(won.size() >= 2 and won.size() <= 8 and won[0] == "Hayatta kaldın" and won[-1] == "R  Yeni oyun", "Victory shows one title, the karne and one hint")
	await _save("victory.png")
	game.reset_game()

func _save(filename: String) -> void:
	if capture_dir == "" or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png(capture_dir.path_join(filename)) == OK, "Rendered " + filename)

func _rendered() -> void:
	for tick: int in range(3): await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

func _frames(count: int) -> void:
	for tick: int in range(count): await physics_frame

func _check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)
