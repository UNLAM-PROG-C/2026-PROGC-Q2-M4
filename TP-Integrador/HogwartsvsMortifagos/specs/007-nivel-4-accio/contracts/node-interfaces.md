# Interface Contracts: Nivel 4 y Hechizo Accio

Este documento describe los contratos públicos de nodos, señales, métodos y eventos que estructuran la interacción entre el HUD, el gestor de nivel y los aliados.

## 1. Contrato del Botón Accio (`AccioButton`)

Representa el control persistente en el HUD para activar y desactivar la herramienta de remoción.

```gdscript
class_name AccioButton
extends Button

## Emitida cuando el jugador hace clic en el botón para alternar el modo Accio.
signal accio_toggled(is_active: bool)

## Configura visual y lógicamente el estado activo/inactivo del botón.
func set_active(active: bool) -> void

## Retorna si el modo Accio se encuentra actualmente activo en el botón.
func is_active() -> bool
```

### Comportamiento y Conexiones
- **Evento**: Conecta internamente la señal `pressed` de `Button` para alternar su estado interno y emitir `accio_toggled`.
- **Feedback visual**: Al estar activo, modula a un color distintivo (e.g. `Color(1.0, 0.4, 0.4)` o estilo presionado). Al estar inactivo, vuelve a `Color.WHITE`.
- **Oyente**: `Level._on_accio_toggled(is_active: bool)`.

---

## 2. Contrato de Entrada e Interacción en `Level`

La clase `Level` centraliza las transiciones entre modos de plantado, remoción y estado neutral.

```gdscript
# Métodos de gestión de Accio en Level:

## Responde al evento emitido por AccioButton.
func _on_accio_toggled(is_active: bool) -> void

## Activa o desactiva el cursor de remoción y el modo del mouse del sistema.
func _set_cursor_mode(is_removing: bool) -> void

## Procesa el clic izquierdo de remoción sobre la celda dada.
func _try_remove_ally(cell: Vector2i) -> void

## Cancela el modo de remoción y restaura el HUD y cursor.
func _cancel_accio() -> void

## Actualiza el feedback de modulación sobre el aliado apuntado.
func _update_hovered_ally(cell: Vector2i) -> void

## Limpia la referencia y restaura el color del aliado actualmente resaltado.
func _clear_hovered_ally() -> void
```

### Reglas de Entrada (`_unhandled_input`)
1. **Clic Derecho (`MOUSE_BUTTON_RIGHT`) o Tecla `ESC`**:
   - Si `_is_removing == true`: invoca `_cancel_accio()`.
   - Si `_selected_card != null`: invoca `_deselect_card()`.
2. **Clic Izquierdo (`MOUSE_BUTTON_LEFT`)**:
   - Si `_is_removing == true`: invoca `_try_remove_ally(_cell_under_mouse())`.
   - Si `_selected_card != null`: invoca `_try_place_ally()`.

---

## 3. Contrato de Feedback Visual sobre Aliados (`Ally`)

- **Grupo**: Todas las entidades removibles pertenecen al grupo reservado `allies` (`Groups.ALLIES`).
- **Propiedad**: `CanvasItem.modulate`.
- **Valores**:
  - Estado normal: `Color.WHITE` (`Color(1.0, 1.0, 1.0, 1.0)`).
  - Estado hover de Accio: `Color(1.0, 0.4, 0.4, 0.8)` (resaltado rojizo translúcido).
- **Compatibilidad con `DamageFlash`**: La rutina de hover respeta la vida del aliado. Al salir el cursor o ser removido, se restablece limpiamente `Color.WHITE`.
