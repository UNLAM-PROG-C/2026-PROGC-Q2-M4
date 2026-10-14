class_name SnitchBox
extends Ally

## Sunflower ally: periodically opens and drops a Snitch for the player.

## Emitted when the box drops a physical Snitch for the player to collect.
signal snitch_dropped(snitch: Snitch)

const OPEN_FRAME: int = 1
const CLOSED_FRAME: int = 0
const SCALE_PROPERTY: NodePath = ^"scale"
## Scale the box pops to while opening, and the duration of each half.
const OPEN_POP_SCALE: Vector2 = Vector2(1.2, 1.2)
const OPEN_POP_DURATION: float = 0.1

## Snitches granted by each dropped Snitch.
@export var snitches_per_drop: int = 25
## Seconds between drops.
@export var drop_interval: float = 10.0
## Physical Snitch scene dropped on each cycle.
@export var snitch_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var snitch_timer: Timer = $SnitchTimer


func _ready() -> void:
	snitch_timer.wait_time = drop_interval
	snitch_timer.start()


## SnitchTimer callback.
func _on_snitch_timer_timeout() -> void:
	_play_open_animation()
	_drop_snitch()


func _play_open_animation() -> void:
	sprite.frame = OPEN_FRAME
	var tween: Tween = create_tween()
	tween.tween_property(self, SCALE_PROPERTY, OPEN_POP_SCALE, OPEN_POP_DURATION)
	tween.tween_property(self, SCALE_PROPERTY, Vector2.ONE, OPEN_POP_DURATION)
	tween.tween_callback(_close)


func _close() -> void:
	sprite.frame = CLOSED_FRAME


func _drop_snitch() -> void:
	var snitch: Snitch = snitch_scene.instantiate() as Snitch
	snitch.value = snitches_per_drop
	snitch.setup_from_box(global_position)
	snitch_dropped.emit(snitch)
