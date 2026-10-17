# Implementation Tasks: Nivel 4 - Remoción con Hechizo Accio

Este documento define el listado de tareas atómicas y ordenadas por dependencias para implementar la funcionalidad del Nivel 4 y la herramienta de remoción Accio (Pala).

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Creación del componente desacoplado del botón de Accio para el HUD.

- [X] T001 [P] Crear el script del componente `accio_button.gd` (`class_name AccioButton`, `extends Button`) con variable `var _is_active: bool = false`, señal tipada `accio_toggled(is_active: bool)`, métodos `set_active(active: bool) -> void`, `is_active() -> bool` y callback `_on_pressed()`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Preparar la infraestructura de estado y cursor de remoción en el gestor de nivel.

**⚠️ CRITICAL**: Estas tareas deben completarse antes de avanzar con la interacción y la lógica de remoción.

- [X] T002 En `level.gd`: declarar las variables de estado `var _is_removing: bool = false`, `var _hovered_ally: Ally = null`, y referencias exportadas u obtenidas en `_ready` para `accio_button` y `accio_cursor`.
- [X] T003 En `level.gd`: implementar los métodos de control de cursor `_set_cursor_mode(is_removing: bool) -> void` (empleando `Input.set_mouse_mode`) y el manejador inicial `_on_accio_toggled(is_active: bool) -> void` respetando funciones de <= 15 líneas.

**Checkpoint**: Base de estado y cursor lista - la interacción de usuario puede implementarse a continuación.

---

## Phase 3: User Story 1 - Selección y Manejo de la Herramienta Accio (Priority: P1) 🎯 MVP

**Goal**: Permitir al jugador activar Accio desde el HUD, ver el cursor personalizado y cancelar la operación en cualquier momento con clic derecho o ESC, garantizando exclusión mutua con las cartas de aliados.

**Independent Test**: Hacer clic en el botón Accio en el HUD, comprobar que se activa y cambia el cursor; pulsar clic derecho o ESC para verificar que se cancela; comprobar que seleccionar una carta desactiva Accio y viceversa.

### Implementation for User Story 1

- [X] T004 [US1] En `level.gd`: implementar la exclusión mutua en `_on_accio_toggled` (deseleccionando `_selected_card = null` y llamando a `_refresh_card_selection()`) y en `_on_card_pressed` (invocando `_cancel_accio()` si `_is_removing` está activo).
- [X] T005 [US1] En `level.gd`: actualizar `_unhandled_input(event: InputEvent)` para detectar clic derecho (`MOUSE_BUTTON_RIGHT`) y tecla `KEY_ESCAPE`, invocando `_cancel_accio()` para restaurar el cursor habitual y desmarcar `AccioButton`.
- [X] T006 [US1] En `level.gd`: en `_process(delta: float)` actualizar la posición global del cursor personalizado `accio_cursor` con `get_global_mouse_position()` cuando `_is_removing` esté activo.

**Checkpoint**: Al completar esta fase, el modo Accio se puede encender, alternar, mover por la pantalla y cancelar de forma independiente.

---

## Phase 4: User Story 2 - Lógica de Remoción en la Cuadrícula y Feedback (Priority: P1)

**Goal**: Proveer feedback visual de hover sobre aliados apuntados y remover inmediatamente al aliado al hacer clic izquierdo, liberando la celda en `_occupied_cells` sin costo ni reembolso de snitches.

**Independent Test**: Plantar un aliado, activar Accio, posicionar el cursor sobre él para ver el modulate rojizo, hacer clic izquierdo para destruirlo, verificar que la celda queda libre y plantar un nuevo aliado en la misma posición de inmediato.

### Implementation for User Story 2

