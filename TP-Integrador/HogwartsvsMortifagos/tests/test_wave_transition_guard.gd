extends SceneTree

const EXIT_OK: int = 0


func _initialize() -> void:
	print("--- Running Wave Transition Guard Tests ---")
	_run_tests()


func _run_tests() -> void:
	var scene: PackedScene = load("res://level_1.tscn")
	var lvl: Level = scene.instantiate() as Level
	root.add_child(lvl)
	await process_frame
	_test_transition_table()
	_test_invalid_transition_is_rejected(lvl)
	lvl.queue_free()
	await process_frame
	print("--- All Wave Transition Guard Tests Passed ---")
	quit(EXIT_OK)


func _test_transition_table() -> void:
	var normal: WaveState.Value = WaveState.Value.SPAWNING_NORMAL
	assert(not WaveState.can_transition(normal, WaveState.Value.WAVE_ACTIVE), "Normal spawn cannot jump to an active wave")
	assert(WaveState.can_transition(normal, WaveState.Value.WAVE_PREPARATION), "Normal spawn can prepare a wave")


func _test_invalid_transition_is_rejected(lvl: Level) -> void:
	assert(lvl.get("_wave_state") == WaveState.Value.SPAWNING_NORMAL, "A level starts in normal spawn")
	lvl.call("_enter_wave_state", WaveState.Value.WAVE_ACTIVE)
	assert(lvl.get("_wave_state") == WaveState.Value.SPAWNING_NORMAL, "A rejected transition keeps the state")
