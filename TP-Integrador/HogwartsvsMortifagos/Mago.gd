extends Area2D

@export var vida: float = 100.0
# preload() carga el archivo en memoria al inicio, equivalente a un import/require
var proyectil_escena = preload("res://proyectil.tscn")

# Esta función se ejecuta cada 1.5 segundos gracias a la señal del Timer
func _on_timer_timeout():
	# Instanciamos el objeto en memoria
	var nuevo_proyectil = proyectil_escena.instantiate()
	
	# SETEO CRÍTICO: No agregamos el proyectil como hijo de la planta. 
	# Si lo hacemos, las coordenadas del proyectil serán relativas a la planta, y si la planta muere, el proyectil desaparece.
	# Lo agregamos al árbol principal (root) del juego.
	get_tree().current_scene.add_child(nuevo_proyectil)
	
	# Posicionamos el proyectil exactamente donde pusimos nuestro Marker2D
	nuevo_proyectil.global_position = $PuntoDisparo.global_position

var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta
		
	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			$Sprite2D.modulate = Color(1.0, 1.0, 1.0)


# Creamos una función pública que el zombi llamará para hacerle daño
func recibir_danio(cantidad_danio: float) -> void:
	vida -= cantidad_danio

	# Efecto visual: parpadeo rojo con enfriamiento
	if _cooldown_flash <= 0.0:
		$Sprite2D.modulate = Color(0.8, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5

	if vida <= 0:
		queue_free() # La planta muere y desaparece
		
