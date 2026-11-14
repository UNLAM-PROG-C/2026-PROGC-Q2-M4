# Data Model: Sistema de Oleadas Mágicas

## WaveState

Representa el estado de la máquina de oleadas.

| Campo | Tipo | Reglas |
|---|---|---|
| `value` | enum/int | Solo puede ser `SPAWNING_NORMAL`, `WAVE_PREPARATION`, `WAVE_ACTIVE`, `WAITING_FOR_CLEAR`, `FINAL_WAVE_PREPARATION` o `LEVEL_COMPLETE` |
| `is_final` | bool | Verdadero únicamente durante la preparación o actividad de la oleada final |
| `threshold_index` | int | Índice del umbral ya alcanzado; no puede retroceder |

### Transiciones

```text
SPAWNING_NORMAL
  -> WAVE_PREPARATION              al alcanzar un umbral intermedio
  -> FINAL_WAVE_PREPARATION        al agotar la cuota regular y limpiar el tablero

WAVE_PREPARATION
  -> WAVE_ACTIVE                   cuando el hilo principal aplica un WavePlan

WAVE_ACTIVE
  -> WAITING_FOR_CLEAR             después de instanciar la cantidad planificada

WAITING_FOR_CLEAR
  -> SPAWNING_NORMAL               al llegar enemigos activos a cero si quedan spawns
  -> FINAL_WAVE_PREPARATION        al completar la cuota regular

FINAL_WAVE_PREPARATION
  -> WAVE_ACTIVE                   cuando el hilo principal aplica el plan final

WAVE_ACTIVE (final)
  -> LEVEL_COMPLETE                cuando la oleada final termina y no quedan enemigos
```

## BoardSnapshot

Copia para el cálculo concurrente.

| Campo | Tipo | Validación |
|---|---|---|
| `level_generation` | int | Debe coincidir con la generación actual al aplicar el resultado |
| `state` | enum/int | Debe ser un estado válido |
| `regular_defeated` | int | `>= 0` y `<= regular_budget` |
| `regular_budget` | int | `> 0` |
| `active_enemies` | int | `>= 0` |
| `defense_value` | float | `>= 0.0` |
| `is_special_level` | bool | Define 2 o 3 oleadas |
| `threshold_index` | int | No puede superar los umbrales configurados |

## WavePlan

Orden de datos simples calculada por el director.

| Campo | Tipo | Validación |
|---|---|---|
| `level_generation` | int | Debe coincidir con la escena activa |
| `request_id` | int | Único dentro de la generación |
| `wave_number` | int | `> 0` |
| `enemy_count` | int | Intermedia entre 10 y 20; final `>= 25` y mayor que la intermedia |
| `is_final` | bool | Coincide con el estado solicitado |
| `spawn_delay` | float | `>= 0.0`; representa separación del spawn en el hilo principal |
| `row_indices` | Array[int] | Solo filas configuradas por el nivel |

## WaveResult

Resultado producido por el cálculo y consumido por el hilo principal.

| Campo | Tipo | Reglas |
|---|---|---|
| `plan` | WavePlan | Puede ser nulo solo si es cancelación o rechazo |
| `level_generation` | int | Se descarta si es obsoleto |
| `request_id` | int | Se descarta si ya fue aplicado |
| `cancelled` | bool | Impide aplicar la orden |
| `error_code` | int | Debe ser explícito; no se usan fallos silenciosos |

## EnemyBudget

Estado de la cuota del nivel.

| Campo | Tipo | Reglas |
|---|---|---|
| `regular_budget` | int | Total de enemigos regulares del nivel |
| `regular_spawned` | int | No supera la cuota |
| `regular_defeated` | int | No supera los generados |
| `active_enemies` | int | Sube en el hilo principal y baja una vez por `defeated` |
| `intermediate_wave_size` | int | Se almacena para calcular la oleada final |

## DefenseSnapshot

Valor numérico de defensas activas.

| Campo | Tipo | Reglas |
|---|---|---|
| `ally_value` | float | Suma de valores de aliados considerados |
| `spell_value` | float | Suma de hechizos o defensas temporales considerados |
| `total_value` | float | `ally_value + spell_value`, nunca negativo |

La extracción ocurre en el hilo principal; el director recibe solo `total_value` y no retiene referencias a aliados.
