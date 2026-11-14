class_name AllyCardButton
extends Button

## HUD button of an AllyCard: shows its cost and whether it can be afforded,
## is selected or is cooling down. Displays visual bottom-to-top sweep recharge.

## Emitted when the player clicks the card.
signal card_pressed(button: AllyCardButton)
## Emitted when the card's cooldown ends.
signal cooldown_finished()

const CARD_COOLDOWN_SHADER: Shader = preload("res://card_cooldown.gdshader")
const PROGRESS_PARAM: StringName = &"progress"
const AFFORDABLE_PARAM: StringName = &"is_affordable"
const SELECTED_PARAM: StringName = &"is_selected"
const THEME_ICON_DISABLED_COLOR: StringName = &"icon_disabled_color"

const FULL_PROGRESS: float = 1.0
const ZERO_PROGRESS: float = 0.0
const ZERO_COOLDOWN: float = 0.0

const LABEL_FORMAT_TEXT: String = "%s (%d)"
const SELECTED_COLOR: Color = Color(0.5, 1.0, 0.5)
const INVALID_CARD_MESSAGE: String = "AllyCardButton %s has an invalid card"

@export var card: AllyCard
@export var seed_texture: Texture2D

var _cooldown_left: float = 0.0
var _card_material: ShaderMaterial


func _ready() -> void:
	if card == null or not card.is_valid():
		push_error(INVALID_CARD_MESSAGE % name)
		return
	_setup_visuals()
	pressed.connect(_on_pressed)
	set_process(false)


func _setup_visuals() -> void:
	tooltip_text = LABEL_FORMAT_TEXT % [card.display_name, card.cost]
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var active_texture: Texture2D = seed_texture if seed_texture != null else icon
	if active_texture != null:
		_apply_icon_styling(active_texture)
	else:
		text = LABEL_FORMAT_TEXT % [card.display_name, card.cost]


func _apply_icon_styling(active_texture: Texture2D) -> void:
	icon = active_texture
	flat = true
	expand_icon = true
	text = ""
	_setup_shader_material()


func _setup_shader_material() -> void:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = CARD_COOLDOWN_SHADER
	material = mat
	_card_material = mat
	add_theme_color_override(THEME_ICON_DISABLED_COLOR, Color.WHITE)
	_update_cooldown_progress(FULL_PROGRESS)
	_update_shader_affordability(true)


func _process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, ZERO_COOLDOWN)
	var progress: float = FULL_PROGRESS - (_cooldown_left / card.cooldown)
	_update_cooldown_progress(progress)
	if _cooldown_left <= ZERO_COOLDOWN:
		_finish_cooldown()


func _finish_cooldown() -> void:
	_update_cooldown_progress(FULL_PROGRESS)
	set_process(false)
	cooldown_finished.emit()


func refresh(snitches: int) -> void:
	var can_afford: bool = snitches >= card.cost
	disabled = not can_afford or _cooldown_left > ZERO_COOLDOWN
	_update_shader_affordability(can_afford)


func set_selected(is_selected: bool) -> void:
	modulate = SELECTED_COLOR if is_selected else Color.WHITE
	if _card_material != null:
		_card_material.set_shader_parameter(SELECTED_PARAM, is_selected)


func start_cooldown() -> void:
	if card.cooldown <= ZERO_COOLDOWN:
		_finish_cooldown()
		return
	_cooldown_left = card.cooldown
	_update_cooldown_progress(ZERO_PROGRESS)
	disabled = true
	set_process(true)


func _update_cooldown_progress(progress: float) -> void:
	if _card_material != null:
		_card_material.set_shader_parameter(PROGRESS_PARAM, progress)


func _update_shader_affordability(is_affordable: bool) -> void:
	if _card_material != null:
		_card_material.set_shader_parameter(AFFORDABLE_PARAM, is_affordable)


func _on_pressed() -> void:
	card_pressed.emit(self)
