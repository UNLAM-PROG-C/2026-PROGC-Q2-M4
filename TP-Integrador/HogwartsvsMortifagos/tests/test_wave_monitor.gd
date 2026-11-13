extends SceneTree

const EXIT_OK: int = 0
const PRODUCER_COUNT: int = 4
const SUBMITS_PER_PRODUCER: int = 250
const FIRST_REQUEST_ID: int = 1
const SECOND_REQUEST_ID: int = 2
const SINGLE_WORKER: int = 1


func _initialize() -> void:
	print("--- Running Wave Monitor Tests ---")
	_test_tasks_are_taken_in_order()
	_test_drop_returns_pending_tasks()
	_test_shutdown_releases_a_sleeping_worker()
	_test_shutdown_rejects_new_tasks()
	_test_concurrent_producers_lose_nothing()
	print("--- All Wave Monitor Tests Passed ---")
	quit(EXIT_OK)


func _test_tasks_are_taken_in_order() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.submit(_task(FIRST_REQUEST_ID))
	monitor.submit(_task(SECOND_REQUEST_ID))
	assert(monitor.take_task().request_id == FIRST_REQUEST_ID, "The queue is first in, first out")
	assert(monitor.take_task().request_id == SECOND_REQUEST_ID, "The second task comes next")
	assert(monitor.pending_task_count() == 0, "Taken tasks leave the queue")


func _test_drop_returns_pending_tasks() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.submit(_task(FIRST_REQUEST_ID))
	assert(monitor.drop_pending_tasks().size() == 1, "Dropping returns the queued task")
	assert(monitor.pending_task_count() == 0, "Dropped tasks leave the queue")


## A worker blocked in take_task() must wake up and exit on shutdown.
func _test_shutdown_releases_a_sleeping_worker() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	var worker: Thread = Thread.new()
	worker.start(monitor.take_task)
	monitor.shut_down(SINGLE_WORKER)
	var task: WaveTask = worker.wait_to_finish()
	assert(task == null, "A worker woken by shutdown receives no task")


func _test_shutdown_rejects_new_tasks() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	monitor.shut_down(SINGLE_WORKER)
	assert(not monitor.submit(_task(FIRST_REQUEST_ID)), "A stopped monitor rejects tasks")


## Several threads submit at the same time. If the monitor did not give
## mutual exclusion, appends would overwrite each other and tasks would be lost.
func _test_concurrent_producers_lose_nothing() -> void:
	var monitor: WaveMonitor = WaveMonitor.new()
	var producers: Array[Thread] = []
	for _i: int in range(PRODUCER_COUNT):
		var producer: Thread = Thread.new()
		producer.start(_submit_many.bind(monitor))
		producers.append(producer)
	for producer: Thread in producers:
		producer.wait_to_finish()
	var queued: int = monitor.pending_task_count()
	assert(queued == PRODUCER_COUNT * SUBMITS_PER_PRODUCER, "No task is lost under concurrent producers")


func _submit_many(monitor: WaveMonitor) -> void:
	for _i: int in range(SUBMITS_PER_PRODUCER):
		monitor.submit(_task(FIRST_REQUEST_ID))


func _task(request_id: int) -> WaveTask:
	return WaveTask.new(BoardSnapshot.new(), request_id, false)
