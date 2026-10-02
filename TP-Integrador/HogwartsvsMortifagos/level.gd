class_name Level
extends Node2D

const SNITCHES_LABEL_TEXT: String = "Snitches: "
const WIN_TITLE_TEXT: String = "¡VICTORIA!"
const WIN_MESSAGE_TEXT: String = "¡Has defendido el jardín con éxito!\nNivel %d desbloqueado en el Mapa del Merodeador."
const LOSE_TITLE_TEXT: String = "¡DERROTA!"
const LOSE_MESSAGE_TEXT: String = "Los mortífagos han invadido el jardín de Hogwarts."

## Snitches the player starts with.
@export var starting_snitches: int = 150
## Total number of enemies the level spawns.
@export var total_enemies: int = 20
## Harry scene to instantiate.
@export var escena_harry: PackedScene
## Snitch Box scene to instantiate.
@export var escena_caja_snitch: PackedScene
## Remembrall scene to instantiate.
@export var escena_recordadora: PackedScene
## Slytherin Student scene to instantiate.
@export var escena_alumno_slytherin: PackedScene
@export var escena_draco: PackedScene
@export var escena_protego: PackedScene
@export var tiempo_recarga_protego: float = 12.0

## Collectable Snitch scene to instantiate.
@export var snitch_scene: PackedScene
## Dementor scene (defensive lawnmower) to instantiate.
@export var dementor_scene: PackedScene
## Level Select Menu scene (Marauder's Map).
@export var level_select_scene: PackedScene

## Active grid rows (TileMap Y coordinate).
## Only these rows allow placing allies and spawning enemies in the level.
@export var active_rows: Array[int] = [4]
@export var spawn_points: Array[NodePath] = []
@export var next_level_to_unlock: int = 2

var _snitches: int = 0
var _selected_card: String = ""
var _occupied_cells: Dictionary = {}
var tiempo_recarga_recordadora: float = 0.0
var tiempo_recarga_protego_actual: float = 0.0
var _spawned_enemies: int = 0
var _defeated_enemies: int = 0
var _is_level_over: bool = false

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawner_central: Marker2D = $Spawners/Marker2D3
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var snitch_spawn_timer: Timer = $SnitchSpawnTimer
@onready var snitches_label: Label = $HUD/SnitchesLabel
@onready var boton_harry: Button = $HUD/HarryCardButton
@onready var boton_caja_snitch: Button = get_node_or_null("HUD/SnitchBoxCardButton")
@onready var boton_recordadora: Button = get_node_or_null("HUD/RemembrallCardButton")
@onready var boton_protego: Button = get_node_or_null("HUD/ProtegoCardButton")
@onready var status_label: Label = $HUD/StatusLabel
@onready var level_end_panel: Control = $HUD/LevelEndPanel
@onready var end_title_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/TitleLabel
@onready var end_message_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/MessageLabel
@onready var next_level_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/NextLevelButton
@onready var retry_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/RetryButton
@onready var back_to_map_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/BackToMapButton


func _ready() -> void:
	_snitches = starting_snitches
	if level_end_panel != null:
		level_end_panel.visible = false
	_refresh_hud()
	_spawn_dementors()

func _process(delta: float) -> void:
	var refresh_hud: bool = false
	if tiempo_recarga_recordadora > 0.0:
		tiempo_recarga_recordadora = max(tiempo_recarga_recordadora - delta, 0.0)
		if boton_recordadora != null:
			boton_recordadora.disabled = true
		if tiempo_recarga_recordadora <= 0.0:
			refresh_hud = true
	if tiempo_recarga_protego_actual > 0.0:
		tiempo_recarga_protego_actual = max(tiempo_recarga_protego_actual - delta, 0.0)
		if boton_protego != null:
			boton_protego.disabled = true
		if tiempo_recarga_protego_actual <= 0.0:
			refresh_hud = true
	if refresh_hud:
		_refresh_hud()



## Spawns a protective Dementor on each row left of the garden (column 0/1).
func _spawn_dementors() -> void:
	if dementor_scene == null:
		return
	var rows_y: Array[float] = [320.0, 448.0, 576.0, 704.0, 832.0]
	var dementor_x: float = 160.0
	for y: float in rows_y:
		var dementor: Dementor = dementor_scene.instantiate() as Dementor
		if dementor != null:
			dementor.position = Vector2(dementor_x, y)
			add_child(dementor)


