extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const FINAL_LEVEL_NUM: int = 10


func _initialize() -> void:
	print("--- Running Test Level Win Flow ---")
	_run_tests()


func _run_tests() -> void:
	for lvl: int in range(1, FINAL_LEVEL_NUM):
		await _verify_level_next_button(lvl, true)
	await _verify_level_next_button(FINAL_LEVEL_NUM, false)
	print("--- All Level Win Flow Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _verify_level_next_button(lvl: int, should_be_visible: bool) -> void:
	var level_node: Node = _instantiate_level(lvl)
	root.add_child(level_node)
	await process_frame
	_check_inferred_level_num(level_node, lvl)
	_check_button_visibility(level_node, lvl, should_be_visible)
	if should_be_visible:
		_check_target_scene_exists(lvl + 1)
	level_node.queue_free()
	await process_frame


func _instantiate_level(lvl: int) -> Node:
	var scene_path: String = "res://level_%d.tscn" % lvl
	var scene: PackedScene = load(scene_path)
	assert(scene != null, "Scene %s failed to load" % scene_path)
	return scene.instantiate()


func _check_inferred_level_num(level_node: Node, lvl: int) -> void:
	var current_num: int = level_node.call("_get_current_level_num")
	assert(current_num == lvl, "Level %d inferred level num was %d" % [lvl, current_num])


func _check_button_visibility(level_node: Node, lvl: int, should_be_visible: bool) -> void:
	level_node.call("_show_victory_panel")
	var next_btn: Button = level_node.get_node("HUD/LevelEndPanel/ModalBox/VBox/ButtonsRow/NextLevelButton")
	assert(next_btn != null, "NextLevelButton not found in level %d" % lvl)
	assert(next_btn.visible == should_be_visible, "Button visibility mismatch for level %d" % lvl)


func _check_target_scene_exists(target_lvl: int) -> void:
	var target_path: String = "res://level_%d.tscn" % target_lvl
	assert(ResourceLoader.exists(target_path), "Target scene %s does not exist" % target_path)
