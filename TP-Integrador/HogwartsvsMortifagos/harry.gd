class_name Harry
extends Ally

## Peashooter ally: shoots a projectile while an enemy is in its lane.

## Seconds between shots.
@export var shot_interval: float = 1.5

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	shoot_timer.wait_time = shot_interval
	shoot_timer.start()


## ShootTimer callback. Shoots only if there is an enemy in the same lane.
func _on_shoot_timer_timeout() -> void:
	if not _has_enemy_in_lane():
		return
	acquire_pooled_projectile(projectile_pool, shoot_point.global_position, ProjectilePool.DEFAULT_PROJECTILE_DAMAGE, false, null)
