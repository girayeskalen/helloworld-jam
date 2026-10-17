class_name SiegeUpgrades
extends Node
## Run-scoped upgrades. Percentages are game balance, not engineering specifications.

signal selection_changed
signal upgrade_selected(id: int)

enum Kind { DASH_REPAIR, AUTO_DRONE, SLAM_SHIELD, DEFLECTOR, GRAPPLE_DASH,
	CHAIN_REPAIR, ADRENALINE_REFLEX, ROOF_TURRET, LOOT_MAGNET, SPRINKLER, DRAINAGE, AWARE_BAG, AWARE_ANCHOR, AWARE_STRUCTURE, AWARE_UTILITIES, AWARE_FLOOD, RESCUE_BOOTS, EPOXY_SHIELD, EARLY_WARNING }
const AWARENESS: Array[int] = [Kind.AWARE_BAG,Kind.AWARE_ANCHOR,Kind.AWARE_STRUCTURE,Kind.AWARE_UTILITIES,Kind.AWARE_FLOOD]
const CATALOG: Array[Dictionary] = [
	{"title": "Takla-Onarım Modülü", "tag": "DASH / ONARIM", "effect": "Uyarılı odadan takla ile geç: 1 malzeme harcayarak +45 HP onar, takla enerjini doldur.", "note": "Ağır eşyaları uygun bağlantılarla sabitlemek yaralanma riskini azaltır.", "color": Color("ffbd60")},
	{"title": "Otonom Kargo & Arama-Kurtarma Dronu", "tag": "UÇAN YARDIMCI", "effect": "Loot ömrü 4 → 7 sn, toplama erişimi ×2,5. Dron yerdeki kargoyu toplar; her 12 sn bedava +45 HP onarır.", "note": "Drone ve robotlar afet tehlikelerinin uzaktan tespitinde kullanılabilir.", "color": Color("59e1ce")},
	{"title": "Sismik Çizme & Şok İnişi", "tag": "KAT / MERMİ TEMİZLEME", "effect": "S ile inerken veya ikinci W ile çıkarken hedef katta şok halkası açılır; o katın tüm mermileri dağılır.", "note": "Sarsıntı sürerken merdivene koşma; bulunduğun yerde Çök-Kapan-Tutun uygula.", "color": Color("efa573")},
	{"title": "Rüzgar Türbini & Saptırıcı", "tag": "PENCERE SAVUNMASI", "effect": "Kepenkli pencerelerde türbin döner. Çarpan mermiyi enerjiye ve malzeme parçasına dönüştürür.", "note": "Pencerelerden ve düşebilecek eşyalardan uzak dur.", "color": Color("70caff")},
	{"title": "Çelik Halat Kancası", "tag": "HAYALET TAKLA", "effect": "Takla mesafesi %60 uzar; duvar ve katlardan geçer. Elektrikli izin içindeki mermiler yavaşlar.", "note": "Tahliye yollarını önceden belirle ve geçişleri eşyalardan arındır.", "color": Color("b0a1f4")},
	{"title": "Merkezi Harç Pompası", "tag": "ZİNCİR ONARIM", "effect": "E ile onar veya güçlendir: dört yöndeki komşular +22,5 HP ve yarım çelik destek kazanır.", "note": "Hasarlı yapının güvenliğini uzman değerlendirmesi olmadan varsayma.", "color": Color("91dbb1")},
	{"title": "Acil Durum Zaman Bükücü", "tag": "PERFECT DODGE", "effect": "Çarpmaya son 0,15 sn kala takla: zaman 1,5 sn yarı hızda akar, yanına 1 malzeme düşer.", "note": "Deprem davranışını önceden prova etmek doğru tepki vermeyi kolaylaştırır.", "color": Color("e9a0dd")},
	{"title": "Paratoner & Lazer Kulesi", "tag": "ÇATI SAVUNMASI", "effect": "Çatıda lazer kulesi kurulur. Her 3 saniyede en tehlikeli büyük enkazı hedefleyip havada patlatır.", "note": "Fırtına uyarılarını izle ve sağlam kapalı alanlarda kal.", "color": Color("f1e694")},
	{"title": "Manyetik Kargo Çekici", "tag": "MALZEME / KALKAN", "effect": "Yerdeki malzemeler sana kayar; ömürleri 4 → 8 sn. Her toplama 2 sn hız ve kalkan verir.", "note": "Acil çantanın yerini evdeki herkes bilmeli ve çanta kolay ulaşılabilir olmalı.", "color": Color("42e1d0")},
	{"title": "Otomatik Sprinkler & Söndürme", "tag": "YANGIN HAZIRLIĞI", "effect": "Yangın mermisi ve oda hasarı %40 azalır. Zemindeki alevlerin süresi 3 → 1,8 saniye olur.", "note": "Gaz ve elektrik kesicilerinin yerini ve güvenli kullanımını önceden öğren.", "color": Color("ff9160")},
	{"title": "Dalgakıran & Drenaj Pompası", "tag": "SEL HAZIRLIĞI", "effect": "Su mermisi ve oda hasarı %40 azalır. Taşkının koşu yavaşlatması %35 → %21 düşer.", "note": "Sel suyunda yürümeye veya araçla geçmeye çalışma.", "color": Color("55e2db")},
	{"title":"72 Saatlik Tam Donanımlı Afet Çantası","tag":"CAN / DALGA DESTEĞİ","effect":"Maksimum can +30; canın tamamen dolar. Her dalga başında +15 can yenilenir.","note":"72 saatlik çantanı su, dayanıklı gıda, ilk yardım, fener, pil ve düdükle hazırla.","color":Color("70e3ad")},
	{"title":"L-Demir Eşya Sabitleme & Çök-Kapan-Tutun","tag":"EŞYA / YARALANMA RİSKİ","effect":"Rastgele 4 ayakta odanın tüm eşyaları sabitlenir. Devrilen eşya hasarı %40 azalır.","note":"Ağır eşyaları sabitle; sarsıntı sırasında Çök-Kapan-Tutun uygula.","color":Color("69c9f5")},
	{"title":"Karbon Fiber (FRP) Kolon Mantolama & Sismik İzolatör","tag":"YAPISAL DAYANIKLILIK","effect":"Tüm odaların maksimum HP'si +30. Hasarlı odalar +35 onarılır; deprem ve yapısal aşınma hasarı %35 azalır.","note":"Yapı güçlendirmesi, uzman mühendislerin inceleme ve projesini gerektirir.","color":Color("ffc76a")},
	{"title":"Otomatik Gaz Kesici Vana & Duman Dedektörü","tag":"İKİNCİL YANGIN ÖNLEMİ","effect":"Gaz/elektrik kaynaklı ikincil hasar ve zemin alevi hasarı %45 azalır.","note":"Gaz ve elektrik kesicilerini önceden tanı; sarsıntı bitince güvenle kapat.","color":Color("f49771")},
	{"title":"Taşkın Bariyeri, Çekvalf & Tahliye Pompası","tag":"SEL / PENCERE SAVUNMASI","effect":"Taşkın koşuyu yavaşlatmaz. Panjurun fırtına/sel bloklaması %50 → %70 olur.","note":"Sel suyuna girme; su yatağı ve çukur alanlardan yüksek, güvenli yere çık.","color":Color("58e1db")},
	{"title":"Pnömatik Kurtarma Botları & Kevlar Yelek","tag":"HIZ / DOKUNULMAZ TAKLA","effect":"Koşu +%18, dash bekleme süresi −%30, dash dokunulmazlığı 0,25 → 0,35 sn.","note":"Koruyucu bot ve eldiven, arama-kurtarma ekipmanının bir parçasıdır.","color":Color("b6b0ff")},
	{"title":"Hızlı Epoksi Enjeksiyon Tabancası & Kalkan Jeneratörü","tag":"GÜÇLÜ ONARIM / KALKAN","effect":"E onarımı +45 → +85 HP. Onarım yaptığında 2,5 sn mermi koruması kazanırsın.","note":"Hasarlı binaya girme; inceleme ve onarımı yetkin uzmanlara bırak.","color":Color("e8b7e8")},
	{"title":"Erken Uyarı Sismograf & Meteoroloji Radarı","tag":"TELGRAF / İKMAL","effect":"Tüm uyarılar +0,25 sn; mermiler %12 yavaşlar. Her dalga başında +2 inşaat kiti gelir.","note":"Sarsıntıda Çök-Kapan-Tutun uygula; tahliye için sarsıntının bitmesini bekle.","color":Color("9edfe9")},
]

