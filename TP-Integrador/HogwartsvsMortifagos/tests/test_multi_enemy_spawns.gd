extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const LEVEL_1_SCENE_PATH: String = "res://level_1.tscn"
const LEVEL_10_SCENE_PATH: String = "res://level_10.tscn"
const SAMPLE_SIZE: int = 20000
const WAIT_MULTI_SPAWN_FINISH: float = 0.060


func _initialize() -> void:
  print("--- Running Test Multi Enemy Spawns ---")
  _run_all_tests()


func _run_all_tests() -> void:
  await _test_spawn_count_probabilities()
  await _test_multi_spawn_delay_values()
  await _test_regular_spawns_increase_counts_level_1()
  await _test_regular_spawns_increase_counts_level_10()
  print("--- All Multi Enemy Spawns Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _test_spawn_count_probabilities() -> void:
  var scene: PackedScene = load(LEVEL_1_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  var counts: Dictionary = {1: 0, 2: 0, 3: 0}
  for i: int in range(SAMPLE_SIZE):
    var c: int = level_node.call(&"_determine_enemy_spawn_count") as int
    counts[c] = counts.get(c, 0) + 1
  _assert_distribution(counts)
  level_node.queue_free()
  await process_frame


func _assert_distribution(counts: Dictionary) -> void:
  var p3: float = float(counts[3]) / float(SAMPLE_SIZE)
  var p2: float = float(counts[2]) / float(SAMPLE_SIZE)
  var p1: float = float(counts[1]) / float(SAMPLE_SIZE)
  assert(p3 >= 0.08 and p3 <= 0.12, "Triple spawn chance ~ 0.10: got " + str(p3))
  assert(p2 >= 0.22 and p2 <= 0.28, "Double spawn chance ~ 0.25: got " + str(p2))
  assert(p1 >= 0.62 and p1 <= 0.68, "Single spawn chance ~ 0.65: got " + str(p1))


func _test_multi_spawn_delay_values() -> void:
  var scene: PackedScene = load(LEVEL_1_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  var t0: float = Time.get_ticks_msec()
  await level_node.call(&"_wait_for_multi_spawn_delay", 1)
  var elapsed_1: float = Time.get_ticks_msec() - t0
  assert(elapsed_1 >= 8.0, "Second spawn delayed by ~10ms: got " + str(elapsed_1))
  var t1: float = Time.get_ticks_msec()
  await level_node.call(&"_wait_for_multi_spawn_delay", 2)
  var elapsed_2: float = Time.get_ticks_msec() - t1
  assert(elapsed_2 >= 25.0, "Third spawn delayed by ~30ms: got " + str(elapsed_2))
  level_node.queue_free()
  await process_frame


func _test_regular_spawns_increase_counts_level_1() -> void:
  var scene: PackedScene = load(LEVEL_1_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  var before_spawned: int = level_node._spawned_enemies
  var before_active: int = level_node._active_enemies
  await level_node.call(&"_spawn_regular_enemies")
  await create_timer(WAIT_MULTI_SPAWN_FINISH).timeout
  var spawned_delta: int = level_node._spawned_enemies - before_spawned
  var active_delta: int = level_node._active_enemies - before_active
  assert(spawned_delta >= 1 and spawned_delta <= 3, "Level 1 spawned 1 to 3 enemies")
  assert(spawned_delta == active_delta, "Active enemies matches spawned count")
  level_node.queue_free()
  await process_frame


func _test_regular_spawns_increase_counts_level_10() -> void:
  var scene: PackedScene = load(LEVEL_10_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  var before_spawned: int = level_node._spawned_enemies
  var before_active: int = level_node._active_enemies
  await level_node.call(&"_spawn_regular_enemies")
  await create_timer(WAIT_MULTI_SPAWN_FINISH).timeout
  var spawned_delta: int = level_node._spawned_enemies - before_spawned
  var active_delta: int = level_node._active_enemies - before_active
  assert(spawned_delta >= 1 and spawned_delta <= 3, "Level 10 spawned 1 to 3 enemies")
  assert(spawned_delta == active_delta, "Active enemies matches spawned count")
  level_node.queue_free()
  await process_frame
