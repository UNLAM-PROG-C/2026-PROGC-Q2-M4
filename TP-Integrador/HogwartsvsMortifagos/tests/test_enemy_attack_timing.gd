extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1


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
	var student_scene: PackedScene = load("res://slytherin_student.tscn")
	var ally_scene: PackedScene = load("res://harry.tscn")
	assert(student_scene != null, "Student scene must load")
	assert(ally_scene != null, "Ally scene must load")

	var student: Enemy = student_scene.instantiate() as Enemy
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(student)
	root.add_child(ally)
	student.global_position = Vector2(500, 200)
	ally.global_position = Vector2(480, 200)
	await process_frame

	var initial_health: float = ally.health
	student._target_ally = ally
	student._update_target_state()
	assert(student._is_attacking, "Student should be in attacking state")
	assert(student.sprite.frame == 0, "Initial attack frame should be 0")

	# Simulate several process frames: no damage should be dealt per delta!
	for i in range(10):
		student._process(0.016)
	assert(ally.health == initial_health, "Ally should take NO damage during delta process while attacking!")

	# Frame 0 -> 1: no damage yet
	student._on_animation_timer_timeout()
	assert(student.sprite.frame == 1, "Frame should advance to 1")
	assert(ally.health == initial_health, "No damage on frame 1")

	# Frame 1 -> 2: no damage yet
	student._on_animation_timer_timeout()
	assert(student.sprite.frame == 2, "Frame should advance to 2")
	assert(ally.health == initial_health, "No damage on frame 2")

	# Frame 2 -> 3: no damage yet
	student._on_animation_timer_timeout()
	assert(student.sprite.frame == 3, "Frame should advance to 3")
	assert(ally.health == initial_health, "No damage on frame 3")

	# Frame 3 -> 0: Loop finishes! Damage MUST be dealt now!
	student._on_animation_timer_timeout()
	assert(student.sprite.frame == 0, "Frame should loop back to 0")
	assert(ally.health < initial_health, "Ally MUST take damage when attack loop finishes!")
	assert(ally.health == initial_health - student.damage_per_attack, "Damage dealt should equal damage_per_attack")

	student.queue_free()
	ally.queue_free()
	await process_frame
	print("Melee Enemy attack loop test PASSED.")


func _test_shooting_enemy_stays_stopped_and_shoots() -> void:
	print("Testing Shooting Enemy (SlytherinPrefect) behavior...")
	var prefect_scene: PackedScene = load("res://slytherin_prefect.tscn")
	var ally_scene: PackedScene = load("res://harry.tscn")
	assert(prefect_scene != null, "Prefect scene must load")

	var prefect: SlytherinPrefect = prefect_scene.instantiate() as SlytherinPrefect
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(prefect)
	root.add_child(ally)
	prefect.global_position = Vector2(800, 200)
	ally.global_position = Vector2(400, 200)
	await process_frame

	assert(prefect._has_ally_ahead(), "Prefect should detect ally ahead in lane")
	var initial_x: float = prefect.position.x

	# While ally is ahead, _process should NOT move it forward
	prefect._process(0.1)
	assert(prefect.position.x == initial_x, "Shooting enemy MUST stay stopped when ally is ahead!")

	# Trigger shoot timeout: starts ranged attack animation
	prefect._on_shoot_timer_timeout()
	assert(prefect._is_shooting, "Prefect should be in shooting casting mode")
	assert(prefect.sprite.frame == 0, "Casting animation should start at frame 0")

	# Frames 0 -> 1 -> 2 -> 3
	prefect._on_animation_timer_timeout()
	assert(prefect.sprite.frame == 1)
	assert(prefect._is_shooting)

	prefect._on_animation_timer_timeout()
	assert(prefect.sprite.frame == 2)
	assert(prefect._is_shooting)

	prefect._on_animation_timer_timeout()
	assert(prefect.sprite.frame == 3)
	assert(prefect._is_shooting)

	# Frame 3 -> 0: Loop finishes! Projectile should shoot and _is_shooting ends
	var child_count_before: int = root.get_child_count()
	prefect._on_animation_timer_timeout()
	assert(not prefect._is_shooting, "Prefect should finish shooting cast when animation loop finishes")
	assert(root.get_child_count() > child_count_before, "Projectile should be spawned into parent")

	prefect.queue_free()
	ally.queue_free()
	await process_frame
	print("Shooting Enemy test PASSED.")


func _test_troll_instakill_and_resumes_walking() -> void:
	print("Testing Troll instakill and walk resumption...")
	var troll_scene: PackedScene = load("res://troll.tscn")
	var ally_scene: PackedScene = load("res://harry.tscn")
	assert(troll_scene != null, "Troll scene must load")

	var troll: Troll = troll_scene.instantiate() as Troll
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(troll)
	root.add_child(ally)
	troll.global_position = Vector2(500, 200)
	ally.global_position = Vector2(450, 200)
	await process_frame

	assert(troll._has_allies_in_front(), "Troll should detect ally in front")
	troll._start_attack()
	assert(troll._is_attacking, "Troll should be attacking")

	var ally_health_before: float = ally.health

	# Simulate process frames during attack
	for i in range(20):
		troll._process(0.05)
	assert(ally.health == ally_health_before, "Troll must NOT deal damage during process frames!")

	# Emit animation_finished with attack animation
	troll._on_animation_finished(&"attack")
	assert(ally.health <= 0.0 or not is_instance_valid(ally), "Ally must receive instakill damage once attack animation finishes!")

	# Check that after attack animation finishes: Troll MUST resume walking!
	assert(not troll._is_attacking, "Troll should NOT be attacking after attack animation finishes!")
	assert(troll.animation_player.current_animation == "Walk", "Troll MUST switch back to Walk animation!")

	# Check that Troll actually moves forward when _process is called
	var pos_x_before: float = troll.position.x
	troll._process(0.1)
	assert(troll.position.x < pos_x_before, "Troll MUST walk forward after attack animation finishes!")

	troll.queue_free()
	if is_instance_valid(ally):
		ally.queue_free()
	await process_frame
	print("Troll instakill and walk resumption test PASSED.")
