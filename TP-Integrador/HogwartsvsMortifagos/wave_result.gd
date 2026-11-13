class_name WaveResult
extends RefCounted

enum ErrorCode
{
	NONE,
	INVALID_SNAPSHOT,
	CANCELLED,
	INVALID_PLAN
}

var plan: WavePlan = null
var level_generation: int = 0
var request_id: int = 0
var cancelled: bool = false
var error_code: ErrorCode = ErrorCode.NONE
## Index of the worker thread that calculated this result.
var worker_index: int = -1

func is_success() -> bool:
	return not cancelled and error_code == ErrorCode.NONE and plan != null
