class_name Quirrell
extends Enemy

signal health_changed(current_health: float, max_health: float)
signal shadow_spawn_requested(spawn_position: Vector2, lane_y: float)
signal mass_shadow_spawn_requested()
signal teleported(from_cell: Vector2i, to_cell: Vector2i)
signal phase_two_started(boss_global_position: Vector2)

const BOSS_MAX_HEALTH: float = 36000.0
const PHASE_THRESHOLD_HEALTH: float = 18000.0
const TELEPORT_INTERVAL: float = 20.0
const INVOCATION_INTERVAL_PHASE_1: float = 7.5
const INVOCATION_INTERVAL_PHASE_2: float = 4.0
const ULTIMATE_ATTACK_CHANCE: float = 0.10
const ACTIVE_ROWS: Array[int] = [2, 3, 4, 5, 6]
const BOSS_COLUMN: int = 10

@export var current_row: int = 4

var current_phase: int = 1
var current_cell: Vector2i = Vector2i(BOSS_COLUMN, 4)

@onready var turban_sprite: Sprite2D = $TurbanSprite
@onready var teleport_timer: Timer = $TeleportTimer
@onready var invocation_timer: Timer = $InvocationTimer


func _enter_tree() -> void:
	_init_boss_stats()


func _ready() -> void:
	_init_boss_stats()
	_init_timers()


func _init_boss_stats() -> void:
	max_health = BOSS_MAX_HEALTH
	_health = max_health
	current_cell = Vector2i(BOSS_COLUMN, current_row)


func _init_timers() -> void:
	if teleport_timer != null:
		teleport_timer.wait_time = TELEPORT_INTERVAL
		teleport_timer.timeout.connect(_on_teleport_timer_timeout)
		teleport_timer.start()
	if invocation_timer != null:
		invocation_timer.wait_time = INVOCATION_INTERVAL_PHASE_1
		invocation_timer.timeout.connect(_on_invocation_timer_timeout)
		invocation_timer.start()


func _process(_delta: float) -> void:
	pass


func take_damage(amount: float) -> void:
	if _health <= 0.0:
		return
	_health = maxf(_health - amount, 0.0)
	health_changed.emit(_health, max_health)
	if damage_flash != null:
		damage_flash.flash()
	_check_phase_transition()
	if _health <= 0.0:
		_die()


func _check_phase_transition() -> void:
	if current_phase == 1 and _health <= PHASE_THRESHOLD_HEALTH:
		_enter_phase_2()


func _enter_phase_2() -> void:
	current_phase = 2
	if turban_sprite != null:
		turban_sprite.visible = false
	if invocation_timer != null:
		invocation_timer.wait_time = INVOCATION_INTERVAL_PHASE_2
		invocation_timer.start()
	phase_two_started.emit(global_position)



func _on_teleport_timer_timeout() -> void:
	var available_rows: Array[int] = []
	for row_idx: int in ACTIVE_ROWS:
		if row_idx != current_row:
			available_rows.append(row_idx)
	var new_row: int = available_rows[randi() % available_rows.size()]
	var old_cell: Vector2i = current_cell
	current_row = new_row
	current_cell = Vector2i(BOSS_COLUMN, new_row)
	teleported.emit(old_cell, current_cell)


func teleport_to(new_row: int, destination_position: Vector2) -> void:
	var old_cell: Vector2i = current_cell
	current_row = new_row
	current_cell = Vector2i(BOSS_COLUMN, new_row)
	global_position = destination_position
	teleported.emit(old_cell, current_cell)


func _on_invocation_timer_timeout() -> void:
	if current_phase == 1:
		shadow_spawn_requested.emit(global_position, global_position.y)
		return
	mass_shadow_spawn_requested.emit()



func _die() -> void:
	if teleport_timer != null:
		teleport_timer.stop()
	if invocation_timer != null:
		invocation_timer.stop()
	defeated.emit(self)


func get_current_cell() -> Vector2i:
	return current_cell


func apply_slow(_factor: float, _duration: float) -> void:
	pass


func occupies_lane_y(lane_y: float) -> bool:
	if super.occupies_lane_y(lane_y):
		return true
	return Lane.is_same_lane(global_position.y - Lane.ROW_SPACING, lane_y)
