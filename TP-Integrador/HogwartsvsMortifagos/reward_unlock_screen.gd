class_name RewardUnlockScreen
extends CanvasLayer

signal reward_dismissed(level_number: int)

const STATE_ANIMATING: int = 0
const STATE_RESTING: int = 1
const STATE_DISMISSED: int = 2

const ANIMATION_DURATION: float = 1.2
const ROTATION_TURNS: float = 4.0 * PI
const INITIAL_SCALE: Vector2 = Vector2(0.1, 0.1)
const FINAL_SCALE: Vector2 = Vector2(2.0, 2.0)
const START_POSITION_Y: float = 540.0
const RESTING_POSITION_Y: float = 310.0
const FALLBACK_CENTER_X: float = 960.0

const CONTINUE_BUTTON_TEXT: String = "Continuar"

@onready var root_control: Control = $RootControl
@onready var seed_anchor: Control = $RootControl/SeedAnchor
@onready var seed_icon: TextureRect = $RootControl/SeedAnchor/SeedIcon
@onready var description_label: Label = $RootControl/DescriptionLabel
@onready var continue_button: Button = $RootControl/ContinueButton

var _tween: Tween = null
var _current_level: int = 1
var _state: int = STATE_ANIMATING


func _ready() -> void:
	layer = 100
	_bind_nodes()
	continue_button.text = CONTINUE_BUTTON_TEXT
	continue_button.visible = false
	root_control.gui_input.connect(_on_root_gui_input)
	continue_button.pressed.connect(_on_continue_button_pressed)
	root_control.resized.connect(_on_root_control_resized)


func _bind_nodes() -> void:
	if root_control == null:
		root_control = $RootControl
		seed_anchor = $RootControl/SeedAnchor
		seed_icon = $RootControl/SeedAnchor/SeedIcon
		description_label = $RootControl/DescriptionLabel
		continue_button = $RootControl/ContinueButton


func setup(level_num: int, item_texture: Texture2D, description: String) -> void:
	_bind_nodes()
	_current_level = level_num
	seed_icon.texture = item_texture
	description_label.text = description
	_start_animation()


func _get_screen_center_x() -> float:
	_bind_nodes()
	if root_control != null and root_control.size.x > 0.0:
		return root_control.size.x * 0.5
	if is_inside_tree() and get_viewport() != null:
		var vp_width: float = get_viewport().get_visible_rect().size.x
		if vp_width > 0.0:
			return vp_width * 0.5
	return FALLBACK_CENTER_X


func _get_start_position() -> Vector2:
	return Vector2(_get_screen_center_x(), START_POSITION_Y)


func _get_resting_position() -> Vector2:
	return Vector2(_get_screen_center_x(), RESTING_POSITION_Y)


func _on_root_control_resized() -> void:
	if _state == STATE_RESTING and seed_anchor != null:
		seed_anchor.position = _get_resting_position()


func _start_animation() -> void:
	_state = STATE_ANIMATING
	continue_button.visible = false
	seed_anchor.position = _get_start_position()
	seed_anchor.scale = INITIAL_SCALE
	seed_anchor.rotation = 0.0
	_create_and_play_tween()


func _create_and_play_tween() -> void:
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(seed_anchor, "position", _get_resting_position(), ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(seed_anchor, "scale", FINAL_SCALE, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(seed_anchor, "rotation", ROTATION_TURNS, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.chain().tween_callback(_on_animation_finished)


func _on_animation_finished() -> void:
	_state = STATE_RESTING
	seed_anchor.position = _get_resting_position()
	seed_anchor.scale = FINAL_SCALE
	seed_anchor.rotation = 0.0
	continue_button.visible = true


func skip_animation() -> void:
	if _state != STATE_ANIMATING:
		return
	if is_instance_valid(_tween) and _tween.is_running():
		_tween.kill()
	_on_animation_finished()


func _on_root_gui_input(event: InputEvent) -> void:
	if _state != STATE_ANIMATING:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip_animation()


func _on_continue_button_pressed() -> void:
	if _state == STATE_DISMISSED:
		return
	_state = STATE_DISMISSED
	reward_dismissed.emit(_current_level)
	queue_free()
