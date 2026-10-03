# Data Model: Refactor de cumplimiento de las reglas de la cátedra

Estructura de clases y recursos al terminar la User Story 3. Los nombres viejos están en [rename-map.md](./rename-map.md); las decisiones, en [research.md](./research.md). Los valores entre paréntesis son los actuales, que FR-001 obliga a conservar.

## Diagrama de clases

```text
Area2D
├── Ally (ally.gd)                       health, defeated, take_damage()
│   ├── Harry (harry.gd)                 shot_interval, projectile_scene
│   ├── SnitchBox (snitch_box.gd)        snitches_per_drop, drop_interval, snitch_scene
│   ├── Remembrall (remembrall.gd)       explosion_damage, detonated
│   └── Protego (protego.gd)             solo health (4000)
├── Enemy (enemy.gd)                     max_health, speed, damage_per_second, hurt_texture
│   ├── SlytherinStudent (slytherin_student.gd)
│   └── Draco (draco.gd)                 max_health = 400 en draco.tscn
├── Projectile (projectile.gd)
├── Snitch (snitch.gd)
└── Dementor (dementor.gd)

Node
├── DamageFlash (damage_flash.gd)        componente hijo de cada Ally/Enemy
└── GameManager (game_manager.gd)        autoload

Node2D
├── Level (level.gd)                     level_1/2/3.tscn
└── Footprint (footprint.gd)

Control  → LevelSelectMenu (level_select_menu.gd)
Button   → AllyCardButton (ally_card_button.gd)
Resource → AllyCard (ally_card.gd)       harry_card.tres, snitch_box_card.tres, remembrall_card.tres, protego_card.tres
Theme    → level_button_theme.tres
RefCounted (solo static) → Groups (groups.gd), Lane (lane.gd)
```

## Entidades nuevas

### AllyCard (`Resource`)

Carta de un aliado: única fuente de costo y recarga (FR-013).

| Campo | Tipo | Valores |
| --- | --- | --- |
| `display_name` | `String` | Texto del botón: `"Harry"`, `"Caja Snitch"`, `"Recordadora"`, `"Protego"` |
| `scene` | `PackedScene` | Escena del aliado |
| `cost` | `int` | Harry 100, Caja Snitch 50, Recordadora 150, Protego 50 |
| `cooldown` | `float` | Harry 0, Caja Snitch 0, Recordadora 25, Protego 12 |

- Validación: `cost > 0`, `cooldown >= 0`, `scene != null`.
- El texto del botón se arma como `"%s (%d)" % [display_name, cost]` (constante `LABEL_FORMAT_TEXT`), igual al texto actual (`"Harry (100)"`).

### AllyCardButton (`Button`)

Botón del HUD de un nivel. Reemplaza los cuatro callbacks `_on_boton_*_pressed`, el `match` de `_intentar_plantar` y las variables de recarga del nivel.

| Miembro | Tipo | Descripción |
| --- | --- | --- |
| `card` | `@export AllyCard` | Carta del botón |
| `card_pressed(button: AllyCardButton)` | señal | Se emite al hacer clic |
| `_cooldown_left` | `float` | Segundos de recarga restantes |
| `refresh(snitches: int)` | método | `disabled = snitches < card.cost or _cooldown_left > 0` |
| `set_selected(is_selected: bool)` | método | `modulate` = `SELECTED_COLOR` (0.5, 1, 0.5) o `Color.WHITE` |
| `start_cooldown()` | método | `_cooldown_left = card.cooldown` |

Estados: **disponible** → (clic) **seleccionado** → (plantar) **en recarga** (solo si `cooldown > 0`) → (llega a 0) **disponible**. Con Snitches insuficientes queda **deshabilitado** en cualquier estado. Al terminar la recarga emite `cooldown_finished` para que el nivel refresque el HUD, igual que hoy.

### DamageFlash (`Node`, `damage_flash.tscn`)

| Campo | Tipo | Aliados | Enemigos |
| --- | --- | --- | --- |
| `target` | `@export CanvasItem` | `Sprite2D` (`Visual` en Protego) | `Sprite2D` |
| `flash_color` | `@export Color` | (1, 0.3, 0.3) | (1, 0.3, 0.3) |
| `duration` | `@export float` | 0.1 | 0.15 |
| `cooldown` | `@export float` | 0.5 | 0 |
| `fade_out` | `@export bool` | `false` (vuelve de golpe) | `true` (tween) |

- `flash()`: si no está en enfriamiento, tiñe `target` y lo devuelve a `Color.WHITE` según `fade_out`.
- `target == null` → no hace nada (hoy `caja_snitch` y `recordadora` preguntan `has_node("Sprite2D")`).

### Ally (`Area2D`, base abstracta)

| Miembro | Tipo | Descripción |
| --- | --- | --- |
| `health` | `@export float` | Harry 100, Caja Snitch 100, Recordadora 100, Protego 4000 |
| `defeated(entity: Node2D)` | señal | Antes de `queue_free()` |
| `take_damage(amount: float)` | método | Resta vida, `DamageFlash.flash()`, muere en `health <= 0` |
| `damage_flash` | `@onready DamageFlash` | `$DamageFlash` |

