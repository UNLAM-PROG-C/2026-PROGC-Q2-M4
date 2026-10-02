class_name Protego
extends Area2D

## Emitted when Protego loses all its health.
signal defeated(entity: Node2D)

## Snitch cost to place a Protego.
@export var coste: int = 50
## Card cooldown in seconds after placing it.
@export var tiempo_recarga: float = 12.0
## Barrier health. Much higher than a wizard's.
@export var health: float = 4000.0

var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _ready() -> void:
	add_to_group("allies")


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta
	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			$Visual.modulate = Color(1.0, 1.0, 1.0)


## Absorbs damage without attacking. Called by enemies on contact.
func take_damage(amount: float) -> void:
	health -= amount
	if _cooldown_flash <= 0.0:
		$Visual.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5
	if health <= 0.0:
		defeated.emit(self)
		queue_free()
