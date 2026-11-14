extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1


func _initialize() -> void:
	print("--- Running Test Broomstick Enemy Ignore ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_regular_enemy_ignores_broomstick()
	await _test_troll_ignores_broomstick_and_takes_damage()
	await _test_prefect_does_not_shoot_at_broomstick()
	await _test_broomstick_is_invulnerable_to_damage()
	print("--- All Broomstick Enemy Ignore Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_regular_enemy_ignores_broomstick() -> void:
	var enemy_scene: PackedScene = load("res://slytherin_student.tscn")
	var broom_scene: PackedScene = load("res://broomstick.tscn")
	var enemy: Enemy = enemy_scene.instantiate() as Enemy
	var broom: Broomstick = broom_scene.instantiate() as Broomstick
	_setup_actors(enemy, broom, Vector2(400, 300), Vector2(380, 300))
	_verify_regular_enemy_ignores(enemy, broom)
	enemy.queue_free()
	broom.queue_free()
	await process_frame


func _verify_regular_enemy_ignores(enemy: Enemy, broom: Broomstick) -> void:
	enemy.call("_on_detection_area_area_entered", broom)
	assert(enemy.get("_target_ally") == null, "Enemy must NOT target Broomstick")
	assert(not enemy.get("_is_attacking"), "Enemy must NOT enter attacking state")
	broom.call("_try_damage_node", enemy)
	assert(enemy.get("_health") <= 0.0, "Enemy health must be <= 0 after sweep")


func _test_troll_ignores_broomstick_and_takes_damage() -> void:
	var troll_scene: PackedScene = load("res://troll.tscn")
	var broom_scene: PackedScene = load("res://broomstick.tscn")
	var troll: Troll = troll_scene.instantiate() as Troll
	var broom: Broomstick = broom_scene.instantiate() as Broomstick
	_setup_actors(troll, broom, Vector2(500, 300), Vector2(480, 300))
	_verify_troll_ignores(troll, broom)
	troll.queue_free()
	broom.queue_free()
	await process_frame


func _verify_troll_ignores(troll: Troll, broom: Broomstick) -> void:
	troll.call("_on_detection_area_area_entered", broom)
	assert(not troll.get("_is_attacking"), "Troll must NOT enter attack state on Broomstick")
	broom.call("_try_damage_node", troll)
	assert(troll.get("_health") == 1800.0, "Troll health should drop from 3600 to 1800")


func _setup_actors(enemy: Node2D, broom: Broomstick, enemy_pos: Vector2, broom_pos: Vector2) -> void:
	broom.set_process(false)
	enemy.set_process(false)
	root.add_child(enemy)
	root.add_child(broom)
	enemy.global_position = enemy_pos
	broom.global_position = broom_pos


func _test_prefect_does_not_shoot_at_broomstick() -> void:
	var broom_scene: PackedScene = load("res://broomstick.tscn")
	var broom: Broomstick = broom_scene.instantiate() as Broomstick
	root.add_child(broom)
	broom.global_position = Vector2(200, 272)
	await process_frame
	var has_ally: bool = Lane.has_allies_in_lane_ahead(self, 272.0, 500.0)
	assert(not has_ally, "Prefect should not see Broomstick as target ahead")
	broom.queue_free()
	await process_frame


func _test_broomstick_is_invulnerable_to_damage() -> void:
	var broom_scene: PackedScene = load("res://broomstick.tscn")
	var broom: Broomstick = broom_scene.instantiate() as Broomstick
	root.add_child(broom)
	await process_frame
	var initial_health: float = broom.health
	broom.take_damage(500.0)
	assert(broom.health == initial_health, "Broomstick must ignore incoming damage")
	assert(not broom.is_queued_for_deletion(), "Broomstick must not be destroyed by attacks")
	broom.queue_free()
	await process_frame
