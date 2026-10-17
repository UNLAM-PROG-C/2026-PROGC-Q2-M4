extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1

const PARCHMENT_BG_COLOR: Color = Color(0.894118, 0.803922, 0.623529, 1.0)
const BORDER_INK_COLOR: Color = Color(0.235294, 0.141176, 0.0823529, 1.0)
const TEXT_INK_COLOR: Color = Color(0.235, 0.141, 0.082, 1.0)
const EXPECTED_FONT_SIZE: int = 44


func _initialize() -> void:
	print("--- Running Test Wave Announcement Format Across Levels ---")
	_run_all_tests()


func _run_all_tests() -> void:
	for lvl: int in range(1, 11):
		_test_level_announcement(lvl)
	print("--- All Wave Announcement Format Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_level_announcement(level_num: int) -> void:
	var path: String = "res://level_%d.tscn" % level_num
	var scene: PackedScene = load(path)
	assert(scene != null, "Scene %s must load successfully" % path)
	var node: Node = scene.instantiate()
	root.add_child(node)
	var level: Level = node as Level
	_verify_panel_style(level, path)
	_verify_label_style(level, path)
	node.queue_free()


func _verify_panel_style(level: Level, path: String) -> void:
	var wa: Control = level.get_node("HUD/WaveAnnouncement") as Control
	assert(wa != null, "WaveAnnouncement must exist in %s" % path)
	assert(wa is PanelContainer, "WaveAnnouncement must be PanelContainer in %s" % path)
	var style: StyleBoxFlat = wa.get_theme_stylebox("panel") as StyleBoxFlat
	assert(style != null, "WaveAnnouncement must have panel stylebox in %s" % path)
	assert(style.bg_color == PARCHMENT_BG_COLOR, "Background must be parchment in %s" % path)
	assert(style.border_color == BORDER_INK_COLOR, "Border must be dark ink in %s" % path)
	assert(style.corner_radius_top_left == 12, "Corner radius must be 12 in %s" % path)


func _verify_label_style(level: Level, path: String) -> void:
	var lbl: Label = level.get_node("HUD/WaveAnnouncement/Label") as Label
	assert(lbl != null, "WaveAnnouncement/Label must exist in %s" % path)
	var color: Color = lbl.get_theme_color("font_color")
	assert(color == TEXT_INK_COLOR, "Text color must match victory cartel ink color in %s" % path)
	var font_size: int = lbl.get_theme_font_size("font_size")
	assert(font_size == EXPECTED_FONT_SIZE, "Font size must be %d in %s" % [EXPECTED_FONT_SIZE, path])
	assert(lbl.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Must be centered in %s" % path)
