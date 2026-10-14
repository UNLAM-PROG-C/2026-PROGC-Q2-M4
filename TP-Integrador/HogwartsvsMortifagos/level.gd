class_name Level
extends Node2D

const BOARD_SNAPSHOT_SCRIPT: Script = preload("res://board_snapshot.gd")
const DEFENSE_SNAPSHOT_SCRIPT: Script = preload("res://defense_snapshot.gd")
const WAVE_PLAN_SCRIPT: Script = preload("res://wave_plan.gd")
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
const PARCHMENT_TEXT_COLOR: Color = Color(0.235, 0.141, 0.082, 1.0)
const WAVE_ANNOUNCEMENT_FONT_SIZE: int = 44
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
const DEFAULT_SNITCH_ROW: int = 4
const FIRST_GRID_ROW_INDEX: int = 2
const GRID_SAMPLE_COLUMN: int = 2
## TileMapLayer source id of a cell without a tile.
const EMPTY_CELL_SOURCE: int = -1
## Initial delay in seconds before the first enemy spawns in any level.
const INITIAL_ENEMY_DELAY: float = 30.0
const MIN_ENEMY_SPAWN_INTERVAL: float = 3.0
const SPAWN_INTERVAL_DECREMENT: float = 0.2
const SINGLE_SPAWN_COUNT: int = 1
const DOUBLE_SPAWN_COUNT: int = 2
const TRIPLE_SPAWN_COUNT: int = 3
const MULTI_SPAWN_TRIPLE_CHANCE: float = 0.10
const MULTI_SPAWN_DOUBLE_CHANCE: float = 0.25
const SECOND_ENEMY_SPAWN_DELAY: float = 0.010
const THIRD_ENEMY_SPAWN_DELAY: float = 0.030
const WAVE_PROGRESS_BAR_SCENE: PackedScene = preload("res://wave_progress_bar.tscn")
const WAVE_METER_2_WAVES_TEXTURE: Texture2D = preload("res://Images/wave_meter_2_waves.png")
const WAVE_METER_3_WAVES_TEXTURE: Texture2D = preload("res://Images/wave_meter_3_waves.png")
const WAVE_CHARGE_1_WAVE_TEXTURE: Texture2D = preload("res://Images/wave_charge_1_wave.png")
const WAVE_CHARGE_2_WAVES_TEXTURE: Texture2D = preload("res://Images/wave_charge_2_waves.png")
const METER_POSITION: Vector2 = Vector2(30.0, 800.0)
const BOSS_WIN_MESSAGE_TEXT: String = "¡Has derrotado al Profesor Quirrell y salvado a Hogwarts!"
const BOSS_HEALTH_BAR_POSITION: Vector2 = Vector2(25.0, 280.0)
const DARK_MARK_CUTSCENE_SCENE: PackedScene = preload("res://dark_mark_cutscene.tscn")
const BOSS_GRID_COLUMN: int = 10
const CRUSH_DAMAGE: float = 9999.0
const BOSS_TELEPORT_FADE_DURATION: float = 0.8
const BOSS_SHADOW_Y_OFFSET: float = 132.0
const BOSS_FALLBACK_X: float = 1704.0
const FINAL_LEVEL_NUMBER: int = 10
const NEXT_LEVEL_SCENE_TEMPLATE: String = "res://level_%d.tscn"

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
## Current level number (if 0, inferred from next_level_to_unlock or is_boss_level).
@export var current_level_number: int = 0
## Level unlocked on the map when this level is won.
@export var next_level_to_unlock: int = 2
@export var is_special_level: bool = false
@export var intermediate_wave_min: int = 10
@export var intermediate_wave_max: int = 20
@export var final_wave_min: int = 25
@export var final_wave_bonus_min: int = 5
@export var final_wave_bonus_max: int = 10
## Kill thresholds per wave.
@export var wave_kill_thresholds: Array[int] = [15, 15]
## Texture for the wave meter hourglass frame.
@export var wave_meter_texture: Texture2D
## Texture for the wave meter fill charge.
@export var wave_charge_texture: Texture2D
@export var is_boss_level: bool = false
@export var boss_scene: PackedScene
## Number of completed waves before Trolls are allowed to spawn.
@export var troll_delay_waves: int = 0

