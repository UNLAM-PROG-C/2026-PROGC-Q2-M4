class_name WaveMonitor
extends RefCounted

## Monitor that owns every piece of state shared between the main thread and
## the wave worker thread: the result queue, the cancel flag, the current level
## generation and the request counter.
##
## Monitor rules:
## - The shared state is private. Nothing outside this class reads or writes it.
## - The public methods are the only entry points. Each one takes the lock on
##   entry and releases it before returning, so at most one thread is inside the
##   monitor at any time (mutual exclusion).
## - A method never returns while holding the lock and never calls code outside
##   the monitor while holding it.

const FIRST_REQUEST_ID: int = 1

var _lock: Mutex = Mutex.new()
var _results: Array[WaveResult] = []
var _cancel_requested: bool = false
var _level_generation: int = 0
var _next_request_id: int = FIRST_REQUEST_ID

## Main thread: opens a new request for a level generation and returns its id.
func reserve_request(generation: int) -> int:
	_lock.lock()
	_level_generation = generation
	_cancel_requested = false
	var request_id: int = _next_request_id
	_next_request_id += 1
	_lock.unlock()
	return request_id

## Worker thread: delivers a finished result. The cancel check and the append
## happen in the same critical section, so a cancel cannot slip in between.
func publish(result: WaveResult) -> void:
	_lock.lock()
	if _cancel_requested or result.level_generation != _level_generation:
		result.cancelled = true
		result.error_code = WaveResult.ErrorCode.CANCELLED
	_results.append(result)
	_lock.unlock()

## Main thread: removes and returns every pending result.
func take_results() -> Array[WaveResult]:
	_lock.lock()
	var pending: Array[WaveResult] = _results.duplicate()
	_results.clear()
	_lock.unlock()
	return pending

## Main thread: asks the running calculation to be discarded.
func request_cancel() -> void:
	_lock.lock()
	_cancel_requested = true
	_lock.unlock()

## Main thread: drops results nobody will read (level restart or exit).
func clear_results() -> void:
	_lock.lock()
	_results.clear()
	_lock.unlock()

## Any thread: true while a cancel is pending.
func is_cancel_requested() -> bool:
	_lock.lock()
	var cancelled: bool = _cancel_requested
	_lock.unlock()
	return cancelled
