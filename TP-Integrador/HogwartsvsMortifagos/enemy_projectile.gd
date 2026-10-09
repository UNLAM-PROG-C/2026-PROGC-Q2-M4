class_name EnemyProjectile
extends Area2D

const IMPACT_EXPLOSION_SCENE: PackedScene = preload("res://impact_explosion.tscn")

## Travel speed towards the left in pixels per second.
@export var speed: float = 400.0
## Damage dealt to the ally it hits.
@export var damage: float = 20.0
## Duration in seconds of each animation frame.
@export var animation_frame_duration: float = 0.08

var _animation_elapsed: float = 0.0
var _has_hit: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	position.x -= speed * delta
	_animation_elapsed += delta
	if _animation_elapsed >= animation_frame_duration:
		_animation_elapsed = 0.0
		sprite.frame = (sprite.frame + 1) % sprite.hframes


func _on_area_entered(area: Area2D) -> void:
	if _has_hit or not area.is_in_group(Groups.ALLIES):
		return
	var ally: Ally = area as Ally
	if ally == null or not is_instance_valid(ally):
		return
	_has_hit = true
	_spawn_impact_explosion()
	ally.take_damage(damage)
	queue_free()


func _spawn_impact_explosion() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var explosion: Node2D = IMPACT_EXPLOSION_SCENE.instantiate() as Node2D
	parent_node.add_child(explosion)
	explosion.global_position = global_position


func _on_screen_exited() -> void:
	queue_free()
