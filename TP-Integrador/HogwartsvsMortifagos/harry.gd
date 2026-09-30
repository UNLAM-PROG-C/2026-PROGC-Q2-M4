class_name Harry
extends Area2D

## Señal emitida cuando Harry pierde toda su salud.
signal derrotado(entidad: Node2D)

## Costo en Snitches para plantar a Harry.
@export var coste: int = 100
## Salud total de Harry.
@export var salud: float = 100.0
## Segundos entre cada disparo.
@export var tiempo_recarga: float = 1.5
## Escena del proyectil que dispara Harry.
@export var escena_proyectil: PackedScene


func _ready() -> void:
	add_to_group("aliados")
	$TimerDisparo.wait_time = tiempo_recarga
	$TimerDisparo.start()


## Callback del TimerDisparo. Dispara un proyectil si hay un enemigo en la misma línea.
func _on_timer_disparo_timeout() -> void:
	if escena_proyectil == null:
		return
	if not _hay_enemigo_en_linea():
		return
	var nuevo_proyectil: Area2D = escena_proyectil.instantiate()
	nuevo_proyectil.global_position = $PuntoDisparo.global_position
	get_tree().current_scene.add_child(nuevo_proyectil)


## Verifica si existe al menos un enemigo válido en la misma línea horizontal.
func _hay_enemigo_en_linea() -> bool:
	for enemigo: Node in get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Node2D and is_instance_valid(enemigo):
			if absf((enemigo as Node2D).global_position.y - global_position.y) < 64.0:
				return true
	return false


var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta
		
	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			$Sprite2D.modulate = Color(1.0, 1.0, 1.0)


## Aplica daño a Harry. Llamado por los enemigos al atacar.
func recibir_danio(cantidad: float) -> void:
	salud -= cantidad
	
	# Efecto visual de daño (parpadeo rojo con enfriamiento)
	if _cooldown_flash <= 0.0:
		$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5
		
	if salud <= 0.0:
		derrotado.emit(self)
		queue_free()

