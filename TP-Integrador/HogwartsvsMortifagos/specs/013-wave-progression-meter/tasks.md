# Tasks: Sistema Híbrido de Oleadas por Bajas y Medidor Visual de Progreso

**Branch**: `013-wave-progression-meter` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Setup (Assets & Normalization)

**Purpose**: Normalización de recursos gráficos a inglés y generación de textura de relleno

- [X] T001 Rename Spanish meter assets `Personajes_Medidor 2 oleadas.png` to `Images/wave_meter_2_waves.png` and `Personajes_Medidor 3 oleadas.png` to `Images/wave_meter_3_waves.png`, cleaning old `.import` files in `Images/`
- [X] T002 [P] Create the inner liquid column texture `Images/wave_meter_red_progress.png` sized 294x1014 px with alpha bounded to the tube interior (x: 48 to 245) for clean progress filling in `Images/wave_meter_red_progress.png`

---

## Phase 2: Foundational (Core Component & Contracts)

**Purpose**: Componente modular reutilizable `WaveProgressBar` para el HUD

**⚠️ CRITICAL**: El componente visual debe estar implementado antes de la integración con los niveles

- [X] T003 [P] Create `wave_progress_bar.gd` implementing `setup(max_kills: int, frame_texture: Texture2D) -> void` and `update_progress(current_kills: int) -> void` adhering to <= 15 lines per function and strict typing in `wave_progress_bar.gd`
- [X] T004 Create `wave_progress_bar.tscn` scene with root `Control` and child `TextureProgressBar` configured with `fill_mode = 3` (Bottom to Top), `texture_progress = res://Images/wave_meter_red_progress.png` and attached script in `wave_progress_bar.tscn`

**Checkpoint**: Componente de interfaz `WaveProgressBar` creado y listo para integrarse.

---

## Phase 3: User Story 1 - Gestor Híbrido de Oleadas: Eventos por Bajas y Dificultad Temporal (Priority: P1) 🎯 MVP

**Goal**: Desacoplar el disparo de Grandes Oleadas del tiempo, condicionándolo a umbrales de bajas en combate mientras el temporizador regular acelera la dificultad en background.

**Independent Test**: Iniciar `level_1.tscn`, verificar que matar 15 enemigos activa la Oleada 1 exactamente en la baja 15, resetea las bajas de fase a 0, y 20 bajas subsiguientes activan la Oleada Final, mientras los enemigos comunes continúan spawneando en background.

### Implementation for User Story 1

- [X] T005 [US1] Add exported configuration `@export var wave_kill_thresholds: Array[int] = [15, 20]` and tracking variables `_phase_defeated_enemies: int = 0`, `_total_defeated_enemies: int = 0`, `_current_phase_index: int = 0` in `level.gd`
- [X] T006 [US1] Refactor `_on_enemy_defeated` and `_check_wave_threshold` in `level.gd` to trigger intermediate waves on threshold reach, reset `_phase_defeated_enemies` to 0, pause `enemy_spawn_timer` during active waves, and ignore non-combat departures
- [X] T007 [US1] Refactor background spawn cadence acceleration and `_resume_after_wave` in `level.gd` to shorten regular spawn interval over time, resume normal spawning after intermediate waves, and trigger `_win()` when `_active_enemies == 0` following the final wave

**Checkpoint**: Bucle jugable de oleadas por bajas 100% operativo y funcional como MVP sin depender del tiempo para las grandes oleadas.

---

## Phase 4: User Story 2 - Interfaz de Medidor Visual de Progreso (Reloj de Arena) (Priority: P1)

**Goal**: Mostrar el medidor visual en la esquina inferior izquierda del HUD con líquido rojo vertical de abajo hacia arriba proporcional a las bajas acumuladas del nivel.

**Independent Test**: Cargar cualquier nivel y observar el medidor en la esquina inferior izquierda; matar enemigos y verificar que el líquido rojo sube progresivamente hasta alcanzar el 100% al disparar la Oleada Final.

### Implementation for User Story 2

- [X] T008 [US2] Add `@export var wave_meter_texture: Texture2D` and instantiate `WaveProgressBar` in the bottom-left corner of `HUD` within `_init_hud_and_cards` in `level.gd`
- [X] T009 [US2] Update `_wave_progress_bar.update_progress(_total_defeated_enemies)` on every combat kill within `_on_enemy_defeated`, clamping at `_total_level_kills` (100%) in `level.gd`
- [X] T010 [P] [US2] Configure `wave_kill_thresholds` (`[15, 20]`, `[20, 25]`, `[20, 30]`, `[25, 30]`, `[30, 35]`, `[30, 30]`, `[30, 30]`) and `wave_meter_texture` (`wave_meter_2_waves.png`) across `level_1.tscn` through `level_7.tscn`
- [X] T011 [P] [US2] Configure `wave_kill_thresholds` (`[20, 40, 60]` and `[30, 40, 70]`) and `wave_meter_texture` (`wave_meter_3_waves.png`) across `level_8.tscn` and `level_9.tscn`

**Checkpoint**: Medidor visual integrado y calibrado en los 9 niveles del juego.

---

## Phase 5: Polish & Validation

**Purpose**: Verificación integral de calidad, ejecución headless y cumplimiento de estándares

- [X] T012 [P] Validate headless execution of `level_1.tscn` and `level_9.tscn` via Godot CLI ensuring no script errors, null instances or missing resource warnings in `level_1.tscn` and `level_9.tscn`
- [X] T013 Execute full validation scenarios from `quickstart.md` testing kill thresholds, pause during huge waves, garden invasion defeat, and victory screen in `specs/013-wave-progression-meter/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sin dependencias previas; normaliza assets y genera texturas inmediatamente.
- **Foundational (Phase 2)**: Depende de Phase 1 (textura de progreso). Bloquea la integración completa de UI en US2.
- **User Story 1 (Phase 3)**: Depende de Phase 1. Puede implementarse en paralelo o justo antes de US2.
- **User Story 2 (Phase 4)**: Depende de Phase 2 (`WaveProgressBar`) y se enlaza con US1 (`level.gd`).
- **Polish (Phase 5)**: Depende de que US1 y US2 estén completados.

### User Story Dependencies

- **User Story 1 (P1)**: Motor de lógica de oleadas. Independiente de la vista.
- **User Story 2 (P1)**: Vista del progreso en el HUD. Consume los eventos y contadores de US1.

---

## Parallel Opportunities

- **T001 y T002**: Pueden ejecutarse en paralelo (renombrado de marcos vs generación de textura roja).
- **T003 y T004**: Creación de script y escena de `WaveProgressBar`.
- **T010 y T011**: Configuración de escenas de niveles (L1-L7 vs L8-L9).
- **T012**: Validación headless paralela a pruebas de testing.

---

## Parallel Example: Setup & Foundational

```bash
# T001 y T002 en paralelo:
Task: "Rename Spanish meter assets to English in Images/"
Task: "Create inner liquid column texture wave_meter_red_progress.png in Images/"

# T010 y T011 en paralelo:
Task: "Configure thresholds and texture in level_1.tscn to level_7.tscn"
Task: "Configure thresholds and texture in level_8.tscn and level_9.tscn"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Completar Setup (T001, T002) y Foundational (T003, T004).
2. Implementar User Story 1 (T005, T006, T007) en `level.gd`.
3. Validar de forma independiente: las oleadas se disparan por kills y no por tiempo.

### Entrega Incremental
1. Integrar User Story 2 (T008, T009, T010, T011) conectando el medidor del HUD y configurando los 9 niveles.
2. Ejecutar validación final y pruebas headless (T012, T013).
