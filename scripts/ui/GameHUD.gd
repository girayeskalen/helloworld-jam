class_name GameHUD
extends Node2D
## Step 4.9 minimal HUD: no panels, titles or control tables. Pixel icons + thick
## INK-outlined bars at the top-left, one thin boss/time strip at the top centre,
## three equipment slots at the bottom-left. Holding Tab/H shows a small help card.

const INK: Color = Color("111518")
const STATUS_X: float = 76.0
## Thin boss/time strip under one line of boss name.
const BOSS_BAR: Rect2 = Rect2(450, 1016, 1020, 22)
const SLOT_SIZE: float = 60.0
const SLOT_ORIGIN: Vector2 = Vector2(32, 976)
const SLOT_STEP: float = 78.0
## Column kit, fixing kit, safety kit (emergency bags heal instantly; no slot).
const SLOT_KINDS: Array[int] = [LootSystem.Kind.COLUMN_KIT, LootSystem.Kind.BARRICADE_KIT, LootSystem.Kind.SAFETY_KIT]
const SLOT_LABELS: Array[String] = ["KOLON", "SABİTLE", "GÜVENLİK"]
const HELP_ROWS: Array = [
	["A / D", "KOŞ"], ["W / ↑", "ZIPLA · HAVADA 2. W ÜST KAT"], ["S / ↓", "ALT KAT · HIZLI İNİŞ"],
	["SHIFT / SPACE / SAĞ TIK", "8 YÖNLÜ TAKLA"], ["E", "ONAR / GÜÇLENDİR"], ["F", "HAZIRIM"],
	["R", "SIFIRLA"], ["1 – 4", "BOSS SEÇ · 4 FİNAL"], ["ESC / P", "DURAKLAT"], ["M · - / +", "SES KAPAT · SEVİYE"],
	["F9 + U", "KART TESTİ"],
]
## 11x10 heart, 9x12 lightning and 11x12 shield; o = ink outline.
const HEART: Array[String] = ["..ooo.ooo..", ".ohhrorrro.", "ohrrrrrrrro", "orrrrrrrrro", "orrrrrrrddo", ".orrrrrrdo.", "..orrrrdo..", "...orrdo...", "....odo....", ".....o....."]
const BOLT: Array[String] = [".....ooo.", "....oyyo.", "...oyyo..", "..oyyo...", ".oyyyoooo", "oyyyyyyyo", "ooooyyyo.", "...oyyo..", "..oyyo...", "..oyo....", ".oyo.....", ".oo......"]
const SHIELD: Array[String] = ["ooooooooooo", "ottttttttdo", "othttttttdo", "othtwwwtddo", "ottwtwtwddo", "ottwwwwwddo", ".otttttddo.", ".otttttddo.", "..ottttdo..", "...ottdo...", "....odo....", ".....o....."]

@export var custom_sprite: Texture2D
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
var _clock: float = 0.0

func _process(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	_clock += delta
	queue_redraw()

func _draw() -> void:
	drawn_texts.clear()
	drawn_rects.clear()
	if player == null or building == null:
		return
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(0, 0, 1920, 1080), false)
	if hit_flash > 0:
		draw_rect(Rect2(0, 0, 1920, 1080), Color(0.85, 0.16, 0.10, hit_flash * 0.75))
	if waves != null and waves.state == DisasterWaveManager.State.WAVE_INTRO and not waves.failed:
		return # Cinema owns the frame; no half-hidden health bar under letterbox.
	_draw_status()
	_draw_boss_strip()
	_draw_slots()
	_draw_corner_hints()
	_draw_banner()
	if show_help:
		_draw_help()
	_draw_outcome()

# --------------------------------------------------------------- status ----

