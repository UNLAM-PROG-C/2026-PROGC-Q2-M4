extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1


func _initialize() -> void:
	print("--- Running Test Protego Shield (1000 Shield HP / 200 Base HP) ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_initial_health_and_states()
	await _test_shield_visual_degradation()
	await _test_shield_break_and_base_health()
	await _test_overflow_damage()
	await _test_massive_sweep_instakill()
	await _test_shield_attack_texture_and_oscillation()
	await _test_attack_damage_cycle()
	print("--- All Protego Shield Tests Passed Successfully! ---")
	quit(EXIT_OK)



func _create_student() -> ProtegoStudent:
	var scene: PackedScene = load("res://protego_student.tscn")
	var student: ProtegoStudent = scene.instantiate() as ProtegoStudent
	student.set_process(false)
	root.add_child(student)
	student.global_position = Vector2(400, 300)
	await process_frame
	return student


func _test_initial_health_and_states() -> void:
	var student: ProtegoStudent = await _create_student()
	assert(student.shield_max_health == 1000.0, "Shield max health must be 1000")
	assert(student.get("_shield_health") == 1000.0, "Initial shield health must be 1000")
	assert(student.max_health == 200.0, "Base student max health must be 200")
	assert(student.get("_health") == 200.0, "Initial base health must be 200")
	assert(student.shield_sprite.visible, "Shield sprite must be visible initially")
	assert(student.shield_sprite.frame == 0, "Shield frame must be 0 initially")
	student.queue_free()
	await process_frame


func _test_shield_visual_degradation() -> void:
	var student: ProtegoStudent = await _create_student()
	student.take_damage(200.0) # 800 shield remaining (> 666.67)
	assert(student.get("_shield_health") == 800.0, "Shield health must be 800")
	assert(student.shield_sprite.frame == 0, "Shield frame 0 for > 66.6% HP")
	student.take_damage(300.0) # 500 shield remaining (<= 666.67, > 333.33)
	assert(student.get("_shield_health") == 500.0, "Shield health must be 500")
	assert(student.shield_sprite.frame == 1, "Shield frame 1 for 33.3% - 66.6% HP")
	student.take_damage(300.0) # 200 shield remaining (<= 333.33, > 0)
	assert(student.get("_shield_health") == 200.0, "Shield health must be 200")
	assert(student.shield_sprite.frame == 2, "Shield frame 2 for <= 33.3% HP")
	assert(student.get("_health") == 200.0, "Base health must remain intact at 200")
	student.queue_free()
	await process_frame


func _test_shield_break_and_base_health() -> void:
	var student: ProtegoStudent = await _create_student()
	student.take_damage(1000.0) # exactly breaks the shield
	assert(student.get("_shield_health") <= 0.0, "Shield health must be 0")
	assert(student.get("_shield_broken") == true, "Shield must be broken")
	assert(not student.shield_sprite.visible, "Shield sprite must be hidden")
	assert(student.get("_health") == 200.0, "Base health must still be 200 on exact break")
	student.take_damage(100.0) # drops base health to 100 (50%)
	assert(student.get("_health") == 100.0, "Base health must be 100")
	assert(student.get("_is_hurt") == true, "Must show hurt texture at 50% base health")
	student.take_damage(100.0) # drops base health to 0
	assert(student.get("_health") <= 0.0, "Student must be defeated at 0 base health")
	student.queue_free()
	await process_frame


func _test_overflow_damage() -> void:
	var student: ProtegoStudent = await _create_student()
	student.take_damage(950.0) # 50 shield remaining
	assert(student.get("_shield_health") == 50.0, "Shield has 50 HP")
	assert(student.get("_health") == 200.0, "Base health has 200 HP")
	student.take_damage(100.0) # 50 absorbs shield, 50 overflows to base
	assert(student.get("_shield_broken") == true, "Shield must be broken")
	assert(student.get("_health") == 150.0, "Base health must have 150 HP after 50 overflow")
	student.queue_free()
	await process_frame


func _test_massive_sweep_instakill() -> void:
	var student: ProtegoStudent = await _create_student()
	student.take_damage(1800.0) # sweep damage exceeds 1000 shield + 200 base health
	assert(student.get("_shield_broken") == true, "Shield must be broken")
	assert(student.get("_health") <= 0.0, "Student must be defeated by 1800 sweep damage")
	student.queue_free()
	await process_frame


func _test_shield_attack_texture_and_oscillation() -> void:
	var student: ProtegoStudent = await _create_student()
	var ally_scene: PackedScene = load("res://harry.tscn")
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(ally)
	ally.global_position = Vector2(380, 300)
	student._target_ally = ally
	student._update_target_state()
	_verify_attacking_visuals(student)
	_verify_shield_oscillation(student)
	student._target_ally = null
	student._update_target_state()
	_verify_walking_visuals(student)
	student.queue_free()
	ally.queue_free()
	await process_frame


func _verify_attacking_visuals(student: ProtegoStudent) -> void:
	assert(student._is_attacking, "Must be attacking")
	assert(student.sprite.texture == student.protego_attacking_texture, "Must use protego_attacking_texture")
	assert(student.sprite.hframes == 1, "Must have 1 hframe when attacking with shield")


func _verify_shield_oscillation(student: ProtegoStudent) -> void:
	var max_diff: float = 0.0
	for i in range(100):
		student._process_shield_attack(0.01)
		var diff: float = absf(student.shield_sprite.position.x - ProtegoStudent.SHIELD_BASE_X)
		max_diff = maxf(max_diff, diff)
	assert(is_equal_approx(max_diff, 4.0) or max_diff <= 4.001, "Max variation must be 4.0")
	assert(max_diff > 3.9, "Oscillation must reach near 4.0")


func _verify_walking_visuals(student: ProtegoStudent) -> void:
	assert(not student._is_attacking, "Must not be attacking")
	assert(student.sprite.texture == student.walk_texture, "Must revert to walk_texture")
	assert(student.sprite.hframes == 8, "Must revert to 8 hframes")
	student._process_shield_attack(0.016)
	assert(student.shield_sprite.position.x == ProtegoStudent.SHIELD_BASE_X, "Shield must be at base X")


func _test_attack_damage_cycle() -> void:
	var student: ProtegoStudent = await _create_student()
	var ally_scene: PackedScene = load("res://harry.tscn")
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(ally)
	ally.global_position = Vector2(380, 300)
	student._target_ally = ally
	student._update_target_state()
	var initial_hp: float = ally.health
	_step_attack_ticks(student, ally, initial_hp)
	student.queue_free()
	ally.queue_free()
	await process_frame


func _step_attack_ticks(student: ProtegoStudent, ally: Ally, initial_hp: float) -> void:
	for i in range(3):
		student._on_animation_timer_timeout()
		assert(ally.health == initial_hp, "No damage before cycle completes")
	student._on_animation_timer_timeout()
	assert(ally.health == initial_hp - student.damage_per_attack, "Damage dealt after 4 ticks")

