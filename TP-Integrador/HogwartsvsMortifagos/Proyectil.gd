class_name Proyectil
extends Area2D

## Velocidad de desplazamiento del proyectil en píxeles por segundo.
@export var velocidad: float = 400.0
## Puntos de daño que inflige al impactar un enemigo.
@export var danio: int = 20

var _impacto_registrado: bool = false


func _ready() -> void:
	add_to_group("hechizos")


func _process(delta: float) -> void:
	position.x += velocidad * delta


## Callback de colisión. Aplica daño al enemigo impactado y se destruye.
func _on_area_entered(area: Area2D) -> void:
	if _impacto_registrado:
		return
	if area.is_in_group("enemigos") and area.has_method("recibir_danio"):
		_impacto_registrado = true
		area.call("recibir_danio", danio)
		queue_free()


## Callback del VisibleOnScreenNotifier2D. Se destruye al salir de pantalla.
func _on_screen_exited() -> void:
	queue_free()
