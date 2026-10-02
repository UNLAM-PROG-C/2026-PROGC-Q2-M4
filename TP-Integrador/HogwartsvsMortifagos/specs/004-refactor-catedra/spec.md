# Especificación: Refactor de cumplimiento de las reglas de la cátedra

**Feature Branch**: `004-refactor-catedra`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Ajustar todo el código del juego a las reglas del `AGENTS.md` de la raíz (dadas por la cátedra, que corrige el trabajo) antes de sumar más entidades o features."

## Contexto

El `AGENTS.md` de la raíz del repositorio es la regla de la cátedra y **prevalece** sobre el `AGENTS.md` del proyecto y sobre `.specify/memory/constitution.md`, que hoy exigen identificadores temáticos en español. Medición al 2026-09-30 sobre el commit `13aad48` (Nivel 3 terminado), 12 scripts `.gd` del juego sin contar el código legacy:

| Regla (`AGENTS.md` raíz) | Estado actual |
| --- | --- |
| §7 Identificadores y comentarios en inglés | Scripts, clases, métodos, señales, nodos y grupos en español. Los grupos `aliados`, `enemigos` y `hechizos` aparecen 45 veces entre `.gd` y `.tscn` |
| §4 Funciones de 15 líneas como máximo | 13 funciones se pasan. Peores: `nivel_principal._intentar_plantar` (64), `snitch._process` (38), `menu_niveles._aplicar_estilo_pergamino_boton` (35), `menu_niveles._generar_caminante_ambiental` (34), `nivel_principal._on_timer_spawneo_timeout` (27), `caja_snitch._on_timer_generacion_snitches_timeout` (27) |
| §6 Sin números ni strings mágicos | Ej.: `64.0` (tolerancia de fila en `harry`), `Color(1.0, 0.3, 0.3)` y `0.15` (flash de daño), `1200.0` (límite de caída de `snitch`), `32.0` (radio de clic), `randi() % 2` (elección de enemigo) |
| §3 Indentación de 2 espacios, sin tabulaciones | Todos los `.gd` usan tabulaciones; `.editorconfig` no fija indentación. **Fuera de alcance de este refactor**: se difiere a la etapa final del proyecto |
| §5 Patrones de diseño cuando se justifique | `draco.gd` copia la lógica de `alumno_slytherin.gd` en vez de heredar. El flash de daño está duplicado en seis entidades: `harry`, `caja_snitch`, `recordadora`, `protego` (0.1 s, enfriamiento 0.5 s), `alumno_slytherin` y `draco` (fundido de 0.15 s). `recibir_danio` recibe `float` en aliados e `int` en enemigos |

## Clarifications

### Session 2026-09-30

- Q: ¿Qué regla manda ante el conflicto de idioma entre el `AGENTS.md` raíz y el del proyecto? → A: Manda el `AGENTS.md` raíz (cátedra). Se actualizan el `AGENTS.md` del proyecto y la constitución para que lo reflejen.
- Q: ¿Qué se hace con el código legacy (`Mago`, `Mortifago`, `tile_map_layer`)? → A: Se borra, no se refactoriza.
- Q: ¿Se traduce también el texto visible del juego? → A: No. Botones, HUD y mensajes siguen en español; solo cambian identificadores y comentarios.
- Q: ¿El refactor convive con otro desarrollo en paralelo? → A: No. El Nivel 3 está terminado y el resto del equipo no inicia tareas de código hasta que el refactor se mergee. Se hace en una sola pasada.

### Session 2026-10-01

- Q: ¿Se reindenta a 2 espacios en este refactor, dado que Godot reindenta al guardar según la configuración de cada editor y no se sabe cuál usa el equipo? → A: No. La indentación (§3) queda fuera de este refactor y se difiere a la etapa final del proyecto. Los `.gd` conservan las tabulaciones actuales.

## User Scenarios & Testing *(mandatory)*

Las historias están en orden de ejecución. Cada una deja el juego jugable y se puede commitear por separado.

### User Story 1 — Limpieza y reglas actualizadas (Priority: P1)

Como equipo, queremos borrar el código muerto y que la documentación del proyecto exija las reglas de la cátedra, para que nadie (persona o agente) vuelva a escribir código que no cumpla.

**Independent Test**: Abrir el proyecto en Godot sin errores de dependencias y jugar los Niveles 1, 2 y 3. Leer el `AGENTS.md` del proyecto y la constitución: exigen inglés y remiten al `AGENTS.md` raíz.

**Acceptance Scenarios**:

