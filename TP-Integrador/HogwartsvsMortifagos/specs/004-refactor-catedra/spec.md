# Especificación: Refactor de cumplimiento de las reglas de la cátedra

**Feature Branch**: `004-refactor-catedra`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Ajustar todo el código del juego a las reglas del `AGENTS.md` de la raíz (dadas por la cátedra, que corrige el trabajo) antes de sumar más entidades o features. El Nivel 3 está en desarrollo en paralelo, por lo que el refactor se divide en una fase que puede avanzar ya y otra que espera al merge del Nivel 3."

## Contexto

El `AGENTS.md` de la raíz del repositorio es la regla de la cátedra y **prevalece** sobre el `AGENTS.md` del proyecto y sobre `.specify/memory/constitution.md`, que hoy exigen identificadores temáticos en español. Medición al 2026-09-30 sobre los 13 scripts `.gd` del juego:

| Regla (`AGENTS.md` raíz) | Estado actual |
| --- | --- |
| §7 Identificadores y comentarios en inglés | Scripts, clases, métodos, señales, nodos y grupos en español. Los grupos `aliados`, `enemigos` y `hechizos` aparecen en 22 lugares |
| §4 Funciones de 15 líneas como máximo | 12 de 93 funciones se pasan. Peores: `_intentar_plantar` (59), `snitch._process` (38), `_aplicar_estilo_pergamino_boton` (35), `_generar_caminante_ambiental` (34), `caja_snitch._on_timer_generacion_snitches_timeout` (27) |
| §6 Sin números ni strings mágicos | Ej.: `64.0` (tolerancia de fila en `harry`), `Color(1.0, 0.3, 0.3)` y `0.15` (flash de daño en 3 scripts), `1200.0` (límite de caída de `snitch`), `32.0` (radio de clic) |
| §3 Indentación de 2 espacios, sin tabulaciones | Los 13 `.gd` usan tabulaciones; `.editorconfig` no fija indentación |
| §5 Patrones de diseño cuando se justifique | `recibir_danio` y el flash de daño duplicados en `harry`, `alumno_slytherin` y (en el Nivel 3) `draco`, que copia a `AlumnoSlytherin` en vez de heredar |

## Clarifications

### Session 2026-09-30

- Q: ¿Qué regla manda ante el conflicto de idioma entre el `AGENTS.md` raíz y el del proyecto? → A: Manda el `AGENTS.md` raíz (cátedra). Se actualizan el `AGENTS.md` del proyecto y la constitución para que lo reflejen.
- Q: ¿Qué se hace con el código legacy (`Mago`, `Mortifago`, `tile_map_layer`)? → A: Se borra, no se refactoriza.
- Q: ¿Cómo convive el refactor con el Nivel 3 en curso? → A: Se divide en Fase A (archivos que el Nivel 3 no toca, sin renombrar interfaces compartidas) y Fase B (todo lo demás, después del merge del Nivel 3).
- Q: ¿Se traduce también el texto visible del juego? → A: No. Botones, HUD y mensajes siguen en español; solo cambian identificadores y comentarios.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Fase A: limpieza sin conflictos con el Nivel 3 (Priority: P1)

Como equipo, queremos avanzar todo el refactor que no se superpone con el trabajo del Nivel 3, para que la Fase B sea corta y mecánica.

**Why this priority**: Se puede hacer hoy sin bloquear a nadie y reduce el tamaño de la Fase B.

**Independent Test**: Jugar los Niveles 1 y 2 de principio a fin: el comportamiento es idéntico al previo. `git diff` contra la rama del Nivel 3 no muestra conflictos en ningún archivo.

**Alcance cerrado de la Fase A** (solo estos archivos):

- Borrar: `Mago.gd`, `Mago.gd.uid`, `Mago.tscn`, `Mortifago.gd`, `Mortifago.gd.uid`, `Mortifago.tscn`, `tile_map_layer.gd`, `Imagenes/Mortifago.png` (+ `.import`), `Imagenes/Pasto.png1391487371.tmp`.
- Refactor interno (funciones cortas + constantes, **manteniendo** nombres públicos, grupos, señales e indentación actuales): `snitch.gd`, `caja_snitch.gd`, `harry.gd`, `Proyectil.gd`, `recordadora.gd`, `dementor.gd`, `huella.gd`.
- Nuevo componente de feedback de daño (archivo nuevo), conectado solo a entidades de la lista anterior.
- Redactar el mapa de renombres y los cambios de `AGENTS.md` del proyecto y de la constitución **en la rama del refactor, sin mergearlos** hasta la Fase B.

**Acceptance Scenarios**:

