extends SceneTree

const EXIT_OK: int = 0
const LEVEL_GENERATION: int = 1
const BURST_REQUESTS: int = 20
const MAX_WAIT_FRAMES: int = 300
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
	await _test_back_to_back_requests_are_not_dropped(director)
	await _test_burst_is_fully_delivered(director)
	await _test_workers_survive_cancel(director)
	_test_shutdown_joins_workers(director)
	print("--- All Wave Worker Tests Passed ---")
	quit(EXIT_OK)


func _test_back_to_back_requests_are_not_dropped(director: WaveDirector) -> void:
	var first: int = director.request_plan(_snapshot(), false)
	var second: int = director.request_plan(_snapshot(), true)
	assert(first != WaveDirector.NO_REQUEST and second != WaveDirector.NO_REQUEST, "No request is rejected")
	var results: Array[WaveResult] = await _collect(director, 2)
	assert(results.size() == 2, "Both queued requests are answered")


func _test_burst_is_fully_delivered(director: WaveDirector) -> void:
	for _i: int in range(BURST_REQUESTS):
		director.request_plan(_snapshot(), false)
	var results: Array[WaveResult] = await _collect(director, BURST_REQUESTS)
	assert(results.size() == BURST_REQUESTS, "Every queued task produces a result")
	for result: WaveResult in results:
		assert(result.worker_index >= 0 and result.worker_index < WaveDirector.WORKER_COUNT, "A known worker did the work")
		assert(result.is_success(), "Each burst result carries a valid plan")


func _test_workers_survive_cancel(director: WaveDirector) -> void:
	director.cancel_and_wait()
	director.request_plan(_snapshot(), false)
	var results: Array[WaveResult] = await _collect(director, 1)
	assert(results.size() == 1 and results[0].is_success(), "Workers keep serving after a cancel")


func _test_shutdown_joins_workers(director: WaveDirector) -> void:
	root.remove_child(director)
	assert(director.worker_count() == 0, "Leaving the tree joins every worker")
	assert(director.request_plan(_snapshot(), false) == WaveDirector.NO_REQUEST, "A stopped boss rejects requests")
	director.free()


func _collect(director: WaveDirector, expected: int) -> Array[WaveResult]:
	var results: Array[WaveResult] = []
	var on_result: Callable = func(result: WaveResult) -> void: results.append(result)
	director.result_ready.connect(on_result)
	var frames: int = 0
	while results.size() < expected and frames < MAX_WAIT_FRAMES:
		director.poll_results()
		await process_frame
		frames += 1
	director.result_ready.disconnect(on_result)
	return results


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
