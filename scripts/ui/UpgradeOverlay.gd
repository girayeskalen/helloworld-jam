class_name UpgradeOverlay
extends Control
signal karne_row_revealed(ok: bool)
## After each disaster: the karne (up to three lines on what the preparation and the
## player's behaviour did) above three cards — icon, short name, one effect line and
## the key that picks it. Real Buttons keep native mouse, keyboard and scaled hit testing.
var upgrades: SiegeUpgrades
var fade: float = 0.0
var cards: Array[Button] = []
## Karne of the disaster just survived (Debrief rows) and the strings drawn for it.
var karne_rows: Array[Dictionary] = []
var karne_texts: PackedStringArray = PackedStringArray()
var karne_rects: Array[Rect2] = []
var karne_reveal: KarneReveal = KarneReveal.new()
var karne_revealed: int:
	get: return karne_reveal.revealed
const KARNE_TOP: float = 140.0
const ACCENTS: Array[Color] = [Color("9cd39a"), Color("8ec3dc"), Color("c3a8dc")]
const CARD_SIZE: Vector2 = Vector2(400, 420)
const CARD_GAP: float = 40.0
const CARD_TOP: float = 452.0
## "Güçlendirme seç" sits between the karne block and the cards.
const PICK_LABEL_Y: float = 392.0

func configure(system: SiegeUpgrades) -> void:
	upgrades = system
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	upgrades.selection_changed.connect(_refresh)
	karne_reveal.row_revealed.connect(func(ok: bool) -> void: karne_row_revealed.emit(ok))

func card_left(slot: int) -> float:
	var total: float = CARD_SIZE.x * 3.0 + CARD_GAP * 2.0
	return (1920.0 - total) * 0.5 + slot * (CARD_SIZE.x + CARD_GAP)

func _refresh() -> void:
	karne_reveal.reset()
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	cards.clear()
	visible = upgrades.pending
	if not visible: return
	fade = 0.0
	modulate.a = 0.0
	karne_rows = Debrief.rows(upgrades.game, upgrades.game.waves.mode) if upgrades.game != null else []
	UIStyle.label(self, "Güçlendirme seç", Rect2(0, PICK_LABEL_Y, 1920, 40), UIStyle.MEDIUM, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	for slot: int in range(upgrades.offers.size()):
		var id: int = upgrades.offers[slot]
		var data: Dictionary = SiegeUpgrades.CATALOG[id]
		var accent: Color = ACCENTS[slot]
		var card: UpgradeDossier = UpgradeDossier.new()
		card.accent = accent
		card.position = Vector2(card_left(slot), CARD_TOP)
		card.size = CARD_SIZE
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var empty: StyleBoxEmpty = StyleBoxEmpty.new()
		for state: String in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
			card.add_theme_stylebox_override(state, empty)
		add_child(card)
		card.pressed.connect(_choose.bind(slot))
		cards.append(card)
		var icon: UpgradeIcon = UpgradeIcon.new()
		icon.kind = id
		icon.accent = accent
		icon.position = Vector2((CARD_SIZE.x - 128.0) * 0.5, 52)
		icon.size = Vector2(128, 128)
		card.add_child(icon)
		_card_label(card, data["title"], Rect2(20, 204, CARD_SIZE.x - 40, 84), UIStyle.MEDIUM, UIStyle.TEXT)
		_card_label(card, data["effect"], Rect2(28, 296, CARD_SIZE.x - 56, 76), UIStyle.SMALL, UIStyle.MUTED)
		_card_label(card, str(slot + 1), Rect2(0, CARD_SIZE.y - 44, CARD_SIZE.x, 36), UIStyle.SMALL, Color(accent, 0.8))
	queue_redraw()

func _choose(slot: int) -> void:
	upgrades.choose(slot)

func _card_label(card: Control, text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label: Label = UIStyle.label(card, text, rect, font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_constant_override("line_spacing", 8)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color(0.02, 0.03, 0.04, 0.86))
	karne_texts = PackedStringArray()
	karne_rects.clear()
	if karne_rows.is_empty(): return
	_karne_text(Vector2(960, KARNE_TOP - 48), "Karne", UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	var left: float = Debrief.block_left(karne_rows)
	for i: int in range(karne_rows.size()):
		var row: Dictionary = karne_rows[i]
		var y: float = KARNE_TOP + i * Debrief.STEP
		var alpha: float = karne_reveal.progress(i)
		var slide: float = -36.0 * (1.0 - alpha)
		Debrief.draw_mark(self, Vector2(left + 10 + slide, y - 13), row["ok"], alpha)
		_karne_text(Vector2(left + Debrief.TEXT_INDENT + slide, y), row["fact"], Color(UIStyle.TEXT if row["ok"] else UIStyle.ALERT, alpha), HORIZONTAL_ALIGNMENT_LEFT, UIStyle.MEDIUM)
		if String(row["tip"]) != "": _karne_text(Vector2(left + Debrief.TEXT_INDENT + slide, y + Debrief.SECOND_LINE), row["tip"], Debrief.second_color(row["ok"], alpha))

func _karne_text(point: Vector2, message: String, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, font_size: int = UIStyle.SMALL) -> void:
	karne_rects.append(UIStyle.text(self, point, message, font_size, color, align))
	karne_texts.append(message)

func _process(delta: float) -> void:
	if not visible: return
	karne_reveal.advance(delta / maxf(.001, Engine.time_scale), karne_rows)
	fade = minf(1.0, fade + delta / maxf(.01, Engine.time_scale) / .3)
	modulate.a = smoothstep(0.0, 1.0, fade)
	for slot: int in range(cards.size()):
		var reveal: float = smoothstep(0.0, 1.0, clampf((fade - slot * .1) / .8, 0, 1))
		cards[slot].position.y = CARD_TOP + (1.0 - reveal) * 14
	queue_redraw()
