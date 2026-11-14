# Tasks: Animación de Desbloqueo de Recompensa al Ganar Nivel

**Feature**: `015-animacion-desbloqueo-recompensa`  
**Input**: Design artifacts from `specs/015-animacion-desbloqueo-recompensa/`  
**Branch**: `015-animacion-desbloqueo-recompensa`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Recursos gráficos y extensiones base compartidas.

- [X] T001 Crear el sprite provisional de la Piedra Filosofal en `Images/trophy_philosophers_stone.png` (relicario de rubí/gema mágica roja estilizada).
- [X] T002 [P] Extender `game_manager.gd` con la estructura de recompensas reclamadas `claimed_rewards: Dictionary[int, bool]` y métodos tipados `claim_reward(level_num: int) -> void` y `is_reward_claimed(level_num: int) -> bool`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Estructura de datos del catálogo y escena base de la pantalla de recompensa que bloquean las historias de usuario.

**⚠️ CRITICAL**: Ninguna historia de usuario puede integrarse hasta completar esta fase.

- [X] T003 [P] Crear `reward_catalog.gd` con la clase `RewardData`, las constantes de texto descriptivo (`*_DESC_TEXT`) y el método estático `get_reward_for_level(level_num: int) -> RewardData`.
- [X] T004 Crear la escena `reward_unlock_screen.tscn` en la raíz con jerarquía: `CanvasLayer` (layer 100), `RootControl` (pantalla completa 1920x1080), fondo atenuado/blur `ColorRect`, contenedor `SeedAnchor` (`Control`) con icono `SeedIcon` (`TextureRect`), texto descriptivo `DescriptionLabel` (`Label`) y botón `ContinueButton` (`Button`).

---

## Phase 3: User Story 1 - Presentación y Animación Cinemática de la Recompensa Desbloqueada (Priority: P1) 🎯 MVP

**Goal**: Mostrar una secuencia cinemática a pantalla completa con fondo desenfocado, donde la semilla aparece girando con zoom in desde el centro hasta su reposo, exhibiendo el texto estático debajo, permitiendo saltar con clic y cerrando con el botón "Continuar" para desplegar `LevelEndPanel`.

**Independent Test**: Simular la victoria en el Nivel 1: verificar que el fondo se atenúe/desenfoque, la semilla rote y aumente su tamaño de forma fluida vía Tween, el texto no sufra distorsión, un clic durante el giro salte al reposo de inmediato y presionar "Continuar" presente `LevelEndPanel`.

### Implementation for User Story 1

- [X] T005 [US1] Implementar el script `reward_unlock_screen.gd` con tipado estático estricto, constantes visuales y de tiempo, señal `reward_dismissed(level_number: int)` y método `setup(level_num: int, item_texture: Texture2D, description: String) -> void`.
- [X] T006 [US1] Implementar en `reward_unlock_screen.gd` la cinemática paralela de `Tween` (`create_tween().set_parallel(true)`) animando simultáneamente escala (`0.1` a `2.5`), rotación (`0.0` a `4.0 * PI`) y traslación vertical al reposo en ~1.2 segundos con curva `TRANS_CUBIC` y `EASE_OUT`.
- [X] T007 [US1] Implementar la detección de clics para omisión instantánea (`skip_animation()` y `_gui_input`) en `reward_unlock_screen.gd` deteniendo el `Tween` activo y fijando la semilla en su posición final de reposo con el botón "Continuar" habilitado.
- [X] T008 [US1] Implementar en `reward_unlock_screen.gd` el manejador de pulsación de `ContinueButton` emitiendo `reward_dismissed(level_number)` y destruyendo la pantalla mediante `queue_free()`.
- [X] T009 [US1] Integrar la cinemática en `level.gd`: en `_win()`, si el nivel tiene recompensa no reclamada (`!GameManager.is_reward_claimed()`), instanciar `reward_unlock_screen.tscn` en `$HUD`, conectar su señal `reward_dismissed` para registrar la recompensa y llamar seguidamente a `_show_end_panel(WIN_TITLE_TEXT, win_message, true)`.

**Checkpoint**: User Story 1 completamente funcional como MVP con cinemática, salto y transición a `LevelEndPanel`.

---

## Phase 4: User Story 2 - Mapeo de Recompensas Específicas por Nivel (Niveles 1 al 8) (Priority: P2)

**Goal**: Asignar ordenadamente las 8 semillas y herramientas desbloqueadas para los niveles 1 al 8 con sus textos tácticos exactos y texturas correspondientes.

