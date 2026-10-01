class_name Protego
extends Area2D

## Señal emitida cuando Protego pierde toda su salud.
signal derrotado(entidad: Node2D)

## Costo en Snitches para plantar un Protego.
@export var coste: int = 50
## Segundos de recarga de la carta después de plantarlo.
@export var tiempo_recarga: float = 12.0
## Salud de la barrera. Mucho mayor que la de un mago.
@export var salud: float = 4000.0

var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _ready() -> void:
	add_to_group("aliados")


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta
	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			$Visual.modulate = Color(1.0, 1.0, 1.0)


## Absorbe daño sin atacar. Llamado por los enemigos al colisionar.
func recibir_danio(cantidad: float) -> void:
	salud -= cantidad
	if _cooldown_flash <= 0.0:
		$Visual.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5
	if salud <= 0.0:
		derrotado.emit(self)
		queue_free()
