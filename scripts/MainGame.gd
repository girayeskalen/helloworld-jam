class_name MainGame
extends Node2D

@export var art_assets: SiegeArtAssets
## The world renders into a low-resolution SubViewport and is upscaled with nearest
## filtering, so the procedural art lands on a real pixel grid. 1 disables it.
@export_range(1, 4) var pixel_scale: int = 2
## World units per screen pixel before pixelation (fits the 4x4 building + bosses).
@export var base_zoom: float = 0.78
## Hand-made PNGs placed here replace the procedural art (see AssetRegistry).
@export var sprite_directory: String = AssetRegistry.DIRECTORY
## Blackout: rooms keep ~50% of their painted brightness, with a cold cast.
@export var night_tint: Color = Color(0.5, 0.53, 0.6)
@export var flash_tint: Color = Color(0.92, 0.95, 1.0)

@onready var world_container: SubViewportContainer = $World
@onready var world_viewport: SubViewport = $World/Viewport
@onready var backdrop: WorldBackdrop = $World/Viewport/WorldBackdrop
@onready var weather: NightWeather = $World/Viewport/NightWeather
@onready var building: ApartmentBuilding = $World/Viewport/ApartmentBuilding
@onready var player: SiegePlayer = $World/Viewport/Player
@onready var game_camera: GameCamera = $World/Viewport/GameCamera
@onready var hud: GameHUD = $Interface/GameHUD
@onready var labels: WorldLabels = $Interface/WorldLabels
@onready var waves: DisasterWaveManager = $DisasterWaveManager
@onready var telegraphs: TelegraphSystem = $World/Viewport/TelegraphSystem
@onready var projectiles: ProjectilePool = $World/Viewport/ProjectilePool
@onready var feedback: CombatFeedback = $World/Viewport/CombatFeedback
@onready var storm: DisasterBoss = $World/Viewport/StormBoss
@onready var earthquake: DisasterBoss = $World/Viewport/EarthquakeBoss
@onready var loot: LootSystem = $World/Viewport/LootSystem
var sprite_overrides: Dictionary = {}
var mechanics: SiegeMechanics
var upgrades: SiegeUpgrades
var upgrade_overlay: UpgradeOverlay

func _ready() -> void:
	_configure_pixel_view()
	_clip_bosses_at_ground()
	# W/Up: jump, second press in the air = floor up. S/Down: floor down / fast fall.
	# Space joins Shift and right mouse as the 8-way i-frame dash (user request, Step 3).
	_bind_action(&"move_left", [KEY_A, KEY_LEFT])
	_bind_action(&"move_right", [KEY_D, KEY_RIGHT])
	_bind_action(&"move_up", [KEY_W, KEY_UP])
	_bind_action(&"move_down", [KEY_S, KEY_DOWN])
	_bind_action(&"jump", [KEY_W, KEY_UP])
	_bind_action(&"dash", [KEY_SHIFT, KEY_SPACE], MOUSE_BUTTON_RIGHT)
	_bind_action(&"test_shake", [KEY_T])
	_bind_action(&"reset_player", [KEY_R])
	_bind_action(&"start_wave", [KEY_F])
	_bind_action(&"storm_test", [KEY_1])
	_bind_action(&"quake_test", [KEY_2])
	_bind_action(&"chaos_test", [KEY_3])
	_bind_action(&"repair", [KEY_E])
	_bind_action(&"upgrade_test", [KEY_U])
	player.building = building
	player.reset_player()
	player.dash_started.connect(Callable(self, "_on_dash_started"))
	hud.player = player
	hud.building = building
	hud.waves = waves
	hud.loot = loot
	labels.configure(self)
	waves.configure(building, player, game_camera, telegraphs, projectiles, storm, earthquake)
	loot.configure(building, player, waves)
	upgrades = SiegeUpgrades.new()
	upgrades.name = "SiegeUpgrades"
	add_child(upgrades)
	upgrades.configure(self)
	waves.upgrades = upgrades
	waves.loot = loot
	mechanics = SiegeMechanics.new()
	mechanics.name = "SiegeMechanics"
	world_viewport.add_child(mechanics)
	mechanics.configure(self)
	projectiles.mechanics = mechanics
	upgrade_overlay = UpgradeOverlay.new()
	upgrade_overlay.name = "UpgradeOverlay"
	$Interface.add_child(upgrade_overlay)
	upgrade_overlay.configure(upgrades)
	projectiles.dodged.connect(Callable(feedback, "show_dodge"))
	player.damaged.connect(Callable(self, "_on_player_damaged"))
	if art_assets != null:
		player.custom_sprite = art_assets.player
		hud.custom_sprite = art_assets.hud
		backdrop.custom_sprite = art_assets.background
		backdrop.queue_redraw()
	sprite_overrides = AssetRegistry.apply(self, AssetRegistry.load_textures(sprite_directory))
	_apply_atmosphere()

