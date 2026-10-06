# Implementation Plan: Nivel 6 - Escoba y Alumno con Protego

**Branch**: `[009-nivel-6-escoba-protego]` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/009-nivel-6-escoba-protego/spec.md`

## Summary

Desarrollar el Nivel 6 del juego introduciendo mecánicas de control de masas para líneas completas con la nueva aliada "Escoba" (`broomstick.tscn` / `broomstick.gd`), con coste de 125 snitches, recarga muy lenta (25.0 s), daño masivo de barrido horizontal de 1800.0 puntos a lo largo de toda la fila seleccionada ($X=0$ a $X \ge 1950$), liberando de inmediato la celda plantada. Implementar además el nuevo enemigo blindado multiparte "Alumno Slytherin con Protego" (`protego_student.tscn` / `protego_student.gd`) con un escudo mágico de 300.0 HP (degradado en 3 estados visuales mediante los frames de `res://Images/protego.png`), salud base de 200.0 HP (`res://Images/slytherin_protego.png` y `res://Images/slytherin.png`), daño de desborde y modos duales de ataque (embestida con escudo vs. mordida sin escudo). Por último, ensamblar la escena `level_6.tscn` con 5 filas activas, 5 Dementores defensivos, mazo completo de 6 cartas más la herramienta Accio, cuota de 30 enemigos y desbloqueo del Nivel 7.

## Technical Context

**Language/Version**: Godot 4.x, GDScript (tipado estático estricto)

**Primary Dependencies**: Godot Engine (Compatibility renderer)

**Storage**: N/A

**Testing**: Pruebas manuales independientes guiadas por [quickstart.md](./quickstart.md) en el editor de Godot

**Target Platform**: Desktop (1920x1080)

**Project Type**: Videojuego 2D (Godot Project)

**Performance Goals**: Desplazamiento fluido de la Escoba a 600 px/s sin bloqueos en la cuadrícula, detección de colisiones de barrido en un único pase por enemigo (`_damaged_enemies`), transiciones de frames de escudo y sprites sin caídas de framerate (>60 fps).

**Constraints**:
- Tamaño de funciones: ningún método debe superar las 15 líneas (Regla 4 de la cátedra en `AGENTS.md`).
- Tipado estático estricto en todas las variables, constantes, parámetros, señales y retornos.
- Modularidad: una escena y un script por entidad (`broomstick.tscn` con `broomstick.gd`, `protego_student.tscn` con `protego_student.gd`).
- Grupos: pertenencia estricta a los grupos reservados `allies` (`Groups.ALLIES`) y `enemies` (`Groups.ENEMIES`), sin comparar por nombres de nodos.
- Rutas de assets: `res://Images/broomstick.png`, `res://Images/protego.png`, `res://Images/slytherin_protego.png`, `res://Images/slytherin.png`.
- Restricciones de cambios: no instalar addons ni modificar `project.godot`.

**Scale/Scope**:
- 1 nueva entidad aliada (`broomstick.tscn`, `broomstick.gd`).
- 1 nuevo recurso de carta (`broomstick_card.tres`).
- 1 nueva entidad enemiga multiparte (`protego_student.tscn`, `protego_student.gd`).
- 1 nueva escena de nivel (`level_6.tscn`).
- Modificaciones puntuales en `level.gd` (soporte de plantado de Escoba con liberación inmediata de celda en métodos `<= 15` líneas).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Principio I (Motor y lenguaje)**: Godot 4, Compatibility renderer, GDScript con tipado estático estricto verificado en todas las firmas y variables.
- [x] **Principio II (Arquitectura de Nodos y Escenas)**: Escoba y Alumno con Protego tienen escenas y scripts independientes (`broomstick.tscn` y `protego_student.tscn`). Sub-componentes visuales como `$ShieldSprite` organizados como nodos hijos explícitos.
- [x] **Principio III (Vocabulario temático e idioma)**: Identificadores técnicos en inglés (`Broomstick`, `ProtegoStudent`, `shield_health`, `sweep_damage`), textos visibles en español con temática mágica ("Escoba", "Alumno con Protego", "Snitches").
- [x] **Principio IV (Colisiones y grupos)**: Detección por `Area2D` y señales (`area_entered`). La Escoba pertenece a `allies` y detecta `enemies`. El Alumno con Protego pertenece a `enemies` y detecta `allies`.
- [x] **Principio V (Sincronización de interfaz)**: No se alteran propiedades globales sin verificar la jerarquía de la escena.
- [x] **Reglas de la Cátedra (AGENTS.md)**: Métodos modulares de $\le 15$ líneas, constantes descriptivas sin números mágicos, llaves estilo Allman en caso de requerirse.

## Project Structure

### Documentation (this feature)

```text
specs/009-nivel-6-escoba-protego/
├── spec.md              # Especificación funcional con clarificaciones resueltas
├── plan.md              # Este plan de implementación (/speckit-plan)
├── research.md          # Decisiones técnicas y patrones (/speckit-plan)
├── data-model.md        # Estados y modelo de datos (/speckit-plan)
├── quickstart.md        # Guía de validación y pruebas (/speckit-plan)
├── contracts/           # Contratos públicos de nodos (/speckit-plan)
│   └── node-interfaces.md
└── checklists/
    └── requirements.md  # Validación de calidad de la especificación
```

### Source Code (repository root)

```text
/ (Raíz del proyecto)
├── broomstick.gd        # Script de la aliada Escoba (hereda de Ally, barrido horizontal)
├── broomstick.tscn      # Escena de la Escoba (Area2D, Sprite2D, CollisionShape2D)
├── broomstick_card.tres # Recurso AllyCard para la Escoba (125 snitches, cooldown 25.0s)
├── protego_student.gd   # Script del Alumno con Protego (Enemy con absorción de escudo)
├── protego_student.tscn # Escena del Alumno con Protego (Sprite2D y ShieldSprite hijo)
├── level.gd             # Manejador modular para la liberación de celda al plantar Broomstick
├── level_6.tscn         # Escena del Nivel 6 (5 líneas, mazo completo de 6 cartas y Accio)
```

**Structure Decision**: Se mantiene la arquitectura plana de Godot del proyecto. La Escoba se especializa como `Ally` con barrido cinemático y liberación de celda, el Alumno con Protego se especializa como `Enemy` con escudo visual jerárquico, y `level_6.tscn` instancia y orquesta las mecánicas.

## Complexity Tracking

| Violación / Decisión | Razón de necesidad | Alternativa más simple descartada porque |
| :--- | :--- | :--- |
| Ninguna | N/A | N/A |
