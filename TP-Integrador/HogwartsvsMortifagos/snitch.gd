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
@export var escape_speed: float = 200.0 # velocidad al escapar
@export var escape_duration: float = 0.3 # duración del escape en segundos
@export var escape_cooldown_time: float = 0.5 # tiempo en segundos antes de poder escapar nuevamente

var _tiempo_restante: float = 0.0
var _fue_recogida: bool = false
var _tiempo_total: float = 0.0
var _start_x: float = 0.0
var _escape_cooldown: float = 0.0
var _tiempo_escape_restante: float = 0.0
var _dir_escape: Vector2 = Vector2.ZERO
var animada: bool = true


func _ready() -> void:
	if not animada:
		if has_node("TimerAnimacion"):
			$TimerAnimacion.stop()
		if has_node("Sprite2D"):
			$Sprite2D.frame = 1
	_tiempo_restante = tiempo_vida
	_start_x = position.x


## Configura la Snitch producida por una Caja de Snitch (pop suave hacia arriba y permanece en el suelo para clic).
func configurar_de_caja(pos_origen: Vector2) -> void:
	animada = false
	velocidad_caida = 0.0
	zigzag_amplitud = 0.0
	escape_distance = 0.0
	_start_x = pos_origen.x + randf_range(-15.0, 15.0)
	global_position = pos_origen
	var salto_y: float = pos_origen.y - 45.0
	var suelo_y: float = pos_origen.y + 15.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position:y", salto_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", suelo_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _process(delta: float) -> void:
	if _fue_recogida:
		return

	# Update timers
	_tiempo_total += delta
	_escape_cooldown = max(_escape_cooldown - delta, 0.0)
	_tiempo_restante -= delta

	if _tiempo_escape_restante > 0.0:
		# Estado: Escapando
		_tiempo_escape_restante -= delta
		position += _dir_escape * escape_speed * delta
		
		# Al terminar el escape, reajustamos el eje del zigzag para evitar un salto brusco
		if _tiempo_escape_restante <= 0.0:
			if zigzag_amplitud > 0.0:
				_start_x = position.x - sin(_tiempo_total * zigzag_frecuencia) * zigzag_amplitud
	else:
		# Estado: Cayendo normalmente
		if zigzag_amplitud > 0.0:
			position.x = _start_x + sin(_tiempo_total * zigzag_frecuencia) * zigzag_amplitud
		
		if velocidad_caida > 0.0:
			position.y += velocidad_caida * delta

		# Comprobar si debe iniciar el escape
		if escape_distance > 0.0 and _escape_cooldown <= 0.0:
			var mouse_pos: Vector2 = get_global_mouse_position()
			if global_position.distance_to(mouse_pos) <= escape_distance:
				_dir_escape = (global_position - mouse_pos).normalized()
				_tiempo_escape_restante = escape_duration
				_escape_cooldown = escape_cooldown_time
				if has_node("ParticulasEscape"):
					$ParticulasEscape.emitting = true

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


func _on_timer_animacion_timeout() -> void:
	if animada and has_node("Sprite2D"):
		$Sprite2D.frame = ($Sprite2D.frame + 1) % 4

