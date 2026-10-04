---

description: "Task list for 004-refactor-catedra"
---

# Tasks: Refactor de cumplimiento de las reglas de la cátedra

**Input**: Design documents from `specs/004-refactor-catedra/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [rename-map.md](./rename-map.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: El spec no pide tests automatizados (Assumptions). La verificación es `tools/check_rules.gd` + partida manual de los tres niveles según [quickstart.md](./quickstart.md). No se generan tareas de test.

**Organization**: Una fase por User Story, en el orden de ejecución del spec (las tres son P1 y secuenciales). Cada fase deja el juego jugable y se commitea por separado.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: User Story a la que pertenece (US1, US2, US3)
- Rutas relativas a la raíz del proyecto Godot `TP-Integrador/HogwartsvsMortifagos/`

## Reglas transversales (aplican a TODAS las tareas)

- **FR-001**: ningún cambio de comportamiento observable (vida, daño, velocidades, costos, tiempos, visuales, textos).
- **FR-005 / R3**: NO reindentar. Los `.gd` conservan tabulaciones; el código nuevo usa tabulaciones. No tocar `.editorconfig`.
- **R13**: renombrar con el editor de Godot **cerrado**: `git mv` del archivo **y** de su `.uid`; actualizar a mano `ext_resource path=`, `[connection ... method=]`, propiedades exportadas en `.tscn` y `shader_parameter/`.
- Tipado estático estricto en todo `var`, `const`, parámetro y retorno; señales con parámetros tipados.
- Textos visibles al jugador quedan en español, en constantes con sufijo `_TEXT` (R9).
- Literales permitidos sin constante (R9): `0`, `1`, `0.0`, `1.0`, `-1.0` como signo, `""`, `Vector2.ZERO`, `Vector2.ONE`, `Color.WHITE` y rutas de nodos.
- Antes de cada commit (SC-002):
  - `diff <(git diff develop --name-only) <(git diff develop -w --name-only)` no imprime nada (archivos con cambios solo de espacios);
  - `git grep -nE "^ +" -- "*.gd" "*.gdshader"` no imprime nada (líneas indentadas con espacios: detecta reindentaciones del editor también en archivos renombrados con `git mv`, que el `diff` anterior no ve).
- Commits en Conventional Commits, sin atribución de IA.

---

## Phase 1: Setup

**Purpose**: Dejar el árbol limpio y obtener la confirmación que exige FR-015 antes de tocar código.

- [X] T001 Revisar `git status` en `TP-Integrador/HogwartsvsMortifagos/` y commitear o descartar cambios locales generados por Godot (`.uid` nuevos, `.tscn` reguardados) que no sean de los docs de `specs/004-refactor-catedra/` ni de `.specify/memory/constitution.md` (edge case del spec). No descartar nunca `constitution.md`: contiene la enmienda v1.1.0 aprobada que T007 verifica. Commitear `../../AGENTS.md` (raíz del repo, hoy sin trackear) y `.specify/memory/constitution.md` con `docs: add course coding rules and amend constitution to v1.1.0`
- [X] T002 Pedir y registrar la confirmación del equipo para los únicos dos cambios permitidos en `project.godot`: sección `[autoload]` (agregar `GameManager="*res://game_manager.gd"`) y sección `[global_group]` (renombrar `aliados`/`enemigos`/`hechizos` a `allies`/`enemies`/`spells`). Anotar la fecha de la confirmación en la sección Clarifications de `specs/004-refactor-catedra/spec.md`. Si no hay confirmación, detener T034 y T059

---

## Phase 2: Foundational

**Purpose**: Línea base de comportamiento para comparar después (SC-005).

**⚠️ CRITICAL**: Ninguna User Story empieza antes de completar esta fase.

- [x] T003 Jugar Niveles 1, 2 y 3 en el commit `13aad48` (o HEAD actual de la rama, que no cambia código) siguiendo la tabla de [quickstart.md §4](./quickstart.md#4-partida-sc-005) y anotar cualquier comportamiento que difiera de lo esperado en esa tabla, para no confundirlo luego con una regresión del refactor
  - Pendiente (manual). Línea base automatizada registrada en su lugar: arnés con Xvfb que juega Niveles 1–3 (victoria y derrota) desde el menú en `13aad48`.

**Checkpoint**: Árbol limpio, confirmación de `project.godot` registrada, comportamiento de referencia conocido.

---

## Phase 3: User Story 1 — Limpieza y reglas actualizadas (Priority: P1) 🎯 MVP

**Goal**: Borrar el código legacy, hacer que `AGENTS.md` del proyecto y la constitución exijan inglés remitiendo al `AGENTS.md` raíz, publicar el mapa de renombres y agregar el script de chequeo con su línea base.

**Independent Test**: El proyecto abre en Godot sin errores de dependencias y los Niveles 1, 2 y 3 se juegan; `AGENTS.md` del proyecto y `.specify/memory/constitution.md` exigen inglés y remiten al `AGENTS.md` raíz; `godot --headless --path . --script res://tools/check_rules.gd` reporta 13 `LONG_FUNCTION` más los `OLD_IDENTIFIER` y `REMOVED_IDENTIFIER` pendientes.

### Limpieza (FR-002, SC-004)

- [X] T004 [US1] Borrar con `git rm` exactamente estos archivos y ningún otro: `Mago.gd`, `Mago.gd.uid`, `Mago.tscn`, `Mortifago.gd`, `Mortifago.gd.uid`, `Mortifago.tscn`, `tile_map_layer.gd`, `tile_map_layer.gd.uid`, `Imagenes/Mortifago.png`, `Imagenes/Mortifago.png.import`, `Imagenes/Pasto.png1391487371.tmp`. Antes, confirmar con `grep -n "Mago\|Mortifago\|tile_map_layer" *.tscn *.gd` que ninguna escena del juego referencia esos archivos como `ext_resource` (las coincidencias `TimerSpawneoMortifagos` son nombres de nodo y se renombran en US2, no son referencias)
- [X] T005 [US1] Verificar SC-004: `git ls-files | grep -E "Mago|Mortifago|tile_map_layer|\.tmp$"` no devuelve nada

