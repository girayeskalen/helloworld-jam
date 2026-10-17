class_name SiegeUpgrades
extends Node
## Nine active modules. Educational notes never promise real shields or engineering success.
signal selection_changed
signal upgrade_selected(id: int)
enum Kind { DOME, AWARE_BAG, AWARE_STRUCTURE, SONIC_DASH, AUTO_DRONE,
	GRAZE_TIME, ORBITALS, SLAM_SHIELD, REMOTE_CRANE }
const AWARENESS: Array[int] = [Kind.DOME, Kind.AWARE_BAG, Kind.AWARE_STRUCTURE]
const CATALOG: Array[Dictionary] = [
	{"title":"Çök-Kapan-Tutun Kalkanı", "tag":"KORUYUCU KUBBE", "effect":"Sabit dur, kalkan aç; ilk mermiyi hasarsız engelle.", "note":"AFAD: Başını ve boynunu koru; Çök-Kapan-Tutun.", "source":"afad_quake", "color":Color("b7e97b")},
	{"title":"72 Saatlik Afet Çantası", "tag":"ACİL KURTARMA", "effect":"Canın düşünce çantan iyileştirir, mermileri temizler ve seni hızlandırır.", "note":"AFAD: Çantana su, gıda, ilk yardım, fener, düdük koy.", "source":"afad_bag", "color":Color("71e5ac")},
	{"title":"L-Demir & Karbon Manto", "tag":"ZIRHLI ODA", "effect":"Onardığın odalar mermileri engeller; içeride takla enerjin hızla dolar.", "note":"AFAD: Eşyaları sabitle; yapı incelemesini uzmanlara bırak.", "source":"afad_quake", "color":Color("e6bf76")},
	{"title":"Sonik Takla", "tag":"MERMİ YARAN DASH", "effect":"Taklayla dokunduğun mermileri parçala; bitişte şok halkası yay.", "note":"AFAD: Tahliye yollarını önceden belirle, geçişleri açık tut.", "source":"afad_quake", "color":Color("6bdcf4")},
	{"title":"Otonom Onarım Dronu", "tag":"UÇAN YARDIMCI", "effect":"Uçan dron malzemeleri sana çeker, hasarlı odaları ücretsiz onarır.", "note":"AFAD: Afet öncesinde hazırlık yap, resmî duyuruları izle.", "source":"afad_quake", "color":Color("71e5d2")},
	{"title":"Zaman Bükücü Sismograf", "tag":"SIYRILMA KUBBESİ", "effect":"Mermiden sıyrıl; zaman kubbesi yakınındaki mermileri yavaşlatsın.", "note":"USGS: Erken uyarı, deprem tahmini değildir.", "source":"usgs_warning", "color":Color("8cb9ff")},
	{"title":"Hidrolik Kalkan Küreleri", "tag":"İKİ ÇELİK UYDU", "effect":"Etrafında dönen iki kalkan küresi temas eden mermileri yok eder.", "note":"AFAD: Sarsıntıda başını ve boynunu koru.", "source":"afad_quake", "color":Color("bda4ff")},
	{"title":"Sismik Çivi Botları", "tag":"KAT GEÇİŞ ŞOKU", "effect":"Kat geçişinde korun; indiğin odanın mermilerini temizle, odayı onar.", "note":"AFAD: Sarsıntı sırasında merdivene veya çıkışa koşma.", "source":"afad_quake", "color":Color("e8bc7c")},
	{"title":"Uzaktan Lazer Vinç", "tag":"ÇİFT ODA ONARIMI", "effect":"E ile tek malzemeden iki uzak odayı onar, mermileri dondur.", "note":"AFAD: Hasarlı binaya girme; uzman incelemesini bekle.", "source":"afad_quake", "color":Color("c3a0ef")},
]
var game: MainGame
var selected: Array[int] = []
var offers: Array[int] = []
var pending: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func configure(owner_game: MainGame) -> void:
	game = owner_game
	_rng.randomize()

func reset() -> void:
	pending = false
	offers.clear()
	selected.clear()
	if game != null:
		if game.mechanics != null: game.mechanics.reset()
		game.player.controls_locked = false
		for room: RoomDiorama in game.building.rooms: room.set_bullet_armor(false)
	selection_changed.emit()

func has_upgrade(id: int) -> bool:
	return selected.has(id)

static func is_awareness(id: int) -> bool:
	return AWARENESS.has(id)

func open_selection() -> bool:
	if pending: return false
	var awareness: Array[int] = []
	var action: Array[int] = []
	for id: int in range(CATALOG.size()):
		if selected.has(id): continue
		if is_awareness(id): awareness.append(id)
		else: action.append(id)
	if awareness.is_empty() or action.size() < 2: return false
	offers.assign([awareness[_rng.randi_range(0, awareness.size()-1)]])
	for slot: int in range(2):
		var index: int = _rng.randi_range(0, action.size()-1)
		offers.append(action[index])
		action.remove_at(index)
	pending = true
	game.player.controls_locked = true
	selection_changed.emit()
	return true

func choose(slot: int) -> bool:
	if not pending or slot < 0 or slot >= offers.size(): return false
	var id: int = offers[slot]
	if not apply_upgrade(id): return false
	pending = false
	offers.clear()
	game.player.controls_locked = false
	selection_changed.emit()
	upgrade_selected.emit(id)
	return true

func apply_upgrade(id: int) -> bool:
	if id < 0 or id >= CATALOG.size() or selected.has(id): return false
	selected.append(id)
	if game.mechanics != null: game.mechanics.upgrade_added(id)
	return true

func damage_multiplier(_attack: HazardAttack) -> float:
	return 1.0

func prepare_attack(attack: HazardAttack) -> HazardAttack:
	return attack.frozen_copy()

func begin_wave() -> void:
	if game.mechanics != null: game.mechanics.begin_wave()