1. **Given** se borró el código legacy, **When** se abre el proyecto en Godot, **Then** no hay errores de dependencias faltantes y los Niveles 1 y 2 cargan.
2. **Given** se refactorizaron los 7 scripts de la Fase A, **When** se mide la longitud de sus funciones, **Then** ninguna supera 15 líneas de cuerpo.
3. **Given** se refactorizaron los 7 scripts de la Fase A, **When** se revisa su lógica, **Then** no queda ningún literal numérico o string con significado de dominio fuera de una `const` o un `@export` con nombre descriptivo.
4. **Given** el componente de feedback de daño existe, **When** un Alumno Slytherin ataca a Harry, **Then** Harry parpadea en rojo como antes, sin código de flash duplicado en `harry.gd`.
5. **Given** la Fase A está terminada, **When** se compara con la rama del Nivel 3, **Then** ningún archivo modificado por la Fase A fue modificado por el Nivel 3.

---

### User Story 2 — Fase B: cumplimiento total después del Nivel 3 (Priority: P2)

Como equipo, queremos que todo el código del juego cumpla las reglas de la cátedra, incluidas las entidades del Nivel 3, antes de sumar nuevas entidades o features.

**Why this priority**: Es el objetivo final, pero renombra interfaces compartidas y cambia la indentación de todos los archivos, así que solo puede hacerse con el Nivel 3 mergeado y el equipo sincronizado.

**Independent Test**: Jugar los Niveles 1, 2 y 3 de principio a fin con comportamiento idéntico al previo. Un script de verificación no encuentra tabulaciones, funciones de más de 15 líneas ni identificadores en español en los `.gd`.

**Precondiciones**: Nivel 3 mergeado en la rama de desarrollo; Fase A mergeada; todo el equipo sin cambios locales pendientes en `.gd`/`.tscn` y con el editor de Godot configurado en espacios de 2.

**Acceptance Scenarios**:

1. **Given** se aplicó el mapa de renombres, **When** se buscan identificadores en español en `.gd` y `.tscn`, **Then** no queda ninguno (salvo strings visibles para el jugador).
2. **Given** se renombraron los grupos a `allies`, `enemies` y `spells`, **When** un hechizo impacta un enemigo o un enemigo ataca un aliado, **Then** el daño se aplica igual que antes.
3. **Given** se reindentó el proyecto, **When** se buscan tabulaciones al inicio de línea en los `.gd`, **Then** no hay ninguna, y `.editorconfig` fija `indent_style = space` e `indent_size = 2`.
4. **Given** existe la clase base de enemigos, **When** se revisa `draco`, **Then** hereda de ella y solo redefine valores (vida, texturas), sin duplicar lógica de movimiento, ataque ni daño.
5. **Given** se partió `nivel_principal.gd`, **When** se mide la longitud de sus funciones, **Then** ninguna supera 15 líneas.
6. **Given** los costos están centralizados, **When** se cambia el `coste` exportado de una entidad, **Then** el HUD y la validación de plantado usan el valor nuevo sin otro cambio.
7. **Given** el menú usa un `Array[PackedScene]`, **When** se agrega un nivel, **Then** solo se agrega una escena al array, sin tocar ramas `if/elif`.
8. **Given** se mergeó la Fase B, **When** se leen el `AGENTS.md` del proyecto y la constitución, **Then** exigen identificadores en inglés y el diccionario temático mapea nombre en el juego → identificador.

---

### Edge Cases

- **Un compañero tiene cambios locales al empezar la Fase B**: la Fase B no empieza hasta que todos hayan pusheado; los renombres sobre trabajo sin pushear generan conflictos en cada línea.
- **Un compañero tiene el editor de Godot en tabulaciones**: con `convert_indent_on_save`, al guardar revierte la indentación del archivo. Todos cambian la configuración antes de la Fase B y se verifica con el script de chequeo en cada PR.
- **Archivo con tabs y espacios mezclados**: GDScript no lo parsea. La reindentación se hace de una vez por archivo completo y con herramienta, nunca a mano.
- **Renombrar un script cambia su ruta `res://`**: hay que actualizar cada `ext_resource` en `.tscn`; los `uid://` se preservan moviendo también el `.uid`.
- **Renombrar un método conectado por señal en un `.tscn`**: la conexión `[connection ... method="..."]` se actualiza en el mismo commit, o la señal deja de dispararse en silencio.
- **Tipo de daño inconsistente**: `AlumnoSlytherin.recibir_danio` recibe `int` y el contrato del Nivel 3 usa `float`. La Fase B unifica a `float` en la interfaz compartida.

## Requirements *(mandatory)*

### Functional Requirements

**Fase A**

