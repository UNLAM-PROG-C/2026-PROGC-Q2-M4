class_name AlumnoSlytherin
extends Area2D

## Señal emitida cuando el Alumno Slytherin es derrotado.
signal derrotado(entidad: Node2D)
## Señal emitida cuando el Alumno Slytherin invade el jardín.
signal invasion_jardin()

## Salud máxima del Alumno Slytherin.
@export var salud_maxima: int = 200
## Velocidad de avance en píxeles por segundo.
@export var velocidad: float = 32.0
## Daño infligido por segundo al atacar un aliado.
@export var danio_por_segundo: float = 30.0

var salud_actual: int = 0
var aliado_objetivo: Area2D = null


func _ready() -> void:
	salud_actual = salud_maxima
	add_to_group("enemigos")


func _process(delta: float) -> void:
	if is_instance_valid(aliado_objetivo):
		# Estado: atacando al aliado
		if aliado_objetivo.has_method("recibir_danio"):
			aliado_objetivo.call("recibir_danio", danio_por_segundo * delta)
	else:
		aliado_objetivo = null
		# Estado: avanzando hacia el jardín
		position.x -= velocidad * delta

	# Condición de invasión del jardín
	if global_position.x < 0.0:
		invasion_jardin.emit()
		queue_free()


## Aplica daño al Alumno Slytherin. Llamado por los proyectiles al impactar.
func recibir_danio(cantidad: int) -> void:
	salud_actual = maxi(salud_actual - cantidad, 0)
	# Efecto visual de daño
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
		var tween: Tween = create_tween()
		tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0), 0.15)
	if salud_actual == 0:
		derrotado.emit(self)
		queue_free()


## Callback del AreaDeteccion. Detecta aliados que entran en rango de ataque.
func _on_area_deteccion_area_entered(area: Area2D) -> void:
	if area.is_in_group("aliados"):
		aliado_objetivo = area


## Callback del AreaDeteccion. Libera el objetivo cuando sale del rango.
func _on_area_deteccion_area_exited(area: Area2D) -> void:
	if not is_instance_valid(aliado_objetivo) or area == aliado_objetivo:
		aliado_objetivo = null
