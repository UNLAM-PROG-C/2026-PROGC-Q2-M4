# Implementation Plan: Nivel 2 — Expansión a 3 Líneas y la Recordadora

**Branch**: `002-nivel-2-recordadora` | **Date**: 2026-09-29 | **Spec**: [specs/002-nivel-2-recordadora/spec.md](spec.md)

**Input**: Feature specification from `specs/002-nivel-2-recordadora/spec.md`

---

## Summary

Desarrollo del Nivel 2 del juego, expandiendo el campo de batalla a las 3 filas centrales (Filas 3, 4 y 5) mientras se mantienen bloqueadas únicamente las 2 filas de los extremos (Filas 2 y 6) mediante `BloqueoMagico`. Introducción de la entidad aliada Recordadora (`recordadora.tscn`) como bomba de área (3×3 celdas, 1,5s de detonación, 150 Snitches y recarga de 25s en HUD). Adaptación del spawner de enemigos a un esquema multilínea aleatorio entre los 3 Marker2D activos, con una oleada de 20 Alumnos Slytherin cada 6 segundos, red de seguridad de 5 Dementores y desbloqueo del Nivel 3 en el Mapa del Merodeador al triunfar.

---

## Technical Context

**Language/Version**: GDScript en Godot 4.x con tipado estático estricto en todas las variables, parámetros y retornos.  
**Primary Dependencies**: Godot 4 Engine (sin addons ni librerías externas).  
**Storage**: Persistencia en memoria de sesión mediante `MenuNiveles.progreso_desbloqueado`.  
**Testing**: Pruebas de integración visuales y funcionales en editor/runtime de Godot (F5 / F6) guiadas por `quickstart.md`.  
**Target Platform**: Desktop (Windows/Linux/macOS), resolución 1920×1080, renderizador Compatibility.  
**Project Type**: Videojuego 2D basado estrictamente en Nodos y Escenas.  
**Performance Goals**: 60 fps estables, respuesta inmediata al clic de plantado y activación de colisiones sin tirones.  
**Constraints**: Prohibido el uso de nombres de nodos para validar objetivos (uso obligatorio de grupos `aliados`, `enemigos`), sin addons externos.  
**Scale/Scope**: 1 nueva entidad (`recordadora.tscn`/`recordadora.gd`), 1 escena de nivel (`nivel_2.tscn`), generalización de `nivel_principal.gd` y actualización de `menu_niveles.gd`.  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Requisito de la Constitución | Estado en Diseño | Evaluación |
|---|---|---|---|
| **I. Motor y lenguaje** | Godot 4, Compatibility renderer, GDScript con tipado estático estricto. | Todo código GDScript declara tipos explícitos (`: int`, `: float`, `-> void`). | **PASSED** |
| **II. Arquitectura de Nodos y Escenas** | Escena propia por entidad; reutilización por instanciación. | `recordadora.tscn` independiente; `nivel_2.tscn` reutiliza arquitectura sin duplicar lógica. | **PASSED** |
| **III. Vocabulario temático** | Términos de Harry Potter: Aliados (Magos), Mortífagos, Snitches, Recordadora. | Diccionario canónico aplicado en HUD, código y señales. | **PASSED** |
| **IV. Colisiones por áreas y grupos** | Detección por `Area2D` y grupos (`aliados`, `enemigos`). Prohibido filtrar por nombre. | `AreaExplosion` consulta `is_in_group("enemigos")` con máscaras de colisión físicas. | **PASSED** |
| **V. Estado de interfaz sincronizado con Godot MCP** | MCP como fuente de verdad para el Scene Tree y propiedades. | Sincronización del árbol y validación en editor respetada. | **PASSED** |

**Resultado del Gate**: **PASSED (5/5)**. Sin violaciones ni requerimientos de complejidad extraordinaria.

---

## Project Structure

### Documentation (this feature)

```text
specs/002-nivel-2-recordadora/
├── spec.md                  # Especificación de requisitos y clarificaciones
├── plan.md                  # Plan de arquitectura e implementación (este archivo)
├── research.md              # Decisiones técnicas y alternativas evaluadas (Fase 0)
├── data-model.md            # Entidades, propiedades y máquinas de estado (Fase 1)
├── quickstart.md            # Guía de validación y pruebas de juego (Fase 1)
├── contracts/               # Contratos de interfaces y flujos (Fase 1)
│   ├── recordadora-contract.md
│   └── nivel2-flow-contract.md
├── checklists/
│   └── requirements.md      # Checklist de calidad de especificación (16/16)
└── tasks.md                 # Desglose de tareas ejecutables (Fase 2: /speckit-tasks)
```

### Source Code (repository layout)

```text
c:/Users/polol/Documents/GitHub/2026-PROGC-Q2-M4/TP-Integrador/HogwartsvsMortifagos/
├── recordadora.tscn         # Nueva escena: Aliado bomba de área
├── recordadora.gd           # Nuevo script: Lógica de detonación y radio 3x3
├── nivel_2.tscn             # Nueva escena: Nivel 2 con 3 filas activas y HUD extendido
├── nivel_principal.gd       # Actualización: Soporte para filas y spawners multilínea configurables
├── menu_niveles.gd          # Actualización: Carga dinámica de escenas según nivel seleccionado
└── menu_niveles.tscn        # Escena principal (Mapa del Merodeador)
```

**Structure Decision**: Se mantiene la estructura plana estándar de escenas en la raíz del proyecto existente (`harry.tscn`, `alumno_slytherin.tscn`, `NivelPrincipal.tscn`), creando `recordadora.tscn` y `nivel_2.tscn` con sus respectivos scripts en la raíz junto al resto de entidades del juego.

---

## Complexity Tracking

> **Sin violaciones a la constitución.** No aplica tabla de justificación.
