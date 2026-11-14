extends SceneTree

const EXIT_OK: int = 0
const ROWS: Array[int] = [2, 3, 4]
const ALLY_HEALTH: Array[float] = [900.0, 0.0, 300.0]
const ENEMY_COUNT: Array[int] = [0, 2, 1]
const WEAKEST_INDEX: int = 1
const STRONGEST_INDEX: int = 0
const WEIGHT_SUM: float = 1.0
const PARALLEL_CALLERS: int = 2
const LEVEL_8_PATH: String = "res://level_8.tscn"
const TARGET_ROW_INDEX: int = 2
const SPAWN_SAMPLES: int = 30
const WAIT_TIMEOUT_MS: int = 2000
const LEVEL_8_FOCUS: float = 0.5
const EARLY_LEVEL_PATH: String = "res://level_3.tscn"
const SKEWED_WEIGHTS: Array[float] = [0.1, 0.7, 0.2]


func _initialize() -> void:
	print("--- Running Row Threat Tests ---")
	_run_tests()


func _run_tests() -> void:
	_test_weak_row_gets_more_weight()
	_test_equal_rows_get_equal_weight()
	_test_two_workers_analyze_at_once()
	await _test_level_maps_rows_and_follows_weights()
	await _test_early_level_keeps_even_spread()
	print("--- All Row Threat Tests Passed ---")
	quit(EXIT_OK)


func _test_weak_row_gets_more_weight() -> void:
	var weights: Array[float] = RowThreatAnalyzer.new().analyze(_snapshot(ALLY_HEALTH, ENEMY_COUNT))
	assert(weights.size() == ROWS.size(), "One weight per row")
	assert(is_equal_approx(_sum(weights), WEIGHT_SUM), "Weights add up to 1")
	assert(weights.max() == weights[WEAKEST_INDEX], "The row with no allies and most enemies weighs most")
	assert(weights.min() == weights[STRONGEST_INDEX], "The best defended row weighs least")


func _test_equal_rows_get_equal_weight() -> void:
	var health: Array[float] = [0.0, 0.0, 0.0]
	var enemies: Array[int] = [0, 0, 0]
	var weights: Array[float] = RowThreatAnalyzer.new().analyze(_snapshot(health, enemies))
	assert(is_equal_approx(weights[0], weights[ROWS.size() - 1]), "Equal rows get equal weight")


## Both wave workers share one analyzer. Two analyses at the same time must
## give the same answer as one alone.
func _test_two_workers_analyze_at_once() -> void:
	var analyzer: RowThreatAnalyzer = RowThreatAnalyzer.new()
	var expected: Array[float] = analyzer.analyze(_snapshot(ALLY_HEALTH, ENEMY_COUNT))
	var callers: Array[Thread] = []
	for _i: int in range(PARALLEL_CALLERS):
		var caller: Thread = Thread.new()
		caller.start(analyzer.analyze.bind(_snapshot(ALLY_HEALTH, ENEMY_COUNT)))
		callers.append(caller)
	for caller: Thread in callers:
		var weights: Array[float] = caller.wait_to_finish()
		assert(weights == expected, "Concurrent analyses agree")


func _test_level_maps_rows_and_follows_weights() -> void:
	var lvl: Level = (load(LEVEL_8_PATH) as PackedScene).instantiate() as Level
	root.add_child(lvl)
	await process_frame
	_test_every_row_has_its_spawn_point(lvl)
	_test_focus_blends_weights(lvl)
	_test_spawns_follow_a_single_weight(lvl)
	await _test_director_plan_has_weights(lvl)
	lvl.queue_free()
	await process_frame


func _test_every_row_has_its_spawn_point(lvl: Level) -> void:
	var seen: Dictionary[NodePath, bool] = {}
	for row: int in lvl.active_rows:
		var path: NodePath = lvl.call("_spawn_point_for_row", row)
		assert(not path.is_empty(), "Every active row has a spawn point")
		seen[path] = true
	assert(seen.size() == lvl.active_rows.size(), "Each row has its own spawn point")


func _test_focus_blends_weights(lvl: Level) -> void:
	assert(is_equal_approx(lvl.wave_row_focus, LEVEL_8_FOCUS), "Level 8 uses half focus")
	var blended: PackedFloat32Array = lvl.call("_blend_row_weights", SKEWED_WEIGHTS)
	var even_share: float = WEIGHT_SUM / float(SKEWED_WEIGHTS.size())
	var expected: float = (WEIGHT_SUM - LEVEL_8_FOCUS) * even_share + LEVEL_8_FOCUS * SKEWED_WEIGHTS[1]
	assert(is_equal_approx(blended[1], expected), "Half focus mixes the even spread and the analysis")
	assert(blended[1] < SKEWED_WEIGHTS[1], "Focus below 1 softens the weakest row")


func _test_early_level_keeps_even_spread() -> void:
	var lvl: Level = (load(EARLY_LEVEL_PATH) as PackedScene).instantiate() as Level
	root.add_child(lvl)
	await process_frame
	var blended: PackedFloat32Array = lvl.call("_blend_row_weights", SKEWED_WEIGHTS)
	assert(is_equal_approx(blended[0], blended[1]), "Early levels ignore the analysis")
	lvl.queue_free()
	await process_frame


func _test_spawns_follow_a_single_weight(lvl: Level) -> void:
	lvl.wave_row_focus = Level.FULL_ROW_FOCUS
	var plan: WavePlan = WavePlan.new()
	plan.row_indices = lvl.active_rows.duplicate()
	for index: int in range(plan.row_indices.size()):
		plan.row_weights.append(1.0 if index == TARGET_ROW_INDEX else 0.0)
	var expected: NodePath = lvl.call("_spawn_point_for_row", plan.row_indices[TARGET_ROW_INDEX])
	for _i: int in range(SPAWN_SAMPLES):
		assert(lvl.call("_pick_wave_spawn_path", plan) == expected, "All enemies use the only weighted row")


func _test_director_plan_has_weights(lvl: Level) -> void:
	var future: WaveFuture = lvl.wave_director.request_plan(lvl.call("_build_snapshot"), false)
	assert(future.wait_for(WAIT_TIMEOUT_MS), "The plan arrives")
	var plan: WavePlan = future.get_result().plan
	assert(plan.row_weights.size() == plan.row_indices.size(), "The plan carries one weight per row")
	await process_frame


func _snapshot(health: Array[float], enemies: Array[int]) -> BoardSnapshot:
	var snapshot: BoardSnapshot = BoardSnapshot.new()
	snapshot.row_indices = ROWS.duplicate()
	snapshot.row_ally_health = health.duplicate()
	snapshot.row_enemy_count = enemies.duplicate()
	return snapshot


func _sum(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total
