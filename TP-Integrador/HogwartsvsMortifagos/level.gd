class_name Level
extends Node2D

const BOARD_SNAPSHOT_SCRIPT: Script = preload("res://board_snapshot.gd")
const DEFENSE_SNAPSHOT_SCRIPT: Script = preload("res://defense_snapshot.gd")
const STATE_SPAWNING_NORMAL: int = 0
const STATE_WAVE_PREPARATION: int = 1
const STATE_WAVE_ACTIVE: int = 2
const STATE_WAITING_FOR_CLEAR: int = 3
const STATE_FINAL_WAVE_PREPARATION: int = 4
const STATE_LEVEL_COMPLETE: int = 5
const STANDARD_WAVE_RATIO: float = 0.5
const SPECIAL_FIRST_WAVE_RATIO: float = 0.33
const SPECIAL_SECOND_WAVE_RATIO: float = 0.66
const WAVE_ANNOUNCEMENT_TEXT: String = "¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"
const FINAL_WAVE_ANNOUNCEMENT_TEXT: String = "¡OLEADA FINAL!"
const WAVE_ANNOUNCEMENT_DURATION: float = 2.0
const DEBUG_SNITCHES: int = 10000
## A playable level: places allies from the HUD cards on the grid, spawns
## enemies, runs the Snitch economy and shows the win/lose end panel.

const SNITCHES_LABEL_TEXT: String = "Snitches: "
const ACCIO_HOVER_COLOR: Color = Color(1.0, 0.4, 0.4, 0.8)
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
## Initial delay in seconds before the first enemy spawns in any level.
const INITIAL_ENEMY_DELAY: float = 30.0

## Snitches the player starts with.
@export var starting_snitches: int = 150
## Total number of enemies the level spawns.
@export var total_enemies: int = 20
## Enemy scenes spawned by the level, picked at random.
@export var enemy_scenes: Array[PackedScene] = []
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
@export var dementor_row_cells: Array[int] = []
@export var dementor_cells: Array[Vector2i] = []
## Level unlocked on the map when this level is won.
@export var next_level_to_unlock: int = 2
@export var is_special_level: bool = false
@export var intermediate_wave_min: int = 10
@export var intermediate_wave_max: int = 20
@export var final_wave_min: int = 25
@export var final_wave_bonus_min: int = 5
@export var final_wave_bonus_max: int = 10

var _snitches: int = 0
## Card chosen in the HUD, or null when nothing is selected.
var _selected_card: AllyCard = null
var _occupied_cells: Dictionary[Vector2i, Node2D] = {}
var _is_removing: bool = false
var _hovered_ally: Ally = null
var _accio_button: AccioButton = null
var _accio_cursor: CanvasItem = null
var _spawned_enemies: int = 0
var _defeated_enemies: int = 0
var _regular_defeated_enemies: int = 0
var _active_enemies: int = 0
var _wave_state: int = STATE_SPAWNING_NORMAL
var _wave_threshold_index: int = 0
var _intermediate_wave_size: int = 10
var _final_wave_active: bool = false
var _level_generation: int = 1
var _pending_request_id: int = 0
var _defeated_enemy_ids: Dictionary[int, bool] = {}
var _regular_enemy_ids: Dictionary[int, bool] = {}
var _is_level_over: bool = false
var _enemy_spawn_interval: float = 8.0

@onready var tile_map: TileMapLayer = _find_tile_map()
@onready var entity_layer: Node2D = $Entities
@onready var projectile_pool: ProjectilePool = $Entities/ProjectilePool
@onready var wave_director: WaveDirector = $WaveDirector
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var snitch_spawn_timer: Timer = $SnitchSpawnTimer
@onready var hud: CanvasLayer = $HUD
@onready var snitches_label: Label = $HUD/SnitchesLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var pool_debug_label: Label = $HUD/PoolDebugLabel
@onready var wave_announcement: ColorRect = $HUD/WaveAnnouncement
@onready var wave_announcement_label: Label = $HUD/WaveAnnouncement/Label
@onready var level_end_panel: Control = $HUD/LevelEndPanel
@onready var end_title_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/TitleLabel
@onready var end_message_label: Label = $HUD/LevelEndPanel/ModalBox/VBox/MessageLabel
@onready var next_level_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/NextLevelButton
@onready var retry_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/RetryButton
@onready var back_to_map_button: Button = $HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/BackToMapButton


func _ready() -> void:
	_init_level_state()
	_init_hud_and_cards()
	_init_pool_and_defense()
	_init_accio_nodes()
	_init_spawn_timers()


