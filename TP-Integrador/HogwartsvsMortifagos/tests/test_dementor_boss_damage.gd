extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const DEMENTOR_SCENE_PATH: String = "res://dementor.tscn"
const QUIRRELL_SCENE_PATH: String = "res://quirrell.tscn"
const SLYTHERIN_SCENE_PATH: String = "res://slytherin_student.tscn"
const DEMENTOR_START_POS: Vector2 = Vector2(160.0, 432.0)
const QUIRRELL_START_POS: Vector2 = Vector2(1711.0, 432.0)
const ENEMY_START_POS: Vector2 = Vector2(190.0, 432.0)
const PHYSICS_DELTA: float = 0.016
const REPEAT_SWEEP_FRAMES: int = 10


func _initialize() -> void:
  print("--- Running Test Dementor Boss Damage ---")
  _run_tests()


func _run_tests() -> void:
  await _test_dementor_deals_tenth_health_to_quirrell()
  await _test_same_dementor_does_not_hit_quirrell_twice()
  await _test_second_dementor_deals_another_tenth()
  await _test_regular_enemy_instakilled_by_dementor()
  print("--- All Dementor Boss Damage Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _create_dementor() -> Dementor:
  var d_scene: PackedScene = load(DEMENTOR_SCENE_PATH) as PackedScene
  var dementor: Dementor = d_scene.instantiate() as Dementor
  dementor.position = DEMENTOR_START_POS
  root.add_child(dementor)
  return dementor


func _create_quirrell() -> Quirrell:
  var q_scene: PackedScene = load(QUIRRELL_SCENE_PATH) as PackedScene
  var quirrell: Quirrell = q_scene.instantiate() as Quirrell
  quirrell.position = QUIRRELL_START_POS
  root.add_child(quirrell)
  return quirrell


func _apply_dementor_sweep(dementor: Dementor, target_pos: Vector2) -> void:
  dementor.activate()
  dementor.global_position = target_pos
  dementor._process_sweeping(PHYSICS_DELTA)


func _cleanup_nodes(nodes: Array[Node]) -> void:
  for node: Node in nodes:
    if is_instance_valid(node):
      node.queue_free()


func _test_dementor_deals_tenth_health_to_quirrell() -> void:
  var dementor: Dementor = _create_dementor()
  var quirrell: Quirrell = _create_quirrell()
  await process_frame
  _apply_dementor_sweep(dementor, QUIRRELL_START_POS)
  var dmg: float = Quirrell.BOSS_MAX_HEALTH * Dementor.BOSS_DAMAGE_FRACTION
  assert(is_equal_approx(quirrell._health, Quirrell.BOSS_MAX_HEALTH - dmg), "Quirrell loses 1/10th")
  assert(quirrell._health > 0.0, "Quirrell not instakilled")
  _cleanup_nodes([dementor, quirrell])
  await process_frame


func _test_same_dementor_does_not_hit_quirrell_twice() -> void:
  var dementor: Dementor = _create_dementor()
  var quirrell: Quirrell = _create_quirrell()
  await process_frame
  _apply_dementor_sweep(dementor, QUIRRELL_START_POS)
  var hp_after_hit: float = quirrell._health
  for i: int in range(REPEAT_SWEEP_FRAMES):
    dementor._process_sweeping(PHYSICS_DELTA)
    await process_frame
  assert(is_equal_approx(quirrell._health, hp_after_hit), "Same dementor must not hit twice")
  _cleanup_nodes([dementor, quirrell])
  await process_frame


func _test_second_dementor_deals_another_tenth() -> void:
  var dementor1: Dementor = _create_dementor()
  var dementor2: Dementor = _create_dementor()
  var quirrell: Quirrell = _create_quirrell()
  await process_frame
  var dmg: float = Quirrell.BOSS_MAX_HEALTH * Dementor.BOSS_DAMAGE_FRACTION
  _apply_dementor_sweep(dementor1, QUIRRELL_START_POS)
  assert(is_equal_approx(quirrell._health, Quirrell.BOSS_MAX_HEALTH - dmg), "Hit 1 takes 1/10th")
  _apply_dementor_sweep(dementor2, QUIRRELL_START_POS)
  assert(is_equal_approx(quirrell._health, Quirrell.BOSS_MAX_HEALTH - (dmg * 2.0)), "Hit 2 takes another 1/10th")
  _cleanup_nodes([dementor1, dementor2, quirrell])
  await process_frame


func _test_regular_enemy_instakilled_by_dementor() -> void:
  var dementor: Dementor = _create_dementor()
  var s_scene: PackedScene = load(SLYTHERIN_SCENE_PATH) as PackedScene
  var enemy: Enemy = s_scene.instantiate() as Enemy
  enemy.position = ENEMY_START_POS
  root.add_child(enemy)
  await process_frame
  var enemy_died: bool = not is_instance_valid(enemy) or enemy.is_queued_for_deletion()
  if not enemy_died:
    enemy_died = enemy._health <= 0.0
  assert(enemy_died, "Regular enemy must be instakilled")
  if is_instance_valid(dementor):
    dementor.queue_free()
  if is_instance_valid(enemy):
    enemy.queue_free()
  await process_frame
