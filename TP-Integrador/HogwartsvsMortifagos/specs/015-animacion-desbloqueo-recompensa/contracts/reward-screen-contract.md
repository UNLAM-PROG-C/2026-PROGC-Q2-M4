# Contract: RewardUnlockScreen Interface & Level Integration

**Feature**: `015-animacion-desbloqueo-recompensa`  
**Date**: 2026-10-12

## 1. `RewardUnlockScreen` Public Interface

```gdscript
class_name RewardUnlockScreen
extends CanvasLayer

signal reward_dismissed(level_number: int)

## Public Methods
func setup(level_num: int, item_texture: Texture2D, description: String) -> void:
    ...

func skip_animation() -> void:
    ...
```

### Signals
- `reward_dismissed(level_number: int)`: Emitida cuando el jugador presiona el botón "Continuar". Indica a `Level` que puede proceder a desplegar `LevelEndPanel`.

### Visual Parameters & Layout (1920x1080)
- `BASE_RESOLUTION`: `Vector2(1920, 1080)`
- `ANIMATION_DURATION`: `1.2` segundos (rango permitido: 1.0 a 2.0s).
- `ROTATION_TURNS`: `2.0` vueltas completas (`4.0 * PI` radianes).
- `INITIAL_SCALE`: `Vector2(0.1, 0.1)`
- `FINAL_SCALE`: `Vector2(2.5, 2.5)`
- `START_POSITION`: `Vector2(960, 540)` (centro exacto de la pantalla).
- `RESTING_POSITION`: `Vector2(960, 420)` (ligeramente elevado para dar espacio armónico al texto descriptivo).
- `LABEL_BOUNDS`: Anchura fija de `1400` píxeles centrada horizontalmente, ubicada verticalmente entre `Y = 620` y `Y = 880`.
- `CONTINUE_BUTTON`: Ubicado en `Vector2(960, 940)` con texto `"Continuar"`.

---

## 2. Text Content Constants

Los textos visibles deben coincidir de forma exacta con la especificación:

- `LEVEL_1_DESC_TEXT`: `"¿Olvidaste algo? Su humo rojo se vuelve tan inestable que estalla mágicamente, fulminando al instante a los enemigos en un radio cercano."`
- `LEVEL_2_DESC_TEXT`: `"¿Necesitas tiempo? Este poderoso encantamiento crea una sólida barrera mágica que detiene a los mortífagos en seco, absorbiendo daño para proteger tus defensas."`
- `LEVEL_3_DESC_TEXT`: `"¿Necesitas espacio? Usa el hechizo convocador Accio para retirar instantáneamente a cualquier aliado del campo de batalla y reorganizar tu estrategia mágica."`
- `LEVEL_4_DESC_TEXT`: `"¡Pura potencia! Aunque le toma un momento extra preparar su ataque, los hechizos de Ron golpean con una fuerza aplastante que destroza al enemigo."`
- `LEVEL_5_DESC_TEXT`: `"¡A despejar el camino! Esta veloz escoba cruza el campo volando, barriendo una línea entera y fulminando a todos los mortífagos a su paso."`
- `LEVEL_6_DESC_TEXT`: `"¿Demasiado rápidos? Hermione conjura precisos hechizos gélidos que ralentizan el avance de los mortífagos, devolviéndote el control absoluto de la batalla."`
- `LEVEL_7_DESC_TEXT`: `"¿Peligro inminente? La profesora McGonagall desata una ráfaga implacable de cuatro hechizos consecutivos, destrozando velozmente hasta las defensas más resistentes de los mortífagos."`
- `LEVEL_8_DESC_TEXT`: `"¿Magia suprema? Dumbledore lanza un poderoso encantamiento frontal que detona al impactar, dañando simultáneamente a múltiples mortífagos en su zona de explosión."`
- `LEVEL_10_DESC_TEXT`: `"¡Has protegido la legendaria Piedra Filosofal! Gracias a tu brillante estrategia mágica, lograste derrotar a Quirrell y frustrar los oscuros planes de Voldemort. Este invaluable tesoro es el trofeo definitivo que consagra tu gran victoria. ¡Muchísimas gracias por jugar y defender los terrenos de Hogwarts hasta el final!"`
- `CONTINUE_BUTTON_TEXT`: `"Continuar"`

---

## 3. Integration Contract with `Level` (`level.gd`)

En `level.gd`:

```gdscript
func _win() -> void:
    _stop_level()
    _unlock_next_level()
    if _should_show_reward_unlock():
        _show_reward_unlock()
    else:
        _show_victory_panel()

func _on_reward_unlock_dismissed(level_num: int) -> void:
    var game_manager: Node = get_node_or_null("/root/GameManager")
    if game_manager != null and game_manager.has_method("claim_reward"):
        game_manager.call("claim_reward", level_num)
    _show_victory_panel()
```

- Este flujo desacopla limpiamente la pantalla de recompensa, garantizando que el panel de fin de nivel (`LevelEndPanel`) se muestre al terminar la cinemática o inmediatamente si el nivel no posee recompensa o ya fue completado previamente.
