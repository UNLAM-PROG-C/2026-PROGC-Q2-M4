class_name LevelSelectMenu
extends Control

## Level Select Menu based on the Marauder's Map.
## Handles the 10-level progression, the Path2D route and the footprint systems.

signal level_selected(level_number: int)

const LEVEL_BUTTON_TEXT: String = "Nivel %d"
const LOCKED_SUFFIX_TEXT: String = "\n[Cerrado]"
const LEVEL_BUTTON_NAME_FORMAT: String = "Level%d"
## Number of level buttons on the map (the path ends at the last one).
const LEVEL_COUNT: int = 10

@export_group("Levels")
## Scene loaded by each level button, in order. Buttons past the end load nothing.
@export var level_scenes: Array[PackedScene] = []

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

# Scene nodes
@onready var level_path: Path2D = $LevelPath
@onready var level_buttons_container: Node2D = $LevelButtons
@onready var path_footprints_layer: Node2D = $PathFootprintsLayer
@onready var ambient_footprints_layer: Node2D = $AmbientFootprintsLayer
@onready var ambient_footprints_timer: Timer = $AmbientFootprintsTimer

# The 10 level buttons
var _level_buttons: Array[Button] = []

# Footprint pool for in-memory reuse (zero garbage collection)
var _footprint_pool: Array[Footprint] = []
var _active_walkers: int = 0


func _ready() -> void:
	# Keep footprints on the background layer and the signs above them
	ambient_footprints_layer.z_index = 1
	ambient_footprints_layer.z_as_relative = false
	path_footprints_layer.z_index = 2
	path_footprints_layer.z_as_relative = false
	level_buttons_container.z_index = 10
	level_buttons_container.z_as_relative = false

	_setup_level_buttons()
	_refresh_level_buttons()
	_start_path_footprints()

	if ambient_footprints_enabled:
		_setup_ambient_timer()


## Highest unlocked level, kept within the buttons on the map.
func _unlocked_level() -> int:
	return clampi(GameManager.max_unlocked_level, 1, LEVEL_COUNT)


## Finds and stores the level buttons of the container.
func _setup_level_buttons() -> void:
	_level_buttons.clear()
	for i: int in range(1, LEVEL_COUNT + 1):
		var button: Button = level_buttons_container.get_node_or_null(LEVEL_BUTTON_NAME_FORMAT % i) as Button
		if button != null:
			_level_buttons.append(button)
			button.pressed.connect(_on_level_button_pressed.bind(i))
			_aplicar_estilo_pergamino_boton(button)


## Applies the look inspired by the "Map Rooms" (CSS).
func _aplicar_estilo_pergamino_boton(button: Button) -> void:
	button.custom_minimum_size = Vector2(160.0, 65.0)

	# Normal style (unlocked)
	var style_normal: StyleBoxFlat = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.894, 0.804, 0.624, 1.0) # #e4cd9f solid
	style_normal.border_color = Color(0.235, 0.141, 0.082)    # #3c2415
	style_normal.set_border_width_all(3)
	style_normal.shadow_color = Color(0.235, 0.141, 0.082, 0.25)
	style_normal.shadow_size = 4
	style_normal.shadow_offset = Vector2(2, 2)
	button.add_theme_stylebox_override("normal", style_normal)

	# Hover style
	var style_hover: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
	style_hover.bg_color = Color(0.922, 0.863, 0.698, 1.0) # #ebdcb2 solid
	style_hover.shadow_size = 6
	button.add_theme_stylebox_override("hover", style_hover)

	# Pressed style
	var style_pressed: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
	style_pressed.bg_color = Color(0.816, 0.722, 0.541, 1.0)
	style_pressed.shadow_offset = Vector2(0, 0)
	button.add_theme_stylebox_override("pressed", style_pressed)

	# Locked style
	var style_disabled: StyleBoxFlat = StyleBoxFlat.new()
	style_disabled.bg_color = Color(0.72, 0.61, 0.46, 1.0) # Aged parchment, 100% solid
	style_disabled.border_color = Color(0.35, 0.25, 0.18, 0.8)
	style_disabled.set_border_width_all(2)
	button.add_theme_stylebox_override("disabled", style_disabled)

	# Text colors
	button.add_theme_color_override("font_color", Color(0.235, 0.141, 0.082))
	button.add_theme_color_override("font_hover_color", Color(0.12, 0.06, 0.03))
	button.add_theme_color_override("font_disabled_color", Color(0.35, 0.25, 0.18, 0.85))


