# Implementation Plan: Nivel 3 - Expansión y Tanques

**Branch**: `[003-nivel-3-protego]` | **Date**: 2026-09-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/003-nivel-3-protego/spec.md`

## Summary

Expandir el tablero a 5 líneas funcionales introduciendo mecánicas de "tanqueo" tanto para aliados (Protego) como para enemigos (Draco). Se implementará expandiendo el gestor de niveles (`nivel_principal.gd` / `nivel_3.tscn`) y creando dos nuevas entidades heredando los patrones de comportamiento de los aliados y enemigos base, pero ajustando atributos de salud, recursos visuales y excluyendo ataques en el caso de Protego.

## Technical Context

**Language/Version**: Godot 4.x, GDScript (tipado estático estricto)

**Primary Dependencies**: Godot Engine

**Storage**: N/A

**Testing**: Pruebas manuales independientes (Playtesting) en editor

**Target Platform**: Desktop

**Project Type**: Videojuego 2D (Godot Project)

**Performance Goals**: N/A

**Constraints**: Respetar estrictamente arquitectura de Nodos, Escenas y señales. Las validaciones de colisión deben usar Grupos y Area2D, nunca nombres de nodos.

**Scale/Scope**: Activación de 5 filas, creación de 2 nuevas entidades (Draco, Protego).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tipado estático estricto en GDScript (Principio I).
- [x] Arquitectura basada en Nodos y Escenas, no lógica monolítica (Principio II).
- [x] Vocabulario temático (Magos, Mortífagos, Snitches) (Principio III).
- [x] Colisiones por áreas y grupos, no por nombres de nodos (Principio IV).

## Project Structure

### Documentation (this feature)

```text
specs/003-nivel-3-protego/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
/ (Raíz del proyecto)
├── nivel_3.tscn            # Nueva escena para el Nivel 3 (copia ajustada del Nivel 2)
├── draco.tscn              # Nueva escena para el enemigo tanque
├── draco.gd                # Script para lógica de Draco
├── protego.tscn            # Nueva escena para la barrera defensiva
├── protego.gd              # Script para lógica de Protego
```

**Structure Decision**: La estructura será plana (o dentro de las carpetas correspondientes si las hubiera), respetando el patrón actual donde cada entidad principal tiene su `.tscn` y `.gd` homónimos.

## Complexity Tracking

N/A
