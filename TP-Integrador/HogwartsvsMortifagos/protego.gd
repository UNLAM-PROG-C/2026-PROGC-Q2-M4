class_name Protego
extends Ally

## Wall-nut ally: only absorbs damage. Its health is set in protego.tscn.

const FRAME_COUNT: int = 3
const MAX_HEALTH: float = 1000.0
const MEDIUM_HEALTH_RATIO: float = 2.0 / 3.0
const CRITICAL_HEALTH_RATIO: float = 1.0 / 3.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_damage_state()


func take_damage(amount: float) -> void:
	health = maxf(health - amount, 0.0)
	_update_damage_state()
	damage_flash.flash()
	if health <= 0.0:
		defeated.emit(self)
		queue_free()


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
	return MAX_HEALTH
