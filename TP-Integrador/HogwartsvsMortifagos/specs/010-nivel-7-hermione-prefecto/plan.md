# Implementation Plan: Nivel 7 - Hermione y Prefecto Slytherin

**Branch**: `[010-nivel-7-hermione-prefecto]` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/010-nivel-7-hermione-prefecto/spec.md`

## Summary

Implementación integral del Nivel 7 del juego:
1. **Hermione (`Hermione`)**: Nueva aliada (125 snitches, 300 HP) con cadencia de 1.5s que dispara hechizos azules con efecto de ralentización.
2. **Mecánica de Ralentización (`Enemy`)**: Extensión de la clase base `Enemy` con `apply_slow(factor, duration)` para reducir en un 30% (factor 0.70) la velocidad de movimiento y de ataque por 5.0 segundos con feedback visual celeste.
3. **Prefecto Slytherin (`SlytherinPrefect`)**: Nuevo enemigo a distancia (200 HP) que camina y se detiene cada 3.5 segundos para disparar proyectiles si detecta aliados en su fila a la izquierda.
4. **Proyectil Enemigo (`EnemyProjectile`)**: Ataque oscuro animado en bucle con la grilla `slytherin_shot.png` (4 fotogramas) que viaja hacia la izquierda e inflige 20 de daño a aliados.
5. **Nivel 7 (`level_7.tscn`)**: Escenario de 5 líneas completas con 5 Dementores, mazo de 8 cartas, oleadas mixtas y desbloqueo del Nivel 8.

## Technical Context

**Language/Version**: GDScript en Godot 4.x (renderizador Compatibility).

**Primary Dependencies**: Godot 4 Engine core nodes (`Area2D`, `Sprite2D`, `Timer`, `TileMapLayer`).

**Storage**: Recursos nativos de Godot (`.tscn`, `.tres`, `.gd`).

**Testing**: Escenas ejecutables de prueba y validación manual/GUT.

**Target Platform**: Desktop (Resolución objetivo 1920x1080).

**Project Type**: Juego 2D Tower Defense (Hogwarts vs Mortífagos).

**Performance Goals**: 60 FPS estables; reutilización de proyectiles mediante `ProjectilePool`.

**Constraints**:
- Regla de la cátedra: Ningún método puede superar las 15 líneas de código.
- Identificadores, métodos, señales y comentarios estrictamente en inglés.
- Textos visibles en español bajo constantes con sufijo `_TEXT`.
- Tipado estático estricto en todas las variables, constantes, parámetros y retornos.
- Indentación de 2 espacios. Prohibido el uso de números mágicos.

**Scale/Scope**: 1 nueva clase aliada, 1 nueva clase enemiga, 1 nuevo proyectil enemigo, 1 recurso de carta, 1 escena de nivel, extensiones en `enemy.gd`, `projectile.gd`, `projectile_pool.gd` y `lane.gd`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Motor y lenguaje**: Godot 4 Compatibility y GDScript con tipado estático estricto en el 100% de declaraciones. -> **PASS**
- **II. Arquitectura de Nodos y Escenas**: Cada entidad (`Hermione`, `SlytherinPrefect`, `EnemyProjectile`) cuenta con su propia escena `.tscn` y script `.gd`. -> **PASS**
- **III. Vocabulario temático e idioma del código**: Nombres en inglés acordes al diccionario temático (`Hermione`, `SlytherinPrefect`, `snitch`). Textos UI en español con `_TEXT`. -> **PASS**
- **IV. Colisiones por áreas y grupos**: Se utilizan nodos `Area2D` y grupos (`allies`, `enemies`, `spells`/`enemy_projectiles`). Sin chequeo frágil por nombres de nodos. -> **PASS**
- **V. Estado de interfaz**: Compatibilidad y sincronización con el Scene Tree de Godot. -> **PASS**
- **Reglas Cátedra**: Métodos de menos de 15 líneas, 2 espacios, cero números mágicos. -> **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/010-nivel-7-hermione-prefecto/
├── plan.md              # Este archivo
├── research.md          # Decisiones de diseño técnico y justificaciones
├── data-model.md        # Definición formal de entidades y estados
├── quickstart.md        # Guía paso a paso para validación de la feature
├── contracts/
│   └── node-interfaces.md # Contratos de nodos, scripts y escenas
├── checklists/
│   └── requirements.md  # Checklist de calidad de requerimientos
└── tasks.md             # Tareas ejecutables (generado por /speckit-tasks)
```

### Source Code (repository root)

```text
# Entidades Aliadas
hermione.gd               # Lógica de disparo y ralentización de Hermione
hermione.tscn             # Escena de Hermione
hermione_card.tres        # Recurso de carta para el HUD (costo 125, recarga 7.5s)

# Entidades Enemigas
slytherin_prefect.gd      # Lógica de ataque a distancia del Prefecto Slytherin
slytherin_prefect.tscn    # Escena del Prefecto Slytherin (usa slytherin_protego sin escudo)

# Proyectiles y Efectos
enemy_projectile.gd       # Lógica del proyectil enemigo animado
enemy_projectile.tscn     # Escena con Sprite2D de 4 frames (slytherin_shot.png)
projectile.gd             # Soporte para flag slows y tinte de color
projectile_pool.gd        # Soporte para acquire_projectile con configuración ralentizadora

# Scripts Base y Utilidades
enemy.gd                  # Estado de ralentización apply_slow() y recuperación
lane.gd                   # Helper has_allies_in_lane_ahead()

# Nivel 7
level_7.tscn              # Escena completa del Nivel 7 con 5 carriles y 8 cartas
```

**Structure Decision**: Arquitectura plana de nodos y escenas en la raíz del proyecto, conservando la estructura establecida en los niveles 1 a 6.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *Ninguna* | Conforme con todas las directrices | No se requieren excepciones arquitectónicas |
