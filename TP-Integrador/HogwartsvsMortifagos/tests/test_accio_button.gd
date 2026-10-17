extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1

const PARCHMENT_NORMAL: Color = Color(0.894118, 0.803922, 0.623529, 1.0)
const BORDER_COLOR: Color = Color(0.235294, 0.141176, 0.0823529, 1.0)
const ACTIVE_COLOR: Color = Color(1.0, 0.4, 0.4)

const AccioBtnScript = preload("res://accio_button.gd")


func _initialize() -> void:
	print("--- Running Test Accio Button ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_accio_button_standalone_visuals()
	await _test_accio_button_state_toggle()
	await _test_level_4_integration()
	await _test_level_10_integration()
	print("--- All Accio Button Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_accio_button_standalone_visuals() -> void:
	var btn: AccioButton = AccioButton.new()
	root.add_child(btn)
	await process_frame
	assert(not btn.flat, "AccioButton must not be flat")
	assert(btn.expand_icon, "AccioButton must expand icon")
	assert(btn.icon != null, "AccioButton must have elder wand icon")
	var normal_box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(normal_box != null, "Must have normal StyleBoxFlat")
	assert(normal_box.bg_color.is_equal_approx(PARCHMENT_NORMAL), "Normal bg must match pause parchment")
	assert(normal_box.border_color.is_equal_approx(BORDER_COLOR), "Border color must match pause button")
	assert(normal_box.border_width_left == 4, "Border width must be 4px")
	assert(normal_box.corner_radius_top_left == 12, "Corner radius must be 12px")
	assert(normal_box.shadow_size == 6, "Normal shadow size must be 6px")
	_test_pressed_and_hover_styles(btn)
	btn.free()


func _test_pressed_and_hover_styles(btn: AccioButton) -> void:
	var pressed_box: StyleBoxFlat = btn.get_theme_stylebox("pressed") as StyleBoxFlat
	assert(pressed_box != null, "Must have pressed StyleBoxFlat")
	assert(pressed_box.shadow_size == 2, "Pressed shadow size must be 2px")
	var hover_box: StyleBoxFlat = btn.get_theme_stylebox("hover") as StyleBoxFlat
	assert(hover_box != null, "Must have hover StyleBoxFlat")
	assert(hover_box.shadow_size == 8, "Hover shadow size must be 8px")
	var focus_box: StyleBox = btn.get_theme_stylebox("focus")
	assert(focus_box is StyleBoxEmpty, "Focus style must be StyleBoxEmpty")


func _test_accio_button_state_toggle() -> void:
	var btn: AccioButton = AccioButton.new()
	root.add_child(btn)
	await process_frame
	assert(not btn.is_active(), "AccioButton must start inactive")
	btn.set_active(true)
	assert(btn.is_active(), "AccioButton must be active")
	assert(btn.modulate.is_equal_approx(ACTIVE_COLOR), "Must modulate active color")
	btn.set_active(false)
	assert(not btn.is_active(), "AccioButton must be inactive")
	assert(btn.modulate.is_equal_approx(Color.WHITE), "Must modulate white when inactive")
	btn.free()


func _test_level_4_integration() -> void:
	var scene: PackedScene = load("res://level_4.tscn") as PackedScene
	var level: Node2D = scene.instantiate() as Node2D
	root.add_child(level)
	for i in range(3):
		await process_frame
	var btn: AccioButton = level.get_node_or_null("HUD/AccioButton") as AccioButton
	assert(btn != null, "Level 4 must have AccioButton in HUD")
	assert(btn.visible, "AccioButton must be visible in Level 4")
	assert(btn.offset_bottom <= 1060.0, "AccioButton must fit inside 1080p screen")
	assert(btn.offset_right <= 1900.0, "AccioButton must fit horizontally")
	_capture_screenshot()
	level.queue_free()


func _test_level_10_integration() -> void:
	var scene: PackedScene = load("res://level_10.tscn") as PackedScene
	var level: Node2D = scene.instantiate() as Node2D
	root.add_child(level)
	for i in range(3):
		await process_frame
	var btn: AccioButton = level.get_node_or_null("HUD/AccioButton") as AccioButton
	assert(btn != null, "Level 10 must have AccioButton in HUD")
	assert(btn.visible, "AccioButton must be visible in Level 10")
	assert(btn.offset_bottom <= 1060.0, "AccioButton must fit inside 1080p screen")
	level.queue_free()


func _capture_screenshot() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tex: ViewportTexture = root.get_viewport().get_texture()
	if tex == null:
		return
	var img: Image = tex.get_image()
	if img != null:
		img.save_png("C:/Users/Mi Equipo/.gemini/antigravity-ide/brain/0f0023fa-e526-40da-ad19-775df2c3eadf/accio_button_preview.png")
