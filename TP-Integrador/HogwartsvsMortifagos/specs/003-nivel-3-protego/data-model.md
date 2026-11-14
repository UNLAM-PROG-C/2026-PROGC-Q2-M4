# Data Model & State: 003-nivel-3-protego

## Entities de Escena (Godot Nodes)

### Draco (`draco.tscn` / `draco.gd`)
- **Tipo Base**: `Area2D`
- **Grupos**: `enemigos`
- **Atributos (`@export`)**:
  - `vida`: `float` (Ej. 200, diseñado para ser el doble de un Alumno Slytherin estándar)
  - `danio_por_segundo`: `float` (Daño continuo aplicado a aliados al colisionar)
  - `velocidad`: `float` (Velocidad de avance en eje X negativo)
- **Funciones Principales**:
  - `recibir_danio(cantidad: float) -> void`
  - Lógica de detección de áreas para colisión con `aliados`.

### Protego (`protego.tscn` / `protego.gd`)
- **Tipo Base**: `Area2D`
- **Grupos**: `aliados`
- **Atributos (`@export`)**:
  - `coste`: `int` (50)
  - `tiempo_recarga`: `float` (Entre 10.0 y 15.0)
  - `salud`: `float` (Ej. 4000.0, valor masivo de barrera)
- **Estado Interno**:
  - `_tiempo_flash`: Para el efecto visual de daño (reutilizado del fix de aliados).
  - `_cooldown_flash`: Tiempo de respiro entre flashes visuales.
- **Funciones Principales**:
  - `recibir_danio(cantidad: float) -> void`
  - Emisión de señal `derrotado` al llegar a salud cero para notificar a la celda/nivel.

### Nivel 3 (`nivel_3.tscn`)
- **Estado de Escena**:
  - `Spawners`: Nodo contenedor con 5 hijos `Marker2D` con distintas coordenadas Y correspondientes a las 5 filas visuales del mapa.
  - Generador de oleadas instanciará aletoriamente enemigos básicos o Dracos.
