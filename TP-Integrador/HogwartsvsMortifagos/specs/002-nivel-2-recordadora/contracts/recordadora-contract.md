# Contrato de Interfaz: Recordadora (`recordadora.tscn`)

**Branch**: `002-nivel-2-recordadora`  
**Fecha**: 2026-09-29  

---

## 1. Identificación y Grupos

- **Nodo Raíz**: `Area2D`
- **Grupos asignados**: `["aliados"]`
- **Capas físicas**:
  - `collision_layer`: `1` (Aliados)
  - `collision_mask`: `0`

## 2. API Pública de la Entidad (`recordadora.gd`)

```gdscript
class_name Recordadora
extends Area2D

## Señal emitida al producirse la detonación en el área.
signal detonada(posicion: Vector2)
## Señal emitida si la entidad es destruida por un enemigo antes de detonar.
signal destruida_sin_explotar()

## Coste en Snitches de la entidad.
@export var coste: int = 150
## Tiempo en segundos antes de que ocurra la detonación.
@export var tiempo_detonacion: float = 1.5
## Daño infligido a cada enemigo alcanzado por la explosión.
@export var danio_explosion: int = 1800
## Salud propia antes de detonar.
@export var salud: int = 100

## Inicia el ciclo de detonación con animación de aviso.
func iniciar_detonacion() -> void

## Método estándar de recepción de daño conforme a la arquitectura del proyecto.
func recibir_danio(cantidad: int) -> void

## Ejecuta la detonación, consulta las áreas de enemigos y aplica daño masivo.
func detonar() -> void
```

## 3. Protocolo de Explosión y Colisión

1. **Sub-nodo `AreaExplosion` (`Area2D`)**:
   - `collision_layer`: `0`
   - `collision_mask`: `2` (detecta exclusivamente Capa 2: Enemigos)
   - `Shape2D`: Rectángulo de `Vector2(384.0, 384.0)` (área de 3×3 celdas centrada en la planta).
2. **Impacto**:
   - Para cada `area` detectada en `AreaExplosion.get_overlapping_areas()`:
     - Verificar `area.is_in_group("enemigos")` o si su nodo propietario tiene método `recibir_danio`.
     - Invocar `area.recibir_danio(danio_explosion)`.
3. **Exclusión de Aliados**:
   - Físicamente imposible de impactar a aliados dado que `AreaExplosion` tiene `collision_mask = 2` y no consulta la Capa 1.
