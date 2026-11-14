class_name WaveTask
extends RefCounted

## One unit of work for a wave worker: a private copy of the board, the request
## it answers and the future where the worker leaves the result. Workers only
## read the snapshot, never the scene.

var snapshot: BoardSnapshot = null
var request_id: int = 0
var is_final: bool = false
var future: WaveFuture = WaveFuture.new()

func _init(task_snapshot: BoardSnapshot, task_request_id: int, task_is_final: bool) -> void:
	snapshot = task_snapshot
	request_id = task_request_id
	is_final = task_is_final
