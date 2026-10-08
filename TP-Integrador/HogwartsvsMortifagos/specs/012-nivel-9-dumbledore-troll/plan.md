# Implementation Plan: Nivel 9 - Dumbledore y el Troll Colosal

**Branch**: `[012-nivel-9-dumbledore-troll]` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/012-nivel-9-dumbledore-troll/spec.md`

## Summary

Desarrollar e integrar el Nivel 9 del juego:
1. **Dumbledore (`dumbledore.tscn` / `dumbledore.gd`)**: Aliado pesado de daño en área (300 snitches, 300 HP, cadencia de 3.0s) que dispara hechizos lineales con la textura explícita `res://Images/dumbledore.png`.
2. **Proyectil de Dumbledore (`dumbledore_projectile.tscn` / `dumbledore_projectile.gd`)**: Proyectil en línea recta horizontal con textura `res://Images/dumbledore_shot.png` (350 px/s). Al primer impacto contra un enemigo o escudo, detona un área de splash de 3x3 celdas (384x384 px) e inflige 20 puntos de daño simultáneo (igual al disparo de Harry) a todos los enemigos en el radio antes de destruirse (`queue_free()`).
3. **Carta de Dumbledore (`dumbledore_card.tres`)**: Recurso de datos para el HUD con costo de 300 snitches, tiempo de recarga de 15.0s y escena `dumbledore.tscn`.
4. **Troll Colosal (`troll.tscn` / `troll.gd`)**: Enemigo colosal (fuerza bruta instakill equivalente a Gargantuar) inyectando la lógica en la escena existente sin alterar sus nodos visuales ni su `AnimationPlayer`. Configura 3600 HP (para resistir exactamente 2 impactos de 1800 de daño masivo), velocidad de 20 px/s, y pausa breve para reproducir `"attack"` y destruir instantáneamente (9999 de daño) a cualquier aliado antes de reanudar `"Walk"`.
5. **Nivel 9 (`level_9.tscn`)**: Escenario completo con 5 carriles activos, 5 Dementores defensivos, HUD expandido con 10 cartas, oleadas mixtas con los 5 tipos de enemigos (incluyendo al Troll) y desbloqueo del Nivel 10 (Profesor Quirrell) al ganar.

## Technical Context

**Language/Version**: GDScript en Godot 4.x (renderizador Compatibility).

**Primary Dependencies**: Nodos core de Godot 4 (`Area2D`, `Sprite2D`, `AnimationPlayer`, `Timer`, `Marker2D`, `TileMapLayer`, `Button`, `Label`).

**Storage**: Recursos nativos de Godot (`.tscn`, `.tres`, `.gd`, `.png`).

**Testing**: Escenas ejecutables de validación con Godot Engine y pruebas manuales paso a paso descritas en `quickstart.md`.

**Target Platform**: Desktop (Resolución objetivo 1920x1080).

**Project Type**: Juego 2D Tower Defense (Hogwarts vs Mortífagos).

**Performance Goals**: 60 FPS estables; consultas de colisión y superposición limpias durante detonaciones de splash 3x3 sin lagunas de memoria.

**Constraints**:
- Regla de la cátedra: Ningún método puede superar las 15 líneas de código.
- Identificadores, métodos, señales y comentarios estrictamente en inglés.
- Textos visibles para el jugador en español bajo constantes con sufijo `_TEXT`.
- Tipado estático estricto en el 100% de variables, constantes, parámetros y retornos.
- Indentación de 2 espacios. Prohibido el uso de números mágicos.
- No alterar la estructura de nodos visuales ni el `AnimationPlayer` de `troll.tscn`.
- Cargar texturas de Dumbledore explícitamente desde `res://Images/dumbledore.png` y `res://Images/dumbledore_shot.png`.
- No modificar `project.godot` sin autorización previa.

**Scale/Scope**: 1 nueva clase aliada (`Dumbledore`), 1 nuevo proyectil con splash (`DumbledoreProjectile`), 1 nueva clase enemiga (`Troll`), 1 recurso de carta (`dumbledore_card.tres`), 1 escena de nivel (`level_9.tscn`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Motor y lenguaje**: Godot 4 Compatibility y GDScript con tipado estático estricto en el 100% de declaraciones. -> **PASS**
- **II. Arquitectura de Nodos y Escenas**: Cada entidad (`Dumbledore`, `DumbledoreProjectile`, `Troll`, `Level9`) posee su propia escena `.tscn` y script `.gd`. Las entidades se comunican mediante señales y no acoplan jerarquías internas. -> **PASS**
- **III. Vocabulario temático e idioma del código**: Nombres en inglés acordes al diccionario temático (`Dumbledore`, `Troll`, `snitch`). Textos UI en español con constante sufijo `_TEXT`. -> **PASS**
- **IV. Colisiones por áreas y grupos**: Se utilizan nodos `Area2D` y pertenencia a los grupos `allies`, `enemies` y `spells`. Sin comparaciones frágiles por nombres de nodos. -> **PASS**
- **V. Estado de interfaz**: Compatibilidad y lectura del Scene Tree de Godot. -> **PASS**
- **Reglas Cátedra**: Métodos de 15 líneas o menos, indentación de 2 espacios, cero números mágicos. -> **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/012-nivel-9-dumbledore-troll/
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
# Entidades Aliadas y Proyectiles
dumbledore.gd             # Script de Dumbledore (disparo pesado cada 3.0s)
dumbledore.tscn           # Escena de Dumbledore (Area2D, Sprite2D, ShootTimer, ShootPoint)
dumbledore_card.tres      # Recurso AllyCard (display_name "Dumbledore", costo 300, cooldown 15.0)
dumbledore_projectile.gd  # Script del proyectil con detonación de splash 3x3 (20 HP)
dumbledore_projectile.tscn# Escena del proyectil con área de splash secundaria

# Entidades Enemigas
troll.gd                  # Script del Troll (3600 HP, velocidad 20 px/s, pausa de golpe instakill 9999)
troll.tscn                # Escena existente actualizada con script troll.gd y CollisionShape2D

# Lógica del Nivel
level_9.tscn              # Escena completa del Nivel 9 (5 filas, 45 enemigos, 10 cartas en HUD)
```

**Structure Decision**: Arquitectura plana de nodos y escenas en la raíz del proyecto, idéntica a la estructura establecida en los niveles 1 al 8.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| *Ninguna* | Cumplimiento estricto de principios arquitectónicos sin violaciones ni desvíos. | N/A |
