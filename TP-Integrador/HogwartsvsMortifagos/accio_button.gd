class_name AccioButton
extends Button

## HUD button to activate and deactivate the Accio removal tool.
## It sits at the right end of the card bar, like the shovel in Plants vs. Zombies.
## It looks like a small parchment card (the same parchment as the pause button
## and the snitch counter): brown frame, a large Elder Wand and a serif
## "ACCIO". Only while active does it turn golden and pulse, to show
## that the next click removes an ally.

signal accio_toggled(is_active: bool)

const LABEL_TEXT: String = "ACCIO"
const TOOLTIP_TEXT_CONTENT: String = "Accio: hacé clic en un aliado para quitarlo.\nClic derecho o Esc para cancelar."
const WAND_TEXTURE: Texture2D = preload("res://Images/elder_wand.png")

const PARCHMENT_BG_NORMAL: Color = Color(0.902, 0.780, 0.549, 1.0)
const PARCHMENT_BG_HOVER: Color = Color(0.941, 0.839, 0.635, 1.0)
const PARCHMENT_BG_ACTIVE: Color = Color(0.980, 0.886, 0.620, 1.0)
const PARCHMENT_FRAME: Color = Color(0.545, 0.353, 0.141, 1.0)
const ACTIVE_FRAME: Color = Color(0.850, 0.600, 0.150, 1.0)
const INK_COLOR: Color = Color(0.325, 0.208, 0.082, 1.0)
const SOFT_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.3)
const ACTIVE_GLOW: Color = Color(1.0, 0.80, 0.30, 0.75)
const ICON_TINT: Color = Color(1.0, 1.0, 1.0, 1.0)
## Serif faces tried in order; the first one installed is used.
const SERIF_FONT_NAMES: PackedStringArray = ["Georgia", "Times New Roman", "Liberation Serif", "DejaVu Serif", "serif"]
const BOLD_WEIGHT: int = 700

const BORDER_WIDTH: int = 3
const CORNER_RADIUS: int = 8
const CONTENT_MARGIN: int = 5
const LABEL_FONT_SIZE: int = 22
## As wide as the inner space allows, so the wand is the main element.
const ICON_MAX_WIDTH: int = 86
const IDLE_SHADOW_SIZE: int = 3
const ACTIVE_GLOW_MIN: float = 4.0
const ACTIVE_GLOW_MAX: float = 14.0
const ACTIVE_PULSE_SECONDS: float = 0.45
const INFINITE_LOOPS: int = 0

const HOVER_SCALE: Vector2 = Vector2(1.05, 1.05)
const NORMAL_SCALE: Vector2 = Vector2(1.0, 1.0)
## Smaller than a card (124 x 185) and centred on the card bar.
const BUTTON_SIZE: Vector2 = Vector2(96.0, 130.0)
## Minimum space between the last card and the button.
const BAR_GAP: float = 20.0
## Space between the button and the pause button. With it the button sits
## where it lands after the 9 cards of levels 9 and 10, in every level.
const RIGHT_MARGIN: float = 84.0
const HALF: float = 0.5

var _is_active: bool = false
var _idle_box: StyleBoxFlat = null
var _hover_box: StyleBoxFlat = null
var _active_box: StyleBoxFlat = null
var _pulse: Tween = null


func _ready() -> void:
	_init_button_visuals()
	_apply_state_style()
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## Places the button at the right end of the card bar, always at the same
## spot (RIGHT_MARGIN before the pause button) and centred on the cards. It
## never overlaps the cards: if they reach that far it moves after them.
func place_on_card_bar(cards_rect: Rect2, right_limit: float) -> void:
	var left: float = right_limit - RIGHT_MARGIN - BUTTON_SIZE.x
	left = maxf(left, cards_rect.end.x + BAR_GAP)
	var top: float = cards_rect.get_center().y - BUTTON_SIZE.y * HALF
	position = Vector2(left, top)
	size = BUTTON_SIZE
	pivot_offset = size * HALF


func set_active(active: bool) -> void:
	_is_active = active
	_apply_state_style()


func is_active() -> bool:
	return _is_active


func _init_button_visuals() -> void:
	icon = WAND_TEXTURE
	expand_icon = true
	flat = false
	text = LABEL_TEXT
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	tooltip_text = TOOLTIP_TEXT_CONTENT
	focus_mode = FOCUS_NONE
	_build_styles()
	_apply_label_theme()
	pivot_offset = size * HALF


func _build_styles() -> void:
	_idle_box = _create_stylebox(PARCHMENT_BG_NORMAL, PARCHMENT_FRAME, SOFT_SHADOW)
	_hover_box = _create_stylebox(PARCHMENT_BG_HOVER, PARCHMENT_FRAME, SOFT_SHADOW)
	_active_box = _create_stylebox(PARCHMENT_BG_ACTIVE, ACTIVE_FRAME, ACTIVE_GLOW)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _create_stylebox(bg: Color, border: Color, glow: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.set_border_width_all(BORDER_WIDTH)
	style.border_color = border
	style.set_corner_radius_all(CORNER_RADIUS)
	style.shadow_color = glow
	style.shadow_size = IDLE_SHADOW_SIZE
	style.set_content_margin_all(CONTENT_MARGIN)
	return style


func _apply_label_theme() -> void:
	var serif: SystemFont = SystemFont.new()
	serif.font_names = SERIF_FONT_NAMES
	serif.font_weight = BOLD_WEIGHT
	add_theme_font_override("font", serif)
	add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	add_theme_constant_override("icon_max_width", ICON_MAX_WIDTH)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color"]:
		add_theme_color_override(color_name, INK_COLOR)
	for color_name: String in ["icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
		add_theme_color_override(color_name, ICON_TINT)


## Swaps the styles for the current state and restarts the glow.
func _apply_state_style() -> void:
	var base: StyleBoxFlat = _active_box if _is_active else _idle_box
	var hover: StyleBoxFlat = _active_box if _is_active else _hover_box
	for state: String in ["normal", "pressed"]:
		add_theme_stylebox_override(state, base)
	add_theme_stylebox_override("hover", hover)
	_restart_pulse()


## Only the active state pulses; idle stays still like the cards.
func _restart_pulse() -> void:
	if _pulse != null and _pulse.is_valid():
		_pulse.kill()
	if not _is_active:
		return
	_pulse = create_tween().set_loops(INFINITE_LOOPS)
	_pulse.tween_method(_set_glow_size, ACTIVE_GLOW_MIN, ACTIVE_GLOW_MAX, ACTIVE_PULSE_SECONDS)
	_pulse.tween_method(_set_glow_size, ACTIVE_GLOW_MAX, ACTIVE_GLOW_MIN, ACTIVE_PULSE_SECONDS)


func _set_glow_size(glow: float) -> void:
	_active_box.shadow_size = roundi(glow)


func _on_pressed() -> void:
	set_active(not _is_active)
	accio_toggled.emit(_is_active)


func _on_mouse_entered() -> void:
	pivot_offset = size * HALF
	scale = HOVER_SCALE


func _on_mouse_exited() -> void:
	scale = NORMAL_SCALE
