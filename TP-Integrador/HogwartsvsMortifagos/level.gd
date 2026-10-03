class_name Level
extends Node2D

## A playable level: places allies from the HUD cards on the grid, spawns
## enemies, runs the Snitch economy and shows the win/lose end panel.

const SNITCHES_LABEL_TEXT: String = "Snitches: "
const WIN_TITLE_TEXT: String = "¡VICTORIA!"
const WIN_MESSAGE_TEXT: String = "¡Has defendido el jardín con éxito!\nNivel %d desbloqueado en el Mapa del Merodeador."
const LOSE_TITLE_TEXT: String = "¡DERROTA!"
const LOSE_MESSAGE_TEXT: String = "Los mortífagos han invadido el jardín de Hogwarts."
## Lane y coordinates where a Dementor is placed, and their x coordinate.
const DEMENTOR_ROWS_Y: Array[float] = [320.0, 448.0, 576.0, 704.0, 832.0]
const DEMENTOR_X: float = 160.0
## Horizontal range and starting height of Snitches falling from the sky.
const SKY_SNITCH_MIN_X: float = 300.0
const SKY_SNITCH_MAX_X: float = 1150.0
const SKY_SNITCH_Y: float = -20.0
## TileMapLayer source id of a cell without a tile.
const EMPTY_CELL_SOURCE: int = -1

## Snitches the player starts with.
@export var starting_snitches: int = 150
## Total number of enemies the level spawns.
@export var total_enemies: int = 20
## Slytherin Student scene to instantiate.
@export var escena_alumno_slytherin: PackedScene
@export var escena_draco: PackedScene
## Collectable Snitch scene to instantiate.
@export var snitch_scene: PackedScene
## Dementor scene (defensive lawnmower) to instantiate.
@export var dementor_scene: PackedScene
## Level Select Menu scene (Marauder's Map). A path, not a PackedScene:
## the menu already references every level, and Godot rejects cyclic scene references.
@export_file("*.tscn") var level_select_scene: String
## Active grid rows (TileMap y coordinate). Only these rows accept allies.
@export var active_rows: Array[int] = [4]
## Markers where enemies spawn, picked at random.
@export var spawn_points: Array[NodePath] = []
## Level unlocked on the map when this level is won.
@export var next_level_to_unlock: int = 2

var _snitches: int = 0
## Card chosen in the HUD, or null when nothing is selected.
var _selected_card: AllyCard = null
var _occupied_cells: Dictionary[Vector2i, Node2D] = {}
var _spawned_enemies: int = 0
var _defeated_enemies: int = 0
var _is_level_over: bool = false

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var spawner_central: Marker2D = $Spawners/Marker2D3
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var snitch_spawn_timer: Timer = $SnitchSpawnTimer
@onready var hud: CanvasLayer = $HUD
@onready var snitches_label: Label = $HUD/SnitchesLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var level_end_panel: Control = $HUD/LevelEndPanel
@onready var end_title_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/TitleLabel
@onready var end_message_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/MessageLabel
@onready var next_level_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/NextLevelButton
@onready var retry_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/RetryButton
@onready var back_to_map_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/BackToMapButton


func _ready() -> void:
	_snitches = starting_snitches
	level_end_panel.visible = false
	for button: AllyCardButton in _card_buttons():
		button.card_pressed.connect(_on_card_pressed)
		button.cooldown_finished.connect(_refresh_hud)
	_refresh_hud()
	_spawn_dementors()


## Spawns a protective Dementor on each row left of the garden.
func _spawn_dementors() -> void:
	for row_y: float in DEMENTOR_ROWS_Y:
		var dementor: Dementor = dementor_scene.instantiate() as Dementor
		dementor.position = Vector2(DEMENTOR_X, row_y)
		add_child(dementor)


func _card_buttons() -> Array[AllyCardButton]:
	var buttons: Array[AllyCardButton] = []
	for child: Node in hud.get_children():
		if child is AllyCardButton:
			buttons.append(child as AllyCardButton)
	return buttons


func _refresh_hud() -> void:
	snitches_label.text = SNITCHES_LABEL_TEXT + str(_snitches)
	for button: AllyCardButton in _card_buttons():
		button.refresh(_snitches)


## Toggles the clicked card: clicking the selected card deselects it.
func _on_card_pressed(button: AllyCardButton) -> void:
	_selected_card = null if _selected_card == button.card else button.card
	_refresh_card_selection()


func _refresh_card_selection() -> void:
	for button: AllyCardButton in _card_buttons():
		button.set_selected(button.card == _selected_card)


## Places the selected ally when the player clicks the grid.
func _unhandled_input(event: InputEvent) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if _is_level_over or _selected_card == null or mouse_event == null:
		return
	if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_try_place_ally()


## Tries to place the selected ally on the cell under the cursor.
func _try_place_ally() -> void:
	var cell: Vector2i = _cell_under_mouse()
	if _can_place_at(cell) and _snitches >= _selected_card.cost:
		_place_ally(_selected_card, cell)


func _cell_under_mouse() -> Vector2i:
	return tile_map.local_to_map(tile_map.get_local_mouse_position())


## The cell must be on an active row, have a tile and be free.
func _can_place_at(cell: Vector2i) -> bool:
	if not cell.y in active_rows or _occupied_cells.has(cell):
		return false
	return tile_map.get_cell_source_id(cell) != EMPTY_CELL_SOURCE


func _place_ally(card: AllyCard, cell: Vector2i) -> void:
	var ally: Ally = card.scene.instantiate() as Ally
	ally.position = tile_map.map_to_local(cell)
	tile_map.add_child(ally)
	_occupied_cells[cell] = ally
	ally.tree_exiting.connect(_on_ally_removed.bind(cell))
	if ally is SnitchBox:
		(ally as SnitchBox).snitch_dropped.connect(_on_snitch_dropped)
	_snitches -= card.cost
	_button_for(card).start_cooldown()
	_selected_card = null
	_refresh_card_selection()
	_refresh_hud()


func _button_for(card: AllyCard) -> AllyCardButton:
	for button: AllyCardButton in _card_buttons():
		if button.card == card:
			return button
	return null


## Frees the grid cell of an ally that left the tree.
func _on_ally_removed(cell: Vector2i) -> void:
	_occupied_cells.erase(cell)


## Callback when a Snitch Box drops a physical Snitch to be collected.
func _on_snitch_dropped(snitch: Snitch) -> void:
	add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


## SnitchSpawnTimer callback. Spawns a Snitch falling from the sky.
func _on_snitch_spawn_timer_timeout() -> void:
	if _is_level_over:
		return
	var snitch: Snitch = snitch_scene.instantiate() as Snitch
	snitch.position = Vector2(randf_range(SKY_SNITCH_MIN_X, SKY_SNITCH_MAX_X), SKY_SNITCH_Y)
	add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


## Callback when the player clicks and collects a Snitch.
func _on_snitch_collected(amount: int) -> void:
	_snitches += amount
	_refresh_hud()


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

	var new_enemy: Enemy = enemy_scene.instantiate() as Enemy
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
	new_enemy.defeated.connect(_on_enemy_defeated)
	new_enemy.garden_invaded.connect(_on_garden_invaded)


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
	LevelSelectMenu.progreso_desbloqueado = maxi(LevelSelectMenu.progreso_desbloqueado, next_level_to_unlock)
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
	get_tree().change_scene_to_file(level_select_scene)
