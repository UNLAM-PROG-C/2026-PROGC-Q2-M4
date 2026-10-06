# Implementation Plan: Nivel 5 - Introducción de Ron y Escalado de Mortífagos

**Branch**: `[008-nivel-5-ron]` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/008-nivel-5-ron/spec.md`

## Summary

Desarrollar el Nivel 5 del juego introduciendo la nueva unidad atacante "Ron" (`ron.tscn` / `ron.gd`), con un coste de 125 snitches, cadencia de 3.0 segundos y daño de impacto de 30.0 puntos ($1.5\times$ superior al de Harry). Ron se integra al banco de cartas del HUD (`ron_card.tres`), consume proyectiles del pool compartido (`ProjectilePool`) configurando su daño, y carga su aspecto visual exclusivamente desde `res://Images/ron.png`. Además, se crea y configura la escena `level_5.tscn` con 5 líneas activas, mazo completo de 5 cartas más la herramienta Accio, oleadas densas de Alumnos Slytherin y Dracos con mayor frecuencia, y desbloqueo del Nivel 6 al triunfar.

## Technical Context

**Language/Version**: Godot 4.x, GDScript (tipado estático estricto)

**Primary Dependencies**: Godot Engine (Compatibility renderer)

**Storage**: N/A

**Testing**: Pruebas manuales independientes guiadas por [quickstart.md](./quickstart.md) en el editor de Godot

**Target Platform**: Desktop (1920x1080)

**Project Type**: Videojuego 2D (Godot Project)

**Performance Goals**: Disparo de Ron a 3.0 s constante, pooling eficiente de proyectiles sin instanciación en tiempo de ejecución, latencia de colocación y Accio < 100 ms

**Constraints**:
- Tamaño de funciones: ningún método debe superar las 15 líneas (Regla 4 de la cátedra en `AGENTS.md`).
- Tipado estático estricto en todas las variables, constantes, parámetros, señales y retornos.
- Modularidad: una escena y un script por entidad (`ron.tscn` con `ron.gd`).
- Grupos: pertenencia estricta al grupo reservado `allies` (`Groups.ALLIES`), sin comparar por nombres de nodos.
- Rutas de assets: asignación estricta a `res://Images/ron.png`.
- Restricciones de cambios: no instalar addons ni modificar `project.godot`.

**Scale/Scope**:
- 1 nueva entidad aliada (`ron.tscn`, `ron.gd`).
- 1 nuevo recurso de carta (`ron_card.tres`).
- 1 nueva escena de nivel (`level_5.tscn`).
- Extensión modular en `projectile_pool.gd` (daño parametrizado) y `level.gd` (inicialización de aliados plantados en método helper `<= 15` líneas).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Principio I (Motor y lenguaje)**: Godot 4, Compatibility renderer, GDScript con tipado estático estricto verificado en todas las firmas.
- [x] **Principio II (Arquitectura de Nodos y Escenas)**: Ron tiene su propia escena (`ron.tscn`) y script (`ron.gd`) como nodo `Area2D` con hijos explícitos (`Sprite2D`, `CollisionShape2D`, `ShootPoint`, `ShootTimer`, `DamageFlash`).
- [x] **Principio III (Vocabulario temático e idioma)**: Identificadores técnicos en inglés (`Ron`, `shot_interval`, `damage`, `projectile_pool`), textos de interfaz en español con temática mágica ("Ron", "Snitches").
- [x] **Principio IV (Colisiones y grupos)**: Pertenece al grupo `allies` (`Groups.ALLIES`). Proyectiles pertenecen a `spells` (`Groups.SPELLS`) y colisionan con `enemies` (`Groups.ENEMIES`).
- [x] **Principio V (Sincronización de interfaz)**: No se alteran propiedades globales sin verificar la jerarquía de la escena.
- [x] **Reglas de la Cátedra (AGENTS.md)**: Métodos modulares de $\le 15$ líneas, constantes descriptivas sin números mágicos, llaves estilo Allman en caso de requerirse.

## Project Structure

### Documentation (this feature)

```text
specs/008-nivel-5-ron/
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
├── ron.gd               # Script de la entidad atacante Ron (hereda de Ally)
├── ron.tscn             # Escena de Ron con Sprite2D (res://Images/ron.png) y ShootTimer
├── ron_card.tres        # Recurso AllyCard para Ron (125 snitches, cooldown 7.5s)
├── projectile_pool.gd   # Soporte para daño parametrizado en acquire_projectile()
├── level.gd             # Método modular _init_placed_ally() para inyección de Ron
├── level_5.tscn         # Escena del Nivel 5 (5 líneas, mazo completo con Ron y Accio)
```

**Structure Decision**: Se mantiene la estructura plana estándar de Godot en la raíz del proyecto, creando `ron.tscn`, `ron.gd` y `ron_card.tres` con reutilización directa en `level_5.tscn`.

## Complexity Tracking

| Violación / Decisión | Razón de necesidad | Alternativa más simple descartada porque |
| :--- | :--- | :--- |
| Ninguna | N/A | N/A |