func _init_level_state() -> void:
	_snitches = DEBUG_SNITCHES if _is_debug_mode_enabled() else starting_snitches
	level_end_panel.visible = false
	wave_announcement.visible = false
	_intermediate_wave_size = intermediate_wave_min
	wave_director.result_ready.connect(_on_wave_result)


func _init_hud_and_cards() -> void:
	for button: AllyCardButton in _card_buttons():
		button.card_pressed.connect(_on_card_pressed)
		button.cooldown_finished.connect(_refresh_hud)
	_refresh_hud()


func _init_pool_and_defense() -> void:
	projectile_pool.stats_changed.connect(_on_pool_stats_changed)
	_update_pool_debug_label(projectile_pool.shots_fired, projectile_pool.get_pool_size(), projectile_pool.active_projectiles.size())
	_spawn_dementors()


func _init_spawn_timers() -> void:
	_enemy_spawn_interval = enemy_spawn_timer.wait_time
	enemy_spawn_timer.stop()
	enemy_spawn_timer.start(INITIAL_ENEMY_DELAY)


func _init_accio_nodes() -> void:
	_accio_button = hud.get_node_or_null("AccioButton") as AccioButton
	if _accio_button != null:
		_accio_button.accio_toggled.connect(_on_accio_toggled)
	_accio_cursor = hud.get_node_or_null("AccioCursor") as CanvasItem
	if _accio_cursor != null:
		_accio_cursor.visible = false


func _is_debug_mode_enabled() -> bool:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	return game_manager != null and bool(game_manager.get("debug_mode"))


func _process(_delta: float) -> void:
	if not _is_level_over:
		wave_director.poll_results()
	_update_accio_process()


func _update_accio_process() -> void:
	if not _is_removing:
		return
	if _accio_cursor != null:
		_accio_cursor.global_position = get_viewport().get_mouse_position()
	_update_hovered_ally(_cell_under_mouse())


func _find_tile_map() -> TileMapLayer:
	var direct_tile_map: TileMapLayer = get_node_or_null("TileMapLayer") as TileMapLayer
	if direct_tile_map != null:
		return direct_tile_map
	return get_node("Grid/TileMapLayer") as TileMapLayer


## Spawns a protective Dementor on each row left of the garden.
func _spawn_dementors() -> void:
	if not dementor_cells.is_empty():
		for cell: Vector2i in dementor_cells:
			var dementor: Dementor = dementor_scene.instantiate() as Dementor
			dementor.global_position = tile_map.to_global(tile_map.map_to_local(cell))
			entity_layer.add_child(dementor)
		return

	if not dementor_row_cells.is_empty():
		var first_column_center: Vector2 = tile_map.to_global(tile_map.map_to_local(Vector2i(2, dementor_row_cells[0])))
		var cell_width: float = tile_map.tile_set.tile_size.x * tile_map.global_scale.x
		var dementor_x: float = first_column_center.x - cell_width
		for row: int in dementor_row_cells:
			var configured_dementor: Dementor = dementor_scene.instantiate() as Dementor
			var row_center: Vector2 = tile_map.to_global(tile_map.map_to_local(Vector2i(2, row)))
			configured_dementor.global_position = Vector2(dementor_x, row_center.y)
			entity_layer.add_child(configured_dementor)
		return

	for row_y: float in DEMENTOR_ROWS_Y:
		var dementor: Dementor = dementor_scene.instantiate() as Dementor
		dementor.position = Vector2(DEMENTOR_X, row_y)
		entity_layer.add_child(dementor)


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


func _on_pool_stats_changed(shots_fired: int, pool_size: int, active_count: int) -> void:
	_update_pool_debug_label(shots_fired, pool_size, active_count)


func _update_pool_debug_label(shots_fired: int, pool_size: int, active_count: int) -> void:
	pool_debug_label.text = "DEBUG | Disparos consecutivos: %d\nPool: %d | Activos: %d | Disponibles: %d" % [
		shots_fired,
		pool_size,
		active_count,
		pool_size - active_count
	]


## Toggles the clicked card: clicking the selected card deselects it.
func _on_card_pressed(button: AllyCardButton) -> void:
	if _is_removing:
		_cancel_accio()
	_selected_card = null if _selected_card == button.card else button.card
	_refresh_card_selection()


func _on_accio_toggled(is_active: bool) -> void:
	if is_active:
		_selected_card = null
		_refresh_card_selection()
		_set_cursor_mode(true)
	else:
		_set_cursor_mode(false)


