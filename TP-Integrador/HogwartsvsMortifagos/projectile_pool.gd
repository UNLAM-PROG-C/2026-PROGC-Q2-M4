class_name ProjectilePool
extends Node2D

const INITIAL_CAPACITY: int = 50
const GROWTH_BATCH: int = 10
const DEFAULT_PROJECTILE_DAMAGE: float = 20.0

@export var projectile_scene: PackedScene

var available_projectiles: Array[Projectile] = []
var active_projectiles: Array[Projectile] = []
var shots_fired: int = 0

signal stats_changed(shots_fired: int, pool_size: int, active_count: int)


func _ready() -> void:
	_add_projectiles(INITIAL_CAPACITY)


func _add_projectiles(amount: int) -> void:
	if projectile_scene == null:
		push_error("ProjectilePool requires a projectile_scene.")
		return
	if amount <= 0:
		return

	for _index: int in range(amount):
		var projectile: Projectile = projectile_scene.instantiate() as Projectile
		if projectile == null:
			push_error("ProjectilePool could not instantiate a Projectile.")
			continue
		add_child(projectile)
		projectile.returned_to_pool.connect(_on_projectile_returned)
		projectile.deactivate()
		available_projectiles.append(projectile)
	_emit_stats()


func acquire_projectile(spawn_position: Vector2, custom_damage: float = DEFAULT_PROJECTILE_DAMAGE, slows: bool = false) -> Projectile:
	if available_projectiles.is_empty():
		_add_projectiles(GROWTH_BATCH)
	if available_projectiles.is_empty():
		return null

	var projectile: Projectile = available_projectiles.pop_back()
	projectile.damage = custom_damage
	active_projectiles.append(projectile)
	shots_fired += 1
	projectile.activate(spawn_position, slows)
	_emit_stats()
	return projectile


func _on_projectile_returned(projectile: Projectile) -> void:
	if not is_instance_valid(projectile) or not active_projectiles.has(projectile):
		return
	active_projectiles.erase(projectile)
	projectile.damage = DEFAULT_PROJECTILE_DAMAGE
	if not available_projectiles.has(projectile):
		available_projectiles.append(projectile)
	_emit_stats()


func release_all() -> void:
	for projectile: Projectile in active_projectiles:
		if is_instance_valid(projectile):
			projectile.deactivate()
			if not available_projectiles.has(projectile):
				available_projectiles.append(projectile)
	active_projectiles.clear()
	_emit_stats()


func get_pool_size() -> int:
	return available_projectiles.size() + active_projectiles.size()


func _emit_stats() -> void:
	stats_changed.emit(shots_fired, get_pool_size(), active_projectiles.size())