func _refresh_hud() -> void:
	snitches_label.text = SNITCHES_LABEL_TEXT + str(_snitches)
	boton_harry.disabled = _snitches < 100
	if boton_caja_snitch != null:
		boton_caja_snitch.disabled = _snitches < 50
	if boton_recordadora != null:
		boton_recordadora.disabled = _snitches < 150 or tiempo_recarga_recordadora > 0.0
	if boton_protego != null:
		boton_protego.disabled = _snitches < 50 or tiempo_recarga_protego_actual > 0.0


## Handles player input to place allies on the grid.
func _unhandled_input(event: InputEvent) -> void:
	if _is_level_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _selected_card != "":
			_try_place_ally()


## Tries to place the selected ally on the cell under the cursor.
func _try_place_ally() -> void:
	var mouse_position: Vector2 = tile_map.get_local_mouse_position()
	var cell: Vector2i = tile_map.local_to_map(mouse_position)
	var source_id: int = tile_map.get_cell_source_id(cell)

	# The cell must be on an active row
	if not cell.y in active_rows:
		return
	# The cell must have a valid tile
	if source_id == -1:
		return
	# The cell must be free
	if _occupied_cells.has(cell):
		return

	var scene: PackedScene = null
	var ally_cost: int = 0
	match _selected_card:
		"harry":
			scene = escena_harry
			ally_cost = 100
		"snitch_box":
			scene = escena_caja_snitch
			ally_cost = 50
		"remembrall":
			scene = escena_recordadora
			ally_cost = 150
		"protego":
			scene = escena_protego
			ally_cost = 50

	if scene == null or _snitches < ally_cost:
		return

	# Spend snitches
	_snitches -= ally_cost

	# Instantiate and position the ally
	var new_ally: Node2D = scene.instantiate() as Node2D
	if new_ally == null:
		_snitches += ally_cost
		return
	var cell_center: Vector2 = tile_map.map_to_local(cell)
	new_ally.position = cell_center
	tile_map.add_child(new_ally)
	_occupied_cells[cell] = new_ally

	# Connect ally signals (only SnitchBox needs an extra one)
	if new_ally is SnitchBox:
		var snitch_box: SnitchBox = new_ally as SnitchBox
		snitch_box.snitch_dropped.connect(_on_snitch_dropped)

	new_ally.tree_exiting.connect(_on_ally_removed.bind(cell))

	# Start the cooldown of cards that have one
	if _selected_card == "remembrall":
		tiempo_recarga_recordadora = 25.0
	if _selected_card == "protego":
		tiempo_recarga_protego_actual = tiempo_recarga_protego

	# Deselect and refresh the HUD
	_selected_card = ""
	_refresh_card_selection()
	_refresh_hud()


## Callback when the Snitch Box drops a physical Snitch to be collected.
func _on_snitch_dropped(snitch: Snitch) -> void:
	add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


## Compatibility callback for a Snitch Box generating Snitches directly.
func _on_snitches_generadas(amount: int) -> void:
	_snitches += amount
	_refresh_hud()


## SnitchSpawnTimer callback. Spawns a Snitch falling from the sky.
func _on_snitch_spawn_timer_timeout() -> void:
	if _is_level_over or snitch_scene == null:
		return
	var new_snitch: Snitch = snitch_scene.instantiate() as Snitch
	if new_snitch == null:
		return
	var x_position: float = randf_range(300.0, 1150.0)
	new_snitch.position = Vector2(x_position, -20.0)
	add_child(new_snitch)
	new_snitch.collected.connect(_on_snitch_collected)


## Callback when the player clicks and collects a Snitch.
func _on_snitch_collected(amount: int) -> void:
	_snitches += amount
	_refresh_hud()


## Callback when an ally is removed. Frees its grid cell.
func _on_ally_removed(cell: Vector2i) -> void:
	_occupied_cells.erase(cell)


## EnemySpawnTimer callback. Spawns a new enemy.
func _on_enemy_spawn_timer_timeout() -> void:
	if _is_level_over:
		return
	if _spawned_enemies >= total_enemies:
		enemy_spawn_timer.stop()
		return

	var enemy_scene: PackedScene = escena_alumno_slytherin
	if escena_draco != null and randi() % 2 == 0:
		enemy_scene = escena_draco

	if enemy_scene == null:
		return

	var new_enemy: Node2D = enemy_scene.instantiate() as Node2D
	if spawn_points.size() > 0:
		var spawner = spawn_points.pick_random()
		if typeof(spawner) == TYPE_NODE_PATH:
			spawner = get_node(spawner)
		new_enemy.global_position = spawner.global_position
	else:
		new_enemy.global_position = spawner_central.global_position
	add_child(new_enemy)
	_spawned_enemies += 1

	# Connect enemy signals
	new_enemy.connect("defeated", _on_enemy_defeated)
	new_enemy.connect("garden_invaded", _on_garden_invaded)