**Independent Test**: Verificar mediante prueba que cada nivel del 1 al 8 retorne su respectiva semilla (Recordadora, Protego, Accio, Ron, Escoba, Hermione, McGonagall, Dumbledore) con las cadenas literales exactas.

### Implementation for User Story 2

- [X] T010 [P] [US2] Mapear los niveles 1 al 8 en `reward_catalog.gd` con las texturas `res://Images/seed_*.png` y `res://Images/elder_wand.png`, junto con sus respectivas constantes textuales literales exactas (`LEVEL_1_DESC_TEXT` a `LEVEL_8_DESC_TEXT`).
- [X] T011 [US2] Conectar en `level.gd` la consulta de `RewardCatalog.get_reward_for_level(level_number)` en el flujo de victoria para abastecer dinámicamente los datos de la recompensa para los niveles 1 al 8.

**Checkpoint**: Los niveles 1 al 8 exhiben sus respectivas semillas y textos descriptivos con fidelidad exacta.

---

## Phase 5: User Story 3 - Casos Especiales de los Niveles Finales (Niveles 9 y 10) (Priority: P3)

**Goal**: Omitir la cinemática de recompensa en el Nivel 9 (transición directa a victoria) y presentar el trofeo de la Piedra Filosofal en el Nivel 10 tras vencer a Quirrell con su mensaje conmemorativo final.

**Independent Test**: Superar el Nivel 9 y comprobar que pasa de inmediato a `LevelEndPanel` sin cinemática; derrotar a Quirrell en el Nivel 10 y verificar que se presente el trofeo de la Piedra Filosofal con el texto final de agradecimiento.

### Implementation for User Story 3

- [X] T012 [P] [US3] Configurar en `reward_catalog.gd` el retorno de `null` para el Nivel 9 y registrar la entrada del Nivel 10 asociando `Images/trophy_philosophers_stone.png` con la constante literal `LEVEL_10_DESC_TEXT`.
- [X] T013 [US3] Adaptar en `level.gd` la condición de victoria para que el Nivel 9 omita la pantalla de recompensa directamente y el Nivel 10 invoque el trofeo conmemorativo final de la Piedra Filosofal.

**Checkpoint**: Todos los casos especiales (Nivel 9 sin recompensa y Nivel 10 trofeo final) funcionando armónicamente.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verificación cruzada, calidad de código y adherencia a las normas de la cátedra.

- [X] T014 [P] Implementar el script de prueba headless en `tests/test_reward_unlock.gd` para verificar el mapeo de los 10 niveles, los textos exactos, la omisión del Nivel 9 y las señales emitidas.
- [X] T015 Ejecutar la validación completa con `tools/check_rules.gd` y la prueba headless para asegurar que ningún método supere las 15 líneas y el tipado estricto sea del 100%.

---

## Dependencies & Execution Order

### Phase Dependencies

```text
Phase 1: Setup (T001, T002)
   ↓
Phase 2: Foundational (T003, T004)
   ↓
Phase 3: User Story 1 (T005 → T006 → T007 → T008 → T009) [MVP]
   ↓
Phase 4: User Story 2 (T010 → T011)
   ↓
Phase 5: User Story 3 (T012 → T013)
   ↓
Phase 6: Polish & Quality (T014, T015)
```

### Parallel Opportunities

- **Setup**: T001 (sprite gema) y T002 (GameManager) pueden ejecutarse en paralelo.
- **Foundational**: T003 (catálogo GDScript) y T004 (escena TSCN) pueden prepararse en paralelo.
- **Historias de Usuario**:
  - T010 [US2] y T012 [US3] pueden redactarse en paralelo dentro de `reward_catalog.gd`.
  - T014 (prueba headless) puede escribirse en paralelo con la integración final.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Completar Setup (T001, T002) y Foundational (T003, T004).
2. Completar User Story 1 (T005..T009).
3. **VALIDAR MVP**: Probar cinemática en Nivel 1 (giro, zoom, salto con clic, transición a `LevelEndPanel`).

### Incremental Delivery

1. MVP funcional → cinemática probada y validada en Nivel 1.
2. US2 → incorporar mapeo completo para niveles 1 al 8.
3. US3 → añadir omisión del Nivel 9 y trofeo conmemorativo del Nivel 10.
4. Polish → pruebas headless y verificación de reglas de la cátedra con `check_rules.gd`.