func _set_cursor_mode(is_removing: bool) -> void:
	_is_removing = is_removing
	if _accio_button != null and _accio_button.is_active() != is_removing:
		_accio_button.set_active(is_removing)
	if _accio_cursor != null:
		_accio_cursor.visible = is_removing
	var mode: Input.MouseMode = Input.MOUSE_MODE_HIDDEN if is_removing else Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(mode)
	if not is_removing:
		_clear_hovered_ally()


func _cancel_accio() -> void:
	_set_cursor_mode(false)


func _refresh_card_selection() -> void:
	for button: AllyCardButton in _card_buttons():
		button.set_selected(button.card == _selected_card)


## Places the selected ally or executes Accio removal.
func _unhandled_input(event: InputEvent) -> void:
	if _is_level_over:
		return
	if _is_cancel_event(event):
		_handle_cancel_input()
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()


func _is_cancel_event(event: InputEvent) -> bool:
	if event is InputEventKey and event.is_pressed() and (event as InputEventKey).keycode == KEY_ESCAPE:
		return true
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	return mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT


func _handle_cancel_input() -> void:
	if _is_removing:
		_cancel_accio()
	elif _selected_card != null:
		_selected_card = null
		_refresh_card_selection()


func _handle_left_click() -> void:
	if _is_removing:
		_try_remove_ally(_cell_under_mouse())
	elif _selected_card != null:
		_try_place_ally()


func _update_hovered_ally(cell: Vector2i) -> void:
	var ally: Ally = _occupied_cells.get(cell) as Ally
	if ally == _hovered_ally:
		return
	_clear_hovered_ally()
	if is_instance_valid(ally):
		_hovered_ally = ally
		_hovered_ally.modulate = ACCIO_HOVER_COLOR


func _clear_hovered_ally() -> void:
	if is_instance_valid(_hovered_ally):
		_hovered_ally.modulate = Color.WHITE
	_hovered_ally = null


func _try_remove_ally(cell: Vector2i) -> void:
	if not _occupied_cells.has(cell):
		return
	var ally: Ally = _occupied_cells[cell] as Ally
	_occupied_cells.erase(cell)
	_clear_hovered_ally()
	_set_cursor_mode(false)
	if is_instance_valid(ally):
		ally.queue_free()


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
	ally.global_position = tile_map.to_global(tile_map.map_to_local(cell))
	_init_placed_ally(ally)
	entity_layer.add_child(ally)
	_register_placed_ally(ally, cell)
	_finalize_ally_placement(card)


func _register_placed_ally(ally: Ally, cell: Vector2i) -> void:
	if ally is Broomstick:
		_handle_broomstick_placed(ally as Broomstick, cell)
		return
	_occupied_cells[cell] = ally
	ally.tree_exiting.connect(_on_ally_removed.bind(cell))


func _handle_broomstick_placed(broom: Broomstick, cell: Vector2i) -> void:
	var first_col_pos: Vector2 = tile_map.to_global(tile_map.map_to_local(Vector2i(2, cell.y)))
	broom.global_position.x = minf(0.0, first_col_pos.x - 200.0)


func _finalize_ally_placement(card: AllyCard) -> void:
	_snitches -= card.cost
	_button_for(card).start_cooldown()
	_selected_card = null
	_refresh_card_selection()
	_refresh_hud()


func _init_placed_ally(ally: Ally) -> void:
	if ally is Harry:
		(ally as Harry).projectile_pool = projectile_pool
	elif ally is Hermione:
		(ally as Hermione).projectile_pool = projectile_pool
	elif ally is McGonagall:
		(ally as McGonagall).projectile_pool = projectile_pool
	elif "projectile_pool" in ally:
		ally.set("projectile_pool", projectile_pool)
	if ally is SnitchBox:
		(ally as SnitchBox).snitch_dropped.connect(_on_snitch_dropped)


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
	entity_layer.add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


## SnitchSpawnTimer callback. Spawns a Snitch falling from the sky.
func _on_snitch_spawn_timer_timeout() -> void:
	if _is_level_over:
		return
	var snitch: Snitch = snitch_scene.instantiate() as Snitch
	snitch.position = Vector2(randf_range(SKY_SNITCH_MIN_X, SKY_SNITCH_MAX_X), SKY_SNITCH_Y)
	entity_layer.add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


## Callback when the player clicks and collects a Snitch.
func _on_snitch_collected(amount: int) -> void:
	_snitches += amount
	_refresh_hud()