## Updates the visual state (enabled/disabled) of each level button.
func _refresh_level_buttons() -> void:
	for index: int in range(_level_buttons.size()):
		var level_number: int = index + 1
		var button: Button = _level_buttons[index]
		var is_unlocked: bool = level_number <= _unlocked_level()

		button.disabled = not is_unlocked
		if is_unlocked:
			button.text = LEVEL_BUTTON_TEXT % level_number
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			button.text = LEVEL_BUTTON_TEXT % level_number + LOCKED_SUFFIX_TEXT
			# Alpha stays at 1.0 so the sign fully covers footprints passing under it
			button.modulate = Color(0.82, 0.78, 0.72, 1.0)


## Handles a click on a level button. Levels without a scene load nothing.
func _on_level_button_pressed(level_number: int) -> void:
	if level_number > _unlocked_level():
		return
	level_selected.emit(level_number)
	if level_number <= level_scenes.size():
		get_tree().change_scene_to_packed(level_scenes[level_number - 1])


# ==============================================================================
# SYSTEM A: SEQUENTIAL FOOTPRINTS ALONG THE PATH (Path2D)
# ==============================================================================

## Starts the footprint animation walking only the unlocked segments.
func _start_path_footprints() -> void:
	if level_path == null or level_path.curve == null:
		return

	# Clear previous path footprints
	for child: Node in path_footprints_layer.get_children():
		child.queue_free()

	# Fraction of the path to walk according to the highest unlocked level:
	# none for the first level, the whole path for the last one
	var walked_fraction: float = clampf(float(_unlocked_level() - 1) / float(LEVEL_COUNT - 1), 0.0, 1.0)
	if walked_fraction <= 0.0:
		return

	var total_length: float = level_path.curve.get_baked_length()
	var target_length: float = total_length * walked_fraction

	# Build the animated step sequence
	_schedule_path_steps(target_length)


func _schedule_path_steps(target_length: float) -> void:
	var current_distance: float = 10.0
	var right_foot: bool = true
	var accumulated_delay: float = 0.0

	while current_distance <= target_length:
		var curve_transform: Transform2D = level_path.curve.sample_baked_with_rotation(current_distance)
		var base_position: Vector2 = level_path.to_global(curve_transform.origin)
		var direction: Vector2 = curve_transform.x.normalized()
		var perpendicular: Vector2 = Vector2(-direction.y, direction.x)

		# Sideways foot offset
		var foot_sign: float = 1.0 if right_foot else -1.0
		var footprint_position: Vector2 = base_position + perpendicular * (foot_spacing * foot_sign)
		var footprint_angle: float = direction.angle() + (PI / 2.0)

		# Schedule the footprint
		var step_timer: SceneTreeTimer = get_tree().create_timer(accumulated_delay)
		step_timer.timeout.connect(_spawn_path_footprint.bind(footprint_position, footprint_angle, right_foot, path_footprints_layer))

		accumulated_delay += path_step_interval
		current_distance += step_distance
		right_foot = not right_foot


func _spawn_path_footprint(spawn_position: Vector2, spawn_rotation: float, right_foot: bool, container: Node2D) -> void:
	var footprint: Footprint = _take_footprint_from_pool()
	footprint.setup(right_foot, 0.85)
	footprint.global_position = spawn_position
	footprint.rotation = spawn_rotation
	footprint.scale = Vector2(0.9, 0.9)
	footprint.z_index = 2
	footprint.z_as_relative = false
	container.add_child(footprint)


# ==============================================================================
# SYSTEM B: RANDOM AMBIENT FOOTPRINTS (Castle passers-by)
# ==============================================================================

