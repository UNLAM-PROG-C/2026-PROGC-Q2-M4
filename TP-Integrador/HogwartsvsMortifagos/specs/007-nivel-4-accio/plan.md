# Implementation Plan: Nivel 4 - Remoción con Hechizo Accio

**Branch**: `[007-nivel-4-accio]` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/007-nivel-4-accio/spec.md`

## Summary

Desarrollar el Nivel 4 del juego introduciendo la mecánica del hechizo "Accio" (Pala) para la gestión y remoción de aliados en la cuadrícula. Se incorporará un nuevo botón modular `AccioButton` en el HUD, control de cursor personalizado (placeholder visual flotante con ocultamiento del cursor del sistema), feedback de modulación durante el hover sobre aliados del grupo `allies`, y destrucción determinística inmediata mediante el diccionario de celdas de `Level` sin otorgar reembolso de snitches. Además, se creará la escena `level_4.tscn` configurada con 5 carriles activos, oleadas combinadas de Alumnos Slytherin y Dracos, y el arsenal completo de 4 aliados junto a la herramienta Accio.

## Technical Context

**Language/Version**: Godot 4.x, GDScript (tipado estático estricto)

**Primary Dependencies**: Godot Engine (Compatibility renderer)

**Storage**: N/A

**Testing**: Pruebas manuales independientes guiadas por [quickstart.md](./quickstart.md) en editor Godot

**Target Platform**: Desktop (1920x1080)

**Project Type**: Videojuego 2D (Godot Project)

**Performance Goals**: Latencia de hover < 100 ms, cancelación y remoción inmediatas (< 1 s)

**Constraints**:
- Tamaño de funciones: ningún método debe superar las 15 líneas (Regla 4 de la cátedra).
- Tipado estático estricto en todas las variables, constantes, parámetros, señales y retornos.
- Modularidad: botón `AccioButton` desacoplado mediante señales.
- Colisiones y grupos: validación exclusiva por grupo `allies`, nunca por nombres de nodos.
- Restricciones de cambios: no instalar addons ni modificar `project.godot`.

**Scale/Scope**: 1 escena nueva (`level_4.tscn`), 1 nuevo script de componente (`accio_button.gd`), extensión de `level.gd` para gestión de Accio y cursor.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Principio I (Motor y lenguaje)**: Godot 4, Compatibility renderer, GDScript con tipado estático estricto verificado en todos los contratos y firmas.
- [x] **Principio II (Arquitectura de Nodos y Escenas)**: Lógica estructurada en nodos hijos (`AccioButton`, `AccioCursor` en HUD), comunicados con el gestor mediante señales (`accio_toggled`).
- [x] **Principio III (Vocabulario temático e idioma)**: Identificadores técnicos en inglés (`AccioButton`, `_is_removing`, `_try_remove_ally`), textos de cara al usuario en español con temática de Harry Potter ("Accio", "Snitches").
- [x] **Principio IV (Colisiones y grupos)**: Operaciones restringidas estrictamente al grupo reservado `allies` (`Groups.ALLIES`), respetando la inmunidad de Dementores y enemigos.
- [x] **Principio V (Sincronización de interfaz)**: No se alteran propiedades globales sin verificar la jerarquía de la escena.
- [x] **Reglas de la Cátedra (AGENTS.md)**: Métodos modulares de <= 15 líneas, constantes descriptivas sin números mágicos.

## Project Structure

### Documentation (this feature)

```text
specs/007-nivel-4-accio/
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
├── accio_button.gd       # Componente modular del botón de Accio en el HUD
├── level.gd             # Extensión para manejo de modo remoción, hover y cursor
├── level_4.tscn         # Nueva escena del Nivel 4 (5 líneas, mazo completo + Accio)
```

**Structure Decision**: Se mantiene la estructura plana estándar del proyecto, creando `accio_button.gd` para la interfaz de Accio y `level_4.tscn` derivado de la configuración de 5 carriles de `level_3.tscn`, integrando el botón Accio en el HUD.

## Complexity Tracking

| Violación / Decisión | Razón de necesidad | Alternativa más simple descartada porque |
| :--- | :--- | :--- |
| Ninguna | N/A | N/A |