var _snitches: int = 0
## Card chosen in the HUD, or null when nothing is selected.
var _selected_card: AllyCard = null
var _occupied_cells: Dictionary[Vector2i, Node2D] = {}
var _is_removing: bool = false
var _boss: Quirrell = null
var _boss_offset: Vector2 = Vector2.ZERO
var _boss_health_bar: BossHealthBar = null
var _hovered_ally: Ally = null
var _accio_button: AccioButton = null
var _accio_cursor: CanvasItem = null
var _spawned_enemies: int = 0
var _defeated_enemies: int = 0
var _phase_defeated_enemies: int = 0
var _total_defeated_enemies: int = 0
var _current_phase_index: int = 0
var _completed_waves: int = 0
var _total_level_kills: int = 0
var _active_enemies: int = 0
var _wave_state: int = STATE_SPAWNING_NORMAL
var _intermediate_wave_size: int = 10
var _final_wave_active: bool = false
var _level_generation: int = 1
var _pending_request_id: int = 0
var _pending_wave_plan: RefCounted = null
var _defeated_enemy_ids: Dictionary[int, bool] = {}
var _regular_enemy_ids: Dictionary[int, bool] = {}
var _is_level_over: bool = false
var _enemy_spawn_interval: float = 12.0
var _wave_progress_bar: WaveProgressBar = null

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
@onready var wave_announcement: Control = $HUD/WaveAnnouncement
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
	_completed_waves = 0
	_current_phase_index = 0
	_phase_defeated_enemies = 0
	_total_defeated_enemies = 0
	_pending_wave_plan = null
	_calculate_total_level_kills()
	if not is_boss_level and is_instance_valid(wave_director):
		wave_director.result_ready.connect(_on_wave_result)


func _calculate_total_level_kills() -> void:
	_total_level_kills = 0
	for threshold: int in wave_kill_thresholds:
		_total_level_kills += threshold
	if _total_level_kills <= 0:
		_total_level_kills = total_enemies


func _init_hud_and_cards() -> void:
	for button: AllyCardButton in _card_buttons():
		button.card_pressed.connect(_on_card_pressed)
		button.cooldown_finished.connect(_refresh_hud)
	_setup_level_hud()
	_refresh_hud()


func _setup_level_hud() -> void:
	_init_wave_announcement_format()
	if is_boss_level:
		_setup_boss_hud()
	else:
		_setup_wave_progress_bar()


func _init_wave_announcement_format() -> void:
	if wave_announcement_label == null:
		return
	wave_announcement_label.add_theme_color_override(&"font_color", PARCHMENT_TEXT_COLOR)
	wave_announcement_label.add_theme_font_size_override(&"font_size", WAVE_ANNOUNCEMENT_FONT_SIZE)
	wave_announcement_label.remove_theme_color_override(&"font_outline_color")
	wave_announcement_label.remove_theme_constant_override(&"outline_size")


func _setup_boss_hud() -> void:
	_boss_health_bar = hud.get_node_or_null("BossHealthBar") as BossHealthBar
	if _boss_health_bar == null:
		var scene: PackedScene = preload("res://boss_health_bar.tscn")
		_boss_health_bar = scene.instantiate() as BossHealthBar
		hud.add_child(_boss_health_bar)
	_boss_health_bar.position = BOSS_HEALTH_BAR_POSITION
	_setup_boss_entity()


func _setup_boss_entity() -> void:
	_boss = get_node_or_null("Entities/Quirrell") as Quirrell
	if _boss == null:
		_boss = get_node_or_null("Quirrell") as Quirrell
	if _boss != null:
		_connect_boss_signals()
		_init_boss_position()


func _init_boss_position() -> void:
	var base_pos: Vector2 = _get_boss_cell_position(_boss.get_current_cell())
	if _boss.global_position != Vector2.ZERO:
		_boss_offset = _boss.global_position - base_pos
	_place_boss_at_cell(_boss.get_current_cell())


