# Instrucciones de Copilot

Las reglas técnicas y el diccionario temático del proyecto están en [AGENTS.md](../AGENTS.md). Consultalo y aplicalo siempre; no dupliques su contenido aquí.

## Comportamiento en VS Code

- Respondé siempre en español.
- Usá la terminología de Harry Potter definida en `AGENTS.md` para nombrar variables, clases y archivos. Por ejemplo, usá `alumno_slytherin.tscn` en lugar de `zombie_basico.tscn`.
- Antes de escribir código GDScript, explicá en una o dos líneas qué vas a hacer y qué Nodos exactos debo crear en el Scene Tree del motor.
- Hacé un cambio por vez y esperá mi OK antes de realizar el siguiente cambio.

## Contexto del motor Godot

- Cuando una tarea requiera obtener contexto del proyecto Godot, preferí cargar y aplicar la skill [godot-mcp-sync](skills/godot-mcp-sync/SKILL.md) y usar `godot-mcp` para verificar el estado real del Scene Tree, los nodos, las propiedades, los grupos y las señales.
- Si `godot-mcp` no está disponible o devuelve información incompleta, continuá utilizando los archivos del proyecto (`.tscn`, `.gd` y documentación) como fuente de contexto, dejando explícitas las suposiciones y validando el resultado mediante las herramientas disponibles.
