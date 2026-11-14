extends SceneTree

const EXIT_OK: int = 0
const PULSE_WAIT: float = 0.4
const LEVEL_PATHS: Array[String] = ["res://level_4.tscn", "res://level_6.tscn", "res://level_9.tscn", "res://level_10.tscn"]
const SCREEN_HEIGHT: float = 1080.0
const LAYOUT_FRAMES: int = 3


func _initialize() -> void:
	print("--- Running Test Accio Button ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_standalone_visuals()
	await _test_state_toggle()
	await _test_glow_pulses()
	var lefts: Array[float] = []
	for path: String in LEVEL_PATHS:
		lefts.append(await _test_sits_after_card_bar(path))
	assert(lefts.min() == lefts.max(), "AccioButton is at the same right-end spot in every level")
	print("--- All Accio Button Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_standalone_visuals() -> void:
	var btn: AccioButton = await _add_button()
	assert(not btn.flat and btn.expand_icon, "AccioButton is a framed button with an expanded icon")
	assert(btn.icon == AccioButton.WAND_TEXTURE, "AccioButton shows the Elder Wand")
	assert(btn.text == AccioButton.LABEL_TEXT, "AccioButton shows the ACCIO label")
	assert(btn.tooltip_text == AccioButton.TOOLTIP_TEXT_CONTENT, "AccioButton explains how to use it")
	var normal_box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(normal_box.bg_color.is_equal_approx(AccioButton.PARCHMENT_BG_NORMAL), "Idle background is parchment")
	assert(normal_box.border_color.is_equal_approx(AccioButton.PARCHMENT_FRAME), "Idle frame is brown")
	assert(btn.get_theme_stylebox("focus") is StyleBoxEmpty, "No focus frame")
	btn.free()


func _test_state_toggle() -> void:
	var btn: AccioButton = await _add_button()
	assert(not btn.is_active(), "AccioButton starts inactive")
	btn.set_active(true)
	var active_box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(btn.is_active() and active_box.bg_color.is_equal_approx(AccioButton.PARCHMENT_BG_ACTIVE), "Active turns golden")
	assert((btn.get_theme_stylebox("normal") as StyleBoxFlat).border_color.is_equal_approx(AccioButton.ACTIVE_FRAME), "Active frame is gold")
	btn.set_active(false)
	var idle_box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(idle_box.bg_color.is_equal_approx(AccioButton.PARCHMENT_BG_NORMAL), "Inactive goes back to parchment")
	btn.free()


func _test_glow_pulses() -> void:
	var btn: AccioButton = await _add_button()
	var idle_box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(idle_box.shadow_color.is_equal_approx(AccioButton.SOFT_SHADOW), "Idle only has a soft shadow")
	btn.set_active(true)
	var box: StyleBoxFlat = btn.get_theme_stylebox("normal") as StyleBoxFlat
	var first: int = box.shadow_size
	await create_timer(PULSE_WAIT).timeout
	assert(box.shadow_size != first, "The glow pulses while active")
	btn.queue_free()
	await process_frame


func _test_sits_after_card_bar(path: String) -> float:
	var level: Level = (load(path) as PackedScene).instantiate() as Level
	root.add_child(level)
	for _i: int in range(LAYOUT_FRAMES):
		await process_frame
	var btn: AccioButton = level.hud.get_node_or_null("AccioButton") as AccioButton
	assert(btn.visible, "%s: AccioButton is visible" % path)
	var rect: Rect2 = btn.get_global_rect()
	_assert_layout(level, rect, path)
	level.queue_free()
	await process_frame
	return rect.position.x


func _assert_layout(level: Level, rect: Rect2, path: String) -> void:
	var bar: Rect2 = level.call("_card_bar_rect")
	assert(rect.position.x >= bar.end.x, "%s: AccioButton sits after the last card" % path)
	assert(is_equal_approx(rect.get_center().y, bar.get_center().y), "%s: AccioButton is centred on the card bar" % path)
	assert(rect.size.y < bar.size.y, "%s: AccioButton is smaller than a card" % path)
	assert(rect.end.x <= level.call("_accio_right_limit"), "%s: AccioButton ends before the pause button" % path)
	assert(rect.end.y <= SCREEN_HEIGHT, "%s: AccioButton fits on screen" % path)


func _add_button() -> AccioButton:
	var btn: AccioButton = AccioButton.new()
	root.add_child(btn)
	await process_frame
	return btn