func _get_boss_cell_position(cell: Vector2i) -> Vector2:
	if tile_map != null:
		return tile_map.to_global(tile_map.map_to_local(cell))
	return Vector2(BOSS_FALLBACK_X, _get_row_center_y(cell.y))


func _connect_boss_signals() -> void:
	_boss.health_changed.connect(_on_boss_health_changed)
	_boss.teleported.connect(_on_boss_teleported)
	_boss.shadow_spawn_requested.connect(_on_boss_single_shadow_spawn_requested)
	_boss.mass_shadow_spawn_requested.connect(_on_boss_mass_shadow_spawn_requested)
	_boss.defeated.connect(_on_boss_defeated)
	_boss.phase_two_started.connect(_on_boss_phase_two_started)


func _on_boss_single_shadow_spawn_requested(spawn_pos: Vector2, _ignored_y: float) -> void:
	var row_idx: int = _get_boss_shadow_spawn_row()
	var lane_y: float = _get_row_center_y(row_idx)
	_on_boss_shadow_spawn_requested(spawn_pos, lane_y)


func _get_boss_shadow_spawn_row() -> int:
	if _boss == null:
		return DEFAULT_SNITCH_ROW
	var candidates: Array[int] = []
	if active_rows.has(_boss.current_row):
		candidates.append(_boss.current_row)
	if active_rows.has(_boss.current_row - 1):
		candidates.append(_boss.current_row - 1)
	if candidates.is_empty():
		return _boss.current_row
	return candidates.pick_random()



func _on_boss_phase_two_started(boss_pos: Vector2) -> void:
	var cutscene: CanvasLayer = DARK_MARK_CUTSCENE_SCENE.instantiate() as CanvasLayer
	hud.add_child(cutscene)
	cutscene.call(&"play", boss_pos)


func _place_boss_at_cell(cell: Vector2i) -> void:
	if _boss != null:
		_boss.global_position = _get_boss_cell_position(cell) + _boss_offset
		_boss.update_row_z_index()


func _on_boss_health_changed(current: float, _max_val: float) -> void:
	if _boss_health_bar != null:
		_boss_health_bar.set_health(current)


func _on_boss_teleported(from_cell: Vector2i, to_cell: Vector2i) -> void:
	_spawn_teleport_shadow(from_cell)
	_place_boss_at_cell(to_cell)
	_crush_ally_at_cell(to_cell)


func _spawn_teleport_shadow(cell: Vector2i) -> void:
	if tile_map == null:
		return
	var sprite: Sprite2D = _create_shadow_sprite(cell)
	entity_layer.add_child(sprite)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, BOSS_TELEPORT_FADE_DURATION)
	tween.tween_callback(sprite.queue_free)


func _create_shadow_sprite(cell: Vector2i) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = preload("res://Images/character_shadow.png")
	sprite.hframes = 2
	sprite.frame = 0
	sprite.modulate = Color(0.0, 0.0, 0.0, 0.6)
	sprite.global_position = _get_boss_cell_position(cell) + _boss_offset + Vector2(0.0, BOSS_SHADOW_Y_OFFSET)
	return sprite


func _crush_ally_at_cell(cell: Vector2i) -> void:
	if not _occupied_cells.has(cell):
		return
	var ally: Node2D = _occupied_cells[cell]
	_occupied_cells.erase(cell)
	if is_instance_valid(ally):
		if ally.has_method("take_damage"):
			ally.take_damage(CRUSH_DAMAGE)
		else:
			ally.queue_free()


func _on_boss_shadow_spawn_requested(spawn_pos: Vector2, lane_y: float) -> void:
	var shadow_scene: PackedScene = preload("res://shadow_enemy.tscn")
	var shadow: ShadowEnemy = shadow_scene.instantiate() as ShadowEnemy
	var spawn_y: float = lane_y if lane_y != 0.0 else (_get_row_center_y(_boss.current_row) if _boss != null else spawn_pos.y)
	shadow.global_position = Vector2(spawn_pos.x, spawn_y)
	shadow.defeated.connect(_on_enemy_defeated)
	shadow.garden_invaded.connect(_on_garden_invaded)
	entity_layer.add_child(shadow)
	shadow.update_row_z_index()
	_active_enemies += 1