## Callback when an enemy is defeated. Checks the victory condition.
func _on_enemy_defeated(_entity: Node2D) -> void:
	_defeated_enemies += 1
	_check_victory()


## Callback when an enemy invades the garden. Triggers the defeat.
func _on_garden_invaded() -> void:
	_lose()


## Triggers the victory once every enemy has been defeated.
func _check_victory() -> void:
	if _spawned_enemies >= total_enemies and _defeated_enemies >= total_enemies:
		_win()


## Wins the level and shows the interactive end panel.
func _win() -> void:
	_is_level_over = true
	enemy_spawn_timer.stop()
	snitch_spawn_timer.stop()

	# Update the map progression to unlock the next level
	MenuNiveles.progreso_desbloqueado = maxi(MenuNiveles.progreso_desbloqueado, next_level_to_unlock)
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and "nivel_maximo_desbloqueado" in game_manager:
		var current: int = int(game_manager.get("nivel_maximo_desbloqueado"))
		game_manager.set("nivel_maximo_desbloqueado", maxi(current, next_level_to_unlock))

	if level_end_panel != null:
		end_title_label.text = WIN_TITLE_TEXT
		end_message_label.text = WIN_MESSAGE_TEXT % next_level_to_unlock
		next_level_button.visible = true
		level_end_panel.visible = true
	else:
		status_label.text = WIN_TITLE_TEXT
		status_label.visible = true


## Loses the level and shows the interactive end panel.
func _lose() -> void:
	if _is_level_over:
		return
	_is_level_over = true
	enemy_spawn_timer.stop()
	snitch_spawn_timer.stop()

	if level_end_panel != null:
		end_title_label.text = LOSE_TITLE_TEXT
		end_message_label.text = LOSE_MESSAGE_TEXT
		next_level_button.visible = false
		level_end_panel.visible = true
	else:
		status_label.text = LOSE_TITLE_TEXT
		status_label.visible = true


## Callbacks of the interactive level end panel
func _on_next_level_button_pressed() -> void:
	_go_to_map()


func _on_back_to_map_button_pressed() -> void:
	_go_to_map()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _go_to_map() -> void:
	if level_select_scene != null:
		get_tree().change_scene_to_packed(level_select_scene)
	else:
		get_tree().change_scene_to_file("res://menu_niveles.tscn")


## Harry button callback. Toggles Harry's selection.
func _on_boton_harry_pressed() -> void:
	if _selected_card == "harry":
		_selected_card = ""
	else:
		_selected_card = "harry"
	_refresh_card_selection()


## Snitch Box button callback. Toggles the Snitch Box selection.
func _on_boton_caja_snitch_pressed() -> void:
	if _selected_card == "snitch_box":
		_selected_card = ""
	else:
		_selected_card = "snitch_box"
	_refresh_card_selection()

func _on_boton_recordadora_pressed() -> void:
	if _selected_card == "remembrall":
		_selected_card = ""
	else:
		_selected_card = "remembrall"
	_refresh_card_selection()

func _on_boton_protego_pressed() -> void:
	if _selected_card == "protego":
		_selected_card = ""
	else:
		_selected_card = "protego"
	_refresh_card_selection()


## Updates the card buttons' look according to the current selection.
func _refresh_card_selection() -> void:
	boton_harry.modulate = Color(0.5, 1.0, 0.5) if _selected_card == "harry" else Color(1.0, 1.0, 1.0)
	if boton_caja_snitch != null:
		boton_caja_snitch.modulate = Color(0.5, 1.0, 0.5) if _selected_card == "snitch_box" else Color(1.0, 1.0, 1.0)
	if boton_recordadora != null:
		boton_recordadora.modulate = Color(0.5, 1.0, 0.5) if _selected_card == "remembrall" else Color(1.0, 1.0, 1.0)
	if boton_protego != null:
		boton_protego.modulate = Color(0.5, 1.0, 0.5) if _selected_card == "protego" else Color(1.0, 1.0, 1.0)
