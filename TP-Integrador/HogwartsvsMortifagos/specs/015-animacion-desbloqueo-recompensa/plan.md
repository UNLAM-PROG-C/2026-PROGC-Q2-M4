# Implementation Plan: Animación de Desbloqueo de Recompensa al Ganar Nivel

**Branch**: `015-animacion-desbloqueo-recompensa` | **Date**: 2026-10-12 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/015-animacion-desbloqueo-recompensa/spec.md`

## Summary

Implementar una secuencia cinemática a pantalla completa con fondo difuminado (blur) que se active al ganar un nivel por primera vez. La semilla o trofeo desbloqueado surge desde el centro de la pantalla mediante un zoom in giratorio animado vía `Tween`, colocándose en su posición de reposo con su texto descriptivo táctico estático debajo y un botón interactivo de confirmación ("Continuar"). Al presionar "Continuar", se despliega el panel habitual de victoria (`LevelEndPanel`). La cinemática puede saltarse de inmediato si el jugador hace clic en pantalla durante el giro. Los niveles 1 al 8 desbloquean a sus aliados/herramientas correspondientes, el nivel 9 pasa directo a victoria (sin recompensa), y el nivel 10 presenta el trofeo de la Piedra Filosofal con su mensaje final conmemorativo.

## Technical Context

**Language/Version**: GDScript 2.0 (Godot Engine 4.7.2 stable) con tipado estático estricto en todas las variables, constantes, parámetros y retornos.

**Primary Dependencies**: Motor Godot 4.7.2 (nodos `CanvasLayer`, `Control`, `ColorRect`, `TextureRect`, `Label`, `Button`, y clase `Tween`).

**Storage**: Singleton de sesión `GameManager` (`game_manager.gd`) para registrar las recompensas reclamadas (`claimed_rewards: Dictionary[int, bool]`) y evitar la repetición de cinemáticas al rejugar niveles ya superados.

**Testing**: Linter formal de la cátedra (`tools/check_rules.gd`) y script de pruebas headless (`tests/test_reward_unlock.gd`) ejecutados mediante `Godot_v4.7.2-stable_win64.exe --headless`.

**Target Platform**: Windows Desktop, resolución objetivo 1920x1080, renderizador Compatibility.

**Project Type**: Videojuego 2D (estrategia / defensa de torres).

**Performance Goals**: 60 FPS estables durante la cinemática de `Tween`, salto instantáneo (< 16ms) al pulsar clic sin bloqueos ni retrasos.

**Constraints**:
- Ninguna función debe superar las 15 líneas de código (regla §4 de `AGENTS.md`).
- Prohibido el uso de números o strings mágicos embebidos (constantes explícitas con sufijo `_TEXT` para cadenas de jugador, regla §6).
- Todo identificador y comentario en inglés, textos visibles al jugador en español (regla §7 y Principio III).
- Arquitectura basada estrictamente en Nodos y Escenas (Principio II).
- No instalar addons ni modificar `project.godot`.

**Scale/Scope**: 1 escena nueva (`reward_unlock_screen.tscn` + `reward_unlock_screen.gd`), 1 catálogo de datos (`reward_catalog.gd`), 1 nuevo activo gráfico placeholder (`trophy_philosophers_stone.png`), extensiones en `level.gd` y `game_manager.gd`, 1 script de prueba headless.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Justificación / Cumplimiento |
|---|---|---|
| **I. Motor y lenguaje** | **PASS** | Godot 4, renderizador Compatibility, GDScript con tipado estricto explícito en cada variable, parámetro y función. |
| **II. Arquitectura de Nodos y Escenas** | **PASS** | La cinemática reside en su propia escena desacoplada `reward_unlock_screen.tscn` con script `reward_unlock_screen.gd`. |
| **III. Vocabulario temático e idioma** | **PASS** | Identificadores técnicos en inglés (`RewardUnlockScreen`, `RewardCatalog`, `reward_dismissed`). Textos para el jugador en español con sufijo `_TEXT`. |
| **IV. Colisiones por áreas y grupos** | **PASS** | La pantalla es un elemento de interfaz CanvasLayer/Control. No interfiere con capas ni grupos de combate existentes. |
| **V. Estado de interfaz sincronizado** | **PASS** | La interfaz manipula únicamente propiedades directas del Scene Tree mediante señales y Tweens de Godot. |
| **Reglas Cátedra: Funciones $\le 15$ líneas** | **PASS** | Cada método en `reward_unlock_screen.gd`, `reward_catalog.gd`, `game_manager.gd` y `level.gd` se estructura en bloques atómicos $\le 15$ líneas. |
| **Reglas Cátedra: Cero números mágicos** | **PASS** | Dimensiones, duraciones, ángulos y escalas definidos mediante constantes descriptivas. |

## Project Structure

### Documentation (this feature)

```text
specs/015-animacion-desbloqueo-recompensa/
├── plan.md              # Plan de implementación y contexto técnico
├── research.md          # Decisiones de investigación (Phase 0)
├── data-model.md        # Definición de entidades y datos (Phase 1)
├── quickstart.md        # Guía y comandos de validación (Phase 1)
├── contracts/
│   └── reward-screen-contract.md  # Contrato de interfaz y constantes de texto
└── checklists/
    └── requirements.md  # Checklist de calidad de la especificación
```

### Source Code (repository root)

```text
# Componentes de Recompensa
reward_unlock_screen.tscn    # Escena desacoplada de la pantalla cinemática
reward_unlock_screen.gd      # Script de la cinemática, shader de desenfoque y eventos de salto
reward_catalog.gd            # Catálogo tipado que asocia nivel con textura y descripción

# Activos Gráficos
Images/
└── trophy_philosophers_stone.png  # Trofeo conmemorativo de la Piedra Filosofal (Nivel 10)

# Integración Existente
game_manager.gd              # Autoload: gestión de persistencia de recompensas reclamadas
level.gd                     # Nivel: orquestación de victoria, llamada a RewardUnlockScreen y LevelEndPanel

# Pruebas Automatizadas
tests/
└── test_reward_unlock.gd    # Prueba headless para validar textos, catálogo y señales
```

**Structure Decision**: Arquitectura modular desacoplada en la raíz del proyecto alineada con la convención existente de Godot (`level.gd`, `game_manager.gd`, `accio_button.gd`). La pantalla cinemática se modela como una escena autocontenida instanciada dinámicamente sobre la capa HUD.

## Complexity Tracking

> Ninguna violación a la constitución. El diseño se adhiere 100% a las reglas de la cátedra y del proyecto.