func _on_boss_mass_shadow_spawn_requested() -> void:
	for row_idx: int in active_rows:
		var pos_x: float = _boss.global_position.x if _boss != null else BOSS_FALLBACK_X
		var lane_y: float = _get_row_center_y(row_idx)
		_spawn_mass_shadow(Vector2(pos_x, lane_y))


func _spawn_mass_shadow(pos: Vector2) -> void:
	_on_boss_shadow_spawn_requested(pos, pos.y)


func _on_boss_defeated(_entity: Node2D) -> void:
	_defeat_all_active_enemies()
	_win()


func _defeat_all_active_enemies() -> void:
	for enemy: Node in get_tree().get_nodes_in_group(Groups.ENEMIES):
		if is_instance_valid(enemy) and enemy != _boss:
			enemy.queue_free()


func _setup_wave_progress_bar() -> void:
	_ensure_wave_progress_bar_instance()
	var is_3_waves: bool = wave_kill_thresholds.size() == 3
	var meter_tex: Texture2D = wave_meter_texture
	if meter_tex == null:
		meter_tex = WAVE_METER_3_WAVES_TEXTURE if is_3_waves else WAVE_METER_2_WAVES_TEXTURE
	var charge_tex: Texture2D = wave_charge_texture
	if charge_tex == null:
		charge_tex = WAVE_CHARGE_2_WAVES_TEXTURE if is_3_waves else WAVE_CHARGE_1_WAVE_TEXTURE
	_wave_progress_bar.setup(_total_level_kills, meter_tex, charge_tex)


func _ensure_wave_progress_bar_instance() -> void:
	_wave_progress_bar = hud.get_node_or_null("WaveProgressBar") as WaveProgressBar
	if _wave_progress_bar == null:
		_wave_progress_bar = WAVE_PROGRESS_BAR_SCENE.instantiate() as WaveProgressBar
		_wave_progress_bar.position = METER_POSITION
		hud.add_child(_wave_progress_bar)


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
	if _accio_cursor == null and _accio_button != null:
		var scene: PackedScene = load("res://accio_cursor.tscn") as PackedScene
		if scene != null:
			_accio_cursor = scene.instantiate() as CanvasItem
			_accio_cursor.name = "AccioCursor"
			hud.add_child(_accio_cursor)
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
	if not _is_removing and not _is_accio_glowing():
		return
	if _accio_cursor != null:
		_accio_cursor.global_position = get_viewport().get_mouse_position()
	if _is_removing:
		_update_hovered_ally(_cell_under_mouse())


func _is_accio_glowing() -> bool:
	var cursor: AccioCursor = _accio_cursor as AccioCursor
	return cursor != null and cursor.is_glowing()


func _find_tile_map() -> TileMapLayer:
	var direct_tile_map: TileMapLayer = get_node_or_null("TileMapLayer") as TileMapLayer
	if direct_tile_map != null:
		return direct_tile_map
	return get_node("Grid/TileMapLayer") as TileMapLayer


## Spawns a protective Dementor on each row left of the garden.
func _spawn_dementors() -> void:
	if not dementor_cells.is_empty():
		_spawn_dementors_from_cells()
	elif not dementor_row_cells.is_empty():
		_spawn_dementors_from_row_cells()
	else:
		_spawn_default_dementors()


func _spawn_dementors_from_cells() -> void:
	for cell: Vector2i in dementor_cells:
		var dementor: Dementor = dementor_scene.instantiate() as Dementor
		dementor.global_position = tile_map.to_global(tile_map.map_to_local(cell))
		entity_layer.add_child(dementor)


