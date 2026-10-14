# Tasks: Nivel 7 - Hermione y Prefecto Slytherin

**Input**: Design documents from `specs/010-nivel-7-hermione-prefecto/` (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/node-interfaces.md`, `quickstart.md`).  
**Status**: Completed.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Assets and base resource definitions needed across the feature.

- [X] T001 [P] Verify `res://Images/hermione.png`, `res://Images/slytherin_shot.png`, and `res://Images/slytherin_protego.png` asset presence and create the ally card resource `hermione_card.tres` with `display_name = "Hermione"`, `scene = ExtResource("res://hermione.tscn")`, `cost = 125`, and `cooldown = 7.5` in `hermione_card.tres`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure and state extensions that MUST be complete before user story implementation.

**⚠️ CRITICAL**: Blocks all user stories until completed.

- [X] T002 Implement slow state handling in `Enemy` (`enemy.gd`): declare `_slow_factor: float = 1.0`, `_base_modulate: Color = Color.WHITE`, `_slow_timer: Timer`, implement `apply_slow(factor: float, duration: float) -> void` and `_on_slow_timer_timeout() -> void`, scale walking speed and attack DPS by `_slow_factor`, preserving method limits <= 15 lines in `enemy.gd`
- [X] T003 [P] Extend `Lane` helper in `lane.gd` adding static method `has_allies_in_lane_ahead(tree: SceneTree, lane_y: float, from_x: float) -> bool` to detect valid allies in the same row positioned to the left of `from_x` in `lane.gd`
- [X] T004 [P] Extend `Projectile` in `projectile.gd` and `ProjectilePool` in `projectile_pool.gd` adding `@export var slows: bool = false`, `@export var slow_factor: float = 0.70`, `@export var slow_duration: float = 5.0`, triggering `enemy.apply_slow()` on hit, and supporting `acquire_projectile(spawn_pos, custom_damage, slows)` in `projectile.gd` and `projectile_pool.gd`

**Checkpoint**: Foundation ready - Los enemigos pueden ser ralentizados, los proyectiles pueden transportar el efecto de hielo y `Lane` puede detectar aliados por delante.

---

## Phase 3: User Story 1 - Ataque Ralentizador de Hermione (Priority: P1) 🎯 MVP

**Goal**: Permitir al jugador plantar a Hermione por 125 snitches para que dispare proyectiles de hielo (20 de daño base, cadencia 1.5s) que ralentizan al 70% la velocidad de marcha y el ataque de los enemigos por 5.0 segundos con tinte visual celeste.

**Independent Test**: Plantar a Hermione en una fila frente a enemigos en avance; verificar que dispara proyectiles azules que impactan, infligen 20 de daño y reducen la velocidad y el ataque del enemigo al 70% durante 5.0 segundos con feedback visual celeste, restableciendo la velocidad normal al expirar.

### Implementation for User Story 1

- [X] T005 [P] [US1] Create the Hermione script `hermione.gd` extending `Ally` with `@export var shot_interval: float = 1.5`, `@export var damage: float = 20.0`, `@export var projectile_scene: PackedScene`, `@export var projectile_pool: ProjectilePool`, `_ready()`, `_on_shoot_timer_timeout()`, `_shoot()` acquiring blue slowing projectiles, and `_has_enemy_in_lane()` in `hermione.gd`
- [X] T006 [US1] Create the Hermione scene `hermione.tscn` as an `Area2D` belonging to group `allies` (`collision_mask = 0`) with `Sprite2D` (`res://Images/hermione.png`), `CollisionShape2D`, `ShootPoint`, `ShootTimer`, and `DamageFlash` in `hermione.tscn`
- [X] T007 [US1] Ensure `level.gd` in `_init_placed_ally()` properly injects `projectile_pool` into Hermione instances when planted on the grid in `level.gd`

**Checkpoint**: User Story 1 completa - Hermione puede ser plantada y sus proyectiles aplican daño y ralentización visual y mecánica a los enemigos.

---

## Phase 4: User Story 3 - Visual y Animación del Hechizo del Prefecto (Priority: P2)

**Goal**: Crear la escena del proyectil enemigo animado `enemy_projectile.tscn` utilizando la textura `res://Images/slytherin_shot.png` (4 fotogramas continuos en bucle) que viaja hacia la izquierda a 400 px/s e inflige 20 de daño a aliados.

**Independent Test**: Instanciar un `EnemyProjectile` en una fila con un aliado plantado; verificar que viaja a 400 px/s hacia la izquierda ciclando continuamente por los 4 fotogramas, inflige 20 de daño al colisionar con el aliado y se destruye sin errores.

### Implementation for User Story 3

- [X] T008 [P] [US3] Create `enemy_projectile.gd` extending `Area2D` declaring `@export var speed: float = 400.0`, `@export var damage: float = 20.0`, `@export var animation_frame_duration: float = 0.08`, `_process(delta: float)` moving in `Vector2.LEFT` and cycling frames 0..3, `_on_area_entered(area: Area2D)` damaging allies, and `_on_screen_exited()` in `enemy_projectile.gd`
- [X] T009 [US3] Create `enemy_projectile.tscn` as an `Area2D` (`collision_layer = 0`, `collision_mask = 1`) with `Sprite2D` (`res://Images/slytherin_shot.png`, `hframes = 4, vframes = 1`), `CollisionShape2D`, and `VisibleOnScreenNotifier2D` connecting `area_entered` and `screen_exited` signals in `enemy_projectile.tscn`

**Checkpoint**: User Story 3 completa - El proyectil oscuro animado viaja hacia la izquierda y colisiona correctamente con aliados.

---

## Phase 5: User Story 2 - Enemigo a Distancia: Prefecto Slytherin (Priority: P1)

**Goal**: Crear la entidad enemiga `slytherin_prefect.tscn` (200 HP) basada en la textura `slytherin_protego` (sin escudo) que camina y dispara proyectiles enemigos cada 3.5 segundos únicamente cuando detecta aliados a su izquierda en su fila.

**Independent Test**: Generar un Prefecto Slytherin en una fila con aliados; comprobar que camina hacia la izquierda, se detiene cada 3.5 segundos para disparar un proyectil que daña al aliado, y verificar que en una fila vacía camina continuamente sin disparar.

### Implementation for User Story 2

- [X] T010 [P] [US2] Create the script `slytherin_prefect.gd` extending `Enemy` declaring `@export var shoot_interval: float = 3.5`, `@export var projectile_scene: PackedScene`, `@onready var shoot_timer: Timer = $ShootTimer`, `@onready var shoot_point: Marker2D = $ShootPoint`, `_ready()`, `_on_shoot_timer_timeout()` verifying `Lane.has_allies_in_lane_ahead()`, and `_shoot()` instantiating `EnemyProjectile` towards the left in `slytherin_prefect.gd`
- [X] T011 [US2] Create the scene `slytherin_prefect.tscn` as an `Area2D` belonging to group `enemies` (`collision_layer = 2, collision_mask = 0`) with `Sprite2D` (`res://Images/slytherin_protego.png`, `hframes = 8` without shield sprite), `CollisionShape2D`, `DetectionArea`, `AnimationTimer`, `ShootTimer`, `ShootPoint`, and `DamageFlash` in `slytherin_prefect.tscn`

**Checkpoint**: User Story 2 completa - El Prefecto Slytherin camina, detecta aliados y dispara proyectiles a distancia hacia la izquierda.

---

## Phase 6: User Story 4 - Desafío y Progresión del Nivel 7 (Priority: P1)

**Goal**: Configurar la escena jugable `level_7.tscn` con 5 líneas activas, 5 Dementores defensivos, HUD con 8 cartas aliadas (Harry, SnitchBox, Ron, Recordadora, Protego, Escoba, Hermione, Accio), oleadas mixtas de 4 tipos de enemigos y desbloqueo del Nivel 8 tras la victoria.

**Independent Test**: Jugar el Nivel 7 desde el selector de niveles, verificar 5 líneas y 8 cartas en HUD, superar las oleadas con Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin, comprobar el panel de victoria y el desbloqueo del Nivel 8 en el Mapa del Merodeador.

### Implementation for User Story 4

- [X] T012 [P] [US4] Create `level_7.tscn` inheriting root `Level` structure with `active_rows = [2, 3, 4, 5, 6]`, 5 Dementors, calibrated Grid (`position = Vector2(24, -128)`, `scale = Vector2(1.25, 1.25)`), 5 spawn markers, `enemy_scenes = [slytherin_student, draco, protego_student, slytherin_prefect]`, `EnemySpawnTimer.wait_time = 4.0`, `total_enemies = 32`, and `next_level_to_unlock = 8` in `level_7.tscn`
- [X] T013 [US4] Configure `$HUD` in `level_7.tscn` adding `HermioneCardButton` with `card = ExtResource("res://hermione_card.tres")`, label `"Hermione (125)"`, arranged alongside the other 7 cards and Accio button in `level_7.tscn`
- [X] T014 [US4] Register `level_7.tscn` in `level_select_menu.tscn` as the 7th element of the `level_scenes` array in `level_select_menu.tscn`

**Checkpoint**: User Story 4 completa - Nivel 7 jugable de principio a fin con todas las cartas y enemigos integrados.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Verificación de estándares de cátedra y validación integral de la feature.

- [X] T015 Verify method line counts (no method > 15 lines per cátedra rule), strict static typing, and formatting across all newly created scripts in `hermione.gd`, `slytherin_prefect.gd`, `enemy_projectile.gd`, `enemy.gd`, `lane.gd`, `projectile.gd`, and `projectile_pool.gd`
- [X] T016 Run end-to-end validation according to `quickstart.md` ensuring Hermione slow and Prefecto shooting operate without console errors in Godot

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion.
- **User Story 3 (Phase 4)**: Depends on Phase 2 completion.
- **User Story 2 (Phase 5)**: Depends on Phase 2 and Phase 4 (needs `EnemyProjectile` scene).
- **User Story 4 (Phase 6)**: Depends on Phase 3, Phase 4, and Phase 5 completion.
- **Polish (Phase 7)**: Depends on all user stories completion.

### Parallel Opportunities

- T001, T003, T004 can be prepared in parallel.
- T005 (`hermione.gd`) and T008 (`enemy_projectile.gd`) can be implemented in parallel.
- T010 (`slytherin_prefect.gd`) and T012 (`level_7.tscn` layout) can be started in parallel once foundational elements exist.

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Complete Phase 1: Setup (`hermione_card.tres`).
2. Complete Phase 2: Foundational (`enemy.gd`, `lane.gd`, `projectile.gd`, `projectile_pool.gd`).
3. Complete Phase 3: User Story 1 (`hermione.gd`, `hermione.tscn`).
4. **VALIDATE MVP**: Test Hermione placing and ice projectiles slowing down enemies.

### Incremental Delivery
1. Add User Story 3 (`enemy_projectile.tscn`).
2. Add User Story 2 (`slytherin_prefect.tscn`).
3. Add User Story 4 (`level_7.tscn` + `level_select_menu.tscn`).
4. Polish and validate against `quickstart.md`.
