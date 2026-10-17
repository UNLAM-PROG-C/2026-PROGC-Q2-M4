class_name CustomCursor
extends CanvasLayer

## Animated custom cursor with a golden flying key and flapping wings.
## Flapping occurs only during mouse motion and rests when stationary.

const MAX_FLAP_ANGLE_DEG: float = 32.0
const FLAP_SPEED: float = 24.0
const RETURN_SPEED: float = 12.0
const MOTION_TIMEOUT: float = 0.08
const DEFAULT_SCALE: float = 0.4
const WING_ATTACH_Y: float = -100.0
const WING_ATTACH_X: float = 5.0
const WING_PIVOT_OFFSET: Vector2 = Vector2(0.0, -55.0)
const KEY_PIVOT_OFFSET: Vector2 = Vector2(0.0, 0.0)

@export var cursor_scale: float = DEFAULT_SCALE
@export var max_flap_angle: float = deg_to_rad(MAX_FLAP_ANGLE_DEG)

var _current_flap_angle: float = 0.0
var _flap_phase: float = 0.0
var _motion_timer: float = 0.0
var _last_mouse_pos: Vector2 = Vector2.ZERO
var _is_ready_settled: bool = false

@onready var cursor_root: Node2D = $CursorRoot
@onready var key_sprite: Sprite2D = $CursorRoot/KeySprite
@onready var left_wing: Sprite2D = $CursorRoot/LeftWing
@onready var right_wing: Sprite2D = $CursorRoot/RightWing


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_setup_nodes()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _setup_nodes() -> void:
	cursor_root.scale = Vector2(cursor_scale, cursor_scale)
	key_sprite.offset = KEY_PIVOT_OFFSET
	right_wing.offset = WING_PIVOT_OFFSET
	left_wing.offset = WING_PIVOT_OFFSET
	right_wing.position = Vector2(WING_ATTACH_X, WING_ATTACH_Y)
	left_wing.position = Vector2(-WING_ATTACH_X, WING_ATTACH_Y)
	left_wing.scale = Vector2(-1.0, 1.0)
	_last_mouse_pos = get_viewport().get_mouse_position()
	cursor_root.global_position = _last_mouse_pos


func _input(event: InputEvent) -> void:
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null:
		_on_mouse_moved(motion.position, motion.relative)


func _on_mouse_moved(pos: Vector2, rel: Vector2) -> void:
	cursor_root.global_position = pos
	if rel.length_squared() > 0.0:
		_motion_timer = MOTION_TIMEOUT


func _process(delta: float) -> void:
	_update_cursor_position()
	_update_flapping_animation(delta)
	_update_visibility_and_mouse_mode()


func _update_cursor_position() -> void:
	var current_pos: Vector2 = get_viewport().get_mouse_position()
	if not _is_ready_settled:
		_last_mouse_pos = current_pos
		cursor_root.global_position = current_pos
		_is_ready_settled = true
		return
	if current_pos != _last_mouse_pos:
		var diff: Vector2 = current_pos - _last_mouse_pos
		_last_mouse_pos = current_pos
		cursor_root.global_position = current_pos
		if diff.length_squared() > 0.25:
			_motion_timer = MOTION_TIMEOUT


func _update_flapping_animation(delta: float) -> void:
	if _motion_timer > 0.0:
		_motion_timer -= delta
		_flap_phase += delta * FLAP_SPEED
		_current_flap_angle = absf(sin(_flap_phase)) * max_flap_angle
	else:
		_current_flap_angle = move_toward(_current_flap_angle, 0.0, delta * RETURN_SPEED)
		if is_zero_approx(_current_flap_angle):
			_flap_phase = 0.0
	_apply_wing_rotations()


func _apply_wing_rotations() -> void:
	right_wing.rotation = -_current_flap_angle
	left_wing.rotation = _current_flap_angle


func _update_visibility_and_mouse_mode() -> void:
	var overridden: bool = _is_cursor_overridden()
	cursor_root.visible = not overridden
	if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _is_cursor_overridden() -> bool:
	var accio_cursor: CanvasItem = get_tree().root.find_child("AccioCursor", true, false) as CanvasItem
	return accio_cursor != null and accio_cursor.is_visible_in_tree()


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
