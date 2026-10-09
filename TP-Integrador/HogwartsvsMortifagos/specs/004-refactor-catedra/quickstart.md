# Quickstart: validar el refactor

Guía para comprobar, después de cada User Story, que el juego cumple las reglas y se comporta igual que en `13aad48`.

## Prerrequisitos

- Godot 4.7 (el de `project.godot`) con el ejecutable accesible desde la terminal como `godot`.
- Rama `004-refactor-catedra` sin cambios locales de Godot pendientes (`git status` limpio salvo lo propio del paso).
- Editor de Godot cerrado mientras se renombran archivos (ver [research.md R13](./research.md#r13-mecánica-de-renombrado)).
- `godot-mcp` disponible para inspeccionar el árbol de escenas en ejecución (principio V de la constitución). Si no responde, se detiene la verificación y se avisa.

## 1. Chequeo automático

```text
godot --headless --path . --script res://tools/check_rules.gd
```

| Después de | Resultado esperado |
| --- | --- |
| User Story 1 | Corre y reporta 13 `LONG_FUNCTION` más los `OLD_IDENTIFIER` pendientes. Línea base registrada en el commit |
| User Story 2 | 0 `OLD_IDENTIFIER` (pueden quedar `REMOVED_IDENTIFIER`) |
| User Story 3 | `check_rules: 0 findings`, código de salida 0 |

Formato de salida: [contracts/check-rules-cli.md](./contracts/check-rules-cli.md).

## 2. Revisión manual

Lo que el chequeo no cubre:

- **Locales y comentarios en español**: buscar tildes, `ñ` y sufijos típicos fuera de textos de UI.

  ```text
  git grep -nIE "[áéíóúñ]|cion\b|_de_|_del_" -- "*.gd" "*.gdshader"
  ```

  Solo deben quedar líneas `const *_TEXT`.
- **Números mágicos** (FR-009): revisar el diff de cada `.gd` contra la lista de literales permitidos de [research.md R9](./research.md#r9-constantes-compartidas-y-carriles).
- **Indentación intacta** (SC-002): ningún archivo cambia solo de espacios.

  ```text
  diff <(git diff develop --name-only) <(git diff develop -w --name-only)
  ```

  No debe imprimir nada: `-w` oculta los archivos que solo cambiaron espacios, así que cualquier diferencia es un archivo reindentado (en Windows, correrlo desde Git Bash).

  ```text
  git grep -nE "^ +" -- "*.gd" "*.gdshader"
  ```

  Tampoco debe imprimir nada: detecta líneas indentadas con espacios, es decir, reindentaciones del editor también en archivos renombrados con `git mv`, que el `diff` anterior no ve porque el renombre los deja en ambas listas.
- **Legacy borrado** (SC-004): `git ls-files | grep -E "Mago|Mortifago|tile_map_layer|\.tmp$"` no devuelve nada.

## 3. Proyecto abre sin errores

Abrir el proyecto en el editor. La pestaña Output y el panel de errores no deben mostrar recursos faltantes, scripts que no compilan ni propiedades desconocidas. Con `godot-mcp`, confirmar en cada escena de nivel:

- Los nodos raíz de `harry`, `snitch_box`, `remembrall` y `protego` están en `allies`; `slytherin_student` y `draco` en `enemies`; `projectile` en `spells`.
- Cada `AllyCardButton` del HUD tiene su `card` asignada.
- `GameManager` aparece como autoload en `/root`.

## 4. Partida (SC-005)

Repetir en Niveles 1, 2 y 3:

| Escenario | Resultado esperado |
| --- | --- |
| Inicio | HUD muestra `Snitches: 150`. Botones con el mismo texto y estado que antes (`Harry (100)`, `Caja Snitch (50)`, …) |
| Plantar cada aliado | Descuenta su costo. Solo en filas activas y celdas libres. Recordadora queda 25 s en recarga y Protego 12 s |
| Clic en un botón seleccionado | Lo deselecciona (vuelve a blanco) |
| Caja de Snitch | Cada 10 s se abre, suelta una Snitch de 25 que se recoge con clic |
| Snitch del cielo | Cae en zigzag, escapa del mouse y se recoge con clic |
| Harry | Dispara solo si hay un enemigo en su carril. Cada impacto saca 20 |
| Enemigo atacado | Parpadea en rojo con fundido (0.15 s). Cambia a textura lastimada con la mitad de la vida |
| Aliado atacado | Parpadea en rojo 0.1 s, como máximo cada 0.5 s |
| Recordadora | Se agranda, se tiñe y explota; elimina enemigos en su área |
| Draco (Nivel 3) | Aparece en alrededor de la mitad de los spawns y aguanta el doble |
| Dementor | Se activa al llegar un enemigo y barre su carril |
| Victoria | Panel `¡VICTORIA!` con el mensaje de nivel desbloqueado |
| Desbloqueo (con `godot-mcp`) | Antes de ganar el Nivel 1, fijar `/root/GameManager.max_unlocked_level = 1`. Al ganar, vale `2`; al volver al mapa, `Level2` está habilitado y `Level3` deshabilitado |
| Derrota | Un enemigo cruza el borde izquierdo y aparece el panel `¡DERROTA!` |
| Botones del panel | Reintentar recarga el nivel; Siguiente nivel y Volver al mapa cargan el menú |

## 5. Menú de niveles (SC-006)

- El mapa muestra las huellas del camino y los caminantes ambientales igual que antes, y los botones conservan el estilo pergamino.
- Agregar un nivel de prueba: duplicar `level_3.tscn`, agregarlo como cuarto elemento de `level_scenes` y comprobar que el botón `Level4` lo carga sin tocar código. Descartar el cambio después.