- **FR-001**: El refactor NO DEBE cambiar el comportamiento observable de ningún nivel (vida, daño, velocidades, costos, tiempos, visuales).
- **FR-002**: La Fase A DEBE borrar los archivos legacy listados en la User Story 1 y ningún otro.
- **FR-003**: La Fase A DEBE modificar únicamente los 7 scripts listados (y sus `.tscn` si cambian conexiones internas) más archivos nuevos.
- **FR-004**: La Fase A NO DEBE renombrar métodos públicos, señales, grupos, clases ni archivos usados por otras escenas.
- **FR-005**: Toda función de los 7 scripts de la Fase A DEBE tener 15 líneas de cuerpo como máximo.
- **FR-006**: Los literales con significado de dominio en los 7 scripts DEBEN reemplazarse por `const` (valores fijos) o `@export` (valores de balance) con nombre descriptivo.
- **FR-007**: El feedback visual de daño DEBE implementarse una sola vez en un componente reutilizable (escena hija o script) y usarse desde `harry`.
- **FR-008**: El mapa de renombres DEBE cubrir archivos, clases, métodos, señales, variables exportadas, nodos referenciados por ruta y grupos de todas las entidades, incluidas `draco` y `protego`.

**Fase B**

- **FR-009**: Todos los identificadores y comentarios de `.gd` y `.tscn` DEBEN estar en inglés, según el mapa de renombres. Los textos visibles para el jugador quedan en español.
- **FR-010**: Los grupos DEBEN renombrarse a `allies`, `enemies` y `spells`.
- **FR-011**: Todos los `.gd` DEBEN indentarse con 2 espacios, sin tabulaciones, y `.editorconfig` DEBE fijarlo.
- **FR-012**: Ninguna función de ningún `.gd` del juego DEBE superar 15 líneas de cuerpo.
- **FR-013**: Ningún `.gd` del juego DEBE contener números o strings mágicos.
- **FR-014**: DEBE existir una clase base de enemigos de la que hereden `alumno_slytherin` y `draco`.
- **FR-015**: Los costos de los aliados DEBEN leerse de una única fuente (el `coste` exportado de cada escena o un `Resource` de configuración).
- **FR-016**: El menú de niveles DEBE obtener las escenas de un `Array[PackedScene]` exportado.
- **FR-017**: DEBE existir el autoload `GameManager` para la progresión de niveles. Requiere modificar `project.godot`, lo que se confirma con el equipo antes de hacerlo.
- **FR-018**: El `AGENTS.md` del proyecto y `.specify/memory/constitution.md` DEBEN exigir identificadores en inglés y remitir al `AGENTS.md` raíz como regla superior.

### Key Entities

- **Mapa de renombres**: Tabla `nombre actual → nombre nuevo` por categoría (archivo, clase, método, señal, variable, nodo, grupo). Fuente única para la Fase B; vive en `specs/004-refactor-catedra/rename-map.md`.
- **Componente de feedback de daño**: Unidad reutilizable que aplica el parpadeo rojo con duración y enfriamiento configurables. Base también para la futura animación de hechizos.
- **Clase base de enemigos**: Movimiento, ataque a aliados, daño, cambio a textura de lastimado e invasión del jardín, con valores exportados para que cada enemigo los ajuste.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Tras la Fase A, 0 de las funciones de los 7 scripts superan 15 líneas (hoy: 2 de ellas).
- **SC-002**: Tras la Fase B, 0 de las funciones del juego superan 15 líneas (hoy: 12 de 93).
- **SC-003**: Tras la Fase B, 0 líneas de `.gd` empiezan con tabulación.
- **SC-004**: Tras la Fase B, 0 referencias a los grupos `aliados`, `enemigos` o `hechizos`.
- **SC-005**: Los Niveles 1, 2 y 3 se completan (victoria y derrota) con el mismo comportamiento que antes de cada fase.
- **SC-006**: La Fase A se mergea sin conflictos con la rama del Nivel 3.

## Assumptions

- No hay tests automatizados; la verificación de comportamiento es jugar los niveles en el editor, como en las features 001–003.
- Las métricas (longitud de funciones, tabs, nombres en español) se verifican con un script de chequeo en `scripts/` o equivalente, sin dependencias externas.
- El Nivel 3 sigue en curso: el commit `13b3f04` tiene `draco.gd` empezando con `//` (no es comentario válido en GDScript) y faltan `draco.tscn` y `protego.gd` aunque sus tareas están marcadas. Se asume que se completan antes de la Fase B.
- La animación de hechizos de Harry (y su extensión a otros aliados) es una feature posterior a la Fase B y tiene su propio spec.