func _spawn_dementors_from_row_cells() -> void:
	var first_col: Vector2 = tile_map.to_global(tile_map.map_to_local(Vector2i(2, dementor_row_cells[0])))
	var cell_width: float = tile_map.tile_set.tile_size.x * tile_map.global_scale.x
	var dementor_x: float = first_col.x - cell_width
	for row: int in dementor_row_cells:
		var dementor: Dementor = dementor_scene.instantiate() as Dementor
		var row_center: Vector2 = tile_map.to_global(tile_map.map_to_local(Vector2i(2, row)))
		dementor.global_position = Vector2(dementor_x, row_center.y)
		entity_layer.add_child(dementor)


func _spawn_default_dementors() -> void:
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
		_stop_accio_glow()


func _stop_accio_glow() -> void:
	var cursor: AccioCursor = _accio_cursor as AccioCursor
	if cursor != null:
		cursor.stop_glow()


func _cancel_accio() -> void:
	_stop_accio_glow()
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
	_finish_accio_removal()
	if is_instance_valid(ally):
		ally.queue_free()


func _finish_accio_removal() -> void:
	_is_removing = false
	if _accio_button != null:
		_accio_button.set_active(false)
	var cursor: AccioCursor = _accio_cursor as AccioCursor
	if cursor != null:
		cursor.play_tip_glow(_on_accio_glow_completed)
	else:
		_set_cursor_mode(false)


func _on_accio_glow_completed() -> void:
	_set_cursor_mode(false)


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
	if is_boss_level and _boss != null and cell == _boss.get_current_cell():
		return false
	return tile_map.get_cell_source_id(cell) != EMPTY_CELL_SOURCE


func _place_ally(card: AllyCard, cell: Vector2i) -> void:
	var ally: Ally = card.scene.instantiate() as Ally
	ally.global_position = tile_map.to_global(tile_map.map_to_local(cell))
	_init_placed_ally(ally)
	entity_layer.add_child(ally)
	ally.update_row_z_index()
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
	snitch.update_row_z_index()
	snitch.collected.connect(_on_snitch_collected)


## SnitchSpawnTimer callback. Spawns a Snitch falling from the sky.
func _on_snitch_spawn_timer_timeout() -> void:
	if _is_level_over:
		return
	var snitch: Snitch = snitch_scene.instantiate() as Snitch
	var target_row: int = _pick_random_snitch_row()
	var target_y: float = _get_row_center_y(target_row)
	snitch.setup_sky_fall(target_y)
	snitch.position = Vector2(randf_range(SKY_SNITCH_MIN_X, SKY_SNITCH_MAX_X), SKY_SNITCH_Y)
	entity_layer.add_child(snitch)
	snitch.collected.connect(_on_snitch_collected)


func _pick_random_snitch_row() -> int:
	if active_rows.is_empty():
		return DEFAULT_SNITCH_ROW
	return active_rows.pick_random()


func _get_row_center_y(row: int) -> float:
	if tile_map != null:
		return tile_map.to_global(tile_map.map_to_local(Vector2i(GRID_SAMPLE_COLUMN, row))).y
	var index: int = clampi(row - FIRST_GRID_ROW_INDEX, 0, DEMENTOR_ROWS_Y.size() - 1)
	return DEMENTOR_ROWS_Y[index]


## Callback when the player clicks and collects a Snitch.
func _on_snitch_collected(amount: int) -> void:
	_snitches += amount
	_refresh_hud()


func _is_troll_scene(scene: PackedScene) -> bool:
	if scene == null:
		return false
	return scene.resource_path.get_file() == "troll.tscn"


func _are_trolls_allowed() -> bool:
	var required_waves: int = troll_delay_waves
	if required_waves <= 0 and (_get_current_level_num() == 9 or name == "Level9"):
		required_waves = 1
	return _completed_waves >= required_waves


func _pick_random_enemy_scene() -> PackedScene:
	if enemy_scenes.is_empty():
		return null
	if _are_trolls_allowed():
		return enemy_scenes.pick_random()
	var allowed_scenes: Array[PackedScene] = []
	for scene: PackedScene in enemy_scenes:
		if not _is_troll_scene(scene):
			allowed_scenes.append(scene)
	if allowed_scenes.is_empty():
		return enemy_scenes.pick_random()
	return allowed_scenes.pick_random()


