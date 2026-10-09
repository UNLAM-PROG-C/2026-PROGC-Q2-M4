# Interface Contracts: entidades después del refactor

Señales, métodos públicos y grupos que el resto del juego usa. Reemplazan los contratos en español de [003](../../003-nivel-3-protego/contracts/node-interfaces.md). Ningún nodo llama métodos por string (`call("recibir_danio", ...)`) ni conecta señales por nombre (`connect("derrotado", ...)`): se usan los tipos `Ally`, `Enemy`, `Snitch` y `AllyCardButton`.

## Daño

```gdscript
func take_damage(amount: float) -> void
```

- La exponen `Ally` y `Enemy`. Misma firma en ambos (FR-012).
- Quién la llama: `Enemy` (a su aliado objetivo, `damage_per_second * delta`), `Projectile` (al enemigo que toca, `damage`), `Remembrall` (enemigos en `ExplosionArea`, `explosion_damage`), `Dementor` (enemigos de su carril, `damage`).
- Al llegar a 0 de vida, emite `defeated(self)` y hace `queue_free()`.

## Ciclo de vida

| Emisor | Señal | Oyente |
| --- | --- | --- |
| `Enemy` | `defeated(entity: Node2D)` | `Level._on_enemy_defeated` |
| `Enemy` | `garden_invaded()` | `Level._on_garden_invaded` |
| `Ally` | `defeated(entity: Node2D)` | Ninguno hoy. El nivel libera la celda con `tree_exiting` |
| `SnitchBox` | `snitch_dropped(snitch: Snitch)` | `Level._on_snitch_dropped` |
| `Snitch` | `collected(amount: int)` | `Level._on_snitch_collected` |
| `Remembrall` | `detonated(entity: Node2D)` | Ninguno hoy |
| `Dementor` | `activated(entity: Node2D)`, `exhausted(entity: Node2D)` | Ninguno hoy |
| `AllyCardButton` | `card_pressed(button: AllyCardButton)` | `Level._on_card_pressed` (conectado por código en `_ready` del nivel) |
| `AllyCardButton` | `cooldown_finished()` | `Level._refresh_hud` |
| `LevelSelectMenu` | `level_selected(level_number: int)` | Ninguno hoy |

## Componentes

```gdscript
# DamageFlash
func flash() -> void

# AllyCardButton
func refresh(snitches: int) -> void
func set_selected(is_selected: bool) -> void
func start_cooldown() -> void

# GameManager (autoload)
var max_unlocked_level: int
func unlock_level(level_number: int) -> void

# Snitch
func setup_from_box(origin: Vector2) -> void
```

## Grupos

Declarados en el `.tscn` de cada entidad y consultados con `Groups`:

| Grupo | Constante | Escenas |
| --- | --- | --- |
| `allies` | `Groups.ALLIES` | `harry`, `snitch_box`, `remembrall`, `protego` |
| `enemies` | `Groups.ENEMIES` | `slytherin_student`, `draco` |
| `spells` | `Groups.SPELLS` | `projectile` |
| `dementors` | `Groups.DEMENTORS` | `dementor` |

## Conexiones declaradas en `.tscn`

Cada línea `[connection]` debe apuntar a un método existente con el nombre nuevo (si no, la señal deja de dispararse sin error visible).

| Escena | Señal (nodo) | Método |
| --- | --- | --- |
| `slytherin_student`, `draco` | `area_entered` / `area_exited` (`DetectionArea`) | `_on_detection_area_area_entered` / `_exited` |
| `slytherin_student`, `draco`, `snitch` | `timeout` (`AnimationTimer`) | `_on_animation_timer_timeout` |
| `harry` | `timeout` (`ShootTimer`) | `_on_shoot_timer_timeout` |
| `snitch_box` | `timeout` (`SnitchTimer`) | `_on_snitch_timer_timeout` |
| `remembrall` | `timeout` (`FuseTimer`) | `_on_fuse_timer_timeout` |
| `projectile` | `area_entered` (raíz), `screen_exited` (`VisibleOnScreenNotifier2D`) | `_on_area_entered`, `_on_screen_exited` |
| `snitch` | `input_event` (raíz) | `_on_input_event` |
| `level_1/2/3` | `timeout` (`EnemySpawnTimer`, `SnitchSpawnTimer`) | `_on_enemy_spawn_timer_timeout`, `_on_snitch_spawn_timer_timeout` |
| `level_1/2/3` | `pressed` (`NextLevelButton`, `RetryButton`, `BackToMapButton`) | `_on_next_level_button_pressed`, `_on_retry_button_pressed`, `_on_back_to_map_button_pressed` |

Las conexiones `pressed` de `BotonHarry`, `BotonCajaSnitch`, `BotonRecordadora` y `BotonProtego` se eliminan: las reemplaza `card_pressed`.
