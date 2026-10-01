# Implementation Tasks: Nivel 3 - Expansión y Tanques

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Duplicar la escena base del nivel anterior para crear `nivel_3.tscn` y actualizar las referencias internas.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel. En este caso, la base del motor de Godot y la estructura del proyecto ya proveen la fundación.

---

## Phase 3: User Story 1 - Expansión Total del Campo (Priority: P1)

**Goal**: Habilitar el acceso a las 5 líneas del mapa para plantar aliados y recibir enemigos.

**Independent Test**: Iniciar `nivel_3.tscn` y comprobar que es posible plantar aliados y que los enemigos aparecen en cualquiera de las 5 filas del tablero.

### Implementation for User Story 1

- [ ] T002 [US1] Añadir 2 `Marker2D` adicionales en el nodo Spawners de `nivel_3.tscn` (total 5) asignándoles las coordenadas Y de las nuevas filas superior e inferior.
- [ ] T003 [US1] Ajustar la lógica del generador de grilla y la interfaz de plantado en `nivel_3.tscn` para validar las 5 filas horizontales completas.

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Enemigo Blindado "Draco" (Priority: P2)

**Goal**: Introducir a "Draco", un enemigo tipo tanque que resiste el doble de impactos.

**Independent Test**: Esperar a que se instancie Draco en el nivel, observar que soporta el doble de daño que un enemigo normal, y verificar que ataca aliados al chocar.

### Implementation for User Story 2

- [ ] T004 [P] [US2] Crear la escena `draco.tscn` (Area2D) configurando los nodos visuales y añadiéndolo al grupo `"enemigos"` según el contrato.
- [ ] T005 [P] [US2] Crear el script `draco.gd` con la variable `@export var vida: float` balanceada al doble del Slytherin, e implementar la función `recibir_danio(cantidad: float)`.
- [ ] T006 [US2] Modificar la lógica del generador de oleadas en `nivel_3.tscn` para instanciar aletoriamente la escena de Draco o AlumnoSlytherin.

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Desbloqueo de Barrera Defensiva "Protego" (Priority: P2)

**Goal**: Implementar a "Protego", una barrera que bloquea enemigos a cambio de 50 snitches.

**Independent Test**: Plantar un Protego (costo 50), verificar que los enemigos se detienen a atacarlo y que resiste una cantidad masiva de daño sin atacar él mismo.

### Implementation for User Story 3

- [ ] T007 [P] [US3] Crear la escena `protego.tscn` (Area2D) configurando los nodos visuales y añadiéndolo al grupo `"aliados"` según el contrato.
- [ ] T008 [P] [US3] Crear el script `protego.gd` con `@export var coste: int = 50`, `tiempo_recarga` (10-15s), `salud` masiva, e implementar `recibir_danio(cantidad: float)` emitiendo `derrotado`.
- [ ] T009 [US3] Configurar el HUD en `nivel_3.tscn` para habilitar el botón de la carta Protego, vinculándola a la nueva escena.

**Checkpoint**: All user stories should now be independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T010 [P] Ajustar y balancear las variables de salud final de Draco y Protego tras pruebas en el motor.
- [ ] T011 Ejecutar todos los escenarios de validación descritos en `quickstart.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1 (P1) debe ser la primera prioridad.
  - US2 y US3 pueden implementarse en paralelo o secuencialmente tras US1.
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Bloquea el plantado en todo el tablero, debe hacerse primero para testear cómodamente.
- **User Story 2 (P2)**: Independiente.
- **User Story 3 (P3)**: Independiente.

### Parallel Opportunities

- El desarrollo de las entidades base de Draco (T004, T005) y Protego (T007, T008) está marcado con `[P]` indicando que son archivos completamente distintos (`draco.tscn`/`draco.gd` y `protego.tscn`/`protego.gd`) y pueden desarrollarse en paralelo antes de ser integrados al nivel mediante T006 y T009.