1. **Given** se borraron `Mago.*`, `Mortifago.*`, `tile_map_layer.gd`, `Imagenes/Mortifago.png` (+ `.import`) e `Imagenes/Pasto.png1391487371.tmp`, **When** se abre el proyecto, **Then** no hay errores de recursos faltantes.
2. **Given** se actualizaron los documentos, **When** se lee el diccionario temático, **Then** mapea cada nombre del juego a su identificador en inglés (ej.: Snitches → `snitch`, Alumno Slytherin → `SlytherinStudent`).
3. **Given** existe `specs/004-refactor-catedra/rename-map.md`, **When** se busca cualquier identificador en español del código, **Then** figura en el mapa con su nombre nuevo.

---

### User Story 2 — Identificadores en inglés (Priority: P1)

Como equipo, queremos que todo identificador y comentario esté en inglés según el mapa de renombres.

**Independent Test**: Los tres niveles se completan con victoria y derrota igual que antes; ninguna búsqueda de identificadores del mapa con nombre nuevo (columna "actual") encuentra resultados en `.gd` o `.tscn`.

**Acceptance Scenarios**:

1. **Given** se renombraron los grupos a `allies`, `enemies` y `spells`, **When** un hechizo impacta un enemigo o un enemigo ataca un aliado, **Then** el daño se aplica igual que antes.
2. **Given** se renombraron scripts y escenas, **When** se abre cada `.tscn`, **Then** sus `ext_resource` apuntan a rutas válidas y los `uid://` se conservaron.
3. **Given** se renombraron métodos conectados desde `.tscn`, **When** ocurre cada señal (timers, clics, colisiones), **Then** su callback se ejecuta.
4. **Given** el HUD, **When** se juega, **Then** los textos visibles siguen en español.

---

### User Story 3 — Funciones cortas, constantes y estructura (Priority: P1)

Como equipo, queremos funciones de 15 líneas como máximo, sin números mágicos y sin lógica duplicada, para cumplir §4, §5 y §6 y dejar una base extensible para nuevas entidades.

**Independent Test**: El script de chequeo reporta 0 funciones de más de 15 líneas; los tres niveles se juegan igual.

**Acceptance Scenarios**:

1. **Given** se partieron las funciones largas, **When** se mide su cuerpo, **Then** ninguna supera 15 líneas.
2. **Given** se extrajeron constantes, **When** se revisa cada `.gd`, **Then** todo literal fuera de la lista permitida de FR-009 está en una `const` o un `@export` con nombre descriptivo.
3. **Given** existe la clase base de enemigos, **When** se revisa `draco`, **Then** hereda de ella y solo redefine valores (vida, texturas), sin duplicar movimiento, ataque ni daño.
4. **Given** existe el componente de feedback de daño, **When** cualquier aliado o enemigo recibe daño, **Then** parpadea en rojo como antes, con el código de flash en un solo lugar.
5. **Given** los costos están centralizados, **When** se cambia el `cost` del `AllyCard` de un aliado, **Then** el HUD y la validación de plantado usan el valor nuevo sin otro cambio.
6. **Given** el menú usa un `Array[PackedScene]` exportado, **When** se agrega un nivel, **Then** solo se agrega una escena al array.
7. **Given** existe el autoload `GameManager` con `max_unlocked_level` menor que el `next_level_to_unlock` del nivel, **When** se gana ese nivel, **Then** `max_unlocked_level` pasa a valer `next_level_to_unlock` y el botón correspondiente del menú queda habilitado. Con el valor inicial (10), ganar no baja el desbloqueo.

---

### Edge Cases

