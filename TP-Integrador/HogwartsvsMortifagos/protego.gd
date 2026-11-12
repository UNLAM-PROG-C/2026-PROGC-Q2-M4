class_name Protego
extends Ally

## Wall-nut ally: only absorbs damage. Its health is set in protego.tscn.

const FRAME_COUNT: int = 3
const MEDIUM_HEALTH_RATIO: float = 2.0 / 3.0
const CRITICAL_HEALTH_RATIO: float = 1.0 / 3.0

var _max_health: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_max_health = health
	_update_damage_state()


func take_damage(amount: float) -> void:
	super.take_damage(amount)
	if is_instance_valid(self):
		_update_damage_state()


func _update_damage_state() -> void:
	if health <= 0.0:
		sprite.frame = FRAME_COUNT - 1
	elif health <= max_health() * CRITICAL_HEALTH_RATIO:
		sprite.frame = 2
	elif health <= max_health() * MEDIUM_HEALTH_RATIO:
		sprite.frame = 1
	else:
		sprite.frame = 0


func max_health() -> float:
	return _max_health
