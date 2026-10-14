# Implementation Plan: Nivel 10 - Batalla contra Jefe Final (Quirrell / Voldemort)

**Branch**: `014-nivel-10-quirrell-boss` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/014-nivel-10-quirrell-boss/spec.md`

## Summary

Desarrollar e integrar el Nivel 10, la batalla final de Hogwarts vs Mortífagos contra el Profesor Quirrell / Voldemort:
1. **Quirrell (`quirrell.tscn` / `quirrell.gd`)**: Entidad jefe final con 36.000 HP (equivalente a 20 impactos de Recordadora o Escoba) posicionada estacionariamente en la columna 8. Cada 20 segundos se teletransporta aleatoriamente a otra fila activa dejando una sombra en sus pies y aplastando a cualquier aliado en la celda de destino. En Fase 1 (> 50% HP) viste el turbante morado e invoca 1 Sombra cada 15s. Al caer a $\le 50\%$ HP (18.000 HP), el turbante cae revelando la nuca de Voldemort, reduciendo el ciclo de invocación a 8s con un 10% de probabilidad de ataque masivo simultáneo en las 5 líneas.
2. **Sombra (`shadow_enemy.tscn` / `shadow_enemy.gd`)**: Enemigo espectral rápido (48 px/s, 1.5x de velocidad común) con 200 HP y 30 de daño/segundo, perteneciente al grupo `enemies`.
3. **Barra de Vida del Jefe (`boss_health_bar.tscn` / `boss_health_bar.gd`)**: Componente de interfaz en la parte superior del HUD que se sincroniza en tiempo real con la salud de Quirrell.
4. **Nivel 10 (`level_10.tscn` / `level.gd`)**: Escenario final con fondo de piedra gris y raíces/tentáculos (`final_background.png`), 5 filas activas, ocultando el reloj de oleadas y disparando la victoria final y limpieza del tablero cuando Quirrell llega a 0 HP.

## Technical Context

**Language/Version**: GDScript en Godot 4.x (renderizador Compatibility).

**Primary Dependencies**: Nodos core de Godot 4 (`Area2D`, `Sprite2D`, `TextureProgressBar`, `Timer`, `CollisionShape2D`, `Marker2D`, `TileMapLayer`, `Button`, `Label`).

**Storage**: Recursos nativos de Godot (`.tscn`, `.tres`, `.gd`, `.png`, `.gdshader`).

**Testing**: Escenas ejecutables de validación con Godot Engine, validación estricta de `tools/check_rules.gd`, y escenarios manuales descritos en `quickstart.md`.

**Target Platform**: Desktop (Resolución objetivo 1920x1080).

**Project Type**: Juego 2D Tower Defense (Hogwarts vs Mortífagos).

**Performance Goals**: 60 FPS estables; teletransporte instantáneo sin recolección de basura ni fugas de memoria; invocación de hasta 5 sombras simultáneas sin caída de fotogramas.

**Constraints**:
- Regla de la cátedra: Ningún método puede superar las 15 líneas de código.
- Identificadores, métodos, señales y comentarios estrictamente en inglés.
- Textos visibles para el jugador en español bajo constantes con sufijo `_TEXT`.
- Tipado estático estricto en el 100% de variables, constantes, parámetros y retornos.
- Indentación con tabulaciones consistentes del proyecto. Prohibido el uso de números mágicos.
- Cargar texturas de Quirrell explícitamente desde `res://Images/quirrell.png`, `res://Images/quirrell_turban.png`, `res://Images/character_shadow.png` y `res://Images/final_background.png`.
- No modificar `project.godot` sin autorización previa.

**Scale/Scope**: 1 nueva escena y script de jefe (`quirrell.tscn`, `quirrell.gd`), 1 nueva escena y script de esbirro (`shadow_enemy.tscn`, `shadow_enemy.gd`), 1 componente de UI (`boss_health_bar.tscn`, `boss_health_bar.gd`), 1 escena de nivel (`level_10.tscn`), y adaptación en `level.gd` para soporte del modo jefe.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Motor y lenguaje**: Godot 4 Compatibility y GDScript con tipado estático estricto en el 100% de declaraciones. -> **PASS**
- **II. Arquitectura de Nodos y Escenas**: Cada entidad (`Quirrell`, `ShadowEnemy`, `BossHealthBar`, `Level10`) posee su propia escena `.tscn` y script `.gd`. Las entidades se comunican mediante señales (`health_changed`, `defeated`, `shadow_spawn_requested`) sin violar encapsulamiento. -> **PASS**
- **III. Vocabulario temático e idioma del código**: Nombres en inglés acordes al diccionario temático (`Quirrell`, `Shadow`, `snitch`). Textos UI en español con constante sufijo `_TEXT`. -> **PASS**
- **IV. Colisiones por áreas y grupos**: Se utilizan nodos `Area2D` y pertenencia al grupo `enemies`. Sin comparaciones frágiles por nombres de nodos. -> **PASS**
- **V. Estado de interfaz**: Compatibilidad y lectura del Scene Tree de Godot. -> **PASS**
- **Reglas Cátedra**: Métodos de 15 líneas o menos, indentación consistente, cero números mágicos. -> **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/014-nivel-10-quirrell-boss/
├── plan.md              # Este archivo (plan de implementación)
├── research.md          # Phase 0: Decisiones arquitectónicas y justificaciones
├── data-model.md        # Phase 1: Entidades, componentes y estados
├── quickstart.md        # Phase 1: Guía de ejecución y validación
├── contracts/
│   └── node-interfaces.md # Phase 1: Interfaces, señales y contratos de nodos
├── checklists/
│   └── requirements.md  # Checklist de calidad de requerimientos (16/16)
└── tasks.md             # Tareas ejecutables (generado por /speckit-tasks)
```

### Source Code (repository root)

```text
# Entidades del Jefe y Esbirro
quirrell.tscn                     # Escena del Jefe Final Quirrell / Voldemort
quirrell.gd                       # Script con lógica de teletransporte, fases y daño
shadow_enemy.tscn                 # Escena del enemigo Sombra invocado
shadow_enemy.gd                   # Script de la Sombra (extends Enemy, speed = 48.0)

# Interfaz de Usuario
boss_health_bar.tscn              # Componente de barra de vida superior del jefe
boss_health_bar.gd                # Controlador de la barra de vida del jefe

# Nivel 10
level_10.tscn                     # Escena del nivel final con fondo final_background.png
level.gd                          # Controlador de nivel adaptado para lógica de jefe

# Assets
Images/final_background.png       # Fondo de la arena final de piedra gris
Images/quirrell.png               # Sprite base de Quirrell / rostro de Voldemort
Images/quirrell_turban.png        # Sprite del turbante morado superpuesto
Images/character_shadow.png       # Sombra de pies para teletransporte e invocación
```

**Structure Decision**: El proyecto utiliza la arquitectura estándar de Godot en la raíz del repositorio, agrupando cada entidad en su par `.tscn`/`.gd`, reutilizando `level.gd` mediante composición de flags para no duplicar lógica de colocación de aliados ni de recolección de snitches.

## Complexity Tracking

> *Sin violaciones constitucionales. Todas las reglas fueron respetadas sin excepciones.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Ninguna | N/A | N/A |