var game: MainGame
var selected: Array[int] = []
var offers: Array[int] = []
var pending: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _baseline: Dictionary = {}

func configure(owner_game: MainGame) -> void:
	game = owner_game
	_rng.randomize()
	_baseline = {"health": game.player.max_health, "run": game.player.run_speed,
		"cooldown": game.player.dash_cooldown, "duration": game.player.dash_duration,
		"repair": game.loot.repair_amount, "lifetime": game.loot.loot_lifetime,
		"radius": game.loot.pickup_radius}

func reset() -> void:
	pending = false
	offers.clear()
	selected.clear()
	if game == null:
		return
	if game.mechanics != null: game.mechanics.reset()
	game.player.grapple_enabled = false
	game.player.speed_boost = 0.0
	game.player.controls_locked = false
	game.player.max_health = _baseline["health"]
	game.player.health = minf(game.player.health, game.player.max_health)
	game.player.run_speed = _baseline["run"]
	game.player.dash_cooldown = _baseline["cooldown"]
	game.player.dash_duration = _baseline["duration"]
	game.player.repair_shield = 0.0
	game.loot.repair_amount = _baseline["repair"]
	game.loot.loot_lifetime = _baseline["lifetime"]
	game.loot.pickup_radius = _baseline["radius"]
	game.loot.repair_shield_duration = 0.0
	game.telegraphs.warning_bonus = 0.0
	game.building.lighting.generator_boost = 1.0
	game.building.structural_factor = 1.0
	game.building.secondary_factor = 1.0
	_rewarded_wave = 0
	for room: RoomDiorama in game.building.rooms:
		room.max_hp = RoomDiorama.MAX_HP
		room.utilities_isolated = false
		room.shutter_block = .5
		room.flood_barrier_bonus = 0.0
		room.auto_protection = false
	selection_changed.emit()

