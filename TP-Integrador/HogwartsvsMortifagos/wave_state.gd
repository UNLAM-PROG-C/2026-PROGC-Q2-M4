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

static func is_valid(value: Value) -> bool:
	return value >= Value.SPAWNING_NORMAL and value <= Value.LEVEL_COMPLETE

static func can_transition(from: Value, to: Value) -> bool:
	if not is_valid(from) or not is_valid(to):
		return false
	var transitions: Dictionary[Value, Array] = {
		Value.SPAWNING_NORMAL: [
			Value.WAVE_PREPARATION,
			Value.FINAL_WAVE_PREPARATION
		],
		Value.WAVE_PREPARATION: [Value.WAVE_ACTIVE],
		Value.WAVE_ACTIVE: [Value.WAITING_FOR_CLEAR],
		Value.WAITING_FOR_CLEAR: [
			Value.SPAWNING_NORMAL,
			Value.FINAL_WAVE_PREPARATION,
			Value.LEVEL_COMPLETE
		],
		Value.FINAL_WAVE_PREPARATION: [Value.WAVE_ACTIVE],
		Value.LEVEL_COMPLETE: []
	}
	return to in transitions[from]
