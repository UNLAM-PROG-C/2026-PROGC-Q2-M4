class_name Dementor
extends Area2D

## Emitted when the Dementor activates and starts sweeping its lane.
signal activated(entity: Node2D)
## Emitted when the Dementor finishes sweeping the lane and is destroyed.
signal exhausted(entity: Node2D)

## Forward speed once active, in pixels per second.
@export var speed: float = 800.0
## Massive damage dealt to enemies in its lane (instant kill).
@export var damage: int = 9999

var _is_active: bool = false


func _ready() -> void:
	add_to_group("dementors")
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if not _is_active:
		# Fallback check: an enemy in the same lane reached the Dementor
		_check_enemies_at_position()
		return

	# Move right sweeping the lane
	position.x += speed * delta

	# Kill every enemy it collides with or reaches in its lane
	_sweep_lane()

	# Free itself once past the right edge of the screen
	if global_position.x > 1450.0:
		exhausted.emit(self)
		queue_free()


## Starts the Dementor's run along its lane.
func activate() -> void:
	if _is_active:
		return
	_is_active = true
	activated.emit(self)

	# Quick launch animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Clear enemies already touching it
	_sweep_lane()


## Area2D collision callback. Detects an enemy making contact.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if not _is_active:
			activate()
		_kill_enemy(area)


## Checks whether an enemy in the same lane reached the Dementor's position.
func _check_enemies_at_position() -> void:
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D and is_instance_valid(enemy):
			var enemy_position: Vector2 = (enemy as Node2D).global_position
			# Same horizontal lane
			if absf(enemy_position.y - global_position.y) < 64.0:
				# Reached or passed the Dementor's X position
				if enemy_position.x <= global_position.x + 40.0:
					activate()
					_kill_enemy(enemy as Node2D)
					break


## Sweeps and kills every enemy in the lane within the Dementor's reach.
func _sweep_lane() -> void:
	# 1. Direct collisions detected by the Area2D
	for area: Area2D in get_overlapping_areas():
		if area.is_in_group("enemies"):
			_kill_enemy(area)

	# 2. Enemies in the same lane reached by the sweep
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D and is_instance_valid(enemy):
			var enemy_position: Vector2 = (enemy as Node2D).global_position
			if absf(enemy_position.y - global_position.y) < 64.0:
				if enemy_position.x <= global_position.x + 60.0:
					_kill_enemy(enemy as Node2D)


## Kills the enemy with massive damage, guaranteeing its destruction.
func _kill_enemy(entity: Node2D) -> void:
	if not is_instance_valid(entity) or entity.is_queued_for_deletion():
		return
	if entity.has_method("take_damage"):
		entity.call("take_damage", damage)
	else:
		entity.queue_free()
