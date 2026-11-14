extends SceneTree

const PROJECTILE_SCENE_PATH: String = "res://projectile.tscn"
const ENEMY_SCENE_PATH: String = "res://slytherin_student.tscn"
const SNITCH_BOX_SCENE_PATH: String = "res://snitch_box.tscn"
const SNITCH_SCENE_PATH: String = "res://snitch.tscn"


func _init() -> void:
  _run_tests_async()


func _run_tests_async() -> void:
  var success: bool = await _run_all_tests()
  quit(0 if success else 1)


func _run_all_tests() -> bool:
  if not await _test_projectile_hits_enemy():
    return false
  if not await _test_snitch_in_front_of_box_all_rows():
    return false
  if not await _test_snitch_above_all_elements():
    return false
  print("All projectile hit and snitch depth tests passed successfully!")
  return true


func _test_projectile_hits_enemy() -> bool:
  var p_scene: PackedScene = load(PROJECTILE_SCENE_PATH) as PackedScene
  var e_scene: PackedScene = load(ENEMY_SCENE_PATH) as PackedScene
  var proj: Projectile = p_scene.instantiate() as Projectile
  var enemy: Enemy = e_scene.instantiate() as Enemy
  root.add_child(proj)
  root.add_child(enemy)
  await process_frame
  enemy.global_position = Vector2(300, Lane.FIRST_ROW_Y)
  proj.activate(Vector2(300, Lane.FIRST_ROW_Y))
  var initial_hp: float = enemy.get("_health") as float
  proj._on_area_entered(enemy)
  var ok: bool = _verify_hit_results(enemy, initial_hp, proj)
  proj.queue_free()
  enemy.queue_free()
  return ok


func _verify_hit_results(enemy: Enemy, initial_hp: float, proj: Projectile) -> bool:
  var current_hp: float = enemy.get("_health") as float
  if current_hp >= initial_hp:
    printerr("Enemy did not take damage from projectile: ", current_hp)
    return false
  if current_hp != initial_hp - proj.damage:
    printerr("Damage mismatch: got ", current_hp, " expected ", initial_hp - proj.damage)
    return false
  return true


func _test_snitch_in_front_of_box_all_rows() -> bool:
  var box_scene: PackedScene = load(SNITCH_BOX_SCENE_PATH) as PackedScene
  var snitch_scene: PackedScene = load(SNITCH_SCENE_PATH) as PackedScene
  for r: int in range(Lane.ROW_COUNT):
    var y: float = Lane.FIRST_ROW_Y + float(r) * Lane.ROW_SPACING
    if not await _verify_box_snitch_row(box_scene, snitch_scene, y, r):
      return false
  return true


func _verify_box_snitch_row(bs: PackedScene, ss: PackedScene, y: float, r: int) -> bool:
  var box: SnitchBox = bs.instantiate() as SnitchBox
  var snitch: Snitch = ss.instantiate() as Snitch
  root.add_child(box)
  root.add_child(snitch)
  box.global_position = Vector2(200, y)
  box.update_row_z_index()
  snitch.setup_from_box(box.global_position)
  await process_frame
  var ok: bool = _assert_snitch_in_front(box, snitch, r)
  box.queue_free()
  snitch.queue_free()
  return ok


func _assert_snitch_in_front(box: SnitchBox, snitch: Snitch, r: int) -> bool:
  var sprite: Sprite2D = snitch.get_node_or_null("Sprite2D") as Sprite2D
  if sprite == null:
    printerr("Snitch has no Sprite2D child")
    return false
  var snitch_visual_z: int = snitch.z_index + sprite.z_index
  if snitch_visual_z <= box.z_index:
    printerr("Snitch sprite (", snitch_visual_z, ") behind box (", box.z_index, ") in row ", r)
    return false
  return true


func _test_snitch_above_all_elements() -> bool:
  var snitch_scene: PackedScene = load(SNITCH_SCENE_PATH) as PackedScene
  var snitch: Snitch = snitch_scene.instantiate() as Snitch
  root.add_child(snitch)
  await process_frame
  snitch.setup_sky_fall(Lane.FIRST_ROW_Y)
  var ok: bool = _verify_snitch_z_above_elements(snitch)
  snitch.queue_free()
  return ok


func _verify_snitch_z_above_elements(snitch: Snitch) -> bool:
  var sprite: Sprite2D = snitch.get_node_or_null("Sprite2D") as Sprite2D
  var snitch_z: int = snitch.z_index + (sprite.z_index if sprite != null else 0)
  for r: int in range(Lane.ROW_COUNT):
    if not _check_snitch_exceeds_row_elements(snitch_z, r):
      return false
  return true


func _check_snitch_exceeds_row_elements(snitch_z: int, r: int) -> bool:
  var ally_z: int = Lane.get_ally_z_index_for_row(r)
  var enemy_z: int = Lane.get_enemy_z_index_for_row(r, false)
  var troll_z: int = Lane.get_enemy_z_index_for_row(r, true)
  var proj_z: int = Lane.get_projectile_z_index_for_row(r)
  if snitch_z <= ally_z or snitch_z <= enemy_z or snitch_z <= troll_z or snitch_z <= proj_z:
    printerr("Snitch z (", snitch_z, ") not above all row ", r, " elements")
    return false
  return true

