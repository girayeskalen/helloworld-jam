class_name SiegeArtAssets
extends Resource
## Persistent drag/drop slots, shared by procedurally spawned components.

@export_group("Scene")
@export var building: Texture2D
@export var room: Texture2D
@export var background: Texture2D
@export var player: Texture2D
@export var hud: Texture2D
@export_group("Objects")
@export var pillar: Texture2D
@export var window: Texture2D
@export var sofa: Texture2D
@export var bookcase: Texture2D
@export var table: Texture2D
@export var gas_valve: Texture2D
@export var electrical: Texture2D
@export var lamp: Texture2D
@export var plant: Texture2D
@export var kitchen: Texture2D
@export_group("Individual overrides by object_id")
@export var object_overrides: Dictionary = {}

func texture_for_prop(kind: BuildingProp.Kind, object_id: StringName) -> Texture2D:
	var override: Variant = object_overrides.get(String(object_id))
	if override is Texture2D:
		return override as Texture2D
	match kind:
		BuildingProp.Kind.PILLAR: return pillar
		BuildingProp.Kind.WINDOW: return window
		BuildingProp.Kind.SOFA: return sofa
		BuildingProp.Kind.BOOKCASE: return bookcase
		BuildingProp.Kind.TABLE: return table
		BuildingProp.Kind.GAS_VALVE: return gas_valve
		BuildingProp.Kind.ELECTRICAL: return electrical
		BuildingProp.Kind.LAMP: return lamp
		BuildingProp.Kind.PLANT: return plant
		BuildingProp.Kind.KITCHEN: return kitchen
	return null
