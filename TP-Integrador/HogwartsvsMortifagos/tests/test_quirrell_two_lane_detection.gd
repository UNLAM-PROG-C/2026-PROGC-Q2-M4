extends SceneTree

const QUIRRELL_SCENE: String = "res://quirrell.tscn"
const PROJECTILE_SCENE: String = "res://projectile.tscn"
const HARRY_SCENE: String = "res://harry.tscn"

const QUIRRELL_X: float = 1000.0
const HARRY_X: float = 400.0
const ROW_4_Y: float = 592.0
const ROW_3_Y: float = 432.0
const ROW_5_Y: float = 752.0
const MAX_FRAMES_WAIT: int = 120

var _quirrell: Quirrell
var _harry_above: Harry
var _harry_current: Harry
var _harry_below: Harry


func _initialize() -> void:
	print("--- Running Quirrell Two Lane Detection Tests ---")
	await _setup_entities()
	_verify_lane_detection()
	await _verify_projectile_hits()
	_cleanup()
	print("--- All Quirrell Two Lane Detection Tests PASSED ---")
	quit(0)


func _setup_entities() -> void:
	_setup_boss()
	_setup_allies()
	await physics_frame


func _setup_boss() -> void:
	_quirrell = (load(QUIRRELL_SCENE) as PackedScene).instantiate() as Quirrell
	root.add_child(_quirrell)
	_quirrell.global_position = Vector2(QUIRRELL_X, ROW_4_Y)


func _setup_allies() -> void:
	_harry_above = _create_harry(ROW_3_Y)
	_harry_current = _create_harry(ROW_4_Y)
	_harry_below = _create_harry(ROW_5_Y)


func _create_harry(y_pos: float) -> Harry:
	var h_scene: PackedScene = load(HARRY_SCENE) as PackedScene
	var ally: Harry = h_scene.instantiate() as Harry
	root.add_child(ally)
	ally.global_position = Vector2(HARRY_X, y_pos)
	return ally


func _verify_lane_detection() -> void:
	assert(_harry_above._has_enemy_in_lane(), "Harry in row above MUST detect Quirrell")
	assert(_harry_current._has_enemy_in_lane(), "Harry in current row MUST detect Quirrell")
	assert(not _harry_below._has_enemy_in_lane(), "Harry in row below MUST NOT detect Quirrell")


func _verify_projectile_hits() -> void:
	await _fire_projectile_from_ally(_harry_above)
	assert(_quirrell._health < _quirrell.max_health, "Projectile from row above must hit Quirrell")
	var hp_after_above: float = _quirrell._health
	await _fire_projectile_from_ally(_harry_current)
	assert(_quirrell._health < hp_after_above, "Projectile from current row must hit Quirrell")


func _fire_projectile_from_ally(ally: Harry) -> void:
	var p_scene: PackedScene = load(PROJECTILE_SCENE) as PackedScene
	var projectile: Projectile = p_scene.instantiate() as Projectile
	root.add_child(projectile)
	await physics_frame
	projectile.activate(ally.shoot_point.global_position)
	for i: int in range(MAX_FRAMES_WAIT):
		await physics_frame
		if projectile.global_position.x >= _quirrell.global_position.x:
			break
	await physics_frame
	projectile.queue_free()


func _cleanup() -> void:
	if is_instance_valid(_quirrell):
		_quirrell.queue_free()
	if is_instance_valid(_harry_above):
		_harry_above.queue_free()
	if is_instance_valid(_harry_current):
		_harry_current.queue_free()
	if is_instance_valid(_harry_below):
		_harry_below.queue_free()
