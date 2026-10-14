extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const SAMPLE_COUNT: int = 100


func _initialize() -> void:
	print("--- Running Test Level 9 Troll Delay ---")
	_run_tests()


func _run_tests() -> void:
	var scene: PackedScene = load("res://level_9.tscn")
	assert(scene != null, "Failed to load level_9.tscn")
	var level_node: Level = scene.instantiate() as Level
	root.add_child(level_node)
	await process_frame

	_test_initial_state(level_node)
	_test_before_first_wave(level_node)
	_test_after_first_wave(level_node)

	level_node.queue_free()
	await process_frame
	print("--- All Level 9 Troll Delay Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_initial_state(level_node: Level) -> void:
	assert(level_node.troll_delay_waves == 1, "troll_delay_waves should be 1")
	assert(not level_node.call("_are_trolls_allowed"), "Trolls should NOT be allowed initially")


func _test_before_first_wave(level_node: Level) -> void:
	for i: int in range(SAMPLE_COUNT):
		var picked: PackedScene = level_node.call("_pick_random_enemy_scene") as PackedScene
		assert(picked != null, "Picked scene should not be null")
		var is_troll: bool = level_node.call("_is_troll_scene", picked)
		assert(not is_troll, "Troll was picked before wave 1 completed!")


func _test_after_first_wave(level_node: Level) -> void:
	level_node.set("_completed_waves", 1)
	assert(level_node.call("_are_trolls_allowed"), "Trolls SHOULD be allowed after wave 1")

	var troll_picked: bool = false
	for i: int in range(SAMPLE_COUNT):
		var picked: PackedScene = level_node.call("_pick_random_enemy_scene") as PackedScene
		if level_node.call("_is_troll_scene", picked):
			troll_picked = true
			break
	assert(troll_picked, "Troll should be picked at least once in 100 samples when allowed")
