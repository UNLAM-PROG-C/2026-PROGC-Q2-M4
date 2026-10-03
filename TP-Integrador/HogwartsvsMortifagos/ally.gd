class_name Ally
extends Area2D

## Base ally: takes damage from enemies, flashes and is freed when its
## health runs out.

## Emitted right before the ally is freed for running out of health.
signal defeated(entity: Node2D)

## Total health.
@export var health: float = 100.0

@onready var damage_flash: DamageFlash = $DamageFlash


## Called by enemies while attacking.
func take_damage(amount: float) -> void:
	health -= amount
	damage_flash.flash()
	if health <= 0.0:
		defeated.emit(self)
		queue_free()
