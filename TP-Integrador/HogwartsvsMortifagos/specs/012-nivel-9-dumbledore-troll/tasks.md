# Implementation Tasks: Nivel 9 - Dumbledore y el Troll Colosal

**Branch**: `[012-nivel-9-dumbledore-troll]` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

**Input**: Design documents from `specs/012-nivel-9-dumbledore-troll/` (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/node-interfaces.md`, `quickstart.md`).  
**Status**: Ready for implementation.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Assets y recursos compartidos requeridos para las entidades del Nivel 9.

- [X] T001 [P] Create ally card resource `dumbledore_card.tres` with `display_name = "Dumbledore"`, `cost = 300`, `cooldown = 15.0`, `texture = ExtResource("res://Images/dumbledore.png")`, and `scene = ExtResource("res://dumbledore.tscn")` in `dumbledore_card.tres`
- [X] T002 [P] Verify asset existence and texture paths in `Images/` confirming `Images/dumbledore.png`, `Images/dumbledore_shot.png`, and `Images/troll_*.png` exist with valid Godot `.import` files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Escena y script del proyectil de Dumbledore con lógica de splash damage 3x3, prerrequisito para la aliada Dumbledore.

**⚠️ CRITICAL**: Bloquea el funcionamiento ofensivo de Dumbledore.

- [X] T003 [P] Create Dumbledore's splash projectile scene `dumbledore_projectile.tscn` with `Area2D` root (`groups = ["spells"]`), `Sprite2D` (`Images/dumbledore_shot.png`), frontal `CollisionShape2D`, and secondary `SplashArea` (`Area2D` with `RectangleShape2D` size `Vector2(384, 384)` and collision mask 2) in `dumbledore_projectile.tscn`
- [X] T004 Implement `dumbledore_projectile.gd` (`class_name DumbledoreProjectile extends Area2D`) with horizontal linear movement (`speed = 350.0`), `_on_area_entered()` collision detection against `groups = ["enemies"]`, 3x3 splash damage application (`splash_damage = 20.0`) to all enemies in the area, spawning impact effect, and immediate `queue_free()`, strictly keeping all methods <= 15 lines in `dumbledore_projectile.gd`

---

## Phase 3: User Story 1 - Ataque Pesado con Splash Damage: Dumbledore (Priority: P1) 🎯 MVP

**Goal**: Implementar la aliada Dumbledore (`dumbledore.tscn` / `dumbledore.gd`) con disparo pesado cada 3.0 segundos, 300 HP y lanzamiento de proyectiles con splash damage 3x3.

**Independent Test**: Plantar a Dumbledore en una fila con enemigos en avance; verificar que al detectar un enemigo en su carril dispara en línea recta horizontal un proyectil que explota al primer impacto causando 20 de daño simultáneo a todos los enemigos en un área de 3x3 celdas (fila de impacto, fila superior y fila inferior), destruyéndose tras la detonación.

### Implementation for User Story 1

- [X] T005 [P] [US1] Create Dumbledore scene `dumbledore.tscn` with `Area2D` root (`groups = ["allies"]`), `Sprite2D` (`Images/dumbledore.png`), `CollisionShape2D` (size 80x110), `ShootTimer` (wait_time 3.0, autostart true), `ShootPoint` (`Marker2D`), and `DamageFlash` instance in `dumbledore.tscn`
- [X] T006 [US1] Implement `dumbledore.gd` (`class_name Dumbledore extends Ally`) with `shot_interval = 3.0`, `projectile_scene` (`dumbledore_projectile.tscn`), lane enemy detection via `Lane.enemies_in_lane()`, and shooting logic in `_on_shoot_timer_timeout()`, strictly keeping all methods <= 15 lines in `dumbledore.gd`

**Checkpoint**: Dumbledore puede plantarse, dispara proyectiles pesados en línea recta y genera detonaciones de 3x3 celdas infligiendo 20 de daño por enemigo.

---

## Phase 4: User Story 2 - Amenaza Colosal Imparable: El Troll (Priority: P1)

**Goal**: Integrar la lógica del Troll colosal en la escena existente `troll.tscn` con script `troll.gd`: 3600 HP (resiste exactamente 2 golpes masivos de 1800), velocidad de 20 px/s, y pausa breve para reproducir `"attack"` y destruir instantáneamente (9999 de daño) a cualquier aliado antes de reanudar `"Walk"`.

**Independent Test**: Instanciar al Troll ante defensas aliadas; verificar que avanza con la animación `"Walk"`, se detiene brevemente al topar una planta para reproducir `"attack"`, la destruye instantáneamente (9999 HP) y reanuda `"Walk"`. Verificar que un golpe de Escoba/Recordadora (1800 HP) reduce su vida al 50% y el segundo golpe lo elimina limpiamente.

### Implementation for User Story 2

- [X] T007 [P] [US2] Update `troll.tscn` setting root type to `Area2D` with collision layer 2 and mask 1, adding `CollisionShape2D` (size 100x180), frontal `DetectionArea` (`Area2D` with mask 1), and `DamageFlash` instance without altering visual child nodes or `AnimationPlayer` in `troll.tscn`
- [X] T008 [US2] Implement `troll.gd` (`class_name Troll extends Enemy`) setting `max_health = 3600.0`, `speed = 20.0`, continuous leftward motion while walking, instakill strike (9999.0 damage) pausing motion during `"attack"` animation, returning to `"Walk"` upon smash completion, and custom `take_damage()` handling, strictly keeping all methods <= 15 lines in `troll.gd`

**Checkpoint**: El Troll funciona como enemigo colosal que avanza, golpea con la animación de ataque aplastando aliados al instante, y requiere exactamente 2 impactos de daño masivo para morir.

---

## Phase 5: User Story 3 - Desafío y Progresión Completa del Nivel 9 (Priority: P1)

**Goal**: Construir la escena completa `level_9.tscn` con 5 líneas activas, 5 Dementores defensivos, HUD de 10 cartas funcionales (incluyendo a Dumbledore y Accio), oleadas compuestas por los 5 tipos de enemigos (incluyendo al Troll) y desbloqueo del Nivel 10 (Profesor Quirrell) al triunfar.

**Independent Test**: Iniciar el Nivel 9 desde el selector de niveles o tras vencer el Nivel 8; verificar 5 filas activas con 5 Dementores, 10 cartas funcionales en el HUD, oleadas con los 5 tipos de enemigos culminando con Trolls en la Gran Oleada Final, y el correcto desbloqueo del Nivel 10 tras ganar.

### Implementation for User Story 3

- [X] T009 [US3] Create the complete Level 9 scene `level_9.tscn` based on Level 8 structure, configuring `total_enemies = 45`, `active_rows = [2, 3, 4, 5, 6]`, 5 Dementor instances, `next_level_to_unlock = 10`, `enemy_scenes` with 5 enemy types (Alumno Slytherin, Draco, Protego, Prefecto, Troll), and the 10-button HUD row with `DumbledoreCardButton` (cost 300) in `level_9.tscn`
- [X] T010 [US3] Verify level select menu progression in `level_select_menu.gd`, ensuring Level 9 unlocks Level 10 properly in the Marauder's Map in `level_select_menu.gd`

**Checkpoint**: El Nivel 9 es totalmente jugable de principio a fin, integrando las 10 cartas, 5 tipos de enemigos y progresión al Nivel 10.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validación cruzada de calidad, pruebas end-to-end y cumplimiento del estándar de código de la cátedra.

- [X] T011 [P] Validate end-to-end gameplay in `level_9.tscn`, testing Dumbledore splash damage on multiple lanes, Troll smash instakill and 2 massive hits death, HUD 10 cards, and victory screen leading to Level 10 unlock without console exceptions or errors in `level_9.tscn`
- [X] T012 Validate repository coding standards (Google style guide, Allman braces where applicable, max 15 lines per GDScript method, strictly typed GDScript, no magic numbers, English identifiers) across all new and modified files (`dumbledore.gd`, `dumbledore.tscn`, `dumbledore_projectile.gd`, `dumbledore_projectile.tscn`, `troll.gd`, `troll.tscn`, `dumbledore_card.tres`, `level_9.tscn`) in `tools/check_rules.gd`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sin dependencias previas; T001 y T002 pueden ejecutarse en paralelo.
- **Foundational (Phase 2)**: Depende de Phase 1. Bloquea a User Story 1 (Dumbledore).
- **User Story 1 (Phase 3)**: Depende de Phase 2 (`dumbledore_projectile.tscn`).
- **User Story 2 (Phase 4)**: Puede desarrollarse en paralelo con User Story 1. Depende de Phase 1 (verificación de assets).
- **User Story 3 (Phase 5)**: Depende de User Story 1 y User Story 2 (integra a Dumbledore y al Troll en `level_9.tscn`).
- **Polish (Phase 6)**: Depende de la finalización de todas las historias de usuario.

### Parallel Opportunities

- `T001` (recurso de carta) y `T002` (verificación de assets) pueden ejecutarse en paralelo.
- `T003` (`dumbledore_projectile.tscn`) y `T007` (`troll.tscn`) pueden prepararse en paralelo.
- `T005` (escena de Dumbledore) y `T007` (escena del Troll) pueden realizarse en paralelo.
- `T011` (prueba end-to-end) y `T012` (auditoría de coding standard) pueden ejecutarse en la fase final.

---

## Implementation Strategy & MVP Scope

- **MVP Scope**: Phase 1 + Phase 2 + Phase 3 (Dumbledore plantable y disparando proyectiles con daño en área 3x3 funcional).
- **Incremento 2**: Phase 4 (Troll colosal con 3600 HP, pausa de ataque `"attack"` e instakill).
- **Incremento 3**: Phase 5 (Escena completa `level_9.tscn` con 10 cartas, 5 tipos de enemigos y desbloqueo del Nivel 10).
- **Incremento Final**: Phase 6 (Verificación end-to-end y validación formal de reglas de la cátedra con `tools/check_rules.gd`).
