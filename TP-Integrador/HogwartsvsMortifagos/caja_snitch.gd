class_name CajaSnitch
extends Area2D

## Señal emitida al generar Snitches. Incluye la cantidad generada.
signal snitches_generadas(cantidad: int)
## Señal emitida cuando la Caja de Snitch es destruida.
signal derrotado(entidad: Node2D)

## Costo en Snitches para plantar la Caja de Snitch.
@export var coste: int = 50
## Salud total de la Caja de Snitch.
@export var salud: float = 100.0
## Cantidad de Snitches que genera en cada ciclo.
@export var snitches_por_generacion: int = 25
## Segundos entre cada generación de Snitches.
@export var tiempo_generacion: float = 10.0


func _ready() -> void:
	add_to_group("aliados")
	$TimerGeneracionSnitches.wait_time = tiempo_generacion
	$TimerGeneracionSnitches.start()


## Callback del TimerGeneracionSnitches. Emite la señal con la cantidad de Snitches generadas.
func _on_timer_generacion_snitches_timeout() -> void:
	snitches_generadas.emit(snitches_por_generacion)
	# Efecto visual de generación
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)


## Aplica daño a la Caja de Snitch. Llamado por los enemigos al atacar.
func recibir_danio(cantidad: float) -> void:
	salud -= cantidad
	if salud <= 0.0:
		derrotado.emit(self)
		queue_free()
