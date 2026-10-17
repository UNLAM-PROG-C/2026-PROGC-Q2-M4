---

description: "Task list for the magical wave system"
---

# Tasks: Sistema de Oleadas Mágicas

**Input**: Design documents from `/specs/006-wave-system/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [quickstart.md](./quickstart.md)

**Tests**: No se generan tareas TDD porque la especificación no solicita un framework de pruebas. Las validaciones manuales, estáticas y de ejecución están incluidas en la fase de pulido.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar los archivos y la configuración de datos sin modificar todavía la lógica de juego.

- [X] T001 [P] Crear `wave_state.gd` con los estados tipados `SPAWNING_NORMAL`, `WAVE_PREPARATION`, `WAVE_ACTIVE`, `WAITING_FOR_CLEAR`, `FINAL_WAVE_PREPARATION` y `LEVEL_COMPLETE`
- [X] T002 [P] Crear `wave_plan.gd` con la estructura tipada de una orden de oleada, incluyendo `level_generation`, `request_id`, `wave_number`, `enemy_count`, `is_final`, `spawn_delay` y `row_indices`
- [X] T003 [P] Crear `board_snapshot.gd` con una copia de datos simples para `regular_defeated`, `regular_budget`, `active_enemies`, `defense_value`, `is_special_level` y `threshold_index`
- [X] T004 [P] Crear `wave_result.gd` con el resultado de cálculo, incluyendo plan, generación, solicitud, cancelación y código de error explícito

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establecer la infraestructura compartida de estados, cuota, sincronización y ciclo de vida. Ninguna historia puede integrarse antes de completar esta fase.

- [X] T005 Definir en `wave_plan.gd` las validaciones de cantidad: oleadas intermedias entre 10 y 20 enemigos, oleada final de al menos 25 y estrictamente mayor que la intermedia
- [X] T006 [P] Implementar en `wave_director.gd` la cola de `WaveResult` protegida por `Mutex`, sin almacenar referencias a `Node`, `Resource`, `PackedScene` ni colecciones del Scene Tree
- [X] T007 [P] Implementar en `wave_director.gd` la bandera de cancelación, `level_generation`, `request_id` y la política de descarte de resultados obsoletos
- [X] T008 Implementar en `wave_director.gd` el ciclo de vida de la tarea concurrente y su unión segura antes de liberar el nivel, usando solo datos de `BoardSnapshot`
- [X] T009 [P] Agregar en `level.gd` los contadores tipados de cuota regular, enemigos activos, oleadas intermedias y generación del nivel sin eliminar todavía los contadores existentes
- [X] T010 Implementar en `level.gd` la construcción de `BoardSnapshot` desde el hilo principal, copiando valores simples y calculando el valor defensivo sin pasar aliados al director
- [X] T011 Integrar en `level.gd` el sondeo diferido de resultados de `WaveDirector`, garantizando que el hilo principal libere el `Mutex` antes de instanciar o modificar nodos
- [X] T012 Agregar en `level.gd` la limpieza del director durante `_stop_level()` y `_exit_tree()`, descartando resultados pendientes antes del cambio de escena o reinicio

**Checkpoint**: La infraestructura puede recibir snapshots, calcular resultados y cancelarse sin tocar el Scene Tree.

---

## Phase 3: User Story 1 - Administrar oleadas y bloqueo del tablero (Priority: P1) 🎯 MVP

**Goal**: Reemplazar el spawn lineal por una máquina de estados que detenga el spawn normal en los umbrales, espere a que el tablero quede vacío y active una oleada final válida.

**Independent Test**: Ejecutar un nivel estándar con una cuota conocida, alcanzar el 50%, comprobar que el spawn normal se detiene, limpiar el tablero, verificar una única oleada intermedia, agotar la cuota regular y confirmar que la victoria ocurre solo al derrotar la oleada final.

### Implementation

- [X] T013 [US1] Implementar en `wave_state.gd` las transiciones válidas entre spawn normal, preparación, actividad, espera de limpieza, preparación final y nivel completado
- [X] T014 [US1] Configurar en `level.gd` los umbrales estándar del 50% y 100%, con una única transición por umbral y sin duplicar solicitudes
- [X] T015 [US1] Adaptar `_on_enemy_spawn_timer_timeout()` en `level.gd` para bloquear el spawn regular durante `WAVE_PREPARATION`, `WAVE_ACTIVE`, `WAITING_FOR_CLEAR` y `FINAL_WAVE_PREPARATION`
- [X] T016 [US1] Adaptar `_spawn_enemy()` en `level.gd` para incrementar `active_enemies` únicamente en el hilo principal y conectar las señales tipadas `defeated` y `garden_invaded`
- [X] T017 [US1] Adaptar `_on_enemy_defeated()` en `level.gd` para decrementar `active_enemies` una sola vez por enemigo y avanzar la máquina solo cuando el tablero llegue a cero
- [X] T018 [US1] Implementar en `level.gd` la solicitud de `WavePlan` intermedio al alcanzar el 50%, deteniendo `EnemySpawnTimer` antes de pedir el cálculo
- [X] T019 [US1] Implementar en `level.gd` la aplicación principal de un `WavePlan`, instanciando enemigos únicamente desde el hilo principal, agregándolos a `Entities` y conectando sus señales
- [X] T020 [US1] Implementar en `level.gd` la transición desde `WAVE_ACTIVE` a `WAITING_FOR_CLEAR` y reanudar el spawn normal solo cuando `active_enemies == 0`
- [X] T021 [US1] Implementar en `level.gd` la preparación de la oleada final después de `regular_spawned == total_enemies` y `active_enemies == 0`
- [X] T022 [US1] Implementar en `level.gd` la condición de victoria para `LEVEL_COMPLETE`, asegurando que todos los enemigos de la oleada final fueron derrotados antes de llamar a `_win()`
- [X] T023 [US1] Actualizar `level_1.tscn`, `level_2.tscn` y `level_3.tscn` para incluir y configurar el nodo `WaveDirector` sin alterar `Entities/ProjectilePool`, filas activas, spawners ni escenas de enemigos existentes

**Checkpoint**: La historia P1 funciona de forma independiente en un nivel estándar y no genera oleadas duplicadas.

---

## Phase 4: User Story 2 - Ajustar la dificultad según las defensas (Priority: P2)

**Goal**: Calcular el tamaño de cada oleada especial según el valor de aliados y hechizos activos, respetando los límites de balance.

**Independent Test**: Ejecutar el mismo cálculo con defensas mínimas, defensas sólidas y sin defensas; verificar cantidades de 10 a 20 y que la oleada final sea mayor que la intermedia y tenga al menos 25 enemigos.

### Implementation

- [X] T024 [P] [US2] Crear en `defense_snapshot.gd` la estructura tipada de `ally_value`, `spell_value` y `total_value`, validando que el total nunca sea negativo
- [X] T025 [US2] Definir en `level.gd` las configuraciones exportadas de dificultad, incluyendo mínimos y máximos intermedios, mínimo final y bonificación aleatoria final sin números mágicos
- [X] T026 [US2] Implementar en `level.gd` la extracción del valor de aliados y hechizos activos en el hilo principal, sin enviar referencias de nodos al director
- [X] T027 [US2] Implementar en `wave_director.gd` la fórmula intermedia basada en `defense_value`, ajustada al rango inclusivo de 10 a 20 enemigos
- [X] T028 [US2] Implementar en `wave_director.gd` la fórmula final `max(25, intermediate_wave_size + random_bonus)` y validar que siempre sea estrictamente mayor que la oleada intermedia
- [X] T029 [US2] Configurar en `level_1.tscn`, `level_2.tscn` y `level_3.tscn` los valores de dificultad, usando 3 enemigos intermedios y 4 finales en el Nivel 1, sin modificar las filas jugables ni las escenas de aliados
- [X] T030 [US2] Actualizar la aplicación de `WavePlan` en `level.gd` para distribuir las apariciones únicamente entre `row_indices` válidos del nivel

**Checkpoint**: Las oleadas intermedias y finales se ajustan al valor defensivo y cumplen todos los límites de balance.

---

## Phase 5: User Story 3 - Comunicar el cálculo concurrente de forma segura (Priority: P3)

**Goal**: Completar la demostración académica de comunicación y sincronización entre hilos sin modificar nodos de Godot fuera del hilo principal.

**Independent Test**: Ejecutar al menos 20 decisiones, verificar snapshots de datos simples, resultados entregados por la cola y aplicación diferida en el hilo principal; cancelar durante una decisión y confirmar que no se instancian enemigos obsoletos.

### Implementation

- [X] T031 [US3] Implementar en `wave_director.gd` el cálculo concurrente de `WavePlan` a partir de una copia de `BoardSnapshot`, sin acceder al Scene Tree, grupos, timers, sprites, áreas ni escenas
- [X] T032 [US3] Implementar en `wave_director.gd` la entrega del `WaveResult` a la cola bajo `Mutex`, con una sección crítica limitada a datos simples
- [X] T033 [US3] Implementar en `level.gd` la aplicación mediante `call_deferred()` o el equivalente seguro del hilo principal, sin instanciar enemigos dentro del hilo director
- [X] T034 [US3] Implementar en `level.gd` la validación conjunta de `level_generation`, `request_id`, estado activo y bandera de cancelación antes de aplicar cada resultado
- [X] T035 [US3] Implementar en `wave_director.gd` la cancelación cooperativa y la salida limpia de la tarea cuando el nivel gana, pierde, reinicia o cambia de escena
- [X] T036 [US3] Actualizar `level.gd` para esperar la terminación del hilo en una fase de limpieza segura, sin llamar a `wait_to_finish()` desde `_process()` ni bloquear el juego durante una decisión normal
- [ ] T037 [US3] Agregar registro temporal y tipado explícito de `request_id`, `level_generation`, estado y resultado en `wave_director.gd` para demostrar la comunicación durante la validación
- [X] T038 [US3] Verificar en `level_1.tscn`, `level_2.tscn` y `level_3.tscn` que el director se crea una vez por escena y no queda como Autoload global

**Checkpoint**: La comunicación entre hilos funciona, se sincroniza con `Mutex` y ninguna operación del Scene Tree se ejecuta desde el hilo secundario.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validar la implementación completa, documentar el comportamiento y evitar regresiones del pool de proyectiles.

- [X] T039 [P] Validar `wave_state.gd`, `wave_plan.gd`, `board_snapshot.gd`, `wave_result.gd`, `defense_snapshot.gd`, `wave_director.gd` y `level.gd` con Godot `--headless --check-only`
- [X] T040 [P] Ejecutar los niveles 1, 2 y 3 y comprobar que conservan las filas activas, spawners, señales de derrota, victoria/derrota y `Entities/ProjectilePool`
- [X] T041 Ejecutar el caso de nivel estándar de `quickstart.md` diez veces y registrar que las oleadas intermedia y final se activan exactamente una vez
- [X] T042 Ejecutar un nivel especial configurado para tres oleadas y verificar los umbrales 33%, 66% y 100% sin duplicaciones
- [X] T043 Ejecutar al menos 20 decisiones concurrentes y confirmar que los resultados llegan al hilo principal sin errores ni operaciones de nodos desde el director
- [X] T044 Ejecutar diez cambios, reinicios, victorias o derrotas durante una tarea concurrente y confirmar que no quedan enemigos obsoletos ni accesos a nodos liberados
- [X] T045 Actualizar `Documentacion.txt` para explicar la máquina de oleadas, el `Mutex`, la instantánea de datos y la responsabilidad exclusiva del hilo principal sobre el Scene Tree
- [X] T046 Revisar y retirar únicamente los registros temporales del director después de completar la validación, conservando errores explícitos y diagnósticos necesarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; T001–T004 pueden ejecutarse en paralelo.
- **Foundational (Phase 2)**: Depende de Setup; T006–T007 y T009–T010 pueden ejecutarse en paralelo, pero T008 y T011 requieren las estructuras creadas.
- **User Story 1 (Phase 3)**: Depende de toda la Phase 2; es el MVP y debe completarse antes de validar las fórmulas de P2.
- **User Story 2 (Phase 4)**: Depende de T018–T022 de US1 para integrar los tamaños calculados en oleadas reales; T024 puede comenzar junto con tareas finales de P1 si no modifica los mismos archivos.
- **User Story 3 (Phase 5)**: Depende de la integración funcional de US1 y de las fórmulas de US2; T031–T032 pueden desarrollarse en paralelo con T033–T034 si se coordinan las interfaces de datos.
- **Polish (Phase 6)**: Depende de las historias seleccionadas para la entrega; T039 puede ejecutarse en paralelo con T040, y T041–T044 requieren la implementación completa.

### User Story Dependencies

- **US1 (P1)**: Depende de Foundational; no depende de otra historia.
- **US2 (P2)**: Depende de US1 para aplicar oleadas dinámicas al flujo real.
- **US3 (P3)**: Depende de US1 y US2 para demostrar el cálculo concurrente sobre el sistema completo.

### Parallel Opportunities

- Setup: T001, T002, T003 y T004.
- Foundational: T006, T007, T009 y T010, respetando conflictos de archivo al integrar.
- US2: T024 puede ejecutarse en paralelo con T025; T027 y T028 pueden ejecutarse en paralelo si comparten únicamente contratos de datos.
- US3: T031 y T032 se pueden preparar en paralelo con T033 y T034 después de acordar `WaveResult`.
- Polish: T039 y T040.

## Parallel Example: User Story 1

```text
Task: T013 Implementar las transiciones en wave_state.gd
Task: T014 Configurar los umbrales estándar en level.gd
Task: T023 Configurar WaveDirector en level_1.tscn, level_2.tscn y level_3.tscn
```

Estas tareas solo deben ejecutarse en paralelo si se coordinan las interfaces del director y no se pisan cambios incompatibles en `level.gd`.

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Completar Phase 1: Setup.
2. Completar Phase 2: Foundational.
3. Completar Phase 3: User Story 1.
4. Ejecutar el caso de nivel estándar de `quickstart.md`.
5. Detenerse y validar antes de incorporar dificultad dinámica o más concurrencia.

### Incremental Delivery

1. Entregar US1 con oleadas estándar y bloqueo correcto del tablero.
2. Incorporar US2 con valores defensivos y fórmulas de balance.
3. Incorporar US3 con cancelación, `Mutex`, resultados diferidos y métricas de concurrencia.
4. Completar Phase 6 y actualizar la documentación del proyecto.
