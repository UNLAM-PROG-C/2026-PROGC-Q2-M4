extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const REMEMBRALL_SCENE_PATH: String = "res://remembrall.tscn"
const SLYTHERIN_SCENE_PATH: String = "res://slytherin_student.tscn"
const TEST_POS: Vector2 = Vector2(400.0, 432.0)
const RemembrallExplosionScript = preload("res://remembrall_explosion.gd")


func _initialize() -> void:
  print("--- Running Test Remembrall Smoke Explosion ---")
  _run_all_tests()


func _run_all_tests() -> void:
  await _test_detonation_deals_damage_and_spawns_smoke()
  await _test_smoke_explosion_visual_components()
  print("--- All Remembrall Smoke Explosion Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _setup_remembrall_scene() -> Array[Node]:
  var container: Node2D = Node2D.new()
  root.add_child(container)
  var remembrall: Remembrall = (load(REMEMBRALL_SCENE_PATH) as PackedScene).instantiate() as Remembrall
  var enemy: Enemy = (load(SLYTHERIN_SCENE_PATH) as PackedScene).instantiate() as Enemy
  remembrall.global_position = TEST_POS
  enemy.global_position = TEST_POS + Vector2(50.0, 0.0)
  container.add_child(remembrall)
  container.add_child(enemy)
  return [container, remembrall, enemy]


func _test_detonation_deals_damage_and_spawns_smoke() -> void:
  var nodes: Array[Node] = _setup_remembrall_scene()
  var container: Node2D = nodes[0] as Node2D
  var remembrall: Remembrall = nodes[1] as Remembrall
  var enemy: Enemy = nodes[2] as Enemy
  await process_frame
  await process_frame
  var initial_hp: float = enemy._health
  remembrall.detonate()
  assert(enemy._health < initial_hp, "Enemy must receive explosion damage")
  _assert_smoke_effect_spawned(container)
  container.queue_free()
  await process_frame


func _assert_smoke_effect_spawned(container: Node2D) -> void:
  var effects: Array[Node] = container.get_children().filter(func(n: Node) -> bool: return n.get_script() == RemembrallExplosionScript)
  assert(effects.size() == 1, "Must spawn one RemembrallExplosion effect")
  var effect: Node2D = effects[0] as Node2D
  assert(effect.global_position == TEST_POS, "Explosion effect must be positioned at Remembrall position")


func _test_smoke_explosion_visual_components() -> void:
  var explosion_scene: PackedScene = load("res://remembrall_explosion.tscn") as PackedScene
  var effect: Node2D = explosion_scene.instantiate() as Node2D
  root.add_child(effect)
  await process_frame
  var sprites: Array[Node] = effect.get_children().filter(func(n: Node) -> bool: return n is Sprite2D)
  assert(sprites.size() >= RemembrallExplosionScript.PUFF_COUNT, "Must spawn multiple smoke puff sprites")
  var particles: CPUParticles2D = effect.get_node_or_null("Particles") as CPUParticles2D
  assert(particles != null and particles.emitting, "Smoke particles must exist and be emitting")
  effect.queue_free()
  await process_frame
