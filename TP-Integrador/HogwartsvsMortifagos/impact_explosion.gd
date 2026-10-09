class_name ImpactExplosion
extends Node2D

const SCALE_PROPERTY: NodePath = ^"scale"
const MODULATE_PROPERTY: NodePath = ^"modulate"
const START_SCALE: Vector2 = Vector2(0.2, 0.2)
const END_SCALE: Vector2 = Vector2(1.0, 1.0)
const DURATION: float = 0.16


func _ready() -> void:
	scale = START_SCALE
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, SCALE_PROPERTY, END_SCALE, DURATION)
	tween.tween_property(self, MODULATE_PROPERTY, Color(1.0, 0.75, 0.15, 0.0), DURATION)
	tween.chain().tween_callback(queue_free)
