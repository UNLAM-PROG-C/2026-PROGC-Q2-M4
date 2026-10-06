class_name Lane
extends RefCounted

## Helpers for entities that act on a whole lane (grid row).

## Maximum vertical distance for two positions to share a lane.
const LANE_TOLERANCE: float = 64.0


static func is_same_lane(a_y: float, b_y: float) -> bool:
	return absf(a_y - b_y) < LANE_TOLERANCE


## Valid enemies whose lane matches lane_y.
static func enemies_in_lane(tree: SceneTree, lane_y: float) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for enemy: Node in tree.get_nodes_in_group(Groups.ENEMIES):
		if enemy is Node2D and is_instance_valid(enemy) and is_same_lane((enemy as Node2D).global_position.y, lane_y):
			result.append(enemy as Node2D)
	return result


## Valid allies whose lane matches lane_y and are positioned ahead (to the left) of from_x.
static func has_allies_in_lane_ahead(tree: SceneTree, lane_y: float, from_x: float) -> bool:
	for ally: Node in tree.get_nodes_in_group(Groups.ALLIES):
		if ally is Node2D and is_instance_valid(ally):
			var pos: Vector2 = (ally as Node2D).global_position
			if is_same_lane(pos.y, lane_y) and pos.x < from_x:
				return true
	return false