## EnemySpawnTimer callback. Spawns regular enemies with accelerating difficulty.
func _on_enemy_spawn_timer_timeout() -> void:
	if _is_level_over or _wave_state != STATE_SPAWNING_NORMAL:
		return
	_accelerate_spawn_cadence()
	_spawn_regular_enemies()


func _determine_enemy_spawn_count() -> int:
	var roll: float = randf()
	if roll < MULTI_SPAWN_TRIPLE_CHANCE:
		return TRIPLE_SPAWN_COUNT
	if roll < MULTI_SPAWN_TRIPLE_CHANCE + MULTI_SPAWN_DOUBLE_CHANCE:
		return DOUBLE_SPAWN_COUNT
	return SINGLE_SPAWN_COUNT


func _spawn_regular_enemies() -> void:
	var count: int = _determine_enemy_spawn_count()
	var points: Array[NodePath] = spawn_points.duplicate()
	points.shuffle()
	for i: int in range(count):
		if _is_level_over:
			return
		await _wait_for_multi_spawn_delay(i)
		if _is_level_over or not is_inside_tree():
			return
		var path: NodePath = points[i % points.size()] if not points.is_empty() else NodePath()
		_spawn_enemy(_pick_random_enemy_scene(), true, path)


func _wait_for_multi_spawn_delay(index: int) -> void:
	var delay: float = 0.0
	if index == 1:
		delay = SECOND_ENEMY_SPAWN_DELAY
	elif index == 2:
		delay = THIRD_ENEMY_SPAWN_DELAY
	if delay > 0.0 and is_inside_tree():
		await get_tree().create_timer(delay).timeout


func _accelerate_spawn_cadence() -> void:
	_enemy_spawn_interval = maxf(
		MIN_ENEMY_SPAWN_INTERVAL,
		_enemy_spawn_interval - SPAWN_INTERVAL_DECREMENT
	)
	enemy_spawn_timer.wait_time = _enemy_spawn_interval
	enemy_spawn_timer.start()


func _spawn_enemy(scene: PackedScene, counts_as_regular: bool, spawn_path: NodePath = NodePath()) -> void:
	if scene == null:
		return
	var enemy: Enemy = scene.instantiate() as Enemy
	enemy.global_position = _pick_spawn_position(spawn_path)
	entity_layer.add_child(enemy)
	enemy.update_row_z_index()
	if counts_as_regular:
		_spawned_enemies += 1
	_active_enemies += 1
	_regular_enemy_ids[enemy.get_instance_id()] = counts_as_regular
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.garden_invaded.connect(_on_garden_invaded)


func _pick_spawn_position(custom_path: NodePath = NodePath()) -> Vector2:
	var path: NodePath = custom_path
	if path.is_empty():
		path = spawn_points.pick_random()
	var spawn_point: Node2D = get_node(path) as Node2D
	return spawn_point.global_position


## Callback when an enemy is defeated. Tracks kills and updates wave progress.
func _on_enemy_defeated(entity: Node2D) -> void:
	var enemy_id: int = entity.get_instance_id()
	if _defeated_enemy_ids.has(enemy_id):
		return
	_defeated_enemy_ids[enemy_id] = true
	var is_regular: bool = _regular_enemy_ids.get(enemy_id, false)
	_active_enemies = maxi(_active_enemies - 1, 0)
	if is_regular:
		_process_regular_enemy_kill()
	_update_wave_lifecycle()


func _process_regular_enemy_kill() -> void:
	if _wave_state != STATE_SPAWNING_NORMAL:
		return
	_phase_defeated_enemies += 1
	_total_defeated_enemies += 1
	_defeated_enemies = _total_defeated_enemies
	_update_hud_meter()
	_check_wave_threshold()


func _update_hud_meter() -> void:
	if is_instance_valid(_wave_progress_bar):
		_wave_progress_bar.update_progress(_get_current_meter_progress())


