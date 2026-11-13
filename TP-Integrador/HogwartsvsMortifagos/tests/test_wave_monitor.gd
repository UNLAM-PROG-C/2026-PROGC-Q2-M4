extends SceneTree

const EXIT_OK: int = 0
const LEVEL_GENERATION: int = 7
const OTHER_GENERATION: int = 8
const WORKER_COUNT: int = 4
const PUBLISHES_PER_WORKER: int = 250


func _initialize() -> void:
	print("--- Running Wave Monitor Tests ---")
	_test_request_ids_are_unique()
	_test_results_are_taken_once()
	_test_cancel_marks_results()
	_test_old_generation_is_cancelled()
	_test_concurrent_publishers_lose_nothing()
	print("--- All Wave Monitor Tests Passed ---")
	quit(EXIT_OK)


func _test_request_ids_are_unique() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	var first: int = monitor.reserve_request(LEVEL_GENERATION)
	var second: int = monitor.reserve_request(LEVEL_GENERATION)
	assert(first != second, "Each request gets its own id")
	assert(second == first + 1, "Request ids grow by one")


func _test_results_are_taken_once() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.reserve_request(LEVEL_GENERATION)
	monitor.publish(_result(LEVEL_GENERATION))
	assert(monitor.take_results().size() == 1, "A published result is delivered")
	assert(monitor.take_results().is_empty(), "A result is delivered only once")


func _test_cancel_marks_results() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.reserve_request(LEVEL_GENERATION)
	monitor.request_cancel()
	assert(monitor.is_cancel_requested(), "Cancel is visible through the monitor")
	monitor.publish(_result(LEVEL_GENERATION))
	var result: WaveResult = monitor.take_results()[0]
	assert(result.cancelled, "A result published after cancel is marked cancelled")
	assert(result.error_code == WaveResult.ErrorCode.CANCELLED, "Cancelled result uses the CANCELLED code")


func _test_old_generation_is_cancelled() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.reserve_request(OTHER_GENERATION)
	monitor.publish(_result(LEVEL_GENERATION))
	assert(monitor.take_results()[0].cancelled, "A result from an old level generation is discarded")


## Several threads publish at the same time. If the monitor did not give
## mutual exclusion, appends would overwrite each other and results would be lost.
func _test_concurrent_publishers_lose_nothing() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.reserve_request(LEVEL_GENERATION)
	var workers: Array[Thread] = []
	for _i: int in range(WORKER_COUNT):
		var worker: Thread = Thread.new()
		worker.start(_publish_many.bind(monitor))
		workers.append(worker)
	for worker: Thread in workers:
		worker.wait_to_finish()
	var delivered: int = monitor.take_results().size()
	assert(delivered == WORKER_COUNT * PUBLISHES_PER_WORKER, "No result is lost under concurrent publishers")


func _publish_many(monitor: WaveMonitor) -> void:
	for _i: int in range(PUBLISHES_PER_WORKER):
		monitor.publish(_result(LEVEL_GENERATION))


func _result(generation: int) -> WaveResult:
	var result: WaveResult = WaveResult.new()
	result.level_generation = generation
	return result
