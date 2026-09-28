class_name NivelPrincipal
extends Node2D

## Snitches con las que comienza el jugador.
@export var snitches_iniciales: int = 150
## Cantidad total de enemigos que genera el nivel.
@export var total_enemigos: int = 10
## Escena de Harry para instanciar.
@export var escena_harry: PackedScene
## Escena de la Caja de Snitch para instanciar.
@export var escena_caja_snitch: PackedScene
## Escena del Alumno Slytherin para instanciar.
@export var escena_alumno_slytherin: PackedScene
## Escena de la Snitch recolectable para instanciar.
@export var escena_snitch: PackedScene
## Escena del Dementor (cortadora de pasto defensiva) para instanciar.
@export var escena_dementor: PackedScene

## Fila activa de la grilla (coordenada Y del TileMap).
## Solo esta fila permite plantación y spawneo en el Nivel 1.
const FILA_ACTIVA: int = 4

var snitches: int = 0
var aliado_seleccionado: String = ""
var celdas_ocupadas: Dictionary = {}
var enemigos_generados: int = 0
var enemigos_derrotados: int = 0
var nivel_terminado: bool = false

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawner_central: Marker2D = $Spawners/Marker2D3
@onready var timer_spawneo: Timer = $TimerSpawneoMortifagos
@onready var timer_spawner_snitches: Timer = $SpawnerDeSnitches
@onready var label_snitches: Label = $HUD/LabelSnitches
@onready var boton_harry: Button = $HUD/BotonHarry
@onready var boton_caja_snitch: Button = $HUD/BotonCajaSnitch
@onready var label_estado: Label = $HUD/LabelEstado


func _ready() -> void:
	snitches = snitches_iniciales
	_actualizar_hud()
	_crear_dementores()
	print("[NivelPrincipal] _ready OK | snitches=", snitches, " | escena_harry=", escena_harry, " | escena_caja=", escena_caja_snitch, " | escena_snitch=", escena_snitch, " | escena_dementor=", escena_dementor)


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


## Actualiza la interfaz del HUD con el saldo actual y el estado de los botones.
func _actualizar_hud() -> void:
	label_snitches.text = "Snitches: " + str(snitches)
	boton_harry.disabled = snitches < 100
	boton_caja_snitch.disabled = snitches < 50


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
	if celda.y != FILA_ACTIVA:
		print("[NivelPrincipal] Plantación ignorada: la fila ", celda.y, " está bloqueada en Nivel 1 (fila activa: ", FILA_ACTIVA, ")")
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

	# Conectar señales del aliado
	if nuevo_aliado is CajaSnitch:
		(nuevo_aliado as CajaSnitch).snitches_generadas.connect(_on_snitches_generadas)

	nuevo_aliado.tree_exiting.connect(_on_aliado_eliminado.bind(celda))

	# Deseleccionar y actualizar HUD
	aliado_seleccionado = ""
	_actualizar_seleccion_visual()
	_actualizar_hud()


## Callback cuando la Caja de Snitch genera Snitches.
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

	var nuevo_enemigo: Node2D = escena_alumno_slytherin.instantiate() as Node2D
	if nuevo_enemigo == null:
		return
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


## Activa la victoria del nivel.
func _victoria() -> void:
	nivel_terminado = true
	timer_spawneo.stop()
	timer_spawner_snitches.stop()
	label_estado.text = "¡VICTORIA!"
	label_estado.visible = true


## Activa la derrota del nivel.
func _derrota() -> void:
	if nivel_terminado:
		return
	nivel_terminado = true
	timer_spawneo.stop()
	timer_spawner_snitches.stop()
	label_estado.text = "¡DERROTA!"
	label_estado.visible = true


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


## Actualiza la apariencia visual de los botones según la selección actual.
func _actualizar_seleccion_visual() -> void:
	boton_harry.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "harry" else Color(1.0, 1.0, 1.0)
	boton_caja_snitch.modulate = Color(0.5, 1.0, 0.5) if aliado_seleccionado == "caja_snitch" else Color(1.0, 1.0, 1.0)