func has_upgrade(id: int) -> bool:
	return selected.has(id)

func open_selection() -> bool:
	if pending:
		return false
	var awareness: Array[int] = []
	var action: Array[int] = []
	for id: int in range(CATALOG.size()):
		if selected.has(id): continue
		if is_awareness(id): awareness.append(id)
		else: action.append(id)
	if awareness.is_empty() or action.size() < 2: return false
	offers.assign([awareness[_rng.randi_range(0,awareness.size()-1)]])
	for slot: int in range(2):
		var index: int = _rng.randi_range(0,action.size()-1)
		offers.append(action[index])
		action.remove_at(index)
	pending = true
	game.player.controls_locked = true
	selection_changed.emit()
	return true

func choose(slot: int) -> bool:
	if not pending or slot < 0 or slot >= offers.size():
		return false
	var id: int = offers[slot]
	if not apply_upgrade(id):
		return false
	pending = false
	offers.clear()
	game.player.controls_locked = false
	selection_changed.emit()
	upgrade_selected.emit(id)
	return true

func apply_upgrade(id: int) -> bool:
	if id < 0 or id >= CATALOG.size() or selected.has(id):
		return false
	selected.append(id)
	if id == Kind.GRAPPLE_DASH: game.player.grapple_enabled = true
	if id in [Kind.LOOT_MAGNET,Kind.AUTO_DRONE]:
		game.loot.loot_lifetime = 8.0 if has_upgrade(Kind.LOOT_MAGNET) else 7.0
	if id == Kind.AUTO_DRONE: game.loot.pickup_radius = float(_baseline["radius"])*2.5
	if id == Kind.RESCUE_BOOTS:
		game.player.run_speed = float(_baseline["run"])*1.18
		game.player.dash_cooldown = float(_baseline["cooldown"])*.7
		game.player.dash_duration = .35
	if id == Kind.EPOXY_SHIELD:
		game.loot.repair_amount = 85.0
		game.loot.repair_shield_duration = 2.5
	if id == Kind.EARLY_WARNING: game.telegraphs.warning_bonus = .25
	if id == Kind.AWARE_BAG:
		game.player.max_health += 30.0
		game.player.health = game.player.max_health
	if id == Kind.AWARE_ANCHOR:
		var rooms: Array[RoomDiorama] = []
		for room: RoomDiorama in game.building.rooms:
			if not room.is_collapsed(): rooms.append(room)
		for i: int in range(mini(4,rooms.size())):
			var index: int = _rng.randi_range(0,rooms.size()-1)
			rooms[index].reinforce(RoomDiorama.Reinforcement.ANCHOR)
			rooms.remove_at(index)
	if id == Kind.AWARE_STRUCTURE:
		for room: RoomDiorama in game.building.rooms:
			var damaged: bool = room.hp > 0.0 and room.hp < room.max_hp
			room.max_hp += 30.0
			if damaged: room.repair(35.0)
			room._refresh_state(true)
		game.building.structural_factor = .65
	if id == Kind.AWARE_UTILITIES: game.building.secondary_factor = .55
	if id == Kind.AWARE_FLOOD:
		for room: RoomDiorama in game.building.rooms: room.flood_barrier_bonus = .2
		for a: HazardAttack in game.telegraphs.pending:
			if a.kind == HazardAttack.Kind.FLOOD_ZONE: a.effect_strength = 0.0
		for shot: HazardProjectile in game.projectiles.entries:
			if shot.active and shot.attack.kind == HazardAttack.Kind.FLOOD_ZONE: shot.attack.effect_strength = 0.0
		game.player.hazard_drag = 0.0
	if game.mechanics != null: game.mechanics.upgrade_added(id)
	return true

