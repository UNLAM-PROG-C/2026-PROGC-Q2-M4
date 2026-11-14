class_name Hermione
extends Ally

## Ally that shoots ice projectiles to damage and slow enemies.

const BASE_DAMAGE: float = 20.0

## Seconds between shots (identical to Harry).
@export var shot_interval: float = 1.5
## Damage dealt by each ice projectile.
@export var damage: float = BASE_DAMAGE

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
	acquire_pooled_projectile(projectile_pool, shoot_point.global_position, damage, true, null)
