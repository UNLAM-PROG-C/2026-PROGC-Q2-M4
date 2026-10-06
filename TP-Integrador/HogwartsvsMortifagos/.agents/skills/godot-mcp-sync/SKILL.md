---
name: godot-mcp-sync
description: 'Sincronizar el contexto real de Godot 4 mediante el servidor MCP godot-mcp antes de proponer código o cambios estructurales en escenas, nodos, propiedades o señales.'
argument-hint: 'Indica la escena o mecánica de Godot que querés sincronizar e implementar.'
user-invocable: true
---

# Sincronización con Godot MCP

## Objetivo

Cuando esté disponible, usar el servidor MCP `godot-mcp` para que las propuestas de código o cambios estructurales en Godot 4 partan del estado real del motor. El Scene Tree, las propiedades y las señales observadas mediante MCP son la fuente preferida de verdad; si MCP no funciona, se utilizarán los archivos del proyecto y la validación local.

## Cuándo usar

Usar esta skill antes de trabajar sobre una escena, por ejemplo `harry.tscn` o `alumno_slytherin.tscn`, o antes de proponer cambios que creen, eliminen, reubiquen o configuren nodos, escenas, propiedades, grupos o señales.

## Uso preferente y alternativa

- Cuando el servidor y sus herramientas estén disponibles, utilizar `godot-mcp` para sincronizar el estado real del motor antes de proponer código o cambios estructurales.
- Si el servidor no está disponible o devuelve información incompleta, no bloquear la tarea: utilizar como fuente alternativa las escenas, scripts y documentación del proyecto, indicar las limitaciones y validar el resultado mediante las herramientas locales disponibles.

## Fase 1: Sincronización

1. Si es la primera interacción con `godot-mcp` en la sesión y el servidor está disponible, listar las herramientas disponibles y considerar únicamente las herramientas realmente expuestas.
2. Identificar la escena objetivo y consultar con las herramientas del MCP el Scene Tree actual completo o el fragmento necesario para la mecánica.
3. Verificar en el motor qué nodos existen realmente, incluyendo sus tipos, nombres, rutas relativas, nodos con Unique Name, grupos relevantes y propiedades necesarias.
4. Revisar las señales conectadas de los nodos involucrados y registrar emisor, señal y receptor.
5. Consultar el estado actual de la escena antes de basarse en cualquier `.tscn`, `.gd` u otro archivo de texto.
6. Si el texto contradice al motor y `godot-mcp` está disponible, descartar la suposición textual y priorizar el estado observado por MCP. Si no está disponible, registrar la discrepancia y resolverla mediante la evidencia local y la validación en Godot.
7. Antes de escribir código, mostrar un resumen de exactamente 2 líneas sobre lo descubierto en el motor. El resumen debe mencionar la jerarquía o nodos relevantes y las señales, propiedades o grupos confirmados.

## Fase 2: Ejecución

1. Leer `BACKLOG.md` para identificar el criterio pendiente relacionado con la solicitud.
2. Determinar si las herramientas disponibles de `godot-mcp` permiten modificar directamente el proyecto; si no están disponibles, utilizar las herramientas locales de edición.
3. Si permiten crear nodos, cambiar propiedades, conectar señales u otra operación necesaria, usarlas para aplicar el cambio correspondiente del backlog. Verificar luego el resultado con una nueva lectura del Scene Tree.
4. Si solo permiten lectura, usar la información sincronizada del motor para redactar el GDScript o el plan de cambio, con los `NodePath` confirmados por MCP. Si MCP no está disponible, obtener y comprobar los `NodePath` desde las escenas y scripts del proyecto; no inventar rutas.
5. Respetar `AGENTS.md`, las instrucciones aplicables a GDScript y la terminología temática del proyecto.
6. Tras una implementación verificable, actualizar el criterio correspondiente de `BACKLOG.md` mediante la skill `gestor-backlog`, sin borrar ni reformular tareas.

## Criterios de calidad

- Cuando MCP esté disponible, la fuente preferida de cada ruta, nodo y señal usada en la propuesta debe ser una consulta al servidor.
- Las rutas de nodos deben coincidir con el Scene Tree real y distinguir nombres normales de Unique Names.
- Toda discrepancia entre archivos y motor debe resolverse a favor de MCP cuando esté disponible; de lo contrario, debe documentarse y comprobarse con validación local.
- Nunca afirmar que un cambio fue aplicado si la herramienta utilizada para editarlo no confirmó la operación.
- El resumen de descubrimientos de 2 líneas debe aparecer inmediatamente antes del código o de la propuesta de cambio.
