class_name Dementor
extends Area2D

## Defensive lawnmower: waits at the left of its lane and, when an enemy
## reaches it, sweeps the whole lane killing every enemy on the way.

## Emitted when the Dementor activates and starts sweeping its lane.
signal activated(entity: Node2D)
## Emitted when the Dementor finishes sweeping the lane and is destroyed.
signal exhausted(entity: Node2D)

const SCALE_PROPERTY: NodePath = ^"scale"
## Scale reached by the launch animation, and the duration of each half.
const LAUNCH_SCALE: Vector2 = Vector2(1.3, 1.3)
const LAUNCH_DURATION: float = 0.1
## An idle Dementor activates when an enemy in its lane gets this close (x).
const TRIGGER_REACH: float = 40.0
## While sweeping, enemies in its lane up to this far ahead (x) are killed.
const SWEEP_REACH: float = 60.0
## The Dementor frees itself after crossing the complete playable board.
const EXIT_X: float = 2200.0
## Sprite frame constants for the 1x2 animation grid.
const TOTAL_FRAMES: int = 2
const IDLE_FRAME: int = 0
## Maximum cycle for the floating timer before wrapping around.
const MAX_FLOAT_CYCLE: float = 628.318

## Forward speed once active, in pixels per second.
@export var speed: float = 800.0
## Massive damage dealt to enemies in its lane (instant kill).
@export var damage: float = 9999.0
## Horizontal floating amplitude in pixels while idle.
@export var float_amplitude_x: float = 4.0
## Vertical floating amplitude in pixels while idle.
@export var float_amplitude_y: float = 6.0
## Horizontal floating frequency in radians per second.
@export var float_frequency_x: float = 2.0
## Vertical floating frequency in radians per second.
@export var float_frequency_y: float = 3.0
## Seconds between frame updates during sweeping.
@export var animation_interval: float = 0.15

var _is_active: bool = false
var _float_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_timer: Timer = $AnimationTimer


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_float_time = randf_range(0.0, TAU)
	sprite.frame = IDLE_FRAME
	animation_timer.wait_time = animation_interval


func _process(delta: float) -> void:
	if not _is_active:
		_update_floating(delta)
		_check_enemies_at_position()
		return
	_process_sweeping(delta)


func _update_floating(delta: float) -> void:
	_float_time += delta
	if _float_time > MAX_FLOAT_CYCLE:
		_float_time -= MAX_FLOAT_CYCLE
	var offset_x: float = sin(_float_time * float_frequency_x) * float_amplitude_x
	var offset_y: float = cos(_float_time * float_frequency_y) * float_amplitude_y
	sprite.position = Vector2(offset_x, offset_y)


func _process_sweeping(delta: float) -> void:
	position.x += speed * delta
	_sweep_lane()
	if global_position.x > EXIT_X:
		exhausted.emit(self)
		queue_free()


## Starts the Dementor's run along its lane.
func activate() -> void:
	if _is_active:
		return
	_is_active = true
	activated.emit(self)
	_start_activation_motion()
	_sweep_lane()


func _start_activation_motion() -> void:
	sprite.position = Vector2.ZERO
	animation_timer.start(animation_interval)
	var tween: Tween = create_tween()
	tween.tween_property(self, SCALE_PROPERTY, LAUNCH_SCALE, LAUNCH_DURATION)
	tween.tween_property(self, SCALE_PROPERTY, Vector2.ONE, LAUNCH_DURATION)


## Area2D collision callback. Detects an enemy making contact.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(Groups.ENEMIES):
		activate()
		_kill_enemy(area as Enemy)


## Advances the sweeping animation frame.
func _on_animation_timer_timeout() -> void:
	if _is_active:
		sprite.frame = (sprite.frame + 1) % TOTAL_FRAMES


## Activates when an enemy in the same lane reached the Dementor's position.
func _check_enemies_at_position() -> void:
	for enemy: Node2D in Lane.enemies_in_lane(get_tree(), global_position.y):
		if enemy.global_position.x <= global_position.x + TRIGGER_REACH:
			activate()
			_kill_enemy(enemy as Enemy)
			return


## Kills every enemy touching the Dementor or within SWEEP_REACH in its lane.
func _sweep_lane() -> void:
	for area: Area2D in get_overlapping_areas():
		if area.is_in_group(Groups.ENEMIES):
			_kill_enemy(area as Enemy)
	for enemy: Node2D in Lane.enemies_in_lane(get_tree(), global_position.y):
		if enemy.global_position.x <= global_position.x + SWEEP_REACH:
			_kill_enemy(enemy as Enemy)


## Kills the enemy with massive damage, guaranteeing its destruction.
func _kill_enemy(enemy: Enemy) -> void:
	if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
		enemy.take_damage(damage)
