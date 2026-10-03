class_name DamageFlash
extends Node

## Tints a CanvasItem when its owner takes damage, then restores it.
## Enemies fade back with a tween; allies snap back and have a cooldown.

const MODULATE_PROPERTY: NodePath = ^"modulate"

## Node tinted by the flash. Nothing happens while it is unset.
@export var target: CanvasItem
@export var flash_color: Color = Color(1.0, 0.3, 0.3)
## Seconds the tint lasts (or takes to fade, when fade_out is set).
@export var duration: float = 0.1
## Minimum seconds between two flashes. 0 means no cooldown.
@export var cooldown: float = 0.0
## Fade back to white with a tween instead of restoring it at once.
@export var fade_out: bool = false

var _is_cooling_down: bool = false


func flash() -> void:
	if target == null or _is_cooling_down:
		return
	target.modulate = flash_color
	if fade_out:
		create_tween().tween_property(target, MODULATE_PROPERTY, Color.WHITE, duration)
	else:
		get_tree().create_timer(duration).timeout.connect(_restore)
	if cooldown > 0.0:
		_is_cooling_down = true
		get_tree().create_timer(cooldown).timeout.connect(_end_cooldown)


func _restore() -> void:
	target.modulate = Color.WHITE


func _end_cooldown() -> void:
	_is_cooling_down = false