func damage_multiplier(attack: HazardAttack) -> float:
	var factor: float = 1.0
	if attack.source == 1 and has_upgrade(Kind.AWARE_STRUCTURE): factor *= .65
	if attack.pattern == HazardAttack.Pattern.ROOM_OBJECT and has_upgrade(Kind.AWARE_ANCHOR): factor *= .6
	if attack.kind == HazardAttack.Kind.FIRE_ZONE and has_upgrade(Kind.AWARE_UTILITIES): factor *= .55
	if attack.source == 2 and has_upgrade(Kind.DRAINAGE): factor *= .6
	if attack.source == 3 and has_upgrade(Kind.SPRINKLER): factor *= .6
	return factor

func prepare_attack(attack: HazardAttack) -> HazardAttack:
	var copy: HazardAttack = attack.frozen_copy()
	copy.damage *= damage_multiplier(attack)
	if copy.kind == HazardAttack.Kind.FIRE_ZONE and has_upgrade(Kind.SPRINKLER): copy.lifetime *= .6
	if copy.kind == HazardAttack.Kind.FLOOD_ZONE:
		if has_upgrade(Kind.AWARE_FLOOD): copy.effect_strength = 0.0
		elif has_upgrade(Kind.DRAINAGE): copy.effect_strength *= .6
	return copy

static func is_awareness(id: int) -> bool:
	return AWARENESS.has(id)

var _rewarded_wave: int = 0
func begin_wave() -> void:
	if _rewarded_wave == game.waves.wave_number: return
	_rewarded_wave = game.waves.wave_number
	if has_upgrade(Kind.AWARE_BAG): game.player.health = minf(game.player.max_health,game.player.health+15.0)
	if has_upgrade(Kind.EARLY_WARNING):
		game.loot.grant(LootSystem.Kind.COLUMN_KIT)
		game.loot.grant(LootSystem.Kind.BARRICADE_KIT)
		game.loot._message(game.player.global_position+Vector2(-90,-150),"RADAR İKMALİ · +2 İNŞAAT KİTİ",Color("9edfe9"))
