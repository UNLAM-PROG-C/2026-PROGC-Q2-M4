class_name ProtegoStudent
extends Enemy

## Armored Slytherin student wielding a Protego magical shield.
## Absorbs damage into the shield before the student body takes damage.

const SHIELD_BASE_X: float = -35.0
const ATTACK_OSCILLATION_SPEED: float = 12.0
const ATTACK_OSCILLATION_AMPLITUDE: float = 8.0
const SHIELD_DAMAGE_THRESHOLD_HIGH: float = 200.0
const SHIELD_DAMAGE_THRESHOLD_LOW: float = 100.0
const SLYTHERIN_TEXTURE: Texture2D = preload("res://Images/slytherin.png")

@export var shield_max_health: float = 300.0

@onready var shield_sprite: Sprite2D = $ShieldSprite

var _shield_health: float = 300.0
var _attack_time: float = 0.0


func _ready() -> void:
	super._ready()
	_shield_health = shield_max_health
	if shield_sprite != null:
		shield_sprite.flip_h = true
	_update_shield_visuals()


func _process(delta: float) -> void:
	super._process(delta)
	_process_shield_attack(delta)


func _process_shield_attack(delta: float) -> void:
	if _shield_health <= 0.0 or shield_sprite == null:
		return
	if _is_attacking:
		_attack_time += delta * ATTACK_OSCILLATION_SPEED
		shield_sprite.position.x = SHIELD_BASE_X + sin(_attack_time) * ATTACK_OSCILLATION_AMPLITUDE
	else:
		_attack_time = 0.0
		shield_sprite.position.x = SHIELD_BASE_X


func take_damage(amount: float) -> void:
	if _shield_health > 0.0:
		_apply_shield_damage(amount)
	else:
		super.take_damage(amount)


func _apply_shield_damage(amount: float) -> void:
	damage_flash.flash()
	if amount <= _shield_health:
		_shield_health -= amount
		_update_shield_visuals()
		return
	var overflow: float = amount - _shield_health
	_shield_health = 0.0
	_break_shield()
	super.take_damage(overflow)


func _update_shield_visuals() -> void:
	if shield_sprite == null or _shield_health <= 0.0:
		return
	if _shield_health > SHIELD_DAMAGE_THRESHOLD_HIGH:
		shield_sprite.frame = 0
	elif _shield_health > SHIELD_DAMAGE_THRESHOLD_LOW:
		shield_sprite.frame = 1
	else:
		shield_sprite.frame = 2


func _break_shield() -> void:
	if shield_sprite != null:
		shield_sprite.visible = false
	walk_texture = SLYTHERIN_TEXTURE
	_update_animation_texture()


func _update_animation_texture() -> void:
	if _shield_health > 0.0:
		sprite.texture = walk_texture
		sprite.hframes = TOTAL_FRAMES
		return
	super._update_animation_texture()
