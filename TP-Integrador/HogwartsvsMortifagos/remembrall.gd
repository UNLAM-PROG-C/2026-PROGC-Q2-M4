class_name Remembrall
extends Area2D

# Remembrall (Cherry Bomb) ally entity
# Cost: 150 Snitches
# Cooldown: handled in level logic (25s)
# Health: 100

@export var coste: int = 150
@export var tiempo_recarga: float = 25.0
@export var health: float = 100.0
## Damage dealt to every enemy inside ExplosionArea.
@export var explosion_damage: int = 1800

signal destruida_sin_explotar(entity: Node2D)
signal detonated(entity: Node2D)

func _ready() -> void:
	start_fuse()

func start_fuse() -> void:
	$FuseTimer.start()

func _on_fuse_timer_timeout() -> void:
	# Play warning animation via Tween
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1,0.5,0.5,1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(Callable(self, "detonate"))

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


func take_damage(amount: float) -> void:
	health -= amount
	# Damage visual effect (red flash with cooldown)
	if _cooldown_flash <= 0.0 and has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1.0, 0.3, 0.3)
		_tiempo_flash = 0.1
		_cooldown_flash = 0.5

	if health <= 0.0:
		destruida_sin_explotar.emit(self)
		queue_free()

func detonate() -> void:
	# Damage enemies in explosion area
	var area: Area2D = $ExplosionArea
	var areas = area.get_overlapping_areas()
	for entity_area in areas:
		if entity_area.is_in_group("enemies"):
			if entity_area.has_method("take_damage"):
				entity_area.take_damage(explosion_damage)
	detonated.emit(self)
	queue_free()
