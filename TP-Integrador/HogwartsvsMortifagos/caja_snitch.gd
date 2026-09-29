class_name CajaSnitch
extends Area2D

## Señal emitida al generar Snitches (para compatibilidad).
signal snitches_generadas(cantidad: int)
## Señal emitida cuando la Caja de Snitch expulsa una Snitch física para ser recolectada.
signal snitch_soltada(snitch_instancia: Snitch)
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
## Escena de la Snitch física que expulsa al generar.
@export var escena_snitch: PackedScene


func _ready() -> void:
	add_to_group("aliados")
	$TimerGeneracionSnitches.wait_time = tiempo_generacion
	$TimerGeneracionSnitches.start()


## Callback del TimerGeneracionSnitches. Expulsa una Snitch física para que el jugador la recoja.
func _on_timer_generacion_snitches_timeout() -> void:
	# Efecto visual de generación
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Instanciar Snitch física si está configurada la escena
	var recurso_snitch: PackedScene = escena_snitch
	if recurso_snitch == null:
		recurso_snitch = load("res://snitch.tscn") as PackedScene

	if recurso_snitch != null:
		var nueva_snitch: Snitch = recurso_snitch.instantiate() as Snitch
		if nueva_snitch != null:
			nueva_snitch.valor = snitches_por_generacion
			nueva_snitch.configurar_de_caja(global_position)
			snitch_soltada.emit(nueva_snitch)

	snitches_generadas.emit(snitches_por_generacion)


## Aplica daño a la Caja de Snitch. Llamado por los enemigos al atacar.
func recibir_danio(cantidad: float) -> void:
	salud -= cantidad
	if salud <= 0.0:
		derrotado.emit(self)
		queue_free()
