class_name AccioButton
extends Button

## HUD button to activate and deactivate the Accio removal tool.
## Displays the Elder Wand sprite framed in a parchment panel matching the Pause button.

signal accio_toggled(is_active: bool)

const ACTIVE_COLOR: Color = Color(1.0, 0.4, 0.4)
const HOVER_SCALE: Vector2 = Vector2(1.08, 1.08)
const NORMAL_SCALE: Vector2 = Vector2(1.0, 1.0)
const TOOLTIP_TEXT_CONTENT: String = "Accio"
const WAND_TEXTURE: Texture2D = preload("res://Images/elder_wand.png")

const PARCHMENT_BG_NORMAL: Color = Color(0.894118, 0.803922, 0.623529, 1.0)
const PARCHMENT_BG_PRESSED: Color = Color(0.819608, 0.729412, 0.54902, 1.0)
const PARCHMENT_BG_HOVER: Color = Color(0.941176, 0.858824, 0.701961, 1.0)
const BORDER_COLOR: Color = Color(0.235294, 0.141176, 0.0823529, 1.0)
const SHADOW_COLOR_NORMAL: Color = Color(0.0, 0.0, 0.0, 0.35)
const SHADOW_COLOR_PRESSED: Color = Color(0.0, 0.0, 0.0, 0.2)
const SHADOW_COLOR_HOVER: Color = Color(0.0, 0.0, 0.0, 0.45)

const BORDER_WIDTH: int = 4
const CORNER_RADIUS: int = 12
const CONTENT_MARGIN: int = 10
const SHADOW_SIZE_NORMAL: int = 6
const SHADOW_SIZE_PRESSED: int = 2
const SHADOW_SIZE_HOVER: int = 8
const SHADOW_OFFSET_NORMAL: Vector2 = Vector2(2.0, 2.0)
const SHADOW_OFFSET_PRESSED: Vector2 = Vector2(1.0, 1.0)
const SHADOW_OFFSET_HOVER: Vector2 = Vector2(3.0, 3.0)

const DEFAULT_BUTTON_SIZE: Vector2 = Vector2(100.0, 100.0)
const MAX_BOTTOM_Y: float = 1056.0
const ADJUSTED_POS_X: float = 1796.0
const ADJUSTED_POS_Y: float = 956.0

var _is_active: bool = false


func _ready() -> void:
	_init_button_visuals()
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _init_button_visuals() -> void:
	icon = WAND_TEXTURE
	expand_icon = true
	flat = false
	text = ""
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_text = TOOLTIP_TEXT_CONTENT
	focus_mode = FOCUS_NONE
	custom_minimum_size = DEFAULT_BUTTON_SIZE
	_apply_theme_styles()
	_adjust_screen_fit()
	pivot_offset = size * 0.5


func _apply_theme_styles() -> void:
	var normal_box: StyleBoxFlat = _create_stylebox(
		PARCHMENT_BG_NORMAL, SHADOW_COLOR_NORMAL, SHADOW_SIZE_NORMAL, SHADOW_OFFSET_NORMAL
	)
	var pressed_box: StyleBoxFlat = _create_stylebox(
		PARCHMENT_BG_PRESSED, SHADOW_COLOR_PRESSED, SHADOW_SIZE_PRESSED, SHADOW_OFFSET_PRESSED
	)
	var hover_box: StyleBoxFlat = _create_stylebox(
		PARCHMENT_BG_HOVER, SHADOW_COLOR_HOVER, SHADOW_SIZE_HOVER, SHADOW_OFFSET_HOVER
	)
	add_theme_stylebox_override("normal", normal_box)
	add_theme_stylebox_override("pressed", pressed_box)
	add_theme_stylebox_override("hover", hover_box)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _create_stylebox(bg: Color, shadow_color: Color, shadow_sz: int, shadow_off: Vector2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.set_border_width_all(BORDER_WIDTH)
	style.border_color = BORDER_COLOR
	style.set_corner_radius_all(CORNER_RADIUS)
	style.shadow_color = shadow_color
	style.shadow_size = shadow_sz
	style.shadow_offset = shadow_off
	style.content_margin_left = CONTENT_MARGIN
	style.content_margin_top = CONTENT_MARGIN
	style.content_margin_right = CONTENT_MARGIN
	style.content_margin_bottom = CONTENT_MARGIN
	return style


func _adjust_screen_fit() -> void:
	if offset_bottom > MAX_BOTTOM_Y:
		offset_left = ADJUSTED_POS_X
		offset_top = ADJUSTED_POS_Y
		offset_right = ADJUSTED_POS_X + DEFAULT_BUTTON_SIZE.x
		offset_bottom = ADJUSTED_POS_Y + DEFAULT_BUTTON_SIZE.y
		size = DEFAULT_BUTTON_SIZE


func set_active(active: bool) -> void:
	_is_active = active
	modulate = ACTIVE_COLOR if _is_active else Color.WHITE


func is_active() -> bool:
	return _is_active


func _on_pressed() -> void:
	set_active(not _is_active)
	accio_toggled.emit(_is_active)


func _on_mouse_entered() -> void:
	pivot_offset = size * 0.5
	scale = HOVER_SCALE


func _on_mouse_exited() -> void:
	scale = NORMAL_SCALE
