extends SceneTree

## Runs every res://tests/test_*.gd in its own Godot process and exits with 1
## if any of them fails, so a CI job or a shell loop can trust the exit code.
##
## A failed assert() in a headless run only prints "SCRIPT ERROR" and lets the
## script keep going, so each child exits with 0 even when it failed. The
## runner reads every child's output through a pipe and marks the test as
## failed when that text appears, when the child exits with an error, or when
## it does not finish in time.
##
## Usage: godot --headless --path . --script res://tools/run_tests.gd

const TESTS_DIR: String = "res://tests/"
const TEST_PREFIX: String = "test_"
const SCRIPT_EXTENSION: String = ".gd"
const FAILURE_MARKERS: PackedStringArray = ["SCRIPT ERROR", "Parse Error"]
const TEST_TIMEOUT_MS: int = 60000
const POLL_STEP_MS: int = 20
const EXIT_OK: int = 0
const EXIT_FAILED: int = 1
const PASS_LINE: String = "PASS %s"
const FAIL_LINE: String = "FAIL %s (%s)"
const SUMMARY_LINE: String = "run_tests: %d passed, %d failed"
const REASON_MARKER: String = "assertion or script error"
const REASON_EXIT: String = "exit code %d"
const REASON_TIMEOUT: String = "timeout"


func _initialize() -> void:
	var failed: int = 0
	var tests: PackedStringArray = _find_tests()
	for test_path: String in tests:
		var reason: String = _run_test(test_path)
		if reason.is_empty():
			print(PASS_LINE % test_path)
		else:
			failed += 1
			print(FAIL_LINE % [test_path, reason])
	print(SUMMARY_LINE % [tests.size() - failed, failed])
	quit(EXIT_FAILED if failed > 0 else EXIT_OK)


func _find_tests() -> PackedStringArray:
	var tests: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(TESTS_DIR):
		if file_name.begins_with(TEST_PREFIX) and file_name.ends_with(SCRIPT_EXTENSION):
			tests.append(TESTS_DIR + file_name)
	tests.sort()
	return tests


## Returns an empty string when the test passed, otherwise the reason.
func _run_test(test_path: String) -> String:
	var args: PackedStringArray = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", test_path]
	var child: Dictionary = OS.execute_with_pipe(OS.get_executable_path(), args, false)
	var pid: int = child["pid"]
	var output: String = _collect_output(child, pid)
	if output.is_empty() and OS.is_process_running(pid):
		OS.kill(pid)
		return REASON_TIMEOUT
	return _failure_reason(output, OS.get_process_exit_code(pid))


## Reads the child's stdout and stderr until it exits. Returns an empty string
## if the child is still running when the timeout expires.
func _collect_output(child: Dictionary, pid: int) -> String:
	var stdio: FileAccess = child["stdio"]
	var stderr: FileAccess = child["stderr"]
	var output: String = ""
	var deadline: int = Time.get_ticks_msec() + TEST_TIMEOUT_MS
	while OS.is_process_running(pid):
		if Time.get_ticks_msec() >= deadline:
			return ""
		output += _drain(stdio) + _drain(stderr)
		OS.delay_msec(POLL_STEP_MS)
	return output + _drain(stdio) + _drain(stderr)


func _drain(pipe: FileAccess) -> String:
	var buffer: PackedByteArray = pipe.get_buffer(pipe.get_length())
	return buffer.get_string_from_utf8()


func _failure_reason(output: String, exit_code: int) -> String:
	for marker: String in FAILURE_MARKERS:
		if output.contains(marker):
			return REASON_MARKER
	if exit_code != EXIT_OK:
		return REASON_EXIT % exit_code
	return ""
