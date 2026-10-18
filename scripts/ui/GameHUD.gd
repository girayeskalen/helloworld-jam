class_name GameHUD
extends Node2D
signal karne_row_revealed(ok: bool)
## Minimal HUD with no words during play. Top-left: segmented health, a thin dash
## energy line and a 4x4 mini-map of the building's rooms. Bottom: one thin boss/time
## line under the boss name in small type (preparation clock and section row between fights),
## and three kit icons with counts. Holding Tab/H shows a compact key list;
## victory/defeat show one title, the karne (up to three lines) and one hint.

const HEALTH_ORIGIN: Vector2 = Vector2(32, 30)
const HEALTH_SEGMENTS: int = 10
const SEGMENT: Vector2 = Vector2(20, 10)
const SEGMENT_GAP: float = 3.0
const ENERGY_BAR: Rect2 = Rect2(32, 46, 227, 4)
## One cell per room: rows are floors (top = floor 3), columns are rooms.
const MAP_ORIGIN: Vector2 = Vector2(32, 62)
const MAP_CELL: Vector2 = Vector2(14, 9)
const MAP_GAP: float = 2.0
const BOSS_BAR: Rect2 = Rect2(610, 1040, 700, 6)
const SLOT_SIZE: float = 44.0
const SLOT_ORIGIN: Vector2 = Vector2(32, 1004)
const SLOT_STEP: float = 54.0
## Column kit, fixing kit, safety kit (emergency bags heal instantly; no slot).
const SLOT_KINDS: Array[int] = [LootSystem.Kind.COLUMN_KIT, LootSystem.Kind.BARRICADE_KIT, LootSystem.Kind.SAFETY_KIT]
const HELP_ROWS: Array = [
	["A D", "Koş"], ["W", "Zıpla"], ["W W", "Üst kat"], ["S", "Alt kat"], ["SHIFT", "Takla"],
	["C", "Çök"], ["E", "Kullan"], ["F", "Başlat"], ["R", "Yeniden"], ["1-4", "Bölüm"], ["ESC", "Duraklat"],
]
## Karne block: check/cross, the fact, then the habit tip in a second column.
const KARNE_LEFT: float = 520.0
const KARNE_TIP: float = 950.0
const KARNE_STEP: float = 40.0
const ROOM_INTACT: Color = Color("5b8c84")
const ROOM_GONE: Color = Color("141819")

@export var custom_sprite: Texture2D
var game: MainGame
var player: SiegePlayer
var building: ApartmentBuilding
var waves: DisasterWaveManager
var loot: LootSystem
var sound: SoundManager
var hit_flash: float = 0.0
var show_help: bool = false
## Every string drawn in the last frame with its screen rect (tests read these).
var drawn_texts: PackedStringArray = PackedStringArray()
var drawn_rects: Array[Rect2] = []
## True when the last frame showed the crossed speaker (muted).
var mute_drawn: bool = false
var _clock: float = 0.0
## A kit count that just went up flashes its slot instead of a floating message.
var _slot_counts: Array[int] = [0, 0, 0]
var _slot_flash: Array[float] = [0.0, 0.0, 0.0]
var _slot_bounce: Array[float] = [0.0, 0.0, 0.0]
const FLIGHT_LIMIT: int = 6
var flying_icons: Array[Dictionary] = []
var objective_pulse: float = 0.0
var objective_pulse_duration: float = .5
var health_shake: float = 0.0
var heal_flash: float = 0.0
var heal_glow_count: int = 0
var _shown_health: float = 100.0
var _last_health: float = 100.0
var _health_hold: float = 0.0
var vignette_alpha: float = 0.0
var _outcome_key: int = 0
var outcome_reveal: KarneReveal = KarneReveal.new()
var karne_revealed: int:
	get: return outcome_reveal.revealed

func configure_feel() -> void:
	game.preparedness.task_done.connect(_on_task_done)
	loot.picked_up.connect(_on_picked_up)
	game.preparedness.bag_used.connect(func(_point: Vector2) -> void: heal_glow())
	game.mechanics.activated.connect(func(id: int, _point: Vector2) -> void:
		if id == SiegeUpgrades.Kind.AWARE_BAG: heal_glow())
	outcome_reveal.row_revealed.connect(func(ok: bool) -> void: karne_row_revealed.emit(ok))
	reset_feel()