## EnemySpawnTimer callback. Spawns a new enemy until total_enemies is reached.
func _on_enemy_spawn_timer_timeout() -> void:
	if _is_level_over or _wave_state != STATE_SPAWNING_NORMAL:
		return
	if enemy_spawn_timer.wait_time != _enemy_spawn_interval:
		enemy_spawn_timer.wait_time = _enemy_spawn_interval
		enemy_spawn_timer.start()
	if _spawned_enemies >= total_enemies:
		enemy_spawn_timer.stop()
		_try_prepare_final_wave()
		return
	_spawn_enemy(enemy_scenes.pick_random(), true)


func _spawn_enemy(scene: PackedScene, counts_as_regular: bool) -> void:
	var enemy: Enemy = scene.instantiate() as Enemy
	enemy.global_position = _pick_spawn_position()
	entity_layer.add_child(enemy)
	if counts_as_regular:
		_spawned_enemies += 1
	_active_enemies += 1
	_regular_enemy_ids[enemy.get_instance_id()] = counts_as_regular
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.garden_invaded.connect(_on_garden_invaded)


func _pick_spawn_position() -> Vector2:
	var spawn_point: Node2D = get_node(spawn_points.pick_random()) as Node2D
	return spawn_point.global_position


## Callback when an enemy is defeated. Checks the victory condition.
func _on_enemy_defeated(entity: Node2D) -> void:
	var enemy_id: int = entity.get_instance_id()
	if _defeated_enemy_ids.has(enemy_id):
		return
	_defeated_enemy_ids[enemy_id] = true
	_defeated_enemies += 1
	if _regular_enemy_ids.get(enemy_id, false):
		_regular_defeated_enemies += 1
	_active_enemies = maxi(_active_enemies - 1, 0)
	_update_wave_progress()


## Callback when an enemy invades the garden. Triggers the defeat.
func _on_garden_invaded() -> void:
	_lose()


## Triggers the victory once every enemy has been defeated.
func _update_wave_progress() -> void:
	if _active_enemies > 0:
		return
	if _wave_state == STATE_WAITING_FOR_CLEAR:
		_resume_after_wave()
		return
	if _wave_state == STATE_SPAWNING_NORMAL:
		_try_prepare_intermediate_wave()
		if _wave_state == STATE_SPAWNING_NORMAL:
			_try_prepare_final_wave()


func _try_prepare_intermediate_wave() -> void:
	var next_index: int = _wave_threshold_index + 1
	var threshold_ratio: float = STANDARD_WAVE_RATIO
	if is_special_level:
		threshold_ratio = SPECIAL_FIRST_WAVE_RATIO if next_index == 1 else SPECIAL_SECOND_WAVE_RATIO
	var threshold: int = maxi(1, ceili(float(total_enemies) * threshold_ratio))
	var max_intermediate_waves: int = 2 if is_special_level else 1
	if next_index > max_intermediate_waves:
		return
	if _regular_defeated_enemies < threshold:
		return
	_wave_threshold_index = next_index
	_wave_state = STATE_WAVE_PREPARATION
	enemy_spawn_timer.stop()
	_request_wave(false)


func _try_prepare_final_wave() -> void:
	if _spawned_enemies < total_enemies or _active_enemies > 0:
		return
	var required_thresholds: int = 2 if is_special_level else 1
	if _wave_state == STATE_LEVEL_COMPLETE or _wave_threshold_index < required_thresholds:
		return
	_wave_state = STATE_FINAL_WAVE_PREPARATION
	_request_wave(true)


func _request_wave(is_final: bool) -> void:
	var snapshot: RefCounted = _build_snapshot()
	_pending_request_id = wave_director.request_plan(snapshot, is_final)


func _build_snapshot() -> RefCounted:
	var snapshot: RefCounted = BOARD_SNAPSHOT_SCRIPT.new()
	snapshot.set("level_generation", _level_generation)
	snapshot.set("state", _wave_state)
	snapshot.set("regular_defeated", _regular_defeated_enemies)
	snapshot.set("regular_budget", total_enemies)
	snapshot.set("active_enemies", _active_enemies)
	snapshot.set("defense_value", _defense_value())
	snapshot.set("is_special_level", is_special_level)
	snapshot.set("threshold_index", _wave_threshold_index)
	snapshot.set("intermediate_wave_size", _intermediate_wave_size)
	snapshot.set("intermediate_wave_min", intermediate_wave_min)
	snapshot.set("intermediate_wave_max", intermediate_wave_max)
	snapshot.set("final_wave_min", final_wave_min)
	snapshot.set("final_wave_bonus_min", final_wave_bonus_min)
	snapshot.set("final_wave_bonus_max", final_wave_bonus_max)
	snapshot.set("row_indices", active_rows)
	return snapshot