func _setup_ambient_timer() -> void:
	ambient_footprints_timer.one_shot = true
	ambient_footprints_timer.timeout.connect(_on_ambient_footprints_timer_timeout)
	_restart_ambient_timer()

	# Spawn the first walkers right away so the map starts full of life
	for i: int in range(4):
		var start_delay: float = float(i) * 0.35
		get_tree().create_timer(start_delay).timeout.connect(func() -> void:
			if _active_walkers < max_active_walkers:
				_spawn_ambient_walker()
		)


func _restart_ambient_timer() -> void:
	var wait_time: float = randf_range(walker_spawn_min_time, walker_spawn_max_time)
	ambient_footprints_timer.start(wait_time)


func _on_ambient_footprints_timer_timeout() -> void:
	if _active_walkers < max_active_walkers:
		_spawn_ambient_walker()
	_restart_ambient_timer()


## Spawns a "passer-by" that takes between walker_min_steps and walker_max_steps and disappears.
func _spawn_ambient_walker() -> void:
	_active_walkers += 1

	# Pick a starting point inside the screen (away from the edges)
	var start_position: Vector2 = Vector2(
		randf_range(120.0, 1800.0),
		randf_range(120.0, 960.0)
	)
	var walk_angle: float = randf_range(0.0, TAU)
	var direction: Vector2 = Vector2(cos(walk_angle), sin(walk_angle))
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)

	var total_steps: int = randi_range(walker_min_steps, walker_max_steps)
	var step_length: float = randf_range(24.0, 32.0)
	var right_foot: bool = randf() > 0.5
	var cadence: float = randf_range(0.28, 0.36)

	for step_index: int in range(total_steps):
		var delay: float = float(step_index) * cadence
		var distance: float = float(step_index) * step_length
		var foot_sign: float = 1.0 if right_foot else -1.0
		var footprint_position: Vector2 = start_position + (direction * distance) + (perpendicular * 5.0 * foot_sign)
		var footprint_rotation: float = walk_angle + (PI / 2.0)

		var step_timer: SceneTreeTimer = get_tree().create_timer(delay)
		var is_last_step: bool = (step_index == total_steps - 1)
		step_timer.timeout.connect(_spawn_ambient_footprint.bind(footprint_position, footprint_rotation, right_foot, is_last_step))

		right_foot = not right_foot

	# Once every step is taken, free the slot so another walker can appear
	var walk_end_time: float = float(total_steps) * cadence + 0.5
	get_tree().create_timer(walk_end_time).timeout.connect(func() -> void:
		_active_walkers = max(_active_walkers - 1, 0)
	)


func _spawn_ambient_footprint(spawn_position: Vector2, spawn_rotation: float, right_foot: bool, _is_last: bool) -> void:
	var footprint: Footprint = _take_footprint_from_pool()
	footprint.setup(right_foot, randf_range(0.60, 0.75))
	footprint.global_position = spawn_position
	footprint.rotation = spawn_rotation
	footprint.scale = Vector2(0.85, 0.85)
	footprint.z_index = 1
	footprint.z_as_relative = false
	ambient_footprints_layer.add_child(footprint)

	# Stays visible longer (2.8s - 4.0s) so more footprints pile up at once
	var visible_time: float = randf_range(2.8, 4.0)
	var lifetime_timer: SceneTreeTimer = get_tree().create_timer(visible_time)
	lifetime_timer.timeout.connect(func() -> void:
		footprint.fade_out(1.5, func() -> void:
			_return_footprint_to_pool(footprint)
		)
	)


# ==============================================================================
# MEMORY MANAGEMENT AND OBJECT POOLING
# ==============================================================================

func _take_footprint_from_pool() -> Footprint:
	if _footprint_pool.size() > 0:
		var footprint: Footprint = _footprint_pool.pop_back()
		footprint.visible = true
		footprint.modulate.a = 1.0
		return footprint
	else:
		return Footprint.new()


func _return_footprint_to_pool(footprint: Footprint) -> void:
	if footprint.get_parent() != null:
		footprint.get_parent().remove_child(footprint)
	footprint.visible = false
	_footprint_pool.append(footprint)
