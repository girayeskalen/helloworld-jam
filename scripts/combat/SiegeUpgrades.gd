class_name SiegeUpgrades
extends Node
## Run-scoped upgrades. Percentages are game balance, not engineering specifications.

signal selection_changed
signal upgrade_selected(id: int)

enum Kind { DASH_REPAIR, AUTO_DRONE, SLAM_SHIELD, DEFLECTOR, GRAPPLE_DASH,
	CHAIN_REPAIR, ADRENALINE_REFLEX, ROOF_TURRET, LOOT_MAGNET }
const CATALOG: Array[Dictionary] = [
	{"title": "Takla-Onarım Modülü", "tag": "DASH / ONARIM", "effect": "Uyarılı odadan takla ile geç: 1 malzeme harcayarak +45 HP onar, takla enerjini doldur.", "note": "Önce çimento, yoksa başka inşaat kiti kullanır.", "color": Color("ffbd60")},
	{"title": "Otonom Tamir Dronu", "tag": "UÇAN YARDIMCI", "effect": "Dron uzaktaki malzemeyi ışınla toplar. Her 12 saniyede en hasarlı odaya uçup bedava +45 HP onarır.", "note": "Dronun ışığını takip et; yıkık odayı kuramaz.", "color": Color("59e1ce")},
	{"title": "Sismik Çizme & Şok İnişi", "tag": "KAT / MERMİ TEMİZLEME", "effect": "S ile inerken veya ikinci W ile çıkarken hedef katta şok halkası açılır; o katın tüm mermileri dağılır.", "note": "Yeni saldırılar için uyarılar devam eder.", "color": Color("efa573")},
	{"title": "Rüzgar Türbini & Saptırıcı", "tag": "PENCERE SAVUNMASI", "effect": "Kepenkli pencerelerde türbin döner. Çarpan mermiyi enerjiye ve malzeme parçasına dönüştürür.", "note": "Her isabet +6 enerji; 3 parça = 1 çimento.", "color": Color("70caff")},
	{"title": "Çelik Halat Kancası", "tag": "HAYALET TAKLA", "effect": "Takla mesafesi %60 uzar; duvar ve katlardan geçer. Elektrikli izin içindeki mermiler yavaşlar.", "note": "İz 0,9 sn kalır; bina dışına çıkamazsın.", "color": Color("b0a1f4")},
	{"title": "Merkezi Harç Pompası", "tag": "ZİNCİR ONARIM", "effect": "E ile onar veya güçlendir: dört yöndeki komşular +22,5 HP ve yarım çelik destek kazanır.", "note": "Yarım destek %27,5 zırhtır; eşya sabitlemez.", "color": Color("91dbb1")},
	{"title": "Acil Durum Zaman Bükücü", "tag": "PERFECT DODGE", "effect": "Çarpmaya son 0,15 sn kala takla: zaman 1,5 sn yarı hızda akar, yanına 1 malzeme düşer.", "note": "Her takla için en fazla bir ödül.", "color": Color("e9a0dd")},
	{"title": "Paratoner & Lazer Kulesi", "tag": "ÇATI SAVUNMASI", "effect": "Çatıda lazer kulesi kurulur. Her 3 saniyede en tehlikeli büyük enkazı hedefleyip havada patlatır.", "note": "Büyük hedef yoksa atışı hazırda tutar.", "color": Color("f1e694")},
	{"title": "Manyetik Kargo Çekici", "tag": "MALZEME / KALKAN", "effect": "Yerdeki malzemeler sana kayar; ömürleri 4 → 8 sn. Her toplama 2 sn hız ve kalkan verir.", "note": "Mıknatıs yakındaki katlardan da çekebilir.", "color": Color("42e1d0")},
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
	for room: RoomDiorama in game.building.rooms:
		room.max_hp = RoomDiorama.MAX_HP
		room.utilities_isolated = false
	selection_changed.emit()

func has_upgrade(id: int) -> bool:
	return selected.has(id)

func open_selection() -> bool:
	if pending:
		return false
	var available: Array[int] = []
	for id: int in range(CATALOG.size()):
		if not selected.has(id): available.append(id)
	if available.is_empty():
		return false
	offers.clear()
	for slot: int in range(mini(3, available.size())):
		var index: int = _rng.randi_range(0, available.size() - 1)
		offers.append(available[index])
		available.remove_at(index)
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
	if id == Kind.LOOT_MAGNET: game.loot.loot_lifetime = 8.0
	if game.mechanics != null: game.mechanics.upgrade_added(id)
	return true

func damage_multiplier(_attack: HazardAttack) -> float:
	return 1.0

func prepare_attack(attack: HazardAttack) -> HazardAttack:
	return attack.frozen_copy()
