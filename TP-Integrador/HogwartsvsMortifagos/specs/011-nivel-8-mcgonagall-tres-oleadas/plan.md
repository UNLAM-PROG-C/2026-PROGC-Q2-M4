# Implementation Plan: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]` | **Date**: 2026-10-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/011-nivel-8-mcgonagall-tres-oleadas/spec.md`

## Summary

Implementación integral del Nivel 8 del juego:
1. **McGonagall (`McGonagall`)**: Nueva aliada de DPS definitivo (200 snitches, 300 HP) con disparo en ráfaga de 4 proyectiles secuenciales (0.15s entre disparos) y tiempo de recarga base de 1.5s entre ráfagas completas, reutilizando el `ProjectilePool` común.
2. **Carta de McGonagall (`mcgonagall_card.tres`)**: Recurso de datos para el HUD con costo de 200 snitches, tiempo de recarga de 7.5s y escena `mcgonagall.tscn`.
3. **Gestión de 3 Grandes Oleadas en `level.gd`**:
   - Activación de `is_special_level = true` para soportar 2 oleadas intermedias masivas y 1 oleada final.
   - Presupuesto de 45 enemigos regulares con hitos de oleadas intermedias en las bajas 15 (~33%) y 30 (~66%).
   - Textos de advertencia diferenciados: `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` para las oleadas 1 y 2, y `"¡OLEADA FINAL!"` para la tercera oleada.
4. **Nivel 8 (`level_8.tscn`)**: Escenario completo con 5 carriles activos, 5 Dementores defensivos, HUD expandido con 9 cartas (Harry, Snitch Box, Ron, Recordadora, Protego, Escoba, Hermione, McGonagall y Accio), oleadas mixtas de 4 tipos de enemigos (Alumno, Draco, Protego, Prefecto) y desbloqueo del Nivel 9 en el Mapa del Merodeador al ganar.

## Technical Context

**Language/Version**: GDScript en Godot 4.x (renderizador Compatibility).

**Primary Dependencies**: Nodos core de Godot 4 (`Area2D`, `Sprite2D`, `Timer`, `Marker2D`, `TileMapLayer`, `Button`, `Label`).

**Storage**: Recursos nativos de Godot (`.tscn`, `.tres`, `.gd`, `.png`).

**Testing**: Escenas ejecutables de validación con Godot Engine CLI y validación manual paso a paso.

**Target Platform**: Desktop (Resolución objetivo 1920x1080).

**Project Type**: Juego 2D Tower Defense (Hogwarts vs Mortífagos).

**Performance Goals**: 60 FPS estables; reutilización de proyectiles mediante `ProjectilePool` sin asignación dinámica de memoria durante ráfagas de 4 disparos por ciclo.

**Constraints**:
- Regla de la cátedra: Ningún método puede superar las 15 líneas de código.
- Identificadores, métodos, señales y comentarios estrictamente en inglés.
- Textos visibles para el jugador en español bajo constantes con sufijo `_TEXT`.
- Tipado estático estricto en el 100% de variables, constantes, parámetros y retornos.
- Indentación de 2 espacios. Prohibido el uso de números mágicos.
- No modificar `project.godot` sin autorización expresa.

**Scale/Scope**: 1 nueva clase aliada (`McGonagall`), 1 escena de aliada (`mcgonagall.tscn`), 1 recurso de carta (`mcgonagall_card.tres`), 1 sprite (`mcgonagall.png`), 1 escena de nivel (`level_8.tscn`), actualización de textos de oleadas en `level.gd`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Motor y lenguaje**: Godot 4 Compatibility y GDScript con tipado estático estricto en el 100% de declaraciones. -> **PASS**
- **II. Arquitectura de Nodos y Escenas**: Cada entidad (`McGonagall`, `Level8`) posee su propia escena `.tscn` y script `.gd`. Las entidades se comunican mediante señales y no acoplan jerarquías internas. -> **PASS**
- **III. Vocabulario temático e idioma del código**: Nombres en inglés acordes al diccionario temático (`McGonagall`, `snitch`). Textos UI en español con constante sufijo `_TEXT`. -> **PASS**
- **IV. Colisiones por áreas y grupos**: Se utilizan nodos `Area2D` y pertenencia al grupo `allies`. Sin comparaciones frágiles por nombres de nodos. -> **PASS**
- **V. Estado de interfaz**: Compatibilidad y lectura del Scene Tree de Godot. -> **PASS**
- **Reglas Cátedra**: Métodos de 15 líneas o menos, indentación de 2 espacios, cero números mágicos. -> **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/011-nivel-8-mcgonagall-tres-oleadas/
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
# Entidades Aliadas
mcgonagall.gd             # Script de McGonagall con lógica de temporizadores para ráfaga cuádruple
mcgonagall.tscn           # Escena de McGonagall (Area2D, Sprite2D, ShootTimer, BurstTimer, ShootPoint)
mcgonagall_card.tres      # Recurso AllyCard (display_name "McGonagall", costo 200, cooldown 7.5)
Images/mcgonagall.png     # Sprite visual de McGonagall (130x130)

# Lógica del Nivel y Oleadas
level.gd                  # Soporte de texto "¡OLEADA FINAL!" para la tercera oleada
level_8.tscn              # Escena completa del Nivel 8 (5 filas, 45 enemigos, 3 oleadas masivas, 9 cartas)
```

**Structure Decision**: Arquitectura plana de nodos y escenas en la raíz del proyecto, idéntica a la estructura establecida en los niveles 1 al 7.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| *Ninguna* | Cumplimiento estricto de principios arquitectónicos sin violaciones ni desvíos. | N/A |
