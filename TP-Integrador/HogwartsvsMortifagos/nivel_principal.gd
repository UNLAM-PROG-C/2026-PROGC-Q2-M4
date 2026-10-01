class_name NivelPrincipal
extends Node2D

## Snitches con las que comienza el jugador.
@export var snitches_iniciales: int = 150
## Cantidad total de enemigos que genera el nivel.
@export var total_enemigos: int = 20
## Escena de Harry para instanciar.
@export var escena_harry: PackedScene
## Escena de la Caja de Snitch para instanciar.
@export var escena_caja_snitch: PackedScene
## Escena de la Recordadora para instanciar.
@export var escena_recordadora: PackedScene
## Escena del Alumno Slytherin para instanciar.
@export var escena_alumno_slytherin: PackedScene
@export var escena_draco: PackedScene
@export var escena_protego: PackedScene
@export var tiempo_recarga_protego: float = 12.0

## Escena de la Snitch recolectable para instanciar.
@export var escena_snitch: PackedScene
## Escena del Dementor (cortadora de pasto defensiva) para instanciar.
@export var escena_dementor: PackedScene
## Escena del Menú de Selección de Niveles (Mapa del Merodeador).
@export var escena_menu_niveles: PackedScene

## Fila activa de la grilla (coordenada Y del TileMap).
## Solo estas filas permiten plantación y spawneo en el nivel.
@export var filas_activas: Array[int] = [4]
@export var spawners_activos: Array[NodePath] = []
@export var nivel_siguiente_desbloqueo: int = 2

var snitches: int = 0
var aliado_seleccionado: String = ""
var celdas_ocupadas: Dictionary = {}
var tiempo_recarga_recordadora: float = 0.0
var tiempo_recarga_protego_actual: float = 0.0
var enemigos_generados: int = 0
var enemigos_derrotados: int = 0
var nivel_terminado: bool = false

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawner_central: Marker2D = $Spawners/Marker2D3
@onready var timer_spawneo: Timer = $TimerSpawneoMortifagos
@onready var timer_spawner_snitches: Timer = $SpawnerDeSnitches
@onready var label_snitches: Label = $HUD/LabelSnitches
@onready var boton_harry: Button = $HUD/BotonHarry
@onready var boton_caja_snitch: Button = get_node_or_null("HUD/BotonCajaSnitch")
@onready var boton_recordadora: Button = get_node_or_null("HUD/BotonRecordadora")
@onready var boton_protego: Button = get_node_or_null("HUD/BotonProtego")
@onready var label_estado: Label = $HUD/LabelEstado
@onready var panel_fin_nivel: Control = $HUD/PanelFinNivel
@onready var label_titulo_fin: Label = $HUD/PanelFinNivel/CajaModal/VBox/LabelTitulo
@onready var label_mensaje_fin: Label = $HUD/PanelFinNivel/CajaModal/VBox/LabelMensaje
@onready var boton_siguiente_nivel: Button = $HUD/PanelFinNivel/CajaModal/VBox/HBoxBotones/BotonSiguienteNivel
@onready var boton_reintentar: Button = $HUD/PanelFinNivel/CajaModal/VBox/HBoxBotones/BotonReintentar
@onready var boton_volver_mapa: Button = $HUD/PanelFinNivel/CajaModal/VBox/HBoxBotones/BotonVolverMapa


func _ready() -> void:
	snitches = snitches_iniciales
	if panel_fin_nivel != null:
		panel_fin_nivel.visible = false
	_actualizar_hud()
	_crear_dementores()
	print("[NivelPrincipal] _ready OK | snitches=", snitches, " | escena_harry=", escena_harry, " | escena_caja=", escena_caja_snitch, " | escena_snitch=", escena_snitch, " | escena_dementor=", escena_dementor)

func _process(delta: float) -> void:
	var actualizar_hud: bool = false
	if tiempo_recarga_recordadora > 0.0:
		tiempo_recarga_recordadora = max(tiempo_recarga_recordadora - delta, 0.0)
		if boton_recordadora != null:
			boton_recordadora.disabled = true
		if tiempo_recarga_recordadora <= 0.0:
			actualizar_hud = true
	if tiempo_recarga_protego_actual > 0.0:
		tiempo_recarga_protego_actual = max(tiempo_recarga_protego_actual - delta, 0.0)
		if boton_protego != null:
			boton_protego.disabled = true
		if tiempo_recarga_protego_actual <= 0.0:
			actualizar_hud = true
	if actualizar_hud:
		_actualizar_hud()



## Instancia un Dementor protector en cada fila a la izquierda del jardín (columna 0/1).
func _crear_dementores() -> void:
	if escena_dementor == null:
		return
	var filas_y: Array[float] = [320.0, 448.0, 576.0, 704.0, 832.0]
	var pos_x: float = 160.0
	for y: float in filas_y:
		var dementor: Dementor = escena_dementor.instantiate() as Dementor
		if dementor != null:
			dementor.position = Vector2(pos_x, y)
			add_child(dementor)


