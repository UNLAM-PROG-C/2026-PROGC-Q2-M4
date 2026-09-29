extends Area2D

# Recordadora (Explosive Cherry) ally entity
# Cost: 150 Snitches
# Cooldown: handled in level logic (25s)
# Health: 100

@export var coste: int = 150
@export var tiempo_recarga: float = 25.0
@export var salud: float = 100.0

signal destruida_sin_explotar(entidad: Node2D)
signal detonada(entidad: Node2D)

func _ready() -> void:
	iniciar_detona()

func iniciar_detona() -> void:
	$TimerDetonate.start()

func _on_TimerDetonate_timeout() -> void:
	# Play warning animation via Tween
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1,0.5,0.5,1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(Callable(self, "detonar"))

func recibir_danio(cantidad: float) -> void:
	salud -= cantidad
	if salud <= 0.0:
		destruida_sin_explotar.emit(self)
		queue_free()

func detonar() -> void:
	# Damage enemies in explosion area
	var area: Area2D = $AreaExplosion
	var areas = area.get_overlapping_areas()
	for entity_area in areas:
		if entity_area.is_in_group("enemigos"):
			if entity_area.has_method("recibir_danio"):
				entity_area.recibir_danio(1800)
	detonada.emit(self)
	queue_free()
