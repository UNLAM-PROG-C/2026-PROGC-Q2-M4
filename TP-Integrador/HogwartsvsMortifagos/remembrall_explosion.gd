class_name RemembrallExplosion
extends Node2D

## Visual-only red smoke explosion effect for the Remembrall ally.
## Displays billowy red smoke clouds expanding across its 3x3 area of action.

const PUFF_COUNT: int = 8
const PUFF_RADIUS: float = 140.0
const CORE_INITIAL_SCALE: Vector2 = Vector2(0.5, 0.5)
const CORE_TARGET_SCALE: Vector2 = Vector2(4.3, 4.3)
const PUFF_INITIAL_SCALE: Vector2 = Vector2(0.4, 0.4)
const PUFF_TARGET_SCALE: Vector2 = Vector2(3.0, 3.0)
const EXPLOSION_DURATION: float = 0.85
const SMOKE_COLOR_CORE: Color = Color(1.0, 0.35, 0.3, 0.95)
const SMOKE_COLOR_MAIN: Color = Color(0.88, 0.12, 0.16, 0.85)
const PUFF_TEXTURE: Texture2D = preload("res://Images/smoke_puff.png")
const SMOKE_Z_INDEX: int = 600

@onready var particles: CPUParticles2D = $Particles


func _ready() -> void:
  z_index = SMOKE_Z_INDEX
  _create_core_puff()
  _create_radial_puffs()
  if particles != null:
    particles.emitting = true
  _schedule_cleanup()


func _create_core_puff() -> void:
  var core: Sprite2D = _build_puff_sprite(SMOKE_COLOR_CORE, CORE_INITIAL_SCALE)
  add_child(core)
  var tween: Tween = create_tween().set_parallel(true)
  tween.tween_property(core, "scale", CORE_TARGET_SCALE, EXPLOSION_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  tween.tween_property(core, "modulate:a", 0.0, EXPLOSION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


func _create_radial_puffs() -> void:
  for i: int in range(PUFF_COUNT):
    var angle: float = (TAU / float(PUFF_COUNT)) * float(i) + randf_range(-0.25, 0.25)
    var offset: Vector2 = Vector2(cos(angle), sin(angle)) * PUFF_RADIUS
    _spawn_puff(offset, angle)


func _spawn_puff(offset: Vector2, angle: float) -> void:
  var puff: Sprite2D = _build_puff_sprite(SMOKE_COLOR_MAIN, PUFF_INITIAL_SCALE)
  puff.rotation = angle + randf_range(-0.5, 0.5)
  add_child(puff)
  var tween: Tween = create_tween().set_parallel(true)
  tween.tween_property(puff, "position", offset, EXPLOSION_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  tween.tween_property(puff, "scale", PUFF_TARGET_SCALE, EXPLOSION_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  tween.tween_property(puff, "modulate:a", 0.0, EXPLOSION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


func _build_puff_sprite(tint: Color, initial_scale: Vector2) -> Sprite2D:
  var sprite: Sprite2D = Sprite2D.new()
  sprite.texture = PUFF_TEXTURE
  sprite.modulate = tint
  sprite.scale = initial_scale
  return sprite


func _schedule_cleanup() -> void:
  var timer: SceneTreeTimer = get_tree().create_timer(EXPLOSION_DURATION)
  timer.timeout.connect(queue_free)
