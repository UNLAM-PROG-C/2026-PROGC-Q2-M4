---
description: "Task list for the Projectile Object Pool feature"
---

# Tasks: Projectile Object Pool

**Input**: Design documents from `/specs/005-projectile-pool/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [quickstart.md](./quickstart.md)

**Organization**: Las tareas están agrupadas por historia de usuario para permitir entregas incrementales y validación independiente.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirmar el estado actual del proyecto y preparar los puntos de integración sin modificar comportamiento ajeno al pool.

- [X] T001 Revisar `harry.gd`, `harry.tscn`, `projectile.gd`, `projectile.tscn`, `level.gd` y `level_1.tscn` para documentar las referencias actuales de creación, padre y señales del proyectil
- [X] T002 [P] Verificar en `projectile.tscn` que el proyectil conserve el grupo `spells`, `collision_layer = 4`, `collision_mask = 2`, `Area2D`, `CollisionShape2D`, `Sprite2D` y `VisibleOnScreenNotifier2D`
- [X] T003 [P] Revisar en `level_select_menu.gd` el patrón existente de reutilización de `Footprint` y registrar las operaciones equivalentes necesarias para el pool de proyectiles

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Crear el ciclo de vida común que necesitan todas las historias de usuario.

**⚠️ CRITICAL**: Las historias de usuario no deben comenzar hasta completar esta fase.

- [X] T004 Crear el administrador `projectile_pool.gd` como nodo del nivel, con colecciones tipadas separadas para proyectiles disponibles y activos, capacidad inicial 50 y crecimiento de 10
- [X] T005 [P] Agregar el nodo propietario del pool a `level_1.tscn`, `level_2.tscn` y `level_3.tscn` bajo el contenedor de entidades definido por cada escena
- [X] T006 [P] Definir en `projectile.gd` las operaciones tipadas de activación y desactivación, incluyendo el estado activo/inactivo y la señal tipada de devolución al pool
- [X] T007 Integrar la conexión única entre cada `Projectile` y su `ProjectilePool`, evitando conectar señales nuevamente durante una reutilización
- [X] T008 Implementar en `projectile.gd` el reinicio de posición, velocidad, `_has_hit`, `_animation_elapsed`, frame del sprite, visibilidad y monitoreo de colisiones al activar o desactivar
- [X] T009 Implementar en `level.gd` la limpieza de proyectiles activos durante reinicios y cambios de nivel, antes de liberar el árbol de la escena

**Checkpoint**: El pool existe como infraestructura del nivel, sus proyectiles pueden cambiar de estado de forma idempotente y el cambio de escena no conserva referencias activas.

---

## Phase 3: User Story 1 - Reutilizar proyectiles durante una oleada (Priority: P1) 🎯 MVP

**Goal**: Reemplazar la creación y destrucción por disparo por activación y devolución de proyectiles reutilizables, manteniendo daño, animación y colisiones.

**Independent Test**: Ejecutar un nivel, disparar contra enemigos y fuera del tablero, y comprobar que cada proyectil aplica daño una vez, vuelve al pool y puede reutilizarse sin estado residual.

### Implementation for User Story 1

- [X] T010 [US1] Implementar el precalentamiento de 50 instancias de `projectile_scene` y su incorporación inicial a `available_projectiles` en `projectile_pool.gd`
- [X] T011 [US1] Implementar en `projectile_pool.gd` la solicitud de un proyectil disponible, su activación en la posición recibida y su movimiento al contenedor estable de entidades
- [X] T012 [US1] Cambiar `harry.gd` para solicitar proyectiles a `ProjectilePool` en lugar de ejecutar `projectile_scene.instantiate()` en cada disparo
- [X] T013 [US1] Reemplazar en `projectile.gd` el `queue_free()` del impacto por la aplicación única del daño, la creación de la explosión visual y la devolución idempotente al pool
- [X] T014 [US1] Reemplazar en `projectile.gd` el `queue_free()` de `screen_exited` por la desactivación de visibilidad, movimiento y colisiones y la devolución al pool
- [X] T015 [US1] Validar el ciclo de reutilización en `level_1.tscn`, `level_2.tscn` y `level_3.tscn`, verificando que los proyectiles se dibujen dentro de `Entities` y conserven su interacción con `enemies`

**Checkpoint**: Harry dispara mediante el pool; el impacto y la salida de pantalla devuelven proyectiles sin destruirlos durante el uso normal.

---

## Phase 4: User Story 2 - Administrar el crecimiento controlado del pool (Priority: P2)

**Goal**: Aumentar la capacidad únicamente cuando todos los proyectiles estén ocupados y hacerlo en lotes exactos de 10.

**Independent Test**: Mantener 50 proyectiles activos, solicitar el número 51, comprobar el crecimiento exacto a 60 y luego comprobar que una solicitud posterior reutiliza un elemento liberado.

### Implementation for User Story 2

- [X] T016 [US2] Implementar en `projectile_pool.gd` la ampliación exacta de 10 instancias cuando `available_projectiles` esté vacío
- [X] T017 [US2] Garantizar en `projectile_pool.gd` que la búsqueda de disponibles ocurra antes de cualquier ampliación y que no se creen unidades extra mientras exista un proyectil inactivo
- [X] T018 [US2] Agregar en `projectile_pool.gd` el rechazo controlado de solicitudes cuando una ampliación no pueda completarse, sin devolver referencias inválidas ni bloquear el nivel
- [X] T019 [US2] Integrar en `harry.gd` el manejo del resultado de una solicitud rechazada, evitando que el aliado agregue un nodo nulo o inválido al Scene Tree
- [X] T020 [US2] Verificar en los tres niveles que el crecimiento del pool y la reutilización no alteren las filas activas, spawners, enemigos ni aliados existentes

**Checkpoint**: La capacidad parte de 50, crece de 10 en 10 solo cuando es necesario y las solicitudes fallidas mantienen el nivel consistente.

---

## Phase 5: User Story 3 - Mantener seguridad y comportamiento existente (Priority: P3)

**Goal**: Asegurar que la reutilización no modifique las reglas jugables ni permita operaciones inseguras fuera del hilo principal.

**Independent Test**: Repetir activaciones, impactos, salidas de pantalla, señales simultáneas y cambios de nivel; comprobar que no hay daño duplicado, conexiones duplicadas, colisiones invisibles ni proyectiles residuales.

### Implementation for User Story 3

- [X] T021 [P] [US3] Auditar y ajustar `projectile.gd` para que ninguna ruta de finalización pueda devolver el mismo proyectil más de una vez por ciclo de activación
- [X] T022 [P] [US3] Validar en `projectile.gd` que un proyectil inactivo no procese movimiento, animación, detección de enemigos ni daño
- [X] T023 [US3] Mantener en `projectile.gd` la animación de cuatro cuadros y reiniciar el frame visual al activar un proyectil reutilizado
- [X] T024 [US3] Mantener en `projectile.gd` la creación de `impact_explosion.tscn` sin mezclar su ciclo de vida con el pool de proyectiles
- [X] T025 [US3] Revisar `projectile_pool.gd`, `projectile.gd`, `harry.gd` y `level.gd` para garantizar que todas las operaciones sobre nodos, señales, colisiones y Scene Tree se ejecuten en el hilo principal
- [X] T026 [US3] Agregar validaciones de referencias liberadas en callbacks de `projectile.gd` y `projectile_pool.gd` siguiendo las instrucciones de `.github/instructions/godot-gdscript.instructions.md`
- [ ] T027 [US3] Ejecutar los escenarios de `quickstart.md` con al menos 100 disparos consecutivos y registrar que los proyectiles liberados se reutilizan

**Checkpoint**: El pool conserva daño, animación, colisiones y limpieza, y no modifica nodos desde procesamiento concurrente.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validar la integración completa y dejar la documentación alineada con el resultado.

- [X] T028 [P] Validar `projectile.gd`, `projectile_pool.gd`, `harry.gd` y `level.gd` con el comprobador de scripts de Godot y corregir solo errores introducidos por esta funcionalidad
- [X] T029 [P] Ejecutar `git diff --check` y revisar que los cambios respeten el tipado estricto y la nomenclatura inglesa del proyecto
- [X] T030 Ejecutar los niveles 1, 2 y 3 y verificar los escenarios de impacto, salida, crecimiento, reutilización y cambio de nivel descritos en `specs/005-projectile-pool/quickstart.md`
- [X] T031 Crear `Documentacion.txt` para describir el pool como reutilización de objetos en el hilo principal y diferenciarlo de `WorkerThreadPool`
- [ ] T032 Actualizar `BACKLOG.md` únicamente si el usuario confirma que la implementación y sus criterios quedaron completados

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No depende de otras fases y puede comenzar inmediatamente.
- **Foundational (Phase 2)**: Depende de Setup y bloquea todas las historias.
- **User Story 1 (Phase 3)**: Depende de la infraestructura de Phase 2 y constituye el MVP.
- **User Story 2 (Phase 4)**: Depende de la solicitud y devolución implementadas en US1.
- **User Story 3 (Phase 5)**: Depende de US1 y US2 porque valida sus rutas completas.
- **Polish (Phase 6)**: Depende de las historias que se hayan implementado.

### User Story Dependencies

- **US1 (P1)**: Depende de Phase 2; no depende de otra historia.
- **US2 (P2)**: Depende de US1 para ampliar el mismo mecanismo de solicitud y devolución.
- **US3 (P3)**: Depende de US1 y US2 para validar impacto, salida, crecimiento y reinicio.

### Parallel Opportunities

- T002 y T003 pueden ejecutarse en paralelo con T001.
- T005 y T006 pueden ejecutarse en paralelo después de T004, siempre que no se edite simultáneamente la misma escena.
- T021, T022, T023 y T024 pueden revisarse en paralelo si se coordinan las modificaciones de `projectile.gd`.
- T028 y T029 pueden ejecutarse en paralelo después de completar las modificaciones.
- Las validaciones de niveles pueden distribuirse entre Nivel 1, Nivel 2 y Nivel 3 en T030.

## Parallel Example: User Story 1

```text
Después de Phase 2:
1. Implementar la solicitud y precalentamiento en projectile_pool.gd (T010-T011).
2. Cambiar la ruta de disparo en harry.gd (T012).
3. Cambiar las rutas de impacto y salida en projectile.gd (T013-T014).
4. Integrar y validar las tres escenas de nivel en T015.
```

## Parallel Example: User Story 2

```text
Después de completar US1:
1. Implementar crecimiento y reutilización prioritaria en projectile_pool.gd (T016-T017).
2. Implementar rechazo controlado en projectile_pool.gd y su consumo en harry.gd (T018-T019).
3. Validar la integración de niveles en T020.
```

## Implementation Strategy

1. **MVP**: Completar Phase 1, Phase 2 y US1. Esto entrega proyectiles reutilizables en combate sin cambiar las reglas visibles.
2. **Escalado**: Completar US2 para soportar picos de más de 50 proyectiles con crecimiento controlado.
3. **Robustez**: Completar US3 para cubrir estado residual, doble devolución, seguridad del hilo principal y cambio de nivel.
4. **Cierre**: Ejecutar Phase 6 y actualizar documentación solo después de validar el comportamiento real.
