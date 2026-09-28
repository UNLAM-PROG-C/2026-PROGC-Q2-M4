class_name Huella
extends Node2D

## Representa una huella individual del Mapa del Merodeador (pie izquierdo o derecho).
## Utiliza _draw() para renderizado vectorial nítido sin dependencias de texturas externas.

@export var color_tinta: Color = Color(0.235, 0.141, 0.082, 0.85) ## #3c2415
@export var es_pie_derecho: bool = true
@export var radio_suela: Vector2 = Vector2(5.5, 9.0)
@export var radio_talon: Vector2 = Vector2(4.0, 5.0)
@export var distancia_talon: float = 13.0

var _opacidad_base: float = 0.85


func _ready() -> void:
	modulate.a = _opacidad_base


func configurar(pie_derecho: bool, opacidad: float = 0.85) -> void:
	es_pie_derecho = pie_derecho
	_opacidad_base = opacidad
	modulate.a = opacidad
	queue_redraw()


func _draw() -> void:
	var color_final: Color = color_tinta
	var signo_pie: float = 1.0 if es_pie_derecho else -1.0

	# 1. Dibujar la suela (elipse orientada hacia adelante con leve curvatura)
	var centro_suela: Vector2 = Vector2(signo_pie * 1.0, -2.0)
	draw_set_transform(centro_suela, deg_to_rad(signo_pie * 6.0), Vector2.ONE)
	draw_colored_polygon(_generar_puntos_elipse(Vector2.ZERO, radio_suela, 16), color_final)

	# 2. Dibujar el talón (elipse menor en la parte posterior)
	var centro_talon: Vector2 = Vector2(-signo_pie * 0.5, distancia_talon)
	draw_set_transform(centro_talon, deg_to_rad(-signo_pie * 3.0), Vector2.ONE)
	draw_colored_polygon(_generar_puntos_elipse(Vector2.ZERO, radio_talon, 12), color_final)


func _generar_puntos_elipse(centro: Vector2, radios: Vector2, segmentos: int) -> PackedVector2Array:
	var puntos: PackedVector2Array = PackedVector2Array()
	var paso: float = TAU / float(segmentos)
	for i: int in range(segmentos):
		var angulo: float = float(i) * paso
		puntos.append(centro + Vector2(cos(angulo) * radios.x, sin(angulo) * radios.y))
	return puntos


## Desvanecimiento suave con Tween y reciclaje/eliminación automática.
func desvanecer(duracion: float, callback_al_terminar: Callable = Callable()) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duracion)
	if callback_al_terminar.is_valid():
		tween.tween_callback(callback_al_terminar)
	else:
		tween.tween_callback(queue_free)
