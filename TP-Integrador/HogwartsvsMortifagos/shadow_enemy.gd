class_name ShadowEnemy
extends Enemy

const SHADOW_SPEED: float = 48.0
const SHADOW_MAX_HEALTH: float = 200.0
const SHADOW_DAMAGE_PER_SECOND: float = 30.0
const SHADOW_HFRAMES: int = 2
const SHADOW_VFRAMES: int = 1


func _ready() -> void:
	speed = SHADOW_SPEED
	max_health = SHADOW_MAX_HEALTH
	damage_per_second = SHADOW_DAMAGE_PER_SECOND
	damage_per_attack = 15.0
	_health = max_health
	_init_sprite()
	_setup_shadow_sprite()
	_init_slow_timer()
	_init_animation_timer()


func _setup_shadow_sprite() -> void:
	if sprite != null:
		sprite.texture = walk_texture
		sprite.hframes = SHADOW_HFRAMES
		sprite.vframes = SHADOW_VFRAMES
		sprite.frame = 0


func _on_animation_timer_timeout() -> void:
	super._on_animation_timer_timeout()


func _update_animation_texture() -> void:
	pass
