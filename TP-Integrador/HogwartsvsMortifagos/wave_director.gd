class_name WaveDirector
extends Node

## Boss/worker pattern. The boss (this node, main thread) starts a fixed team
## of worker threads when it enters the tree and queues one WaveTask per
## request. request_plan() answers at once with a WaveFuture; a worker fills
## it later. Workers only read their own copy of the board and never touch the
## scene. The task queue they share with the main thread lives in WaveMonitor.

## Defense value at which the intermediate wave reaches its maximum size.
const DEFENSE_SCALE: float = 1000.0
const FIRST_REQUEST_ID: int = 1
const WORKER_COUNT: int = 2
const RESULT_LOG: String = "[WaveDirector] worker %d planned wave %d: %d enemies"

var _monitor: WaveMonitor = WaveMonitor.new()
var _workers: Array[Thread] = []
## Stateless, so both workers share it.
var _row_analyzer: RowThreatAnalyzer = RowThreatAnalyzer.new()
## Only the main thread touches this counter, so it needs no lock.
var _next_request_id: int = FIRST_REQUEST_ID

func _ready() -> void:
	for worker_index: int in range(WORKER_COUNT):
		var worker: Thread = Thread.new()
		worker.start(_worker_loop.bind(worker_index))
		_workers.append(worker)

func _exit_tree() -> void:
	_cancel_tasks(_monitor.shut_down(_workers.size()))
	for worker: Thread in _workers:
		worker.wait_to_finish()
	_workers.clear()

## Main thread: queues a plan request and returns its future right away. It
## never blocks and never drops a request because a worker is busy. Returns
## null once the boss has stopped.
func request_plan(snapshot: BoardSnapshot, is_final: bool) -> WaveFuture:
	if _workers.is_empty():
		return null
	var task: WaveTask = WaveTask.new(snapshot.duplicate_snapshot(), _next_request_id, is_final)
	_next_request_id += 1
	if not _monitor.submit(task):
		return null
	return task.future

## Main thread: drops queued work and cancels its futures. Running tasks
## finish on their own; their futures stay usable. Workers stay alive.
func cancel_pending() -> void:
	_cancel_tasks(_monitor.drop_pending_tasks())

func worker_count() -> int:
	return _workers.size()

## Worker thread body. Each worker owns its random generator because the
## global one is shared state and is not safe to call from several threads.
func _worker_loop(worker_index: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var task: WaveTask = _monitor.take_task()
	while task != null:
		_run_task(task, worker_index, rng)
		task = _monitor.take_task()

## Worker thread: skips cancelled work, otherwise fills the task's future.
func _run_task(task: WaveTask, worker_index: int, rng: RandomNumberGenerator) -> void:
	if task.future.is_cancelled():
		return
	var result: WaveResult = _build_result(task.snapshot, task.request_id, task.is_final, rng)
	result.worker_index = worker_index
	if task.future.complete(result) and task.snapshot.verbose_logs:
		_log_result(result)

func _cancel_tasks(tasks: Array[WaveTask]) -> void:
	for task: WaveTask in tasks:
		task.future.cancel()

func _log_result(result: WaveResult) -> void:
	if result.plan != null:
		print(RESULT_LOG % [result.worker_index, result.plan.wave_number, result.plan.enemy_count])

func _build_result(
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool,
	rng: RandomNumberGenerator
) -> WaveResult:
	var result: WaveResult = WaveResult.new()
	result.level_generation = snapshot.level_generation
	result.request_id = request_id
	if not snapshot.is_valid():
		result.error_code = WaveResult.ErrorCode.INVALID_SNAPSHOT
		return result
	var plan: WavePlan = _create_plan(snapshot, request_id, is_final, rng)
	if not plan.is_valid():
		result.error_code = WaveResult.ErrorCode.INVALID_PLAN
		return result
	result.plan = plan
	return result

func _create_plan(
	snapshot: BoardSnapshot,
	request_id: int,
	is_final: bool,
	rng: RandomNumberGenerator
) -> WavePlan:
	var plan: WavePlan = WavePlan.new()
	_fill_plan_identity(plan, snapshot, request_id, is_final)
	_fill_plan_counts(plan, snapshot, is_final, rng)
	_fill_plan_rows(plan, snapshot)
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

## Wave worker thread: rows and their spawn weights from the parallel analysis.
func _fill_plan_rows(plan: WavePlan, snapshot: BoardSnapshot) -> void:
	plan.row_indices = snapshot.row_indices.duplicate()
	plan.row_weights = _row_analyzer.analyze(snapshot)

func _fill_plan_counts(
	plan: WavePlan,
	snapshot: BoardSnapshot,
	is_final: bool,
	rng: RandomNumberGenerator
) -> void:
	plan.enemy_count = _calculate_enemy_count(snapshot, is_final, rng)
	plan.reference_intermediate_count = snapshot.intermediate_wave_size
	plan.intermediate_wave_min = snapshot.intermediate_wave_min
	plan.intermediate_wave_max = snapshot.intermediate_wave_max
	plan.final_wave_min = snapshot.final_wave_min

func _calculate_enemy_count(
	snapshot: BoardSnapshot,
	is_final: bool,
	rng: RandomNumberGenerator
) -> int:
	if is_final:
		return _final_enemy_count(snapshot, rng)
	return _intermediate_enemy_count(snapshot)

func _final_enemy_count(snapshot: BoardSnapshot, rng: RandomNumberGenerator) -> int:
	var bonus: int = rng.randi_range(snapshot.final_wave_bonus_min, snapshot.final_wave_bonus_max)
	var scaled: int = snapshot.intermediate_wave_size + bonus
	return maxi(snapshot.final_wave_min, scaled)

func _intermediate_enemy_count(snapshot: BoardSnapshot) -> int:
	var pressure: float = clampf(snapshot.defense_value / DEFENSE_SCALE, 0.0, 1.0)
	var span: int = snapshot.intermediate_wave_max - snapshot.intermediate_wave_min
	var count: int = snapshot.intermediate_wave_min + roundi(pressure * float(span))
	return clampi(count, snapshot.intermediate_wave_min, snapshot.intermediate_wave_max)
