extends TileMapLayer
@export var vida: float = 100.0

var planta_escena = preload("res://Mago.tscn")

# Diccionario para llevar registro de qué celdas ya están ocupadas
var celdas_ocupadas = {}

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var posicion_mouse = get_global_mouse_position()
		var celda_grilla = local_to_map(posicion_mouse)
		
		# Verificamos que sea pasto Y que la celda no esté ocupada
		if get_cell_source_id(celda_grilla) != -1 and not celdas_ocupadas.has(celda_grilla):
			print("Plantando en: ", celda_grilla)
			
			# Instanciamos la planta
			var nueva_planta = planta_escena.instantiate()
			
			# Calculamos el centro de la celda. map_to_local devuelve el centro en píxeles.
			nueva_planta.position = map_to_local(celda_grilla)
			
			# Añadimos la planta como hija del TileMapLayer
			add_child(nueva_planta)
			
			# Registramos la celda como ocupada para no apilar plantas
			celdas_ocupadas[celda_grilla] = true

# 1. Cargamos la escena del Zombi al inicio
var zombi_escena = preload("res://Mortifago.tscn")

# 2. Esta función se ejecuta cada vez que el TimerZombis llega a 0
func _on_timer_spawneo_mortifagos_timeout() -> void:
	# Obtenemos un arreglo (lista) con los 5 Marker2D que pusiste
	var lista_spawners = $"../Spawners".get_children()
	
	# La función nativa pick_random() elige un elemento al azar de la lista
	var spawner_elegido = lista_spawners.pick_random()
	
	# Instanciamos el Zombi en memoria
	var nuevo_zombi = zombi_escena.instantiate()
	
	# Le asignamos la posición exacta del marcador que salió sorteado
	nuevo_zombi.global_position = spawner_elegido.global_position
	
	# Lo agregamos al escenario principal para que empiece a caminar
	add_child(nuevo_zombi)
	
	
