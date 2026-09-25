extends Area2D

@export var velocidad: float = 30.0
@export var vida: int = 100
@export var danio_por_segundo: float = 30.0

var danio_proyectil: int = 20 

# Renombramos la variable para mantener la coherencia
var mago_objetivo: Area2D = null

func _process(delta: float) -> void:
	if is_instance_valid(mago_objetivo):
		# ESTADO: ATACANDO AL MAGO
		mago_objetivo.recibir_danio(danio_por_segundo * delta)
	else:
		# ESTADO: CAMINANDO
		position.x -= velocidad * delta
		
	if global_position.x < -100:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("proyectiles"):
		vida -= danio_proyectil
		area.queue_free() 
		
		$Sprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color(1, 1, 1)
		
		if vida <= 0:
			queue_free()
			
	# Actualizamos la palabra clave que busca el motor
	elif area.is_in_group("Magos"):
		mago_objetivo = area
