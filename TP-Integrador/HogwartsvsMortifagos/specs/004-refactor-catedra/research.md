# Research: Refactor de cumplimiento de las reglas de la cátedra

Decisiones tomadas en la Fase 0 del plan. Cada una resuelve una incógnita del spec o del código medido en `13aad48`.

## R1. Alcance de archivos

- **Decision**: Entran todos los `.gd`, `.tscn` y `.gdshader` del juego en la raíz del proyecto. Quedan fuera `addons/`, `godot-mcp-main/`, `.godot/`, `.specify/`, `specs/` y los assets de `Images/` (los nombres de imágenes no son identificadores de código).
- **Rationale**: §7 exige "todo el código, sin excepción". `pergamino.gdshader` es código (uniforms y funciones en español), y sus uniforms se referencian desde `menu_niveles.tscn` como `shader_parameter/...`. El addon `godot_mcp_bridge` no es código del juego y no es responsabilidad del equipo.
- **Alternatives considered**: Solo `.gd` y `.tscn` (como dice FR-006). Se descarta porque dejaría el shader en español y la cátedra no hace excepciones. Renombrar `Images/` y las texturas: cambia `uid` e `.import` sin aportar a ninguna regla.

## R2. Convención de nombres

- **Decision**: Archivos en `snake_case` inglés (`slytherin_student.gd`), `class_name` en `PascalCase`, métodos y variables en `snake_case`, constantes en `UPPER_SNAKE_CASE`, nodos en `PascalCase`. Los nombres propios del universo se conservan (`Harry`, `Draco`, `Protego`, `Snitch`, `Dementor`, `Quirrell`). Las traducciones de entidades usan el nombre oficial en inglés de los libros: Recordadora → `Remembrall`, Caja de Snitch → `SnitchBox`, Alumno Slytherin → `SlytherinStudent`.
- **Rationale**: Es la guía de estilo oficial de GDScript, compatible con Google Style. Los nombres oficiales evitan inventar traducciones.
- **Alternatives considered**: `PascalCase` para archivos (`Proyectil.tscn` hoy). Se descarta por inconsistente con el resto del repo.

## R3. Indentación

- **Decision**: No se toca. Los `.gd` conservan las tabulaciones y `.editorconfig` no cambia (clarificación 2026-10-01). El código nuevo usa tabulaciones.
- **Rationale**: La configuración de Godot del equipo es desconocida; reindentar ahora generaría diffs de formato mezclados con lógica.
- **Alternatives considered**: Reindentar en esta pasada (descartado por el equipo).

## R4. Regla de medición de 15 líneas

- **Decision**: Se cuentan todas las líneas del cuerpo, desde la línea siguiente al `func` hasta la última línea no vacía antes de la próxima declaración de nivel superior. Las líneas en blanco y los comentarios internos cuentan; las líneas en blanco finales no.
- **Rationale**: Es la regla que reproduce la medición del spec (13 funciones, `_intentar_plantar` = 64). Es la más estricta y la más fácil de verificar a mano.
- **Alternatives considered**: Contar solo líneas de código. Da 10 funciones en vez de 13 y la cátedra podría medir distinto.

## R5. Costos y recargas de aliados (FR-013)

- **Decision**: Un `Resource` `AllyCard` (`scene`, `cost`, `cooldown`) por aliado, guardado como `.tres`. Cada botón del HUD tiene el script `AllyCardButton` con la carta exportada: muestra su estado (costo alcanzable, recarga, selección) y emite `card_pressed`. El nivel solo guarda la carta seleccionada.
- **Rationale**: Hoy el costo está en tres lugares (`coste` exportado en la escena, el `match` de `_intentar_plantar` y `_actualizar_hud`) y la recarga en dos (`protego.tiempo_recarga` y `nivel.tiempo_recarga_protego`; la Recordadora tiene `25.0` fijo en el nivel). Con la carta, el `match`, los cuatro callbacks de botón, las dos variables de recarga y los strings `"harry"`, `"caja_snitch"`, etc. desaparecen. Agregar un aliado es crear su escena, su `.tres` y un botón. Es el patrón Strategy (la carta decide qué se planta y cuánto cuesta) más un componente de UI.
- **Alternatives considered**:
  - Leer `cost` del `PackedScene` con `get_state()`: solo ve valores sobrescritos en la escena, no el default del script. Frágil.
  - Instanciar cada aliado una vez para leer `cost`: funciona pero crea nodos descartables y oculta la fuente.
  - El `cost` sigue exportado en la escena del aliado y la carta lo duplica: viola "única fuente".
