extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1


func _initialize() -> void:
	print("--- Running Test Troll Collision References & Z-Index ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_node_structure_and_references()
	await _test_projectile_hits_hitbox_not_attack_box()
	await _test_ally_in_attack_box_triggers_strike()
	_test_lane_row_z_index_calculation()
	_test_troll_z_index_layer_hierarchy()
	await _test_instantiated_enemy_z_indices()
	await _test_multi_troll_same_lane_separation()
	await _test_three_trolls_same_lane_separation()
	print("--- All Troll Collision References & Z-Index Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_node_structure_and_references() -> void:
	print("Testing Troll node structure and references...")
	var scene: PackedScene = load("res://troll.tscn")
	assert(scene != null, "troll.tscn must load")
	var troll: Troll = scene.instantiate() as Troll
	root.add_child(troll)
	await process_frame
	_assert_hitbox_properties(troll)
	_assert_detection_area_properties(troll)
	troll.queue_free()
	await process_frame
	print("Node structure and references PASSED.")


func _assert_hitbox_properties(troll: Troll) -> void:
	assert(troll.hitbox != null, "Troll must have a valid hitbox reference")
	assert(troll.hitbox.get_parent() == troll, "Hitbox must be a child of root Troll")
	assert(troll.hitbox.name == "Hitbox", "Hitbox must be named Hitbox")
	assert(troll.hitbox.position == Vector2(-2, -6), "Hitbox must be positioned at Vector2(-2, -6)")
	assert(troll.collision_layer == 2, "Troll root collision_layer must be 2")


func _assert_detection_area_properties(troll: Troll) -> void:
	assert(troll.detection_area != null, "Troll must have a valid detection_area reference")
	assert(troll.attack_collision_box != null, "Troll must have a valid attack_collision_box reference")
	assert(troll.attack_collision_box.get_parent() == troll.detection_area, "AtackCollisionBox child of DetectionArea")
	assert(troll.attack_collision_box.name == "AtackCollisionBox", "Named AtackCollisionBox")
	assert(troll.attack_collision_box.position == Vector2(-64, -5), "Positioned at Vector2(-64, -5)")
	assert(troll.detection_area.collision_layer == 0, "DetectionArea collision_layer must be 0")
	var is_connected: bool = troll.detection_area.area_entered.is_connected(troll._on_detection_area_area_entered)
	assert(is_connected, "DetectionArea area_entered connected")


func _test_projectile_hits_hitbox_not_attack_box() -> void:
	print("Testing projectile impacts Hitbox and ignores AtackCollisionBox...")
	var troll_scene: PackedScene = load("res://troll.tscn")
	var projectile_scene: PackedScene = load("res://projectile.tscn")
	var troll: Troll = troll_scene.instantiate() as Troll
	var projectile: Projectile = projectile_scene.instantiate() as Projectile
	root.add_child(troll)
	root.add_child(projectile)
	troll.global_position = Vector2(500, 200)
	await _assert_projectile_in_attack_box(troll, projectile)
	await _assert_projectile_in_hitbox(troll, projectile)
	projectile.queue_free()
	troll.queue_free()
	await process_frame
	print("Projectile impacts Hitbox test PASSED.")


func _assert_projectile_in_attack_box(troll: Troll, projectile: Projectile) -> void:
	var initial_health: float = troll._health
	projectile.activate(Vector2(420, 200), false)
	await process_frame
	assert(troll._health == initial_health, "Troll must NOT take damage when projectile is only in AtackCollisionBox area!")


func _assert_projectile_in_hitbox(troll: Troll, projectile: Projectile) -> void:
	var initial_health: float = troll._health
	projectile.global_position = Vector2(498, 194)
	await process_frame
	projectile._on_area_entered(troll)
	assert(troll._health < initial_health, "Troll MUST take damage when projectile impacts Hitbox on root Troll Area2D!")


func _test_ally_in_attack_box_triggers_strike() -> void:
	print("Testing ally in AtackCollisionBox triggers attack...")
	var troll_scene: PackedScene = load("res://troll.tscn")
	var ally_scene: PackedScene = load("res://harry.tscn")
	var troll: Troll = troll_scene.instantiate() as Troll
	var ally: Ally = ally_scene.instantiate() as Ally
	root.add_child(troll)
	root.add_child(ally)
	troll.global_position = Vector2(500, 200)
	await _assert_ally_detection_and_strike(troll, ally)
	troll.queue_free()
	if is_instance_valid(ally):
		ally.queue_free()
	await process_frame
	print("Ally in AtackCollisionBox strike test PASSED.")


func _assert_ally_detection_and_strike(troll: Troll, ally: Ally) -> void:
	ally.global_position = Vector2(436, 200)
	await process_frame
	assert(troll._has_allies_in_front(), "Troll must detect ally in AtackCollisionBox")
	troll._on_detection_area_area_entered(ally)
	assert(troll._is_attacking, "Troll MUST start attacking when ally enters AtackCollisionBox!")
	troll._on_animation_finished(&"attack")
	assert(ally.health <= 0.0 or not is_instance_valid(ally), "Ally in AtackCollisionBox MUST be instakilled!")


func _test_lane_row_z_index_calculation() -> void:
	print("Testing Lane row z-index calculation for all 5 rows...")
	for row_idx: int in range(5):
		var y: float = Lane.FIRST_ROW_Y + float(row_idx) * Lane.ROW_SPACING
		var regular_z: int = Lane.get_enemy_z_index(y, false)
		var troll_z: int = Lane.get_enemy_z_index(y, true)
		assert(regular_z == 10 + row_idx * 200, "Regular enemy z-index for row must match scale")
		assert(troll_z == 30 + row_idx * 200, "Troll z-index for row must match scale")
	print("Lane row z-index calculation PASSED.")


func _test_troll_z_index_layer_hierarchy() -> void:
	print("Testing Troll visual integrity and row layering...")
	for r: int in range(5):
		var reg_z: int = Lane.get_enemy_z_index_for_row(r, false)
		var troll_z: int = Lane.get_enemy_z_index_for_row(r, true)
		assert(troll_z > reg_z, "Troll must be top layer of its own row")
		assert(reg_z < troll_z + 1, "Regular enemy behind lowest Troll limb")
		if r < 4:
			var next_reg_z: int = Lane.get_enemy_z_index_for_row(r + 1, false)
			assert(next_reg_z > troll_z + 6, "Next row in front of highest Troll limb")
	print("Troll visual integrity and row layering PASSED.")


func _test_instantiated_enemy_z_indices() -> void:
	print("Testing instantiated Enemy and Troll z_index values...")
	var troll_scene: PackedScene = load("res://troll.tscn")
	var enemy_scene: PackedScene = load("res://slytherin_student.tscn")
	var troll: Troll = troll_scene.instantiate() as Troll
	var enemy: Enemy = enemy_scene.instantiate() as Enemy
	root.add_child(troll)
	root.add_child(enemy)
	_verify_enemy_positions_z_indices(troll, enemy)
	troll.queue_free()
	enemy.queue_free()
	await process_frame
	print("Instantiated Enemy and Troll z_index PASSED.")


func _verify_enemy_positions_z_indices(troll: Troll, enemy: Enemy) -> void:
	for row: int in range(5):
		var row_y: float = Lane.FIRST_ROW_Y + float(row) * Lane.ROW_SPACING
		troll.global_position.y = row_y
		enemy.global_position.y = row_y
		troll.update_row_z_index()
		enemy.update_row_z_index()
		assert(enemy.z_index == 10 + row * 200, "Enemy z_index must update to row value")
		assert(troll.z_index == 30 + row * 200, "Troll z_index must update to row value")


func _test_multi_troll_same_lane_separation() -> void:
	print("Testing multiple Trolls in same lane do not overlap layers...")
	var scene: PackedScene = load("res://troll.tscn")
	var front_troll: Troll = scene.instantiate() as Troll
	var back_troll: Troll = scene.instantiate() as Troll
	root.add_child(front_troll)
	root.add_child(back_troll)
	front_troll.global_position = Vector2(400, Lane.FIRST_ROW_Y)
	back_troll.global_position = Vector2(700, Lane.FIRST_ROW_Y)
	Lane.update_trolls_z_index_in_lane(root.get_tree(), Lane.FIRST_ROW_Y)
	_assert_two_troll_layer_separation(front_troll, back_troll)
	front_troll.queue_free()
	back_troll.queue_free()
	await process_frame
	print("Multiple Trolls in same lane separation PASSED.")


func _assert_two_troll_layer_separation(front_troll: Troll, back_troll: Troll) -> void:
	assert(front_troll.z_index == 40, "Front Troll must have slot 1 (z=40)")
	assert(back_troll.z_index == 30, "Back Troll must have slot 0 (z=30)")
	var back_troll_max_limb_z: int = back_troll.z_index + 6
	var front_troll_min_limb_z: int = front_troll.z_index + 1
	assert(back_troll_max_limb_z < front_troll_min_limb_z, "Back Troll top limb below front Troll bottom limb")


func _test_three_trolls_same_lane_separation() -> void:
	print("Testing three Trolls in same lane have disjoint layer bands...")
	var scene: PackedScene = load("res://troll.tscn")
	var trolls: Array[Troll] = [scene.instantiate() as Troll, scene.instantiate() as Troll, scene.instantiate() as Troll]
	for t: Troll in trolls:
		root.add_child(t)
	_position_and_update_three_trolls(trolls)
	_assert_three_trolls_bands(trolls[0], trolls[1], trolls[2])
	for t: Troll in trolls:
		t.queue_free()
	await process_frame
	print("Three Trolls in same lane separation PASSED.")


func _position_and_update_three_trolls(trolls: Array[Troll]) -> void:
	trolls[0].global_position = Vector2(300, Lane.FIRST_ROW_Y)
	trolls[1].global_position = Vector2(600, Lane.FIRST_ROW_Y)
	trolls[2].global_position = Vector2(900, Lane.FIRST_ROW_Y)
	Lane.update_trolls_z_index_in_lane(root.get_tree(), Lane.FIRST_ROW_Y)


func _assert_three_trolls_bands(t1: Troll, t2: Troll, t3: Troll) -> void:
	assert(t1.z_index == 50, "T1 must have slot 2 (z=50)")
	assert(t2.z_index == 40, "T2 must have slot 1 (z=40)")
	assert(t3.z_index == 30, "T3 must have slot 0 (z=30)")
	assert(t3.z_index + 6 < t2.z_index + 1, "T3 highest limb below T2 lowest limb")
	assert(t2.z_index + 6 < t1.z_index + 1, "T2 highest limb below T1 lowest limb")
