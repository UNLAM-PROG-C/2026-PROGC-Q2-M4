class_name SlytherinStudent
extends Area2D

## Emitted when the Slytherin Student is defeated.
signal defeated(entity: Node2D)
## Emitted when the Slytherin Student invades the garden.
signal garden_invaded()

## Maximum health of the Slytherin Student.
@export var max_health: int = 200
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
	add_to_group("enemigos")
	# Random starting frame so not every enemy walks in sync.
	$Sprite2D.frame = randi() % TOTAL_FRAMES


func _process(delta: float) -> void:
	if is_instance_valid(_target_ally):
		# State: attacking the ally
		if _target_ally.has_method("take_damage"):
			_target_ally.call("take_damage", damage_per_second * delta)
	else:
		_target_ally = null
		# State: walking towards the garden
		position.x -= speed * delta

	# Garden invasion condition
	if global_position.x < 0.0:
		garden_invaded.emit()
		queue_free()


## Advances to the next frame of the animation sheet.
func _on_animation_timer_timeout() -> void:
	$Sprite2D.frame = ($Sprite2D.frame + 1) % TOTAL_FRAMES


## Applies damage to the Slytherin Student. Called by projectiles on hit.
func take_damage(amount: int) -> void:
	_health = maxi(_health - amount, 0)

	# Switch to the hurt texture at 50 % of max health.
	if not _is_hurt and _health <= max_health / 2:
		_is_hurt = true
		if hurt_texture != null:
			# Keep the current animation frame when swapping the texture.
			var current_frame: int = $Sprite2D.frame
			$Sprite2D.texture = hurt_texture
			$Sprite2D.frame = current_frame

	# Damage visual effect (red flash)
	$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0), 0.15)

	if _health == 0:
		defeated.emit(self)
		queue_free()


## DetectionArea callback. Targets allies that enter attack range.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("aliados"):
		_target_ally = area


## DetectionArea callback. Releases the target when it leaves range.
func _on_detection_area_area_exited(area: Area2D) -> void:
	if not is_instance_valid(_target_ally) or area == _target_ally:
		_target_ally = null
