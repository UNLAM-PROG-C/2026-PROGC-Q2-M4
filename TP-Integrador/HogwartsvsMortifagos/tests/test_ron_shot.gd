extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const EXPECTED_RON_SHOT_PATH: String = "res://Images/ron_shot.png"
const EXPECTED_DEFAULT_SHOT_PATH: String = "res://Images/projectile_effect.png"
const PROJECTILE_SCENE_PATH: String = "res://projectile.tscn"
const RON_SCENE_PATH: String = "res://ron.tscn"
const EXPECTED_SCALE: Vector2 = Vector2(0.48076922, 0.48076922)
const EXPECTED_HFRAMES: int = 4
const EXPECTED_RON_DAMAGE: float = 60.0


func _init() -> void:
	_run_all_tests()


func _run_all_tests() -> void:
	print("--- Running Test Ron Shot ---")
	await _test_projectile_ron_shot_texture()
	await _test_ron_shoots_ron_shot_from_pool()
	await _test_pool_recycling_restores_default_texture()
	print("--- All Ron Shot Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_projectile_ron_shot_texture() -> void:
	print("Testing Projectile activation with ron_shot.png...")
	var scene: PackedScene = load(PROJECTILE_SCENE_PATH) as PackedScene
	var proj: Projectile = scene.instantiate() as Projectile
	root.add_child(proj)
	await process_frame
	proj.activate(Vector2(100.0, 100.0), false, Projectile.RON_SHOT_TEXTURE)
	assert(proj.sprite.texture.resource_path == EXPECTED_RON_SHOT_PATH, "Texture must be ron_shot.png")
	assert(proj.sprite.scale.is_equal_approx(EXPECTED_SCALE), "Scale must remain 0.48076922")
	assert(proj.sprite.hframes == EXPECTED_HFRAMES, "Hframes must remain 4")
	proj.deactivate()
	assert(proj.sprite.texture.resource_path == EXPECTED_DEFAULT_SHOT_PATH, "Deactivated texture must be default")
	proj.queue_free()
	await process_frame
	print("Projectile direct activation PASSED.")


func _test_ron_shoots_ron_shot_from_pool() -> void:
	var pool: ProjectilePool = _create_test_pool()
	var ron: Ron = _create_test_ron(pool)
	await process_frame
	ron._shoot()
	_assert_ron_acquired_projectile(pool)
	ron.queue_free()
	pool.queue_free()
	await process_frame


func _create_test_pool() -> ProjectilePool:
	var pool: ProjectilePool = ProjectilePool.new()
	pool.projectile_scene = load(PROJECTILE_SCENE_PATH) as PackedScene
	root.add_child(pool)
	return pool


func _create_test_ron(pool: ProjectilePool) -> Ron:
	var ron_scene: PackedScene = load(RON_SCENE_PATH) as PackedScene
	var ron: Ron = ron_scene.instantiate() as Ron
	ron.projectile_pool = pool
	root.add_child(ron)
	return ron


func _assert_ron_acquired_projectile(pool: ProjectilePool) -> void:
	assert(pool.active_projectiles.size() == 1, "Pool must have 1 active projectile")
	var proj: Projectile = pool.active_projectiles[0]
	assert(proj.sprite.texture.resource_path == EXPECTED_RON_SHOT_PATH, "Shot texture must be ron_shot.png")
	assert(is_equal_approx(proj.damage, EXPECTED_RON_DAMAGE), "Ron shot damage must be 60.0")
	assert(proj.sprite.scale.is_equal_approx(EXPECTED_SCALE), "Scale must remain unchanged")
	assert(proj.sprite.hframes == EXPECTED_HFRAMES, "Hframes must remain 4")


func _test_pool_recycling_restores_default_texture() -> void:
	var pool: ProjectilePool = _create_test_pool()
	await process_frame
	var ron_shot: Projectile = pool.acquire_projectile(Vector2(50, 50), 60.0, false, Projectile.RON_SHOT_TEXTURE)
	assert(ron_shot.sprite.texture.resource_path == EXPECTED_RON_SHOT_PATH, "Ron shot texture")
	pool.release_all()
	await process_frame
	var normal_shot: Projectile = pool.acquire_projectile(Vector2(50, 50))
	assert(normal_shot.sprite.texture.resource_path == EXPECTED_DEFAULT_SHOT_PATH, "Subsequent shot must reset")
	pool.queue_free()
	await process_frame
