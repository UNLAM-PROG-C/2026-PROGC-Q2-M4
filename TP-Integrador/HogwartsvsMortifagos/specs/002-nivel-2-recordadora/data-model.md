# Modelo de Datos: Nivel 2 y la Recordadora

**Branch**: `002-nivel-2-recordadora`  
**Feature**: Nivel 2 — Expansión a 3 Líneas y la Recordadora  
**Fecha**: 2026-09-29  

---

## 1. Entities Principales

### Entidad: Recordadora (`recordadora.gd`)
Representa la planta-bomba de área (rol Cereza Explosiva).

- **Herencia**: `Area2D`
- **Grupos**: `aliados`
- **Capas de Física**:
  - `collision_layer`: `1` (Capa 1: Aliados — permite que los enemigos la detecten y ataquen)
  - `collision_mask`: `0`
- **Área Hija `AreaExplosion` (`Area2D`)**:
  - `collision_layer`: `0`
  - `collision_mask`: `2` (Capa 2: Enemigos — detecta exclusivamente Alumnos Slytherin)
  - `shape`: `RectangleShape2D` de 384×384 px (cobertura 3×3 celdas centradas)

#### Propiedades
| Campo | Tipo | Valor Inicial | Descripción |
|---|---|---|---|
| `salud` | `int` | `100` | Puntos de vida antes de detonar. Si llega a 0, se destruye sin explotar. |
| `coste` | `int` | `150` | Coste en Snitches para plantarla. |
| `tiempo_detonacion` | `float` | `1.5` | Segundos que transcurren desde el plantado hasta la explosión. |
| `danio_explosion` | `int` | `1800` | Daño letal aplicado a cada enemigo en el radio de 3×3 celdas. |
| `detonando` | `bool` | `false` | Indica si el temporizador de explosión está activo. |

#### Señales
```gdscript
signal detonada(posicion: Vector2)
signal destruida_sin_explotar()
```

#### Máquina de Estados
```text
[PLANTADA] 
    │
    ├── (timer 1.5s transcurre) ──> [ANIMACION_PULSO / TWEEN] ──> [EXPLOSION (1800 daño a Capa 2)] ──> [QUEUE_FREE]
    │
    └── (salud <= 0 por ataque enemigo) ──> [DESTRUIDA] ──> [QUEUE_FREE (sin daño)]
```

---

### Entidad: Configuración Nivel 2 (`nivel_2.gd` / `nivel_principal.gd`)
Controla la sesión del Nivel 2, el tablero expandido y la lógica de oleada multilínea.

- **Herencia**: `Node2D` (extiende o parametriza `NivelPrincipal`)

#### Propiedades
| Campo | Tipo | Valor Inicial | Descripción |
|---|---|---|---|
| `filas_activas` | `Array[int]` | `[3, 4, 5]` | Filas jugables en la grilla del TileMap (coordenadas Y entre 384 y 768). |
| `filas_bloqueadas` | `Array[int]` | `[2, 6]` | Filas cubiertas por `BloqueoMagico` que rechazan plantado. |
| `total_enemigos` | `int` | `20` | Cuota de Alumnos Slytherin requerida para ganar el nivel. |
| `tiempo_spawneo` | `float` | `6.0` | Intervalo regular en segundos entre apariciones enemigas. |
| `snitches_iniciales` | `int` | `150` | Saldo inicial de Snitches. |
| `intervalo_snitches_cielo` | `float` | `10.0` | Intervalo de caída de Snitches celestes de 25 unidades. |
| `posiciones_dementores_y` | `Array[float]` | `[320.0, 448.0, 576.0, 704.0, 832.0]` | Posición Y de los 5 Dementores a X=160.0. |

#### Estado en Ejecución
| Campo | Tipo | Descripción |
|---|---|---|
| `snitches` | `int` | Saldo actual disponible. |
| `enemigos_generados` | `int` | Contador acumulado de enemigos spawneados. |
| `enemigos_derrotados` | `int` | Contador acumulado de enemigos eliminados. |
| `nivel_terminado` | `bool` | Flag que bloquea acciones al ganar o perder. |

---

### Componente: Carta HUD Recordadora
Controla la disponibilidad, costo y enfriamiento de la Recordadora en la barra de cartas.

- **Herencia**: `Button` en `HUD`

#### Propiedades y Variables
| Campo | Tipo | Valor Inicial | Descripción |
|---|---|---|---|
| `coste` | `int` | `150` | Snitches requeridas para comprar. |
| `tiempo_recarga` | `float` | `25.0` | Duración del cooldown tras plantar. |
| `tiempo_recarga_restante` | `float` | `0.0` | Cuenta regresiva en segundos hasta volver a habilitarse. |

#### Regla de Habilitación
```gdscript
boton_recordadora.disabled = (snitches < 150) or (tiempo_recarga_restante > 0.0)
```
