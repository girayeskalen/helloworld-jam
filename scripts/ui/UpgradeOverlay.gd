class_name UpgradeOverlay
extends Control
## Equipment dossiers retain native mouse, keyboard and scaled hit testing.
var upgrades: SiegeUpgrades
var fade: float = 0.0
var cards: Array[Button] = []
const ACCENTS: Array[Color] = [Color("9cbb9a"),Color("8eaebc"),Color("b2a2bb")]

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
	var completed: int = upgrades.game.waves.completed_waves
	var headings: Array[String] = ["BİR SONRAKİ DALGAYA HAZIRLAN","FIRTINA GERİ ÇEKİLDİ","SARSINTI DİNDİ","SULAR ÇEKİLDİ"]
	FieldUI.label(self,"SAHA İKMALİ  /  %02d" % maxi(1,completed),Rect2(240,120,900,28),16,FieldUI.AMBER)
	FieldUI.label(self,headings[clampi(completed,0,3)],Rect2(236,158,1450,68),45)
	FieldUI.label(self,"Bir ekipman al. Binayı ayakta tut.",Rect2(240,237,1000,36),22,FieldUI.MUTED)
	var step: Label = FieldUI.label(self,"[1]  [2]  [3]   /   SEÇ",Rect2(1330,243,350,30),16,FieldUI.MUTED)
	step.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for slot: int in range(upgrades.offers.size()):
		var id: int = upgrades.offers[slot]
		var data: Dictionary = SiegeUpgrades.CATALOG[id]
		var accent: Color = ACCENTS[slot]
		var card: UpgradeDossier = UpgradeDossier.new()
		card.accent = accent
		card.position = Vector2(240+slot*490,310)
		card.size = Vector2(460,568)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state: String in ["normal","hover","pressed","focus"]:
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = Color("1c272a") if state == "normal" else Color("2b3737")
			style.border_color = Color("4c5856") if state == "normal" else accent
			style.set_border_width_all(1 if state == "normal" else 2)
			style.shadow_color = Color(0,0,0,.5)
			style.shadow_size = 8
			style.shadow_offset = Vector2(4,7)
			card.add_theme_stylebox_override(state,style)
		add_child(card)
		card.pressed.connect(_choose.bind(slot))
		cards.append(card)
		_card_label(card,"HAZIRLIK DONANIMI" if slot == 0 else "SAHA EKİPMANI",Rect2(25,16,390,24),13,accent)
		var icon: UpgradeIcon = UpgradeIcon.new()
		icon.kind = id
		icon.accent = accent
		icon.position = Vector2(166,65)
		icon.size = Vector2(128,128)
		card.add_child(icon)
		_card_label(card,data["title"],Rect2(25,224,410,72),26,FieldUI.PAPER)
		_card_label(card,data["effect"],Rect2(25,322,410,96),22,Color("d7dfd9"))
		_card_label(card,"SAHA NOTU",Rect2(28,437,404,20),11,accent)
		_card_label(card,data["note"],Rect2(28,464,404,52),15,FieldUI.MUTED)
		_card_label(card,"[%d]  EKİPMANI AL" % (slot+1),Rect2(25,536,410,26),15,accent)
	FieldUI.label(self,"SEÇİMDEN SONRA %d SN  /  E: ONAR  /  F: HAZIRIM" % int(upgrades.game.waves.build_duration),Rect2(240,915,1440,30),16,FieldUI.AMBER)
	FieldUI.label(self,"Kalkanlar, onarım ışınları ve zaman etkileri oyun kurgusudur.",Rect2(240,962,1440,26),14,FieldUI.MUTED)
	queue_redraw()

func _choose(slot: int) -> void:
	upgrades.choose(slot)

func _card_label(card: Control, text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label: Label = FieldUI.label(card,text,rect,font_size,color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true

func _draw() -> void:
	draw_rect(Rect2(0,0,1920,1080),Color("080f13",.88))
	draw_rect(Rect2(0,0,1920,76),Color("080d10",.85))
	draw_line(Vector2(240,285),Vector2(1680,285),Color("64716b",.6),1)
	FieldUI.grain(self,Rect2(160,90,1600,900),180)
	for x: int in range(240,1680,28):
		draw_line(Vector2(x,1032),Vector2(x+12,1032),Color("8b866a",.18),3)

func _process(delta: float) -> void:
	if not visible: return
	fade = minf(1.0,fade+delta/maxf(.01,Engine.time_scale)/.38)
	modulate.a = smoothstep(0.0,1.0,fade)
	for slot: int in range(cards.size()):
		var reveal: float = smoothstep(0.0,1.0,clampf((fade-slot*.1)/.8,0,1))
		cards[slot].position.y = 310+(1.0-reveal)*18