func _draw_status() -> void:
	var health: float = clampf(player.health / player.max_health, 0.0, 1.0)
	_sprite(Vector2(32, 26), HEART, 3.0, {"o": INK, "r": Color("e2453a"), "h": Color("ffb3a1"), "d": Color("9c2730")})
	var health_color: Color = Color("e2453a").lerp(Color("58d06a"), smoothstep(.2, .8, health))
	_bar(Rect2(STATUS_X, 30, 250, 22), health, health_color)
	_text(Vector2(STATUS_X + 125, 47), "%d/%d" % [ceili(player.health), int(player.max_health)], 16, CelArt.PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	var stamina: float = clampf(player.stamina / 100.0, 0.0, 1.0)
	_sprite(Vector2(40, 62), BOLT, 2.0, {"o": INK, "y": Color("ffd84a").lerp(Color("7fd8ff"), 1.0 if stamina >= 1.0 else 0.0)})
	_bar(Rect2(STATUS_X, 70, 190, 10), stamina, Color("ffd84a") if stamina < 1.0 else Color("7fd8ff"))
	var integrity: float = clampf(building.integrity / building.max_integrity, 0.0, 1.0)
	var tint: Color = Color("4fd6c4") if integrity > .5 else (Color("f0a93c") if integrity > .25 else Color("ff5a4a"))
	_sprite(Vector2(32, 94), SHIELD, 3.0, {"o": INK, "t": tint, "h": tint.lightened(.45), "d": tint.darkened(.35), "w": Color("1d2a2c")})
	_bar(Rect2(STATUS_X, 104, 220, 14), integrity, tint)
	_text(Vector2(STATUS_X + 232, 119), "%%%d" % roundi(integrity * 100.0), 19, tint.lightened(.25))
	var collapsed: int = building.collapsed_count()
	if collapsed > 0:
		# Collapsed rooms toward the four-room failure limit, as tiny rubble pips.
		for i: int in range(building.collapse_limit):
			var pip: Rect2 = Rect2(STATUS_X + 292 + i * 15, 106, 11, 11)
			draw_rect(pip.grow(2), INK)
			draw_rect(pip, Color("ff5a4a") if i < collapsed else Color("2c3434"))

# ----------------------------------------------------------- boss strip ----

func _draw_boss_strip() -> void:
	if waves == null:
		return
	var preparing: bool = waves.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE]
	var transition: bool = waves.state in [DisasterWaveManager.State.WAVE_INTRO, DisasterWaveManager.State.WAVE_OUTRO]
	var wave: int = mini(waves.completed_waves + 1, DisasterWaveManager.TOTAL_WAVES) if preparing else waves.wave_number
	var title: String = waves.boss_name()
	var ratio: float = waves.boss_endurance / 100.0
	var seconds: float = waves.siege_remaining
	var accent: Color = Color("e0663f")
	if preparing:
		var duration: float = waves.build_duration if waves.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE else waves.preparation_duration
		seconds = waves.preparation_remaining
		ratio = waves.preparation_remaining / duration
		accent = Color("4fd6c4")
	elif transition:
		var outro: bool = waves.state == DisasterWaveManager.State.WAVE_OUTRO
		seconds = waves.siege_remaining if not outro else 0.0
		ratio = 1.0 - waves.transition_remaining / (DisasterWaveManager.OUTRO_DURATION if outro else waves.intro_duration()) if not outro else 0.0
	if waves.nova:
		accent = Color("ff4a3a").lerp(Color("fff1d0"), .5 + .5 * sin(_clock * 14.0))
	if waves.victory:
		title = "%d/%d DALGA • ZAFER" % [DisasterWaveManager.TOTAL_WAVES, DisasterWaveManager.TOTAL_WAVES]
		ratio = 0.0
	if waves.state == DisasterWaveManager.State.WAVE_INTRO: return
	_text(Vector2(BOSS_BAR.get_center().x, BOSS_BAR.position.y-19), title, 26, CelArt.PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	_bar(BOSS_BAR, ratio, accent)
	if not waves.victory:
		_text(Vector2(BOSS_BAR.end.x + 18, BOSS_BAR.position.y+20), "%ds" % ceili(seconds), 19, CelArt.GOLD)
		_text(Vector2(BOSS_BAR.end.x + 82, BOSS_BAR.position.y+20), "%%%d" % roundi(ratio*100), 17, CelArt.PAPER)
	if preparing and not waves.upgrade_pending:
		_text(Vector2(BOSS_BAR.get_center().x, 1064), "[F] HAZIRIM", 13, Color(CelArt.PAPER, .55), HORIZONTAL_ALIGNMENT_CENTER)

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
		var count: int = slot_count(i)
		var aura: Color = LootSystem.AURA[SLOT_KINDS[i]]
		var armed: bool = _slot_ready(i)
		draw_rect(slot, Color(0.05, 0.07, 0.08, .55))
		draw_rect(slot, INK, false, 4.0)
		draw_line(slot.position + Vector2(4, 4), slot.position + Vector2(slot.size.x - 4, 4), Color(aura, .45), 2.0)
		if armed:
			draw_rect(slot.grow(3), Color(aura, .55 + .45 * sin(_clock * 8.0)), false, 3.0)
		draw_set_transform(slot.get_center() + Vector2(-2, 0), 0, Vector2.ONE * 1.2)
		EquipmentArt.draw_kit(self, SLOT_KINDS[i], _clock)
		draw_set_transform(Vector2.ZERO)
		if count == 0:
			draw_rect(slot.grow(-2), Color(0.03, 0.04, 0.05, .55))
		_text(slot.end + Vector2(-4, -5), "x%d" % count, 16, CelArt.PAPER if count > 0 else Color("8b938c"), HORIZONTAL_ALIGNMENT_RIGHT)
		_text(Vector2(slot.get_center().x, slot.end.y + 21), SLOT_LABELS[i], 13, Color(aura.lightened(.2), .9), HORIZONTAL_ALIGNMENT_CENTER)

## The slot whose kit the E key would spend right now pulses.
func _slot_ready(index: int) -> bool:
	var room: RoomDiorama = loot.current_room()
	if room == null or room.is_collapsed() or SLOT_KINDS[index] == LootSystem.Kind.SAFETY_KIT: return false
	if SLOT_KINDS[index] == LootSystem.Kind.COLUMN_KIT:
		return loot.column_kits > 0 and (loot.can_offer_repair() or (loot.can_build() and room.hp < room.max_hp))
	return loot.barricade_kits > 0 and (loot.can_build() or loot.repair_alert(room)) and loot.next_component(room) == LootSystem.Kind.BARRICADE_KIT

## Tiny top-right hints: help, pause and a speaker that shows the mute state.
func _draw_corner_hints() -> void:
	var muted: bool = sound != null and sound.muted
	var sound_text: String = "[M] SES KAPALI" if muted else "[M] SES"
	_text(Vector2(1888, 30), sound_text, 13, Color("ff8a7a", .8) if muted else Color(CelArt.PAPER, .5), HORIZONTAL_ALIGNMENT_RIGHT)
	var x: float = 1888.0 - ThemeDB.fallback_font.get_string_size(sound_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x - 22.0
	var tint: Color = Color("ff8a7a", .8) if muted else Color(CelArt.PAPER, .5)
	draw_colored_polygon(PackedVector2Array([Vector2(x, 21), Vector2(x + 4, 21), Vector2(x + 9, 16), Vector2(x + 9, 32), Vector2(x + 4, 27), Vector2(x, 27)]), tint)
	if muted:
		draw_line(Vector2(x + 12, 19), Vector2(x + 19, 29), tint, 2.0)
		draw_line(Vector2(x + 19, 19), Vector2(x + 12, 29), tint, 2.0)
	else:
		draw_arc(Vector2(x + 10, 24), 6.0, -PI * 0.3, PI * 0.3, 6, tint, 2.0)
	_text(Vector2(x - 14, 30), "[H] YARDIM   [ESC] DURAKLAT", 13, Color(CelArt.PAPER, .5), HORIZONTAL_ALIGNMENT_RIGHT)

# -------------------------------------------------------------- banners ----

## Short centred titles: wave entry, the final fusion reveal, nova and retreat.
func _draw_banner() -> void:
	if waves == null or waves.failed or waves.victory:
		return
	if waves.state == DisasterWaveManager.State.WAVE_INTRO:
		return # BossCinematic owns the single intro title and letterbox.
	elif waves.state == DisasterWaveManager.State.WAVE_OUTRO:
		_text(Vector2(960, 540), "DALGA %02d PÜSKÜRTÜLDÜ" % waves.wave_number, 40, Color(Color("b0f1c7"), 1.0 - smoothstep(.6, 1.0, 1.0 - waves.transition_remaining / DisasterWaveManager.OUTRO_DURATION)), HORIZONTAL_ALIGNMENT_CENTER)
	elif waves.nova and waves.siege_remaining > DisasterWaveManager.NOVA_WINDOW - 1.6:
		var pulse: float = .7 + .3 * sin(_clock * 18.0)
		_text(Vector2(960, 540), "NOVA", 56, Color(Color("d7fff5"), pulse), HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 580), "SON 15 SANİYE • ACİL YARDIM DÜŞÜYOR", 18, Color(Color("8fd8ff"), pulse), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_help() -> void:
	var panel: Rect2 = Rect2(SLOT_ORIGIN.x, 940 - 34 - HELP_ROWS.size() * 30, 470, 34 + HELP_ROWS.size() * 30)
	draw_rect(panel, Color(0.04, 0.05, 0.06, .82))
	draw_rect(panel, INK, false, 4.0)
	_text(panel.position + Vector2(18, 26), "KONTROLLER", 15, CelArt.GOLD)
	for i: int in range(HELP_ROWS.size()):
		var y: float = panel.position.y + 56 + i * 30
		_text(Vector2(panel.position.x + 18, y), HELP_ROWS[i][0], 15, Color("ffd36b"))
		_text(Vector2(panel.position.x + 214, y), HELP_ROWS[i][1], 15, CelArt.PAPER)

func _draw_outcome() -> void:
	if waves == null:
		return
	if waves.victory:
		draw_rect(Rect2(0, 0, 1920, 1080), Color(.02, .05, .06, .55))
		_text(Vector2(960, 470), "ZAFER", 30, CelArt.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 530), DisasterWaveManager.VICTORY_TEXT, 34, Color("b0f1c7"), HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 580), "AYAKTA KALAN ODA %d/16" % (16 - building.collapsed_count()), 22, CelArt.PAPER, HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 630), "R • YENİ OYUN", 18, Color(CelArt.PAPER, .7), HORIZONTAL_ALIGNMENT_CENTER)
	elif waves.failed:
		draw_rect(Rect2(0, 0, 1920, 1080), Color(.06, .02, .02, .5))
		var building_lost: bool = waves.fail_reason == DisasterWaveManager.FailReason.BUILDING
		_text(Vector2(960, 500), "BİNA ÇÖKTÜ!" if building_lost else "KUŞATMA SONLANDI", 52, Color("ff5a4a") if building_lost else Color("e9b981"), HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 550), "ODALARI ZAMANINDA ONARAMADIN" if building_lost else "CAN TÜKENDİ", 22, CelArt.PAPER, HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(960, 600), "R • YENİDEN DENE     1–4 • BOSS SEÇ", 18, Color(CelArt.PAPER, .7), HORIZONTAL_ALIGNMENT_CENTER)

