extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1

const CustomCursorScript = preload("res://custom_cursor.gd")
const KEY_TEXTURE_PATH: String = "res://Images/cursor_key.png"
const WING_TEXTURE_PATH: String = "res://Images/cursor_wing.png"
const EXPECTED_WING_OFFSET: Vector2 = Vector2(0.0, -44.0)
const EXPECTED_KEY_OFFSET: Vector2 = Vector2(-34.5, 0.0)


func _initialize() -> void:
	print("--- Running Test Custom Cursor ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_cursor_node_structure()
	await _test_flapping_animation_states()
	await _test_level_integration_and_screenshot()
	print("--- All Custom Cursor Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_cursor_node_structure() -> void:
	var scene: PackedScene = load("res://custom_cursor.tscn") as PackedScene
	assert(scene != null, "custom_cursor.tscn must exist")
	var cursor: CanvasLayer = scene.instantiate() as CanvasLayer
	root.add_child(cursor)
	await process_frame
	assert(cursor.layer == 128, "CustomCursor layer must be 128")
	assert(cursor.process_mode == Node.PROCESS_MODE_ALWAYS, "Must process always")
	_verify_cursor_children(cursor)
	cursor.queue_free()
	await process_frame


func _verify_cursor_children(cursor: CanvasLayer) -> void:
	var key_sprite: Sprite2D = cursor.get_node("CursorRoot/KeySprite") as Sprite2D
	var left_wing: Sprite2D = cursor.get_node("CursorRoot/LeftWing") as Sprite2D
	var right_wing: Sprite2D = cursor.get_node("CursorRoot/RightWing") as Sprite2D
	assert(key_sprite.texture.resource_path == KEY_TEXTURE_PATH, "Key texture mismatch")
	assert(left_wing.texture.resource_path == WING_TEXTURE_PATH, "Left wing texture mismatch")
	assert(right_wing.texture.resource_path == WING_TEXTURE_PATH, "Right wing texture mismatch")
	assert(key_sprite.offset == EXPECTED_KEY_OFFSET, "Key offset must center horizontally at top")
	assert(left_wing.offset == EXPECTED_WING_OFFSET, "Left wing pivot must be at bottom-left")
	assert(right_wing.offset == EXPECTED_WING_OFFSET, "Right wing pivot must be at bottom-left")
	assert(left_wing.scale.x == -1.0, "Left wing must be mirrored horizontally")
	assert(right_wing.position.y == 45.0, "Wings must attach in top third")


func _test_flapping_animation_states() -> void:
	var scene: PackedScene = load("res://custom_cursor.tscn") as PackedScene
	var cursor: CanvasLayer = scene.instantiate() as CanvasLayer
	root.add_child(cursor)
	await process_frame
	var left_wing: Sprite2D = cursor.get_node("CursorRoot/LeftWing") as Sprite2D
	var right_wing: Sprite2D = cursor.get_node("CursorRoot/RightWing") as Sprite2D
	assert(is_zero_approx(left_wing.rotation), "Left wing must start at 0 rotation")
	assert(is_zero_approx(right_wing.rotation), "Right wing must start at 0 rotation")
	cursor.call("_on_mouse_moved", Vector2(100.0, 100.0), Vector2(15.0, 5.0))
	cursor.call("_update_flapping_animation", 0.05)
	assert(right_wing.rotation < 0.0, "Right wing must rotate upwards (negative)")
	assert(left_wing.rotation > 0.0, "Left wing must rotate upwards (positive)")
	_test_motion_stop_settling(cursor, left_wing, right_wing)
	cursor.queue_free()
	await process_frame


func _test_motion_stop_settling(cursor: CanvasLayer, left: Sprite2D, right: Sprite2D) -> void:
	for i in range(30):
		cursor.call("_update_flapping_animation", 0.05)
	assert(is_zero_approx(left.rotation), "Left wing must settle to 0 when quiet")
	assert(is_zero_approx(right.rotation), "Right wing must settle to 0 when quiet")


func _test_level_integration_and_screenshot() -> void:
	var scene: PackedScene = load("res://level_1.tscn") as PackedScene
	var level: Node2D = scene.instantiate() as Node2D
	root.add_child(level)
	for i in range(5):
		await process_frame
	var cursor: CanvasLayer = root.find_child("CustomCursor", true, false) as CanvasLayer
	assert(cursor != null, "CustomCursor must exist via GameManager in level")
	cursor.call("_on_mouse_moved", Vector2(960.0, 540.0), Vector2(10.0, 0.0))
	for i in range(2):
		await process_frame
	_capture_screenshot()
	level.queue_free()
	await process_frame


func _capture_screenshot() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tex: ViewportTexture = root.get_viewport().get_texture()
	if tex == null:
		return
	var img: Image = tex.get_image()
	if img != null:
		img.save_png("C:/Users/Mi Equipo/.gemini/antigravity-ide/brain/0f0023fa-e526-40da-ad19-775df2c3eadf/custom_cursor_in_game_preview.png")
