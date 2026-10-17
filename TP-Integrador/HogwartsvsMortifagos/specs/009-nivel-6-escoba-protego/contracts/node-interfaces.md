# Interface Contracts: Nivel 6 - Escoba y Alumno con Protego

Este documento define los contratos públicos de nodos, métodos, señales y estructuras de escenas para la Escoba, el Alumno con Protego y la escena del Nivel 6.

## 1. Contrato de la Entidad Escoba (`Broomstick`)

```gdscript
class_name Broomstick
extends Ally

## Velocidad de desplazamiento horizontal en px/s.
@export var speed: float = 600.0

## Daño masivo por impacto aplicado a cada enemigo alcanzado.
@export var sweep_damage: float = 1800.0

## Límite horizontal derecho donde la entidad se libera.
@export var end_x: float = 1950.0

## Diccionario interno de IDs de enemigos ya impactados para evitar daño múltiple.
var _damaged_enemies: Dictionary[int, bool] = {}

## Avanza horizontalmente en el eje X y libera el nodo al salir de la pantalla.
func _process(delta: float) -> void

## Detecta enemigos y les aplica sweep_damage sin detenerse.
func _on_area_entered(area: Area2D) -> void
```

### Estructura de `broomstick.tscn`
- **Raíz**: `Broomstick` (`Area2D`, en grupo `allies`, `collision_layer = 1`, `collision_mask = 2`).
- **Hijos**:
  - `Sprite2D`: textura `res://Images/broomstick.png`.
  - `CollisionShape2D`: `RectangleShape2D` dimensionado para abarcar la altura del carril.
  - `DamageFlash`: `res://damage_flash.tscn` (opcional).

---

## 2. Contrato de la Entidad Alumno con Protego (`ProtegoStudent`)

```gdscript
class_name ProtegoStudent
extends Enemy

## Salud máxima del escudo Protego.
@export var shield_max_health: float = 300.0

## Nodo sprite hijo que renderiza el escudo Protego frontal.
@onready var shield_sprite: Sprite2D = $ShieldSprite

var _shield_health: float = 300.0

## Recibe daño restando primero del escudo y aplicando el desborde al cuerpo.
func take_damage(amount: float) -> void

## Actualiza el frame del escudo (0, 1, 2) según los umbrales de vida.
func _update_shield_visuals() -> void

## Destruye el escudo y transiciona la textura base a slytherin común.
func _break_shield() -> void
```

### Estructura de `protego_student.tscn`
- **Raíz**: `ProtegoStudent` (`Area2D`, en grupo `enemies`, `collision_layer = 2`, `collision_mask = 0`).
- **Hijos**:
  - `Sprite2D`: textura `res://Images/slytherin_protego.png` (`hframes = 8`). Al romperse, usa `res://Images/slytherin.png`.
  - `ShieldSprite`: `Sprite2D` en `position = Vector2(-35, -12)`, textura `res://Images/protego.png` (`hframes = 3`).
  - `CollisionShape2D`: `RectangleShape2D` (abarcando cuerpo y escudo).
  - `DetectionArea`: `Area2D` para interactuar con aliados.
  - `AnimationTimer`: `Timer`.
  - `DamageFlash`: `res://damage_flash.tscn`.

---

## 3. Contrato de Integración en `Level`

En `level.gd`, `_init_placed_ally(ally: Ally)` gestiona la inicialización de la Escoba:

```gdscript
func _init_placed_ally(ally: Ally) -> void:
    if ally is Harry:
        (ally as Harry).projectile_pool = projectile_pool
    elif "projectile_pool" in ally:
        ally.set("projectile_pool", projectile_pool)
    if ally is SnitchBox:
        (ally as SnitchBox).snitch_dropped.connect(_on_snitch_dropped)
    if ally is Broomstick:
        _handle_broomstick_placed(ally as Broomstick)
```

Y `_handle_broomstick_placed(broom: Broomstick) -> void` asegura que la celda de la cuadrícula quede libre de inmediato para permitir plantados posteriores mientras la Escoba barre el carril.

---

## 4. Contrato de la Escena `level_6.tscn`

- **Nodo Raíz**: `Level6` (`level.gd`).
- **Nodos Clave**:
  - `Grid`: `position = Vector2(24, -128)`, `scale = Vector2(1.25, 1.25)`.
  - `Spawners`: 5 `Marker2D` en $Y \in [272, 432, 592, 752, 912]$.
  - `HUD`:
    - `HarryCardButton`: Harry (100)
    - `SnitchBoxCardButton`: Caja Snitch (50)
    - `RonCardButton`: Ron (125)
    - `RemembrallCardButton`: Recordadora (150)
    - `ProtegoCardButton`: Protego (50)
    - `BroomstickCardButton`: Escoba (125)
    - `AccioButton`: Accio
