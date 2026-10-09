class_name Hermione
extends Ally

## Ally that shoots ice projectiles to damage and slow enemies.

const BASE_DAMAGE: float = 20.0
const BASE_HEALTH: float = 300.0

## Seconds between shots (identical to Harry).
@export var shot_interval: float = 1.5
## Damage dealt by each ice projectile.
@export var damage: float = BASE_DAMAGE
## Fallback projectile scene.
@export var projectile_scene: PackedScene
## Shared projectile pool injected by Level.
@export var projectile_pool: ProjectilePool

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	health = BASE_HEALTH
	shoot_timer.wait_time = shot_interval
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	if not _has_enemy_in_lane():
		return
	_shoot()


func _shoot() -> void:
	if projectile_pool == null or not is_instance_valid(projectile_pool):
		return
	var projectile: Projectile = projectile_pool.acquire_projectile(shoot_point.global_position, damage, true)
	if projectile == null:
		return


func _has_enemy_in_lane() -> bool:
	return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()
