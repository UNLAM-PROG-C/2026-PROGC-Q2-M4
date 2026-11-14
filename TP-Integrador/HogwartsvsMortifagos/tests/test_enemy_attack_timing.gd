extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const PAIR_ORIGIN: Vector2 = Vector2(500.0, 200.0)
const MELEE_ALLY_OFFSET_X: float = -20.0
const MELEE_PROCESS_STEPS: int = 10
const MELEE_PROCESS_DELTA: float = 0.016
const TROLL_ALLY_OFFSET_X: float = -50.0
const TROLL_PROCESS_STEPS: int = 20
const TROLL_PROCESS_DELTA: float = 0.05
const TROLL_WALK_DELTA: float = 0.1
const TROLL_ATTACK_ANIMATION: StringName = &"attack"
const TROLL_WALK_ANIMATION: String = "Walk"


func _initialize() -> void:
	print("--- Running Test Enemy Attack Timing ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_melee_enemy_attack_loop_damage()
	await _test_shooting_enemy_stays_stopped_and_shoots()
	await _test_troll_instakill_and_resumes_walking()
	print("--- All Enemy Attack Timing Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_melee_enemy_attack_loop_damage() -> void:
	print("Testing Melee Enemy attack loop damage...")
	var student: Enemy = (load("res://slytherin_student.tscn") as PackedScene).instantiate() as Enemy
	var ally: Ally = (load("res://harry.tscn") as PackedScene).instantiate() as Ally
	await _place_pair(student, ally, MELEE_ALLY_OFFSET_X)
	var initial_health: float = ally.health
	student._target_ally = ally
	student._update_target_state()
	assert(student._is_attacking, "Student should be in attacking state")
	assert(student.sprite.frame == 0, "Initial attack frame should be 0")
	_verify_no_damage_while_processing(student, ally, initial_health)
	_verify_damage_only_when_loop_ends(student, ally, initial_health)
	await _free_pair(student, ally)
	print("Melee Enemy attack loop test PASSED.")


func _verify_no_damage_while_processing(student: Enemy, ally: Ally, initial_health: float) -> void:
	for _i: int in range(MELEE_PROCESS_STEPS):
		student._process(MELEE_PROCESS_DELTA)
	assert(ally.health == initial_health, "Ally should take NO damage during delta process while attacking!")


## Frames 0 to 3 deal no damage; closing the loop back to 0 deals one hit.
func _verify_damage_only_when_loop_ends(student: Enemy, ally: Ally, initial_health: float) -> void:
	for expected_frame: int in range(1, Enemy.ATTACKING_FRAME_COUNT):
		student._on_animation_timer_timeout()
		assert(student.sprite.frame == expected_frame, "Frame should advance to %d" % expected_frame)
		assert(ally.health == initial_health, "No damage on frame %d" % expected_frame)
	student._on_animation_timer_timeout()
	assert(student.sprite.frame == 0, "Frame should loop back to 0")
	assert(ally.health == initial_health - student.damage_per_attack, "Damage dealt should equal damage_per_attack")


func _test_shooting_enemy_stays_stopped_and_shoots() -> void:
	print("Testing Shooting Enemy (SlytherinPrefect) behavior...")
	var prefect_scene: PackedScene = load("res://slytherin_prefect.tscn")
	assert(prefect_scene != null, "Prefect scene must load")
	var prefect: SlytherinPrefect = prefect_scene.instantiate() as SlytherinPrefect
	root.add_child(prefect)
	prefect.global_position = Vector2(1800, 200)
	await process_frame
	_verify_prefect_walking_state(prefect)
	_verify_prefect_stopping_and_attacking_state(prefect)
	_verify_prefect_hurt_textures(prefect)
	prefect.queue_free()
	await process_frame
	print("Shooting Enemy test PASSED.")


func _verify_prefect_walking_state(prefect: SlytherinPrefect) -> void:
	assert(not prefect.is_stopped(), "Prefect should be walking before stop_x")
	assert(prefect.sprite.texture == prefect.walk_texture, "Prefect should use walk texture while walking")
	assert(prefect.sprite.hframes == 8, "Walk texture must have 8 frames")
	var initial_x: float = prefect.position.x
	prefect._process(0.1)
	assert(prefect.position.x < initial_x, "Prefect should advance while walking")
	var child_count_before: int = root.get_child_count()
	prefect._on_shoot_timer_timeout()
	assert(root.get_child_count() > child_count_before, "Prefect must shoot while walking")


func _verify_prefect_stopping_and_attacking_state(prefect: SlytherinPrefect) -> void:
	prefect.global_position.x = prefect.stop_x - 10.0
	prefect._process(0.1)
	assert(prefect.is_stopped(), "Prefect must stay stopped at or past stop_x")
	assert(prefect.global_position.x == prefect.stop_x, "Position should be clamped to stop_x")
	assert(prefect.sprite.texture == prefect.attacking_texture, "Prefect should use attacking texture when stopped")
	assert(prefect.sprite.hframes == 1, "Attacking texture must have 1 frame")
	var stopped_x: float = prefect.position.x
	prefect._process(0.5)
	assert(prefect.position.x == stopped_x, "Prefect must remain still after stopping")
	var child_count_before: int = root.get_child_count()
	prefect._on_shoot_timer_timeout()
	assert(root.get_child_count() > child_count_before, "Prefect must continue shooting when stopped")


func _verify_prefect_hurt_textures(prefect: SlytherinPrefect) -> void:
	prefect.take_damage(prefect.max_health * 0.6)
	assert(prefect.sprite.texture == prefect.hurt_attacking_texture, "Should use hurt attacking texture when stopped")
	prefect._is_stopped = false
	prefect._update_animation_texture()
	assert(prefect.sprite.texture == prefect.hurt_texture, "Should use hurt walk texture when walking")


func _test_troll_instakill_and_resumes_walking() -> void:
	print("Testing Troll instakill and walk resumption...")
	var troll: Troll = (load("res://troll.tscn") as PackedScene).instantiate() as Troll
	var ally: Ally = (load("res://harry.tscn") as PackedScene).instantiate() as Ally
	await _place_pair(troll, ally, TROLL_ALLY_OFFSET_X)
	assert(troll._has_allies_in_front(), "Troll should detect ally in front")
	troll._start_attack()
	assert(troll._is_attacking, "Troll should be attacking")
	_verify_troll_waits_for_animation(troll, ally)
	_verify_troll_resumes_walking(troll)
	await _free_pair(troll, ally)
	print("Troll instakill and walk resumption test PASSED.")


func _verify_troll_waits_for_animation(troll: Troll, ally: Ally) -> void:
	var ally_health_before: float = ally.health
	for _i: int in range(TROLL_PROCESS_STEPS):
		troll._process(TROLL_PROCESS_DELTA)
	assert(ally.health == ally_health_before, "Troll must NOT deal damage during process frames!")
	troll._on_animation_finished(TROLL_ATTACK_ANIMATION)
	assert(ally.health <= 0.0 or not is_instance_valid(ally), "Ally must receive instakill damage once attack animation finishes!")


func _verify_troll_resumes_walking(troll: Troll) -> void:
	assert(not troll._is_attacking, "Troll should NOT be attacking after attack animation finishes!")
	assert(troll.animation_player.current_animation == TROLL_WALK_ANIMATION, "Troll MUST switch back to Walk animation!")
	var pos_x_before: float = troll.position.x
	troll._process(TROLL_WALK_DELTA)
	assert(troll.position.x < pos_x_before, "Troll MUST walk forward after attack animation finishes!")


func _place_pair(enemy: Enemy, ally: Ally, ally_offset_x: float) -> void:
	root.add_child(enemy)
	root.add_child(ally)
	enemy.global_position = PAIR_ORIGIN
	ally.global_position = PAIR_ORIGIN + Vector2(ally_offset_x, 0.0)
	await process_frame


func _free_pair(enemy: Enemy, ally: Ally) -> void:
	enemy.queue_free()
	if is_instance_valid(ally):
		ally.queue_free()
	await process_frame