- **Impacto en el spec**: el escenario 5 de la User Story 3 ("se cambia el `cost` exportado de una entidad") se cumple cambiando el `cost` de la carta. Las variables `coste` y `tiempo_recarga` se eliminan de los scripts de aliados.

## R6. Clases base

- **Decision**: `Enemy` (`enemy.gd`, `extends Area2D`, sin escena propia) con movimiento, ataque, daño, textura de lastimado e invasión. `SlytherinStudent` y `Draco` hacen `extends Enemy` y no redefinen métodos; la vida de Draco (400) se fija en `draco.tscn`. Además, `Ally` (`ally.gd`) con `health`, `defeated` y `take_damage`, base de `Harry`, `SnitchBox`, `Remembrall` y `Protego`.
- **Rationale**: FR-010 pide la base de enemigos. La de aliados no la pide el spec, pero sin ella `recibir_danio` sigue duplicado en cuatro scripts, contra §5 y el objetivo "sin lógica duplicada" de la User Story 3. Se mantiene un script por entidad (`AGENTS.md` del proyecto), aunque el de Draco quede casi vacío.
- **Alternatives considered**: Escena base `enemy.tscn` con escenas heredadas: la herencia de escenas en Godot complica los diffs y los `uid`, y el problema es solo de lógica.

## R7. Feedback de daño (FR-011)

- **Decision**: Componente `DamageFlash` (`damage_flash.tscn` + `damage_flash.gd`, `extends Node`) instanciado como hijo en cada entidad. Exporta `target: CanvasItem`, `flash_color`, `duration`, `cooldown` y `fade_out: bool`. Las bases `Ally` y `Enemy` llaman `damage_flash.flash()`.
- **Rationale**: Hoy hay dos comportamientos: los enemigos vuelven a blanco con un tween de 0.15 s sin enfriamiento; los aliados vuelven de golpe tras 0.1 s con 0.5 s de enfriamiento. FR-001 prohíbe cambiar visuales, así que el componente soporta ambos y cada escena fija sus valores. El spec menciona que este componente es la base de la futura animación de hechizos.
- **Alternatives considered**: Unificar en un solo comportamiento: cambia lo visible (FR-001).

## R8. Grupos

- **Decision**: Los grupos se declaran solo en los `.tscn` (`groups=["allies"]`) y se consultan con constantes de `Groups` (`groups.gd`, `const ALLIES: StringName = &"allies"`). Se eliminan las llamadas `add_to_group` duplicadas. Renombres: `aliados`→`allies`, `enemigos`→`enemies`, `hechizos`→`spells`, `dementores`→`dementors`. En `project.godot` se renombran las entradas de `[global_group]`.
- **Rationale**: Los grupos ya están en cada `.tscn`, así que `add_to_group` en `_ready` es redundante. Las constantes eliminan strings mágicos (§6). `[global_group]` de `project.godot` hoy declara `aliados`, `enemigos` y `hechizos`: dejar esas entradas viejas mantiene identificadores en español.
- **Alternatives considered**: Dejar `project.godot` sin tocar (los grupos funcionan aunque no estén declarados globalmente): deja nombres viejos en el repo y el chequeo los marcaría.
- **Impacto en el spec**: FR-015 decía "nada más de `project.godot` cambia"; se amplió en este plan para incluir `[global_group]`. Ambos cambios requieren la misma confirmación del equipo.

## R9. Constantes compartidas y carriles

- **Decision**: `Lane` (`lane.gd`, solo funciones `static`) con `LANE_TOLERANCE = 64.0` y `is_same_lane(a_y, b_y)`. Lo usan `Harry` (¿hay enemigo en mi carril?) y `Dementor` (barrido). El resto de los literales pasa a `const` en el script que lo usa, o a `@export` si es un valor de balance.
- **Rationale**: `64.0` aparece tres veces en dos scripts con el mismo significado.
- **Qué es un literal permitido**: `0`, `1`, `0.0`, `1.0`, `-1.0` como signo, `""`, `Vector2.ZERO`, `Vector2.ONE`, `Color.WHITE` y rutas de nodos (`$Sprite2D`). Todo lo demás va a una `const` o a un `@export`. Los textos visibles para el jugador (en español) van a constantes con sufijo `_TEXT`.

## R10. Progresión de niveles (FR-014, FR-015)

