class_name Projectile
extends Area2D

const IMPACT_EXPLOSION_SCENE: PackedScene = preload("res://impact_explosion.tscn")

## Travel speed in pixels per second.
@export var speed: float = 400.0
## Damage dealt to the enemy it hits.
@export var damage: float = 20.0
## Duration in seconds of each animation frame.
@export var animation_frame_duration: float = 0.08

var _has_hit: bool = false
var _animation_elapsed: float = 0.0
var _is_active: bool = false

signal returned_to_pool(projectile: Projectile)

@onready var sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	if not _is_active:
		return
	position.x += speed * delta
	_animation_elapsed += delta
	if _animation_elapsed >= animation_frame_duration:
		_animation_elapsed = 0.0
		sprite.frame = (sprite.frame + 1) % sprite.hframes


func activate(spawn_position: Vector2) -> void:
	global_position = spawn_position
	_has_hit = false
	_animation_elapsed = 0.0
	_is_active = true
	sprite.frame = 0
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	set_process(true)


func deactivate() -> void:
	_is_active = false
	_has_hit = false
	_animation_elapsed = 0.0
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_process(false)


func _return_to_pool() -> void:
	if not _is_active:
		return
	deactivate()
	returned_to_pool.emit(self)


## Collision callback. Damages the enemy it hits and returns to the pool.
func _on_area_entered(area: Area2D) -> void:
	if not _is_active or _has_hit or not area.is_in_group(Groups.ENEMIES):
		return
	var enemy: Enemy = area as Enemy
	if enemy == null or not is_instance_valid(enemy):
		return
	_has_hit = true
	_spawn_impact_explosion()
	enemy.take_damage(damage)
	_return_to_pool()


func _spawn_impact_explosion() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var explosion: Node2D = IMPACT_EXPLOSION_SCENE.instantiate() as Node2D
	parent_node.add_child(explosion)
	explosion.global_position = global_position


## VisibleOnScreenNotifier2D callback. Returns itself when leaving the screen.
func _on_screen_exited() -> void:
	_return_to_pool()
