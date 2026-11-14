extends SceneTree

const EXIT_OK: int = 0
const POOLED_SHOOTER_PATHS: Array[String] = [
	"res://harry.tscn",
	"res://ron.tscn",
	"res://hermione.tscn",
	"res://mcgonagall.tscn",
]
const SCENE_HEALTH_PATHS: Array[String] = ["res://hermione.tscn", "res://dumbledore.tscn"]
const EXPECTED_SCENE_HEALTH: float = 300.0
const PROTEGO_PATH: String = "res://protego.tscn"
const PROTEGO_SCENE_HEALTH: float = 1000.0
const SMALL_HIT: float = 1.0
const UNDAMAGED_FRAME: int = 0


func _initialize() -> void:
	print("--- Running Ally Shot Contract Tests ---")
	_run_tests()


func _run_tests() -> void:
	_test_pooled_shooters_have_no_projectile_scene()
	for path: String in SCENE_HEALTH_PATHS:
		await _test_scene_health_survives_ready(path)
	await _test_protego_reads_scene_health()
	print("--- All Ally Shot Contract Tests Passed ---")
	quit(EXIT_OK)


func _test_pooled_shooters_have_no_projectile_scene() -> void:
	for path: String in POOLED_SHOOTER_PATHS:
		var ally: Node = (load(path) as PackedScene).instantiate()
		assert(ally.get("projectile_scene") == null, "%s must shoot only through the pool" % path)
		ally.free()


func _test_scene_health_survives_ready(path: String) -> void:
	var ally: Ally = await _add_ally(path)
	assert(is_equal_approx(ally.health, EXPECTED_SCENE_HEALTH), "%s health must come from the scene" % path)
	await _dispose(ally)


func _test_protego_reads_scene_health() -> void:
	var protego: Protego = await _add_ally(PROTEGO_PATH) as Protego
	assert(is_equal_approx(protego.max_health(), PROTEGO_SCENE_HEALTH), "Protego max health comes from the scene")
	protego.take_damage(SMALL_HIT)
	assert(protego.health < PROTEGO_SCENE_HEALTH, "Protego must lose health")
	assert(protego.sprite.frame == UNDAMAGED_FRAME, "A small hit keeps the undamaged frame")
	await _dispose(protego)


func _add_ally(path: String) -> Ally:
	var ally: Ally = (load(path) as PackedScene).instantiate() as Ally
	root.add_child(ally)
	await process_frame
	return ally


func _dispose(node: Node) -> void:
	node.queue_free()
	await process_frame
