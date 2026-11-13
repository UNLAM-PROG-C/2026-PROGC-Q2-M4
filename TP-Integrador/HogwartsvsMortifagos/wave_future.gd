class_name WaveFuture
extends RefCounted

## Placeholder for a wave result that a worker thread will produce later.
## The main thread keeps the future returned by WaveDirector.request_plan()
## and asks is_done() every frame instead of blocking; the worker fills it once
## with complete(). The future is single-assignment: the first complete() or
## cancel() wins and later calls are ignored.
##
## Godot's Semaphore has no timed wait, so wait_for() polls try_wait() in short
## steps until the deadline.

const WAIT_STEP_MS: int = 2

var _lock: Mutex = Mutex.new()
var _finished: Semaphore = Semaphore.new()
var _result: WaveResult = null
var _completed: bool = false
var _cancelled: bool = false

## Worker thread: stores the result once. Returns false if the future was
## already completed or cancelled, so the caller knows the result was dropped.
func complete(result: WaveResult) -> bool:
	_lock.lock()
	var accepted: bool = not _completed and not _cancelled
	if accepted:
		_result = result
		_completed = true
	_lock.unlock()
	if accepted:
		_finished.post()
	return accepted

## Main thread: the result is no longer needed. Wakes anyone waiting.
func cancel() -> void:
	_lock.lock()
	var was_pending: bool = not _completed and not _cancelled
	_cancelled = true
	_lock.unlock()
	if was_pending:
		_finished.post()

## Any thread: true once the future was completed or cancelled. Never blocks.
func is_done() -> bool:
	_lock.lock()
	var done: bool = _completed or _cancelled
	_lock.unlock()
	return done

## Any thread: true if cancel() won before complete().
func is_cancelled() -> bool:
	_lock.lock()
	var cancelled: bool = _cancelled and not _completed
	_lock.unlock()
	return cancelled

## Main thread: the result, or null while pending or after a cancel.
func get_result() -> WaveResult:
	_lock.lock()
	var result: WaveResult = _result if _completed else null
	_lock.unlock()
	return result

## Any thread: waits at most timeout_ms for the future to finish. Returns true
## if it finished in time (completed or cancelled), false on timeout.
func wait_for(timeout_ms: int) -> bool:
	var deadline: int = Time.get_ticks_msec() + timeout_ms
	while not _finished.try_wait():
		if Time.get_ticks_msec() >= deadline:
			return is_done()
		OS.delay_msec(WAIT_STEP_MS)
	_finished.post()
	return true
