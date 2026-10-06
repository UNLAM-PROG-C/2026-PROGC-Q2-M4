class_name Ron
extends Ally

## Seconds between shots.
@export var shot_interval: float = 3.0
## Damage dealt to the enemy hit by Ron's projectile (1.5x base damage).
@export var damage: float = 30.0
## Fallback projectile scene.
@export var projectile_scene: PackedScene
## Shared projectile pool injected by Level.
@export var projectile_pool: ProjectilePool

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	shoot_timer.wait_time = shot_interval
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	if not _has_enemy_in_lane():
		return
	_shoot()


func _shoot() -> void:
	if projectile_pool == null or not is_instance_valid(projectile_pool):
		return
	var projectile: Projectile = projectile_pool.acquire_projectile(shoot_point.global_position, damage)
	if projectile == null:
		return


func _has_enemy_in_lane() -> bool:
	return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()
