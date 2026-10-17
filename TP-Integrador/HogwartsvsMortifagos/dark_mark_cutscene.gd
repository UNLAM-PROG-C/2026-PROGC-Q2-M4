class_name DarkMarkCutscene
extends CanvasLayer

## Cutscene triggered in Level 10 when Quirrell reaches half health and loses his turban.
## Displays the Dark Mark emerging from Quirrell and sweeping downwards in the center of the screen.

signal animation_finished

const TEXTURE_WIDTH: float = 733.0
const TEXTURE_HEIGHT: float = 1392.0
const SKULL_PIVOT_X: float = 362.0
const SKULL_PIVOT_Y: float = 313.5
const FULL_MARK_CENTER_OFFSET_Y: float = 228.9

const SCREEN_CENTER_X: float = 960.0
const SCREEN_CENTER_Y: float = 540.0
const TARGET_SCALE: Vector2 = Vector2(0.6, 0.6)
const INITIAL_SCALE: Vector2 = Vector2(0.08, 0.08)

const OVERLAY_DIM_COLOR: Color = Color(0.0, 0.0, 0.0, 0.6)
const OVERLAY_TRANSPARENT_COLOR: Color = Color(0.0, 0.0, 0.0, 0.0)

const ZOOM_IN_DURATION: float = 2.0
const SWEEP_DURATION: float = 2.5
const HOLD_DURATION: float = 2.0
const FADE_OUT_DURATION: float = 0.6
const SKULL_FADE_IN_RATIO: float = 0.4

@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var mark_pivot: Control = $MarkPivot
@onready var full_mark_clipper: Control = $MarkPivot/FullMarkClipper
@onready var full_mark_texture: TextureRect = $MarkPivot/FullMarkClipper/FullMarkTexture
@onready var skull_texture: TextureRect = $MarkPivot/SkullTexture


func _ready() -> void:
  process_mode = Node.PROCESS_MODE_ALWAYS
  _setup_initial_visuals()


func _setup_initial_visuals() -> void:
  if dark_overlay != null:
   dark_overlay.color = OVERLAY_TRANSPARENT_COLOR
  if full_mark_clipper != null:
   full_mark_clipper.size = Vector2(TEXTURE_WIDTH, 0.0)
   full_mark_clipper.clip_contents = true
  if mark_pivot != null:
   mark_pivot.scale = INITIAL_SCALE


func play(boss_position: Vector2) -> void:
  get_tree().paused = true
  _setup_pivot_at_boss(boss_position)
  _start_cutscene_sequence()


func _setup_pivot_at_boss(boss_position: Vector2) -> void:
  mark_pivot.position = boss_position
  mark_pivot.scale = INITIAL_SCALE
  skull_texture.modulate.a = 0.0
  full_mark_clipper.size.y = 0.0


func _start_cutscene_sequence() -> void:
  var target_pos: Vector2 = Vector2(SCREEN_CENTER_X, SCREEN_CENTER_Y - FULL_MARK_CENTER_OFFSET_Y)
  var tween: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_parallel(true)
  tween.tween_property(dark_overlay, "color", OVERLAY_DIM_COLOR, ZOOM_IN_DURATION)
  tween.tween_property(mark_pivot, "position", target_pos, ZOOM_IN_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  tween.tween_property(mark_pivot, "scale", TARGET_SCALE, ZOOM_IN_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  tween.tween_property(skull_texture, "modulate:a", 1.0, ZOOM_IN_DURATION * SKULL_FADE_IN_RATIO)
  tween.set_parallel(false)
  tween.tween_callback(_start_sweep_animation)


func _start_sweep_animation() -> void:
  var tween: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(full_mark_clipper, "size:y", TEXTURE_HEIGHT, SWEEP_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  tween.tween_interval(HOLD_DURATION)
  tween.tween_callback(_start_fade_out)


func _start_fade_out() -> void:
  var tween: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_parallel(true)
  tween.tween_property(dark_overlay, "color:a", 0.0, FADE_OUT_DURATION)
  tween.tween_property(mark_pivot, "modulate:a", 0.0, FADE_OUT_DURATION)
  tween.set_parallel(false)
  tween.tween_callback(_on_cutscene_finished)


func _on_cutscene_finished() -> void:
  get_tree().paused = false
  animation_finished.emit()
  queue_free()