func reset_feel() -> void:
	hit_flash = 0.0
	health_shake = 0.0
	heal_flash = 0.0
	_health_hold = 0.0
	vignette_alpha = 0.0
	_shown_health = player.health
	_last_health = player.health
	objective_pulse = 0.0
	flying_icons.clear()
	for index: int in range(3):
		_slot_counts[index] = slot_count(index)
		_slot_flash[index] = 0.0
		_slot_bounce[index] = 0.0
	_outcome_key = 0
	outcome_reveal.reset()
	queue_redraw()

func on_damage() -> void:
	hit_flash = .35
	health_shake = .35
	_shown_health = maxf(_shown_health, _last_health)
	_last_health = player.health
	_health_hold = .12

func heal_glow() -> void:
	heal_glow_count += 1
	heal_flash = .4

func phase_recovery() -> void:
	hit_flash = 0.0
	health_shake = 0.0
	vignette_alpha = 0.0
	_health_hold = 0.0
	_last_health = player.health
	_shown_health = player.health
	heal_glow()

func _on_task_done(_kind: int, _point: Vector2) -> void:
	objective_pulse_duration = .8 if game.preparedness.pending().is_empty() else .5
	objective_pulse = objective_pulse_duration

func _on_picked_up(kind: int, point: Vector2) -> void:
	var slot: int = SLOT_KINDS.find(kind)
	var target: Vector2 = HEALTH_ORIGIN + Vector2(113.5, 5) if slot < 0 else slot_rect(slot).get_center()
	if slot >= 0: _slot_counts[slot] = mini(slot_count(slot), _slot_counts[slot] + 1)
	if flying_icons.size() >= FLIGHT_LIMIT: flying_icons.pop_front()
	var start: Vector2 = game.world_to_screen(point)
	flying_icons.append({"kind": kind, "slot": slot, "start": start, "target": target, "control": (start + target) * .5 + Vector2(0, -160), "age": 0.0})

static func flight_position(data: Dictionary) -> Vector2:
	var t: float = smoothstep(0.0, .5, float(data["age"]))
	return Vector2(data["start"]) * (1-t) * (1-t) + Vector2(data["control"]) * 2 * t * (1-t) + Vector2(data["target"]) * t * t

func _process(delta: float) -> void:
	advance_feel(delta / maxf(.001, Engine.time_scale))

func advance_feel(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	health_shake = maxf(0.0, health_shake - delta)
	heal_flash = maxf(0.0, heal_flash - delta)
	objective_pulse = maxf(0.0, objective_pulse - delta)
	_clock += delta
	if player.health > _last_health:
		heal_glow()
		_shown_health = player.health
	elif player.health < _last_health:
		_shown_health = maxf(_shown_health, _last_health)
		_health_hold = .12
	_last_health = player.health
	var held: float = minf(delta, _health_hold)
	_health_hold -= held
	_shown_health = move_toward(_shown_health, player.health, 120.0 * (delta - held))
	for i: int in range(SLOT_KINDS.size()):
		var count: int = slot_count(i)
		if count > _slot_counts[i]: _slot_flash[i] = 0.45
		_slot_counts[i] = count
		_slot_flash[i] = maxf(0.0, _slot_flash[i] - delta)
		_slot_bounce[i] = maxf(0.0, _slot_bounce[i] - delta)
	for index: int in range(flying_icons.size() - 1, -1, -1):
		var data: Dictionary = flying_icons[index]
		data["age"] = float(data["age"]) + delta
		if float(data["age"]) + .000001 >= .5:
			var slot: int = data["slot"]
			if slot >= 0:
				_slot_bounce[slot] = .28
				_slot_flash[slot] = .45
			else: heal_glow()
			flying_icons.remove_at(index)
	var key: int = (3 if waves.victory else (2 if waves.fail_reason == DisasterWaveManager.FailReason.BUILDING else 1)) if waves != null and (waves.failed or waves.victory) else 0
	if key != _outcome_key:
		_outcome_key = key
		outcome_reveal.reset()
	if key != 0: outcome_reveal.advance(delta, Debrief.rows(game, waves.mode))
	queue_redraw()

func _draw() -> void:
	objective_band = Rect2()
	drawn_texts.clear()
	drawn_rects.clear()
	mute_drawn = false
	if player == null or building == null:
		return
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(0, 0, 1920, 1080), false)
	_draw_hit_edges()
	if waves != null and waves.state == DisasterWaveManager.State.WAVE_INTRO and not waves.failed:
		return # The boss cinematic owns the frame.
	if waves == null or not (waves.victory or waves.failed):
		_draw_status()
		_draw_map()
		_draw_boss_strip()
		_draw_slots()
		_draw_flying_icons()
		_draw_objective()
		_draw_mute()
		if show_help:
			_draw_help()
	_draw_outcome()