func _get_current_meter_progress() -> int:
	var base_kills: int = 0
	for i: int in range(_current_phase_index):
		base_kills += _get_phase_threshold(i)
	var current_quota: int = _get_phase_threshold(_current_phase_index)
	return base_kills + mini(_phase_defeated_enemies, current_quota)


func _get_phase_threshold(phase_index: int) -> int:
	if wave_kill_thresholds.is_empty() or phase_index < 0 or phase_index >= wave_kill_thresholds.size():
		return 0
	var wave_count: int = wave_kill_thresholds.size()
	if wave_count == 2:
		var half: int = _total_level_kills / 2
		return half if phase_index == 0 else (_total_level_kills - half)
	elif wave_count == 3:
		var third: int = roundi(float(_total_level_kills) / 3.0)
		if phase_index == 0 or phase_index == 1:
			return third
		return _total_level_kills - (third * 2)
	return wave_kill_thresholds[phase_index]


## Callback when an enemy invades the garden. Triggers the defeat.
func _on_garden_invaded() -> void:
	_lose()


func _check_wave_threshold() -> void:
	if is_boss_level or _wave_state != STATE_SPAWNING_NORMAL:
		return
	if _current_phase_index >= wave_kill_thresholds.size():
		return
	var required_kills: int = _get_phase_threshold(_current_phase_index)
	if _phase_defeated_enemies >= required_kills:
		_reach_wave_threshold()


func _reach_wave_threshold() -> void:
	if is_instance_valid(enemy_spawn_timer):
		enemy_spawn_timer.stop()
	var is_final: bool = (_current_phase_index + 1) >= wave_kill_thresholds.size()
	_wave_state = STATE_FINAL_WAVE_PREPARATION if is_final else STATE_WAVE_PREPARATION
	_request_wave(is_final)
	_check_wave_readiness()


func _check_wave_readiness() -> void:
	if _wave_state != STATE_WAVE_PREPARATION and _wave_state != STATE_FINAL_WAVE_PREPARATION:
		return
	if _active_enemies > 0:
		return
	if _pending_wave_plan == null:
		return
	_start_prepared_wave()


func _update_wave_lifecycle() -> void:
	if is_boss_level:
		return
	if _wave_state == STATE_WAVE_PREPARATION or _wave_state == STATE_FINAL_WAVE_PREPARATION:
		_check_wave_readiness()
	elif _wave_state == STATE_WAITING_FOR_CLEAR and _active_enemies == 0:
		_resume_after_wave()


func _request_wave(is_final: bool) -> void:
	if is_instance_valid(wave_director):
		var snapshot: RefCounted = _build_snapshot()
		_pending_request_id = wave_director.request_plan(snapshot, is_final)
	else:
		_create_fallback_wave(is_final)


func _create_fallback_wave(is_final: bool) -> void:
	var plan: RefCounted = WAVE_PLAN_SCRIPT.new()
	plan.set("level_generation", _level_generation)
	plan.set("request_id", 1)
	plan.set("wave_number", _current_phase_index + 1)
	plan.set("is_final", is_final)
	plan.set("enemy_count", final_wave_min if is_final else intermediate_wave_min)
	plan.set("spawn_delay", 0.25)
	plan.set("row_indices", active_rows.duplicate())
	_pending_wave_plan = plan
	_check_wave_readiness()


func _build_snapshot() -> RefCounted:
	var snapshot: RefCounted = BOARD_SNAPSHOT_SCRIPT.new()
	_fill_snapshot_base(snapshot)
	_fill_snapshot_wave_params(snapshot)
	return snapshot


func _fill_snapshot_base(snapshot: RefCounted) -> void:
	var budget: int = maxi(total_enemies, _total_level_kills)
	snapshot.set("level_generation", _level_generation)
	snapshot.set("state", _wave_state)
	snapshot.set("regular_defeated", mini(_total_defeated_enemies, budget))
	snapshot.set("regular_budget", budget)
	snapshot.set("active_enemies", _active_enemies)
	snapshot.set("defense_value", _defense_value())
	snapshot.set("is_special_level", is_special_level)
	snapshot.set("threshold_index", _current_phase_index)


