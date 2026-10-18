class_name SiegeUpgrades
extends Node
## Nine active modules. Each card shows a short name and one plain effect line.
signal selection_changed
signal upgrade_selected(id: int)
enum Kind { DOME, AWARE_BAG, AWARE_STRUCTURE, SONIC_DASH, AUTO_DRONE,
	GRAZE_TIME, ORBITALS, SLAM_SHIELD, REMOTE_CRANE }
const AWARENESS: Array[int] = [Kind.DOME, Kind.AWARE_BAG, Kind.AWARE_STRUCTURE]
const CATALOG: Array[Dictionary] = [
	{"title":"Sakin Kal", "effect":"Kısa süre durunca bir isabeti engeller.", "color":Color("b7e97b")},
	{"title":"Afet Çantası", "effect":"Can azalınca bir kez iyileştirir.", "color":Color("71e5ac")},
	{"title":"Güçlü Oda", "effect":"Onardığın odalar mermi tutar.", "color":Color("e6bf76")},
	{"title":"Sonik Takla", "effect":"Takla değdiği mermiyi siler.", "color":Color("6bdcf4")},
	{"title":"Onarım Dronu", "effect":"Odaları onarır, malzeme getirir.", "color":Color("71e5d2")},
	{"title":"Ağır Çekim", "effect":"Sıyrılınca yakın mermiler yavaşlar.", "color":Color("8cb9ff")},
	{"title":"Yörünge Küreleri", "effect":"Etrafında dönen iki küre mermi siler.", "color":Color("bda4ff")},
	{"title":"Çelik Botlar", "effect":"Kat değiştirirken korur, odayı temizler.", "color":Color("e8bc7c")},
	{"title":"Uzaktan Vinç", "effect":"Tek kitle iki odayı uzaktan onarır.", "color":Color("c3a0ef")},
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