### Documentación de reglas (FR-003, FR-004)

- [X] T006 [P] [US1] Enmendar `AGENTS.md` del proyecto: (a) agregar al inicio que el `AGENTS.md` raíz del repositorio (`../../AGENTS.md`) es la regla superior y prevalece; (b) exigir identificadores y comentarios en inglés y textos visibles en español; (c) agregar al diccionario temático (Moneda, tabla de Aliados, lista de Enemigos) una columna "Identificador" con el nombre en inglés según R2 de `research.md` (Snitches → `snitch`, Harry → `Harry`, Caja de Snitch → `SnitchBox`, Recordadora → `Remembrall`, Protego → `Protego`, Alumno Slytherin → `SlytherinStudent`, Draco → `Draco`, Profesor Quirrell → `Quirrell`; para los aún no implementados usar el nombre oficial en inglés de los libros); (d) cambiar los grupos reservados a `allies`, `enemies`, `spells`; (e) traducir al inglés los identificadores de los ejemplos de código (`salud` → `health`, `recibir_danio` → `take_damage`, `salud_agotada` → `health_depleted`, `coste` → `cost`, `tiempo_recarga` → `cooldown`, `escena_proyectil` → `projectile_scene`)
- [X] T007 [US1] Verificar que `.specify/memory/constitution.md` está en v1.1.0 (enmendada con `/speckit-constitution` antes de `/speckit-implement`): principio III exige inglés y remite al `AGENTS.md` raíz; principio IV usa `allies`, `enemies`, `spells`; el Sync Impact Report registra la fecha de aprobación del equipo. Si no, detener la implementación
- [X] T008 [P] [US1] Revisar `specs/004-refactor-catedra/rename-map.md` contra el código actual: cada identificador en español de los `.gd`, `.tscn` y `pergamino.gdshader` del alcance (R1 de `research.md`) figura en alguna tabla. Agregar las filas faltantes en la sección que corresponda (Archivos, Clases, Grupos, Señales, Métodos, Variables exportadas, Variables de miembro y constantes, Nodos, Uniforms y funciones del shader)

### Script de chequeo (FR-016)

- [X] T009 [US1] Crear `tools/check_rules.gd` (`extends SceneTree`, tipado estricto, todo en inglés, ninguna función > 15 líneas, sin números mágicos) que cumpla [contracts/check-rules-cli.md](./contracts/check-rules-cli.md): constante con la ruta `res://specs/004-refactor-catedra/rename-map.md`; parseo de la primera celda de cada fila de tabla solo si es un único identificador entre backticks (ignora `—`, celdas con espacios o varios identificadores); recorrido recursivo de `.gd`, `.tscn` y `.gdshader` bajo `res://` excluyendo `addons/`, `godot-mcp-main/`, `.godot/`, `specs/` (y `tools/` no se excluye: el script también se chequea a sí mismo)
- [X] T010 [US1] Implementar en `tools/check_rules.gd` la regla `LONG_FUNCTION` (solo `.gd`): cuerpo desde la línea siguiente a `func` hasta la última línea no vacía antes de la próxima línea sin indentar; cuentan líneas en blanco y comentarios intermedios; las líneas en blanco finales no (R4). Salida `LONG_FUNCTION res://<file>:<line> <func_name> (<n> lines)`
- [X] T011 [US1] Implementar en `tools/check_rules.gd` las reglas `OLD_IDENTIFIER` y `REMOVED_IDENTIFIER` (según la segunda celda de la fila del mapa: nombre nuevo o `—`, ver contrato): coincidencia `\b<id>\b` sensible a mayúsculas con `RegEx`; ignorar líneas de `.tscn` que empiezan con `text = `, líneas de `.gd` que declaran una `const` con sufijo `_TEXT` y rutas bajo `res://Imagenes/`. Salida `OLD_IDENTIFIER res://<file>:<line> <id>` o `REMOVED_IDENTIFIER res://<file>:<line> <id>`
- [X] T012 [US1] Completar `tools/check_rules.gd`: hallazgos ordenados por archivo y línea en stdout; resumen final `check_rules: <n> findings (<a> LONG_FUNCTION, <b> OLD_IDENTIFIER, <c> REMOVED_IDENTIFIER)` (o `check_rules: 0 findings`); `quit()` con código 0 sin hallazgos, 1 con al menos uno, 2 si no se pudo leer el mapa
- [X] T013 [US1] Correr `godot --headless --path . --script res://tools/check_rules.gd` y verificar la línea base: exactamente 13 `LONG_FUNCTION` (las del spec: `_intentar_plantar` 64, `snitch._process` 38, `_aplicar_estilo_pergamino_boton` 35, `_generar_caminante_ambiental` 34, `_on_timer_spawneo_timeout` 27, `_on_timer_generacion_snitches_timeout` 27, etc.) más los `OLD_IDENTIFIER` y `REMOVED_IDENTIFIER`. Si el número de `LONG_FUNCTION` difiere, corregir T010 antes de seguir. Guardar el resumen en el mensaje de commit

### Cierre US1

- [x] T014 [US1] Abrir el proyecto en Godot (verificación con `godot-mcp`, principio V): sin recursos faltantes en Output; jugar Niveles 1, 2 y 3 ([quickstart.md §3–4](./quickstart.md)). Commit `chore(refactor): remove legacy code and adopt course coding rules`
  - Pendiente (manual/`godot-mcp`). Verificado en headless: importación del editor sin errores, escenas cargan, arnés de partida sin errores. Commit hecho.

**Checkpoint**: Legacy borrado, reglas documentadas, chequeo funcionando con línea base registrada.

---

## Phase 4: User Story 2 — Identificadores en inglés (Priority: P1)

