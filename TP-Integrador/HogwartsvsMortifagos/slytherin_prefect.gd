class_name SlytherinPrefect
extends Enemy

## Ranged enemy that walks until reaching the rightmost grid cell, stays still,
## and continuously fires dark curses down its lane.

const DEFAULT_PROJECTILE_SCENE: PackedScene = preload("res://enemy_projectile.tscn")
const DEFAULT_STOP_X: float = 1704.0
const ATTACKING_FRAMES: int = 1

## Seconds between ranged attacks.
@export var shoot_interval: float = 3.5
## Projectile scene to fire towards allies.
@export var projectile_scene: PackedScene = DEFAULT_PROJECTILE_SCENE
## Target X coordinate where the prefect stops and stays still.
@export var stop_x: float = DEFAULT_STOP_X

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

var _is_stopped: bool = false


func _ready() -> void:
	super._ready()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()
	_update_animation_texture()


func is_stopped() -> bool:
	return _is_stopped


func _process_actions(delta: float) -> void:
	if _is_stopped or is_instance_valid(_target_ally):
		return
	if global_position.x <= stop_x:
		_arrive_at_stop_position()
		return
	position.x -= speed * _slow_factor * delta
	if global_position.x <= stop_x:
		_arrive_at_stop_position()


func _arrive_at_stop_position() -> void:
	global_position.x = stop_x
	_is_stopped = true
	_update_animation_texture()


func _update_target_state() -> void:
	var has_attack_target: bool = is_instance_valid(_target_ally)
	if has_attack_target != _is_attacking:
		_is_attacking = has_attack_target


func _update_animation_texture() -> void:
	if sprite == null:
		return
	var texture_to_apply: Texture2D = _get_current_state_texture()
	var frame_count: int = ATTACKING_FRAMES if _is_stopped else TOTAL_FRAMES
	if texture_to_apply != null:
		_apply_next_texture(texture_to_apply, frame_count)


func _get_current_state_texture() -> Texture2D:
	if _is_stopped:
		return hurt_attacking_texture if _is_hurt else attacking_texture
	return hurt_texture if _is_hurt else walk_texture


func _on_shoot_timer_timeout() -> void:
	_shoot()


func _on_animation_timer_timeout() -> void:
	if sprite == null or sprite.hframes <= 0:
		return
	if _is_stopped:
		sprite.frame = 0
		_deal_stopped_melee_damage()
	else:
		super._on_animation_timer_timeout()


func _deal_stopped_melee_damage() -> void:
	if is_instance_valid(_target_ally) and _target_ally.has_method(&"take_damage"):
		_target_ally.take_damage(damage_per_attack)


func _shoot() -> void:
	if projectile_scene == null or get_parent() == null:
		return
	var projectile: Node2D = projectile_scene.instantiate() as Node2D
	if projectile == null:
		return
	get_parent().add_child(projectile)
	projectile.global_position = shoot_point.global_position
	if projectile.has_method(&"update_row_z_index"):
		projectile.call(&"update_row_z_index")


func _has_ally_ahead() -> bool:
	return Lane.has_allies_in_lane_ahead(get_tree(), global_position.y, global_position.x)
