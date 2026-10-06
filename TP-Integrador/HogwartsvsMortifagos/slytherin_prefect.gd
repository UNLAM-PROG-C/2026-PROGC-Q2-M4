class_name SlytherinPrefect
extends Enemy

## Ranged enemy that shoots projectiles when detecting allies ahead in its lane.

const DEFAULT_PROJECTILE_SCENE: PackedScene = preload("res://enemy_projectile.tscn")

## Seconds between ranged attacks.
@export var shoot_interval: float = 3.5
## Projectile scene to fire towards allies.
@export var projectile_scene: PackedScene = DEFAULT_PROJECTILE_SCENE

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	super._ready()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	if not _has_ally_ahead() or _is_attacking:
		return
	_shoot()


func _shoot() -> void:
	if projectile_scene == null or get_parent() == null:
		return
	var projectile: Node2D = projectile_scene.instantiate() as Node2D
	if projectile == null:
		return
	get_parent().add_child(projectile)
	projectile.global_position = shoot_point.global_position


func _has_ally_ahead() -> bool:
	return Lane.has_allies_in_lane_ahead(get_tree(), global_position.y, global_position.x)
