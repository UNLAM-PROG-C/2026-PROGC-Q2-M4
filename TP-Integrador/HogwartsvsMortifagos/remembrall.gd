class_name Remembrall
extends Ally

## Cherry bomb ally: shortly after being placed it swells and explodes,
## damaging every enemy inside ExplosionArea.

## Emitted when the Remembrall explodes.
signal detonated(entity: Node2D)

const SPRITE_SCALE_PROPERTY: NodePath = ^"scale"
const MODULATE_PROPERTY: NodePath = ^"modulate"
## Size and tint reached by the warning animation, and its duration.
const WARNING_SCALE: Vector2 = Vector2(1.25, 1.25)
const WARNING_COLOR: Color = Color(1.0, 0.5, 0.5, 1.0)
const WARNING_DURATION: float = 0.3
const ANIMATION_FRAME_COUNT: int = 7
const FUSE_DURATION: float = 1.5

## Damage dealt to every enemy inside ExplosionArea.
@export var explosion_damage: float = 1800.0

@onready var fuse_timer: Timer = $FuseTimer
@onready var animation_timer: Timer = $AnimationTimer
@onready var explosion_area: Area2D = $ExplosionArea
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	animation_timer.wait_time = FUSE_DURATION / ANIMATION_FRAME_COUNT
	animation_timer.start()
	start_fuse()


func start_fuse() -> void:
	fuse_timer.start()


## AnimationTimer callback. Advances through the seven Remembrall frames.
func _on_animation_timer_timeout() -> void:
	if sprite.frame >= ANIMATION_FRAME_COUNT - 1:
		animation_timer.stop()
		return
	sprite.frame += 1


## FuseTimer callback. Plays the warning animation and then explodes.
func _on_fuse_timer_timeout() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, SPRITE_SCALE_PROPERTY, WARNING_SCALE, WARNING_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, MODULATE_PROPERTY, WARNING_COLOR, WARNING_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(detonate)


## Damages every enemy inside ExplosionArea and frees itself.
func detonate() -> void:
	for area: Area2D in explosion_area.get_overlapping_areas():
		if area.is_in_group(Groups.ENEMIES):
			(area as Enemy).take_damage(explosion_damage)
	detonated.emit(self)
	queue_free()
