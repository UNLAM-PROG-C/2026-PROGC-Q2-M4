extends SceneTree

const EXIT_OK: int = 0
const LEVEL_GENERATION: int = 1
const BURST_REQUESTS: int = 20
const WAIT_TIMEOUT_MS: int = 2000
const ACTIVE_ROW: int = 2
const BUDGET: int = 10


func _initialize() -> void:
	print("--- Running Wave Worker Tests ---")
	_run_tests()


func _run_tests() -> void:
	var director: WaveDirector = WaveDirector.new()
	root.add_child(director)
	await process_frame
	assert(director.worker_count() == WaveDirector.WORKER_COUNT, "The boss starts its worker team")
	_test_back_to_back_requests_are_not_dropped(director)
	_test_burst_is_fully_delivered(director)
	_test_workers_survive_cancel(director)
	_test_shutdown_joins_workers(director)
	print("--- All Wave Worker Tests Passed ---")
	quit(EXIT_OK)


func _test_back_to_back_requests_are_not_dropped(director: WaveDirector) -> void:
	var first: WaveFuture = director.request_plan(_snapshot(), false)
	var second: WaveFuture = director.request_plan(_snapshot(), true)
	assert(first != null and second != null, "No request is rejected")
	assert(first.wait_for(WAIT_TIMEOUT_MS) and second.wait_for(WAIT_TIMEOUT_MS), "Both queued requests finish")
	assert(first.get_result().is_success() and second.get_result().is_success(), "Both requests get a plan")
	assert(second.get_result().plan.is_final, "Each future holds the answer to its own request")


func _test_burst_is_fully_delivered(director: WaveDirector) -> void:
	var futures: Array[WaveFuture] = []
	for _i: int in range(BURST_REQUESTS):
		futures.append(director.request_plan(_snapshot(), false))
	for future: WaveFuture in futures:
		assert(future.wait_for(WAIT_TIMEOUT_MS), "Every queued task finishes")
		var result: WaveResult = future.get_result()
		assert(result.is_success(), "Each burst result carries a valid plan")
		assert(result.worker_index >= 0 and result.worker_index < WaveDirector.WORKER_COUNT, "A known worker did the work")


func _test_workers_survive_cancel(director: WaveDirector) -> void:
	director.cancel_pending()
	var future: WaveFuture = director.request_plan(_snapshot(), false)
	assert(future.wait_for(WAIT_TIMEOUT_MS) and future.get_result().is_success(), "Workers keep serving after a cancel")


func _test_shutdown_joins_workers(director: WaveDirector) -> void:
	root.remove_child(director)
	assert(director.worker_count() == 0, "Leaving the tree joins every worker")
	assert(director.request_plan(_snapshot(), false) == null, "A stopped boss rejects requests")
	director.free()


func _snapshot() -> BoardSnapshot:
	var snapshot: BoardSnapshot = BoardSnapshot.new()
	snapshot.level_generation = LEVEL_GENERATION
	snapshot.regular_budget = BUDGET
	snapshot.intermediate_wave_min = WaveDirector.INTERMEDIATE_MIN_COUNT
	snapshot.intermediate_wave_max = WaveDirector.INTERMEDIATE_MAX_COUNT
	snapshot.final_wave_min = WaveDirector.FINAL_MIN_COUNT
	snapshot.final_wave_bonus_min = WaveDirector.FINAL_BONUS_MIN
	snapshot.final_wave_bonus_max = WaveDirector.FINAL_BONUS_MAX
	snapshot.row_indices = [ACTIVE_ROW] as Array[int]
	return snapshot
