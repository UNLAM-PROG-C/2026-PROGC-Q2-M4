class_name WaveProgressBar
extends Control

## Visual hourglass progress meter showing kill progression towards waves.

const FILL_MODE_BOTTOM_TO_TOP: int = 3

@onready var progress_bar: TextureProgressBar = $ProgressBar


func _get_bar() -> TextureProgressBar:
  if progress_bar == null:
    progress_bar = get_node_or_null("ProgressBar") as TextureProgressBar
  return progress_bar


func setup(max_kills: int, frame_texture: Texture2D) -> void:
  var bar: TextureProgressBar = _get_bar()
  if is_instance_valid(bar):
    bar.max_value = float(max_kills)
    bar.value = 0.0
    bar.texture_over = frame_texture


func update_progress(current_kills: int) -> void:
  var bar: TextureProgressBar = _get_bar()
  if is_instance_valid(bar):
    bar.value = clampf(float(current_kills), 0.0, bar.max_value)


func get_progress_value() -> float:
  var bar: TextureProgressBar = _get_bar()
  if is_instance_valid(bar):
    return bar.value
  return 0.0
