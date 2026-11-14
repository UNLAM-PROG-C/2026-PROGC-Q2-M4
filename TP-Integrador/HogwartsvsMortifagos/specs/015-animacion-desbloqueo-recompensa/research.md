# Research: Animación de Desbloqueo de Recompensa al Ganar Nivel

**Feature**: `015-animacion-desbloqueo-recompensa`  
**Date**: 2026-10-12

## R-001: Efecto visual de fondo desenfocado (Blur) en Godot 4 Compatibility

- **Decision**: Utilizar un nodo `ColorRect` a pantalla completa (1920x1080) con un shader `CanvasItem` que tome lectura de pantalla (`hint_screen_texture`) para desenfoque por muestras gaussianas/caja, acompañado de una atenuación semitransparente oscura `Color(0.04, 0.04, 0.07, 0.85)`.
- **Rationale**: El renderizador Compatibility de Godot 4 soporta `hint_screen_texture` en shaders de materiales `CanvasItem`. Combinar el desenfoque con una atenuación semitransparente asegura contraste visual de alta fidelidad para el texto descriptivo y la semilla, garantizando legibilidad total incluso sobre fondos complejos o dinámicos.
- **Alternatives considered**:
  - *Capturar viewport en Image y aplicar blur por software*: Descartado por penalización de rendimiento en frames al pausar.
  - *Solo oscurecimiento sin shader*: Descartado porque la especificación exige explícitamente "fondo blurreado".

## R-002: Cinemática de Zoom In Giratorio de la Semilla

- **Decision**: Emplear un `Tween` programático de Godot 4 configurado en paralelo (`set_parallel(true)`) sobre un contenedor central (`seed_anchor: Control` o `seed_icon: TextureRect`).
- **Rationale**: Un `Tween` permite sincronizar con exactitud la curva de aceleración/desaceleración (`TRANS_CUBIC`, `EASE_OUT`), interpolando simultáneamente:
  - `scale`: desde `Vector2(0.05, 0.05)` en el centro de la pantalla hasta `Vector2(2.5, 2.5)` (o tamaño de escala de visualización objetivo).
  - `rotation`: desde `0.0` hasta un múltiplo angular (por ejemplo `PI * 4.0`, dos giros completos).
  - `position`: desde el centro exacto `Vector2(960, 540)` hacia la posición de reposo superior `Vector2(960, 420)` para dejar espacio armónico al bloque de texto inferior.
- **Alternatives considered**:
  - *AnimationPlayer*: Descartado por requerir archivos de recursos adicionales o pistas rígidas embebidas en la escena, mientras que un `Tween` permite cancelar/omitir instantáneamente con `kill()`.

## R-003: Mecanismo de Salto de Animación (Skip / Omitir)

- **Decision**: Manejar el evento de clic de omisión mediante `_gui_input` sobre el nodo raíz `Control` de `RewardUnlockScreen` (o filtro de eventos `mouse_filter = MOUSE_FILTER_STOP`).
- **Rationale**: Si el usuario hace clic o presiona la pantalla mientras el estado de la cinemática es `ANIMATING`:
  1. Se detiene el `Tween` activo (`_tween.kill()`).
  2. Se colocan las propiedades de la semilla en su valor final de reposo (`rotation = 0.0`, `scale = FINAL_SCALE`, `position = FINAL_POS`).
  3. Se hace visible de inmediato el texto descriptivo y el botón "Continuar".
  4. Se transiciona el estado interno a `RESTING`.
- **Alternatives considered**:
  - *Botón transparente dedicado*: Añade complejidad en el árbol de nodos innecesariamente cuando el nodo raíz `Control` captura clics nativamente.

## R-004: Integración en `level.gd` y Conexión con `LevelEndPanel`

- **Decision**: Preload de `reward_unlock_screen.tscn` en `level.gd`. En `_win()`, antes de mostrar `_show_end_panel()`, comprobar si el nivel tiene recompensa y si aún no fue reclamada (`!GameManager.is_reward_claimed(level_number)`):
  - Si aplica recompensa: instanciar `RewardUnlockScreen`, pasarle la configuración `RewardData` del nivel actual, conectarse a su señal `reward_dismissed(level_number: int)` y agregarlo como hijo del `CanvasLayer` `$HUD`.
  - Al emitirse `reward_dismissed`: registrar la recompensa como reclamada en `GameManager`, destruir la pantalla de recompensa y llamar al método habitual `_show_end_panel(WIN_TITLE_TEXT, win_message, true)`.
  - Si no aplica recompensa (Nivel 9 o niveles ya completados): proceder directamente a `_show_end_panel()`.
- **Rationale**: Cumple a la perfección con la arquitectura de nodos y escenas de Godot y las reglas de la cátedra (funciones breves $\le 15$ líneas, comunicación por señales fuertemente tipadas).

## R-005: Persistencia de Recompensas Reclamadas en `GameManager`

- **Decision**: Extender `game_manager.gd` con una estructura de datos `var claimed_rewards: Dictionary[int, bool] = {}` y métodos tipados `claim_reward(level_num: int) -> void` y `is_reward_claimed(level_num: int) -> bool`.
- **Rationale**: `GameManager` ya es el Singleton de sesión del proyecto (`game_manager.gd`). Esto garantiza que al rejugar un nivel no se repita la cinemática, respetando la aclaración aprobada por el usuario.

## R-006: Recurso Visual para la Piedra Filosofal (Nivel 10)

- **Decision**: Generar e incorporar `res://Images/trophy_philosophers_stone.png` como icono estilizado de piedra preciosa carmesí/rubí brillante mágica para el trofeo de la Piedra Filosofal.
- **Rationale**: Cumple el requisito de edge case del spec ("placeholder visualmente coherente de joya/piedra mágica de color rubí") sin dejar enlaces rotos ni texturas nulas.
