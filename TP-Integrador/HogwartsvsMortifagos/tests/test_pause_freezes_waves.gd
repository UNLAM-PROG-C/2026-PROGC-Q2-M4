extends SceneTree

const EXIT_OK: int = 0
const LEVEL_PATH: String = "res://level_1.tscn"
const WAVE_SIZE: int = 3
const SPAWN_DELAY: float = 0.05
## Real time waited while paused: several spawn delays.
const PAUSED_WAIT: float = 0.4
const RESUMED_WAIT: float = 0.4
const TEST_TIMER_RUNS_WHILE_PAUSED: bool = true
const ACTIVE_ROW: int = 4


func _initialize() -> void:
	print("--- Running Pause Freezes Waves Tests ---")
	_run_tests()


func _run_tests() -> void:
	var lvl: Level = (load(LEVEL_PATH) as PackedScene).instantiate() as Level
	root.add_child(lvl)
	await process_frame
	lvl.enemy_spawn_timer.stop()
	lvl.set("_wave_state", WaveState.Value.WAVE_ACTIVE)
	await _test_wave_waits_for_resume(lvl)
	lvl.queue_free()
	await process_frame
	print("--- All Pause Freezes Waves Tests Passed ---")
	quit(EXIT_OK)


func _test_wave_waits_for_resume(lvl: Level) -> void:
	var before: int = lvl.get("_active_enemies")
	paused = true
	lvl.call("_spawn_wave_enemies", _plan())
	await create_timer(PAUSED_WAIT, TEST_TIMER_RUNS_WHILE_PAUSED).timeout
	assert(lvl.get("_active_enemies") == before + 1, "Only the first wave enemy appears while paused")
	paused = false
	await create_timer(RESUMED_WAIT).timeout
	assert(lvl.get("_active_enemies") == before + WAVE_SIZE, "The rest of the wave arrives after resuming")


func _plan() -> WavePlan:
	var plan: WavePlan = WavePlan.new()
	plan.enemy_count = WAVE_SIZE
	plan.spawn_delay = SPAWN_DELAY
	plan.row_indices = [ACTIVE_ROW] as Array[int]
	return plan
