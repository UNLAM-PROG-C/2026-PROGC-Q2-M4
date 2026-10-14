extends SceneTree

const BOSS_SCENE_PATH: String = "res://boss_health_bar.tscn"
const LEVEL_10_SCENE_PATH: String = "res://level_10.tscn"
const EXPECTED_FILL_MODE_BOTTOM_TO_TOP: int = 3
const EXPECTED_INITIAL_MAX_HP: float = 36000.0
const TEST_DAMAGE_HP: float = 18000.0
const EXPECTED_LABEL_INITIAL: String = "36000 / 36000"
const EXPECTED_LABEL_DAMAGED: String = "18000 / 36000"
const EXPECTED_X_POS: float = 25.0
const EXPECTED_Y_POS: float = 280.0


func _init() -> void:
  _run_tests_async()


func _run_tests_async() -> void:
  var success: bool = await _run_all_tests()
  quit(0 if success else 1)


func _run_all_tests() -> bool:
  if not await _test_boss_health_bar_scene():
    return false
  if not await _test_level_10_boss_health_bar_position():
    return false
  print("All boss health bar vertical tests passed successfully!")
  return true


func _test_boss_health_bar_scene() -> bool:
  var scene: PackedScene = load(BOSS_SCENE_PATH) as PackedScene
  if scene == null:
    printerr("Failed to load boss_health_bar.tscn")
    return false
  var bar: BossHealthBar = scene.instantiate() as BossHealthBar
  root.add_child(bar)
  await process_frame
  var ok: bool = _verify_bar_components(bar)
  bar.queue_free()
  return ok


func _verify_bar_components(bar: BossHealthBar) -> bool:
  if bar.progress_bar == null or bar.progress_bar.fill_mode != EXPECTED_FILL_MODE_BOTTOM_TO_TOP:
    printerr("ProgressBar fill_mode is not bottom-to-top (3)")
    return false
  if bar.health_label == null or bar.health_label.text != EXPECTED_LABEL_INITIAL:
    printerr("Initial health label text mismatch: ", bar.health_label.text)
    return false
  bar.set_health(TEST_DAMAGE_HP)
  if bar.progress_bar.value != TEST_DAMAGE_HP or bar.health_label.text != EXPECTED_LABEL_DAMAGED:
    printerr("Damaged health text/value mismatch: ", bar.health_label.text)
    return false
  return true


func _test_level_10_boss_health_bar_position() -> bool:
  var lvl_scene: PackedScene = load(LEVEL_10_SCENE_PATH) as PackedScene
  if lvl_scene == null:
    printerr("Failed to load level_10.tscn")
    return false
  var lvl: Node = lvl_scene.instantiate()
  root.add_child(lvl)
  await process_frame
  var bar: Control = lvl.get_node_or_null("HUD/BossHealthBar") as Control
  if bar == null:
    printerr("BossHealthBar not found in HUD of level_10")
    lvl.queue_free()
    return false
  var pos_ok: bool = _verify_position(bar.position)
  lvl.queue_free()
  return pos_ok


func _verify_position(pos: Vector2) -> bool:
  if not is_equal_approx(pos.x, EXPECTED_X_POS) or not is_equal_approx(pos.y, EXPECTED_Y_POS):
    printerr("BossHealthBar position mismatch: got ", pos, " expected (", EXPECTED_X_POS, ", ", EXPECTED_Y_POS, ")")
    return false
  return true
