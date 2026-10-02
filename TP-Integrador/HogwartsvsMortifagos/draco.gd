class_name Draco
extends Area2D

## Emitted when Draco is defeated.
signal defeated(entity: Node2D)
## Emitted when Draco invades the garden.
signal garden_invaded()

## Draco's maximum health. Twice a Slytherin Student's (200).
@export var max_health: int = 400
## Walking speed in pixels per second.
@export var speed: float = 32.0
## Damage dealt per second while attacking an ally.
@export var damage_per_second: float = 30.0
## Animation sheet used once hurt (< 50 % health).
@export var hurt_texture: Texture2D

## Total number of frames in the animation sheet.
const TOTAL_FRAMES: int = 8

var _health: int = 0
var _target_ally: Area2D = null
## Whether the hurt texture was already applied.
var _is_hurt: bool = false


func _ready() -> void:
	_health = max_health
	add_to_group("enemies")
	$Sprite2D.frame = randi() % TOTAL_FRAMES


func _process(delta: float) -> void:
	if is_instance_valid(_target_ally):
		if _target_ally.has_method("take_damage"):
			_target_ally.call("take_damage", damage_per_second * delta)
	else:
		_target_ally = null
		position.x -= speed * delta

	if global_position.x < 0.0:
		garden_invaded.emit()
		queue_free()


## Advances to the next frame of the animation sheet.
func _on_animation_timer_timeout() -> void:
	$Sprite2D.frame = ($Sprite2D.frame + 1) % TOTAL_FRAMES


## Applies damage to Draco. Called by projectiles on hit.
func take_damage(amount: int) -> void:
	_health = maxi(_health - amount, 0)

	if not _is_hurt and _health <= max_health / 2:
		_is_hurt = true
		if hurt_texture != null:
			var current_frame: int = $Sprite2D.frame
			$Sprite2D.texture = hurt_texture
			$Sprite2D.frame = current_frame

	$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0), 0.15)

	if _health == 0:
		defeated.emit(self)
		queue_free()


## DetectionArea callback. Targets allies that enter attack range.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("allies"):
		_target_ally = area


## DetectionArea callback. Releases the ally when it leaves range.
func _on_detection_area_area_exited(area: Area2D) -> void:
	if not is_instance_valid(_target_ally) or area == _target_ally:
		_target_ally = null