**Goal**: Todo identificador y comentario de `.gd`, `.tscn` y `.gdshader` en inglés según `rename-map.md`, con `uid://` preservados y textos visibles en español.

**Independent Test**: Niveles 1, 2 y 3 se completan con victoria y derrota igual que antes; `tools/check_rules.gd` reporta 0 `OLD_IDENTIFIER`.

**Procedimiento común a T015–T033** (editor de Godot cerrado, R13): (1) `git mv` de `.gd`, `.gd.uid` y `.tscn` según la tabla "Archivos" de `rename-map.md`; (2) en el `.gd`: `class_name`, señales, métodos, variables exportadas y de miembro, constantes, rutas `$Nodo`, variables locales, parámetros y comentarios (incluidos `##`) al inglés según las tablas del mapa; (3) en el `.tscn` propio: `[ext_resource path=]` al nuevo nombre conservando `uid=`, nombres de nodo, grupos, propiedades exportadas sobrescritas y líneas `[connection ... method=]` según [contracts/node-interfaces.md](./contracts/node-interfaces.md); (4) en **toda** escena o script que referencie lo renombrado (`grep -rn "<viejo>" --include='*.gd' --include='*.tscn' .`), actualizar `path=` y usos; (5) abrir el editor, inspeccionar con `godot-mcp` (si no responde, detenerse y reportar), verificar 0 errores de carga, jugar el nivel afectado y commitear el bloque.

### Bloque 1: Enemigos

- [X] T015 [US2] Renombrar `alumno_slytherin.gd/.gd.uid/.tscn` → `slytherin_student.gd/.gd.uid/.tscn`, `class_name AlumnoSlytherin` → `SlytherinStudent`, señales `derrotado` → `defeated`, `invasion_jardin` → `garden_invaded`, `recibir_danio` → `take_damage`, nodos y callbacks según `rename-map.md` (ej. `AreaDeteccion` → `DetectionArea`, `_on_area_deteccion_area_entered` → `_on_detection_area_area_entered`, timer de animación → `AnimationTimer` con `_on_animation_timer_timeout`). Grupo en el `.tscn`: mantener `enemigos` hasta T034
- [X] T016 [US2] Renombrar en `draco.gd` y `draco.tscn` los mismos identificadores que T015 (señales, métodos, nodos, conexiones). Hoy la vida de Draco es el default del script (`salud_maxima: int = 400` en `draco.gd`) y `draco.tscn` no la sobrescribe: renombrar el export a `max_health` en `draco.gd` conservando el valor 400
- [X] T017 [US2] Actualizar en `nivel_principal.gd`, `NivelPrincipal.tscn`, `nivel_2.tscn`, `nivel_3.tscn` y `dementor.gd`/`Proyectil.gd`/`recordadora.gd`/`harry.gd` todos los usos de lo renombrado en T015–T016: `ext_resource path="res://alumno_slytherin.tscn"` → `res://slytherin_student.tscn`, conexiones por código a `derrotado`/`invasion_jardin`, llamadas `call("recibir_danio", ...)`/`has_method("recibir_danio")`. Jugar Nivel 3 (Draco). Commit `refactor(enemies): rename enemy identifiers to english`

### Bloque 2: Aliados y proyectil

- [X] T018 [P] [US2] Renombrar en `harry.gd` y `harry.tscn` según el mapa (`coste` se conserva: fila `—` del mapa, se elimina en T047; `tiempo_recarga` → `shot_interval`, es el intervalo de disparo de 1.5 s; `salud` → `health`, `recibir_danio` → `take_damage`, `derrotado` → `defeated`, timer de disparo → `ShootTimer` con `_on_shoot_timer_timeout`, `escena_proyectil` → `projectile_scene` también en el `.tscn`)
- [X] T019 [P] [US2] Renombrar `caja_snitch.gd/.gd.uid/.tscn` → `snitch_box.*`, `class_name CajaSnitch` → `SnitchBox`, señal `snitch_soltada` → `snitch_dropped`, timer → `SnitchTimer` con `_on_snitch_timer_timeout`, `coste` se conserva (fila `—`, se elimina en T049), demás según el mapa (la señal muerta `snitches_generadas` se elimina en T049, aquí solo se deja como está si no figura en el mapa con nombre nuevo)
- [X] T020 [P] [US2] Renombrar `recordadora.gd/.gd.uid/.tscn` → `remembrall.*`, agregar `class_name Remembrall`, señal → `detonated`, timer → `FuseTimer` con `_on_fuse_timer_timeout`, área → `ExplosionArea`, propiedad → `explosion_damage`, `coste` y `tiempo_recarga` se conservan (filas `—`, se eliminan en T050), demás según el mapa
- [X] T021 [P] [US2] Renombrar en `protego.gd` y `protego.tscn` según el mapa (`coste` y `tiempo_recarga` se conservan: filas `—`, se eliminan en T048; `salud` → `health`, `recibir_danio` → `take_damage`, `derrotado` → `defeated`)
- [X] T022 [P] [US2] Renombrar `Proyectil.gd/.gd.uid/.tscn` → `projectile.*`, `class_name Proyectil` → `Projectile`, propiedades (`danio` → `damage` tipo `float`), callbacks `_on_area_entered` y `_on_screen_exited` según [node-interfaces.md](./contracts/node-interfaces.md). No renombrar `Imagenes/Proyectil.png` (R1)
- [X] T023 [US2] Actualizar referencias de T018–T022 en `nivel_principal.gd`, `NivelPrincipal.tscn`, `nivel_2.tscn`, `nivel_3.tscn`, `harry.tscn` (ext_resource del proyectil) y en enemigos (`slytherin_student.gd`, `draco.gd`) donde llamen a métodos del aliado. Jugar Niveles 1 y 3. Commit `refactor(allies): rename ally and projectile identifiers to english`

### Bloque 3: Snitch y Dementor

