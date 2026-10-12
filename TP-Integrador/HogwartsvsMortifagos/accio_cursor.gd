class_name AccioCursor
extends Node2D

## Visual cursor for the Accio tool displaying the Elder Wand.
## Emits a magical glow at the wand tip when an ally is removed.

signal glow_finished()

const SCALE_PROPERTY: NodePath = ^"scale"
const MODULATE_PROPERTY: NodePath = ^"modulate"
const ROTATION_PROPERTY: NodePath = ^"rotation"

const GLOW_START_SCALE: Vector2 = Vector2(0.1, 0.1)
const GLOW_PEAK_SCALE: Vector2 = Vector2(1.3, 1.3)
const GLOW_END_SCALE: Vector2 = Vector2(1.8, 1.8)
const GLOW_PEAK_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const GLOW_FADED_COLOR: Color = Color(1.0, 1.0, 1.0, 0.0)

const BURST_DURATION: float = 0.08
const FADE_DURATION: float = 0.18
const ROTATION_BURST: float = 0.35
const ROTATION_TOTAL: float = 0.75

@onready var wand_sprite: Sprite2D = $WandSprite
@onready var tip_glow: Node2D = $TipGlow

var _active_tween: Tween = null
var _is_glowing: bool = false


func _ready() -> void:
	if tip_glow != null:
		tip_glow.visible = false


func play_tip_glow(on_finished: Callable = Callable()) -> void:
	_is_glowing = true
	_stop_active_tween()
	_reset_glow_visuals()
	_animate_tip_glow(on_finished)


func stop_glow() -> void:
	_is_glowing = false
	_stop_active_tween()
	if tip_glow != null:
		tip_glow.visible = false


func is_glowing() -> bool:
	return _is_glowing


func _reset_glow_visuals() -> void:
	if tip_glow == null:
		return
	tip_glow.visible = true
	tip_glow.scale = GLOW_START_SCALE
	tip_glow.modulate = GLOW_PEAK_COLOR
	tip_glow.rotation = 0.0


func _stop_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
		_active_tween = null


func _animate_tip_glow(on_finished: Callable) -> void:
	if tip_glow == null:
		_finish_glow(on_finished)
		return
	_active_tween = create_tween()
	var burst: Tween = _active_tween.parallel()
	burst.tween_property(tip_glow, SCALE_PROPERTY, GLOW_PEAK_SCALE, BURST_DURATION)
	burst.tween_property(tip_glow, ROTATION_PROPERTY, ROTATION_BURST, BURST_DURATION)
	_active_tween.chain()
	var fade: Tween = _active_tween.parallel()
	fade.tween_property(tip_glow, SCALE_PROPERTY, GLOW_END_SCALE, FADE_DURATION)
	fade.tween_property(tip_glow, MODULATE_PROPERTY, GLOW_FADED_COLOR, FADE_DURATION)
	fade.tween_property(tip_glow, ROTATION_PROPERTY, ROTATION_TOTAL, FADE_DURATION)
	_active_tween.chain().tween_callback(_finish_glow.bind(on_finished))


func _finish_glow(callback: Callable) -> void:
	_is_glowing = false
	if tip_glow != null:
		tip_glow.visible = false
	glow_finished.emit()
	if callback.is_valid():
		callback.call()