- **Decision**: Autoload `GameManager` (`game_manager.gd`, sin `class_name`) con `max_unlocked_level: int` y `unlock_level(level_number: int)`. El valor inicial es `INITIAL_UNLOCKED_LEVEL = 10`. El menú lee el autoload y obtiene las escenas de `@export var level_scenes: Array[PackedScene]`. Se eliminan `MenuNiveles.progreso_desbloqueado` (variable estática), el `@export nivel_maximo_desbloqueado` y las rutas `res://nivel_2.tscn` de respaldo.
- **Rationale**: Hoy los 10 niveles arrancan desbloqueados (`progreso_desbloqueado = 10`). FR-001 obliga a conservarlo; arrancar en 1 es una decisión de juego para otra feature. La variable estática acopla el nivel a la clase del menú.
- **Alternatives considered**: Mantener la variable estática: no cumple FR-015.

## R11. Spawn de enemigos

- **Decision**: El nivel exporta `enemy_scenes: Array[PackedScene]` y elige con `pick_random()`. Nivel 1 y 2: `[slytherin_student]`. Nivel 3: `[slytherin_student, draco]`. `spawn_points: Array[NodePath]` se completa en las tres escenas (Nivel 1: solo el `Marker2D3` central), y se elimina el respaldo `spawner_central`.
- **Rationale**: Mismo reparto 50/50 que `randi() % 2` sin número mágico y sin caso especial para Draco. Agregar un enemigo a un nivel es solo agregar una escena al array.

## R12. Código muerto y depuración

- **Decision**: Se eliminan la señal `snitches_generadas` y `_on_snitches_generadas` (nadie las conecta), `snitch._unhandled_input` (duplica `_input`, que siempre se ejecuta antes y marca el evento como manejado), los `print` de depuración y los respaldos `load("res://snitch.tscn")` y `change_scene_to_file(...)` (las escenas exportadas siempre están asignadas). Las señales sin oyente que modelan eventos de la entidad (`activated`, `exhausted`, `detonated`, `level_selected`) se conservan renombradas.
- **Rationale**: Nada de esto cambia el comportamiento observable, y cada elemento suma líneas o strings mágicos.

## R13. Mecánica de renombrado

- **Decision**: Con el editor de Godot cerrado: `git mv` del archivo y de su `.uid`, y actualización por texto de cada `ext_resource path=`, de las líneas `[connection ... method=]`, de las propiedades exportadas en `.tscn` y de los `shader_parameter/`. Después se abre el editor y se verifica que no haya errores de carga. Un commit por entidad (o grupo chico de entidades) dentro de la User Story 2.
- **Rationale**: El `.uid` conserva el `uid://`. Las escenas que referencian por `path` sin `uid` (`harry.tscn`, `caja_snitch.tscn`, `dementor.tscn`, etc.) se rompen si no se actualiza el `path`. El renombrado del editor (FileSystem dock) también actualiza referencias, pero no cubre métodos ni propiedades, y no deja un diff revisable.
- **Riesgo**: una propiedad exportada renombrada en el `.gd` pero no en el `.tscn` no da error: Godot descarta el valor en silencio y usa el default. Por eso el chequeo también busca los nombres viejos en los `.tscn`.

## R14. Script de chequeo (FR-016)

- **Decision**: `tools/check_rules.gd` (`extends SceneTree`), ejecutado con `godot --headless --path . --script res://tools/check_rules.gd`. Lee la columna "Actual" de `specs/004-refactor-catedra/rename-map.md`, recorre los `.gd`, `.tscn` y `.gdshader` del alcance (R1) y reporta funciones de más de 15 líneas (regla R4) e identificadores viejos. Termina con código 1 si encuentra algo. Contrato en [`contracts/check-rules-cli.md`](./contracts/check-rules-cli.md).
- **Rationale**: Solo depende de Godot, que todo el equipo ya tiene. El script cumple las mismas reglas (inglés, tipado, ≤ 15 líneas).
- **Alternatives considered**:
  - Python: no hay garantía de que esté instalado en las máquinas del equipo.
  - `EditorScript` (menú File > Run): no se puede correr desde la terminal ni en CI.
  - Chequear números mágicos automáticamente: una heurística así da demasiados falsos positivos. Se revisa a mano con la lista de R9.
- **Nota**: Godot no está instalado en la máquina donde se armó este plan; el script se valida en la de un integrante.

## R15. Verificación

- **Decision**: Sin tests automatizados (como en 001–003). Después de cada historia: chequeo de reglas, apertura del proyecto sin errores y partida de los Niveles 1, 2 y 3 con victoria y derrota. El estado de escenas, grupos y señales se confirma con `godot-mcp` (principio V de la constitución).