- **Godot reindenta al guardar** (`convert_indent_on_save`) según la configuración de cada editor, que hoy no se conoce: el refactor conserva las tabulaciones existentes y no cambia `.editorconfig`. Si un commit trae un archivo entero reindentado por el editor, se revierte ese cambio de formato antes de mergear para no mezclarlo con la lógica.
- **Archivo con tabs y espacios mezclados**: GDScript no lo parsea. El código nuevo o movido usa tabulaciones, igual que el archivo donde se escribe.
- **Renombrar un script cambia su ruta `res://`**: se actualiza cada `ext_resource`; el `.uid` se mueve junto al script para conservar el `uid://`.
- **Renombrar un método conectado por señal en un `.tscn`**: la línea `[connection ... method="..."]` se actualiza en el mismo commit, o la señal deja de dispararse sin error visible.
- **Tipo de daño inconsistente**: se unifica `take_damage(amount: float)` en aliados y enemigos.
- **Botón de nivel sin escena** (niveles 4–10 hoy): el botón sigue habilitado según el desbloqueo y al pulsarlo no carga nada, como antes del refactor. Mostrarlo deshabilitado es un cambio de comportamiento y queda para otra feature.
- **Cambios locales de Godot sin commitear** (ej.: `.uid` generados, `.tscn` reguardados): se revisan y commitean o descartan antes de empezar, para no mezclarlos con el refactor.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El refactor NO DEBE cambiar el comportamiento observable de ningún nivel (vida, daño, velocidades, costos, tiempos, visuales, textos).
- **FR-002**: DEBEN borrarse los archivos legacy listados en la User Story 1 y ningún otro.
- **FR-003**: El `AGENTS.md` del proyecto y `.specify/memory/constitution.md` DEBEN exigir identificadores en inglés y remitir al `AGENTS.md` raíz como regla superior.
- **FR-004**: DEBE existir `specs/004-refactor-catedra/rename-map.md` con archivos, clases, métodos, señales, variables exportadas, nodos referenciados por ruta y grupos de todas las entidades.
- **FR-005**: Este refactor NO DEBE cambiar la indentación de los `.gd` ni `.editorconfig`; se conservan las tabulaciones. El cumplimiento de §3 se difiere a la etapa final del proyecto.
- **FR-006**: Todos los identificadores y comentarios de `.gd`, `.tscn` y `.gdshader` DEBEN estar en inglés según el mapa. Los textos visibles para el jugador quedan en español.
- **FR-007**: Los grupos DEBEN llamarse `allies`, `enemies` y `spells`.
- **FR-008**: Ninguna función de ningún `.gd` del juego DEBE superar 15 líneas de cuerpo.
- **FR-009**: Ningún `.gd` del juego DEBE contener números o strings mágicos. Literales permitidos fuera de una `const` o un `@export`: `0`, `1`, `0.0`, `1.0`, `-1.0` como signo, `""`, `Vector2.ZERO`, `Vector2.ONE`, `Color.WHITE` y rutas de nodos (`$Sprite2D`). Los textos visibles para el jugador van en constantes con sufijo `_TEXT`. Cualquier otro literal es mágico. Se verifica a mano (no hay chequeo automático).
- **FR-010**: DEBE existir una clase base de enemigos de la que hereden el Alumno Slytherin y Draco.
- **FR-011**: El feedback visual de daño DEBE implementarse una sola vez en un componente reutilizable usado por todas las entidades que lo muestran.
- **FR-012**: El método de daño compartido DEBE tener la misma firma (`float`) en aliados y enemigos.
- **FR-013**: Los costos de los aliados DEBEN leerse de una única fuente (el `cost` exportado de cada escena o un `Resource` de configuración).
- **FR-014**: El menú de niveles DEBE obtener las escenas de un `Array[PackedScene]` exportado.
- **FR-015**: DEBE existir el autoload `GameManager` para la progresión de niveles. En `project.godot` solo cambian `[autoload]` (registro de `GameManager`) y `[global_group]` (grupos renombrados por FR-007); ambos cambios requieren confirmación del equipo antes de implementarse.
- **FR-016**: DEBE existir un script de chequeo sin dependencias externas que reporte funciones de más de 15 líneas e identificadores del mapa todavía presentes, distinguiendo los que se renombran de los que se eliminan.

### Key Entities

- **Mapa de renombres**: Tabla `nombre actual → nombre nuevo` por categoría. Fuente única para el renombrado y para el script de chequeo.
- **Componente de feedback de daño**: Aplica el parpadeo rojo con duración y enfriamiento configurables. Base también para la futura animación de hechizos.
- **Clase base de enemigos**: Movimiento, ataque a aliados, daño, cambio a textura de lastimado e invasión del jardín, con valores exportados que cada enemigo ajusta.
- **`GameManager`**: Autoload con el nivel máximo desbloqueado, que hoy el código busca con `get_node_or_null("/root/GameManager")` sin que exista.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 0 funciones de más de 15 líneas (hoy: 13).
- **SC-002**: 0 archivos del refactor con cambios solo de indentación: todo archivo que aparece en `git diff develop` muestra al menos un cambio en `git diff -w develop`.
- **SC-003**: 0 apariciones de los grupos `aliados`, `enemigos` o `hechizos` (hoy: 45).
- **SC-004**: 0 archivos legacy en el repositorio.
- **SC-005**: Los Niveles 1, 2 y 3 se completan (victoria y derrota) con el mismo comportamiento que antes del refactor.
- **SC-006**: Agregar un nivel nuevo requiere solo crear su escena y sumarla al array del menú.

## Assumptions

- No hay tests automatizados; la verificación de comportamiento es jugar los tres niveles en el editor después de cada historia, como en las features 001–003.
- Nadie del equipo modifica `.gd` ni `.tscn` mientras el refactor está abierto.
- La reindentación a 2 espacios (§3) se hace en la etapa final del proyecto, una vez acordada la configuración del editor de Godot de todo el equipo.
- La animación de hechizos de Harry (y su extensión a otros aliados) es una feature posterior a este refactor y tiene su propio spec.
