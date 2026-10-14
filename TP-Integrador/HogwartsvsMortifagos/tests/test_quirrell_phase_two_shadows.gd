extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const QUIRRELL_SCENE_PATH: String = "res://quirrell.tscn"
const LEVEL_10_SCENE_PATH: String = "res://level_10.tscn"


func _initialize() -> void:
  print("--- Running Test Quirrell Phase Two Shadows ---")
  _run_all_tests()


func _run_all_tests() -> void:
  await _test_quirrell_invocation_intervals()
  await _test_quirrell_shadow_signals_per_phase()
  await _test_level_10_single_shadow_aligns_to_single_row()
  await _test_level_10_mass_shadows_in_all_rows()
  print("--- All Quirrell Phase Two Shadows Tests Passed Successfully! ---")
  quit(EXIT_OK)



func _test_quirrell_invocation_intervals() -> void:
  var scene: PackedScene = load(QUIRRELL_SCENE_PATH) as PackedScene
  var boss: Quirrell = scene.instantiate() as Quirrell
  root.add_child(boss)
  await process_frame
  assert(boss.current_phase == 1, "Initial phase 1")
  assert(boss.invocation_timer.wait_time == Quirrell.INVOCATION_INTERVAL_PHASE_1, "Phase 1 interval")
  boss.take_damage(Quirrell.BOSS_MAX_HEALTH * 0.5)
  assert(boss.current_phase == 2, "Transitioned to phase 2")
  assert(boss.invocation_timer.wait_time == Quirrell.INVOCATION_INTERVAL_PHASE_2, "Phase 2 interval")
  assert(Quirrell.INVOCATION_INTERVAL_PHASE_2 < Quirrell.INVOCATION_INTERVAL_PHASE_1, "Phase 2 faster")
  boss.queue_free()
  await process_frame


func _test_quirrell_shadow_signals_per_phase() -> void:
  var scene: PackedScene = load(QUIRRELL_SCENE_PATH) as PackedScene
  var boss: Quirrell = scene.instantiate() as Quirrell
  root.add_child(boss)
  await process_frame
  var counts: Array[int] = [0, 0]
  boss.shadow_spawn_requested.connect(func(_p: Vector2, _y: float) -> void: counts[0] += 1)
  boss.mass_shadow_spawn_requested.connect(func() -> void: counts[1] += 1)
  boss._on_invocation_timer_timeout()
  assert(counts[0] == 1 and counts[1] == 0, "Phase 1 must spawn single shadow")
  boss.take_damage(Quirrell.BOSS_MAX_HEALTH * 0.5)
  boss._on_invocation_timer_timeout()
  assert(counts[0] == 1 and counts[1] == 1, "Phase 2 must spawn mass shadows in all rows")
  boss.queue_free()
  await process_frame


func _test_level_10_single_shadow_aligns_to_single_row() -> void:
  var scene: PackedScene = load(LEVEL_10_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  level_node.call("_on_boss_single_shadow_spawn_requested", Vector2(1700, 531), 531.0)
  var shadows: Array[Node] = root.get_tree().get_nodes_in_group("enemies").filter(func(e: Node) -> bool: return e is ShadowEnemy)
  assert(shadows.size() == 1, "Should spawn one shadow")
  var se: ShadowEnemy = shadows[0] as ShadowEnemy
  var y4: float = level_node.call("_get_row_center_y", 4) as float
  var y3: float = level_node.call("_get_row_center_y", 3) as float
  assert(is_equal_approx(se.global_position.y, y4) or is_equal_approx(se.global_position.y, y3), "Shadow must align to row 3 or row 4")
  assert(not is_equal_approx(se.global_position.y, 531.0), "Shadow must NOT spawn in middle (531.0)")
  level_node.queue_free()
  await process_frame


func _test_level_10_mass_shadows_in_all_rows() -> void:
  var scene: PackedScene = load(LEVEL_10_SCENE_PATH) as PackedScene
  var level_node: Level = scene.instantiate() as Level
  root.add_child(level_node)
  await process_frame
  level_node.call("_on_boss_mass_shadow_spawn_requested")
  var shadows: Array[Node] = root.get_tree().get_nodes_in_group("enemies").filter(func(e: Node) -> bool: return e is ShadowEnemy)
  assert(shadows.size() == level_node.active_rows.size(), "Should spawn one shadow per active row")
  _assert_shadow_rows_distribution(shadows, level_node)
  level_node.queue_free()
  await process_frame


func _assert_shadow_rows_distribution(shadows: Array[Node], level_node: Level) -> void:
  var spawned_ys: Array[float] = []
  for s: Node in shadows:
    var se: ShadowEnemy = s as ShadowEnemy
    spawned_ys.append(se.global_position.y)
  for row_idx: int in level_node.active_rows:
    var expected_y: float = level_node.call("_get_row_center_y", row_idx) as float
    var found: bool = false
    for y: float in spawned_ys:
      if is_equal_approx(y, expected_y):
        found = true
        break
    assert(found, "Shadow MUST be spawned in active row " + str(row_idx) + " at y " + str(expected_y))
