class_name WaveDirector
extends Node

const INTERMEDIATE_MIN_COUNT: int = 10
const INTERMEDIATE_MAX_COUNT: int = 20
const FINAL_MIN_COUNT: int = 25
const FINAL_BONUS_MIN: int = 5
const FINAL_BONUS_MAX: int = 10
## Defense value at which the intermediate wave reaches its maximum size.
const DEFENSE_SCALE: float = 1000.0
const NO_REQUEST: int = 0

signal result_ready(result: WaveResult)

var _mutex: Mutex = Mutex.new()
var _thread: Thread = null
var _results: Array[WaveResult] = []
var _cancel_requested: bool = false
var _level_generation: int = 0
var _next_request_id: int = 1
var _active_request_id: int = 0

func request_plan(snapshot: BoardSnapshot, is_final: bool) -> int:
	if _thread != null and _thread.is_started():
		return NO_REQUEST
	var request_id: int = _reserve_request(snapshot.level_generation)
	var copied_snapshot: BoardSnapshot = snapshot.duplicate_snapshot()
	_thread = Thread.new()
	_thread.start(_calculate_plan.bind(copied_snapshot, request_id, is_final))
	return request_id

func poll_results() -> void:
	var pending: Array[WaveResult] = _take_results()
	for result: WaveResult in pending:
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
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool
) -> void:
	var result: WaveResult = _build_result(snapshot, request_id, is_final)
	_mutex.lock()
	if _cancel_requested or snapshot.level_generation != _level_generation:
		result.cancelled = true
		result.error_code = WaveResult.ErrorCode.CANCELLED
	_results.append(result)
	_mutex.unlock()

func _build_result(
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool
) -> WaveResult:
	var result: WaveResult = WaveResult.new()
	result.level_generation = snapshot.level_generation
	result.request_id = request_id
	if not snapshot.is_valid():
		result.error_code = WaveResult.ErrorCode.INVALID_SNAPSHOT
		return result
	var plan: WavePlan = _create_plan(snapshot, request_id, is_final)
	if not plan.is_valid():
		result.error_code = WaveResult.ErrorCode.INVALID_PLAN
		return result
	result.plan = plan
	return result

func _create_plan(
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool
) -> WavePlan:
	var plan: WavePlan = WavePlan.new()
	_fill_plan_identity(plan, snapshot, request_id, is_final)
	_fill_plan_counts(plan, snapshot, is_final)
	return plan

func _fill_plan_identity(
	plan: WavePlan,
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool
) -> void:
	plan.level_generation = snapshot.level_generation
	plan.request_id = request_id
	plan.wave_number = snapshot.threshold_index + 1
	plan.is_final = is_final
	plan.spawn_delay = WavePlan.DEFAULT_SPAWN_DELAY
	plan.row_indices = snapshot.row_indices.duplicate()

func _fill_plan_counts(plan: WavePlan, snapshot: BoardSnapshot, is_final: bool) -> void:
	plan.enemy_count = _calculate_enemy_count(snapshot, is_final)
	plan.reference_intermediate_count = snapshot.intermediate_wave_size
	plan.intermediate_wave_min = snapshot.intermediate_wave_min
	plan.intermediate_wave_max = snapshot.intermediate_wave_max
	plan.final_wave_min = snapshot.final_wave_min

func _calculate_enemy_count(snapshot: BoardSnapshot, is_final: bool) -> int:
	if is_final:
		return _final_enemy_count(snapshot)
	return _intermediate_enemy_count(snapshot)

func _final_enemy_count(snapshot: BoardSnapshot) -> int:
	var bonus: int = randi_range(snapshot.final_wave_bonus_min, snapshot.final_wave_bonus_max)
	var scaled: int = snapshot.intermediate_wave_size + bonus
	return maxi(snapshot.final_wave_min, scaled)

func _intermediate_enemy_count(snapshot: BoardSnapshot) -> int:
	var pressure: float = clampf(snapshot.defense_value / DEFENSE_SCALE, 0.0, 1.0)
	var span: int = snapshot.intermediate_wave_max - snapshot.intermediate_wave_min
	var count: int = snapshot.intermediate_wave_min + roundi(pressure * float(span))
	return clampi(count, snapshot.intermediate_wave_min, snapshot.intermediate_wave_max)

func _take_results() -> Array[WaveResult]:
	_mutex.lock()
	var pending: Array[WaveResult] = _results.duplicate()
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
