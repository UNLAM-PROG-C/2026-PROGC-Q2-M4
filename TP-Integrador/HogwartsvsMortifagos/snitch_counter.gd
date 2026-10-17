class_name SnitchCounter
extends PanelContainer

## Counter display showing accumulated snitches in a styled parchment box.

@onready var snitches_label: Label = $VBoxContainer/SnitchesLabel
@onready var snitch_icon: TextureRect = $VBoxContainer/SnitchIcon


func set_value(amount: int) -> void:
	if snitches_label == null:
		snitches_label = $VBoxContainer/SnitchesLabel
	snitches_label.text = str(amount)


func get_value_text() -> String:
	if snitches_label == null:
		snitches_label = $VBoxContainer/SnitchesLabel
	return snitches_label.text
