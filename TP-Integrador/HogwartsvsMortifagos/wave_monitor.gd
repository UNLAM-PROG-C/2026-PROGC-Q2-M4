class_name WaveMonitor
extends RefCounted

## Monitor that owns the state shared between the main thread and the wave
## worker threads: the task queue and the shutdown flag. Results do not travel
## through here; each task carries its own WaveFuture.
##
## Producer-consumer: the main thread produces WaveTask objects with submit()
## and the workers consume them with take_task(). The semaphore counts the
## tasks waiting in the queue, so an idle worker sleeps instead of spinning.
##
## Monitor rules:
## - The shared state is private. Nothing outside this class reads or writes it.
## - The public methods are the only entry points. Each one takes the lock on
##   entry and releases it before returning, so at most one thread is inside the
##   monitor at any time (mutual exclusion).
## - A method never returns while holding the lock and never calls code outside
##   the monitor while holding it.
## - A worker waits on the semaphore with the lock released. Waiting while
##   holding the lock would block submit() forever (deadlock).

var _lock: Mutex = Mutex.new()
var _tasks_available: Semaphore = Semaphore.new()
var _tasks: Array[WaveTask] = []
var _shutting_down: bool = false

## Producer: queues a task and wakes one sleeping worker. Returns false once
## the monitor is shutting down.
func submit(task: WaveTask) -> bool:
	_lock.lock()
	var accepted: bool = not _shutting_down
	if accepted:
		_tasks.append(task)
	_lock.unlock()
	if accepted:
		_tasks_available.post()
	return accepted

## Worker thread (consumer): sleeps until there is a task. Returns null only
## when the monitor is shutting down, which tells the worker to exit.
func take_task() -> WaveTask:
	var task: WaveTask = null
	while task == null and not is_shutting_down():
		_tasks_available.wait()
		task = _pop_task()
	return task

## Main thread: removes and returns the tasks no worker has started yet.
func drop_pending_tasks() -> Array[WaveTask]:
	_lock.lock()
	var dropped: Array[WaveTask] = _tasks.duplicate()
	_tasks.clear()
	_lock.unlock()
	return dropped

## Main thread: stops accepting work and wakes every worker so it can exit.
## Returns the tasks that were still queued.
func shut_down(worker_count: int) -> Array[WaveTask]:
	_lock.lock()
	_shutting_down = true
	var dropped: Array[WaveTask] = _tasks.duplicate()
	_tasks.clear()
	_lock.unlock()
	_tasks_available.post(worker_count)
	return dropped

## Any thread: true once shut_down() was called.
func is_shutting_down() -> bool:
	_lock.lock()
	var stopping: bool = _shutting_down
	_lock.unlock()
	return stopping

## Any thread: number of tasks waiting for a worker.
func pending_task_count() -> int:
	_lock.lock()
	var count: int = _tasks.size()
	_lock.unlock()
	return count

func _pop_task() -> WaveTask:
	_lock.lock()
	var task: WaveTask = null
	if not _shutting_down and not _tasks.is_empty():
		task = _tasks.pop_front()
	_lock.unlock()
	return task
