class_name AccioButton
extends Button

## HUD button to activate and deactivate the Accio removal tool.

signal accio_toggled(is_active: bool)

const ACTIVE_COLOR: Color = Color(1.0, 0.4, 0.4)
const DEFAULT_TEXT: String = "Accio"

var _is_active: bool = false


func _ready() -> void:
	text = DEFAULT_TEXT
	pressed.connect(_on_pressed)


func set_active(active: bool) -> void:
	_is_active = active
	modulate = ACTIVE_COLOR if _is_active else Color.WHITE


func is_active() -> bool:
	return _is_active


func _on_pressed() -> void:
	set_active(not _is_active)
	accio_toggled.emit(_is_active)