# -------------------------------------------------------------- helpers ----

## Thick INK frame, dark trough and a flat fill with a one-pixel cel highlight.
func _bar(area: Rect2, ratio: float, color: Color) -> void:
	draw_rect(area.grow(3), INK)
	draw_rect(area, Color("1c2427"))
	var fill: Rect2 = Rect2(area.position, Vector2(area.size.x * clampf(ratio, 0.0, 1.0), area.size.y))
	if fill.size.x > 0.0:
		draw_rect(fill, color)
		draw_rect(Rect2(fill.position, Vector2(fill.size.x, maxf(2.0, area.size.y * .28))), color.lightened(.3))
		draw_rect(Rect2(fill.position + Vector2(0, area.size.y - 2), Vector2(fill.size.x, 2)), color.darkened(.3))

## Pixel sprite from a character map; "." is transparent.
func _sprite(origin: Vector2, rows: Array[String], pixel: float, palette: Dictionary) -> void:
	for y: int in range(rows.size()):
		var row: String = rows[y]
		for x: int in range(row.length()):
			var key: String = row[x]
			if palette.has(key):
				draw_rect(Rect2(origin + Vector2(x, y) * pixel, Vector2.ONE * pixel), palette[key])

func _text(point: Vector2, message: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if color.a <= 0.01:
		return
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	if align == HORIZONTAL_ALIGNMENT_CENTER: point.x -= width * .5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT: point.x -= width
	draw_string_outline(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, maxi(5, size / 4), Color(INK, color.a))
	draw_string(font, point, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
	drawn_texts.append(message)
	drawn_rects.append(Rect2(point.x, point.y - size, width, size * 1.25))
