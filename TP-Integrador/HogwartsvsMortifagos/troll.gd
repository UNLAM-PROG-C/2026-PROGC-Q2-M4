class_name Troll
extends Enemy

## Colossal brute enemy (Gargantuar equivalent): walks slowly, pauses to play
## attack animation and instakills allies in front, with massive health pool (3600 HP).

const DEFAULT_MAX_HEALTH: float = 3600.0
const DEFAULT_SPEED: float = 20.0
const INSTAKILL_DAMAGE: float = 9999.0
const SMASH_HIT_DELAY: float = 1.0
const ATTACK_TOTAL_DURATION: float = 1.6
const FRONT_REACH_X: float = 140.0
const MIN_REACH_X: float = -40.0
const ATTACK_ANIM_NAME: StringName = &"attack"
const WALK_ANIM_NAME: StringName = &"Walk"

@export var damage_instakill: float = INSTAKILL_DAMAGE

var _attack_timer: float = 0.0
var _has_smashed: bool = false

@onready var animation_player: AnimationPlayer = $Animation
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	max_health = DEFAULT_MAX_HEALTH
	speed = DEFAULT_SPEED
	sprite = $Troll_Body
	_health = max_health
	_init_slow_timer()
	animation_player.play(WALK_ANIM_NAME)


func _process(delta: float) -> void:
	_update_combat(delta)
	_check_garden_invasion()


func _update_combat(delta: float) -> void:
	if _is_attacking:
		_process_attack_cycle(delta)
	elif _has_allies_in_front():
		_start_attack()
	else:
		_process_movement(delta)


func _process_movement(delta: float) -> void:
	position.x -= speed * _slow_factor * delta


func _process_attack_cycle(delta: float) -> void:
	_attack_timer += delta
	if not _has_smashed and _attack_timer >= SMASH_HIT_DELAY:
		_has_smashed = true
		_execute_instakill_all()
	if _attack_timer >= ATTACK_TOTAL_DURATION:
		_finish_attack()


func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = 0.0
	_has_smashed = false
	animation_player.play(ATTACK_ANIM_NAME)


func _finish_attack() -> void:
	if _has_allies_in_front():
		_start_attack()
	else:
		_is_attacking = false
		animation_player.play(WALK_ANIM_NAME)


func _execute_instakill_all() -> void:
	for ally: Ally in _get_allies_in_front():
		if is_instance_valid(ally) and ally.has_method(&"take_damage"):
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
		if ally_node is Ally and is_instance_valid(ally_node):
			var ally: Ally = ally_node as Ally
			if _is_ally_in_hit_box(ally):
				_try_add_ally(ally, result, seen)


func _try_add_ally(node: Node, result: Array[Ally], seen: Dictionary) -> void:
	if node != null and node.is_in_group(Groups.ALLIES) and is_instance_valid(node):
		var id: int = node.get_instance_id()
		if not seen.has(id) and node is Ally:
			seen[id] = true
			result.append(node as Ally)


func _is_ally_in_hit_box(ally: Ally) -> bool:
	if not Lane.is_same_lane(ally.global_position.y, global_position.y):
		return false
	var diff_x: float = global_position.x - ally.global_position.x
	return diff_x >= MIN_REACH_X and diff_x <= FRONT_REACH_X


func _on_detection_area_area_entered(area: Area2D) -> void:
	if not _is_attacking and area.is_in_group(Groups.ALLIES):
		_start_attack()


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
