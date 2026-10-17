class_name GameHUD
extends Node2D

## Bottom control bar: x, keys, action.
const CONTROLS: Array = [
	[172, "A / D", "KOŞ"],
	[290, "W / ↑", "ZIPLA  (2x W: ÜST KAT)"],
	[520, "S / ↓", "ALT KATA İN · KAT 00: HIZLI İNİŞ"],
	[790, "SHIFT / SPACE / SAĞ TIK", "TAKLA · 8 YÖN · DOKUNULMAZ"],
	[1080, "E", "ODAYI ONAR / GÜÇLENDİR"],
	[1300, "T / R", "SARSINTI / SIFIRLA"],
]

@export var custom_sprite: Texture2D
var player: SiegePlayer
var building: ApartmentBuilding
var waves: DisasterWaveManager
var loot: LootSystem
var hit_flash: float = 0.0
var _clock: float = 0.0

func _process(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	_clock += delta
	queue_redraw()

func _draw() -> void:
	if player == null or building == null:
		return
	if custom_sprite != null:
		draw_texture_rect(custom_sprite, Rect2(0, 0, 1920, 1080), false)
	if hit_flash > 0:
		draw_rect(Rect2(0, 0, 1920, 1080), Color(0.85, 0.16, 0.10, hit_flash * 0.75))
	# Header: restrained game typography, warm paper and relief rules.
	CelArt.label(self, Vector2(85, 57), "AFETE HAZIRLIK / BÖLÜM 01", 15, Color("a7baae"))
	CelArt.label(self, Vector2(82, 105), "AFET KUŞATMASI", 43, Color("f0deba"))
	CelArt.line(self, Vector2(86, 122), Vector2(463, 122), CelArt.GOLD, 3)
	CelArt.label(self, Vector2(86, 147), "DISASTER SIEGE", 16, Color("b5c2b4"))
	CelArt.rect(self, Rect2(1471, 32, 361, 127), Color("0f151a"), 2.5)
	var area_label: String = "HAZIRLIK ALANI" if waves == null or waves.state != DisasterWaveManager.State.SIEGE_PHASE else "KUŞATMA ALTINDA"
	if waves != null and waves.victory: area_label = "AFET ATLATILDI"
	CelArt.label(self, Vector2(1492, 59), area_label, 15, Color("cad3bd"))
	CelArt.label(self, Vector2(1713, 59), "KAT %02d" % player.current_floor, 15, CelArt.GOLD)
	_meter(Vector2(1492, 83), 157, player.health / player.max_health, Color("91bc8d"), "CAN")
	_meter(Vector2(1663, 83), 147, player.stamina / 100.0, CelArt.GOLD, "TAKLA ENERJİSİ")
	# Building integrity = average room HP; collapsed rooms count toward the 4-room limit.
	var collapsed: int = building.collapsed_count()
	var integrity_ratio: float = building.integrity / building.max_integrity
	var integrity_color: Color = Color("80aca7") if integrity_ratio > 0.5 else (Color("e0b04c") if integrity_ratio > 0.25 else Color("ff5a4a"))
	var integrity_title: String = "BİNA DAYANIKLILIĞI"
	if collapsed > 0:
		integrity_title += "  ·  YIKIK ODA %d/%d" % [collapsed, building.collapse_limit]
	_meter(Vector2(1492, 122), 318, integrity_ratio, integrity_color, integrity_title)
	_draw_wave_bar()
	_draw_inventory()
	var message: String = "2x W: ÜST KATA ZIPLA   ·   S: ALT KATA İN"
	var message_color: Color = Color("bac7b7")
	var room: RoomDiorama = loot.current_room() if loot != null else null
	if player.is_dashing:
		message = "TAKLA  /  DOKUNULMAZ"
		message_color = CelArt.TEAL
	elif player.hit_invulnerability > 0:
		message = "İSABET  /  KISA KORUMA"
	elif player.is_shifting:
		message = "KAT GEÇİŞİ  " + ("↑ ÜST KAT" if player.shift_direction > 0 else "↓ ALT KAT")
		message_color = Color("9fd6dc")
	elif loot != null and loot.can_offer_repair():
		message = loot.interaction_hint()
		message_color = CelArt.GOLD
	elif loot != null and loot.can_build():
		message = loot.interaction_hint()
		message_color = CelArt.TEAL
	elif room != null and room.state() == RoomDiorama.RoomState.CRITICAL:
		message = "ODA ÇÖKMEK ÜZERE  /  ONARIM MALZEMESİ BUL"
		message_color = Color("ff6a4a")
	elif absf(player.wind_velocity) > 25.0:
		message = "RÜZGÂR İTİYOR  /  KOŞ VEYA TAKLA İLE DİREN"
		message_color = Color("9fd6dc")
	CelArt.label(self, Vector2(1004, 994), message, 11, message_color)
	CelArt.label(self, Vector2(1532, 994), ("TEST AÇIK: 1–5 BOSS · U KART" if waves.debug_enabled else "[F] HAZIRIM · [F9] TEST MODU"), 11, Color("c2cdb8"))
	CelArt.rect(self, Rect2(150, 1004, 1620, 68), Color("11181d"))
	CelArt.line(self, Vector2(150, 1004), Vector2(1770, 1004), Color("809283"), 2)
	for control: Array in CONTROLS:
		_control(Vector2(float(control[0]), 1030), control[1], control[2])
	if waves != null:
		_control(Vector2(1500, 1030), "KAÇINIŞ  %02d" % waves.dodge_count, "DASH İLE GERÇEK TEMAS")
		if waves.victory:
			draw_rect(Rect2(0,0,1920,1080),Color(.02,.05,.06,.6))
			CelArt.rect(self,Rect2(415,375,1090,300),Color("10252a"),3.0)
			CelArt.label(self,Vector2(464,438),"5 BÜYÜK AFET KUŞATMASI ATLATILDI!",32,Color("b0f1c7"))
			CelArt.label(self,Vector2(464,498),"TAM HAZIRLIK ZAFERİ!",39,CelArt.PAPER)
			CelArt.label(self,Vector2(464,550),"5 / 5 DALGA  ·  AYAKTA KALAN ODA: %d / 16" % [16 - collapsed],22,CelArt.GOLD)
			CelArt.label(self,Vector2(464,615),"R: YENİ OYUN     ·     F9: TEST MODU",18,Color("bad5cd"))
		if waves.failed:
			CelArt.rect(self, Rect2(609, 442, 702, 163), Color("11181d"))
			if waves.fail_reason == DisasterWaveManager.FailReason.BUILDING:
				CelArt.rect(self, Rect2(609, 442, 702, 163), Color(1.0, 0.25, 0.2, 0.08), 0)
				CelArt.label(self, Vector2(646, 493), "BİNA ÇÖKTÜ!", 34, Color("ff5a4a"))
				CelArt.label(self, Vector2(647, 532), "ODALARI ZAMANINDA ONARAMADIN.", 22, CelArt.PAPER)
				CelArt.label(self, Vector2(647, 568), "R ile hazırlan ve yeniden dene · %d oda yıkıldı." % collapsed, 17, Color("a7b8a9"))
			else:
				CelArt.label(self, Vector2(646, 493), "KUŞATMA SONLANDI", 31, Color("e9b981"))
				CelArt.label(self, Vector2(647, 532), "R ile hazırlan ve yeniden dene.", 22, CelArt.PAPER)
				CelArt.label(self, Vector2(647, 565), "F9 ile test modunu aç; 1 / 2 / 3 / 4 / 5 boss seçer.", 17, Color("a7b8a9"))

## Four readable equipment summaries; the first two are stocked E-action kits.
func _draw_inventory() -> void:
	if loot == null:
		return
	for kind: int in range(4):
		var x: float = 169.0+kind*205.0
		var aura: Color = LootSystem.AURA[kind]
		draw_set_transform(Vector2(x,983),0,Vector2.ONE*.55)
		EquipmentArt.draw_kit(self,kind,_clock)
		draw_set_transform(Vector2.ZERO)
		var title: String = "%s ×%d" % [LootSystem.short_name(kind),loot.count_kind(kind)]
		if kind == LootSystem.Kind.EMERGENCY_BAG: title = "ÇANTA · +25 CAN"
		if kind == LootSystem.Kind.SAFETY_KIT: title = "GÜVENLİK · %d ODA" % loot.safety_installs
		CelArt.label(self,Vector2(x+20,980),title,13,aura)
		CelArt.label(self,Vector2(x+20,997),LootSystem.purpose(kind),10,Color("adbfba"))

func _draw_wave_bar() -> void:
	if waves == null:
		return
	var preparing: bool = waves.state in [DisasterWaveManager.State.PREPARATION_PHASE, DisasterWaveManager.State.BUILD_PREPARATION_PHASE]
	var time_left: float = waves.preparation_remaining if preparing else waves.siege_remaining
	if waves.state in [DisasterWaveManager.State.WAVE_INTRO, DisasterWaveManager.State.WAVE_OUTRO]: time_left = waves.transition_remaining
	var duration: float = waves.build_duration if waves.state == DisasterWaveManager.State.BUILD_PREPARATION_PHASE else waves.preparation_duration
	var ratio: float = time_left / duration if preparing else waves.boss_endurance / 100.0
	var accent: Color = CelArt.TEAL if preparing else Color("dba06b")
	CelArt.rect(self, Rect2(580, 32, 800, 85), Color("11181d"))
	CelArt.rect(self, Rect2(580, 32, 5, 85), accent, 0)
	CelArt.label(self, Vector2(605, 55), waves.phase_label(), 14, accent)
	var title: String = "SONRAKİ: " if preparing else "AFET DALGASI %02d: " % waves.wave_number
	if waves.victory:
		title = "5 / 5 TAMAMLANDI: "
		ratio = 1.0
	CelArt.label(self, Vector2(605, 82), title + waves.boss_name(), 18, CelArt.PAPER)
	CelArt.label(self, Vector2(1310, 55), "ZAFER" if waves.victory else "%02d sn" % ceili(time_left), 19, CelArt.GOLD)
	CelArt.rect(self, Rect2(605, 96, 748, 9), Color("111e22"), 1)
	CelArt.rect(self, Rect2(607, 98, 744 * clampf(ratio, 0, 1), 5), accent, 0)

func _meter(point: Vector2, width: float, ratio: float, color: Color, title: String) -> void:
	CelArt.label(self, point, title, 11, Color("8fa69b"))
	CelArt.rect(self, Rect2(point + Vector2(0, 8), Vector2(width, 12)), Color("111e22"), 1.5)
	CelArt.rect(self, Rect2(point + Vector2(2, 10), Vector2((width - 4) * clampf(ratio, 0, 1), 8)), color, 0)
	for i: int in range(1, 8):
		CelArt.line(self, point + Vector2(width * i / 8.0, 9), point + Vector2(width * i / 8.0, 19), Color("11181d"), 2)

func _control(point: Vector2, keys: String, title: String) -> void:
	CelArt.label(self, point, keys, 15, CelArt.GOLD)
	CelArt.label(self, point + Vector2(0, 22), title, 12, Color("c7cdb9"))
