class_name WaveDirector
extends Node

const BOARD_SNAPSHOT_SCRIPT: Script = preload("res://board_snapshot.gd")
const WAVE_PLAN_SCRIPT: Script = preload("res://wave_plan.gd")
const WAVE_RESULT_SCRIPT: Script = preload("res://wave_result.gd")
const INTERMEDIATE_MIN_COUNT: int = 10
const INTERMEDIATE_MAX_COUNT: int = 20
const FINAL_MIN_COUNT: int = 25
const FINAL_BONUS_MIN: int = 5
const FINAL_BONUS_MAX: int = 10

signal result_ready(result: RefCounted)

var _mutex: Mutex = Mutex.new()
var _thread: Thread = null
var _results: Array[RefCounted] = []
var _cancel_requested: bool = false
var _level_generation: int = 0
var _next_request_id: int = 1
var _active_request_id: int = 0

func request_plan(snapshot: RefCounted, is_final: bool) -> int:
	if _thread != null and _thread.is_started():
		return 0
	var request_id: int = _reserve_request(snapshot.get("level_generation"))
	var copied_snapshot: RefCounted = _copy_snapshot(snapshot)
	_thread = Thread.new()
	_thread.start(_calculate_plan.bind(copied_snapshot, request_id, is_final))
	return request_id

func poll_results() -> void:
	var pending: Array[RefCounted] = _take_results()
	for result: RefCounted in pending:
		result_ready.emit(result)
	if not pending.is_empty():
		_join_thread()

func cancel_and_wait() -> void:
	_mutex.lock()
	_cancel_requested = true
	_mutex.unlock()
	_join_thread()
	_clear_results()

func _reserve_request(generation: int) -> int:
	_mutex.lock()
	_level_generation = generation
	_active_request_id = _next_request_id
	_next_request_id += 1
	_cancel_requested = false
	var request_id: int = _active_request_id
	_mutex.unlock()
	return request_id

func _calculate_plan(
	snapshot: RefCounted,
	request_id: int,
	is_final: bool
) -> void:
	var result: RefCounted = _build_result(snapshot, request_id, is_final)
	_mutex.lock()
	if _cancel_requested or snapshot.get("level_generation") != _level_generation:
		result.set("cancelled", true)
		result.set("error_code", 2)
	_results.append(result)
	_mutex.unlock()

func _build_result(
	snapshot: RefCounted,
	request_id: int,
	is_final: bool
) -> RefCounted:
	var result: RefCounted = WAVE_RESULT_SCRIPT.new()
	result.set("level_generation", snapshot.get("level_generation"))
	result.set("request_id", request_id)
	if not snapshot.call("is_valid"):
		result.set("error_code", 1)
		return result
	var plan: RefCounted = _create_plan(snapshot, request_id, is_final)
	if not plan.call("is_valid"):
		result.set("error_code", 3)
		return result
	result.set("plan", plan)
	return result

func _create_plan(
	snapshot: RefCounted,
	request_id: int,
	is_final: bool
) -> RefCounted:
	var plan: RefCounted = WAVE_PLAN_SCRIPT.new()
	plan.set("level_generation", snapshot.get("level_generation"))
	plan.set("request_id", request_id)
	plan.set("wave_number", snapshot.get("threshold_index") + 1)
	plan.set("is_final", is_final)
	plan.set("enemy_count", _calculate_enemy_count(snapshot, is_final))
	plan.set("reference_intermediate_count", snapshot.get("intermediate_wave_size"))
	plan.set("intermediate_wave_min", snapshot.get("intermediate_wave_min"))
	plan.set("intermediate_wave_max", snapshot.get("intermediate_wave_max"))
	plan.set("final_wave_min", snapshot.get("final_wave_min"))
	plan.set("spawn_delay", 0.25)
	plan.set("row_indices", snapshot.get("row_indices").duplicate())
	return plan

func _calculate_enemy_count(snapshot: RefCounted, is_final: bool) -> int:
	if is_final:
		var bonus: int = randi_range(
			snapshot.get("final_wave_bonus_min"),
			snapshot.get("final_wave_bonus_max")
		)
		return maxi(
			snapshot.get("final_wave_min"),
			snapshot.get("intermediate_wave_size") + bonus
		)
	var scaled_value: float = clampf(snapshot.get("defense_value") / 1000.0, 0.0, 1.0)
	return clampi(
		snapshot.get("intermediate_wave_min")
			+ roundi(
				scaled_value
				* (
					snapshot.get("intermediate_wave_max")
					- snapshot.get("intermediate_wave_min")
				)
			),
		snapshot.get("intermediate_wave_min"),
		snapshot.get("intermediate_wave_max")
	)

func _copy_snapshot(source: RefCounted) -> RefCounted:
	var copy: RefCounted = BOARD_SNAPSHOT_SCRIPT.new()
	copy.set("level_generation", source.get("level_generation"))
	copy.set("state", source.get("state"))
	copy.set("regular_defeated", source.get("regular_defeated"))
	copy.set("regular_budget", source.get("regular_budget"))
	copy.set("active_enemies", source.get("active_enemies"))
	copy.set("defense_value", source.get("defense_value"))
	copy.set("is_special_level", source.get("is_special_level"))
	copy.set("threshold_index", source.get("threshold_index"))
	copy.set("intermediate_wave_size", source.get("intermediate_wave_size"))
	copy.set("intermediate_wave_min", source.get("intermediate_wave_min"))
	copy.set("intermediate_wave_max", source.get("intermediate_wave_max"))
	copy.set("final_wave_min", source.get("final_wave_min"))
	copy.set("final_wave_bonus_min", source.get("final_wave_bonus_min"))
	copy.set("final_wave_bonus_max", source.get("final_wave_bonus_max"))
	copy.set("row_indices", source.get("row_indices").duplicate())
	return copy

func _take_results() -> Array[RefCounted]:
	_mutex.lock()
	var pending: Array[RefCounted] = _results.duplicate()
	_results.clear()
	_mutex.unlock()
	return pending

func _clear_results() -> void:
	_mutex.lock()
	_results.clear()
	_mutex.unlock()

func _join_thread() -> void:
	if _thread == null:
		return
	if _thread.is_started():
		_thread.wait_to_finish()
	_thread = null
