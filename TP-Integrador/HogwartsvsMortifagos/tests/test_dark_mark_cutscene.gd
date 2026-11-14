extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const CUTSCENE_SCENE_PATH: String = "res://dark_mark_cutscene.tscn"
const CUTSCENE_SCRIPT: GDScript = preload("res://dark_mark_cutscene.gd")
const QUIRRELL_SCENE_PATH: String = "res://quirrell.tscn"


func _initialize() -> void:
  print("--- Running Test Dark Mark Cutscene ---")
  _run_all_tests()


func _run_all_tests() -> void:
  await _test_cutscene_structure_and_layering()
  await _test_cutscene_play_state_and_pausing()
  await _test_quirrell_phase_two_signal_emission()
  await _test_cutscene_completion_and_unpause()
  print("--- All Dark Mark Cutscene Tests Passed Successfully! ---")
  quit(EXIT_OK)


func _test_cutscene_structure_and_layering() -> void:
  var scene: PackedScene = load(CUTSCENE_SCENE_PATH) as PackedScene
  assert(scene != null, "Cutscene scene must load")
  var cutscene: CanvasLayer = scene.instantiate() as CanvasLayer
  root.add_child(cutscene)
  await process_frame
  _assert_cutscene_nodes(cutscene)
  cutscene.queue_free()
  await process_frame


func _assert_cutscene_nodes(cutscene: CanvasLayer) -> void:
  assert(cutscene.process_mode == Node.PROCESS_MODE_ALWAYS, "Cutscene must process always")
  assert(cutscene.get("dark_overlay") != null, "Overlay must exist")
  assert(cutscene.get("mark_pivot") != null, "Pivot must exist")
  var clipper: Control = cutscene.get("full_mark_clipper") as Control
  assert(clipper != null, "Clipper must exist")
  assert(clipper.clip_contents, "Clipper must clip contents")
  var skull: TextureRect = cutscene.get("skull_texture") as TextureRect
  assert(skull != null, "Skull texture must exist")
  assert(cutscene.get("full_mark_texture") != null, "Full mark texture must exist")
  assert(skull.get_index() > clipper.get_index(), "Skull must be rendered in front of full mark clipper")


func _test_cutscene_play_state_and_pausing() -> void:
  var scene: PackedScene = load(CUTSCENE_SCENE_PATH) as PackedScene
  var cutscene: CanvasLayer = scene.instantiate() as CanvasLayer
  root.add_child(cutscene)
  await process_frame
  var test_pos: Vector2 = Vector2(1600, 400)
  cutscene.call("play", test_pos)
  assert(paused == true, "Play must pause the scene tree")
  var pivot: Control = cutscene.get("mark_pivot") as Control
  assert(pivot.position == test_pos, "Initial pivot must be at boss pos")
  assert(pivot.scale == CUTSCENE_SCRIPT.INITIAL_SCALE, "Initial scale 0.08")
  var clipper: Control = cutscene.get("full_mark_clipper") as Control
  assert(clipper.size.y == 0.0, "Initial sweep height 0")
  cutscene.call("_on_cutscene_finished")
  await process_frame


func _test_quirrell_phase_two_signal_emission() -> void:
  var scene: PackedScene = load(QUIRRELL_SCENE_PATH) as PackedScene
  assert(scene != null, "Quirrell scene must load")
  var quirrell: Quirrell = scene.instantiate() as Quirrell
  root.add_child(quirrell)
  quirrell.global_position = Vector2(1700, 500)
  await process_frame
  var emitted_pos: Array[Vector2] = []
  quirrell.phase_two_started.connect(func(pos: Vector2) -> void: emitted_pos.append(pos))
  quirrell.take_damage(Quirrell.BOSS_MAX_HEALTH * 0.5)
  _assert_quirrell_phase_two_state(quirrell, emitted_pos)
  quirrell.queue_free()
  await process_frame


func _assert_quirrell_phase_two_state(quirrell: Quirrell, emitted_pos: Array[Vector2]) -> void:
  assert(quirrell.current_phase == 2, "Quirrell must enter phase 2")
  assert(not quirrell.turban_sprite.visible, "Turban must be removed")
  assert(emitted_pos.size() == 1, "phase_two_started must be emitted once")
  assert(emitted_pos[0] == quirrell.global_position, "Emitted pos must match boss pos")


func _test_cutscene_completion_and_unpause() -> void:
  var scene: PackedScene = load(CUTSCENE_SCENE_PATH) as PackedScene
  var cutscene: CanvasLayer = scene.instantiate() as CanvasLayer
  root.add_child(cutscene)
  await process_frame
  paused = true
  var signal_fired: Array[bool] = []
  cutscene.connect("animation_finished", func() -> void: signal_fired.append(true))
  cutscene.call("_on_cutscene_finished")
  assert(paused == false, "Tree must be unpaused on cutscene finished")
  assert(signal_fired.size() == 1, "animation_finished signal must fire")
  await process_frame