- [X] T024 [P] [US2] Renombrar en `snitch.gd` y `snitch.tscn` según el mapa (señal `recogida` → `collected`, `valor` → `value`, método de inicialización desde la caja → `setup_from_box(origin: Vector2)`, `_on_input_event`, `AnimationTimer` con `_on_animation_timer_timeout`)
- [X] T025 [P] [US2] Renombrar en `dementor.gd` y `dementor.tscn` según el mapa (señales `activado` → `activated`, agotado → `exhausted`, grupo `dementores` → `dementors` en el `.tscn` y en las consultas del `.gd`)
- [X] T026 [US2] Actualizar referencias de T024–T025 en `snitch_box.gd`, `nivel_principal.gd` y escenas de nivel. Jugar Nivel 1 (snitch del cielo y de la caja, dementor). Commit `refactor(pickups): rename snitch and dementor identifiers to english`

### Bloque 4: Niveles

- [X] T027 [US2] Renombrar `nivel_principal.gd/.gd.uid` → `level.gd/.gd.uid`, `class_name NivelPrincipal` → `Level`, y dentro del script todas las variables, `@export`, `@onready`, métodos, callbacks y comentarios según el mapa (ej. `_intentar_plantar` → `_try_place_ally`, `_on_timer_spawneo_timeout` → `_on_enemy_spawn_timer_timeout`, `$TimerSpawneoMortifagos` → `$EnemySpawnTimer`, `snitches` → `_snitches`, `_victoria` → `_win`, `_derrota` → `_lose`). Los textos visibles (`"¡VICTORIA!"`, `"Snitches: %d"`, etc.) quedan en español en `const *_TEXT`
- [X] T028 [US2] Renombrar `NivelPrincipal.tscn` → `level_1.tscn`, `nivel_2.tscn` → `level_2.tscn`, `nivel_3.tscn` → `level_3.tscn` (sin `.uid`; conservar el `uid://` del encabezado `[gd_scene]`). En las tres: `ext_resource` de `level.gd`, nombre del nodo raíz, nodos del HUD y paneles según la sección Nodos del mapa (`TimerSpawneoMortifagos` → `EnemySpawnTimer`, timer de snitches → `SnitchSpawnTimer`, botones de fin → `NextLevelButton`/`RetryButton`/`BackToMapButton`, panel → `LevelEndPanel`), propiedades exportadas sobrescritas y todas las líneas `[connection]` según [node-interfaces.md](./contracts/node-interfaces.md). Las conexiones `pressed` de los botones de aliados y sus callbacks (`_on_boton_*_pressed`, filas `—` del mapa) conservan su nombre actual y se eliminan en T055–T056
- [X] T029 [US2] Actualizar referencias a las escenas de nivel en `menu_niveles.gd`/`menu_niveles.tscn` (exports y rutas `res://nivel_2.tscn` de respaldo), en `level.gd` (escena de siguiente nivel / menú). `project.godot` no se toca: `run/main_scene` apunta por `uid://c0vgnide3ben3`, que sobrevive al renombre. Jugar los tres niveles. Commit `refactor(levels): rename level identifiers to english`

### Bloque 5: Menú

- [X] T030 [P] [US2] Renombrar `pergamino.gdshader/.gdshader.uid` → `parchment.gdshader/.gdshader.uid`, uniforms y funciones según la sección "Uniforms y funciones del shader" del mapa, comentarios al inglés
- [X] T031 [P] [US2] Renombrar `huella.gd/.gd.uid` → `footprint.gd/.gd.uid`, `class_name Huella` → `Footprint`, miembros y comentarios según el mapa
- [X] T032 [US2] Renombrar `menu_niveles.gd/.gd.uid/.tscn` → `level_select_menu.*`, `class_name MenuNiveles` → `LevelSelectMenu`, métodos (`_generar_caminante_ambiental` → `_spawn_ambient_walker`, `_aplicar_estilo_pergamino_boton` sin renombrar (fila `—`, se elimina en T063), `_animar_pasos_en_camino` → `_schedule_path_steps`, etc.), variables, nodos (`NivelN` → `LevelN`), señal → `level_selected(level_number: int)`. En `level_select_menu.tscn`: `ext_resource` de `level_select_menu.gd`, `parchment.gdshader` y `footprint.gd`; cada `shader_parameter/<viejo>` → `shader_parameter/<nuevo>`; conexiones
- [X] T033 [US2] Actualizar referencias al menú en `level.gd` y en las tres escenas de nivel (`level_select_scene` u homólogo exportado, `ext_resource` de `level_select_menu.tscn`). `project.godot` no se toca (`run/main_scene` usa `uid://`). Verificar en el editor que el menú se ve igual (pergamino, huellas, caminantes). Commit `refactor(menu): rename menu, footprint and shader identifiers to english`
  - Desvío: `level_select_scene` es `@export_file` (ruta `uid://`) y no `PackedScene`: el menú ya referencia los niveles y Godot rechaza referencias cíclicas entre escenas.

### Bloque 6: Grupos (requiere T002)

