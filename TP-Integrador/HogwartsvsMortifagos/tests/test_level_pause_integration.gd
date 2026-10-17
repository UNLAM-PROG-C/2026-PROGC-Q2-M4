extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const LEVEL_1_PATH: String = "res://level_1.tscn"
const LEVEL_10_PATH: String = "res://level_10.tscn"
const PauseMenu = preload("res://pause_menu.gd")


func _initialize() -> void:
  print("--- Running Test Level Pause Integration ---")
  _run_tests()


func _run_tests() -> void:
  await _test_level_1_pause_integration()
  await _test_level_10_pause_integration()
  await _test_level_stop_disables_pause()
  print("--- All Level Pause Integration Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _test_level_1_pause_integration() -> void:
  var scene: PackedScene = load(LEVEL_1_PATH) as PackedScene
  assert(scene != null, "level_1.tscn must load")
  var level: Node2D = scene.instantiate() as Node2D
  root.add_child(level)
  await process_frame
  var menu: PauseMenu = level.get("_pause_menu") as PauseMenu
  _assert_level_pause_button(menu)
  _test_level_pause_toggle(menu)
  level.queue_free()
  await process_frame


func _assert_level_pause_button(menu: PauseMenu) -> void:
  assert(menu != null, "Level 1 must instantiate PauseMenu in HUD")
  assert(menu.pause_button != null, "Pause button must exist in HUD")
  assert(menu.pause_button.text == "| |", "Pause button symbol must be | |")
  assert(menu.pause_button.visible, "Pause button must be visible during gameplay")
  assert(not menu.is_paused(), "Level 1 must start unpaused")
  assert(not paused, "SceneTree must not be paused initially")


func _test_level_pause_toggle(menu: PauseMenu) -> void:
  menu.pause()
  assert(paused, "Pausing menu must pause scene tree")
  assert(menu.modal_overlay.visible, "Modal overlay must be visible when paused")
  menu.resume()
  assert(not paused, "Resuming menu must unpause scene tree")
  assert(not menu.modal_overlay.visible, "Modal overlay must be hidden on resume")


func _test_level_10_pause_integration() -> void:
  var scene: PackedScene = load(LEVEL_10_PATH) as PackedScene
  assert(scene != null, "level_10.tscn must load")
  var level: Node2D = scene.instantiate() as Node2D
  root.add_child(level)
  await process_frame
  var menu: PauseMenu = level.get("_pause_menu") as PauseMenu
  assert(menu != null, "Level 10 must instantiate PauseMenu in HUD")
  assert(menu.pause_button.visible, "Level 10 pause button must be visible")
  level.queue_free()
  await process_frame


func _test_level_stop_disables_pause() -> void:
  var scene: PackedScene = load(LEVEL_1_PATH) as PackedScene
  var level: Node2D = scene.instantiate() as Node2D
  root.add_child(level)
  await process_frame
  var menu: PauseMenu = level.get("_pause_menu") as PauseMenu
  level.call("_stop_level")
  assert(not menu.is_enabled(), "Stopping level must disable pause menu")
  assert(not menu.pause_button.visible, "Pause button must be hidden when level stops")
  level.queue_free()
  await process_frame