func _actualizar_hud() -> void:
	label_snitches.text = "Snitches: " + str(snitches)
	boton_harry.disabled = snitches < 100
	if boton_caja_snitch != null:
		boton_caja_snitch.disabled = snitches < 50
	if boton_recordadora != null:
		boton_recordadora.disabled = snitches < 150 or tiempo_recarga_recordadora > 0.0
	if boton_protego != null:
		boton_protego.disabled = snitches < 50 or tiempo_recarga_protego_actual > 0.0


## Maneja la entrada del jugador para plantar aliados en la grilla.
func _unhandled_input(event: InputEvent) -> void:
	if nivel_terminado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if aliado_seleccionado != "":
			_intentar_plantar()


## Intenta plantar el aliado seleccionado en la celda bajo el cursor.
func _intentar_plantar() -> void:
	var posicion_mouse: Vector2 = tile_map.get_local_mouse_position()
	var celda: Vector2i = tile_map.local_to_map(posicion_mouse)
	var source_id: int = tile_map.get_cell_source_id(celda)

	# Verificar que la celda está en la fila activa
	if not celda.y in filas_activas:
		print("[NivelPrincipal] Plantación ignorada: la fila ", celda.y, " no está activa (filas activas: ", filas_activas, ")")
		return
	# Verificar que la celda tiene un tile válido
	if source_id == -1:
		return
	# Verificar que la celda no está ocupada
	if celdas_ocupadas.has(celda):
		return

	var escena: PackedScene = null
	var coste_aliado: int = 0
	match aliado_seleccionado:
		"harry":
			escena = escena_harry
			coste_aliado = 100
		"caja_snitch":
			escena = escena_caja_snitch
			coste_aliado = 50
		"recordadora":
			escena = escena_recordadora
			coste_aliado = 150
		"protego":
			escena = escena_protego
			coste_aliado = 50

	if escena == null or snitches < coste_aliado:
		return

	# Descontar snitches
	snitches -= coste_aliado

	# Instanciar y posicionar el aliado
	var nuevo_aliado: Node2D = escena.instantiate() as Node2D
	if nuevo_aliado == null:
		snitches += coste_aliado
		return
	var centro_celda: Vector2 = tile_map.map_to_local(celda)
	nuevo_aliado.position = centro_celda
	tile_map.add_child(nuevo_aliado)
	celdas_ocupadas[celda] = nuevo_aliado

	# Conectar señales del aliado (solo CajaSnitch necesita señal adicional)
	if nuevo_aliado is CajaSnitch:
		var caja: CajaSnitch = nuevo_aliado as CajaSnitch
		caja.snitch_soltada.connect(_on_snitch_soltada)

	nuevo_aliado.tree_exiting.connect(_on_aliado_eliminado.bind(celda))

	# Si es Recordadora, iniciar cooldown
	if aliado_seleccionado == "recordadora":
		tiempo_recarga_recordadora = 25.0
	if aliado_seleccionado == "protego":
		tiempo_recarga_protego_actual = tiempo_recarga_protego

	# Deseleccionar y actualizar HUD
	aliado_seleccionado = ""
	_actualizar_seleccion_visual()
	_actualizar_hud()


## Callback cuando la Caja de Snitch expulsa una Snitch física para ser recolectada.
func _on_snitch_soltada(snitch_instancia: Snitch) -> void:
	add_child(snitch_instancia)
	snitch_instancia.recogida.connect(_on_snitch_recogida)


## Callback de compatibilidad cuando la Caja de Snitch genera Snitches directamente.
func _on_snitches_generadas(cantidad: int) -> void:
	snitches += cantidad
	_actualizar_hud()


## Callback cuando el SpawnerDeSnitches genera una Snitch del cielo.
func _on_spawner_de_snitches_timeout() -> void:
	if nivel_terminado or escena_snitch == null:
		return
	var nueva_snitch: Snitch = escena_snitch.instantiate() as Snitch
	if nueva_snitch == null:
		return
	var x_pos: float = randf_range(300.0, 1150.0)
	nueva_snitch.position = Vector2(x_pos, -20.0)
	add_child(nueva_snitch)
	nueva_snitch.recogida.connect(_on_snitch_recogida)


## Callback cuando el jugador hace clic y recoge una Snitch.
func _on_snitch_recogida(cantidad: int) -> void:
	snitches += cantidad
	_actualizar_hud()


## Callback cuando un aliado es eliminado. Libera su celda en la grilla.
func _on_aliado_eliminado(celda: Vector2i) -> void:
	celdas_ocupadas.erase(celda)


