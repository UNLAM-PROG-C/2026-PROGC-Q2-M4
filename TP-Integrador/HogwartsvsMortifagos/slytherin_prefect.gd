class_name SlytherinPrefect
extends Enemy

## Ranged enemy that shoots projectiles when detecting allies ahead in its lane.
## When an ally is ahead in its lane, it stays stopped shooting.

const DEFAULT_PROJECTILE_SCENE: PackedScene = preload("res://enemy_projectile.tscn")

## Seconds between ranged attacks.
@export var shoot_interval: float = 3.5
## Projectile scene to fire towards allies.
@export var projectile_scene: PackedScene = DEFAULT_PROJECTILE_SCENE

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

var _is_shooting: bool = false


func _ready() -> void:
	super._ready()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()


func _process_actions(delta: float) -> void:
	if is_instance_valid(_target_ally):
		# Target in melee range: stay stopped and melee attack
		return
	if _has_ally_ahead():
		# Ally ahead in lane: stay stopped shooting
		return
	_target_ally = null
	position.x -= speed * _slow_factor * delta


func _update_target_state() -> void:
	var has_attack_target: bool = is_instance_valid(_target_ally)
	if has_attack_target:
		_is_shooting = false
	if has_attack_target != _is_attacking:
		_is_attacking = has_attack_target
		_update_animation_texture()


func _update_animation_texture() -> void:
	if _is_shooting:
		var next_texture: Texture2D = attacking_texture if not _is_hurt else hurt_attacking_texture
		if next_texture != null:
			_apply_next_texture(next_texture, 4)
		return
	super._update_animation_texture()


func _on_shoot_timer_timeout() -> void:
	if not _has_ally_ahead() or _is_attacking:
		return
	_start_ranged_attack()


func _start_ranged_attack() -> void:
	if _is_shooting:
		return
	_is_shooting = true
	var next_texture: Texture2D = attacking_texture if not _is_hurt else hurt_attacking_texture
	if next_texture != null:
		_apply_next_texture(next_texture, 4)
	sprite.frame = 0


func _on_animation_timer_timeout() -> void:
	if _is_shooting:
		if sprite == null or sprite.hframes <= 0:
			return
		var next_frame: int = (sprite.frame + 1) % sprite.hframes
		var loop_finished: bool = (next_frame == 0)
		sprite.frame = next_frame
		if loop_finished:
			_shoot()
			_is_shooting = false
			_update_animation_texture()
			if sprite != null:
				sprite.frame = 0
			shoot_timer.start(shoot_interval)
	elif _is_attacking:
		super._on_animation_timer_timeout()
	else:
		if _has_ally_ahead():
			# Stopped waiting between shots: stay on resting frame
			if sprite != null:
				sprite.frame = 0
		else:
			super._on_animation_timer_timeout()


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
