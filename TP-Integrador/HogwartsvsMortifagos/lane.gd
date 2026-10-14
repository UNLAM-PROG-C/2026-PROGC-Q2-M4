class_name Lane
extends RefCounted

## Helpers for entities that act on a whole lane (grid row).

## Maximum vertical distance for two positions to share a lane.
const LANE_TOLERANCE: float = 64.0


static func is_same_lane(a_y: float, b_y: float) -> bool:
	return absf(a_y - b_y) < LANE_TOLERANCE


static func is_enemy_in_lane(enemy: Node2D, lane_y: float) -> bool:
	if enemy.has_method(&"occupies_lane_y"):
		return enemy.call(&"occupies_lane_y", lane_y)
	return is_same_lane(enemy.global_position.y, lane_y)


## Valid enemies whose lane matches lane_y.
static func enemies_in_lane(tree: SceneTree, lane_y: float) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for enemy: Node in tree.get_nodes_in_group(Groups.ENEMIES):
		if enemy is Node2D and is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			if is_enemy_in_lane(enemy as Node2D, lane_y):
				result.append(enemy as Node2D)
	return result


## Valid allies whose lane matches lane_y and are positioned ahead (to the left) of from_x.
static func has_allies_in_lane_ahead(tree: SceneTree, lane_y: float, from_x: float) -> bool:
	for ally: Node in tree.get_nodes_in_group(Groups.ALLIES):
		if ally is Broomstick:
			continue
		if ally is Node2D and is_instance_valid(ally):
			var pos: Vector2 = (ally as Node2D).global_position
			if is_same_lane(pos.y, lane_y) and pos.x < from_x:
				return true
	return false


const ROW_SPACING: float = 160.0
const FIRST_ROW_Y: float = 272.0
const ROW_COUNT: int = 5
const Z_STEP_PER_ROW: int = 200
const REGULAR_ENEMY_Z_BASE: int = 10
const TROLL_Z_BASE: int = 30
const TROLL_SLOT_STEP: int = 10


const ALLY_Z_BASE: int = 5
const PROJECTILE_Z_BASE: int = 150
const SNITCH_Z_INDEX: int = 1000


static func get_row_index_from_y(y: float) -> int:
	var raw_index: int = int(roundf((y - FIRST_ROW_Y) / ROW_SPACING))
	return clampi(raw_index, 0, ROW_COUNT - 1)


static func get_enemy_z_index_for_row(row_idx: int, is_troll: bool = false) -> int:
	var clamped_row: int = clampi(row_idx, 0, ROW_COUNT - 1)
	var base_offset: int = TROLL_Z_BASE if is_troll else REGULAR_ENEMY_Z_BASE
	return (clamped_row * Z_STEP_PER_ROW) + base_offset


static func get_troll_z_index_for_row_and_slot(row_idx: int, slot: int) -> int:
	var clamped_row: int = clampi(row_idx, 0, ROW_COUNT - 1)
	var base: int = (clamped_row * Z_STEP_PER_ROW) + TROLL_Z_BASE
	return base + (slot * TROLL_SLOT_STEP)


static func get_enemy_z_index(y: float, is_troll: bool = false) -> int:
	return get_enemy_z_index_for_row(get_row_index_from_y(y), is_troll)


static func get_projectile_z_index_for_row(row_idx: int) -> int:
	var clamped_row: int = clampi(row_idx, 0, ROW_COUNT - 1)
	return (clamped_row * Z_STEP_PER_ROW) + PROJECTILE_Z_BASE


static func get_projectile_z_index(y: float) -> int:
	return get_projectile_z_index_for_row(get_row_index_from_y(y))


static func get_ally_z_index_for_row(row_idx: int) -> int:
	var clamped_row: int = clampi(row_idx, 0, ROW_COUNT - 1)
	return (clamped_row * Z_STEP_PER_ROW) + ALLY_Z_BASE


static func get_ally_z_index(y: float) -> int:
	return get_ally_z_index_for_row(get_row_index_from_y(y))


static func get_snitch_z_index() -> int:
	return SNITCH_Z_INDEX


static func get_trolls_in_lane(tree: SceneTree, lane_y: float) -> Array[Node2D]:
	var trolls: Array[Node2D] = []
	for enemy: Node in tree.get_nodes_in_group(Groups.ENEMIES):
		if enemy is Troll and is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			if is_same_lane((enemy as Node2D).global_position.y, lane_y):
				trolls.append(enemy as Node2D)
	return trolls


static func _compare_troll_positions(a: Node2D, b: Node2D) -> bool:
	if is_equal_approx(a.global_position.x, b.global_position.x):
		return a.get_instance_id() < b.get_instance_id()
	return a.global_position.x < b.global_position.x


static func update_trolls_z_index_in_lane(tree: SceneTree, lane_y: float) -> void:
	var trolls: Array[Node2D] = get_trolls_in_lane(tree, lane_y)
	if trolls.is_empty():
		return
	trolls.sort_custom(_compare_troll_positions)
	var row_idx: int = get_row_index_from_y(lane_y)
	for i: int in range(trolls.size()):
		var slot: int = trolls.size() - 1 - i
		trolls[i].z_index = get_troll_z_index_for_row_and_slot(row_idx, slot)

