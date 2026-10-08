class_name DumbledoreProjectile
extends Area2D

## Linear heavy projectile that detonates on first impact, dealing splash damage
## to all enemies in a 3x3 cell area (480x480 px).

const IMPACT_EXPLOSION_SCENE: PackedScene = preload("res://impact_explosion.tscn")
const DEFAULT_SPEED: float = 350.0
const DEFAULT_SPLASH_DAMAGE: float = 20.0
const HALF_SPLASH_WIDTH: float = 240.0
const HALF_SPLASH_HEIGHT: float = 240.0
const EXIT_X: float = 1950.0
const ANIMATION_FRAME_DURATION: float = 0.08

@export var speed: float = DEFAULT_SPEED
@export var splash_damage: float = DEFAULT_SPLASH_DAMAGE

var _has_hit: bool = false
var _animation_elapsed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var splash_area: Area2D = $SplashArea


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	position.x += speed * delta
	_update_animation(delta)
	if global_position.x > EXIT_X:
		queue_free()


func _update_animation(delta: float) -> void:
	_animation_elapsed += delta
	if _animation_elapsed >= ANIMATION_FRAME_DURATION:
		_animation_elapsed = 0.0
		sprite.frame = (sprite.frame + 1) % sprite.hframes


func _on_area_entered(area: Area2D) -> void:
	if _has_hit:
		return
	var enemy: Node2D = _get_enemy_from_area(area)
	if enemy == null:
		return
	_has_hit = true
	_detonate(enemy)


func _get_enemy_from_area(area: Area2D) -> Node2D:
	if area == null:
		return null
	if area.is_in_group(Groups.ENEMIES):
		return area
	var parent_node: Node = area.get_parent()
	if parent_node != null and parent_node.is_in_group(Groups.ENEMIES):
		return parent_node as Node2D
	return null


func _detonate(primary_target: Node2D) -> void:
	_apply_splash_damage(primary_target)
	_spawn_impact_effect()
	queue_free()


func _apply_splash_damage(primary_target: Node2D) -> void:
	var hit_enemies: Dictionary = {}
	if primary_target != null and is_instance_valid(primary_target):
		_try_damage_enemy(primary_target, hit_enemies)
	_damage_overlapping_areas(hit_enemies)
	_damage_spatial_enemies(hit_enemies)


func _damage_overlapping_areas(hit_enemies: Dictionary) -> void:
	for area: Area2D in splash_area.get_overlapping_areas():
		var enemy: Node2D = _get_enemy_from_area(area)
		if enemy != null:
			_try_damage_enemy(enemy, hit_enemies)


func _damage_spatial_enemies(hit_enemies: Dictionary) -> void:
	for enemy_node: Node in get_tree().get_nodes_in_group(Groups.ENEMIES):
		if enemy_node is Node2D and _is_inside_splash_box(enemy_node as Node2D):
			_try_damage_enemy(enemy_node, hit_enemies)


func _try_damage_enemy(target: Node, hit_enemies: Dictionary) -> void:
	var target_id: int = target.get_instance_id()
	if hit_enemies.has(target_id):
		return
	hit_enemies[target_id] = true
	if target.has_method(&"take_damage"):
		target.call(&"take_damage", splash_damage)


func _is_inside_splash_box(node: Node2D) -> bool:
	var diff: Vector2 = (node.global_position - global_position).abs()
	return diff.x <= HALF_SPLASH_WIDTH and diff.y <= HALF_SPLASH_HEIGHT


func _spawn_impact_effect() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var explosion: Node2D = IMPACT_EXPLOSION_SCENE.instantiate() as Node2D
	parent_node.add_child(explosion)
	explosion.global_position = global_position