func _fill_snapshot_wave_params(snapshot: RefCounted) -> void:
	snapshot.set("intermediate_wave_size", _intermediate_wave_size)
	snapshot.set("intermediate_wave_min", intermediate_wave_min)
	snapshot.set("intermediate_wave_max", intermediate_wave_max)
	snapshot.set("final_wave_min", final_wave_min)
	snapshot.set("final_wave_bonus_min", final_wave_bonus_min)
	snapshot.set("final_wave_bonus_max", final_wave_bonus_max)
	snapshot.set("row_indices", active_rows)


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
	_pending_wave_plan = plan
	_check_wave_readiness()


func _start_prepared_wave() -> void:
	var plan: RefCounted = _pending_wave_plan
	_pending_wave_plan = null
	_wave_state = STATE_WAVE_ACTIVE
	_final_wave_active = bool(plan.get("is_final"))
	if not _final_wave_active:
		_intermediate_wave_size = plan.get("enemy_count")
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
		_spawn_enemy(_pick_random_enemy_scene(), false)
	_wave_state = STATE_WAITING_FOR_CLEAR
	_update_wave_lifecycle()


func _resume_after_wave() -> void:
	if _wave_state != STATE_WAITING_FOR_CLEAR:
		return
	_completed_waves += 1
	if _final_wave_active:
		_wave_state = STATE_LEVEL_COMPLETE
		_win()
		return
	_advance_to_next_regular_phase()


func _advance_to_next_regular_phase() -> void:
	_current_phase_index += 1
	_phase_defeated_enemies = 0
	_wave_state = STATE_SPAWNING_NORMAL
	enemy_spawn_timer.start(_enemy_spawn_interval)


## Wins the level, unlocks the next one and shows reward or end panel.
func _win() -> void:
	_stop_level()
	_unlock_next_level()
	if _should_show_reward_unlock():
		_show_reward_unlock()
	else:
		_show_victory_panel()


func _unlock_next_level() -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("unlock_level"):
		game_manager.call("unlock_level", next_level_to_unlock)


func _get_current_level_num() -> int:
	if current_level_number > 0:
		return current_level_number
	return FINAL_LEVEL_NUMBER if is_boss_level else next_level_to_unlock - 1


func _should_show_reward_unlock() -> bool:
	var level_num: int = _get_current_level_num()
	var reward_data: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(level_num)
	if reward_data == null:
		return false
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("is_reward_claimed"):
		return not bool(game_manager.call("is_reward_claimed", level_num))
	return true


func _show_reward_unlock() -> void:
	var level_num: int = _get_current_level_num()
	var reward_data: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(level_num)
	var screen_scene: PackedScene = preload("res://reward_unlock_screen.tscn")
	var screen: RewardUnlockScreen = screen_scene.instantiate() as RewardUnlockScreen
	screen.reward_dismissed.connect(_on_reward_dismissed)
	hud.add_child(screen)
	screen.setup(level_num, reward_data.texture, reward_data.description_text)


func _on_reward_dismissed(level_num: int) -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("claim_reward"):
		game_manager.call("claim_reward", level_num)
	_show_victory_panel()


func _show_victory_panel() -> void:
	var win_message: String = BOSS_WIN_MESSAGE_TEXT if is_boss_level else WIN_MESSAGE_TEXT % next_level_to_unlock
	var has_next: bool = not is_boss_level and _get_current_level_num() < FINAL_LEVEL_NUMBER
	_show_end_panel(WIN_TITLE_TEXT, win_message, has_next)


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
	_pending_wave_plan = null
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
	var next_num: int = _get_current_level_num() + 1
	var next_path: String = NEXT_LEVEL_SCENE_TEMPLATE % next_num
	if next_num <= FINAL_LEVEL_NUMBER and ResourceLoader.exists(next_path):
		get_tree().change_scene_to_file(next_path)
	else:
		_go_to_map()


func _on_back_to_map_button_pressed() -> void:
	_go_to_map()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _go_to_map() -> void:
	get_tree().change_scene_to_file(level_select_scene)
