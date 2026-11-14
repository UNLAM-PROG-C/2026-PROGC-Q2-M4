extends SceneTree

const PREFECT_SCENE_PATH: String = "res://slytherin_prefect.tscn"
const SPAWN_X: float = 1850.0
const LANE_Y: float = 300.0
const PROCESS_DELTA: float = 0.2

var _root: Node2D
var _prefect: SlytherinPrefect


func _initialize() -> void:
	print("--- Running SlytherinPrefect Walk & Shoot Tests ---")
	await _setup_test_scene()
	_test_walking_phase()
	_test_shooting_while_walking()
	_test_arrival_and_stop()
	_test_shooting_while_stopped()
	_test_hurt_textures()
	_cleanup()
	print("--- All SlytherinPrefect Tests PASSED ---")
	quit(0)


func _setup_test_scene() -> void:
	_root = Node2D.new()
	root.add_child(_root)
	var scene: PackedScene = load(PREFECT_SCENE_PATH) as PackedScene
	assert(scene != null, "Scene must exist")
	_prefect = scene.instantiate() as SlytherinPrefect
	_root.add_child(_prefect)
	_prefect.global_position = Vector2(SPAWN_X, LANE_Y)
	await process_frame


func _test_walking_phase() -> void:
	assert(not _prefect.is_stopped(), "Must start in walking state")
	assert(_prefect.sprite.texture == _prefect.walk_texture, "Must use walk texture")
	assert(_prefect.sprite.hframes == 8, "Walk sprite must have 8 frames")
	var prev_x: float = _prefect.global_position.x
	_prefect._process(PROCESS_DELTA)
	assert(_prefect.global_position.x < prev_x, "Must advance left while walking")


func _test_shooting_while_walking() -> void:
	var count_before: int = _root.get_child_count()
	_prefect._on_shoot_timer_timeout()
	assert(_root.get_child_count() > count_before, "Must shoot projectile while walking")
	var projectile: EnemyProjectile = _root.get_child(_root.get_child_count() - 1) as EnemyProjectile
	assert(projectile != null, "Projectile must be EnemyProjectile")
	assert(projectile.global_position.y == _prefect.shoot_point.global_position.y)


func _test_arrival_and_stop() -> void:
	_prefect.global_position.x = _prefect.stop_x + 5.0
	_prefect._process(PROCESS_DELTA)
	assert(_prefect.is_stopped(), "Must be stopped once reaching stop_x")
	assert(_prefect.global_position.x == _prefect.stop_x, "Must clamp to stop_x")
	assert(_prefect.sprite.texture == _prefect.attacking_texture, "Must use attacking texture")
	assert(_prefect.sprite.hframes == 1, "Attacking texture must have 1 frame")
	_prefect._process(1.0)
	assert(_prefect.global_position.x == _prefect.stop_x, "Must remain stopped")


func _test_shooting_while_stopped() -> void:
	var count_before: int = _root.get_child_count()
	_prefect._on_shoot_timer_timeout()
	assert(_root.get_child_count() > count_before, "Must shoot projectile while stopped")


func _test_hurt_textures() -> void:
	_prefect.take_damage(_prefect.max_health * 0.6)
	assert(_prefect.sprite.texture == _prefect.hurt_attacking_texture, "Stopped hurt texture")
	_prefect._is_stopped = false
	_prefect._update_animation_texture()
	assert(_prefect.sprite.texture == _prefect.hurt_texture, "Walking hurt texture")


func _cleanup() -> void:
	if is_instance_valid(_root):
		_root.queue_free()
