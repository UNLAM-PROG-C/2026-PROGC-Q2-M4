# Node & Interface Contracts: Sistema Híbrido de Oleadas y Medidor Visual

## 1. Contrato del Componente `WaveProgressBar`

### Escena: `res://wave_progress_bar.tscn`
- **Nodo Raíz**: `WaveProgressBar` (`Control`)
- **Hijos**:
  - `ProgressBar`: `TextureProgressBar`

### Script: `res://wave_progress_bar.gd`
```gdscript
class_name WaveProgressBar
extends Control

@onready var _bar: TextureProgressBar = $ProgressBar

func setup(max_kills: int, frame_texture: Texture2D) -> void:
  _bar.max_value = float(max_kills)
  _bar.value = 0.0
  _bar.texture_over = frame_texture

func update_progress(current_kills: int) -> void:
  _bar.value = float(current_kills)
```

---

## 2. Contrato de la Entidad `Enemy`

### Señales
- `signal defeated(entity: Node2D)`: Emitida **únicamente** cuando `health <= 0` tras recibir daño de aliados o proyectiles.
- `signal garden_invaded()`: Emitida cuando el enemigo cruza la línea de defensa (`global_position.x < 0`). **No** debe emitir `defeated`.

---

## 3. Contrato de Configuración en `Level` (`level.gd`)

### Variables Exportadas
```gdscript
@export var wave_kill_thresholds: Array[int] = [15, 20]
@export var wave_meter_texture: Texture2D
```

### Configuración por Nivel en Escenas (`level_1.tscn` a `level_9.tscn`)
- `level_1.tscn` a `level_7.tscn`:
  - `wave_meter_texture`: `preload("res://Images/wave_meter_2_waves.png")`
  - Umbrales respectivos según la matriz de `research.md`.
- `level_8.tscn` y `level_9.tscn`:
  - `wave_meter_texture`: `preload("res://Images/wave_meter_3_waves.png")`
  - Umbrales respectivos (`[20, 40, 60]` y `[30, 40, 70]`).

### Métodos del Ciclo de Oleadas en `level.gd`
- `_on_enemy_defeated(entity: Node2D) -> void`:
  - Registra baja válida si el enemigo no fue procesado.
  - Incrementa `_phase_defeated_enemies` y `_total_defeated_enemies`.
  - Actualiza el medidor del HUD: `_wave_progress_bar.update_progress(_total_defeated_enemies)`.
  - Evalúa `_check_wave_threshold()`.
- `_check_wave_threshold() -> void`:
  - Si `_wave_state != STATE_SPAWNING_NORMAL`, retorna.
  - Compara `_phase_defeated_enemies >= wave_kill_thresholds[_current_phase_index]`.
  - Si se cumple y no es la última fase: detiene `enemy_spawn_timer`, resetea `_phase_defeated_enemies = 0`, incrementa `_current_phase_index` y llama `_request_wave(false)`.
  - Si se cumple y es la última fase: detiene `enemy_spawn_timer`, resetea `_phase_defeated_enemies = 0`, fija `_final_wave_active = true` y llama `_request_wave(true)`.
- `_resume_after_wave() -> void`:
  - Si `_active_enemies == 0`:
    - Si `_final_wave_active`: llama a `_win()`.
    - Si no: `_wave_state = STATE_SPAWNING_NORMAL` y `enemy_spawn_timer.start()`.
