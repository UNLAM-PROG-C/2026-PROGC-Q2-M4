extends SceneTree

const EXIT_OK: int = 0
const WAIT_TIMEOUT_MS: int = 2000
const SHORT_TIMEOUT_MS: int = 50
const WORKER_DELAY_MS: int = 30
const FIRST_GENERATION: int = 1
const SECOND_GENERATION: int = 2


func _initialize() -> void:
	print("--- Running Wave Future Tests ---")
	_test_worker_completes_and_waiter_wakes()
	_test_wait_times_out_without_result()
	_test_second_complete_is_ignored()
	_test_cancel_wakes_waiter()
	_test_complete_after_cancel_is_dropped()
	print("--- All Wave Future Tests Passed ---")
	quit(EXIT_OK)


func _test_worker_completes_and_waiter_wakes() -> void:
	var future: WaveFuture = WaveFuture.new()
	assert(not future.is_done(), "A new future is pending")
	var worker: Thread = Thread.new()
	worker.start(_complete_later.bind(future))
	assert(future.wait_for(WAIT_TIMEOUT_MS), "The waiter wakes when the worker completes")
	worker.wait_to_finish()
	assert(future.is_done(), "The future is done after complete")
	assert(future.get_result().level_generation == FIRST_GENERATION, "The waiter reads the worker's result")


func _test_wait_times_out_without_result() -> void:
	var future: WaveFuture = WaveFuture.new()
	var started: int = Time.get_ticks_msec()
	assert(not future.wait_for(SHORT_TIMEOUT_MS), "Waiting on a pending future times out")
	assert(Time.get_ticks_msec() - started < WAIT_TIMEOUT_MS, "A timed wait never hangs")
	assert(future.get_result() == null, "A pending future has no result")


func _test_second_complete_is_ignored() -> void:
	var future: WaveFuture = WaveFuture.new()
	assert(future.complete(_result(FIRST_GENERATION)), "The first complete is accepted")
	assert(not future.complete(_result(SECOND_GENERATION)), "A second complete is rejected")
	assert(future.get_result().level_generation == FIRST_GENERATION, "The first result stays")


func _test_cancel_wakes_waiter() -> void:
	var future: WaveFuture = WaveFuture.new()
	future.cancel()
	assert(future.wait_for(SHORT_TIMEOUT_MS), "Cancel releases a waiter immediately")
	assert(future.is_done() and future.is_cancelled(), "A cancelled future is done and cancelled")
	assert(future.get_result() == null, "A cancelled future has no result")


func _test_complete_after_cancel_is_dropped() -> void:
	var future: WaveFuture = WaveFuture.new()
	future.cancel()
	assert(not future.complete(_result(FIRST_GENERATION)), "A late result is dropped after cancel")
	assert(future.get_result() == null, "A late result is never visible")


func _complete_later(future: WaveFuture) -> void:
	OS.delay_msec(WORKER_DELAY_MS)
	future.complete(_result(FIRST_GENERATION))


func _result(generation: int) -> WaveResult:
	var result: WaveResult = WaveResult.new()
	result.level_generation = generation
	return result
