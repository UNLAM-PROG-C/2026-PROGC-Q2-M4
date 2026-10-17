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
const SLOW_TINT_COLOR: Color = Color(0.5, 0.75, 1.0)
const MIN_SLOW_FACTOR: float = 0.70

## Maximum health.
@export var max_health: float = 200.0
## Walking speed in pixels per second.
@export var speed: float = 32.0
## Damage dealt per second while attacking an ally.
@export var damage_per_second: float = 30.0
## Damage dealt per attack cycle once the attack animation loop finishes.
@export var damage_per_attack: float = 30.0
## Animation sheet used once hurt.
@export var hurt_texture: Texture2D
## Walking animation sheet.
@export var walk_texture: Texture2D
## Attacking animation sheet.
@export var attacking_texture: Texture2D
## Attacking animation sheet used once hurt.
@export var hurt_attacking_texture: Texture2D

var _health: float = 0.0
var _target_ally: Ally = null
## Whether the hurt texture was already applied.
var _is_hurt: bool = false
var _is_attacking: bool = false
var _slow_factor: float = 1.0
var _base_modulate: Color = Color.WHITE
var _slow_timer: Timer
var _animation_timer: Timer = null
var _base_animation_interval: float = 0.25

var sprite: Sprite2D = null

@onready var damage_flash: DamageFlash = $DamageFlash


func _ready() -> void:
	_init_sprite()
	_health = max_health
	if walk_texture != null:
		sprite.texture = walk_texture
	# Random starting frame so not every enemy walks in sync.
	if sprite != null and TOTAL_FRAMES > 0:
		sprite.frame = randi() % TOTAL_FRAMES
	_init_slow_timer()
	_init_animation_timer()
	update_row_z_index()


func update_row_z_index() -> void:
	z_index = Lane.get_enemy_z_index(global_position.y, _is_troll_entity())


func _is_troll_entity() -> bool:
	return false


func occupies_lane_y(lane_y: float) -> bool:
	return Lane.is_same_lane(global_position.y, lane_y)


func _init_sprite() -> void:
	sprite = get_node_or_null("Sprite2D") as Sprite2D


func _init_slow_timer() -> void:
	_slow_timer = Timer.new()
	_slow_timer.one_shot = true
	_slow_timer.timeout.connect(_on_slow_timer_timeout)
	add_child(_slow_timer)


func _init_animation_timer() -> void:
	_animation_timer = get_node_or_null("AnimationTimer") as Timer
	if _animation_timer != null:
		_base_animation_interval = _animation_timer.wait_time


func _process(delta: float) -> void:
	_update_target_state()
	_process_actions(delta)
	if global_position.x < GARDEN_EDGE_X:
		garden_invaded.emit()
		queue_free()


func _update_target_state() -> void:
	var has_attack_target: bool = is_instance_valid(_target_ally)
	if has_attack_target != _is_attacking:
		_is_attacking = has_attack_target
		_update_animation_texture()


func _process_actions(delta: float) -> void:
	if is_instance_valid(_target_ally):
		return
	_target_ally = null
	position.x -= speed * _slow_factor * delta


func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = minf(_slow_factor, maxf(factor, MIN_SLOW_FACTOR))
	_base_modulate = SLOW_TINT_COLOR
	sprite.modulate = _base_modulate
	sprite.set_meta(&"base_modulate", _base_modulate)
	if _animation_timer != null and _slow_factor > 0.0:
		_animation_timer.wait_time = _base_animation_interval / _slow_factor
	_slow_timer.start(duration)


func _on_slow_timer_timeout() -> void:
	_slow_factor = 1.0
	_base_modulate = Color.WHITE
	sprite.modulate = _base_modulate
	sprite.set_meta(&"base_modulate", _base_modulate)
	if _animation_timer != null:
		_animation_timer.wait_time = _base_animation_interval


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
	_update_animation_texture()


func _update_animation_texture() -> void:
	var next_texture: Texture2D = _walking_texture()
	var frame_count: int = TOTAL_FRAMES
	if _is_attacking:
		next_texture = attacking_texture if not _is_hurt else hurt_attacking_texture
		frame_count = 4
	elif _is_hurt:
		next_texture = hurt_texture
	if next_texture != null:
		_apply_next_texture(next_texture, frame_count)


func _apply_next_texture(next_texture: Texture2D, frame_count: int) -> void:
	var previous_frame_size: Vector2 = _frame_size(sprite.texture, sprite.hframes)
	var previous_left_edge: float = sprite.position.x - previous_frame_size.x * absf(sprite.scale.x) * 0.5
	sprite.texture = next_texture
	sprite.hframes = frame_count
	sprite.frame = 0 if _is_attacking else (sprite.frame % frame_count)
	var next_frame_size: Vector2 = _frame_size(next_texture, frame_count)
	sprite.position.x = previous_left_edge + next_frame_size.x * absf(sprite.scale.x) * 0.5


func _frame_size(texture: Texture2D, frame_count: int) -> Vector2:
	return Vector2(
		float(texture.get_width()) / float(frame_count),
		float(texture.get_height())
	)


func _walking_texture() -> Texture2D:
	return walk_texture


func _die() -> void:
	defeated.emit(self)
	queue_free()


## Advances to the next frame of the animation sheet.
## Deals attack damage only upon finishing the attack animation loop.
func _on_animation_timer_timeout() -> void:
	if sprite == null or sprite.hframes <= 0:
		return
	var next_frame: int = (sprite.frame + 1) % sprite.hframes
	var loop_finished: bool = (next_frame == 0)
	sprite.frame = next_frame
	if _is_attacking and loop_finished:
		_deal_attack_damage()


func _deal_attack_damage() -> void:
	if is_instance_valid(_target_ally) and _target_ally.has_method(&"take_damage"):
		var damage_amount: float = damage_per_attack if damage_per_attack > 0.0 else damage_per_second
		_target_ally.take_damage(damage_amount)


## DetectionArea callback. Targets allies that enter attack range.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area is Broomstick:
		return
	if area.is_in_group(Groups.ALLIES):
		_target_ally = area as Ally


## DetectionArea callback. Releases the target when it leaves range.
func _on_detection_area_area_exited(area: Area2D) -> void:
	if area is Broomstick:
		return
	if not is_instance_valid(_target_ally) or area == _target_ally:
		_target_ally = null
