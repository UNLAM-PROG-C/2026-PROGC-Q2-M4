class_name Broomstick
extends Ally

## Sweeps across the lane dealing massive area damage to all enemies.

const DEFAULT_SPEED: float = 600.0
const DEFAULT_SWEEP_DAMAGE: float = 1800.0
const EXIT_X: float = 1950.0
const SWEEP_REACH: float = 50.0
const INVULNERABLE_HEALTH: float = 9999.0

@export var speed: float = DEFAULT_SPEED
@export var sweep_damage: float = DEFAULT_SWEEP_DAMAGE
@export var end_x: float = EXIT_X

var _damaged_enemies: Dictionary[int, bool] = {}


func _ready() -> void:
	health = INVULNERABLE_HEALTH
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	global_position.x += speed * delta
	_sweep_lane()
	if global_position.x >= end_x:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	_try_damage_area(area)


func _sweep_lane() -> void:
	for area: Area2D in get_overlapping_areas():
		_try_damage_area(area)
	_sweep_lane_enemies()


func _sweep_lane_enemies() -> void:
	for enemy: Node2D in Lane.enemies_in_lane(get_tree(), global_position.y):
		if enemy.global_position.x <= global_position.x + SWEEP_REACH:
			_try_damage_node(enemy)


func _try_damage_area(area: Area2D) -> void:
	if area != null and area.is_in_group(Groups.ENEMIES):
		_try_damage_node(area)


func _try_damage_node(enemy_node: Node2D) -> void:
	if not is_instance_valid(enemy_node) or enemy_node.is_queued_for_deletion():
		return
	var enemy_id: int = enemy_node.get_instance_id()
	if _damaged_enemies.has(enemy_id):
		return
	_damaged_enemies[enemy_id] = true
	if enemy_node.has_method("take_damage"):
		enemy_node.call("take_damage", sweep_damage)
