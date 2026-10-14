# Implementation Plan: Refactor de cumplimiento de las reglas de la cátedra

**Branch**: `004-refactor-catedra` | **Date**: 2026-10-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/004-refactor-catedra/spec.md`

## Summary

Llevar el código del juego (12 scripts, 13 escenas, 1 shader) a las reglas §4–§7 del `AGENTS.md` raíz sin cambiar el comportamiento observable. La indentación (§3) queda fuera (clarificación 2026-10-01). Se hace en tres historias que se commitean por separado:

1. **Limpieza y reglas**: se borra el legacy, se actualizan `AGENTS.md` del proyecto y la constitución, se publica el [mapa de renombres](./rename-map.md) y se agrega `tools/check_rules.gd` para registrar la línea base.
2. **Inglés**: se renombran archivos, clases, señales, métodos, propiedades, nodos, grupos y uniforms según el mapa, manteniendo los `uid://`.
3. **Estructura**: clases base `Ally` y `Enemy`, componente `DamageFlash`, cartas `AllyCard` con `AllyCardButton`, autoload `GameManager`, `Theme` para el menú, constantes, y división de las 13 funciones largas.

## Technical Context

**Language/Version**: GDScript con tipado estático estricto, Godot 4.7 (`config/features` de `project.godot`)

**Primary Dependencies**: Solo Godot. El addon `godot_mcp_bridge` ya instalado se usa para verificar, no se modifica

**Storage**: N/A (la progresión vive en memoria durante la sesión, como hoy)

**Testing**: Chequeo de reglas `tools/check_rules.gd` + partida manual de los tres niveles + inspección con `godot-mcp` ([quickstart.md](./quickstart.md))

**Target Platform**: Desktop, renderizador Compatibility, 1920x1080

**Project Type**: Videojuego 2D en Godot (estructura plana en la raíz del proyecto)

**Performance Goals**: Sin cambios. Los componentes nuevos no agregan trabajo por frame más allá del que ya existe (`DamageFlash` reemplaza los contadores de `_process` de cada aliado)

**Constraints**: FR-001 (comportamiento idéntico), sin reindentar, `project.godot` solo cambia en `[autoload]` y `[global_group]` y con confirmación previa, sin dependencias nuevas

