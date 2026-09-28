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

# Parámetros de movimiento en zigzag
@export var zigzag_amplitud: float = 60.0 # píxeles de desplazamiento lateral máximo
@export var zigzag_frecuencia: float = 3.0 # radianes por segundo (controla rapidez del zigzag)

# Parámetros de escape al acercarse el mouse
@export var escape_distance: float = 80.0 # distancia a la que la snitch reacciona
# Duplicate escape_distance removed
@export var escape_offset: float = 30.0 # desplazamiento extra al escapar
@export var escape_cooldown_time: float = 0.5 # tiempo en segundos antes de poder escapar nuevamente

var _tiempo_restante: float = 0.0
var _fue_recogida: bool = false
var _tiempo_total: float = 0.0
var _start_x: float = 0.0
var _escape_cooldown: float = 0.0


func _ready() -> void:
	_tiempo_restante = tiempo_vida
	_start_x = position.x


func _process(delta: float) -> void:
	if _fue_recogida:
		return

	# Update timers
	_tiempo_total += delta
	_escape_cooldown = max(_escape_cooldown - delta, 0.0)

	# Zigzag horizontal movement
	position.x = _start_x + sin(_tiempo_total * zigzag_frecuencia) * zigzag_amplitud

	# Vertical falling
	position.y += velocidad_caida * delta
	_tiempo_restante -= delta

	# Escape when mouse gets close
	if _escape_cooldown <= 0.0:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) <= escape_distance:
			var dir: Vector2 = (global_position - mouse_pos).normalized()
			position += dir * escape_offset
			_escape_cooldown = escape_cooldown_time

	# Lifetime check
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

# New global input handling to ensure collection even if other nodes consume the event
func _input(event: InputEvent) -> void:
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

