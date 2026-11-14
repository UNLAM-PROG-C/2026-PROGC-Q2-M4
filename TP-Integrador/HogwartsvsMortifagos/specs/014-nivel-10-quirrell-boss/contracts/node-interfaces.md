# Node Interfaces & Contracts: Nivel 10 - Quirrell Boss

**Feature Branch**: `014-nivel-10-quirrell-boss` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

## Contratos de Nodos y Señales

### 1. `Quirrell` (`quirrell.gd` extends `Area2D`)

Entidad del jefe final. Pertenece al grupo `enemies`.

#### Señales

| Señal | Parámetros | Cuándo se emite |
|---|---|---|
| `health_changed` | `current_health: float, max_health: float` | Cada vez que Quirrell recibe daño. |
| `defeated` | `entity: Node2D` | Cuando `health <= 0.0`. |
| `shadow_spawn_requested` | `spawn_position: Vector2, lane_y: float` | En timeout de invocación simple (Fase 1 o 90% en Fase 2). |
| `mass_shadow_spawn_requested` | Ninguno | En timeout de invocación definitiva (10% en Fase 2). |
| `teleported` | `from_cell: Vector2i, to_cell: Vector2i` | Al completarse el teletransporte a una nueva fila. |

#### Métodos Públicos

| Método | Firma | Descripción |
|---|---|---|
| `take_damage` | `func take_damage(amount: float) -> void` | Reduce la salud de Quirrell, gestiona transición de fases y emite señales. |
| `teleport_to` | `func teleport_to(new_row: int, destination_position: Vector2) -> void` | Teletransporta a Quirrell al carril indicado y actualiza su celda. |
| `get_current_cell` | `func get_current_cell() -> Vector2i` | Retorna la celda de la cuadrícula actualmente ocupada. |

#### Grupos

- `enemies` (estrictamente requerido para detección por proyectiles, colisiones y hechizos masivos).

---

### 2. `ShadowEnemy` (`shadow_enemy.gd` extends `Enemy`)

Esbirro rápido invocado por Quirrell. Pertenece al grupo `enemies`.

#### Señales (heredadas de `Enemy`)

| Señal | Parámetros | Cuándo se emite |
|---|---|---|
| `defeated` | `entity: Node2D` | Cuando la salud de la sombra llega a 0. |
| `garden_invaded` | Ninguno | Si la sombra sobrepasa `GARDEN_EDGE_X`. |

#### Métodos Públicos

| Método | Firma | Descripción |
|---|---|---|
| `take_damage` | `func take_damage(amount: float) -> void` | Recibe daño de proyectiles y explosiones. |
| `apply_slow` | `func apply_slow(factor: float, duration: float) -> void` | Ralentización compatible con Hermione. |

#### Grupos

- `enemies`

---

### 3. `BossHealthBar` (`boss_health_bar.gd` extends `Control`)

Componente del HUD para la barra de vida superior del jefe.

#### Métodos Públicos

| Método | Firma | Descripción |
|---|---|---|
| `initialize_bar` | `func initialize_bar(max_hp: float) -> void` | Configura el valor máximo y estado inicial de la barra. |
| `set_health` | `func set_health(current_hp: float) -> void` | Actualiza el valor visual de la barra de vida. |
