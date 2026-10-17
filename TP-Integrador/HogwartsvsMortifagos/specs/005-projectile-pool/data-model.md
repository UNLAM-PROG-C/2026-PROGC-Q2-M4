# Data Model: Projectile Object Pool

## ProjectilePool

Administrador de las instancias reutilizables durante la vida de un nivel.

| Campo | Tipo conceptual | Reglas |
|---|---|---|
| `projectile_scene` | Escena de proyectil | Obligatoria; fuente de las instancias precalentadas y ampliadas |
| `initial_capacity` | Entero | Fijo en 50 |
| `growth_batch` | Entero | Fijo en 10 |
| `available_projectiles` | Colección de proyectiles | Solo contiene instancias inactivas |
| `active_projectiles` | Colección de proyectiles | Solo contiene instancias activas |
| `owner_level` | Nivel actual | El pool no sobrevive al nivel propietario |

### Invariantes

- Un proyectil pertenece a exactamente una colección: disponibles o activos.
- La capacidad comienza en 50 y solo crece en incrementos de 10.
- Una solicitud usa un elemento disponible antes de ampliar.
- Ningún método del pool modifica nodos desde un hilo secundario.

## ReusableProjectile

Instancia de `projectile.tscn` que alterna entre estados inactivo y activo.

| Campo | Tipo conceptual | Reglas |
|---|---|---|
| `lifecycle_state` | Estado | `inactive` o `active` |
| `global_position` | Vector2 | Se establece al activar |
| `speed` | Número | Se conserva la configuración existente y se reinicia el movimiento |
| `has_hit` | Booleano | Debe ser `false` al activar; pasa a `true` como máximo una vez por ciclo |
| `animation_elapsed` | Número | Debe comenzar en cero al activar |
| `sprite_frame` | Entero | Debe comenzar en el primer cuadro al activar |
| `collision_monitoring` | Booleano | Activo solo durante el estado activo |
| `visible` | Booleano | Visible solo durante el estado activo |

## PoolRequest

Solicitud de activación emitida por un aliado que dispara.

| Campo | Tipo conceptual | Reglas |
|---|---|---|
| `spawn_position` | Vector2 | Punto inicial del disparo |
| `source` | Aliado solicitante | Debe ser una referencia válida al solicitar |
| `projectile_parameters` | Configuración existente | No altera el daño ni la animación actuales |

## PoolReturn

Resultado de la finalización del ciclo activo.

| Causa | Acción |
|---|---|
| Impacto contra `enemies` | Aplicar daño una vez, crear la explosión visual y devolver |
| Salida de pantalla | No aplicar daño adicional y devolver |
| Reinicio/cambio de nivel | Desactivar sin daño y limpiar referencias |

### Transiciones

```text
inactive --activate--> active
active --enemy impact--> inactive
active --screen exit--> inactive
active --level reset--> inactive
inactive --level teardown--> released with owner level
```
