# Data Model & State Transitions: Nivel 10 - Quirrell Boss

**Feature Branch**: `014-nivel-10-quirrell-boss` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

## Entidades y Componentes

### 1. Quirrell (`quirrell.gd` extends `Area2D`)

Representa al jefe final en la cuadrícula. Pertenece al grupo `enemies`.

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `max_health` | `float` | `36000.0` | Salud máxima calculada para resistir 20 explosiones masivas de 1800. |
| `health` | `float` | `36000.0` | Puntos de vida actuales del jefe. |
| `current_phase` | `int` | `1` | Fase del combate: `1` (con turbante) o `2` (sin turbante / Voldemort). |
| `current_row` | `int` | `4` | Fila actual en la que se encuentra posicionado (2 a 6). |
| `current_cell` | `Vector2i` | `Vector2i(8, 4)` | Coordenada de celda de la cuadrícula ocupada por el jefe. |
| `teleport_time` | `float` | `20.0` | Intervalo fijo en segundos entre teletransportaciones. |
| `invocation_time_phase_1` | `float` | `15.0` | Intervalo de invocación de sombras en Fase 1. |
| `invocation_time_phase_2` | `float` | `8.0` | Intervalo de invocación de sombras en Fase 2. |
| `ultimate_attack_chance` | `float` | `0.10` | Probabilidad de invocar sombras en las 5 líneas simultáneamente en Fase 2. |

#### Ciclo de Vida y Transición de Fases

```text
[Inicio Nivel 10]
       │
       ▼
┌───────────────────────────────────────────────┐
│                   FASE 1                      │
│ - Vida: 18000.0 < health <= 36000.0           │
│ - Sprite del turbante visible ($TurbanSprite) │
│ - Invocación: 1 Sombra en carril cada 15s     │
│ - Teletransporte: cada 20s                    │
└───────────────────────┬───────────────────────┘
                        │ health <= 18000.0 (<= 50%)
                        ▼
┌───────────────────────────────────────────────┐
│                   FASE 2                      │
│ - Vida: 0.0 < health <= 18000.0               │
│ - Turbante cae / oculto ($TurbanSprite falso) │
│ - Rostro de Voldemort visible en la nuca      │
│ - Invocación: cada 8s                         │
│   • 90%: 1 Sombra en carril actual            │
│   • 10%: Habilidad Definitiva (5 líneas)      │
│   • Teletransporte: cada 20s                  │
└───────────────────────┬───────────────────────┘
                        │ health <= 0.0
                        ▼
┌───────────────────────────────────────────────┐
│                  DERROTADO                    │
│ - Emite señal `defeated`                      │
│ - Destrucción/derrota de enemigos remanentes  │
│ - Disparo del modal de Victoria Final         │
└───────────────────────────────────────────────┘
```

---

### 2. Sombra (`shadow_enemy.gd` extends `Enemy`)

Enemigo espectral rápido invocado por el jefe. Pertenece al grupo `enemies`.

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `max_health` | `float` | `200.0` | Salud idéntica a un Alumno Slytherin básico. |
| `speed` | `float` | `48.0` | Velocidad de movimiento hacia la izquierda (1.5x de 32.0 px/s). |
| `damage_per_second` | `float` | `30.0` | Daño por segundo infligido al atacar a un aliado. |

---

### 3. Barra de Vida del Jefe (`BossHealthBar`)

Componente de interfaz en el `HUD` que muestra la salud del jefe en tiempo real.

| Propiedad | Tipo | Valor | Descripción |
|---|---|---|---|
| `min_value` | `float` | `0.0` | Valor mínimo de salud. |
| `max_value` | `float` | `36000.0` | Valor máximo (salud inicial de Quirrell). |
| `value` | `float` | `36000.0` | Valor actual reflejado visualmente. |
| `visible` | `bool` | `true` | Visible en Nivel 10; el reloj de oleadas permanece oculto. |

---

### 4. Nivel 10 (`level_10.tscn` / `level.gd`)

Coordinador del escenario de batalla final.

| Atributo | Tipo | Valor | Descripción |
|---|---|---|---|
| `is_boss_level` | `bool` | `true` | Identifica que el nivel se rige por la vida del jefe y no por oleadas. |
| `active_rows` | `Array[int]` | `[2, 3, 4, 5, 6]` | Carriles jugables de la cuadrícula. |
| `boss_instance` | `Quirrell` | Instancia | Referencia a Quirrell en la escena. |
| `boss_cell` | `Vector2i` | `Vector2i(8, row)` | Celda actualmente ocupada por Quirrell, bloqueada para plantación. |
