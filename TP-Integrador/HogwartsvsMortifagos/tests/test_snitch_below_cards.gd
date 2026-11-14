extends SceneTree

const EXIT_OK: int = 0
const FIRST_LEVEL: int = 1
const LAST_LEVEL: int = 10
const LEVEL_PATH_TEMPLATE: String = "res://level_%d.tscn"
const SKY_SPAWN_LEVEL: String = "res://level_8.tscn"
const SNITCH_SCENE: String = "res://snitch.tscn"
const ESCAPE_START: Vector2 = Vector2(600.0, 230.0)
const ESCAPE_STEPS: int = 60
const ESCAPE_DELTA: float = 0.016
const ESCAPE_TIME: float = 1.0


func _initialize() -> void:
	print("--- Running Snitch Below Cards Tests ---")
	_run_tests()


func _run_tests() -> void:
	for level_number: int in range(FIRST_LEVEL, LAST_LEVEL + 1):
		await _test_cards_end_above_limit(LEVEL_PATH_TEMPLATE % level_number)
	await _test_sky_snitch_starts_below_cards()
	await _test_escape_never_climbs_behind_cards()
	print("--- All Snitch Below Cards Tests Passed ---")
	quit(EXIT_OK)


## The limit only works if every card of every level ends above it.
func _test_cards_end_above_limit(path: String) -> void:
	var lvl: Level = await _add_level(path)
	for button: AllyCardButton in lvl.call("_card_buttons"):
		assert(button.get_global_rect().end.y <= Snitch.MIN_VISIBLE_Y, "%s: a card reaches below MIN_VISIBLE_Y" % path)
	await _dispose(lvl)


func _test_sky_snitch_starts_below_cards() -> void:
	var lvl: Level = await _add_level(SKY_SPAWN_LEVEL)
	lvl.call("_on_snitch_spawn_timer_timeout")
	var snitches: Array[Node] = lvl.entity_layer.get_children().filter(func(node: Node) -> bool: return node is Snitch)
	assert(not snitches.is_empty(), "A sky snitch is spawned")
	for snitch: Node in snitches:
		assert((snitch as Snitch).global_position.y >= Snitch.MIN_VISIBLE_Y, "Sky snitches start below the cards")
	await _dispose(lvl)


func _test_escape_never_climbs_behind_cards() -> void:
	var snitch: Snitch = (load(SNITCH_SCENE) as PackedScene).instantiate() as Snitch
	root.add_child(snitch)
	await process_frame
	snitch.global_position = ESCAPE_START
	snitch.set("_escape_direction", Vector2.UP)
	snitch.set("_escape_time_left", ESCAPE_TIME)
	for _i: int in range(ESCAPE_STEPS):
		snitch.call("_process_escape", ESCAPE_DELTA)
	assert(snitch.global_position.y >= Snitch.MIN_VISIBLE_Y, "Escaping upward stops at the card bar")
	await _dispose(snitch)


func _add_level(path: String) -> Level:
	var lvl: Level = (load(path) as PackedScene).instantiate() as Level
	root.add_child(lvl)
	await process_frame
	return lvl


func _dispose(node: Node) -> void:
	node.queue_free()
	await process_frame
