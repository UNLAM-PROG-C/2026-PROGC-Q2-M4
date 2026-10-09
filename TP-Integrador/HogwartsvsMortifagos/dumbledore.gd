class_name Dumbledore
extends Ally

## Dumbledore ally: shoots straight-line heavy projectile dealing 3x3 area splash damage.

const DEFAULT_SHOT_INTERVAL: float = 3.0
const BASE_HEALTH: float = 300.0

@export var shot_interval: float = DEFAULT_SHOT_INTERVAL
@export var projectile_scene: PackedScene = preload("res://dumbledore_projectile.tscn")

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
	if projectile_scene == null or get_parent() == null:
		return
	var projectile: Node2D = projectile_scene.instantiate() as Node2D
	if projectile == null:
		return
	get_parent().add_child(projectile)
	projectile.global_position = shoot_point.global_position


func _has_enemy_in_lane() -> bool:
	return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()
