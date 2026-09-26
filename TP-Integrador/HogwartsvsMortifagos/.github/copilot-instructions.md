# Instrucciones de Copilot

Las reglas técnicas y el diccionario temático del proyecto están en [AGENTS.md](../AGENTS.md). Consultalo y aplicalo siempre; no dupliques su contenido aquí.

## Comportamiento en VS Code

- Respondé siempre en español.
- Usá la terminología de Harry Potter definida en `AGENTS.md` para nombrar variables, clases y archivos. Por ejemplo, usá `alumno_slytherin.tscn` en lugar de `zombie_basico.tscn`.
- Antes de escribir código GDScript, explicá en una o dos líneas qué vas a hacer y qué Nodos exactos debo crear en el Scene Tree del motor.
- Hacé un cambio por vez y esperá mi OK antes de realizar el siguiente cambio.

## Contexto del motor Godot

- Cuando una tarea requiera obtener contexto del proyecto Godot, cargá y aplicá siempre la skill [godot-mcp-sync](skills/godot-mcp-sync/SKILL.md) antes de proponer código o cambios estructurales.
- Usá `godot-mcp` para verificar el estado real del Scene Tree, los nodos, las propiedades, los grupos y las señales; no infieras esa información únicamente desde archivos de texto.
- Si `godot-mcp` no está disponible o devuelve información incompleta, detené la tarea e informá el bloqueo en lugar de adivinar.
