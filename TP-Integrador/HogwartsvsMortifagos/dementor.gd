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
## The Dementor frees itself past this x coordinate (right edge of the screen).
const EXIT_X: float = 1450.0

## Forward speed once active, in pixels per second.
@export var speed: float = 800.0
## Massive damage dealt to enemies in its lane (instant kill).
@export var damage: int = 9999

var _is_active: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if not _is_active:
		# Fallback check: an enemy in the same lane reached the Dementor
		_check_enemies_at_position()
		return
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
	var tween: Tween = create_tween()
	tween.tween_property(self, SCALE_PROPERTY, LAUNCH_SCALE, LAUNCH_DURATION)
	tween.tween_property(self, SCALE_PROPERTY, Vector2.ONE, LAUNCH_DURATION)
	# Clear enemies already touching it
	_sweep_lane()


## Area2D collision callback. Detects an enemy making contact.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(Groups.ENEMIES):
		activate()
		_kill_enemy(area)


## Activates when an enemy in the same lane reached the Dementor's position.
func _check_enemies_at_position() -> void:
	for enemy: Node2D in Lane.enemies_in_lane(get_tree(), global_position.y):
		if enemy.global_position.x <= global_position.x + TRIGGER_REACH:
			activate()
			_kill_enemy(enemy)
			return


## Kills every enemy touching the Dementor or within SWEEP_REACH in its lane.
func _sweep_lane() -> void:
	for area: Area2D in get_overlapping_areas():
		if area.is_in_group(Groups.ENEMIES):
			_kill_enemy(area)
	for enemy: Node2D in Lane.enemies_in_lane(get_tree(), global_position.y):
		if enemy.global_position.x <= global_position.x + SWEEP_REACH:
			_kill_enemy(enemy)


## Kills the enemy with massive damage, guaranteeing its destruction.
func _kill_enemy(entity: Node2D) -> void:
	if not is_instance_valid(entity) or entity.is_queued_for_deletion():
		return
	if entity.has_method("take_damage"):
		entity.call("take_damage", damage)
	else:
		entity.queue_free()
