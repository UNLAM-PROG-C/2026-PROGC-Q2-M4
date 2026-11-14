# Implementation Plan: Sistema Híbrido de Oleadas por Bajas y Medidor Visual de Progreso

**Branch**: `013-wave-progression-meter` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/013-wave-progression-meter/spec.md`

## Summary

Refactorizar el sistema de progresión y oleadas en *Hogwarts vs. Mortífagos* desacoplando el disparo de las Grandes Oleadas (intermedia y final) del paso del tiempo y asociándolo estrictamente a la acumulación de bajas en combate (`Enemy.defeated`). El temporizador de spawn de fondo (`enemy_spawn_timer`) se mantendrá corriendo para acelerar la cadencia de enemigos comunes y escalar la dificultad ambiental. Adicionalmente, se normalizarán a inglés los assets gráficos del medidor (`wave_meter_2_waves.png` y `wave_meter_3_waves.png`) y se creará el componente HUD `WaveProgressBar` (`TextureProgressBar`) en la esquina inferior izquierda con llenado vertical (`Bottom to Top`) en líquido rojo proporcional al total acumulado de bajas del nivel.

## Technical Context

**Language/Version**: GDScript en Godot 4.3 (Compatibility renderer).  
**Primary Dependencies**: Godot 4 Core Engine (Nodos 2D, CanvasLayer, TextureProgressBar, Timer, Thread/Mutex de WaveDirector).  
**Storage**: N/A (Estado de partida en memoria y GameManager).  
**Testing**: Validación visual y ejecución interactiva/headless de escenarios (`level_1.tscn` a `level_9.tscn`) mediante Godot CLI.  
**Target Platform**: Desktop (Windows, 1920x1080).  
**Project Type**: Videojuego 2D (Clon temático de Plants vs. Zombies).  
**Performance Goals**: 60 FPS estables sin pausas en el hilo principal durante el recuento de bajas o actualización del HUD.  
**Constraints**:
- Reglas de cátedra (`AGENTS.md`): Funciones <= 15 líneas, tipado estático estricto, 2 espacios de indentación, identificadores y comentarios en inglés, textos del jugador en español, sin números mágicos.
- Principios de Constitución: Arquitectura estricta de Nodos y Escenas, colisiones por Area2D/grupos.  
**Scale/Scope**: Refactor de `level.gd`, 9 niveles de juego (`level_1.tscn` a `level_9.tscn`), creación de `wave_progress_bar.tscn` / `wave_progress_bar.gd` y normalización de 2 recursos gráficos en `Images/`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Principle I (Engine & Strict Typing)**: PASS. Godot 4 Compatibility y tipado estático estricto en todas las variables, parámetros, señales y retornos.
- **Principle II (Node and Scene Architecture)**: PASS. El medidor es un componente autónomo (`wave_progress_bar.tscn` + `wave_progress_bar.gd`) instanciado en el HUD.
- **Principle III (Thematic Vocabulary & Language)**: PASS. Todo identificador y archivo en inglés (`wave_meter_2_waves.png`, `wave_meter_3_waves.png`, `WaveProgressBar`). Textos del jugador en español en constantes `_TEXT`.
- **Principle IV (Collisions and Groups)**: PASS. El recuento se basa exclusivamente en señales `defeated` de enemigos al morir con salud <= 0, no por detección de nombres.
- **Principle V (Engine State Sync)**: PASS. El estado visual se sincroniza directamente con las propiedades del nodo `TextureProgressBar`.
- **AGENTS.md (Lines limit & no magic numbers)**: PASS. Todas las funciones respetan el límite de 15 líneas y los umbrales se parametrizan en constantes descriptivas y `@export`.

## Project Structure

### Documentation (this feature)

```text
specs/013-wave-progression-meter/
├── spec.md              # Especificación funcional y de requisitos
├── plan.md              # Este archivo (Plan de implementación)
├── research.md          # Fase 0: Decisiones de arquitectura y umbrales por nivel
├── data-model.md        # Fase 1: Entidades, máquina de estados y modelos de datos
├── contracts/           # Fase 1: Contratos de nodos e interfaces
│   └── node-interfaces.md
├── quickstart.md        # Fase 1: Guía paso a paso de validación
└── checklists/
    └── requirements.md  # Checklist de calidad de requisitos
```

### Source Code Layout

```text
Images/
├── wave_meter_2_waves.png        # Marco de 2 oleadas (renombrado de Personajes_Medidor 2 oleadas.png)
├── wave_meter_3_waves.png        # Marco de 3 oleadas (renombrado de Personajes_Medidor 3 oleadas.png)
└── wave_meter_red_progress.png   # Textura de líquido rojo para el progreso

wave_progress_bar.tscn            # Escena del medidor visual (TextureProgressBar)
wave_progress_bar.gd              # Script del medidor visual (<= 15 líneas por método)
level.gd                          # Refactor del gestor de oleadas por bajas y aceleración temporal
level_1.tscn ... level_7.tscn     # Configuración de 2 oleadas y umbrales respectivos
level_8.tscn ... level_9.tscn     # Configuración de 3 oleadas y umbrales respectivos
```

**Structure Decision**: El medidor de progreso se implementa como escena independiente para permitir instanciación limpia dentro de `HUD` en cada nivel, manteniendo desacoplada la presentación visual de la lógica de orquestación de `level.gd`.

## Complexity Tracking

> No se detectaron violaciones constitucionales ni desvíos injustificados.
