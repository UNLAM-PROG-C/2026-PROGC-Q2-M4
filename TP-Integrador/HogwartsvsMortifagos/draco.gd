class_name Draco
extends Area2D

## Señal emitida cuando Draco es derrotado.
signal derrotado(entidad: Node2D)
## Señal emitida cuando Draco invade el jardín.
signal invasion_jardin()

## Salud máxima de Draco. El doble de un Alumno Slytherin (200).
@export var salud_maxima: int = 400
## Velocidad de avance en píxeles por segundo.
@export var velocidad: float = 32.0
## Daño infligido por segundo al atacar un aliado.
@export var danio_por_segundo: float = 30.0
## Textura de la grilla de animación cuando está lastimado (< 50 % de salud).
@export var textura_lastimado: Texture2D

## Cantidad total de cuadros en la grilla de animación.
const TOTAL_FRAMES: int = 8

var salud_actual: int = 0
var aliado_objetivo: Area2D = null
## Indica si ya se aplicó la textura de lastimado.
var _lastimado: bool = false


func _ready() -> void:
	salud_actual = salud_maxima
	add_to_group("enemigos")
	$Sprite2D.frame = randi() % TOTAL_FRAMES


func _process(delta: float) -> void:
	if is_instance_valid(aliado_objetivo):
		if aliado_objetivo.has_method("recibir_danio"):
			aliado_objetivo.call("recibir_danio", danio_por_segundo * delta)
	else:
		aliado_objetivo = null
		position.x -= velocidad * delta

	if global_position.x < 0.0:
		invasion_jardin.emit()
		queue_free()


## Avanza al siguiente cuadro de la grilla de animación.
func _on_timer_animacion_timeout() -> void:
	$Sprite2D.frame = ($Sprite2D.frame + 1) % TOTAL_FRAMES


## Aplica daño a Draco. Llamado por los proyectiles al impactar.
func recibir_danio(cantidad: int) -> void:
	salud_actual = maxi(salud_actual - cantidad, 0)

	if not _lastimado and salud_actual <= salud_maxima / 2:
		_lastimado = true
		if textura_lastimado != null:
			var frame_actual: int = $Sprite2D.frame
			$Sprite2D.texture = textura_lastimado
			$Sprite2D.frame = frame_actual

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


## Callback del AreaDeteccion. Suelta al aliado cuando sale del rango.
func _on_area_deteccion_area_exited(area: Area2D) -> void:
	if not is_instance_valid(aliado_objetivo) or area == aliado_objetivo:
		aliado_objetivo = null