# --------------------------------------------------------------- status ----

func _draw_status() -> void:
	var health: float = clampf(player.health / player.max_health, 0.0, 1.0)
	var low: bool = health < 0.3
	var color: Color = UIStyle.HEALTH.lightened(0.25 * (0.5 + 0.5 * sin(_clock * 9.0))) if low else UIStyle.HEALTH
	if heal_flash > 0: color = color.lerp(UIStyle.SAFE, heal_flash / .4)
	var shake: float = sin((.35 - health_shake) * 70.0) * 5.0 * health_shake / .35
	draw_set_transform(Vector2(shake, 0))
	for i: int in range(HEALTH_SEGMENTS):
		var cell: Rect2 = Rect2(HEALTH_ORIGIN + Vector2(i * (SEGMENT.x + SEGMENT_GAP), 0), SEGMENT)
		draw_rect(cell, UIStyle.TROUGH)
		var fill: float = clampf(health * HEALTH_SEGMENTS - i, 0.0, 1.0)
		var trail: float = clampf(_shown_health / player.max_health * HEALTH_SEGMENTS - i, 0, 1)
		if trail > fill: draw_rect(Rect2(cell.position, Vector2(cell.size.x * trail, cell.size.y)), Color(UIStyle.TEXT, .65))
		if fill > 0.0:
			draw_rect(Rect2(cell.position, Vector2(cell.size.x * fill, cell.size.y)), color)
			draw_rect(Rect2(cell.position, Vector2(cell.size.x * fill, 2)), color.lightened(0.3))
	draw_set_transform(Vector2.ZERO)
	var stamina: float = clampf(player.stamina / 100.0, 0.0, 1.0)
	draw_rect(ENERGY_BAR, UIStyle.TROUGH)
	draw_rect(Rect2(ENERGY_BAR.position, Vector2(ENERGY_BAR.size.x * stamina, ENERGY_BAR.size.y)), UIStyle.ENERGY_FULL if stamina >= 1.0 else UIStyle.ENERGY)

## The building as 16 tiny rooms: teal = intact, amber = damaged, red = critical
## (pulsing), dark = collapsed. A light frame marks the player's room.
func _draw_map() -> void:
	var player_room: RoomDiorama = building.room_at_point(player.current_floor, player.global_position.x)
	for index: int in range(building.rooms.size()):
		var room: RoomDiorama = building.rooms[index]
		var column: int = index % ApartmentBuilding.COLUMN_COUNT
		var row: int = building.floor_count - 1 - room.floor_index
		var cell: Rect2 = map_cell(row, column)
		draw_rect(cell, room_color(room))
		if room == player_room:
			draw_rect(cell.grow(1.0), UIStyle.TEXT, false, 1.0)

func map_cell(row: int, column: int) -> Rect2:
	return Rect2(MAP_ORIGIN + Vector2(column * (MAP_CELL.x + MAP_GAP), row * (MAP_CELL.y + MAP_GAP)), MAP_CELL)

func room_color(room: RoomDiorama) -> Color:
	match room.state():
		RoomDiorama.RoomState.COLLAPSED: return ROOM_GONE
		RoomDiorama.RoomState.CRITICAL: return UIStyle.DANGER.lerp(Color.WHITE, 0.25 * (0.5 + 0.5 * sin(_clock * 8.0)))
		RoomDiorama.RoomState.DAMAGED: return UIStyle.ALERT.lerp(Color.WHITE, .18 * (.5 + .5 * sin(_clock * 5.0)))
	return ROOM_INTACT

# ----------------------------------------------------------- boss strip ----

