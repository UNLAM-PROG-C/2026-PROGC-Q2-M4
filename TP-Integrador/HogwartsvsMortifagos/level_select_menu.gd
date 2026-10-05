class_name LevelSelectMenu
extends Control

## Level Select Menu based on the Marauder's Map.
## Shows the level buttons, footprints walking the unlocked part of the path
## (System A) and ambient footprints of castle passers-by (System B).

signal level_selected(level_number: int)

const LEVEL_BUTTON_TEXT: String = "Nivel %d"
const LOCKED_SUFFIX_TEXT: String = "\n[Cerrado]"
const LEVEL_BUTTON_NAME_FORMAT: String = "Level%d"
## Number of level buttons on the map (the path ends at the last one).
const LEVEL_COUNT: int = 10
const LEVEL_BUTTON_MIN_SIZE: Vector2 = Vector2(160.0, 65.0)
## Locked signs stay opaque so they fully cover footprints passing under them.
const LOCKED_BUTTON_MODULATE: Color = Color(0.82, 0.78, 0.72, 1.0)
## Draw order: ambient footprints below path footprints, level signs on top.
const AMBIENT_LAYER_Z: int = 1
const PATH_LAYER_Z: int = 2
const BUTTONS_Z: int = 10
## Footprints point forward, a quarter turn from the walking direction.
const FOOTPRINT_ROTATION_OFFSET: float = PI / 2.0

## System A: distance along the path of the first footprint, and its look.
const PATH_START_DISTANCE: float = 10.0
const PATH_FOOTPRINT_OPACITY: float = 0.85
const PATH_FOOTPRINT_SCALE: Vector2 = Vector2(0.9, 0.9)

## System B: walkers spawned right away, and the delay between them.
const INITIAL_WALKERS: int = 4
const INITIAL_WALKER_INTERVAL: float = 0.35
## Area where walkers start (away from the screen edges).
const WALKER_AREA_MIN: Vector2 = Vector2(120.0, 120.0)
const WALKER_AREA_MAX: Vector2 = Vector2(1800.0, 960.0)
## Step length and seconds per step ranges, and sideways offset of each foot.
const WALKER_MIN_STEP_LENGTH: float = 24.0
const WALKER_MAX_STEP_LENGTH: float = 32.0
const WALKER_MIN_CADENCE: float = 0.28
const WALKER_MAX_CADENCE: float = 0.36
const WALKER_FOOT_OFFSET: float = 5.0
## Chance of a walker starting with the right foot.
const RIGHT_FOOT_CHANCE: float = 0.5
## Extra seconds after the last step before the walker slot is freed.
const WALKER_RELEASE_DELAY: float = 0.5
## Ambient footprint look, seconds it stays visible and its fade duration.
const AMBIENT_MIN_OPACITY: float = 0.60
const AMBIENT_MAX_OPACITY: float = 0.75
const AMBIENT_FOOTPRINT_SCALE: Vector2 = Vector2(0.85, 0.85)
const AMBIENT_MIN_VISIBLE_TIME: float = 2.8
const AMBIENT_MAX_VISIBLE_TIME: float = 4.0
const AMBIENT_FADE_DURATION: float = 1.5

@export_group("Levels")
## Scene loaded by each level button, in order. Buttons past the end load nothing.
@export var level_scenes: Array[PackedScene] = []
## Parchment look of the level buttons.
@export var level_button_theme: Theme

@export_group("System A - Path Footprints")
## Distance in pixels between steps along the Path2D.
@export var step_distance: float = 30.0
## Sideways spacing between the left and right foot.
@export var foot_spacing: float = 7.0
## Seconds between each footprint appearing.
@export var path_step_interval: float = 0.12

@export_group("System B - Ambient Footprints")
## Whether the ghost walkers system is active in the background.
@export var ambient_footprints_enabled: bool = true
## Minimum and maximum time before a new ambient walker appears.
@export var walker_spawn_min_time: float = 0.5
@export var walker_spawn_max_time: float = 1.4
## Maximum number of walkers crossing the map at the same time.
@export var max_active_walkers: int = 4
## Number of steps each ambient walker takes.
@export var walker_min_steps: int = 4
@export var walker_max_steps: int = 8

var _level_buttons: Array[Button] = []
# Footprint pool for in-memory reuse (zero garbage collection)
var _footprint_pool: Array[Footprint] = []
var _active_walkers: int = 0

@onready var level_path: Path2D = $LevelPath
@onready var level_buttons_container: Node2D = $LevelButtons
@onready var path_footprints_layer: Node2D = $PathFootprintsLayer
@onready var ambient_footprints_layer: Node2D = $AmbientFootprintsLayer
@onready var ambient_footprints_timer: Timer = $AmbientFootprintsTimer
@onready var debug_mode_check_button: CheckButton = $DebugModeCheckButton


