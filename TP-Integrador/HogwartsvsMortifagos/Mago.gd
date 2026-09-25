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
	# Creamos una función pública que el zombi llamará para hacerle daño
func recibir_danio(cantidad_danio: float) -> void:
	vida -= cantidad_danio
	
	# Efecto visual opcional para saber que la están comiendo
	$Sprite2D.modulate = Color(0.8, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color(1, 1, 1)
	
	if vida <= 0:
		queue_free() # La planta muere y desaparece
		
