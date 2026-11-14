extends SceneTree

const EXIT_OK: int = 0
const FIRST_REGULAR_LEVEL: int = 1
const LAST_REGULAR_LEVEL: int = 9
const BOSS_LEVEL_PATH: String = "res://level_10.tscn"
const LEVEL_PATH_TEMPLATE: String = "res://level_%d.tscn"


func _initialize() -> void:
	print("--- Running Level Kill Budget Tests ---")
	_run_tests()


func _run_tests() -> void:
	for level_number: int in range(FIRST_REGULAR_LEVEL, LAST_REGULAR_LEVEL + 1):
		await _test_regular_level(LEVEL_PATH_TEMPLATE % level_number)
	await _test_boss_level()
	print("--- All Level Kill Budget Tests Passed ---")
	quit(EXIT_OK)


func _test_regular_level(path: String) -> void:
	var lvl: Level = await _load_level(path)
	var quota_sum: int = _sum_thresholds(lvl)
	assert(quota_sum > 0, "%s must declare wave kill quotas" % path)
	assert(lvl.get("_total_level_kills") == quota_sum, "%s total kills must be the quota sum" % path)
	assert(lvl.get("total_enemies") == null, "%s must not expose total_enemies" % path)
	await _dispose(lvl)


func _test_boss_level() -> void:
	var lvl: Level = await _load_level(BOSS_LEVEL_PATH)
	assert(lvl.is_boss_level, "Level 10 must be the boss level")
	assert(_sum_thresholds(lvl) == 0, "The boss level has no wave quotas")
	await _dispose(lvl)


func _load_level(path: String) -> Level:
	var scene: PackedScene = load(path)
	var lvl: Level = scene.instantiate() as Level
	root.add_child(lvl)
	await process_frame
	return lvl


func _sum_thresholds(lvl: Level) -> int:
	var total: int = 0
	for threshold: int in lvl.wave_kill_thresholds:
		total += threshold
	return total


func _dispose(lvl: Level) -> void:
	lvl.queue_free()
	await process_frame
