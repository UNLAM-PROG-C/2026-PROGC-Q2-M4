# Contract: `tools/check_rules.gd`

Script de chequeo de reglas (FR-016). Solo depende de Godot 4.

## Invocación

```text
godot --headless --path <raíz del proyecto> --script res://tools/check_rules.gd
```

En Windows, `godot` es el ejecutable del editor (por ejemplo `Godot_v4.x-stable_win64_console.exe`). No abre ventana ni modifica archivos.

## Entradas

- **Mapa de renombres**: `res://specs/004-refactor-catedra/rename-map.md` (constante en el script). Se toma la primera celda de cada fila de tabla si es un único identificador entre backticks (`` `nombre` ``); si no lo es, la fila se ignora. La segunda celda define la categoría:
  - nombre nuevo → la fila genera hallazgos `OLD_IDENTIFIER`;
  - `—` (el identificador desaparece en la User Story 3) → la fila genera hallazgos `REMOVED_IDENTIFIER`;
  - cualquier otro valor (varias opciones, texto libre) → el mapa es inválido: el script termina con código 2 e indica la línea del mapa.
- **Archivos**: todos los `.gd`, `.tscn` y `.gdshader` bajo `res://`, salvo los directorios `addons/`, `godot-mcp-main/`, `.godot/` y `specs/`.

## Reglas

1. **Función larga**: una función cuyo cuerpo supera 15 líneas. El cuerpo va desde la línea siguiente a `func` hasta la última línea no vacía antes de la próxima línea sin indentar. Cuentan las líneas en blanco y los comentarios intermedios. Solo aplica a `.gd`.
2. **Identificador viejo**: una aparición de un identificador del mapa como palabra completa (`\b<id>\b`, sensible a mayúsculas). Se ignoran:
   - líneas de `.tscn` que empiezan con `text = `;
   - líneas de `.gd` que declaran una constante con sufijo `_TEXT`;
   - rutas bajo `res://Imagenes/`.
3. **Identificador a eliminar**: igual que la regla 2, con las mismas exclusiones, pero para las filas cuyo nombre nuevo es `—`.

La tabulación no se chequea (indentación fuera de alcance, ver la clarificación del 2026-10-01).

## Salida

Una línea por hallazgo, en stdout, ordenadas por archivo y línea:

```text
LONG_FUNCTION res://level.gd:42 _try_place_ally (18 lines)
OLD_IDENTIFIER res://level_2.tscn:124 TimerSpawneoMortifagos
REMOVED_IDENTIFIER res://level.gd:88 _on_boton_harry_pressed
```

Al final, un resumen:

```text
check_rules: 3 findings (1 LONG_FUNCTION, 1 OLD_IDENTIFIER, 1 REMOVED_IDENTIFIER)
```

## Código de salida

| Código | Significado |
| --- | --- |
| 0 | Sin hallazgos |
| 1 | Al menos un hallazgo |
| 2 | No se pudo leer el mapa de renombres |

## Línea base esperada

- Antes del refactor: 13 `LONG_FUNCTION` (las del spec), cientos de `OLD_IDENTIFIER` y los `REMOVED_IDENTIFIER` de las filas `—`.
- Después de la User Story 2: 0 `OLD_IDENTIFIER`. Los `REMOVED_IDENTIFIER` siguen presentes y el código de salida es 1.
- Después de la User Story 3: 0 hallazgos de cualquier tipo (SC-001), código de salida 0.
