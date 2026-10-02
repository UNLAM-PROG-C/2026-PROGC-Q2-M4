class_name Dementor
extends Area2D

## Señal emitida cuando el Dementor se activa y comienza a barrer su fila.
signal activado(entidad: Node2D)
## Señal emitida cuando el Dementor completa el barrido de la fila y es destruido.
signal agotado(entidad: Node2D)

## Velocidad de avance al activarse en píxeles por segundo.
@export var velocidad: float = 800.0
## Daño masivo que inflige a los enemigos de su fila (elimina instantáneamente).
@export var danio: int = 9999

var _esta_activo: bool = false


func _ready() -> void:
	add_to_group("dementores")
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if not _esta_activo:
		# Comprobación de respaldo: si un enemigo de la misma fila llega al Dementor
		_verificar_enemigos_en_posicion()
		return

	# Avanzar barriendo la fila hacia la derecha
	position.x += velocidad * delta

	# Eliminar a todos los enemigos que colisionen o que el Dementor alcance en su fila
	_barrer_fila()

	# Destruir cuando sale del límite derecho de la pantalla
	if global_position.x > 1450.0:
		agotado.emit(self)
		queue_free()


## Activa el avance del Dementor a lo largo de su fila.
func activar() -> void:
	if _esta_activo:
		return
	_esta_activo = true
	activado.emit(self)

	# Animación de salida veloz
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Limpiar enemigos que ya estuvieran en contacto inicial
	_barrer_fila()


## Callback de colisión del Area2D. Detecta cuando un enemigo entra en contacto.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos"):
		if not _esta_activo:
			activar()
		_eliminar_enemigo(area)


## Comprueba si algún enemigo de la misma fila alcanzó la posición del Dementor.
func _verificar_enemigos_en_posicion() -> void:
	for enemigo: Node in get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Node2D and is_instance_valid(enemigo):
			var pos_enemigo: Vector2 = (enemigo as Node2D).global_position
			# Mismo carril horizontal
			if absf(pos_enemigo.y - global_position.y) < 64.0:
				# Si llegó o pasó la posición X del Dementor
				if pos_enemigo.x <= global_position.x + 40.0:
					activar()
					_eliminar_enemigo(enemigo as Node2D)
					break


## Barre y elimina a todos los enemigos de la fila que estén al alcance del Dementor.
func _barrer_fila() -> void:
	# 1. Colisiones directas detectadas por el Area2D
	for area: Area2D in get_overlapping_areas():
		if area.is_in_group("enemigos"):
			_eliminar_enemigo(area)

	# 2. Enemigos en la misma fila horizontal alcanzados por el barrido
	for enemigo: Node in get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Node2D and is_instance_valid(enemigo):
			var pos_enemigo: Vector2 = (enemigo as Node2D).global_position
			if absf(pos_enemigo.y - global_position.y) < 64.0:
				if pos_enemigo.x <= global_position.x + 60.0:
					_eliminar_enemigo(enemigo as Node2D)


## Elimina al enemigo aplicando daño masivo y garantizando su destrucción.
func _eliminar_enemigo(entidad: Node2D) -> void:
	if not is_instance_valid(entidad) or entidad.is_queued_for_deletion():
		return
	if entidad.has_method("take_damage"):
		entidad.call("take_damage", danio)
	else:
		entidad.queue_free()
