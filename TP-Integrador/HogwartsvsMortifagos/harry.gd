class_name Harry
extends Ally

## Peashooter ally: shoots a projectile while an enemy is in its lane.

## Seconds between shots.
@export var shot_interval: float = 1.5
## Projectile scene Harry shoots.
@export var projectile_scene: PackedScene

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	shoot_timer.wait_time = shot_interval
	shoot_timer.start()


## ShootTimer callback. Shoots only if there is an enemy in the same lane.
func _on_shoot_timer_timeout() -> void:
	if not _has_enemy_in_lane():
		return
	var projectile: Projectile = projectile_scene.instantiate() as Projectile
	projectile.global_position = shoot_point.global_position
	get_tree().current_scene.add_child(projectile)


func _has_enemy_in_lane() -> bool:
	return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()
