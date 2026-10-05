class_name WavePlan
extends RefCounted

const INTERMEDIATE_MIN_COUNT: int = 10
const INTERMEDIATE_MAX_COUNT: int = 20
const FINAL_MIN_COUNT: int = 25

var level_generation: int = 0
var request_id: int = 0
var wave_number: int = 0
var enemy_count: int = 0
var reference_intermediate_count: int = INTERMEDIATE_MIN_COUNT
var intermediate_wave_min: int = INTERMEDIATE_MIN_COUNT
var intermediate_wave_max: int = INTERMEDIATE_MAX_COUNT
var final_wave_min: int = FINAL_MIN_COUNT
var is_final: bool = false
var spawn_delay: float = 0.0
var row_indices: Array[int] = []

func is_valid() -> bool:
	if level_generation < 0 or request_id <= 0 or wave_number <= 0:
		return false
	if spawn_delay < 0.0 or row_indices.is_empty():
		return false
	if is_final:
		return enemy_count >= final_wave_min and enemy_count > reference_intermediate_count
	return enemy_count >= intermediate_wave_min and enemy_count <= intermediate_wave_max