Grupo `allies` en cada `.tscn`.

### Enemy (`Area2D`, base abstracta)

| Miembro | Tipo | Descripción |
| --- | --- | --- |
| `max_health` | `@export float` | Alumno 200, Draco 400 |
| `speed` | `@export float` | 32 |
| `damage_per_second` | `@export float` | 30 |
| `hurt_texture` | `@export Texture2D` | Textura con `health <= max_health / 2` |
| `defeated(entity: Node2D)` | señal | Al llegar a 0 de vida |
| `garden_invaded()` | señal | Al cruzar `x < 0` |
| `take_damage(amount: float)` | método | Antes recibía `int` (FR-012) |
| `TOTAL_FRAMES` | `const int` | 8 |

Estados: **avanzando** ↔ **atacando** (según haya un aliado válido en `DetectionArea`) → **lastimado** (cambio de textura, una sola vez) → **derrotado** o **invadió**. Grupo `enemies`.

### GameManager (autoload)

| Miembro | Tipo | Descripción |
| --- | --- | --- |
| `INITIAL_UNLOCKED_LEVEL` | `const int` | 10 (comportamiento actual) |
| `max_unlocked_level` | `int` | Nivel máximo desbloqueado en la sesión |
| `unlock_level(level_number: int)` | método | `max_unlocked_level = maxi(max_unlocked_level, level_number)` |

Registro en `project.godot` (`[autoload] GameManager="*res://game_manager.gd"`), con confirmación previa del equipo (FR-015).

### Groups y Lane (solo `static`)

- `Groups`: `ALLIES = &"allies"`, `ENEMIES = &"enemies"`, `SPELLS = &"spells"`, `DEMENTORS = &"dementors"`.
- `Lane`: `LANE_TOLERANCE = 64.0`, `is_same_lane(a_y: float, b_y: float) -> bool`, `enemies_in_lane(tree: SceneTree, lane_y: float) -> Array[Node2D]`.

## Entidades modificadas

### Level (`level.gd`)

| Miembro | Tipo | Nivel 1 | Nivel 2 | Nivel 3 |
| --- | --- | --- | --- | --- |
| `starting_snitches` | `@export int` | 150 | 150 | 150 |
| `total_enemies` | `@export int` | 20 | 20 | 20 |
| `enemy_scenes` | `@export Array[PackedScene]` | Alumno | Alumno | Alumno, Draco |
| `spawn_points` | `@export Array[NodePath]` | `Marker2D3` | `Marker2D2..4` | `Marker2D..5` |
| `active_rows` | `@export Array[int]` | [4] | [3, 4, 5] | [2..6] |
| `next_level_to_unlock` | `@export int` | 2 | 3 | 4 |
| `snitch_scene`, `dementor_scene` | `@export PackedScene` | | | |
| `level_select_scene` | `@export_file String` (`uid://` del menú; un `PackedScene` crearía una referencia cíclica menú ↔ nivel) | | | |
| `_selected_card` | `AllyCard` | `null` = nada seleccionado | | |
| `_occupied_cells` | `Dictionary[Vector2i, Node2D]` | | | |

Constantes: `DEMENTOR_ROWS_Y = [320, 448, 576, 704, 832]`, `DEMENTOR_X = 160`, `SKY_SNITCH_MIN_X = 300`, `SKY_SNITCH_MAX_X = 1150`, `SKY_SNITCH_Y = -20`, `EMPTY_CELL_SOURCE = -1`, textos `WIN_TITLE_TEXT`, `WIN_MESSAGE_TEXT`, `LOSE_TITLE_TEXT`, `LOSE_MESSAGE_TEXT`, `SNITCHES_LABEL_TEXT`.

Estados del nivel: **jugando** → **victoria** (generados = derrotados = `total_enemies`) o **derrota** (`garden_invaded`). Ambos detienen los timers y muestran `LevelEndPanel`; la victoria llama `GameManager.unlock_level(next_level_to_unlock)`.

### LevelSelectMenu (`level_select_menu.gd`)

- `level_scenes: @export Array[PackedScene]` = [level_1, level_2, level_3] (FR-014). El botón `LevelN` carga `level_scenes[N - 1]` si existe.
- `level_button_theme: @export Theme` con los cuatro `StyleBoxFlat` (normal, hover, pressed, disabled) y los colores de texto que hoy arma `_aplicar_estilo_pergamino_boton`.
- `LEVEL_COUNT = 10` (botones del mapa). El resto de los literales del Sistema A/B de huellas pasa a `const`.

### Otras entidades

Solo cambian nombres, tipos (`damage: float`) y constantes: `Projectile`, `Snitch`, `Dementor`, `Footprint`. `Snitch` pierde `_unhandled_input` (R12) y `_process` se parte en funciones por estado (cayendo, escapando, vencida).
