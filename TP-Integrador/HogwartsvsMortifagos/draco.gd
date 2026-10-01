// draco.gd - Enemy tank Draco
class_name Draco
extends Area2D

# Signals
signal derrotado(entidad: Node2D)
signal invasion_jardin()

# Exported configuration
@export var vida: float = 400.0  # Double the health of a standard AlumnoSlytherin (200)
@export var velocidad: float = 32.0
@export var danio_por_segundo: float = 30.0
@export var textura_lastimado: Texture2D

const TOTAL_FRAMES: int = 8

var salud_actual: float = 0.0
var aliado_objetivo: Area2D = null
var _lastimado: bool = false

func _ready() -> void:
    salud_actual = vida
    add_to_group("enemigos")
    # Randomize starting animation frame
    $Sprite2D.frame = randi() % TOTAL_FRAMES

func _process(delta: float) -> void:
    if is_instance_valid(aliado_objetivo):
        if aliado_objetivo.has_method("recibir_danio"):
            aliado_objetivo.call("recibir_danio", danio_por_segundo * delta)
    else:
        aliado_objetivo = null
        # Move leftwards across the garden
        position.x -= velocidad * delta

    # Check for garden invasion
    if global_position.x < 0.0:
        invasion_jardin.emit()
        queue_free()

# Animation timer callback
func _on_timer_animacion_timeout() -> void:
    $Sprite2D.frame = ($Sprite2D.frame + 1) % TOTAL_FRAMES

# Damage handling
func recibir_danio(cantidad: float) -> void:
    salud_actual = maxi(salud_actual - cantidad, 0.0)
    if not _lastimado and salud_actual <= vida / 2:
        _lastimado = true
        if textura_lastimado != null:
            var frame_actual: int = $Sprite2D.frame
            $Sprite2D.texture = textura_lastimado
            $Sprite2D.frame = frame_actual
    # Flash red effect
    $Sprite2D.modulate = Color(1.0, 0.3, 0.3)
    var tween: Tween = create_tween()
    tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0), 0.15)
    if salud_actual == 0.0:
        derrotado.emit(self)
        queue_free()

# Detection area callbacks
func _on_area_deteccion_area_entered(area: Area2D) -> void:
    if area.is_in_group("aliados"):
        aliado_objetivo = area

func _on_area_deteccion_area_exited(area: Area2D) -> void:
    if not is_instance_valid(aliado_objetivo) or area == aliado_objetivo:
        aliado_objetivo = null
