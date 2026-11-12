class_name BoardSnapshot
extends RefCounted

var level_generation: int = 0
var state: WaveState.Value = WaveState.Value.SPAWNING_NORMAL
var regular_defeated: int = 0
var regular_budget: int = 1
var active_enemies: int = 0
var defense_value: float = 0.0
var is_special_level: bool = false
var threshold_index: int = 0
var intermediate_wave_size: int = 10
var intermediate_wave_min: int = 10
var intermediate_wave_max: int = 20
var final_wave_min: int = 25
var final_wave_bonus_min: int = 5
var final_wave_bonus_max: int = 10
var row_indices: Array[int] = []

func is_valid() -> bool:
	return (
		level_generation >= 0
		and regular_budget > 0
		and regular_defeated >= 0
		and regular_defeated <= regular_budget
		and active_enemies >= 0
		and defense_value >= 0.0
		and not row_indices.is_empty()
	)

func duplicate_snapshot() -> BoardSnapshot:
	var copy: BoardSnapshot = BoardSnapshot.new()
	_copy_progress_onto(copy)
	_copy_wave_params_onto(copy)
	return copy

func _copy_progress_onto(copy: BoardSnapshot) -> void:
	copy.level_generation = level_generation
	copy.state = state
	copy.regular_defeated = regular_defeated
	copy.regular_budget = regular_budget
	copy.active_enemies = active_enemies
	copy.defense_value = defense_value
	copy.is_special_level = is_special_level
	copy.threshold_index = threshold_index

func _copy_wave_params_onto(copy: BoardSnapshot) -> void:
	copy.intermediate_wave_size = intermediate_wave_size
	copy.intermediate_wave_min = intermediate_wave_min
	copy.intermediate_wave_max = intermediate_wave_max
	copy.final_wave_min = final_wave_min
	copy.final_wave_bonus_min = final_wave_bonus_min
	copy.final_wave_bonus_max = final_wave_bonus_max
	copy.row_indices = row_indices.duplicate()