## The ground occludes entering/retreating bosses instead of letting their legs
## slide across the HUD. Only boss art is clipped; room/player physics are untouched.
func _clip_bosses_at_ground() -> void:
	var mask: Control = Control.new()
	mask.name = "BossGroundMask"
	mask.size = Vector2(backdrop.view_size.x, backdrop.ground_y)
	mask.clip_contents = true
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.z_index = 5
	world_viewport.add_child(mask)
	for boss: DisasterBoss in [storm, earthquake]:
		boss.reparent(mask, true)
		boss.z_index = 0

func _configure_pixel_view() -> void:
	world_container.stretch_shrink = pixel_scale
	game_camera.zoom = Vector2.ONE * base_zoom / float(pixel_scale)

## World position -> 1920x1080 HUD/screen position (through camera and pixel upscale).
func world_to_screen(point: Vector2) -> Vector2:
	return world_container.position + (world_viewport.get_canvas_transform() * point) * float(pixel_scale)

func _process(_delta: float) -> void:
	_apply_atmosphere()

func _apply_atmosphere() -> void:
	weather.storminess = 1.0 - storm.retreat if storm.visible else 0.0
	var ambient: Color = night_tint
	building.set_darkness(ambient.lerp(flash_tint, weather.flash * 0.6))
	building.lighting.tremor = clampf((game_camera.shake_strength() - 3.0) / 10.0, 0.0, 1.0)

func _bind_action(action: StringName, keys: Array[int], mouse_button: int = 0) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = key
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
	if mouse_button != 0:
		var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
		mouse_event.button_index = mouse_button
		if not InputMap.action_has_event(action, mouse_event):
			InputMap.action_add_event(action, mouse_event)

func _input(event: InputEvent) -> void:
	if upgrades == null or not upgrades.pending or not event is InputEventKey:
		return
	if event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("reset_player"):
			reset_game()
		else:
			for slot: int in range(3):
				if event.is_action_pressed(["storm_test", "quake_test", "chaos_test"][slot]):
					upgrades.choose(slot)
	get_viewport().set_input_as_handled()

func reset_game() -> void:
	waves.reset_cycle()
	player.reset_player()
	feedback.clear()
	hud.hit_flash = 0.0
	game_camera.clear_shake()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_F9 and not event.echo:
		waves.debug_enabled = not waves.debug_enabled
	if waves.upgrade_pending or event.is_echo():
		return
	if event.is_action_pressed("reset_player"):
		reset_game()
	elif waves.debug_enabled and event.is_action_pressed("upgrade_test"):
		waves.test_upgrades()
	elif event.is_action_pressed("repair"):
		loot.repair_current_room()
	elif event.is_action_pressed("start_wave"):
		waves.start_next_wave()
	elif waves.debug_enabled and event.is_action_pressed("storm_test"):
		waves.start_siege(DisasterWaveManager.Mode.STORM, true)
	elif waves.debug_enabled and event.is_action_pressed("quake_test"):
		waves.start_siege(DisasterWaveManager.Mode.EARTHQUAKE, true)
	elif waves.debug_enabled and event.is_action_pressed("chaos_test"):
		waves.start_siege(DisasterWaveManager.Mode.CHAOS, true)

func _on_dash_started() -> void:
	game_camera.apply_shake(2.0, 0.09)

func _on_player_damaged(remaining_health: float) -> void:
	hud.hit_flash = 0.2
	game_camera.apply_shake(9.0, 0.25)
	if remaining_health <= 0:
		waves.fail_siege()
