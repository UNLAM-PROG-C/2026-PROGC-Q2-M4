class_name Enemy
extends Area2D

## Base enemy: walks left along its lane, attacks the first ally it meets,
## switches to its hurt texture at half health and invades the garden at the
## left edge of the screen.

## Emitted when the enemy is defeated.
signal defeated(entity: Node2D)
## Emitted when the enemy invades the garden.
signal garden_invaded()

## Total number of frames in the animation sheet.
const TOTAL_FRAMES: int = 8
## Health fraction at or below which the hurt texture is shown.
const HURT_HEALTH_RATIO: float = 0.5
## Enemies past this x coordinate have invaded the garden.
const GARDEN_EDGE_X: float = 0.0

## Maximum health.
@export var max_health: float = 200.0
## Walking speed in pixels per second.
@export var speed: float = 32.0
## Damage dealt per second while attacking an ally.
@export var damage_per_second: float = 30.0
## Animation sheet used once hurt.
@export var hurt_texture: Texture2D

var _health: float = 0.0
var _target_ally: Ally = null
## Whether the hurt texture was already applied.
var _is_hurt: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_flash: DamageFlash = $DamageFlash


func _ready() -> void:
	_health = max_health
	# Random starting frame so not every enemy walks in sync.
	sprite.frame = randi() % TOTAL_FRAMES


func _process(delta: float) -> void:
	if is_instance_valid(_target_ally):
		# State: attacking the ally
		_target_ally.take_damage(damage_per_second * delta)
	else:
		_target_ally = null
		# State: walking towards the garden
		position.x -= speed * delta
	if global_position.x < GARDEN_EDGE_X:
		garden_invaded.emit()
		queue_free()


## Called by projectiles, the Remembrall and Dementors.
func take_damage(amount: float) -> void:
	# Already dying: avoid emitting defeated twice in the same frame.
	if _health <= 0.0:
		return
	_health = maxf(_health - amount, 0.0)
	_update_hurt_texture()
	damage_flash.flash()
	if _health <= 0.0:
		_die()


func _update_hurt_texture() -> void:
	if _is_hurt or _health > max_health * HURT_HEALTH_RATIO:
		return
	_is_hurt = true
	if hurt_texture != null:
		# Keep the current animation frame when swapping the texture.
		var current_frame: int = sprite.frame
		sprite.texture = hurt_texture
		sprite.frame = current_frame


func _die() -> void:
	defeated.emit(self)
	queue_free()


## Advances to the next frame of the animation sheet.
func _on_animation_timer_timeout() -> void:
	sprite.frame = (sprite.frame + 1) % TOTAL_FRAMES


## DetectionArea callback. Targets allies that enter attack range.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group(Groups.ALLIES):
		_target_ally = area as Ally


## DetectionArea callback. Releases the target when it leaves range.
func _on_detection_area_area_exited(area: Area2D) -> void:
	if not is_instance_valid(_target_ally) or area == _target_ally:
		_target_ally = null
