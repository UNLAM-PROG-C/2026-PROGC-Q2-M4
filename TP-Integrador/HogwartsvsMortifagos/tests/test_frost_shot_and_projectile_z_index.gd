extends SceneTree

const PROJECTILE_SCENE_PATH: String = "res://projectile.tscn"
const DUMBLEDORE_PROJECTILE_PATH: String = "res://dumbledore_projectile.tscn"
const ENEMY_PROJECTILE_PATH: String = "res://enemy_projectile.tscn"
const HARRY_SCENE_PATH: String = "res://harry.tscn"


func _init() -> void:
  _run_tests_async()


func _run_tests_async() -> void:
  var success: bool = await _run_all_tests()
  quit(0 if success else 1)


func _run_all_tests() -> bool:
  if not await _test_frost_shot_texture_and_no_filter():
    return false
  if not await _test_z_index_hierarchy_across_rows():
    return false
  if not await _test_instantiated_projectiles_z_index():
    return false
  print("All frost shot and projectile z-index tests passed successfully!")
  return true


func _test_frost_shot_texture_and_no_filter() -> bool:
  var scene: PackedScene = load(PROJECTILE_SCENE_PATH) as PackedScene
  var proj: Projectile = scene.instantiate() as Projectile
  root.add_child(proj)
  await process_frame
  proj.activate(Vector2(200, Lane.FIRST_ROW_Y), true)
  var active_ok: bool = _verify_frost_active(proj)
  proj.deactivate()
  var deact_ok: bool = _verify_frost_deact(proj)
  proj.queue_free()
  return active_ok and deact_ok


func _verify_frost_active(proj: Projectile) -> bool:
  if not proj.sprite.texture.resource_path.ends_with("frost_shot.png"):
    printerr("Hermione shot did not use frost_shot.png: ", proj.sprite.texture.resource_path)
    return false
  if proj.sprite.modulate != Color.WHITE:
    printerr("Hermione shot still has a modulate tint filter applied!")
    return false
  return true


func _verify_frost_deact(proj: Projectile) -> bool:
  if not proj.sprite.texture.resource_path.ends_with("projectile_effect.png"):
    printerr("Deactivated shot did not restore default texture!")
    return false
  return true


func _test_z_index_hierarchy_across_rows() -> bool:
  for r: int in range(Lane.ROW_COUNT):
    if not _verify_row_hierarchy(r):
      return false
  return true


func _verify_row_hierarchy(r: int) -> bool:
  var ally_z: int = Lane.get_ally_z_index_for_row(r)
  var reg_z: int = Lane.get_enemy_z_index_for_row(r, false)
  var troll_z: int = Lane.get_enemy_z_index_for_row(r, true)
  var proj_z: int = Lane.get_projectile_z_index_for_row(r)
  if proj_z <= ally_z or proj_z <= reg_z or proj_z <= troll_z:
    printerr("Projectile not in front of characters in row ", r)
    return false
  return true


func _test_instantiated_projectiles_z_index() -> bool:
  var ps: PackedScene = load(PROJECTILE_SCENE_PATH) as PackedScene
  var ds: PackedScene = load(DUMBLEDORE_PROJECTILE_PATH) as PackedScene
  var es: PackedScene = load(ENEMY_PROJECTILE_PATH) as PackedScene
  var hs: PackedScene = load(HARRY_SCENE_PATH) as PackedScene
  for r: int in range(Lane.ROW_COUNT):
    var y: float = Lane.FIRST_ROW_Y + float(r) * Lane.ROW_SPACING
    if not await _verify_row_instances(ps, ds, es, hs, r, y):
      return false
  return true


func _verify_row_instances(ps: PackedScene, ds: PackedScene, es: PackedScene, hs: PackedScene, r: int, y: float) -> bool:
  var p: Projectile = ps.instantiate() as Projectile
  var d: DumbledoreProjectile = ds.instantiate() as DumbledoreProjectile
  var ep: EnemyProjectile = es.instantiate() as EnemyProjectile
  var h: Harry = hs.instantiate() as Harry
  _add_and_pos_instances(p, d, ep, h, y)
  var ok: bool = _check_instance_z(p.z_index, d.z_index, ep.z_index, h.z_index, r)
  p.queue_free()
  d.queue_free()
  ep.queue_free()
  h.queue_free()
  return ok


func _add_and_pos_instances(p: Projectile, d: Node2D, ep: Node2D, h: Node2D, y: float) -> void:
  root.add_child(p)
  root.add_child(d)
  root.add_child(ep)
  root.add_child(h)
  p.activate(Vector2(200, y))
  d.global_position = Vector2(200, y)
  d.call(&"update_row_z_index")
  ep.global_position = Vector2(200, y)
  ep.call(&"update_row_z_index")
  h.global_position = Vector2(200, y)
  h.call(&"update_row_z_index")


func _check_instance_z(pz: int, dz: int, epz: int, hz: int, r: int) -> bool:
  var expected_pz: int = Lane.get_projectile_z_index_for_row(r)
  var expected_hz: int = Lane.get_ally_z_index_for_row(r)
  if pz != expected_pz or dz != expected_pz or epz != expected_pz:
    printerr("Projectile instance z_index mismatch in row ", r)
    return false
  if hz != expected_hz or pz <= hz:
    printerr("Ally instance z_index mismatch or behind ally in row ", r)
    return false
  return true
