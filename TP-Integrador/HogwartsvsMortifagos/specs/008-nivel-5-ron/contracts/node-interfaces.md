# Interface Contracts: Nivel 5 y Ron

Este documento define los contratos públicos de nodos, señales, métodos y firmas tipadas que estructuran la nueva unidad aliada Ron, su proyectil y la integración con `Level` y `ProjectilePool`.

## 1. Contrato de la Entidad Ron (`Ron`)

Unidad aliada ofensiva que detecta enemigos en su línea y dispara proyectiles potenciados cada 3 segundos.

```gdscript
class_name Ron
extends Ally

## Cadencia de disparo: segundos entre cada ataque.
@export var shot_interval: float = 3.0

## Daño por impacto aplicado al enemigo (1.5x el proyectil base).
@export var damage: float = 30.0

## Escena base de proyectil para respaldo.
@export var projectile_scene: PackedScene

## Referencia al pool compartido de proyectiles (inyectada por Level).
@export var projectile_pool: ProjectilePool

## Nodos internos requeridos en ron.tscn:
# $ShootTimer: Timer
# $ShootPoint: Marker2D
# $Sprite2D: Sprite2D (textura res://Images/ron.png)
# $CollisionShape2D: CollisionShape2D
# $DamageFlash: DamageFlash (instancia de res://damage_flash.tscn)

## Dispara un proyectil si hay enemigos presentes en su carril.
func _on_shoot_timer_timeout() -> void

## Valida si existe al menos un enemigo en su misma línea Y.
func _has_enemy_in_lane() -> bool

## Solicita un proyectil al pool configurando su daño y posición de salida.
func _shoot() -> void
```

### Reglas de Diseño y Modularidad
- Ningún método supera las 15 líneas de código (Regla 4 de la cátedra).
- Tipado estático estricto en todas las variables, constantes, parámetros y retornos.
- Pertenece al grupo `Groups.ALLIES` (definido en `ron.tscn`).

---

## 2. Contrato de Adquisición de Proyectiles (`ProjectilePool`)

Extensión limpia del pool existente para soportar daño parametrizado sin acoplarse a clases concretas de atacantes:

```gdscript
## Adquiere un proyectil del pool asignándole posición y daño de impacto opcional.
func acquire_projectile(spawn_position: Vector2, custom_damage: float = 20.0) -> Projectile:
```

### Comportamiento del Proyectil (`Projectile`)
1. Al invocarse `acquire_projectile(spawn_position, custom_damage)`:
   - Se asigna `projectile.damage = custom_damage`.
   - Se activa el proyectil en `spawn_position`.
2. Al colisionar o salir de la pantalla:
   - Aplica `damage` al enemigo mediante `enemy.take_damage(damage)`.
   - Al retornar al pool en `_on_projectile_returned`, restaura `damage = 20.0` para garantizar aislamiento de estado.

---

## 3. Contrato de Inicialización de Aliados en `Level`

Para preservar el límite de 15 líneas en `Level._place_ally`, la configuración de dependencias de entidades plantadas se delega a un método modular:

```gdscript
## Configura dependencias e inyecciones específicas del aliado plantado.
func _init_placed_ally(ally: Ally) -> void:
    if ally is Harry:
        (ally as Harry).projectile_pool = projectile_pool
    elif ally is Ron:
        (ally as Ron).projectile_pool = projectile_pool
    if ally is SnitchBox:
        (ally as SnitchBox).snitch_dropped.connect(_on_snitch_dropped)
```

---

## 4. Contrato de la Escena `level_5.tscn`

- **Nodo Raíz**: `Level` (`level.gd`).
- **Nodos Hijos Clave**:
  - `Grid`: `position = Vector2(24, -128)`, `scale = Vector2(1.25, 1.25)`.
  - `Grid/TileMapLayer`: 45 celdas configuradas (9 columnas $\times$ 5 filas).
  - `Grid/MagicBarrier`: Bloqueos invisibles (todas las filas habilitadas).
  - `Spawners`: 5 `Marker2D` con $Y \in [272, 432, 592, 752, 912]$.
  - `HUD/HarryCardButton`: `Harry (100)`.
  - `HUD/SnitchBoxCardButton`: `Caja Snitch (50)`.
  - `HUD/RonCardButton`: `Ron (125)`.
  - `HUD/RemembrallCardButton`: `Recordadora (150)`.
  - `HUD/ProtegoCardButton`: `Protego (50)`.
  - `HUD/AccioButton`: `Accio`.