- [X] T034 [US2] Renombrar grupos en todos los `.tscn` (`groups=["aliados"]` → `["allies"]`, `enemigos` → `enemies`, `hechizos` → `spells`) y en todas las consultas `is_in_group`/`get_nodes_in_group`/`add_to_group` de los `.gd` (como string por ahora; pasan a `Groups.*` en T036). En `project.godot`, sección `[global_group]` únicamente: `aliados=""` → `allies=""`, `enemigos=""` → `enemies=""`, `hechizos=""` → `spells=""`. No tocar ninguna otra línea de `project.godot`
- [X] T035 [US2] Cierre US2: `check_rules.gd` reporta 0 `OLD_IDENTIFIER` (los `REMOVED_IDENTIFIER` se resuelven en US3); `git grep -nIE "[áéíóúñ]|cion\b|_de_|_del_" -- "*.gd" "*.gdshader"` solo devuelve líneas `const *_TEXT`; SC-003: `git grep -nwE "aliados|enemigos|hechizos" -- "*.gd" "*.tscn" project.godot` vacío; SC-002 con el `diff` de reglas transversales; con `godot-mcp`, entidades en sus grupos ([quickstart.md §3](./quickstart.md#3-proyecto-abre-sin-errores)); partida completa de los tres niveles con victoria y derrota. Commit `refactor(groups): rename collision groups to english`

**Checkpoint**: Todo en inglés salvo los identificadores `—` pendientes de US3, juego idéntico, 0 `OLD_IDENTIFIER`.

---

## Phase 5: User Story 3 — Funciones cortas, constantes y estructura (Priority: P1)

**Goal**: 0 funciones de más de 15 líneas, 0 números/strings mágicos, sin lógica duplicada (bases `Ally`/`Enemy`, `DamageFlash`, `AllyCard`, `GameManager`, `Theme`).

**Independent Test**: `check_rules.gd` imprime `check_rules: 0 findings` con código 0; los tres niveles se juegan igual ([quickstart.md §4](./quickstart.md#4-partida-sc-005)); agregar un nivel solo requiere sumarlo a `level_scenes` ([quickstart.md §5](./quickstart.md#5-menú-de-niveles-sc-006)).

### Paso 1: Constantes compartidas (FR-009)

- [X] T036 [US3] Crear `groups.gd` (`class_name Groups`, `extends RefCounted`) con `const ALLIES: StringName = &"allies"`, `const ENEMIES: StringName = &"enemies"`, `const SPELLS: StringName = &"spells"`, `const DEMENTORS: StringName = &"dementors"`. Reemplazar todos los strings de grupo de los `.gd` por estas constantes y eliminar las llamadas `add_to_group` redundantes en `_ready` (el grupo ya está en el `.tscn`, R8)
- [X] T037 [P] [US3] Crear `lane.gd` (`class_name Lane`, `extends RefCounted`, solo `static`) con `const LANE_TOLERANCE: float = 64.0`, `static func is_same_lane(a_y: float, b_y: float) -> bool` y `static func enemies_in_lane(tree: SceneTree, lane_y: float) -> Array[Node2D]`. Reemplazar los tres usos de `64.0` en `harry.gd` y `dementor.gd`
- [X] T038 [US3] Extraer a `const` (o `@export` si es valor de balance) todos los literales no permitidos (R9) de `projectile.gd`, `snitch.gd` (ej. límite de caída `1200.0`, radio de clic `32.0`), `dementor.gd` y `footprint.gd`; quitar los `print` de depuración (R12). Después de T037: ambas tocan `dementor.gd`
- [X] T039 [US3] Extraer a `const` en `level.gd`: `DEMENTOR_ROWS_Y: Array[float] = [320.0, 448.0, 576.0, 704.0, 832.0]` (mismo tipo que hoy en `nivel_principal.gd`), `DEMENTOR_X = 160`, `SKY_SNITCH_MIN_X = 300`, `SKY_SNITCH_MAX_X = 1150`, `SKY_SNITCH_Y = -20`, `EMPTY_CELL_SOURCE = -1`, y los textos `WIN_TITLE_TEXT`, `WIN_MESSAGE_TEXT`, `LOSE_TITLE_TEXT`, `LOSE_MESSAGE_TEXT`, `SNITCHES_LABEL_TEXT` con los valores actuales exactos. Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `refactor(core): extract shared groups, lane and constants`

### Paso 2: DamageFlash (FR-011)

- [X] T040 [US3] Crear `damage_flash.gd` (`class_name DamageFlash`, `extends Node`) y `damage_flash.tscn` (raíz `Node` con el script). Exports: `target: CanvasItem`, `flash_color: Color = Color(1.0, 0.3, 0.3)`, `duration: float`, `cooldown: float`, `fade_out: bool`. `func flash() -> void`: si `target == null` no hace nada; si está en enfriamiento no hace nada; tiñe `target.modulate` y lo devuelve a `Color.WHITE` con tween de `duration` si `fade_out`, o de golpe tras `duration` si no; arranca el enfriamiento si `cooldown > 0`. Sin trabajo por frame (usar `create_timer`/`create_tween`)
- [X] T041 [US3] Instanciar `damage_flash.tscn` como hijo `DamageFlash` en `slytherin_student.tscn` y `draco.tscn` con `target = Sprite2D`, `duration = 0.15`, `cooldown = 0.0`, `fade_out = true`
- [X] T042 [US3] Con el editor abierto, confirmar con `godot-mcp` que `harry.tscn`, `snitch_box.tscn` y `remembrall.tscn` tienen un hijo `Sprite2D` y que `protego.tscn` tiene un hijo `Visual` (principio V; si `godot-mcp` no responde, detenerse y reportar). Instanciar `damage_flash.tscn` como hijo `DamageFlash` en esas cuatro escenas (`target = Sprite2D`, o `Visual` en Protego) con `duration = 0.1`, `cooldown = 0.5` y `fade_out = false`. Si alguna escena no tiene el nodo esperado, detenerse y reportar en vez de conservar el `has_node("Sprite2D")`; si todas lo tienen, ese `has_node` se elimina en T047–T050

### Paso 3: Enemy (FR-010, FR-012)

- [X] T043 [US3] Crear `enemy.gd` (`class_name Enemy`, `extends Area2D`, sin escena) moviendo desde `slytherin_student.gd` el movimiento, ataque a aliados en `DetectionArea`, daño, textura de lastimado e invasión: exports `max_health: float = 200.0`, `speed: float = 32.0`, `damage_per_second: float = 30.0`, `hurt_texture: Texture2D`; señales `defeated(entity: Node2D)` y `garden_invaded()`; `const TOTAL_FRAMES: int = 8`; `@onready var damage_flash: DamageFlash = $DamageFlash`; `func take_damage(amount: float) -> void` (antes `int`) dividido en `_update_hurt_texture()`, `damage_flash.flash()` y `_die()`; callbacks `_on_detection_area_area_entered/_exited` y `_on_animation_timer_timeout`; validar objetivos con `is_in_group(Groups.ALLIES)` y llamar `(target as Ally).take_damage(...)` cuando exista `Ally` (hasta T046, mantener la llamada actual). Todas las funciones ≤ 15 líneas
- [X] T044 [US3] Reducir `slytherin_student.gd` a `class_name SlytherinStudent` + `extends Enemy` sin métodos propios, y `draco.gd` a `class_name Draco` + `extends Enemy` sin métodos propios. Mover las texturas/valores que hoy están en el script a exports sobrescritos en `slytherin_student.tscn` y `draco.tscn` (`max_health = 400.0` en `draco.tscn`, `hurt_texture` en ambos). Verificar que las `[connection]` de los `.tscn` siguen resolviendo a métodos heredados. Con `godot-mcp`, confirmar en una instancia de Draco en ejecución que `max_health == 400.0`, y en una de `SlytherinStudent` que `max_health == 200.0` (si `godot-mcp` no responde, detenerse y reportar)
- [X] T045 [US3] Actualizar `projectile.gd`, `remembrall.gd`, `dementor.gd` y `level.gd` para tipar enemigos como `Enemy` y llamar `take_damage(amount: float)` directo (sin `call`/`has_method` por string); `projectile.damage` y `dementor.damage` de tipo `float`. Jugar Nivel 3 (Draco aguanta el doble, flash con fundido, textura lastimada). Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `refactor(enemies): extract Enemy base class and DamageFlash`

### Paso 4: Ally (FR-012)

- [X] T046 [US3] Crear `ally.gd` (`class_name Ally`, `extends Area2D`, sin escena) con `@export var health: float = 100.0`, señal `defeated(entity: Node2D)`, `@onready var damage_flash: DamageFlash = $DamageFlash` y `func take_damage(amount: float) -> void` (resta vida, `damage_flash.flash()`, al llegar a `<= 0` emite `defeated(self)` y `queue_free()`)
- [X] T047 [P] [US3] `harry.gd`: `extends Ally`; borrar `health`, `take_damage`, señal `defeated` y contadores de flash de `_process`; quitar `coste`; disparo solo si `Lane.enemies_in_lane(...)` no está vacío; exports `shot_interval`, `projectile_scene`
- [X] T048 [P] [US3] `protego.gd`: `extends Ally`; borrar lo duplicado y `coste`/`tiempo_recarga`; fijar `health = 4000.0` en `protego.tscn` si hoy es default del script
- [X] T049 [P] [US3] `snitch_box.gd`: `extends Ally`; borrar lo duplicado y `coste`; eliminar señal muerta `snitches_generadas`, su handler y el respaldo `load("res://snitch.tscn")` (R12); dividir `_on_snitch_timer_timeout` (27 líneas) en `_play_open_animation()` y `_drop_snitch()`; exports `snitches_per_drop`, `drop_interval`, `snitch_scene`; constantes para los literales de animación
- [X] T050 [P] [US3] `remembrall.gd`: `extends Ally`; borrar lo duplicado y `coste`/`tiempo_recarga`; `explosion_damage` exportado; constantes para escala/color/tiempos de la explosión; enemigos de `ExplosionArea` tipados `Enemy`
- [X] T051 [US3] Cambiar en `enemy.gd` la llamada al aliado objetivo a `(target as Ally).take_damage(damage_per_second * delta)`. Jugar Nivel 3 (flash de aliados 0.1 s cada 0.5 s, Protego aguanta igual). Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `refactor(allies): extract Ally base class`

### Paso 5: AllyCard y AllyCardButton (FR-013)

- [X] T052 [P] [US3] Crear `ally_card.gd` (`class_name AllyCard`, `extends Resource`) con `@export var display_name: String`, `@export var scene: PackedScene`, `@export var cost: int`, `@export var cooldown: float`. Validación: `cost > 0`, `cooldown >= 0`, `scene != null` (con `assert` o `push_error` en un método `is_valid() -> bool`)
- [X] T053 [US3] Crear `harry_card.tres` (`display_name = "Harry"`, `scene = harry.tscn`, `cost = 100`, `cooldown = 0.0`), `snitch_box_card.tres` (`"Caja Snitch"`, `snitch_box.tscn`, `50`, `0.0`), `remembrall_card.tres` (`"Recordadora"`, `remembrall.tscn`, `150`, `25.0`), `protego_card.tres` (`"Protego"`, `protego.tscn`, `50`, `12.0`)
- [X] T054 [US3] Crear `ally_card_button.gd` (`class_name AllyCardButton`, `extends Button`) con `@export var card: AllyCard`, señales `card_pressed(button: AllyCardButton)` y `cooldown_finished()`, `var _cooldown_left: float`, `const SELECTED_COLOR: Color = Color(0.5, 1.0, 0.5)`, `const LABEL_FORMAT_TEXT: String = "%s (%d)"`; `_ready` arma `text = LABEL_FORMAT_TEXT % [card.display_name, card.cost]` y conecta `pressed`; `refresh(snitches: int)` → `disabled = snitches < card.cost or _cooldown_left > 0`; `set_selected(is_selected: bool)` → `modulate = SELECTED_COLOR` o `Color.WHITE`; `start_cooldown()` → `_cooldown_left = card.cooldown`; descuento de recarga en `_process` que emite `cooldown_finished` al llegar a 0 (solo trabaja si `_cooldown_left > 0`)
- [X] T055 [US3] En `level_1.tscn`, `level_2.tscn` y `level_3.tscn`: asignar `ally_card_button.gd` a los cuatro botones de aliados del HUD con su `card` (`harry_card.tres`, etc.), eliminar las cuatro conexiones `pressed` de esos botones y conservar el orden y posición actuales de los botones
- [X] T056 [US3] En `level.gd`: reemplazar la selección por string (`"harry"`, `"caja_snitch"`, …) por `var _selected_card: AllyCard` (`null` = nada); `_ready` conecta `card_pressed` → `_on_card_pressed` y `cooldown_finished` → `_refresh_hud` de cada `AllyCardButton`; `_on_card_pressed(button: AllyCardButton)` alterna selección (clic sobre la carta seleccionada la deselecciona); `_refresh_hud()` llama `refresh(_snitches)` y `set_selected(...)` en cada botón; eliminar los cuatro callbacks `_on_*_button_pressed` de aliados y las variables de recarga de Protego/Recordadora
- [X] T057 [US3] Dividir `Level._try_place_ally` (64 líneas) en `_cell_under_mouse() -> Vector2i`, `_can_place_at(cell: Vector2i) -> bool` (fila activa, `EMPTY_CELL_SOURCE`, celda libre en `_occupied_cells: Dictionary[Vector2i, Node2D]`) y `_place_ally(card: AllyCard, cell: Vector2i)` (instancia `card.scene`, descuenta `card.cost`, `start_cooldown()` del botón, libera la celda con `tree_exiting`). Eliminar el `match`. Jugar los tres niveles verificando costos y recargas 25 s / 12 s. Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `refactor(level): drive ally placement from AllyCard resources`

### Paso 6: GameManager y menú (FR-014, FR-015; requiere T002)

- [X] T058 [P] [US3] Crear `game_manager.gd` (`extends Node`, sin `class_name`) con `const INITIAL_UNLOCKED_LEVEL: int = 10`, `var max_unlocked_level: int = INITIAL_UNLOCKED_LEVEL` y `func unlock_level(level_number: int) -> void: max_unlocked_level = maxi(max_unlocked_level, level_number)`
- [X] T059 [US3] En `project.godot`, sección `[autoload]` únicamente: agregar `GameManager="*res://game_manager.gd"` debajo de la entrada existente `ClaudeBridgeGameCapture`. No tocar ninguna otra línea
- [X] T060 [US3] En `level.gd`: dividir `_win` (19 líneas) en `_stop_level()`, `GameManager.unlock_level(next_level_to_unlock)` y `_show_end_panel(title: String, message: String, show_next: bool)` compartido con `_lose`; agregar `@export var next_level_to_unlock: int` con valores 2/3/4 en `level_1/2/3.tscn`; eliminar `get_node_or_null("/root/GameManager")` y toda referencia a `LevelSelectMenu.progreso_desbloqueado` (o su nombre nuevo)
- [X] T061 [US3] Antes de editar, confirmar con `godot-mcp` en las tres escenas de nivel los hijos de `Spawners` y el valor actual de `spawn_points` (ex `spawners_activos`); si difieren de lo listado abajo, usar los de `godot-mcp` y anotarlo (principio V; si no responde, detenerse y reportar). En `level.gd`: `@export var enemy_scenes: Array[PackedScene]` y el export existente `spawn_points: Array[NodePath]` (renombrado en T027); dividir `_on_enemy_spawn_timer_timeout` (27 líneas) en `_pick_spawn_position() -> Vector2` y `_spawn_enemy(scene: PackedScene)` usando `enemy_scenes.pick_random()` (reemplaza `randi() % 2`); eliminar el respaldo `spawner_central`. En las escenas: `level_1.tscn` → `enemy_scenes = [slytherin_student]`, `spawn_points = [Marker2D3]`; `level_2.tscn` → `[slytherin_student]`, `Marker2D2..4`; `level_3.tscn` → `[slytherin_student, draco]`, `Marker2D..5`
- [X] T062 [US3] En `level_select_menu.gd`: `@export var level_scenes: Array[PackedScene]` (asignar `[level_1, level_2, level_3]` en `level_select_menu.tscn`); `_on_level_button_pressed` (20 líneas) queda en ~5: emite `level_selected` y, si `level_number <= level_scenes.size()`, carga `level_scenes[level_number - 1]`; si no hay escena no hace nada (igual que hoy los niveles 4–10: botón habilitado, sin carga). Leer el desbloqueo desde `GameManager.max_unlocked_level`. Eliminar la variable estática `progreso_desbloqueado`, el `@export nivel_maximo_desbloqueado` y las rutas `res://nivel_*.tscn`/`change_scene_to_file` de respaldo. `const LEVEL_COUNT: int = 10` (botones del mapa y largo del camino: reemplaza `range(1, 11)`, `clamp(..., 1, 10)` y `/ 9.0` por `LEVEL_COUNT - 1`); es independiente de `GameManager.INITIAL_UNLOCKED_LEVEL` (progresión inicial), aunque hoy valgan lo mismo. Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `feat(core): add GameManager autoload and data-driven level list`

### Paso 7: Theme y funciones restantes (FR-008)

- [X] T063 [US3] Crear `level_button_theme.tres` (`Theme`) con los cuatro `StyleBoxFlat` (normal, hover, pressed, disabled) y los colores de fuente que hoy arma `_aplicar_estilo_pergamino_boton` (valores exactos). En `level_select_menu.gd`: `@export var level_button_theme: Theme` asignado en el `.tscn`, aplicarlo a los botones y eliminar la función de estilo (35 líneas)
- [X] T064 [US3] En `level_select_menu.gd`: dividir `_spawn_ambient_walker` (34) en `_random_walker_origin()`, `_schedule_walker_step(...)` y `_schedule_walker_release(...)`; `_schedule_path_steps` (22) usando `_footprint_transform_at(distance: float, is_right_foot: bool) -> Transform2D`; `_start_path_footprints` (19) en `_clear_path_footprints()` y `_unlocked_path_length() -> float`; `_spawn_ambient_footprint` (17) con `_schedule_footprint_fade(footprint: Footprint)`. Todos los literales del Sistema A/B de huellas a `const`
- [X] T065 [US3] Dividir `Snitch._process` (38 líneas) en `_tick_timers(delta: float)`, `_process_escape(delta: float)`, `_process_fall(delta: float)`, `_try_start_escape()` y `_is_expired() -> bool`; eliminar `snitch._unhandled_input` (R12)
- [X] T066 [US3] Correr `check_rules.gd` y dividir cualquier función restante de más de 15 líneas (incluidas las nuevas de `enemy.gd`, `ally.gd`, `ally_card_button.gd`, `damage_flash.gd`, `tools/check_rules.gd`). Revisar a mano cada `.gd` contra la lista de literales permitidos de R9 (FR-009). Inspeccionar con `godot-mcp`; si no responde, detenerse y reportar. Commit `refactor(menu): move button style to theme and split long functions`

**Checkpoint**: `check_rules: 0 findings`, estructura extensible.

---

## Phase 6: Polish & Cross-Cutting

- [X] T067 Correr la validación completa de [quickstart.md](./quickstart.md): §1 `check_rules: 0 findings` y código de salida 0 (SC-001, SC-003); §2 revisión manual (locales en español, números mágicos, SC-002 sin archivos solo reindentados, SC-004 legacy); §3 proyecto abre sin errores y con `godot-mcp` grupos, `card` de cada `AllyCardButton` y `/root/GameManager` presentes
- [x] T068 Partida completa de Niveles 1, 2 y 3 con victoria y derrota según la tabla de [quickstart.md §4](./quickstart.md#4-partida-sc-005), comparando con lo anotado en T003 (SC-005). Incluir la prueba de desbloqueo de [quickstart.md §4](./quickstart.md#4-partida-sc-005) (fila "Desbloqueo"), que es la única que puede fallar con `INITIAL_UNLOCKED_LEVEL = 10`
  - Pendiente (manual). Equivalente automatizado: arnés en 6 escenarios (N1 victoria/derrota/desbloqueo, N2 victoria, N3 victoria/derrota) con los mismos resultados que la línea base; parpadeo de daño idéntico cuadro a cuadro; recargas 12 s/25 s; capturas de menú y HUD idénticas píxel a píxel contra `13aad48`.
- [X] T069 Prueba de extensibilidad (SC-006, [quickstart.md §5](./quickstart.md#5-menú-de-niveles-sc-006)): duplicar `level_3.tscn`, agregarlo como cuarto elemento de `level_scenes` en `level_select_menu.tscn`, comprobar que `Level4` lo carga sin tocar código, y descartar el cambio con `git restore`/`git clean` del archivo duplicado
- [X] T070 [P] Actualizar `BACKLOG.md` si menciona nombres de archivo o identificadores viejos (`alumno_slytherin`, `caja_snitch`, `recordadora`, `nivel_principal`, grupos en español) para que remita a los nuevos
- [X] T071 Verificar que `project.godot` difiere de `develop` solo en `[autoload]` (`GameManager`) y `[global_group]`: `git diff develop -- project.godot`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)** → **US1 (Phase 3)** → **US2 (Phase 4)** → **US3 (Phase 5)** → **Polish (Phase 6)**
- Las tres historias son **secuenciales** (el spec las define en orden de ejecución): US2 necesita el mapa revisado (T008) y el chequeo (T009–T013) de US1; US3 asume nombres en inglés y grupos renombrados (T034).
- **T002** bloquea T034 (grupos en `project.godot`) y T059 (autoload).
- **T007** bloquea T015: la constitución enmendada (identificadores en inglés, principio III) debe estar vigente antes del primer renombre de US2.

### Within Each User Story

- **US1**: T004 → T005; T006, T007, T008 en paralelo; T009 → T010 → T011 → T012 → T013 (mismo archivo); T014 al final.
- **US2**: los bloques 1→6 en orden (cada uno toca las escenas de nivel en su tarea de referencias). Dentro de cada bloque, las tareas [P] tocan archivos distintos y la tarea de referencias (T017, T023, T026, T029, T033) va al final.
- **US3**: Paso 1 → Paso 2 → Paso 3 → Paso 4 → Paso 5 → Paso 6 → Paso 7. T036 antes de T037–T038 (toca todos los `.gd` con strings de grupo, incluidos `harry.gd`, `dementor.gd` y `projectile.gd`); T037 antes de T038 (ambas editan `dementor.gd`); T040 antes de T041–T043; T043 antes de T044; T046 antes de T047–T051; T052 antes de T053–T054; T054 antes de T055–T057; T058 + T059 antes de T060 y T062.

### Parallel Opportunities

- US1: T006 (`AGENTS.md`), T007 (`constitution.md`), T008 (`rename-map.md`).
- US2 Bloque 2: T018–T022 (un aliado/proyectil cada una, archivos propios). Bloque 3: T024, T025. Bloque 5: T030, T031.
- US3: T047–T050 (un aliado cada una, después de T046); T058 con cualquier tarea del Paso 5.

## Parallel Example: User Story 2, Bloque 2

```text
T018 harry.gd / harry.tscn
T019 caja_snitch.* → snitch_box.*
T020 recordadora.* → remembrall.*
T021 protego.gd / protego.tscn
T022 Proyectil.* → projectile.*
# luego, en serie:
T023 referencias en level.gd y escenas de nivel
```

## Parallel Example: User Story 3, Paso 4

```text
T046 ally.gd                 # primero
T047 harry.gd                # en paralelo
T048 protego.gd
T049 snitch_box.gd
T050 remembrall.gd
T051 enemy.gd → Ally         # al final
```

## Implementation Strategy

### MVP (User Story 1)

1. Phase 1 + Phase 2 (árbol limpio, confirmación de `project.godot`, línea base de juego).
2. US1: legacy borrado, reglas documentadas, `check_rules.gd` con línea base de 13 `LONG_FUNCTION`.
3. **Parar y validar**: el proyecto abre y los tres niveles se juegan. A partir de aquí ningún código nuevo del equipo puede violar las reglas sin que el chequeo lo marque.

### Entrega incremental

- Cada bloque de US2 y cada paso de US3 terminan en un commit que deja el juego jugable. Si un bloque rompe algo, se revierte ese commit sin perder el resto.
- El equipo no toca `.gd` ni `.tscn` hasta que la rama se mergee a `develop` (Assumptions del spec).
