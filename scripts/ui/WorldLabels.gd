class_name WorldLabels
extends Node2D
## Screen-space text for world events: evacuation/splinter/vortex warnings, the gust
## countdown, boss attack names and DODGE!. The world itself renders at low resolution;
## text is drawn here at full resolution so it stays readable, with a dark outline.

var game: MainGame
## Labels drawn in the last frame (used by tests).
var drawn: int = 0
var repair_markers: int = 0
var feedback_rects: Array[Rect2] = []
const GRAZE_TEXT: String = "SIYRILDI! +ENERJİ"
const SAFE_FLOOR_COLOR: Color = Color("7dffb2")

func configure(owner_game: MainGame) -> void:
	game = owner_game

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	drawn = 0
	repair_markers = 0
	feedback_rects.clear()
	if game == null:
		return
	var telegraphs: TelegraphSystem = game.telegraphs
	for attack: HazardAttack in telegraphs.pending:
		if attack.warning_delay > 0.0: continue
		if attack.kind == HazardAttack.Kind.ROCKFALL: continue
		if attack.is_area():
			var message: String = "GİRDAP ÇEKİMİ" if attack.source == 2 else "TERMAL VAKUM"
			if attack.kind == HazardAttack.Kind.STEAM_COLUMN: message = "BUHAR SÜTUNU"
			if attack.kind == HazardAttack.Kind.FLOOD_ZONE: message = "TAŞKIN · ZIPLA / ÜST KATA ÇIK"
			if attack.kind == HazardAttack.Kind.FIRE_ZONE: message = "ZEMİN ALEVİ · ZIPLA / ODADAN ÇIK"
			_text(attack.area.get_center()+Vector2(-140,-35),message,18,TelegraphSystem.warning_color(attack))
		if attack.pattern == HazardAttack.Pattern.QUADRANT_SEAL and attack.lead and attack.source == 0:
			_text(Vector2(game.building.center_x() - 150, attack.origin.y - 40), "ELEMENTAL MÜHÜR · %.1f sn" % maxf(0.0, attack.warning_duration - attack.warning_elapsed), 20, Color("ffe2b0"))
		if attack.pattern == HazardAttack.Pattern.EMBER_DETONATION and attack.lead:
			_text(attack.origin+Vector2(-65,-43),"KOR · %.1f sn" % maxf(0.0,attack.warning_duration-attack.warning_elapsed),17,Color("ffbc6a"))
		var color: Color = TelegraphSystem.warning_color(attack)
		match attack.pattern:
			HazardAttack.Pattern.FULL_ROW:
				var left: float = minf(attack.origin.x, attack.point_at(attack.lifetime).x)
				var width: float = absf(attack.velocity.x * attack.lifetime)
				var remaining: float = maxf(0.0, attack.warning_duration - attack.warning_elapsed)
				_text(Vector2(left + width * 0.30, attack.floor_y - attack.row_height + 44), "KAT %02d  ·  TAHLİYE  ·  %.1f sn" % [attack.floor_index, remaining], 22, color)
			HazardAttack.Pattern.SPLINTER:
				_text(attack.origin + Vector2(-48, -30), "SEKEN ENKAZ", 15, color)
			HazardAttack.Pattern.VORTEX:
				if attack.lead:
					_text(attack.origin + Vector2(-34, -112), "GİRDAP", 18, color)
			HazardAttack.Pattern.SAFE_FLOOR:
				if attack.lead:
					var safe: int = int(String(attack.room_source).get_slice("_", 1))
					var arrow: String = "▲" if safe > game.player.current_floor else ("▼" if safe < game.player.current_floor else "●")
					_plate(Vector2(game.building.center_x(), game.building.floor_y(safe) - 110), "%s GÜVENLİ KAT %s" % [arrow, arrow], 20, SAFE_FLOOR_COLOR)
	if telegraphs.gust_warning_left > 0.0:
		var area: Rect2 = telegraphs.gust_area
		var arrow: String = "→" if telegraphs.gust_direction > 0 else "←"
		_plate(Vector2(area.position.x + area.size.x * 0.5, area.position.y - 120), "RÜZGÂR KÜKREMESİ %s  %.1f sn" % [arrow, telegraphs.gust_warning_left], 24, TelegraphSystem.GUST)
	for boss: DisasterBoss in game.waves.bosses():
		if boss.visible and boss.is_charging() and boss.pattern_label != "":
			var accent: Color = [TelegraphSystem.STORM_WARNING,TelegraphSystem.QUAKE_WARNING,Color("55e2db"),Color("c4f4ed")][boss.kind]
			# The titan's attack plate sits under its head, inside the top floor band.
			var anchor: Vector2 = Vector2(game.building.center_x(), game.building.global_position.y + 60) if boss.kind == DisasterBoss.Kind.CATACLYSM else Vector2(boss.global_position.x, maxf(240.0,boss.global_position.y-610*absf(boss.scale.y)))
			_plate(anchor, boss.pattern_label, 18, accent)
	_draw_action_hint()
	for dodge: Dictionary in game.feedback.texts:
		var alpha: float = minf(1.0, float(dodge["life"]) * 3.0)
		_text(Vector2(dodge["position"]), "DODGE!", 28, Color(Color("f5d986"), alpha))
	for graze: Dictionary in game.feedback.grazes:
		var fade: float = minf(1.0, float(graze["life"]) * 4.0)
		_text(Vector2(graze["position"]), GRAZE_TEXT, 17, Color(CombatFeedback.GRAZE_GOLD, fade))
	_draw_rooms_and_loot()

