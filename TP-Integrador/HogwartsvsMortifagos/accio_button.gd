class_name AccioButton
extends Button

## HUD button to activate and deactivate the Accio removal tool.
## Displays the Elder Wand sprite instead of a text label.

signal accio_toggled(is_active: bool)

const ACTIVE_COLOR: Color = Color(1.0, 0.4, 0.4)
const HOVER_SCALE: Vector2 = Vector2(1.08, 1.08)
const NORMAL_SCALE: Vector2 = Vector2(1.0, 1.0)
const TOOLTIP_TEXT_CONTENT: String = "Accio"
const WAND_TEXTURE: Texture2D = preload("res://Images/elder_wand.png")

var _is_active: bool = false


func _ready() -> void:
	_init_button_visuals()
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _init_button_visuals() -> void:
	icon = WAND_TEXTURE
	expand_icon = true
	flat = true
	text = ""
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_text = TOOLTIP_TEXT_CONTENT
	pivot_offset = size * 0.5


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
