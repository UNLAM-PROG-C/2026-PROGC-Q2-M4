class_name Harry
extends Area2D

## Emitted when Harry loses all his health.
signal defeated(entity: Node2D)

## Snitch cost to place Harry.
@export var coste: int = 100
## Harry's total health.
@export var health: float = 100.0
## Seconds between shots.
@export var shot_interval: float = 1.5
## Projectile scene Harry shoots.
@export var projectile_scene: PackedScene


func _ready() -> void:
	add_to_group("aliados")
	$ShootTimer.wait_time = shot_interval
	$ShootTimer.start()


## ShootTimer callback. Shoots a projectile if there is an enemy in the same lane.
func _on_shoot_timer_timeout() -> void:
	if projectile_scene == null:
		return
	if not _has_enemy_in_lane():
		return
	var new_projectile: Area2D = projectile_scene.instantiate()
	new_projectile.global_position = $ShootPoint.global_position
	get_tree().current_scene.add_child(new_projectile)


## Checks whether at least one valid enemy is in the same horizontal lane.
func _has_enemy_in_lane() -> bool:
	for enemy: Node in get_tree().get_nodes_in_group("enemigos"):
		if enemy is Node2D and is_instance_valid(enemy):
			if absf((enemy as Node2D).global_position.y - global_position.y) < 64.0:
				return true
	return false


var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta

	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			$Sprite2D.modulate = Color(1.0, 1.0, 1.0)


## Applies damage to Harry. Called by enemies while attacking.
func take_damage(amount: float) -> void:
	health -= amount

	# Damage visual effect (red flash with cooldown)
	if _cooldown_flash <= 0.0:
		$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5

	if health <= 0.0:
		defeated.emit(self)
		queue_free()
