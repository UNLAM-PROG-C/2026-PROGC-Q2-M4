# Research & Technical Decisions: 003-nivel-3-protego

## 1. Patrón arquitectónico para Draco y Protego
- **Decision**: Crear nuevas escenas (`draco.tscn`, `protego.tscn`) con sus propios scripts independientes (`draco.gd`, `protego.gd`), imitando la estructura de `alumno_slytherin` y los aliados existentes, en lugar de forzar una cadena de herencia de clases GDScript.
- **Rationale**: El Principio II de la Constitución establece la reutilización mediante instanciación de escenas. Godot funciona eficientemente con Duck Typing (ej. llamando a `recibir_danio()` si existe en el nodo colisionado). Esto mantiene el código simple y consistente con la arquitectura actual del proyecto.
- **Alternatives considered**: Crear una clase base `Enemigo.gd` y heredar `Draco` de ella. Rechazado por requerir un refactor masivo de los scripts existentes, lo cual viola la directiva de minimizar impacto estructural fuera del scope de la feature.

## 2. Habilitación de 5 líneas funcionales
- **Decision**: La escena `nivel_3.tscn` tendrá un nodo "Spawners" (Node2D) conteniendo exactamente 5 `Marker2D` distribuidos verticalmente. El sistema de grilla (si existe) o de coordenadas de plantado deberá reconocer las nuevas alturas Y.
- **Rationale**: Las oleadas seleccionan un `Marker2D` al azar. Al proveer 5 markers, la lógica de distribución es inmediata. La lógica de HUD/Grilla deberá ajustarse si estaba harcodeada a 3 filas.

## 3. Comportamiento pasivo de Protego
- **Decision**: `protego.tscn` pertenecerá al grupo `aliados`. Tendrá un script con variables `@export` de `salud` muy alta y `coste` = 50. Implementará `recibir_danio(cantidad)`. No tendrá ningún `Timer` de ataque ni nodos de disparos.
- **Rationale**: Cumple el requerimiento FR-006 (no atacar) y FR-007 (salud masiva). Al pertenecer al grupo `aliados`, los enemigos lo detectarán usando la misma lógica de colisión Area2D que ya usan para atacar a los Magos, eliminando la necesidad de programar lógica de detección especial en los enemigos.
