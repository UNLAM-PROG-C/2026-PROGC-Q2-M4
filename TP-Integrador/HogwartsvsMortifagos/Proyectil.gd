extends Area2D

var velocidad = 400 # Píxeles por segundo

func _process(delta):
	# En Godot, el eje X positivo va hacia la derecha.
	# Multiplicamos por delta (tiempo entre frames) para que el movimiento sea independiente de los FPS.
	position.x += velocidad * delta
	
	# Garbage collection manual: Si sale de la pantalla, lo destruimos para liberar memoria
	if global_position.x > 2000:
		queue_free()
