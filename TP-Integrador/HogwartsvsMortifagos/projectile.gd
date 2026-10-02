class_name Projectile
extends Area2D

## Travel speed in pixels per second.
@export var speed: float = 400.0
## Damage dealt to the enemy it hits.
@export var damage: float = 20.0

var _has_hit: bool = false


func _ready() -> void:
	add_to_group("hechizos")


func _process(delta: float) -> void:
	position.x += speed * delta


## Collision callback. Damages the enemy it hits and frees itself.
func _on_area_entered(area: Area2D) -> void:
	if _has_hit:
		return
	if area.is_in_group("enemigos") and area.has_method("take_damage"):
		_has_hit = true
		area.call("take_damage", damage)
		queue_free()


## VisibleOnScreenNotifier2D callback. Frees itself when leaving the screen.
func _on_screen_exited() -> void:
	queue_free()