- [X] T007 [US2] En `level.gd`: implementar los métodos `_update_hovered_ally(cell: Vector2i) -> void` y `_clear_hovered_ally() -> void` para modular el aliado a `Color(1.0, 0.4, 0.4, 0.8)` durante el hover y restaurar `Color.WHITE` al salir de la celda.
- [X] T008 [US2] En `level.gd`: en `_process(delta: float)` invocar `_update_hovered_ally(_cell_under_mouse())` mientras `_is_removing` esté activo para actualizar el hover en tiempo real.
- [X] T009 [US2] En `level.gd`: implementar `_try_remove_ally(cell: Vector2i) -> void` que verifique si `_occupied_cells.has(cell)`, borre la entrada (`_occupied_cells.erase(cell)`), destruya al aliado (`ally.queue_free()`), limpie el hover y desactive Accio volviendo a estado normal.
- [X] T010 [US2] En `level.gd`: en `_unhandled_input(event: InputEvent)` capturar el clic izquierdo (`MOUSE_BUTTON_LEFT`) durante `_is_removing` invocando `_try_remove_ally(_cell_under_mouse())`, ignorando clics sobre celdas vacías o enemigos.

**Checkpoint**: Las Historias de Usuario 1 y 2 permiten el flujo completo de selección, hover y remoción de aliados en la cuadrícula.

---

## Phase 5: User Story 3 - Integración del Escenario y Desafío del Nivel 4 (Priority: P2)

**Goal**: Ensamblar y configurar la escena `level_4.tscn` con 5 líneas, mazo completo de 4 aliados, botón de Accio en el HUD, oleadas de Alumnos Slytherin y Dracos, y desbloqueo del nivel 5.

**Independent Test**: Iniciar `level_4.tscn`, comprobar que las 5 filas están habilitadas para plantado y spawners, que el HUD tiene las 4 cartas más el botón de Accio, y jugar una partida completa.

### Implementation for User Story 3

- [X] T011 [US3] Crear la escena `level_4.tscn` en la raíz del proyecto (duplicando `level_3.tscn`) configurando `active_rows = [2, 3, 4, 5, 6]`, `enemy_scenes = [slytherin_student, draco]`, `next_level_to_unlock = 5` y dementores en las 5 filas.
- [X] T012 [US3] En `level_4.tscn`: agregar el nodo `AccioButton` (asignando el script `accio_button.gd`) dentro del contenedor HUD separado de las cartas de aliados, y el nodo `AccioCursor` como indicador visual flotante.
- [X] T013 [US3] En `level.gd`: en `_ready()` enlazar dinámicamente la señal `accio_toggled` de `AccioButton` con `_on_accio_toggled` si el botón está presente en el HUD.

**Checkpoint**: Nivel 4 completamente integrado, jugable y conectado a la progresión del juego.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verificación de calidad de código de cátedra, límites de funciones y validación integral.

- [X] T014 En `accio_button.gd` y `level.gd`: verificar que ninguna función exceda las 15 líneas y que todas las variables, parámetros y retornos tengan tipado estático estricto según `AGENTS.md`.
- [X] T015 Ejecutar la validación completa de los 5 escenarios detallados en `specs/007-nivel-4-accio/quickstart.md` confirmando el comportamiento correcto en el motor.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Puede iniciar de inmediato (`accio_button.gd`).
- **Foundational (Phase 2)**: Depende de Phase 1 (referencias en `level.gd`).
- **User Story 1 (Phase 3)**: Depende de Phase 2 (infraestructura de estado de Accio).
- **User Story 2 (Phase 4)**: Depende de Phase 3 (requiere modo Accio funcional para hover y clic).
- **User Story 3 (Phase 5)**: Depende de Phase 4 (ensamblado de escena `level_4.tscn` con todos los componentes listos).
- **Polish (Phase 6)**: Depende de la finalización de todas las historias de usuario.

---

## Parallel Opportunities

- **T001 [P]** puede desarrollarse de forma independiente antes de modificar `level.gd`.
- Las tareas de documentación y preparación de escena pueden coexistir una vez definidos los scripts.

---

## Implementation Strategy

### MVP First (User Story 1 & 2)

1. Crear `accio_button.gd` (T001).
2. Extender `level.gd` con la gestión de estado de Accio y cursor (T002, T003).
3. Implementar exclusión mutua y cancelación con clic derecho/ESC (T004, T005, T006).
4. Implementar hover y remoción sobre `_occupied_cells` (T007, T008, T009, T010).
5. **Validar MVP**: Probar la remoción en una escena de prueba o en `level_3.tscn` temporalmente.
6. Ensamblar la escena definitiva `level_4.tscn` (T011, T012, T013).
7. Verificar límites de 15 líneas y ejecutar `quickstart.md` (T014, T015).
