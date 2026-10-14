class_name Troll
extends Enemy

## Colossal brute enemy (Gargantuar equivalent): walks slowly, pauses to play
## attack animation and instakills allies in front, with massive health pool (3600 HP).

const DEFAULT_MAX_HEALTH: float = 3600.0
const DEFAULT_SPEED: float = 20.0
const INSTAKILL_DAMAGE: float = 9999.0
const FRONT_REACH_X: float = 140.0
const MIN_REACH_X: float = -40.0
const ATTACK_COOLDOWN: float = 1.0
const ATTACK_ANIM_NAME: StringName = &"attack"
const WALK_ANIM_NAME: StringName = &"Walk"

@export var damage_instakill: float = INSTAKILL_DAMAGE
@export var attack_cooldown: float = ATTACK_COOLDOWN

var _attack_cooldown_remaining: float = 0.0

@onready var animation_player: AnimationPlayer = $Animation
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var attack_collision_box: CollisionShape2D = $DetectionArea/AtackCollisionBox


func _ready() -> void:
	max_health = DEFAULT_MAX_HEALTH
	speed = DEFAULT_SPEED
	sprite = $Troll_Body
	_health = max_health
	_attack_cooldown_remaining = 0.0
	_init_slow_timer()
	_init_animation()
	update_row_z_index()
	animation_player.play(WALK_ANIM_NAME)


func _exit_tree() -> void:
	var tree: SceneTree = get_tree()
	if tree != null:
		Lane.update_trolls_z_index_in_lane(tree, global_position.y)


func update_row_z_index() -> void:
	var tree: SceneTree = get_tree()
	if tree != null:
		Lane.update_trolls_z_index_in_lane(tree, global_position.y)
	else:
		z_index = Lane.get_enemy_z_index(global_position.y, true)


func _is_troll_entity() -> bool:
	return true



func _init_animation() -> void:
	if animation_player.has_animation(ATTACK_ANIM_NAME):
		var attack_anim: Animation = animation_player.get_animation(ATTACK_ANIM_NAME)
		if attack_anim != null:
			attack_anim.loop_mode = Animation.LOOP_NONE
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
	_update_combat(delta)
	_check_garden_invasion()


func _update_combat(delta: float) -> void:
	if _attack_cooldown_remaining > 0.0:
		_attack_cooldown_remaining -= delta
	if _is_attacking:
		# Attack animation in progress. Instakill triggers when attack animation finishes.
		return
	if _attack_cooldown_remaining <= 0.0 and _has_allies_in_front():
		_start_attack()
	else:
		_process_movement(delta)


func _process_movement(delta: float) -> void:
	position.x -= speed * _slow_factor * delta


func _start_attack() -> void:
	update_row_z_index()
	_is_attacking = true
	animation_player.stop()
	animation_player.play(ATTACK_ANIM_NAME)


## Called when the Godot animation finishes.
## Delivers instakill and immediately returns to Walk mode so the Troll keeps moving forward.
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == ATTACK_ANIM_NAME:
		_execute_instakill_all()
		_is_attacking = false
		_attack_cooldown_remaining = attack_cooldown
		animation_player.play(WALK_ANIM_NAME)


func _execute_instakill_all() -> void:
	for ally: Ally in _get_allies_in_front():
		if is_instance_valid(ally) and not ally.is_queued_for_deletion() and ally.has_method(&"take_damage"):
			ally.take_damage(damage_instakill)


func _has_allies_in_front() -> bool:
	return not _get_allies_in_front().is_empty()


func _get_allies_in_front() -> Array[Ally]:
	var result: Array[Ally] = []
	var seen: Dictionary = {}
	_collect_overlapping_allies(result, seen)
	_collect_lane_allies(result, seen)
	return result


func _collect_overlapping_allies(result: Array[Ally], seen: Dictionary) -> void:
	for area: Area2D in detection_area.get_overlapping_areas():
		_try_add_ally(area, result, seen)
	for area: Area2D in get_overlapping_areas():
		_try_add_ally(area, result, seen)


func _collect_lane_allies(result: Array[Ally], seen: Dictionary) -> void:
	for ally_node: Node in get_tree().get_nodes_in_group(Groups.ALLIES):
		if ally_node is Ally and is_instance_valid(ally_node) and not ally_node.is_queued_for_deletion():
			var ally: Ally = ally_node as Ally
			if _is_ally_in_hit_box(ally):
				_try_add_ally(ally, result, seen)


func _try_add_ally(node: Node, result: Array[Ally], seen: Dictionary) -> void:
	if node is Broomstick or not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	if node.is_in_group(Groups.ALLIES) and node is Ally:
		var ally: Ally = node as Ally
		if ally.health > 0.0:
			var id: int = ally.get_instance_id()
			if not seen.has(id):
				seen[id] = true
				result.append(ally)


func _is_ally_in_hit_box(ally: Ally) -> bool:
	if not Lane.is_same_lane(ally.global_position.y, global_position.y):
		return false
	var diff_x: float = global_position.x - ally.global_position.x
	return diff_x >= MIN_REACH_X and diff_x <= FRONT_REACH_X


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area is Broomstick:
		return
	if not _is_attacking and _attack_cooldown_remaining <= 0.0 and area.is_in_group(Groups.ALLIES):
		var ally: Ally = area as Ally
		if ally != null and is_instance_valid(ally) and not ally.is_queued_for_deletion() and ally.health > 0.0:
			_start_attack()


func apply_slow(factor: float, duration: float) -> void:
	super.apply_slow(factor, duration)
	if animation_player != null:
		animation_player.speed_scale = _slow_factor


func _on_slow_timer_timeout() -> void:
	super._on_slow_timer_timeout()
	if animation_player != null:
		animation_player.speed_scale = 1.0


func _check_garden_invasion() -> void:
	if global_position.x < GARDEN_EDGE_X:
		garden_invaded.emit()
		queue_free()


func take_damage(amount: float) -> void:
	if _health <= 0.0:
		return
	_health = maxf(_health - amount, 0.0)
	damage_flash.flash()
	if _health <= 0.0:
		_die()


func _die() -> void:
	defeated.emit(self)
	queue_free()