**Scale/Scope**: ~1.300 líneas de `.gd`, ~230 identificadores en el mapa, 13 funciones a dividir

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Pre-diseño | Post-diseño | Nota |
| --- | --- | --- | --- |
| I. Godot 4, Compatibility, tipado estricto | ✅ | ✅ | Las clases nuevas declaran tipos en todo. `Dictionary[Vector2i, Node2D]` tipado (Godot ≥ 4.4) |
| II. Nodos y escenas, una escena por entidad | ✅ | ✅ | Cada entidad conserva escena + script. `Ally`, `Enemy`, `Groups`, `Lane` son scripts sin escena porque no son entidades. `DamageFlash` tiene su escena |
| III. Vocabulario temático | ⚠️ | ✅ con enmienda | La constitución exige identificadores en español (Magos/Mortífagos). El `AGENTS.md` raíz prevalece (clarificación 2026-09-30); FR-003 enmienda el principio en la User Story 1. La temática se conserva en los textos visibles y en los nombres oficiales en inglés |
| IV. Colisiones por áreas y grupos | ⚠️ | ✅ con enmienda | Mismo mecanismo; cambian los nombres de grupo (`allies`, `enemies`, `spells`), enmendados junto con III. Se eliminan las comparaciones por nombre de método en string |
| V. Estado de interfaz vía `godot-mcp` | ✅ | ✅ | La verificación usa `godot-mcp` ([quickstart.md §3](./quickstart.md#3-proyecto-abre-sin-errores)). Si no está disponible, se detiene |

**Gate**: aprobado condicionado. Las dos advertencias (III, IV) se resuelven con la enmienda v1.1.0 de la constitución, aprobada por el equipo y aplicada con `/speckit-constitution` **antes** de `/speckit-implement`. T007 solo la verifica. La postergación de §3 (indentación) es una excepción a la regla superior, documentada en la clarificación del 2026-10-01 y en Complexity Tracking, según la sección Cumplimiento de la constitución.

## Project Structure

### Documentation (this feature)

```text
specs/004-refactor-catedra/
├── plan.md               # Este archivo
├── spec.md
├── research.md           # Fase 0: decisiones R1–R15
├── rename-map.md         # FR-004, fuente del chequeo
├── data-model.md         # Fase 1: clases y recursos
├── quickstart.md         # Fase 1: validación
├── contracts/
│   ├── node-interfaces.md
│   └── check-rules-cli.md
└── tasks.md              # /speckit-tasks (no lo crea este comando)
```

### Source Code (raíz del proyecto Godot)

```text
HogwartsvsMortifagos/
├── project.godot                 # [autoload] GameManager, [global_group] renombrado (con confirmación)
├── AGENTS.md                     # Enmendado (FR-003)
├── .specify/memory/constitution.md  # Enmendada (FR-003)
├── tools/
│   └── check_rules.gd            # NUEVO (FR-016)
│
├── groups.gd                     # NUEVO: constantes de grupos
├── lane.gd                       # NUEVO: tolerancia y consulta de carril
├── game_manager.gd               # NUEVO: autoload de progresión
├── damage_flash.gd/.tscn         # NUEVO: componente de daño
├── ally_card.gd                  # NUEVO: Resource
├── ally_card_button.gd           # NUEVO: botón del HUD
├── harry_card.tres, snitch_box_card.tres, remembrall_card.tres, protego_card.tres  # NUEVOS
│
├── ally.gd                       # NUEVO: base de aliados
├── harry.gd/.tscn
├── snitch_box.gd/.tscn           # ← caja_snitch
├── remembrall.gd/.tscn           # ← recordadora
├── protego.gd/.tscn
│
├── enemy.gd                      # NUEVO: base de enemigos
├── slytherin_student.gd/.tscn    # ← alumno_slytherin
├── draco.gd/.tscn
│
├── projectile.gd/.tscn           # ← Proyectil
├── snitch.gd/.tscn
├── dementor.gd/.tscn
│
├── level.gd                      # ← nivel_principal.gd
├── level_1.tscn                  # ← NivelPrincipal.tscn
├── level_2.tscn, level_3.tscn    # ← nivel_2, nivel_3
├── level_select_menu.gd/.tscn    # ← menu_niveles
├── level_button_theme.tres       # NUEVO: estilo pergamino de los botones
├── footprint.gd                  # ← huella
├── parchment.gdshader            # ← pergamino
└── Images/                     # Sin cambios (fuera de alcance)

Borrados: Mago.*, Mortifago.*, tile_map_layer.*, Images/Mortifago.png(.import), Images/grass.png1391487371.tmp
```

**Structure Decision**: Se mantiene la estructura plana en la raíz, como en 001–003. Mover a carpetas (`entities/`, `ui/`) cambiaría todas las rutas `res://` una segunda vez sin aportar a ninguna regla; queda para otra feature si el equipo lo quiere. Solo `tools/` se separa, porque no es parte del juego.

## Orden de ejecución

### User Story 1: Limpieza y reglas

1. Revisar `git status` y commitear o descartar cambios locales de Godot (edge case del spec).
2. Borrar los archivos legacy (FR-002).
3. Enmendar `AGENTS.md` del proyecto (diccionario temático con columna de identificador en inglés) y la constitución (principios III y IV, versión 1.1.0) (FR-003).
4. Commitear `rename-map.md` (ya generado en este plan).
5. Crear `tools/check_rules.gd` según el [contrato](./contracts/check-rules-cli.md) y registrar la línea base: 13 `LONG_FUNCTION`.

### User Story 2: Identificadores en inglés

Con el editor cerrado, un commit por bloque. Cada uno deja el juego jugable:

1. Enemigos: `alumno_slytherin` → `slytherin_student`, `draco`.
2. Aliados y proyectil: `harry`, `caja_snitch` → `snitch_box`, `recordadora` → `remembrall`, `protego`, `Proyectil` → `projectile`.
3. `snitch`, `dementor`.
4. Niveles: `nivel_principal.gd` → `level.gd`, las tres escenas, nodos del HUD.
5. Menú: `menu_niveles` → `level_select_menu`, `huella` → `footprint`, `pergamino` → `parchment` y sus `shader_parameter`.
6. Grupos: `.tscn` y `[global_group]` de `project.godot` (requiere confirmación, ver Riesgos).

En cada bloque: `git mv` de archivo y `.uid`, actualizar `ext_resource path=`, `[connection ... method=]`, propiedades exportadas en `.tscn`, rutas `$Nodo`, comentarios y variables locales. Cierre: el chequeo da 0 `OLD_IDENTIFIER`.

### User Story 3: Funciones cortas, constantes y estructura

1. `Groups`, `Lane` y constantes de cada script (FR-009).
2. `DamageFlash` y su instancia en cada entidad (FR-011).
3. `Enemy` + `SlytherinStudent` + `Draco` (FR-010, FR-012).
4. `Ally` + los cuatro aliados (FR-012).
5. `AllyCard`, los cuatro `.tres`, `AllyCardButton` en los HUD de los tres niveles (FR-013).
6. `GameManager` registrado en `project.godot` (FR-015, con confirmación) y `level_scenes` en el menú (FR-014).
7. `level_button_theme.tres` y división de las funciones restantes (FR-008).

División prevista de las 13 funciones largas:

| Función (nombre nuevo) | Líneas | Cómo se resuelve |
| --- | ---: | --- |
| `Level._try_place_ally` | 64 | `_cell_under_mouse`, `_can_place_at(cell)`, `_place_ally(card, cell)`. El `match`, los costos fijos y las recargas desaparecen con `AllyCard` |
| `Snitch._process` | 38 | `_tick_timers`, `_process_escape`, `_process_fall`, `_try_start_escape`, `_is_expired` |
| `LevelSelectMenu._aplicar_estilo_pergamino_boton` | 35 | Se elimina: el estilo pasa a `level_button_theme.tres` |
| `LevelSelectMenu._spawn_ambient_walker` | 34 | `_random_walker_origin`, `_schedule_walker_step`, `_schedule_walker_release` |
| `Level._on_enemy_spawn_timer_timeout` | 27 | `_pick_spawn_position`, `_spawn_enemy(scene)`; elección con `enemy_scenes.pick_random()` |
| `SnitchBox._on_snitch_timer_timeout` | 27 | `_play_open_animation`, `_drop_snitch`. Se van el respaldo `load()` y la señal muerta |
| `LevelSelectMenu._schedule_path_steps` | 22 | `_footprint_transform_at(distance, is_right_foot)` |
| `LevelSelectMenu._on_level_button_pressed` | 20 | Índice en `level_scenes`: queda en ~5 líneas |
| `Enemy.take_damage` (Alumno) | 19 | `_update_hurt_texture`, `damage_flash.flash()`, `_die` |
| `LevelSelectMenu._start_path_footprints` | 19 | `_clear_path_footprints`, `_unlocked_path_length` |
| `Level._win` | 19 | `_stop_level`, `GameManager.unlock_level`, `_show_end_panel(title, message, show_next)` compartido con `_lose` |
| `LevelSelectMenu._spawn_ambient_footprint` | 17 | `_schedule_footprint_fade(footprint)` |
| `Enemy.take_damage` (Draco) | 16 | Se elimina: lo hereda de `Enemy` |

## Riesgos

| Riesgo | Mitigación |
| --- | --- |
| Valor que pasa del default del script a una propiedad sobrescrita en el `.tscn` (ej.: la vida de Draco, hoy `400` en `draco.gd`, pasa a `draco.tscn` en T044): si el nombre no coincide, Godot la descarta sin error y usa el default de `Enemy` (Draco con 200 de vida) | El chequeo busca los nombres viejos también en `.tscn`; T044 verifica `max_health` con `godot-mcp` y la partida comprueba que Draco aguanta el doble |
| Método de una conexión `.tscn` sin renombrar: la señal deja de disparar en silencio | Tabla de conexiones en [node-interfaces.md](./contracts/node-interfaces.md); el chequeo detecta el nombre viejo |
| El editor abierto reescribe `.tscn` o reindenta al guardar | Renombrar con el editor cerrado; revisar el diff con `-w` antes de cada commit |
| `project.godot` cambia en dos lugares (`[autoload]` y `[global_group]`) y FR-015 decía "nada más cambia" | El spec se ajustó en este plan: FR-015 incluye `[global_group]`. Una sola confirmación del equipo antes de la User Story 2 |
| Godot no está instalado en la máquina donde se armó el plan | El chequeo y las partidas se corren en la máquina de un integrante |

## Complexity Tracking

| Desvío | Por qué hace falta | Alternativa más simple descartada porque |
| --- | --- | --- |
| Base `Ally` no pedida por el spec | Sin ella, `take_damage` y el estado de vida quedan copiados en cuatro scripts (§5) | Solo `DamageFlash`: elimina el parpadeo duplicado pero no el resto |
| `AllyCard` + `AllyCardButton` en vez de leer `cost` de la escena | El costo hoy está en tres lugares y las recargas en dos; la carta es la única fuente (FR-013) y saca 4 callbacks, un `match` y 4 strings mágicos | Leer `cost` de un `PackedScene` sin instanciarlo no ve los defaults del script |
| Enmienda de los principios III y IV de la constitución | El `AGENTS.md` raíz prevalece (clarificación 2026-09-30) | No hay: la cátedra corrige con el raíz |
| Excepción a §3 del `AGENTS.md` raíz: no se reindenta a 2 espacios | Godot reindenta al guardar según la configuración de cada editor, que hoy no se conoce; reindentar ahora mezcla formato con lógica | Reindentar en esta pasada: descartado por el equipo (clarificación 2026-10-01). Se cumple en la etapa final del proyecto |
