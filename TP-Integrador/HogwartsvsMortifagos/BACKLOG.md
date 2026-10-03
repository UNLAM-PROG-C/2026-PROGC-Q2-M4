# Feature 1: Núcleo y Nivel 1.
- [x] Como jugador quiero una grilla de 1 línea que empiece con 150 snitches.
- [x] Como jugador quiero plantar a "Harry" (100 de costo) y que dispare.
- [x] Como jugador quiero plantar una "Caja de Snitch" (50 de costo) que genere 1 snitch (25 de valor) periódicamente.
- [x] Como jugador quiero que aparezca el "Alumno Slytherin" como enemigo básico.

# Feature 2: Progresión de Defensas (Niveles 2 al 6).
- [ ] Como jugador quiero expandir la grilla de 3 a 5 líneas.
- [ ] Como jugador quiero desbloquear "Recordadora" (Costo 150, explosión área) y "Protego" (Costo 50, pared).
- [ ] Como jugador quiero usar "Accio" para remover aliados de la grilla.
- [ ] Como jugador quiero que aparezca "Draco" (más vida) y "Alumno con Protego".

# Feature 3: Enemigos Avanzados y Jefe Final (Niveles 7 al 10).
- [ ] Como jugador quiero desbloquear a "Ron", "Hermione" y "McGonagall" (Ametralladora).
- [ ] Como jugador quiero enfrentar al "Prefecto Slytherin" (destruye aliados rápido) y al "Troll" (Gigante).
- [ ] Como jugador quiero enfrentar al "Profesor Quirrell" en el nivel 10 (Jefe con barra de vida que invoca sombras y no avanza, cambia de línea).

## Plan técnico: Nivel 1 - Tareas de implementación

### Setup de Escenas

- [x] Configurar `TileMapLayer`, `Spawners/Marker2D3` y la conexión de `EnemySpawnTimer` en `level_1.tscn` (`level.gd`).
- [x] Configurar la línea central como única línea activa y mantener visibles las otras cuatro líneas con bloqueo mágico.
- [x] Deshabilitar `Marker2D`, `Marker2D2`, `Marker2D4` y `Marker2D5` para plantación y spawneo en Nivel 1.
- [x] Crear `harry.tscn` con `Area2D` raíz, `CollisionShape2D`, `ShootTimer` y referencia exportada a `projectile.tscn`.
- [x] Crear `snitch_box.tscn` con `Area2D` raíz, `CollisionShape2D` y `SnitchTimer`.
- [x] Crear `slytherin_student.tscn` con `Area2D` raíz, `CollisionShape2D` y área de detección/ataque.
- [x] Crear `projectile.tscn` con `Area2D` raíz, `CollisionShape2D` y `VisibleOnScreenNotifier2D`.
- [x] Asignar los grupos `allies`, `enemies` y `spells` a las escenas correspondientes.
- [x] Crear `snitch.tscn` y `SnitchSpawnTimer` para la caída y recolección de Snitches del cielo.

### Lógica de Movimiento

- [x] Instanciar los Alumnos Slytherin desde `Spawners/Marker2D3` en la línea central.
- [x] Implementar el avance del Alumno Slytherin desde la derecha hacia el jardín usando `delta`.
- [x] Restringir el movimiento y el spawneo a la línea central activa.
- [x] Implementar el desplazamiento de los proyectiles de Harry hacia los enemigos usando `delta`.
- [x] Liberar los proyectiles fuera de pantalla mediante `VisibleOnScreenNotifier2D`.

### Detección de Daño

- [x] Configurar detección de `spells` sobre `enemies` mediante `Area2D`.
- [x] Implementar el disparo de Harry cada 1.5 segundos cuando exista un Alumno Slytherin válido en su línea.
- [x] Aplicar 20 puntos de daño por impacto de proyectil y 200 puntos de vida iniciales al Alumno Slytherin.
- [x] Validar objetivos con Grupos, `Area2D` e `is_instance_valid()`, sin comparar nombres de nodos.
- [x] Ignorar impactos de `spells` sobre `allies` y bloquear la interacción jugable en líneas deshabilitadas.

### Economía

- [x] Inicializar el saldo del jugador en 150 Snitches y evitar saldos negativos.
- [x] Descontar 100 Snitches al plantar Harry y rechazar la acción si no alcanza el saldo.
- [x] Descontar 50 Snitches al plantar la Caja de Snitch y rechazar la acción si no alcanza el saldo.
- [x] Generar 25 Snitches cada 10 segundos desde la Caja de Snitch.
- [x] Generar Snitches que caen del borde superior cada 5 segundos y se recolectan al hacer clic.
- [x] Actualizar la interfaz del HUD en tiempo real con el saldo y habilitación de botones.
