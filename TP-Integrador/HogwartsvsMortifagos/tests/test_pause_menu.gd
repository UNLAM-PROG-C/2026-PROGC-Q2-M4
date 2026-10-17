extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const PAUSE_MENU_PATH: String = "res://pause_menu.tscn"
const PauseMenu = preload("res://pause_menu.gd")


func _initialize() -> void:
  print("--- Running Test Pause Menu ---")
  _run_tests()


func _run_tests() -> void:
  await _test_initial_state()
  await _test_pause_and_resume_toggle()
  await _test_escape_key_toggle()
  await _test_button_signals()
  await _test_enabled_toggle()
  await _test_volume_slider()
  print("--- All Pause Menu Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _test_initial_state() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  assert(scene != null, "pause_menu.tscn must load")
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  _assert_menu_buttons_text(menu)
  _assert_menu_initial_visibility(menu)
  menu.queue_free()
  await process_frame


func _assert_menu_buttons_text(menu: PauseMenu) -> void:
  assert(menu.pause_button != null, "Pause button must exist")
  assert(menu.pause_button.text == "| |", "Pause button must display | | symbol")
  assert(menu.resume_button != null, "Resume button must exist")
  assert(menu.resume_button.text == "Reanudar", "Resume button text mismatch")
  assert(menu.retry_button != null, "Retry button must exist")
  assert(menu.retry_button.text == "Reiniciar nivel", "Retry button text mismatch")
  assert(menu.back_to_map_button != null, "Back to map button must exist")
  assert(menu.back_to_map_button.text == "Volver al Mapa", "Back button text mismatch")


func _assert_menu_initial_visibility(menu: PauseMenu) -> void:
  assert(not menu.is_paused(), "Initial state should not be paused")
  assert(menu.is_enabled(), "Initial state should be enabled")
  assert(not menu.modal_overlay.visible, "Modal overlay must be hidden initially")


func _test_pause_and_resume_toggle() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  menu.pause()
  assert(menu.is_paused(), "Menu should report paused")
  assert(paused, "SceneTree should be paused")
  assert(menu.modal_overlay.visible, "Modal overlay should be visible when paused")
  menu.resume()
  assert(not menu.is_paused(), "Menu should report unpaused")
  assert(not paused, "SceneTree should be unpaused")
  assert(not menu.modal_overlay.visible, "Modal overlay should be hidden when resumed")
  menu.queue_free()
  await process_frame


func _test_escape_key_toggle() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  var esc_event: InputEventKey = InputEventKey.new()
  esc_event.pressed = true
  esc_event.keycode = KEY_ESCAPE
  menu._unhandled_input(esc_event)
  assert(menu.is_paused(), "Escape key should pause the game")
  assert(paused, "SceneTree must be paused on Escape")
  menu._unhandled_input(esc_event)
  assert(not menu.is_paused(), "Escape key should unpause the game")
  assert(not paused, "SceneTree must be unpaused on second Escape")
  menu.queue_free()
  await process_frame


func _test_button_signals() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  _test_resume_and_retry_clicks(menu)
  _test_back_to_map_click(menu)
  menu.queue_free()
  await process_frame


func _test_resume_and_retry_clicks(menu: PauseMenu) -> void:
  var retry_emitted: Array[bool] = [false]
  menu.retry_requested.connect(func() -> void: retry_emitted[0] = true)
  menu.pause()
  menu.resume_button.emit_signal("pressed")
  assert(not menu.is_paused(), "Resume button should unpause")
  menu.pause()
  menu.retry_button.emit_signal("pressed")
  assert(retry_emitted[0], "Retry signal should be emitted")
  assert(not paused, "Retry button must unpause scene tree")


func _test_back_to_map_click(menu: PauseMenu) -> void:
  var back_emitted: Array[bool] = [false]
  menu.back_to_map_requested.connect(func() -> void: back_emitted[0] = true)
  menu.pause()
  menu.back_to_map_button.emit_signal("pressed")
  assert(back_emitted[0], "Back to map signal should be emitted")
  assert(not paused, "Back button must unpause scene tree")


func _test_enabled_toggle() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  menu.pause()
  menu.set_enabled(false)
  _assert_disabled_menu_state(menu)
  menu.queue_free()
  await process_frame


func _assert_disabled_menu_state(menu: PauseMenu) -> void:
  assert(not menu.is_paused(), "Disabling menu should resume game")
  assert(not paused, "SceneTree must be unpaused when disabled")
  assert(not menu.pause_button.visible, "Pause button should be invisible when disabled")
  var esc_event: InputEventKey = InputEventKey.new()
  esc_event.pressed = true
  esc_event.keycode = KEY_ESCAPE
  menu._unhandled_input(esc_event)
  assert(not menu.is_paused(), "Disabled menu should ignore Escape key")


func _test_volume_slider() -> void:
  var scene: PackedScene = load(PAUSE_MENU_PATH) as PackedScene
  var menu: PauseMenu = scene.instantiate() as PauseMenu
  root.add_child(menu)
  await process_frame
  _assert_volume_slider_structure(menu)
  _assert_volume_slider_interaction(menu)
  menu.queue_free()
  await process_frame


func _assert_volume_slider_structure(menu: PauseMenu) -> void:
  assert(menu.volume_label != null, "Volume label must exist")
  assert(menu.volume_label.text == "Volumen de fondo", "Volume label text mismatch")
  assert(menu.volume_slider != null, "Volume slider must exist")
  assert(menu.volume_slider.max_value == 1.0, "Slider max value must be 1.0")
  var track: StyleBoxFlat = menu.volume_slider.get_theme_stylebox("slider") as StyleBoxFlat
  assert(track != null, "Slider track style must exist")
  assert(track.bg_color.is_equal_approx(Color(0.18, 0.14, 0.28, 0.9)), "Track bg must match button normal bg")
  assert(track.border_color.is_equal_approx(Color(0.85, 0.75, 0.35, 1)), "Track border must match button border")


func _assert_volume_slider_interaction(menu: PauseMenu) -> void:
  var gm: Node = root.get_node_or_null("GameManager")
  if gm != null:
    gm.call("set_music_volume", 0.5)
    menu.pause()
    assert(is_equal_approx(menu.volume_slider.value, 0.5), "Slider must sync on pause")
    menu.volume_slider.value = 0.25
    assert(is_equal_approx(gm.call("get_music_volume"), 0.25), "GameManager volume must update")
    gm.call("set_music_volume", 1.0)
    assert(is_equal_approx(gm.call("get_music_volume"), 1.0), "Volume reset")

