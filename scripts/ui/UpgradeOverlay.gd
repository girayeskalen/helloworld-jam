class_name UpgradeOverlay
extends Control
## Native Control buttons retain mouse, keyboard focus and screen-scale hit testing.

var upgrades: SiegeUpgrades
var fade: float = 0.0
var cards: Array[Button] = []

func configure(system: SiegeUpgrades) -> void:
	upgrades = system
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	upgrades.selection_changed.connect(_refresh)

func _refresh() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	cards.clear()
	visible = upgrades.pending
	if not visible: return
	fade = 0.0
	modulate.a = 0.0
	_label("AFET HAZIRLIK BÜLTENİ", Rect2(240, 180, 1440, 65), 44, Color("f0deba"))
	_label("SIRADAKİ FELAKET İÇİN 1 ÖNLEM SEÇ", Rect2(240, 247, 1440, 40), 24, Color("91cbbc"))
	_label("1 / 2 / 3 veya karta tıkla · Seçim sırasında süre durur", Rect2(240, 299, 1440, 35), 19, Color("b5c4c1"))
	for slot: int in range(upgrades.offers.size()):
		var data: Dictionary = SiegeUpgrades.CATALOG[upgrades.offers[slot]]
		var accent: Color = data["color"]
		var card: Button = Button.new()
		card.position = Vector2(240 + slot * 490, 380)
		card.size = Vector2(460, 420)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state_name: String in ["normal", "hover", "pressed", "focus"]:
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = Color("17262c") if state_name == "normal" else Color("253c42")
			style.border_color = accent.darkened(0.4) if state_name == "normal" else accent
			style.set_border_width_all(2 if state_name == "normal" else 4)
			style.set_corner_radius_all(8)
			style.shadow_color = Color(0,0,0,.45)
			style.shadow_size = 12
			card.add_theme_stylebox_override(state_name, style)
		add_child(card)
		card.pressed.connect(_choose.bind(slot))
		cards.append(card)
		_card_label(card, "%02d  /  %s" % [slot + 1, data["tag"]], Rect2(26, 24, 408, 35), 17, accent)
		_card_label(card, data["title"], Rect2(26, 78, 408, 105), 28, Color("f0e5cf"))
		_card_label(card, data["effect"], Rect2(26, 196, 408, 120), 21, Color("d5dfd9"))
		_card_label(card, data["note"], Rect2(26, 322, 408, 58), 16, Color("a4b8b4"))
		_card_label(card, "[%d]  BU ÖNLEMİ SEÇ" % [slot + 1], Rect2(26, 382, 408, 26), 17, accent)
	_label("Seçimden sonra 15 sn: E ile onar / güçlendir · F ile hazırım", Rect2(240, 832, 1440, 40), 21, Color("cfdbcc"))
	_label("Bu oranlar ve ekipman etkileri oyun kurgusudur; gerçek yapı güvenliği değerlendirmesi değildir.", Rect2(240, 925, 1440, 35), 15, Color("8ba09c"))
	queue_redraw()

func _choose(slot: int) -> void:
	upgrades.choose(slot)

func _label(text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label: Label = _make_label(text, rect, font_size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func _card_label(card: Control, text: String, rect: Rect2, font_size: int, color: Color) -> void:
	card.add_child(_make_label(text, rect, font_size, color))

func _make_label(text: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.text = text
	label.position = rect.position
	label.size = rect.size
	return label

func _draw() -> void:
	draw_rect(Rect2(0,0,1920,1080),Color(.025,.045,.06,.96))
	draw_line(Vector2(240,350),Vector2(1680,350),Color("557a78"),2.0)

func _process(delta: float) -> void:
	if visible:
		fade = minf(1.0, fade + delta / maxf(0.01, Engine.time_scale) / 0.35)
		modulate.a = smoothstep(0.0, 1.0, fade)