func _ready() -> void:
	_set_absolute_z(ambient_footprints_layer, AMBIENT_LAYER_Z)
	_set_absolute_z(path_footprints_layer, PATH_LAYER_Z)
	_set_absolute_z(level_buttons_container, BUTTONS_Z)
	_setup_level_buttons()
	_refresh_level_buttons()
	debug_mode_check_button.button_pressed = _is_debug_mode_enabled()
	debug_mode_check_button.toggled.connect(_on_debug_mode_toggled)
	_start_path_footprints()
	if ambient_footprints_enabled:
		_setup_ambient_timer()


func _on_debug_mode_toggled(enabled: bool) -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.set("debug_mode", enabled)


func _is_debug_mode_enabled() -> bool:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	return game_manager != null and bool(game_manager.get("debug_mode"))


func _set_absolute_z(item: CanvasItem, z: int) -> void:
	item.z_index = z
	item.z_as_relative = false


## Highest unlocked level, kept within the buttons on the map.
func _unlocked_level() -> int:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager == null:
		return 1
	return clampi(int(game_manager.get("max_unlocked_level")), 1, LEVEL_COUNT)


## Finds the level buttons of the container and gives them the parchment look.
func _setup_level_buttons() -> void:
	_level_buttons.clear()
	for i: int in range(1, LEVEL_COUNT + 1):
		var button: Button = level_buttons_container.get_node_or_null(LEVEL_BUTTON_NAME_FORMAT % i) as Button
		if button != null:
			_level_buttons.append(button)
			button.pressed.connect(_on_level_button_pressed.bind(i))
			button.custom_minimum_size = LEVEL_BUTTON_MIN_SIZE
			button.theme = level_button_theme


## Updates the visual state (enabled/disabled) of each level button.
func _refresh_level_buttons() -> void:
	for index: int in range(_level_buttons.size()):
		var level_number: int = index + 1
		var button: Button = _level_buttons[index]
		var is_unlocked: bool = level_number <= _unlocked_level()
		button.disabled = not is_unlocked
		if is_unlocked:
			button.text = LEVEL_BUTTON_TEXT % level_number
			button.modulate = Color.WHITE
		else:
			button.text = LEVEL_BUTTON_TEXT % level_number + LOCKED_SUFFIX_TEXT
			button.modulate = LOCKED_BUTTON_MODULATE


## Handles a click on a level button. Levels without a scene load nothing.
func _on_level_button_pressed(level_number: int) -> void:
	if level_number > _unlocked_level():
		return
	level_selected.emit(level_number)
	if level_number <= level_scenes.size():
		get_tree().change_scene_to_packed(level_scenes[level_number - 1])


func _take_footprint_from_pool() -> Footprint:
	if _footprint_pool.is_empty():
		return Footprint.new()
	var footprint: Footprint = _footprint_pool.pop_back()
	footprint.visible = true
	footprint.modulate.a = 1.0
	return footprint


func _return_footprint_to_pool(footprint: Footprint) -> void:
	if footprint.get_parent() != null:
		footprint.get_parent().remove_child(footprint)
	footprint.visible = false
	_footprint_pool.append(footprint)


func _place_footprint(footprint: Footprint, spawn_position: Vector2, spawn_rotation: float, footprint_scale: Vector2, z: int) -> void:
	footprint.global_position = spawn_position
	footprint.rotation = spawn_rotation
	footprint.scale = footprint_scale
	_set_absolute_z(footprint, z)


# ==============================================================================
# SYSTEM A: SEQUENTIAL FOOTPRINTS ALONG THE PATH (Path2D)
# ==============================================================================

## Starts the footprint animation walking only the unlocked part of the path.
func _start_path_footprints() -> void:
	if level_path == null or level_path.curve == null:
		return
	_clear_path_footprints()
	var target_length: float = _unlocked_path_length()
	if target_length > 0.0:
		_schedule_path_steps(target_length)


func _clear_path_footprints() -> void:
	for child: Node in path_footprints_layer.get_children():
		child.queue_free()


## Path length up to the highest unlocked level: none for the first level,
## the whole path for the last one.
func _unlocked_path_length() -> float:
	var walked_fraction: float = clampf(float(_unlocked_level() - 1) / float(LEVEL_COUNT - 1), 0.0, 1.0)
	return level_path.curve.get_baked_length() * walked_fraction


func _schedule_path_steps(target_length: float) -> void:
	var distance: float = PATH_START_DISTANCE
	var right_foot: bool = true
	var delay: float = 0.0
	while distance <= target_length:
		var step: Transform2D = _footprint_transform_at(distance, right_foot)
		var step_timer: SceneTreeTimer = get_tree().create_timer(delay)
		step_timer.timeout.connect(_spawn_path_footprint.bind(step.origin, step.get_rotation(), right_foot))
		delay += path_step_interval
		distance += step_distance
		right_foot = not right_foot


## Global position and rotation of the footprint at a distance along the path.
func _footprint_transform_at(distance: float, is_right_foot: bool) -> Transform2D:
	var curve_transform: Transform2D = level_path.curve.sample_baked_with_rotation(distance)
	var base_position: Vector2 = level_path.to_global(curve_transform.origin)
	var direction: Vector2 = curve_transform.x.normalized()
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
	var foot_sign: float = 1.0 if is_right_foot else -1.0
	var footprint_position: Vector2 = base_position + perpendicular * (foot_spacing * foot_sign)
	return Transform2D(direction.angle() + FOOTPRINT_ROTATION_OFFSET, footprint_position)


