class_name McGonagall
extends Ally

## Gatling shooter ally: shoots a burst of 4 projectiles when enemies are in lane.

const DEFAULT_SHOT_INTERVAL: float = 1.5
const DEFAULT_BURST_INTERVAL: float = 0.15
const DEFAULT_BURST_COUNT: int = 4

@export var shot_interval: float = DEFAULT_SHOT_INTERVAL
@export var burst_interval: float = DEFAULT_BURST_INTERVAL
@export var burst_count: int = DEFAULT_BURST_COUNT
@export var projectile_scene: PackedScene
@export var projectile_pool: ProjectilePool

var _shots_remaining: int = 0

@onready var shoot_timer: Timer = $ShootTimer
@onready var burst_timer: Timer = $BurstTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	shoot_timer.one_shot = true
	burst_timer.one_shot = false
	burst_timer.wait_time = burst_interval
	shoot_timer.start(shot_interval)


func _on_shoot_timer_timeout() -> void:
	if not _has_enemy_in_lane():
		shoot_timer.start(shot_interval)
		return
	_start_burst()


func _start_burst() -> void:
	_shots_remaining = burst_count
	_fire_burst_shot()
	burst_timer.start(burst_interval)


func _on_burst_timer_timeout() -> void:
	if _shots_remaining <= 0:
		_finish_burst()
		return
	_fire_burst_shot()
	if _shots_remaining <= 0:
		_finish_burst()


func _finish_burst() -> void:
	burst_timer.stop()
	shoot_timer.start(shot_interval)


func _fire_burst_shot() -> void:
	_shots_remaining -= 1
	if projectile_pool == null or not is_instance_valid(projectile_pool):
		return
	var projectile: Projectile = projectile_pool.acquire_projectile(shoot_point.global_position)
	if projectile == null:
		return


func _has_enemy_in_lane() -> bool:
	return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()


func _exit_tree() -> void:
	_shots_remaining = 0
	if is_instance_valid(burst_timer):
		burst_timer.stop()
	if is_instance_valid(shoot_timer):
		shoot_timer.stop()
