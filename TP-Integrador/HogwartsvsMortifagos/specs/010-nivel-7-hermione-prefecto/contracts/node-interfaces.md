# Interface Contracts: Nivel 7 - Hermione y Prefecto Slytherin

Este documento define los contratos públicos de nodos, métodos, señales y estructuras de escenas para Hermione, el Prefecto Slytherin, los hechizos y el Nivel 7.

## 1. Contrato de la Entidad Hermione (`Hermione`)

```gdscript
class_name Hermione
extends Ally

## Cadencia de disparo en segundos (idéntica a Harry).
@export var shot_interval: float = 1.5

## Daño base por impacto.
@export var damage: float = 20.0

## Escena de proyectil fallback.
@export var projectile_scene: PackedScene

## Pool de proyectiles inyectado por Level.
@export var projectile_pool: ProjectilePool

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

## Inicia el temporizador de disparo.
func _ready() -> void

## Dispara un proyectil helado si detecta enemigos en su fila.
func _on_shoot_timer_timeout() -> void

## Solicita un proyectil al pool marcando el flag de ralentización.
func _shoot() -> void

## Verifica presencia de enemigos en la misma fila.
func _has_enemy_in_lane() -> bool
```

### Estructura de `hermione.tscn`
- **Raíz**: `Hermione` (`Area2D`, en grupo `allies`, `collision_mask = 0`, script `hermione.gd`).
- **Hijos**:
  - `Sprite2D`: textura `res://Images/hermione.png`, escala `Vector2(1.44, 1.44)`.
  - `CollisionShape2D`: `RectangleShape2D` (size `Vector2(148, 112)`).
  - `ShootPoint`: `Marker2D` (`position = Vector2(104, -40)`).
  - `ShootTimer`: `Timer` (`wait_time = 1.5`).
  - `DamageFlash`: `res://damage_flash.tscn` (`cooldown = 0.5`).

---

## 2. Contrato de la Entidad Prefecto Slytherin (`SlytherinPrefect`)

```gdscript
class_name SlytherinPrefect
extends Enemy

## Segundos entre disparos a distancia.
@export var shoot_interval: float = 3.5

## Escena del proyectil enemigo a instanciar.
@export var projectile_scene: PackedScene

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

## Inicia el shoot_timer con shoot_interval.
func _ready() -> void

## Temporizador de disparo: dispara si hay aliados al frente en la fila.
func _on_shoot_timer_timeout() -> void

## Instancia y dispara un proyectil hacia la izquierda.
func _shoot() -> void

## Comprueba si hay aliados en su carril hacia la izquierda.
func _has_ally_ahead() -> bool
```

### Estructura de `slytherin_prefect.tscn`
- **Raíz**: `SlytherinPrefect` (`Area2D`, en grupo `enemies`, `collision_layer = 2`, `collision_mask = 0`, script `slytherin_prefect.gd`).
- **Hijos**:
  - `Sprite2D`: textura `res://Images/slytherin_protego.png` (`hframes = 8`). Sin nodo `ShieldSprite`.
  - `CollisionShape2D`: `RectangleShape2D` (`size = Vector2(68, 160)`).
  - `DetectionArea`: `Area2D` para interactuar cuerpo a cuerpo.
  - `AnimationTimer`: `Timer` (`wait_time = 0.25`).
  - `ShootTimer`: `Timer` (`wait_time = 3.5`).
  - `ShootPoint`: `Marker2D` (`position = Vector2(-35, -20)`).
  - `DamageFlash`: `res://damage_flash.tscn`.

---

## 3. Contrato de la Entidad Proyectil Enemigo (`EnemyProjectile`)

```gdscript
class_name EnemyProjectile
extends Area2D

## Velocidad de desplazamiento horizontal hacia la izquierda en px/s.
@export var speed: float = 400.0

## Daño que inflige al aliado impactado.
@export var damage: float = 20.0

## Duración de cada fotograma de la animación cíclica.
@export var animation_frame_duration: float = 0.08

@onready var sprite: Sprite2D = $Sprite2D

## Avanza en dirección Vector2.LEFT y anima el frame del sprite sheet.
func _process(delta: float) -> void

## Colisiona con un aliado, le aplica daño y se libera.
func _on_area_entered(area: Area2D) -> void

## Libera el proyectil al salir de pantalla.
func _on_screen_exited() -> void
```

### Estructura de `enemy_projectile.tscn`
- **Raíz**: `EnemyProjectile` (`Area2D`, `collision_layer = 0`, `collision_mask = 1`, script `enemy_projectile.gd`).
- **Hijos**:
  - `Sprite2D`: textura `res://Images/slytherin_shot.png`, `hframes = 4`, `vframes = 1`.
  - `CollisionShape2D`: `RectangleShape2D` o `CircleShape2D`.
  - `VisibleOnScreenNotifier2D`.

---

## 4. Contrato de Extensión en `Enemy` (`enemy.gd`)

```gdscript
## Aplica un factor de ralentización por una duración en segundos.
func apply_slow(factor: float, duration: float) -> void

## Restaura la velocidad original y la modulación de color al terminar la duración.
func _on_slow_timer_timeout() -> void
```

---

## 5. Contrato de Extensión en `Lane` (`lane.gd`)

```gdscript
## Determina si existe algún aliado en el mismo carril ubicado a la izquierda de from_x.
static func has_allies_in_lane_ahead(tree: SceneTree, lane_y: float, from_x: float) -> bool
```

---

## 6. Contrato de Extensión en `ProjectilePool` y `Projectile`

```gdscript
## En Projectile:
@export var slows: bool = false
@export var slow_factor: float = 0.70
@export var slow_duration: float = 5.0

## En ProjectilePool:
func acquire_projectile(spawn_position: Vector2, custom_damage: float = DEFAULT_PROJECTILE_DAMAGE, slows: bool = false) -> Projectile
```

---

## 7. Contrato de la Escena `level_7.tscn`

- **Nodo Raíz**: `Level7` (`level.gd`).
- **Nodos Clave**:
  - `Grid`: 5 filas activas (`[2, 3, 4, 5, 6]`).
  - `Spawners`: 5 `Marker2D` correspondientes a las filas activas.
  - `HUD`:
    - `HarryCardButton`: Harry (100)
    - `SnitchBoxCardButton`: Caja Snitch (50)
    - `RonCardButton`: Ron (125)
    - `RemembrallCardButton`: Recordadora (150)
    - `ProtegoCardButton`: Protego (50)
    - `BroomstickCardButton`: Escoba (125)
    - `HermioneCardButton`: Hermione (125)
    - `AccioButton`: Accio
  - `Entities/ProjectilePool`: Reutilizable para proyectiles de Harry, Ron y Hermione.
