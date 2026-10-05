class_name BoardSnapshot
extends RefCounted

var level_generation: int = 0
var state: int = 0
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
