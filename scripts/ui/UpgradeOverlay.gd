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
	_label("AFETE HAZIRLAN · BİR MEKANİK SEÇ",Rect2(240,153,1440,62),38,Color("f0deba"))
	_label("[1 / 2 / 3] veya karta tıkla",Rect2(240,230,1440,36),21,Color("afc6c5"))
	for slot: int in range(upgrades.offers.size()):
		var id: int = upgrades.offers[slot]
		var data: Dictionary = SiegeUpgrades.CATALOG[id]
		var accent: Color = [Color("80dba5"),Color("7ac4f2"),Color("c1a1ef")][slot]
		var card: Button = Button.new()
		card.position = Vector2(240+slot*490,310)
		card.size = Vector2(460,560)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state_name: String in ["normal","hover","pressed","focus"]:
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = Color("131f29") if state_name == "normal" else Color("24343f")
			style.border_color = accent.darkened(.4) if state_name == "normal" else accent
			style.set_border_width_all(2 if state_name == "normal" else 4)
			style.set_corner_radius_all(8)
			style.shadow_color = Color(0,0,0,.45)
			style.shadow_size = 12
			card.add_theme_stylebox_override(state_name,style)
		add_child(card)
		card.pressed.connect(_choose.bind(slot))
		cards.append(card)
		_card_label(card,"HAZIRLIK" if slot == 0 else "AKSİYON",Rect2(26,20,408,28),15,accent)
		var icon: UpgradeIcon = UpgradeIcon.new()
		icon.kind = id
		icon.accent = accent
		icon.position = Vector2(166,65)
		icon.size = Vector2(128,128)
		card.add_child(icon)
		_card_label(card,data["title"],Rect2(24,218,412,76),27,Color("f0e5cf"))
		_card_label(card,data["effect"],Rect2(28,300,404,132),25,Color("e8eee5"))
		_card_label(card,"GERÇEK BİLGİ",Rect2(24,441,412,22),12,accent)
		var note: Label = _make_label(data["note"],Rect2(24,469,412,28),15,Color("aec4bc"))
		note.autowrap_mode = TextServer.AUTOWRAP_OFF
		var font: Font = note.get_theme_font("font")
		var font_size: int = 15
		while font.get_string_size(note.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x > 408 and font_size > 10: font_size -= 1
		note.add_theme_font_size_override("font_size",font_size)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(note)
		_card_label(card,"[%d] SEÇ" % [slot+1],Rect2(24,515,412,28),18,accent)
	_label("Seçimden sonra %d sn hazırlık · E: Onar · F: Hazırım" % int(upgrades.game.waves.build_duration),Rect2(240,900,1440,38),20,Color("cfdbcc"))
	_label("Kalkanlar, onarım ışınları ve zaman etkileri oyun kurgusudur.",Rect2(240,950,1440,30),15,Color("8ba09c"))
	queue_redraw()

func _choose(slot: int) -> void:
	upgrades.choose(slot)

func _label(text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label: Label = _make_label(text, rect, font_size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func _card_label(card: Control, text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label: Label = _make_label(text,rect,font_size,color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font_size >= 25:
		label.add_theme_constant_override("outline_size",1)
		label.add_theme_color_override("font_outline_color",color)
	card.add_child(label)

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
	draw_line(Vector2(240,292),Vector2(1680,292),Color("557a78"),2.0)

func _process(delta: float) -> void:
	if visible:
		fade = minf(1.0, fade + delta / maxf(0.01, Engine.time_scale) / 0.35)
		modulate.a = smoothstep(0.0, 1.0, fade)
