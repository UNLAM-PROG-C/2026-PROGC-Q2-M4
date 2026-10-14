---
name: gestor-backlog
description: 'Crear y administrar el BACKLOG.md del proyecto Godot. Usar cuando se solicite crear el backlog, consultar el progreso, actualizar tareas, marcar criterios cumplidos o gestionar el desarrollo pendiente.'
argument-hint: 'Indica qué tarea o criterio del BACKLOG.md se completó.'
user-invocable: true
---

# Gestor de backlog

## Objetivo

Crear y administrar el archivo [`BACKLOG.md`](../../../BACKLOG.md) en la raíz del proyecto para llevar el control del desarrollo del juego.

## Procedimiento

### Crear el backlog

1. Comprobar si existe `BACKLOG.md` en la raíz del proyecto.
2. Si no existe, crearlo con el backlog inicial definido para este proyecto.
3. Mantener el formato Markdown y las tareas como listas de tareas con checkboxes usando `- [ ]`.

### Actualizar el progreso

1. Leer siempre el contenido actual de `BACKLOG.md` antes de modificarlo.
2. Identificar únicamente los criterios que el usuario indique como cumplidos.
3. Cambiar el estado de cada criterio cumplido de `- [ ]` a `- [x]`.
4. No borrar, reordenar, renombrar ni reformular ninguna tarea.
5. Guardar `BACKLOG.md` conservando todas las tareas pendientes y completadas.
6. Informar siempre cómo quedó el archivo después de modificarlo, dentro de un bloque de código Markdown.

### Consultar el progreso

1. Leer `BACKLOG.md`.
2. Resumir el estado actual sin modificar tareas.
3. Mantener los nombres temáticos definidos en [`AGENTS.md`](../../../AGENTS.md).

## Reglas

- Nunca borrar una tarea; solo cambiar su estado entre `- [ ]` y `- [x]` cuando corresponda.
- No marcar una tarea como completada sin indicación explícita del usuario o evidencia verificable en el proyecto.
- No agregar tareas al backlog inicial salvo que el usuario lo solicite.
- Después de cada modificación, mostrar el contenido completo actualizado de `BACKLOG.md` en un bloque de código.
