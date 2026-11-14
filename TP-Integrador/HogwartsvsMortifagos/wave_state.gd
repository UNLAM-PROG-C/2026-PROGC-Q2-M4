class_name WaveState
extends RefCounted

enum Value
{
	SPAWNING_NORMAL,
	WAVE_PREPARATION,
	WAVE_ACTIVE,
	WAITING_FOR_CLEAR,
	FINAL_WAVE_PREPARATION,
	LEVEL_COMPLETE
}

static var _transitions: Dictionary[Value, Array] = {
	Value.SPAWNING_NORMAL: [Value.WAVE_PREPARATION, Value.FINAL_WAVE_PREPARATION] as Array[Value],
	Value.WAVE_PREPARATION: [Value.WAVE_ACTIVE] as Array[Value],
	Value.WAVE_ACTIVE: [Value.WAITING_FOR_CLEAR] as Array[Value],
	Value.WAITING_FOR_CLEAR: [Value.SPAWNING_NORMAL, Value.FINAL_WAVE_PREPARATION, Value.LEVEL_COMPLETE] as Array[Value],
	Value.FINAL_WAVE_PREPARATION: [Value.WAVE_ACTIVE] as Array[Value],
	Value.LEVEL_COMPLETE: [] as Array[Value]
}

static func is_valid(value: Value) -> bool:
	return value >= Value.SPAWNING_NORMAL and value <= Value.LEVEL_COMPLETE

static func can_transition(from: Value, to: Value) -> bool:
	if not is_valid(from) or not is_valid(to):
		return false
	var allowed: Array[Value] = _transitions[from]
	return to in allowed
