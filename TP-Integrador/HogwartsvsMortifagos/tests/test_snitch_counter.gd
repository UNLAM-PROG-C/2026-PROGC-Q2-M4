extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1

const PARCHMENT_BG: Color = Color(0.894118, 0.803922, 0.623529, 1)
const BORDER_COLOR: Color = Color(0.235294, 0.141176, 0.0823529, 1)

const SnitchCounter = preload("res://snitch_counter.gd")
const LevelScript = preload("res://level.gd")


func _initialize() -> void:
	print("--- Running Test Snitch Counter ---")
	_run_all_tests()


func _run_all_tests() -> void:
	_test_snitch_counter_node_structure()
	_test_snitch_counter_value_methods()
	await _test_level_1_integration()
	await _test_level_10_starting_snitches()
	print("--- All Snitch Counter Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_snitch_counter_node_structure() -> void:
	var scene: PackedScene = load("res://snitch_counter.tscn") as PackedScene
	assert(scene != null, "snitch_counter.tscn must exist")
	var counter: SnitchCounter = scene.instantiate() as SnitchCounter
	assert(counter != null, "Must instantiate as SnitchCounter")
	assert(counter is PanelContainer, "SnitchCounter must be a PanelContainer")
	var style: StyleBoxFlat = counter.get_theme_stylebox("panel") as StyleBoxFlat
	assert(style != null, "Must have a StyleBoxFlat panel style")
	assert(style.bg_color.is_equal_approx(PARCHMENT_BG), "Panel must match pause button parchment color")
	assert(style.border_color.is_equal_approx(BORDER_COLOR), "Border must match pause button border")
	assert(style.border_width_left == 4, "Border width must be 4px")
	_verify_counter_children(counter)
	counter.free()


func _verify_counter_children(counter: SnitchCounter) -> void:
	var label: Label = counter.get_node_or_null("VBoxContainer/SnitchesLabel") as Label
	assert(label != null, "Must have SnitchesLabel child")
	assert(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Label must be centered")
	var icon: TextureRect = counter.get_node_or_null("VBoxContainer/SnitchIcon") as TextureRect
	assert(icon != null, "Must have SnitchIcon child")
	assert(icon.size_flags_horizontal == Control.SIZE_SHRINK_CENTER, "Icon must be centered horizontally")
	var atlas: AtlasTexture = icon.texture as AtlasTexture
	assert(atlas != null, "Icon must use AtlasTexture")
	assert(atlas.region.position == Vector2.ZERO, "Atlas must start at 0,0")
	assert(atlas.region.size.y == 38.0, "Atlas height must be 38px")


func _test_snitch_counter_value_methods() -> void:
	var scene: PackedScene = load("res://snitch_counter.tscn") as PackedScene
	var counter: SnitchCounter = scene.instantiate() as SnitchCounter
	counter.set_value(150)
	assert(counter.get_value_text() == "150", "Must show '150'")
	counter.set_value(250)
	assert(counter.get_value_text() == "250", "Must show '250'")
	assert(not counter.get_value_text().to_lower().contains("snitches"), "Must not contain 'snitches'")
	counter.free()


func _test_level_1_integration() -> void:
	var scene: PackedScene = load("res://level_1.tscn") as PackedScene
	var level: Node2D = scene.instantiate() as Node2D
	root.add_child(level)
	for i in range(2):
		await process_frame
	var counter: SnitchCounter = level.get("_snitch_counter") as SnitchCounter
	assert(counter != null, "Level must instantiate _snitch_counter")
	assert(counter.get_value_text() == "150", "Level 1 must start with 150 snitches")
	var legacy: Label = level.get_node("HUD/SnitchesLabel") as Label
	if legacy != null and legacy != counter.snitches_label:
		assert(not legacy.visible, "Legacy label must be hidden")
	level.call("_on_snitch_collected", 25)
	assert(counter.get_value_text() == "175", "Counter must update after collecting snitch")
	level.queue_free()


func _test_level_10_starting_snitches() -> void:
	var scene: PackedScene = load("res://level_10.tscn") as PackedScene
	var level: Node2D = scene.instantiate() as Node2D
	root.add_child(level)
	for i in range(2):
		await process_frame
	var counter: SnitchCounter = level.get("_snitch_counter") as SnitchCounter
	assert(counter != null, "Level 10 must instantiate _snitch_counter")
	assert(counter.get_value_text() == "1500", "Level 10 must start with 1500 snitches")
	level.queue_free()
