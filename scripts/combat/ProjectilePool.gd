class_name ProjectilePool
extends Node2D

signal dodged(world_position: Vector2)
signal structure_hit(amount: float, world_position: Vector2)
signal projectile_impacted(attack: HazardAttack, world_position: Vector2)

@export_range(16, 256) var capacity: int = 128
var entries: Array[HazardProjectile] = []
var mechanics: SiegeMechanics
var player: SiegePlayer
var spawn_count: int = 0
var rejected_count: int = 0
var peak_active: int = 0
var last_spawn_warning: float = 0.0

func _ready() -> void:
	process_physics_priority = 20
	for i: int in range(capacity):
		var projectile: HazardProjectile = HazardProjectile.new()
		projectile.name = "Hazard%03d" % i
		projectile.visible = false
		add_child(projectile)
		entries.append(projectile)

func spawn(attack: HazardAttack) -> HazardProjectile:
	if not attack.is_armed():
		rejected_count += 1
		return null
	for projectile: HazardProjectile in entries:
		if not projectile.active:
			if projectile.activate(attack):
				spawn_count += 1
				last_spawn_warning = attack.warning_elapsed
				peak_active = maxi(peak_active, active_count())
				return projectile
			return null
	rejected_count += 1
	return null

func active_count() -> int:
	var count: int = 0
	for projectile: HazardProjectile in entries:
		if projectile.active:
			count += 1
	return count

func clear() -> void:
	for projectile: HazardProjectile in entries:
		projectile.deactivate()

func _physics_process(delta: float) -> void:
	if player == null:
		return
	for projectile: HazardProjectile in entries:
		if not projectile.active:
			continue
		var previous: Vector2 = projectile.global_position
		projectile.advance(delta * (mechanics.projectile_speed(projectile) if mechanics != null else 1.0))
		if mechanics != null and mechanics.intercept(projectile, previous): continue
		if projectile.crosses_player(player, previous):
			projectile.contacted_player = true
			if player.is_dashing or player.dashing_this_tick:
				dodged.emit(player.global_position)
			else:
				player.take_damage(projectile.attack.damage)
			# A death callback may have cleared the complete pool synchronously.
			if not projectile.active:
				continue
		if projectile.age + 0.000001 >= projectile.attack.lifetime:
			var amount: float = projectile.attack.structure_damage
			var finished: HazardAttack = projectile.attack
			var impact: Vector2 = projectile.global_position
			projectile.deactivate()
			if amount > 0.0:
				structure_hit.emit(amount, impact)
			projectile_impacted.emit(finished, impact)

## Destroyed projectiles never trigger impact damage or cluster children.
func dissolve(projectile: HazardProjectile) -> void:
	if not projectile.active: return
	if mechanics != null: mechanics.burst(projectile.global_position, Color("9adce6"), 8)
	projectile.deactivate()

func dissolve_all() -> void:
	for projectile: HazardProjectile in entries:
		if projectile.active: dissolve(projectile)

func clear_floor(floor_index: int) -> int:
	var count: int = 0
	for projectile: HazardProjectile in entries:
		if projectile.active and projectile.attack.floor_index == floor_index:
			dissolve(projectile)
			count += 1
	return count