## Callback del TimerSpawneoMortifagos. Genera un nuevo Alumno Slytherin.
func _on_timer_spawneo_timeout() -> void:
	if nivel_terminado:
		return
	if enemigos_generados >= total_enemigos:
		timer_spawneo.stop()
		return

	var enemy_scene: PackedScene = escena_alumno_slytherin
	if escena_draco != null and randi() % 2 == 0:
		enemy_scene = escena_draco
		
	if enemy_scene == null:
		return
		
	var nuevo_enemigo: Node2D = enemy_scene.instantiate() as Node2D
	if spawners_activos.size() > 0:
		var spawner = spawners_activos.pick_random()
		if typeof(spawner) == TYPE_NODE_PATH:
			spawner = get_node(spawner)
		nuevo_enemigo.global_position = spawner.global_position
	else:
		nuevo_enemigo.global_position = spawner_central.global_position
	add_child(nuevo_enemigo)
	enemigos_generados += 1

	# Conectar señales del enemigo
	nuevo_enemigo.connect("derrotado", _on_enemigo_derrotado)
	nuevo_enemigo.connect("invasion_jardin", _on_invasion_jardin)


## Callback cuando un enemigo es derrotado. Verifica condición de victoria.
func _on_enemigo_derrotado(_entidad: Node2D) -> void:
	enemigos_derrotados += 1
	_verificar_victoria()


## Callback cuando un enemigo invade el jardín. Activa la derrota.
func _on_invasion_jardin() -> void:
	_derrota()


## Verifica si todos los enemigos fueron derrotados para activar la victoria.
func _verificar_victoria() -> void:
	if enemigos_generados >= total_enemigos and enemigos_derrotados >= total_enemigos:
		_victoria()


## Activa la victoria del nivel y muestra el menú interactivo.
func _victoria() -> void:
	nivel_terminado = true
	timer_spawneo.stop()
	timer_spawner_snitches.stop()

	# Actualizar la progresión en el mapa para desbloquear el siguiente nivel
	MenuNiveles.progreso_desbloqueado = maxi(MenuNiveles.progreso_desbloqueado, nivel_siguiente_desbloqueo)
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and "nivel_maximo_desbloqueado" in game_manager:
		var actual: int = int(game_manager.get("nivel_maximo_desbloqueado"))
		game_manager.set("nivel_maximo_desbloqueado", maxi(actual, nivel_siguiente_desbloqueo))

	if panel_fin_nivel != null:
		label_titulo_fin.text = "¡VICTORIA!"
		label_mensaje_fin.text = "¡Has defendido el jardín con éxito!\nNivel %d desbloqueado en el Mapa del Merodeador." % nivel_siguiente_desbloqueo
		boton_siguiente_nivel.visible = true
		panel_fin_nivel.visible = true
	else:
		label_estado.text = "¡VICTORIA!"
		label_estado.visible = true


## Activa la derrota del nivel y muestra el menú interactivo.
func _derrota() -> void:
	if nivel_terminado:
		return
	nivel_terminado = true
	timer_spawneo.stop()
	timer_spawner_snitches.stop()

	if panel_fin_nivel != null:
		label_titulo_fin.text = "¡DERROTA!"
		label_mensaje_fin.text = "Los mortífagos han invadido el jardín de Hogwarts."
		boton_siguiente_nivel.visible = false
		panel_fin_nivel.visible = true
	else:
		label_estado.text = "¡DERROTA!"
		label_estado.visible = true


## Callbacks del panel interactivo de fin de nivel
func _on_boton_siguiente_nivel_pressed() -> void:
	_volver_al_mapa()


func _on_boton_volver_mapa_pressed() -> void:
	_volver_al_mapa()


func _on_boton_reintentar_pressed() -> void:
	get_tree().reload_current_scene()


func _volver_al_mapa() -> void:
	if escena_menu_niveles != null:
		get_tree().change_scene_to_packed(escena_menu_niveles)
	else:
		get_tree().change_scene_to_file("res://menu_niveles.tscn")


## Callback del botón de Harry. Alterna la selección de Harry.
func _on_boton_harry_pressed() -> void:
	if aliado_seleccionado == "harry":
		aliado_seleccionado = ""
	else:
		aliado_seleccionado = "harry"
	_actualizar_seleccion_visual()


## Callback del botón de Caja de Snitch. Alterna la selección de la Caja de Snitch.
func _on_boton_caja_snitch_pressed() -> void:
	if aliado_seleccionado == "caja_snitch":
		aliado_seleccionado = ""
	else:
		aliado_seleccionado = "caja_snitch"
	_actualizar_seleccion_visual()

func _on_boton_recordadora_pressed() -> void:
	if aliado_seleccionado == "recordadora":
		aliado_seleccionado = ""
	else:
		aliado_seleccionado = "recordadora"
	_actualizar_seleccion_visual()

func _on_boton_protego_pressed() -> void:
	if aliado_seleccionado == "protego":
		aliado_seleccionado = ""
	else:
		aliado_seleccionado = "protego"
	_actualizar_seleccion_visual()


## Actualiza la apariencia visual de los botones según la selección actual.
func _actualizar_seleccion_visual() -> void:
	boton_harry.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "harry" else Color(1.0, 1.0, 1.0)
	if boton_caja_snitch != null:
		boton_caja_snitch.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "caja_snitch" else Color(1.0, 1.0, 1.0)
	if boton_recordadora != null:
		boton_recordadora.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "recordadora" else Color(1.0, 1.0, 1.0)
	if boton_protego != null:
		boton_protego.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "protego" else Color(1.0, 1.0, 1.0)
