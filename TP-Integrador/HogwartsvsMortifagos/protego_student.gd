class_name ProtegoStudent
extends Enemy

## Armored Slytherin student wielding a Protego magical shield.
## The shield is purely visual: all damage goes to the student's health.
## The shield sprite degrades and breaks based on the student's max_health.

const SHIELD_BASE_X: float = -35.0
const ATTACK_OSCILLATION_SPEED: float = 12.0
const ATTACK_OSCILLATION_AMPLITUDE: float = 8.0

## Health ratio thresholds for shield visual states.
const SHIELD_DAMAGED_RATIO: float = 0.9
const SHIELD_CRITICAL_RATIO: float = 0.8
const SHIELD_BREAK_RATIO: float = 0.7

## Health ratio at which the student shows hurt texture (overrides Enemy's 0.5).
const STUDENT_HURT_RATIO: float = 0.4

const SLYTHERIN_TEXTURE: Texture2D = preload("res://Images/slytherin.png")

@onready var shield_sprite: Sprite2D = $ShieldSprite

var _shield_broken: bool = false
var _attack_time: float = 0.0


func _ready() -> void:
	super._ready()
	_shield_broken = false
	if shield_sprite != null:
		shield_sprite.flip_h = true
	_update_shield_visuals()


func _process(delta: float) -> void:
	super._process(delta)
	_process_shield_attack(delta)


func _process_shield_attack(delta: float) -> void:
	if _shield_broken or shield_sprite == null:
		return
	if _is_attacking:
		_attack_time += delta * ATTACK_OSCILLATION_SPEED
		shield_sprite.position.x = SHIELD_BASE_X + sin(_attack_time) * ATTACK_OSCILLATION_AMPLITUDE
	else:
		_attack_time = 0.0
		shield_sprite.position.x = SHIELD_BASE_X


func take_damage(amount: float) -> void:
	super.take_damage(amount)
	_update_shield_visuals()


## Overrides Enemy's threshold: hurt texture at 40% instead of 50%.
func _update_hurt_texture() -> void:
	if _is_hurt or _health > max_health * STUDENT_HURT_RATIO:
		return
	_is_hurt = true
	_update_animation_texture()


func _update_shield_visuals() -> void:
	if _shield_broken or shield_sprite == null:
		return
	var health_ratio: float = _health / max_health
	if health_ratio <= SHIELD_BREAK_RATIO:
		_break_shield()
	elif health_ratio <= SHIELD_CRITICAL_RATIO:
		shield_sprite.frame = 2
	elif health_ratio <= SHIELD_DAMAGED_RATIO:
		shield_sprite.frame = 1
	else:
		shield_sprite.frame = 0


func _break_shield() -> void:
	_shield_broken = true
	if shield_sprite != null:
		shield_sprite.visible = false
	walk_texture = SLYTHERIN_TEXTURE
	_update_animation_texture()


func _update_animation_texture() -> void:
	if not _shield_broken:
		sprite.texture = walk_texture
		sprite.hframes = TOTAL_FRAMES
		return
	super._update_animation_texture()
