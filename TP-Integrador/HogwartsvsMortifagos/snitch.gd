class_name Snitch
extends Area2D

## Emitted when the player collects the snitch by clicking it.
signal collected(amount: int)

## Snitches granted when collected.
@export var value: int = 25
## Fall speed in pixels per second.
@export var fall_speed: float = 60.0
## Maximum lifetime in seconds before disappearing.
@export var lifetime: float = 10.0

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


func _ready() -> void:
	if not _is_animated:
		if has_node("AnimationTimer"):
			$AnimationTimer.stop()
		if has_node("Sprite2D"):
			$Sprite2D.frame = 1
	_time_left = lifetime
	_start_x = position.x


## Sets up a Snitch dropped by a Snitch Box (soft pop upwards, then it stays on the ground to be clicked).
func setup_from_box(origin: Vector2) -> void:
	_is_animated = false
	fall_speed = 0.0
	zigzag_amplitude = 0.0
	escape_distance = 0.0
	_start_x = origin.x + randf_range(-15.0, 15.0)
	global_position = origin
	var jump_y: float = origin.y - 45.0
	var ground_y: float = origin.y + 15.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position:y", jump_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", ground_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _process(delta: float) -> void:
	if _is_collected:
		return

	# Update timers
	_elapsed += delta
	_escape_cooldown = max(_escape_cooldown - delta, 0.0)
	_time_left -= delta

	if _escape_time_left > 0.0:
		# State: escaping
		_escape_time_left -= delta
		position += _escape_direction * escape_speed * delta

		# When the escape ends, re-center the zigzag axis to avoid a sudden jump
		if _escape_time_left <= 0.0:
			if zigzag_amplitude > 0.0:
				_start_x = position.x - sin(_elapsed * zigzag_frequency) * zigzag_amplitude
	else:
		# State: falling normally
		if zigzag_amplitude > 0.0:
			position.x = _start_x + sin(_elapsed * zigzag_frequency) * zigzag_amplitude

		if fall_speed > 0.0:
			position.y += fall_speed * delta

		# Check whether it should start escaping
		if escape_distance > 0.0 and _escape_cooldown <= 0.0:
			var mouse_pos: Vector2 = get_global_mouse_position()
			if global_position.distance_to(mouse_pos) <= escape_distance:
				_escape_direction = (global_position - mouse_pos).normalized()
				_escape_time_left = escape_duration
				_escape_cooldown = escape_cooldown_time
				if has_node("EscapeParticles"):
					$EscapeParticles.emitting = true

	# Lifetime check
	if _time_left <= 0.0 or global_position.y > 1200.0:
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if _is_collected:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) <= 32.0:
			_collect()
			get_viewport().set_input_as_handled()

# Global input handling to ensure collection even if other nodes consume the event
func _input(event: InputEvent) -> void:
	if _is_collected:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) <= 32.0:
			_collect()
			get_viewport().set_input_as_handled()


## input_event callback. Detects the player's click on the snitch.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_collected:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_collect()
		get_viewport().set_input_as_handled()


func _collect() -> void:
	if _is_collected:
		return
	_is_collected = true
	collected.emit(value)
	queue_free()


func _on_animation_timer_timeout() -> void:
	if _is_animated and has_node("Sprite2D"):
		$Sprite2D.frame = ($Sprite2D.frame + 1) % 4