func _defense_value() -> float:
	var ally_value: float = 0.0
	for ally_node: Node2D in _occupied_cells.values():
		if is_instance_valid(ally_node) and ally_node is Ally:
			ally_value += (ally_node as Ally).health
	var snapshot: RefCounted = DEFENSE_SNAPSHOT_SCRIPT.new()
	snapshot.call("set_values", ally_value, 0.0)
	return snapshot.get("total_value")


func _on_wave_result(result: RefCounted) -> void:
	if _is_level_over or result.get("level_generation") != _level_generation:
		return
	if result.get("request_id") != _pending_request_id or result.get("cancelled"):
		return
	var plan: RefCounted = result.get("plan")
	if plan == null:
		return
	_apply_wave_plan(plan)


func _apply_wave_plan(plan: RefCounted) -> void:
	if _wave_state != STATE_WAVE_PREPARATION and _wave_state != STATE_FINAL_WAVE_PREPARATION:
		return
	_final_wave_active = bool(plan.get("is_final"))
	if not _final_wave_active:
		_intermediate_wave_size = plan.get("enemy_count")
	_wave_state = STATE_WAVE_ACTIVE
	await _show_wave_announcement()
	_spawn_wave_enemies(plan)


func _show_wave_announcement() -> void:
	if _final_wave_active:
		wave_announcement_label.text = FINAL_WAVE_ANNOUNCEMENT_TEXT
	else:
		wave_announcement_label.text = WAVE_ANNOUNCEMENT_TEXT
	wave_announcement.visible = true
	await get_tree().create_timer(WAVE_ANNOUNCEMENT_DURATION).timeout
	if is_instance_valid(wave_announcement):
		wave_announcement.visible = false


func _spawn_wave_enemies(plan: RefCounted) -> void:
	var enemy_count: int = plan.get("enemy_count")
	var spawn_delay: float = plan.get("spawn_delay")
	for index: int in range(enemy_count):
		if index > 0 and spawn_delay > 0.0:
			await get_tree().create_timer(spawn_delay).timeout
		if _is_level_over:
			return
		_spawn_enemy(enemy_scenes.pick_random(), false)
	_wave_state = STATE_WAITING_FOR_CLEAR


func _resume_after_wave() -> void:
	if _wave_state != STATE_WAITING_FOR_CLEAR:
		return
	if _final_wave_active:
		_wave_state = STATE_LEVEL_COMPLETE
		_win()
		return
	if _spawned_enemies >= total_enemies:
		_try_prepare_final_wave()
		return
	_wave_state = STATE_SPAWNING_NORMAL
	enemy_spawn_timer.start()


## Wins the level, unlocks the next one and shows the end panel.
func _win() -> void:
	_stop_level()
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("unlock_level"):
		game_manager.call("unlock_level", next_level_to_unlock)
	_show_end_panel(WIN_TITLE_TEXT, WIN_MESSAGE_TEXT % next_level_to_unlock, true)


## Loses the level and shows the end panel.
func _lose() -> void:
	if _is_level_over:
		return
	_stop_level()
	_show_end_panel(LOSE_TITLE_TEXT, LOSE_MESSAGE_TEXT, false)


func _stop_level() -> void:
	if _is_removing:
		_set_cursor_mode(false)
	_is_level_over = true
	_level_generation += 1
	enemy_spawn_timer.stop()
	snitch_spawn_timer.stop()
	wave_director.cancel_and_wait()
	projectile_pool.release_all()


func _exit_tree() -> void:
	if _is_removing:
		_set_cursor_mode(false)
	if is_instance_valid(wave_director):
		wave_director.cancel_and_wait()
	if is_instance_valid(projectile_pool):
		projectile_pool.release_all()


func _show_end_panel(title: String, message: String, show_next: bool) -> void:
	if level_end_panel == null:
		status_label.text = title
		status_label.visible = true
		return
	end_title_label.text = title
	end_message_label.text = message
	next_level_button.visible = show_next
	level_end_panel.visible = true


## Callbacks of the interactive level end panel
func _on_next_level_button_pressed() -> void:
	_go_to_map()


func _on_back_to_map_button_pressed() -> void:
	_go_to_map()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _go_to_map() -> void:
	get_tree().change_scene_to_file(level_select_scene)
