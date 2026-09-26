class_name Snitch
extends Area2D

## Señal emitida cuando el jugador recoge la snitch haciendo clic.
signal recogida(cantidad: int)

## Valor en snitches que otorga al ser recogida.
@export var valor: int = 25
## Velocidad de caída en píxeles por segundo.
@export var velocidad_caida: float = 60.0
## Tiempo máximo de vida en segundos antes de desaparecer.
@export var tiempo_vida: float = 10.0

var _tiempo_restante: float = 0.0
var _fue_recogida: bool = false


func _ready() -> void:
	_tiempo_restante = tiempo_vida


func _process(delta: float) -> void:
	if _fue_recogida:
		return
	position.y += velocidad_caida * delta
	_tiempo_restante -= delta
	if _tiempo_restante <= 0.0 or global_position.y > 1200.0:
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if _fue_recogida:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) <= 32.0:
			_recoger()
			get_viewport().set_input_as_handled()


## Callback de input_event. Detecta el clic del jugador sobre la snitch.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _fue_recogida:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_recoger()
		get_viewport().set_input_as_handled()


func _recoger() -> void:
	if _fue_recogida:
		return
	_fue_recogida = true
	recogida.emit(valor)
	queue_free()

