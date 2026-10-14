# Research: Nivel 4 - Remoción con Hechizo Accio

Este documento consolida las decisiones técnicas, patrones y alternativas evaluadas para implementar el Nivel 4 y la mecánica del hechizo Accio (Pala).

## D1: Modelo de Cursor Personalizado e Interacción Visual

- **Decisión**: Implementar un nodo dedicado `Sprite2D` (o icono flotante) como cursor personalizado gestionado por `Level`, activando `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)` durante `ESTADO_REMOVIENDO` y actualizando su posición a `get_global_mouse_position()` en `_process()`.
- **Razón**: 
  - La API de `Input.set_custom_mouse_cursor()` requiere texturas preformateadas en memoria y puede tener inconsistencias de escala entre resoluciones de ventana.
  - Un nodo `Sprite2D` / `CanvasItem` permite usar placeholders inmediatos (cuadrado de color distintivo, icono temático de varita/hechizo), animar o modular libremente y garantizar escala y renderizado coherente en 1920x1080.
  - Al cancelar o finalizar la remoción, se oculta el Sprite y se restablece `Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)`.
- **Alternativas consideradas**:
  - `Input.set_custom_mouse_cursor(texture)`: Descartada por menor flexibilidad para feedback visual dinámico y dependencia de formatos de cursor de la plataforma.
  - Cambiar únicamente la apariencia del botón sin alterar el cursor: Descartada porque incumple HU-1 (el jugador necesita feedback continuo sobre el cursor).

## D2: Exclusión Mutua entre Modos de Plantado y Remoción

- **Decisión**: Extender la máquina de estados de interacción en `Level`:
  - `_selected_card: AllyCard` (modo plantado si != null).
  - `_is_removing: bool` (modo remoción si == true).
  - Al pulsar el botón `Accio`: si `_is_removing` era false, se cancela la carta (`_selected_card = null`), se refresca la interfaz (`_refresh_card_selection()`), y se activa `_is_removing = true`. Si ya era true, se desactiva.
  - Al pulsar cualquier `AllyCardButton`: si `_is_removing` estaba activo, se desactiva Accio, se restaura el cursor y se selecciona la carta normalmente.
  - Al presionar clic derecho o la tecla `ESC` en `_unhandled_input()`: se cancela cualquier modo activo (tanto carta como Accio) y se retorna a estado normal.
- **Razón**: Garantiza que no puedan coexistir acciones contradictorias al hacer clic sobre una celda del tablero.
- **Alternativas consideradas**:
  - Requerir deseleccionar manualmente la carta antes de permitir pulsar Accio: Descartada por fricción innecesaria de usuario (UX inferior).

## D3: Registro de Celdas y Ciclo de Vida de Destrucción de Aliados

- **Decisión**: Utilizar el diccionario existente `_occupied_cells: Dictionary[Vector2i, Ally]` en `Level` para la detección y remoción determinística por coordenadas.
  - Se obtiene la celda bajo el mouse mediante `tile_map.local_to_map(tile_map.get_local_mouse_position())`.
  - Si la celda existe en `_occupied_cells`, se obtiene la referencia al nodo `Ally`.
  - Se borra la entrada del diccionario: `_occupied_cells.erase(cell)`.
  - Se invoca `ally.queue_free()`.
  - Como `_place_ally()` ya conecta `ally.tree_exiting` a `_on_ally_removed(cell)`, la llamada a `_occupied_cells.erase(cell)` asegura que la celda quede disponible de inmediato incluso antes de que finalice el cuadro de proceso del motor.
- **Razón**: No depende de físicas o áreas de colisión para el clic del jugador; el mapeo exacto celda-entidad es instantáneo, O(1) y libre de falsos positivos con proyectiles o enemigos que pasen por encima.
- **Alternativas consideradas**:
  - Raycast o clics por `Area2D` de colisión: Descartada porque los enemigos o proyectiles en la misma celda podrían interceptar el clic, o provocar fallos si el área de colisión del aliado no cubre el 100% de la celda.

## D4: Feedback Visual de Hover sobre Aliados

- **Decisión**: En `_process()`, cuando `_is_removing` esté activo, evaluar la celda actual del mouse:
  - Si hay un aliado en la celda y es distinto al actualmente resaltado (`_hovered_ally`), se restaura el modulate del anterior a `Color.WHITE` y se aplica al nuevo `Color(1.0, 0.4, 0.4, 0.8)` (rojo translúcido).
  - Si el mouse se desplaza a una celda vacía o fuera del tablero, se restaura el modulate y se limpia la referencia `_hovered_ally = null`.
  - Al cancelar o salir de `ESTADO_REMOVIENDO`, se invoca una rutina de limpieza `_clear_hovered_ally()` para garantizar que ningún aliado quede con modulación alterada.
- **Razón**: Proporciona retroalimentación instantánea al jugador sobre qué entidad específica será destruida si hace clic.

## D5: Modularidad y Estándar de Código de Cátedra

- **Decisión**:
  - Crear un botón específico o componente modular `AccioButton` (extends `Button`) en `accio_button.gd` con señal tipada `accio_toggled(active: bool)` y método `set_active(active: bool)`.
  - Mantener todas las funciones del script `level.gd` y `accio_button.gd` bajo la restricción estricta de **<= 15 líneas por función**, dividiendo la lógica en métodos de responsabilidad única:
    - `_handle_accio_input(mouse_event: InputEventMouseButton)`
    - `_try_remove_ally(cell: Vector2i)`
    - `_cancel_accio()`
    - `_update_hovered_ally(cell: Vector2i)`
    - `_clear_hovered_ally()`
- **Razón**: Cumple estrictamente con la regla 4 de `AGENTS.md` (tamaño de métodos <= 15 líneas) y el principio II de la Constitución (modularidad orientada a nodos).
