class_name WaveTask
extends RefCounted

## One unit of work for a wave worker: a private copy of the board and the
## request it answers. Workers only read this object, never the scene.

var snapshot: BoardSnapshot = null
var request_id: int = 0
var is_final: bool = false

func _init(task_snapshot: BoardSnapshot, task_request_id: int, task_is_final: bool) -> void:
	snapshot = task_snapshot
	request_id = task_request_id
	is_final = task_is_final