func _draw_boss_strip() -> void:
	if waves == null:
		return
	var preparing: bool = waves.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE]
	var ratio: float = waves.boss_endurance / 100.0
	var mode_index: int = int(waves.mode)
	var accent: Color = UIStyle.BOSS[clampi(mode_index, 0, 3)]
	if preparing:
		ratio = 1.0 if waves.prep_hold else waves.preparation_remaining / maxf(0.01, waves.preparation_total)
		accent = UIStyle.MUTED
	elif waves.state == DisasterWaveManager.State.WAVE_OUTRO:
		ratio = 0.0
	if waves.nova:
		accent = UIStyle.DANGER.lerp(Color("fff1d0"), 0.5 + 0.5 * sin(_clock * 14.0))
	_text(Vector2(BOSS_BAR.get_center().x, BOSS_BAR.position.y - 12), waves.boss_name(), UIStyle.SMALL, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	if preparing and not waves.upgrade_pending: _draw_sections()
	draw_rect(BOSS_BAR, UIStyle.TROUGH)
	draw_rect(Rect2(BOSS_BAR.position, Vector2(BOSS_BAR.size.x * clampf(ratio, 0.0, 1.0), BOSS_BAR.size.y)), accent)

const SECTION_LABELS: Array[String] = ["1 Deprem", "2 Fırtına", "3 Sel", "4 Afet"]

func _draw_sections() -> void:
	var separator: String = " · "
	var total: float = UIStyle.width(separator.join(SECTION_LABELS), UIStyle.SMALL)
	var x: float = BOSS_BAR.get_center().x - total * 0.5
	for index: int in range(SECTION_LABELS.size()):
		var label: String = SECTION_LABELS[index]
		var color: Color = UIStyle.TEXT if index == waves.completed_waves else UIStyle.MUTED
		_text(Vector2(x, BOSS_BAR.position.y - 48), label, UIStyle.SMALL, color)
		x += UIStyle.width(label, UIStyle.SMALL)
		if index < SECTION_LABELS.size() - 1:
			_text(Vector2(x, BOSS_BAR.position.y - 48), separator, UIStyle.SMALL, UIStyle.MUTED)
			x += UIStyle.width(separator, UIStyle.SMALL)

# ----------------------------------------------------------- equipment ----

func slot_rect(index: int) -> Rect2:
	return Rect2(SLOT_ORIGIN + Vector2(index * SLOT_STEP, 0), Vector2(SLOT_SIZE, SLOT_SIZE))

func slot_count(index: int) -> int:
	if loot == null: return 0
	var kind: int = SLOT_KINDS[index]
	return loot.safety_installs if kind == LootSystem.Kind.SAFETY_KIT else loot.count_kind(kind)

func _draw_slots() -> void:
	if loot == null:
		return
	for i: int in range(SLOT_KINDS.size()):
		var slot: Rect2 = slot_rect(i)
		var pop: float = 1.0 + .22 * sin(PI * (1.0 - _slot_bounce[i] / .28)) if _slot_bounce[i] > 0 else 1.0
		draw_set_transform(slot.get_center() * (1.0 - pop), 0, Vector2.ONE * pop)
		var count: int = slot_count(i)
		var aura: Color = LootSystem.AURA[SLOT_KINDS[i]]
		draw_rect(slot, UIStyle.TROUGH)
		var edge: Color = UIStyle.FAINT
		if _slot_ready(i): edge = Color(aura, 0.55 + 0.45 * sin(_clock * 8.0))
		if _slot_flash[i] > 0.0: edge = Color.WHITE.lerp(aura, 1.0 - _slot_flash[i] / 0.45)
		draw_rect(slot, edge, false, 1.0 if edge == UIStyle.FAINT else 2.0)
		draw_set_transform(slot.get_center(), 0, Vector2.ONE * (0.85 * pop))
		EquipmentArt.draw_kit(self, SLOT_KINDS[i], _clock)
		draw_set_transform(slot.get_center() * (1.0 - pop), 0, Vector2.ONE * pop)
		if count == 0:
			draw_rect(slot.grow(-1), Color(0.02, 0.03, 0.04, 0.68))
		else:
			var badge: Rect2 = Rect2(slot.end - Vector2(16, 18), Vector2(16, 18))
			draw_rect(badge, Color(0.02, 0.03, 0.04, 0.9))
			_text(Vector2(badge.get_center().x + 1, badge.end.y - 2), str(count), UIStyle.SMALL, UIStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		draw_set_transform(Vector2.ZERO)

func _draw_flying_icons() -> void:
	for data: Dictionary in flying_icons:
		var scale_size: float = lerpf(1.0, .75, clampf(float(data["age"]) / .5, 0, 1))
		draw_set_transform(flight_position(data), 0, Vector2.ONE * scale_size)
		EquipmentArt.draw_kit(self, data["kind"], _clock)
	draw_set_transform(Vector2.ZERO)

## Six non-overlapping bands: the strongest edge never exceeds alpha .45.
func _draw_hit_edges() -> void:
	var hit: float = clampf(hit_flash / .35, 0, 1)
	var low: float = (.1 + .04 * sin(TAU * 1.6 * _clock)) if player.health > 0 and player.health / player.max_health < .3 else 0.0
	vignette_alpha = minf(.45, hit * .45 + low)
	if hit > 0: draw_rect(Rect2(0, 0, 1920, 1080), Color(UIStyle.DANGER, hit * .15))
	if vignette_alpha <= 0: return
	var previous: float = 0.0
	for index: int in range(6):
		var depth: float = lerpf(12, 70, index / 5.0)
		var width: float = depth - previous
		var color: Color = Color(UIStyle.DANGER, vignette_alpha * (1.0 - index / 6.0))
		draw_rect(Rect2(previous, previous, 1920 - 2 * previous, width), color)
		draw_rect(Rect2(previous, 1080 - depth, 1920 - 2 * previous, width), color)
		draw_rect(Rect2(previous, depth, width, 1080 - 2 * depth), color)
		draw_rect(Rect2(1920 - depth, depth, width, 1080 - 2 * depth), color)
		previous = depth

## The slot whose kit the E key would spend right now pulses.
func _slot_ready(index: int) -> bool:
	var room: RoomDiorama = loot.current_room()
	if room == null or room.is_collapsed() or SLOT_KINDS[index] == LootSystem.Kind.SAFETY_KIT: return false
	if SLOT_KINDS[index] == LootSystem.Kind.COLUMN_KIT:
		return loot.column_kits > 0 and (loot.can_offer_repair() or (loot.can_build() and room.hp < room.max_hp))
	return loot.barricade_kits > 0 and (loot.can_build() or loot.repair_alert(room)) and loot.next_component(room) == LootSystem.Kind.BARRICADE_KIT

## One short objective line at the top centre (preparation task, tutorial step, first
## repair): a coloured tick, the line, and a soft dark band so it reads over the sky.
const OBJECTIVE_Y: float = 66.0

var objective_band: Rect2 = Rect2()
var objective_font_size: int = UIStyle.MEDIUM

func _draw_objective() -> void:
	objective_band = Rect2()
	if game == null or game.tutorial == null or not game.tutorial.cues_visible() or game.tutorial.objective_text == "": return
	var guide: TutorialGuide = game.tutorial
	var message: String = guide.objective_text
	var prefix: String = ""
	if message.contains(" · "):
		prefix = message.get_slice(" · ", 0) + " · "
		message = message.substr(prefix.length())
	var color: Color = guide.objective_color
	var prefix_width: float = UIStyle.width(prefix, UIStyle.SMALL)
	objective_font_size = UIStyle.MEDIUM
	if prefix_width + UIStyle.width(message, objective_font_size) > 1200.0: objective_font_size = UIStyle.SMALL
	var width: float = prefix_width + UIStyle.width(message, objective_font_size)
	var band: Rect2 = Rect2(960.0 - width * .5 - 36.0, 38.0, width + 72.0, 56.0)
	var slide: float = -14.0 * (1.0 - smoothstep(0.0, .25, .8 - guide.entry_left)) if guide.entry_left > .55 else 0.0
	band.position.y += slide
	objective_band = band
	var progress: float = 1.0 - objective_pulse / objective_pulse_duration
	var pop: float = 1.0 + (.065 if objective_pulse_duration > .5 else .04) * sin(PI * progress) if objective_pulse > 0 else 1.0
	if guide.reminder_left > 0: pop = 1.0 + .04 * sin(PI * (1.0-guide.reminder_left/.5))
	draw_set_transform(band.get_center() * (1.0-pop), 0, Vector2.ONE * pop)
	draw_rect(band, Color(.02,.03,.04,.80))
	var flash: float = pow(sin(PI * 2.0 * (1.0-guide.entry_left/.8)), 2.0) if guide.entry_left > 0 else 0.0
	draw_rect(Rect2(band.position.x,band.end.y-4.0,band.size.x,4.0), (UIStyle.SAFE if objective_pulse > 0 else color).lerp(Color.WHITE, .5*flash))
	draw_rect(Rect2(band.position + Vector2(12,22), Vector2(12,12)), color)
	if objective_pulse > 0: Debrief.draw_mark(self, band.position + Vector2(16,12), true)
	var start: float = 960.0-width*.5+6.0
	var baseline: float = 76.0+slide
	var alpha: float = .6 + .4 * guide.text_blend
	if prefix != "": _text(Vector2(start,baseline), prefix, UIStyle.SMALL, Color(color,alpha))
	_text(Vector2(start+prefix_width,baseline), message, objective_font_size, Color(UIStyle.TEXT,alpha))
	draw_set_transform(Vector2.ZERO)

## Only when muted: a small crossed speaker in the top-right corner.
func _draw_mute() -> void:
	if sound == null or not sound.muted: return
	mute_drawn = true
	var x: float = 1862.0
	var tint: Color = Color(UIStyle.DANGER, 0.85)
	draw_colored_polygon(PackedVector2Array([Vector2(x, 26), Vector2(x + 5, 26), Vector2(x + 11, 20), Vector2(x + 11, 38), Vector2(x + 5, 32), Vector2(x, 32)]), tint)
	draw_line(Vector2(x + 15, 24), Vector2(x + 23, 34), tint, 2.0)
	draw_line(Vector2(x + 23, 24), Vector2(x + 15, 34), tint, 2.0)

func _draw_help() -> void:
	var top: float = SLOT_ORIGIN.y - 40.0 - HELP_ROWS.size() * 30.0
	draw_rect(Rect2(SLOT_ORIGIN.x - 16, top - 32, 320, HELP_ROWS.size() * 30.0 + 40), Color(0.02, 0.03, 0.04, 0.8))
	for i: int in range(HELP_ROWS.size()):
		var y: float = top + i * 30.0
		_text(Vector2(SLOT_ORIGIN.x, y), HELP_ROWS[i][0], UIStyle.SMALL, UIStyle.TEXT)
		_text(Vector2(SLOT_ORIGIN.x + 112, y), HELP_ROWS[i][1], UIStyle.SMALL, UIStyle.MUTED)

func _draw_outcome() -> void:
	if waves == null or not (waves.victory or waves.failed):
		return
	draw_rect(Rect2(0, 0, 1920, 1080), Color(0.02, 0.03, 0.04, 0.7))
	var rows: Array[Dictionary] = Debrief.rows(game, waves.mode) if game != null else []
	var title_alpha: float = clampf(outcome_reveal.clock / .25, 0, 1)
	if waves.victory:
		_text(Vector2(960, 440), "Hayatta kaldın", UIStyle.TITLE, Color(UIStyle.TEXT, title_alpha), HORIZONTAL_ALIGNMENT_CENTER, true)
	else:
		var building_lost: bool = waves.fail_reason == DisasterWaveManager.FailReason.BUILDING
		_text(Vector2(960, 440), "Bina çöktü" if building_lost else "Yaralandın", UIStyle.TITLE, Color(UIStyle.DANGER if building_lost else UIStyle.TEXT, title_alpha), HORIZONTAL_ALIGNMENT_CENTER, true)
	draw_karne(rows, 520.0)
	_text(Vector2(960, 540.0 + KARNE_STEP * rows.size() + 40.0), "R  Yeni oyun" if waves.victory else "R  Bölümü tekrar dene", UIStyle.SMALL, Color(UIStyle.MUTED, outcome_reveal.hint_progress(rows.size())), HORIZONTAL_ALIGNMENT_CENTER, true)

## Karne rows (see Debrief): mark, fact, tip. Shared layout with the card screen.
func draw_karne(rows: Array[Dictionary], top: float) -> void:
	for i: int in range(rows.size()):
		var row: Dictionary = rows[i]
		var y: float = top + i * KARNE_STEP
		var alpha: float = outcome_reveal.progress(i)
		var slide: float = -36.0 * (1.0 - alpha)
		Debrief.draw_mark(self, Vector2(KARNE_LEFT + slide, y - 10), row["ok"], alpha)
		_text(Vector2(KARNE_LEFT + 24 + slide, y), row["fact"], UIStyle.SMALL, Color(UIStyle.TEXT if row["ok"] else UIStyle.ALERT, alpha), HORIZONTAL_ALIGNMENT_LEFT, true)
		if String(row["tip"]) != "":
			_text(Vector2(KARNE_TIP + slide, y), row["tip"], UIStyle.SMALL, Color(UIStyle.MUTED, alpha), HORIZONTAL_ALIGNMENT_LEFT, true)

# -------------------------------------------------------------- helpers ----

func _text(point: Vector2, message: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, record_invisible: bool = false) -> void:
	if color.a <= 0.01 and not record_invisible:
		return
	drawn_rects.append(UIStyle.text(self, point, message, size, color, align))
	drawn_texts.append(message)
