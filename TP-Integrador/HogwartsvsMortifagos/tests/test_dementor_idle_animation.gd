extends SceneTree

const DEMENTOR_SCENE_PATH: String = "res://dementor.tscn"
const TOTAL_FRAMES: int = 2
const INITIAL_FRAME: int = 0
const SECOND_FRAME: int = 1


func _init() -> void:
  _run_tests_async()


func _run_tests_async() -> void:
  var success: bool = await _run_all_tests()
  quit(0 if success else 1)


func _run_all_tests() -> bool:
  if not await _test_idle_animation():
    return false
  if not await _test_active_animation():
    return false
  print("All Dementor animation tests passed successfully!")
  return true


func _test_idle_animation() -> bool:
  var dementor: Dementor = _instantiate_dementor()
  if dementor == null:
    return false
  await process_frame
  var timer_running: bool = not dementor.animation_timer.is_stopped()
  if not timer_running:
    printerr("Dementor animation_timer is stopped while idle!")
    dementor.queue_free()
    return false
  var cycles_ok: bool = _verify_idle_frame_cycling(dementor)
  dementor.queue_free()
  return cycles_ok


func _verify_idle_frame_cycling(dementor: Dementor) -> bool:
  dementor.sprite.frame = INITIAL_FRAME
  dementor._on_animation_timer_timeout()
  if dementor.sprite.frame != SECOND_FRAME:
    printerr("Idle Dementor did not advance to frame 1: got ", dementor.sprite.frame)
    return false
  dementor._on_animation_timer_timeout()
  if dementor.sprite.frame != INITIAL_FRAME:
    printerr("Idle Dementor did not wrap to frame 0: got ", dementor.sprite.frame)
    return false
  return true


func _test_active_animation() -> bool:
  var dementor: Dementor = _instantiate_dementor()
  if dementor == null:
    return false
  await process_frame
  dementor.activate()
  var cycles_ok: bool = _verify_active_frame_cycling(dementor)
  dementor.queue_free()
  return cycles_ok


func _verify_active_frame_cycling(dementor: Dementor) -> bool:
  dementor.sprite.frame = INITIAL_FRAME
  dementor._on_animation_timer_timeout()
  if dementor.sprite.frame != SECOND_FRAME:
    printerr("Active Dementor did not advance to frame 1: got ", dementor.sprite.frame)
    return false
  dementor._on_animation_timer_timeout()
  if dementor.sprite.frame != INITIAL_FRAME:
    printerr("Active Dementor did not wrap to frame 0: got ", dementor.sprite.frame)
    return false
  return true


func _instantiate_dementor() -> Dementor:
  var scene: PackedScene = load(DEMENTOR_SCENE_PATH) as PackedScene
  if scene == null:
    printerr("Failed to load dementor.tscn")
    return null
  var dementor: Dementor = scene.instantiate() as Dementor
  root.add_child(dementor)
  return dementor
