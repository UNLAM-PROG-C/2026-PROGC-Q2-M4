---
name: godot-mcp-sync
description: 'Sincronizar el contexto real de Godot 4 mediante el servidor MCP godot-mcp antes de proponer código o cambios estructurales en escenas, nodos, propiedades o señales.'
argument-hint: 'Indica la escena o mecánica de Godot que querés sincronizar e implementar.'
user-invocable: true
---

# Sincronización con Godot MCP

## Objetivo

Obligar a que cualquier propuesta de código o cambio estructural en Godot 4 parta del estado real del motor consultado mediante el servidor MCP `godot-mcp`. El Scene Tree, las propiedades y las señales observadas en el MCP son la única fuente de verdad.

## Cuándo usar

Usar esta skill antes de trabajar sobre una escena, por ejemplo `harry.tscn` o `alumno_slytherin.tscn`, o antes de proponer cambios que creen, eliminen, reubiquen o configuren nodos, escenas, propiedades, grupos o señales.

## Regla de bloqueo

- No proponer código ni cambios estructurales hasta completar la sincronización con `godot-mcp`.
- Si el servidor o sus herramientas no están disponibles, detenerse e informar que no se puede continuar de forma confiable. No adivinar la jerarquía a partir de archivos de texto.
- Si una operación del MCP falla o devuelve información incompleta, informar el bloqueo y solicitar resolver la conexión antes de implementar.

## Fase 1: Sincronización

1. Si es la primera interacción con `godot-mcp` en la sesión, listar las herramientas disponibles del servidor y considerar únicamente las herramientas que realmente estén expuestas.
2. Identificar la escena objetivo y consultar con las herramientas del MCP el Scene Tree actual completo o el fragmento necesario para la mecánica.
3. Verificar en el motor qué nodos existen realmente, incluyendo sus tipos, nombres, rutas relativas, nodos con Unique Name, grupos relevantes y propiedades necesarias.
4. Revisar las señales conectadas de los nodos involucrados y registrar emisor, señal y receptor.
5. Consultar el estado actual de la escena antes de basarse en cualquier `.tscn`, `.gd` u otro archivo de texto.
6. Si el texto contradice al motor, descartar la suposición textual y priorizar el estado observado por MCP.
7. Antes de escribir código, mostrar un resumen de exactamente 2 líneas sobre lo descubierto en el motor. El resumen debe mencionar la jerarquía o nodos relevantes y las señales, propiedades o grupos confirmados.

## Fase 2: Ejecución

1. Leer `BACKLOG.md` para identificar el criterio pendiente relacionado con la solicitud.
2. Determinar si las herramientas disponibles de `godot-mcp` permiten modificar directamente el proyecto.
3. Si permiten crear nodos, cambiar propiedades, conectar señales u otra operación necesaria, usarlas para aplicar el cambio correspondiente del backlog. Verificar luego el resultado con una nueva lectura del Scene Tree.
4. Si solo permiten lectura, usar exclusivamente la información sincronizada del motor para redactar el GDScript o el plan de cambio, con los `NodePath` exactos confirmados por MCP. No inventar rutas.
5. Respetar `AGENTS.md`, las instrucciones aplicables a GDScript y la terminología temática del proyecto.
6. Tras una implementación verificable, actualizar el criterio correspondiente de `BACKLOG.md` mediante la skill `gestor-backlog`, sin borrar ni reformular tareas.

## Criterios de calidad

- La fuente de cada ruta, nodo y señal usada en la propuesta debe ser una consulta al MCP.
- Las rutas de nodos deben coincidir con el Scene Tree real y distinguir nombres normales de Unique Names.
- Toda discrepancia entre archivos y motor debe quedar resuelta a favor del MCP antes de continuar.
- Nunca afirmar que un cambio fue aplicado si la herramienta del MCP no confirmó la operación.
- El resumen de descubrimientos de 2 líneas debe aparecer inmediatamente antes del código o de la propuesta de cambio.
