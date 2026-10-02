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
