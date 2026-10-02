class_name SnitchBox
extends Area2D

## Emitted when Snitches are generated (kept for compatibility).
signal snitches_generadas(amount: int)
## Emitted when the Snitch Box drops a physical Snitch for the player to collect.
signal snitch_dropped(snitch: Snitch)
## Emitted when the Snitch Box is destroyed.
signal defeated(entity: Node2D)

## Snitch cost to place the Snitch Box.
@export var coste: int = 50
## Total health of the Snitch Box.
@export var health: float = 100.0
## Snitches produced on each drop.
@export var snitches_per_drop: int = 25
## Seconds between drops.
@export var drop_interval: float = 10.0
## Physical Snitch scene dropped on each cycle.
@export var snitch_scene: PackedScene


func _ready() -> void:
	add_to_group("allies")
	$SnitchTimer.wait_time = drop_interval
	$SnitchTimer.start()


## SnitchTimer callback. Drops a physical Snitch for the player to collect.
func _on_snitch_timer_timeout() -> void:
	# Open the box
	if has_node("Sprite2D"):
		$Sprite2D.frame = 1

	# Drop visual effect
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	# Close the box when done
	tween.tween_callback(func():
		if is_instance_valid(self) and has_node("Sprite2D"):
			$Sprite2D.frame = 0
	)

	# Spawn a physical Snitch if the scene is set
	var snitch_resource: PackedScene = snitch_scene
	if snitch_resource == null:
		snitch_resource = load("res://snitch.tscn") as PackedScene

	if snitch_resource != null:
		var new_snitch: Snitch = snitch_resource.instantiate() as Snitch
		if new_snitch != null:
			new_snitch.value = snitches_per_drop
			new_snitch.setup_from_box(global_position)
			snitch_dropped.emit(new_snitch)

	snitches_generadas.emit(snitches_per_drop)


var _tiempo_flash: float = 0.0
var _cooldown_flash: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_flash > 0.0:
		_cooldown_flash -= delta

	if _tiempo_flash > 0.0:
		_tiempo_flash -= delta
		if _tiempo_flash <= 0.0:
			if has_node("Sprite2D"):
				$Sprite2D.modulate = Color(1.0, 1.0, 1.0)


## Applies damage to the Snitch Box. Called by enemies while attacking.
func take_damage(amount: float) -> void:
	health -= amount
	# Damage visual effect (red flash with cooldown)
	if _cooldown_flash <= 0.0 and has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5

	if health <= 0.0:
		defeated.emit(self)
		queue_free()