func _spawn_path_footprint(spawn_position: Vector2, spawn_rotation: float, right_foot: bool) -> void:
	var footprint: Footprint = _take_footprint_from_pool()
	footprint.setup(right_foot, PATH_FOOTPRINT_OPACITY)
	_place_footprint(footprint, spawn_position, spawn_rotation, PATH_FOOTPRINT_SCALE, PATH_LAYER_Z)
	path_footprints_layer.add_child(footprint)


# ==============================================================================
# SYSTEM B: RANDOM AMBIENT FOOTPRINTS (Castle passers-by)
# ==============================================================================

func _setup_ambient_timer() -> void:
	ambient_footprints_timer.one_shot = true
	ambient_footprints_timer.timeout.connect(_on_ambient_footprints_timer_timeout)
	_restart_ambient_timer()
	# Spawn the first walkers right away so the map starts full of life
	for i: int in range(INITIAL_WALKERS):
		get_tree().create_timer(float(i) * INITIAL_WALKER_INTERVAL).timeout.connect(_try_spawn_ambient_walker)


func _restart_ambient_timer() -> void:
	ambient_footprints_timer.start(randf_range(walker_spawn_min_time, walker_spawn_max_time))


func _on_ambient_footprints_timer_timeout() -> void:
	_try_spawn_ambient_walker()
	_restart_ambient_timer()


func _try_spawn_ambient_walker() -> void:
	if _active_walkers < max_active_walkers:
		_spawn_ambient_walker()


## Spawns a passer-by that takes between walker_min_steps and walker_max_steps and disappears.
func _spawn_ambient_walker() -> void:
	_active_walkers += 1
	var origin: Vector2 = _random_walker_origin()
	var walk_angle: float = randf_range(0.0, TAU)
	var total_steps: int = randi_range(walker_min_steps, walker_max_steps)
	var step_length: float = randf_range(WALKER_MIN_STEP_LENGTH, WALKER_MAX_STEP_LENGTH)
	var right_foot: bool = randf() > RIGHT_FOOT_CHANCE
	var cadence: float = randf_range(WALKER_MIN_CADENCE, WALKER_MAX_CADENCE)
	for step_index: int in range(total_steps):
		var step_origin: Vector2 = origin + Vector2.from_angle(walk_angle) * (float(step_index) * step_length)
		_schedule_walker_step(step_origin, walk_angle, right_foot, float(step_index) * cadence)
		right_foot = not right_foot
	# Once every step is taken, free the slot so another walker can appear
	_schedule_walker_release(float(total_steps) * cadence + WALKER_RELEASE_DELAY)


func _random_walker_origin() -> Vector2:
	var x: float = randf_range(WALKER_AREA_MIN.x, WALKER_AREA_MAX.x)
	var y: float = randf_range(WALKER_AREA_MIN.y, WALKER_AREA_MAX.y)
	return Vector2(x, y)


func _schedule_walker_step(step_origin: Vector2, walk_angle: float, right_foot: bool, delay: float) -> void:
	var direction: Vector2 = Vector2.from_angle(walk_angle)
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)
	var foot_sign: float = 1.0 if right_foot else -1.0
	var footprint_position: Vector2 = step_origin + (perpendicular * WALKER_FOOT_OFFSET * foot_sign)
	var step_timer: SceneTreeTimer = get_tree().create_timer(delay)
	step_timer.timeout.connect(_spawn_ambient_footprint.bind(footprint_position, walk_angle + FOOTPRINT_ROTATION_OFFSET, right_foot))


func _schedule_walker_release(delay: float) -> void:
	get_tree().create_timer(delay).timeout.connect(_release_walker)


func _release_walker() -> void:
	_active_walkers = maxi(_active_walkers - 1, 0)


func _spawn_ambient_footprint(spawn_position: Vector2, spawn_rotation: float, right_foot: bool) -> void:
	var footprint: Footprint = _take_footprint_from_pool()
	footprint.setup(right_foot, randf_range(AMBIENT_MIN_OPACITY, AMBIENT_MAX_OPACITY))
	_place_footprint(footprint, spawn_position, spawn_rotation, AMBIENT_FOOTPRINT_SCALE, AMBIENT_LAYER_Z)
	ambient_footprints_layer.add_child(footprint)
	_schedule_footprint_fade(footprint)


## Keeps the footprint visible for a while so more of them pile up, then fades it back into the pool.
func _schedule_footprint_fade(footprint: Footprint) -> void:
	var visible_time: float = randf_range(AMBIENT_MIN_VISIBLE_TIME, AMBIENT_MAX_VISIBLE_TIME)
	var fade: Callable = footprint.fade_out.bind(AMBIENT_FADE_DURATION, _return_footprint_to_pool.bind(footprint))
	get_tree().create_timer(visible_time).timeout.connect(fade)
