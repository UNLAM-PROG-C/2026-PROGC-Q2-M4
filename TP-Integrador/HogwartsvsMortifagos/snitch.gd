class_name Snitch
extends Area2D

## Collectable Snitch. Falls from the sky in a zigzag dodging the mouse, or
## rests on the ground when dropped by a Snitch Box. Clicking it collects it.

## Emitted when the player collects the snitch by clicking it.
signal collected(amount: int)

## Frames of the flying animation sheet.
const FLY_FRAMES: int = 4
## Frame shown while resting on the ground (dropped by a Snitch Box).
const RESTING_FRAME: int = 1
## The snitch is freed once it falls below this y coordinate.
const FALL_LIMIT_Y: float = 1200.0
## Clicks closer than this (pixels) collect the snitch.
const CLICK_RADIUS: float = 32.0
## Random horizontal offset (pixels) when dropped by a Snitch Box.
const BOX_DROP_SPREAD: float = 15.0
## Pop when dropped by a Snitch Box: height, landing offset and duration of each half.
const BOX_POP_HEIGHT: float = 45.0
const BOX_LANDING_OFFSET: float = 15.0
const BOX_POP_DURATION: float = 0.25
const GLOBAL_Y_PROPERTY: NodePath = ^"global_position:y"
## Default target Y coordinate for sky fall.
const DEFAULT_TARGET_Y: float = 576.0
## Lifetime in seconds while resting on the ground.
const GROUND_LIFETIME: float = 5.0
## Maximum seconds allowed to reach the ground before timing out.
const AIR_FALL_TIMEOUT: float = 30.0

## Snitches granted when collected.
@export var value: int = 25
## Fall speed in pixels per second.
@export var fall_speed: float = 60.0
## Maximum lifetime in seconds before disappearing.
@export var lifetime: float = 10.0
## Target Y coordinate where the falling snitch lands.
@export var target_y: float = DEFAULT_TARGET_Y
## Seconds the snitch stays at row level on the ground before disappearing.
@export var ground_duration: float = GROUND_LIFETIME

# Zigzag movement parameters
@export var zigzag_amplitude: float = 60.0 # maximum sideways offset in pixels
@export var zigzag_frequency: float = 3.0 # radians per second (zigzag speed)

# Escape parameters when the mouse gets close
@export var escape_distance: float = 80.0 # distance at which the snitch reacts
@export var escape_speed: float = 200.0 # speed while escaping
@export var escape_duration: float = 0.3 # escape duration in seconds
@export var escape_cooldown_time: float = 0.5 # seconds before it can escape again

var _time_left: float = 0.0
var _is_collected: bool = false
var _elapsed: float = 0.0
var _start_x: float = 0.0
var _escape_cooldown: float = 0.0
var _escape_time_left: float = 0.0
var _escape_direction: Vector2 = Vector2.ZERO
var _is_animated: bool = true
var _is_on_ground: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_timer: Timer = $AnimationTimer
@onready var escape_particles: CPUParticles2D = $EscapeParticles


func _ready() -> void:
	if not _is_animated:
		_stop_animation()
	_time_left = AIR_FALL_TIMEOUT if not _is_on_ground else lifetime
	_start_x = position.x


func _stop_animation() -> void:
	_is_animated = false
	if animation_timer != null:
		animation_timer.stop()
	if sprite != null:
		sprite.frame = RESTING_FRAME


## Sets up a Snitch falling from the sky towards a specific ground row level.
func setup_sky_fall(target_ground_y: float, stay_duration: float = GROUND_LIFETIME) -> void:
	target_y = target_ground_y
	ground_duration = stay_duration
	_is_on_ground = false
	_time_left = AIR_FALL_TIMEOUT


## Returns whether the snitch is currently landed on the ground.
func is_on_ground() -> bool:
	return _is_on_ground


## Sets up a Snitch dropped by a Snitch Box (soft pop upwards, then it stays on the ground to be clicked).
func setup_from_box(origin: Vector2) -> void:
	_is_animated = false
	_is_on_ground = true
	fall_speed = 0.0
	zigzag_amplitude = 0.0
	escape_distance = 0.0
	_start_x = origin.x + randf_range(-BOX_DROP_SPREAD, BOX_DROP_SPREAD)
	global_position = origin
	_animate_box_pop(origin)


func _animate_box_pop(origin: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, GLOBAL_Y_PROPERTY, origin.y - BOX_POP_HEIGHT, BOX_POP_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, GLOBAL_Y_PROPERTY, origin.y + BOX_LANDING_OFFSET, BOX_POP_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _process(delta: float) -> void:
	if _is_collected:
		return
	_tick_timers(delta)
	if not _is_on_ground:
		_process_air_state(delta)
	if _is_expired():
		queue_free()


func _process_air_state(delta: float) -> void:
	if _escape_time_left > 0.0:
		_process_escape(delta)
	else:
		_process_fall(delta)
		_try_start_escape()
	if position.y >= target_y:
		_land_on_ground()


func _land_on_ground() -> void:
	_is_on_ground = true
	_stop_animation()
	position.y = target_y
	fall_speed = 0.0
	zigzag_amplitude = 0.0
	_escape_time_left = 0.0
	_time_left = ground_duration
	if escape_particles != null:
		escape_particles.emitting = false


func _tick_timers(delta: float) -> void:
	_elapsed += delta
	_escape_cooldown = maxf(_escape_cooldown - delta, 0.0)
	_time_left -= delta


## Escaping state: flies away from the mouse.
func _process_escape(delta: float) -> void:
	_escape_time_left -= delta
	position += _escape_direction * escape_speed * delta
	if _escape_time_left <= 0.0 and zigzag_amplitude > 0.0:
		_start_x = position.x - _zigzag_offset()


## Falling state: zigzags down.
func _process_fall(delta: float) -> void:
	if zigzag_amplitude > 0.0:
		position.x = _start_x + _zigzag_offset()
	if fall_speed > 0.0:
		position.y += fall_speed * delta


func _zigzag_offset() -> float:
	return sin(_elapsed * zigzag_frequency) * zigzag_amplitude


func _try_start_escape() -> void:
	if _is_on_ground or escape_distance <= 0.0 or _escape_cooldown > 0.0:
		return
	if get_viewport() == null:
		return
	var mouse_position: Vector2 = get_global_mouse_position()
	if global_position.distance_to(mouse_position) > escape_distance:
		return
	_escape_direction = (global_position - mouse_position).normalized()
	_escape_time_left = escape_duration
	_escape_cooldown = escape_cooldown_time
	escape_particles.emitting = true


func _is_expired() -> bool:
	return _time_left <= 0.0 or global_position.y > FALL_LIMIT_Y


# Global input handling to ensure collection even if other nodes consume the event
func _input(event: InputEvent) -> void:
	if _is_collected or not _is_left_click(event):
		return
	if global_position.distance_to(get_global_mouse_position()) <= CLICK_RADIUS:
		_collect()
		get_viewport().set_input_as_handled()


## input_event callback. Detects the player's click on the snitch.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_collected or not _is_left_click(event):
		return
	_collect()
	get_viewport().set_input_as_handled()


func _is_left_click(event: InputEvent) -> bool:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	return mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT


func _collect() -> void:
	if _is_collected:
		return
	_is_collected = true
	collected.emit(value)
	queue_free()


func _on_animation_timer_timeout() -> void:
	if _is_animated:
		sprite.frame = (sprite.frame + 1) % FLY_FRAMES