## Critical rooms get an elegant "[!] ONAR [E]" marker; loot/repair feedback floats up.
func _draw_rooms_and_loot() -> void:
	var clock: float = Time.get_ticks_msec() / 1000.0
	for room: RoomDiorama in game.building.rooms:
		if not game.loot.repair_alert(room):
			continue
		var pulse: float = 0.65 + 0.35 * sin(clock * 5.0 + room.room_kind)
		var center: Vector2 = game.world_to_screen(room.global_position + Vector2(room.room_size.x * 0.5, 70))
		_alert_plate(center, "ONAR [E]", Color(Color("ff5a4a") if room.state() == RoomDiorama.RoomState.CRITICAL else Color("ffc466"), pulse))
		repair_markers += 1
	var loot: LootSystem = game.loot
	if loot == null:
		return
	if loot.can_build():
		for room: RoomDiorama in game.building.rooms:
			if room.reinforcement_level == 0 or room.is_collapsed(): continue
			var text: String = "TAM ODA DESTEĞİ" if room.reinforcement_level == 3 else "GÜÇLENDİRME %d/3" % room.reinforcement_level
			_text(room.global_position + Vector2(92, 64), text, 13, Color("97f7c2"))
	for message: Dictionary in loot.messages:
		var alpha: float = clampf(float(message["life"]) * 2.0, 0.0, 1.0)
		var point: Vector2 = game.world_to_screen(Vector2(message["position"]))
		var width: float = ThemeDB.fallback_font.get_string_size(message["text"],HORIZONTAL_ALIGNMENT_LEFT,-1,18).x
		point.x = clampf(point.x,15,maxf(15,1905-width))
		point.y = clampf(point.y,200,934)
		var rect: Rect2 = Rect2(point-Vector2(0,20),Vector2(width,26))
		# Rapid pickup/E feedback is stacked using actual screen text bounds.
		for attempt: int in range(feedback_rects.size()+1):
			var collision: bool = false
			for occupied: Rect2 in feedback_rects:
				if occupied.intersects(rect):
					point.y = occupied.position.y-8
					rect.position.y = point.y-20
					collision = true
			if not collision: break
		feedback_rects.append(rect)
		_screen_text(point,message["text"],18,Color(Color(message["color"]),alpha))

## Minimal contextual E prompt over the player (replaces the old bottom message bar).
func _draw_action_hint() -> void:
	var loot: LootSystem = game.loot
	if loot == null or game.waves.failed or game.waves.victory or game.waves.upgrade_pending: return
	var hint: String = loot.short_hint()
	if hint == "": return
	var color: Color = CelArt.GOLD if loot.can_offer_repair() else CelArt.TEAL
	_text(game.player.global_position + Vector2(-46, -96), hint, 16, color)

func _alert_plate(center: Vector2, message: String, accent: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: int = 16
	var width: float = font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 48.0
	var plate: Rect2 = Rect2(center.x - width * 0.5, center.y - 16.0, width, 30.0)
	draw_rect(plate, Color(0.06, 0.03, 0.03, 0.88))
	draw_rect(plate, accent, false, 2.0)
	var icon: Vector2 = Vector2(plate.position.x + 16.0, center.y - 1.0)
	draw_colored_polygon(PackedVector2Array([icon + Vector2(0, -10), icon + Vector2(10, 0), icon + Vector2(0, 10), icon + Vector2(-10, 0)]), accent)
	draw_rect(Rect2(icon + Vector2(-1.5, -6), Vector2(3, 7)), Color("1a0d0c"))
	draw_rect(Rect2(icon + Vector2(-1.5, 3), Vector2(3, 3)), Color("1a0d0c"))
	draw_string(font, Vector2(plate.position.x + 32.0, center.y + 6.0), message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, accent.lightened(0.3))
	drawn += 1

func _text(world: Vector2, message: String, size: int, color: Color) -> void:
	var point: Vector2 = game.world_to_screen(world)
	var text_width: float = ThemeDB.fallback_font.get_string_size(message,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	point.x = clampf(point.x,15,maxf(15,1905-text_width))
	_screen_text(point,message,size,color)

func _screen_text(point: Vector2, message: String, size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	draw_string_outline(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 7, Color(CelArt.INK, color.a))
	draw_string(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
	drawn += 1

func _plate(world_center: Vector2, message: String, size: int, accent: Color) -> void:
	var center: Vector2 = game.world_to_screen(world_center)
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 36.0
	var plate: Rect2 = Rect2(clampf(center.x-width*.5,16.0,1904.0-width),clampf(center.y-size-10.0,174.0,928.0-size),width,size+22.0)
	draw_rect(plate, Color(0.05, 0.07, 0.09, 0.9))
	draw_rect(plate, Color(accent, 0.35), false, 6.0)
	draw_rect(plate, accent, false, 2.0)
	draw_string(font, Vector2(plate.position.x + 18.0, plate.end.y - 12.0), message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, accent.lightened(0.25))
	drawn += 1
