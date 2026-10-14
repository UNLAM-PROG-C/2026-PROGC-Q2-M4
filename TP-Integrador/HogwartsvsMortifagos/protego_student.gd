class_name ProtegoStudent
extends Enemy

## Armored Slytherin student wielding a Protego magical shield.
## The shield has 1000 HP and absorbs damage before the student's 200 HP body.

const DEFAULT_SHIELD_MAX_HEALTH: float = 1000.0
const BASE_STUDENT_HEALTH: float = 200.0
const SHIELD_BASE_X: float = -35.0
const ATTACK_OSCILLATION_SPEED: float = 12.0
const ATTACK_OSCILLATION_AMPLITUDE: float = 4.0
const ATTACK_TICKS_PER_CYCLE: int = 4
const ATTACKING_FRAMES: int = 1

## Shield health ratio thresholds for visual states (0 intact, 1 damaged, 2 critical).
const SHIELD_DAMAGED_RATIO: float = 2.0 / 3.0
const SHIELD_CRITICAL_RATIO: float = 1.0 / 3.0

const SLYTHERIN_TEXTURE: Texture2D = preload("res://Images/slytherin.png")
const PROTEGO_ATTACKING_TEXTURE: Texture2D = preload("res://Images/slytherin_protego_attacking.png")

@export var shield_max_health: float = DEFAULT_SHIELD_MAX_HEALTH
@export var protego_attacking_texture: Texture2D = PROTEGO_ATTACKING_TEXTURE

@onready var shield_sprite: Sprite2D = $ShieldSprite

var _shield_health: float = DEFAULT_SHIELD_MAX_HEALTH
var _shield_broken: bool = false
var _attack_time: float = 0.0
var _attack_tick: int = 0


func _ready() -> void:
	max_health = BASE_STUDENT_HEALTH
	super._ready()
	_shield_health = shield_max_health
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
	if not _shield_broken and _shield_health > 0.0:
		_absorb_shield_damage(amount)
	else:
		super.take_damage(amount)


func _absorb_shield_damage(amount: float) -> void:
	var shield_damage: float = minf(amount, _shield_health)
	_shield_health -= shield_damage
	var overflow: float = amount - shield_damage
	_update_shield_visuals()
	if overflow > 0.0:
		super.take_damage(overflow)
	elif damage_flash != null:
		damage_flash.flash()


func _update_shield_visuals() -> void:
	if _shield_broken or shield_sprite == null:
		return
	if _shield_health <= 0.0:
		_break_shield()
		return
	var ratio: float = _shield_health / shield_max_health
	if ratio <= SHIELD_CRITICAL_RATIO:
		shield_sprite.frame = 2
	elif ratio <= SHIELD_DAMAGED_RATIO:
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
		_attack_tick = 0
		var tex: Texture2D = protego_attacking_texture if _is_attacking else walk_texture
		var frames: int = ATTACKING_FRAMES if _is_attacking else TOTAL_FRAMES
		if tex != null and sprite != null:
			_apply_next_texture(tex, frames)
		return
	super._update_animation_texture()


func _on_animation_timer_timeout() -> void:
	if not _shield_broken and _is_attacking:
		if sprite != null:
			sprite.frame = 0
		_attack_tick = (_attack_tick + 1) % ATTACK_TICKS_PER_CYCLE
		if _attack_tick == 0:
			_deal_attack_damage()
		return
	_attack_tick = 0
	super._on_animation_timer_timeout()
