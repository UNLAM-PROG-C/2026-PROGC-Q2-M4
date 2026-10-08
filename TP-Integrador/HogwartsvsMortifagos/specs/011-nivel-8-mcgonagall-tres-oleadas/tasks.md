# Implementation Tasks: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]` | **Date**: 2026-10-07 | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

**Input**: Design documents from `specs/011-nivel-8-mcgonagall-tres-oleadas/` (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/node-interfaces.md`, `quickstart.md`).  
**Status**: Completed.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Assets y recursos compartidos requeridos para las entidades de la funcionalidad.

- [X] T001 [P] Generate and validate McGonagall sprite asset (`130x130` with transparency) in `Images/mcgonagall.png`
- [X] T002 [P] Create ally card resource `mcgonagall_card.tres` with `display_name = "McGonagall"`, `cost = 200`, `cooldown = 7.5`, and `scene = ExtResource("res://mcgonagall.tscn")` in `mcgonagall_card.tres`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Actualizaciones en la lógica base de anuncios de oleadas en `level.gd`.

**⚠️ CRITICAL**: Bloquea la correcta presentación de las 3 oleadas masivas.

- [X] T003 Update wave announcement banners and dynamic distinction in `level.gd`: declare `WAVE_ANNOUNCEMENT_TEXT: String = "¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` and `FINAL_WAVE_ANNOUNCEMENT_TEXT: String = "¡OLEADA FINAL!"`, and update `_show_wave_announcement()` to check `_final_wave_active`, preserving method limits <= 15 lines in `level.gd`

---

## Phase 3: User Story 1 - Fuego Rápido en Ráfaga: McGonagall (Priority: P1) 🎯 MVP

**Goal**: Implementar la aliada McGonagall con disparo cuádruple secuencial (4 proyectiles a 0.15s de intervalo, 1.5s de recarga base entre ráfagas, 300 HP) reutilizando el pool de proyectiles común.

**Independent Test**: Plantar a McGonagall en una fila con enemigos en avance; verificar que al detectar un enemigo dispara exactamente 4 proyectiles en rápida sucesión (intervalo 0.15s), espera 1.5s de recarga y vuelve a disparar, aplicando 20 de daño por proyectil y cancelando la ráfaga limpiamente si es derrotada.

### Implementation for User Story 1

- [X] T004 [P] [US1] Create McGonagall scene `mcgonagall.tscn` with `Area2D` root (`groups = ["allies"]`), `Sprite2D` (`Images/mcgonagall.png`), `CollisionShape2D`, `ShootTimer` (wait_time 1.5, one_shot true), `BurstTimer` (wait_time 0.15, one_shot false), and `ShootPoint` (`Marker2D`) in `mcgonagall.tscn`
- [X] T005 [US1] Implement burst shooting logic and timer coordination in `mcgonagall.gd` (`class_name McGonagall extends Ally`), with `shot_interval = 1.5`, `burst_interval = 0.15`, `burst_count = 4`, `_shots_remaining`, `_on_shoot_timer_timeout()`, `_on_burst_timer_timeout()`, `_fire_burst_shot()`, and clean cancellation in `_die()`, strictly keeping all methods <= 15 lines in `mcgonagall.gd`

**Checkpoint**: McGonagall funciona de forma autónoma con ráfagas cuádruples no bloqueantes y reutilización de proyectiles del pool.

---

## Phase 4: User Story 2 - Extensión del Gestor de Oleadas a 3 Grandes Oleadas (Priority: P1)

**Goal**: Habilitar el flujo de 3 eventos de Gran Oleada en el gestor de niveles (`is_special_level = true`, 45 enemigos de presupuesto, hitos en las bajas 15 y 30, y Oleada Final tras limpiar la fase regular).

**Independent Test**: Ejecutar un nivel configurado con `is_special_level = true` y `total_enemies = 45`; verificar que al alcanzar 15 y 30 bajas se detiene el spawn regular, aparece el banner `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` y se despliega una oleada masiva, y al limpiar el tablero regular se muestra `"¡OLEADA FINAL!"` con el asalto definitivo.

### Implementation for User Story 2

- [X] T006 [US2] Verify and validate 3-wave threshold handling in `level.gd` (`SPECIAL_FIRST_WAVE_RATIO = 0.33`, `SPECIAL_SECOND_WAVE_RATIO = 0.66`, `_try_prepare_intermediate_wave()`, and `_try_prepare_final_wave()`), ensuring 2 intermediate waves and 1 final wave execute without overlap in `level.gd`

**Checkpoint**: El gestor de niveles controla de manera fluida y robusta las 3 grandes oleadas masivas con sus anuncios correspondientes.

---

## Phase 5: User Story 3 - Desafío y Progresión Completa del Nivel 8 (Priority: P1)

**Goal**: Construir la escena completa `level_8.tscn` de 5 líneas activas con 5 Dementores, 9 cartas funcionales en el HUD (incluyendo McGonagall y Accio), oleadas mixtas de los 4 tipos de enemigos y desbloqueo del Nivel 9 en el Mapa del Merodeador al ganar.

**Independent Test**: Iniciar el Nivel 8 desde el selector de niveles o tras vencer el Nivel 7; verificar 5 filas activas con 5 Dementores, 9 cartas funcionales en el HUD, oleadas compuestas por los 4 tipos de enemigos y el correcto desbloqueo del Nivel 9 tras triunfar.

### Implementation for User Story 3

- [X] T007 [US3] Create the complete Level 8 scene `level_8.tscn` based on Level 7 structure, configuring `total_enemies = 45`, `is_special_level = true`, `starting_snitches = 150`, `active_rows = [2, 3, 4, 5, 6]`, 5 Dementor instances, `next_level_to_unlock = 9`, `enemy_scenes` with 4 enemy types (Alumno Slytherin, Draco, Protego, Prefecto), and the 9-button HUD row with `McGonagallCardButton` (cost 200) in `level_8.tscn`
- [X] T008 [US3] Verify level select progression in `level_select_menu.gd` ensuring Level 8 unlocks Level 9 properly in the Marauder's Map in `level_select_menu.gd`

**Checkpoint**: El Nivel 8 es totalmente jugable de principio a fin, integrando las 9 cartas, 4 tipos de enemigos y progresión al Nivel 9.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validación cruzada de calidad, pruebas end-to-end y cumplimiento del estándar de código de la cátedra.

- [X] T009 [P] Execute end-to-end gameplay verification via Godot CLI running `level_8.tscn`, testing card placement, burst firing, 3 wave triggers, and victory panel without null instance errors or console exceptions in `level_8.tscn`
- [X] T010 Validate repository coding standards (Google style guide, Allman braces where applicable, max 15 lines per GDScript method, strictly typed GDScript, no magic numbers, English identifiers) across all new and modified files (`mcgonagall.gd`, `level.gd`, `mcgonagall_card.tres`, `level_8.tscn`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sin dependencias previas; T001 y T002 pueden ejecutarse en paralelo.
- **Foundational (Phase 2)**: Depende de Phase 1. Bloquea la correcta presentación de las oleadas.
- **User Story 1 (Phase 3)**: Depende de Phase 1 (sprite y recurso de carta).
- **User Story 2 (Phase 4)**: Depende de Phase 2 (anuncios y lógica de oleadas en `level.gd`).
- **User Story 3 (Phase 5)**: Depende de User Story 1 y User Story 2 (integra a McGonagall y la configuración de 3 oleadas en `level_8.tscn`).
- **Polish (Phase 6)**: Depende de la finalización de todas las historias de usuario.

### Parallel Opportunities

- `T001` (sprite) y `T002` (recurso de carta) pueden ejecutarse en paralelo.
- `T004` (escena de McGonagall) puede crearse en paralelo con la implementación del script `T005`.
- `T009` (verificación de ejecución) puede prepararse en paralelo con `T010` (auditoría de coding standard).

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Completar Setup (T001, T002) y Foundational (T003).
2. Implementar User Story 1 (T004, T005: McGonagall con ráfagas cuádruples).
3. Validar de forma aislada a McGonagall disparando ráfagas continuas contra enemigos.

### Incremental Delivery
1. Sumar User Story 2 (T006: Control de 3 oleadas en `level.gd`).
2. Sumar User Story 3 (T007, T008: Escena completa `level_8.tscn` con 9 cartas y 5 carriles).
3. Ejecutar validación final y verificación de reglas de la cátedra (T009, T010).
