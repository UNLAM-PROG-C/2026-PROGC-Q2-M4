# Research & Technical Decisions: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Feature Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]` | **Date**: 2026-10-07

## 1. Mecanismo de Disparo en Ráfaga de McGonagall (`mcgonagall.gd`)

### Contexto
McGonagall requiere disparar una ráfaga ininterrumpida de 4 proyectiles secuenciales separados por ~0.15 segundos cada vez que detecta un enemigo en su carril, entrando luego en un tiempo de recarga base de 1.5 segundos antes de poder iniciar la siguiente ráfaga.

### Decisión
Implementar un sistema de dos temporizadores acoplados pero no bloqueantes dentro de la escena `mcgonagall.tscn`:
1. `ShootTimer` (`one_shot = true`, `wait_time = 1.5s`): Controla el período de recarga base entre ráfagas completas.
2. `BurstTimer` (`one_shot = false`, `wait_time = 0.15s`): Controla el intervalo entre disparos consecutivos dentro de una misma ráfaga.

**Flujo de ejecución:**
- `_ready()`: Inicia `ShootTimer` con `shot_interval` (1.5s).
- `_on_shoot_timer_timeout()`: Si detecta al menos un enemigo en su fila con `Lane.enemies_in_lane()`, establece `_shots_remaining = burst_count` (4), ejecuta el primer disparo inmediatamente mediante `_fire_burst_shot()` y arranca `BurstTimer` con `burst_interval` (0.15s). Si no hay enemigos, reinicia `ShootTimer`.
- `_on_burst_timer_timeout()`: Ejecuta `_fire_burst_shot()`. Si `_shots_remaining <= 0`, detiene `BurstTimer` e inicia `ShootTimer` con `shot_interval`.
- Si McGonagall muere o sale del Scene Tree, `BurstTimer` se detiene automáticamente y `_shots_remaining` se restablece a 0, evitando proyectiles huérfanos o timers pendientes.

### Justificación
- Elimina el uso de `await get_tree().create_timer()` dentro de bucles, el cual puede disparar proyectiles fantasmas tras la destrucción de la unidad si el nodo es liberado.
- Permite dividir la lógica en funciones pequeñas con responsabilidad única de menos de 15 líneas cada una, cumpliendo con la regla de la cátedra.

### Alternativas Consideradas
- **Bucle `for` con `await`**: Rechazado porque si la entidad muere o el nivel termina durante los 0.6s de la ráfaga, las corrutinas de `await` continúan en memoria provocando accesos a referencias nulas (`null instance`).
- **Un único Timer con acumulador delta en `_process`**: Rechazado por innecesaria complejidad matemática y potencial desacoplamiento del frame-rate.

---

## 2. Reutilización y Rendimiento de Proyectiles (`projectile_pool.gd`)

### Contexto
Con una cadencia de 4 proyectiles cada 1.65 segundos por cada McGonagall en el tablero, una defensa de varias líneas puede generar más de 20 proyectiles volando simultáneamente.

### Decisión
Reutilizar directamente el `ProjectilePool` central del nivel.
- Cada proyectil de la ráfaga se adquiere mediante `projectile_pool.acquire_projectile(shoot_point.global_position)`.
- El proyectil reutiliza la escena estándar `projectile.tscn` sin modificaciones ni tintes especiales (conforme a la decisión de la Sesión de Clarificación 2026-10-07), manteniendo velocidad horizontal constante de +400 px/s y 20 de daño base.
- El pool de 50 proyectiles con auto-expansión garantiza 0 asignación dinámica en memoria durante las ráfagas intensivas.

### Justificación
- Evita recolección de basura y congelamiento de fotogramas (micro-stuttering).
- Mantiene consistencia estética y funcional con el resto de atacantes aliados (Harry).

---

## 3. Extensión de 3 Grandes Oleadas y Retroalimentación en Pantalla (`level.gd`)

### Contexto
El Nivel 8 extiende el combate a 3 grandes picos de dificultad: dos oleadas intermedias y una oleada final. Además, los textos en pantalla deben advertir la aproximación de cada hito.

### Decisión
Aprovechar la arquitectura de soporte para niveles especiales ya existente en `level.gd`:
- `is_special_level = true` configura:
  - `SPECIAL_FIRST_WAVE_RATIO = 0.33` (hito 1: ~15 bajas de 45).
  - `SPECIAL_SECOND_WAVE_RATIO = 0.66` (hito 2: ~30 bajas de 45).
  - `max_intermediate_waves = 2`.
  - `required_thresholds = 2` para habilitar la Oleada Final.
- Enriquecer los textos visibles de advertencia en `level.gd`:
  - `const WAVE_ANNOUNCEMENT_TEXT: String = "¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"`
  - `const FINAL_WAVE_ANNOUNCEMENT_TEXT: String = "¡OLEADA FINAL!"`
  - En `_show_wave_announcement()`: verificar si `_final_wave_active` está activo para mostrar `FINAL_WAVE_ANNOUNCEMENT_TEXT`; en caso contrario, mostrar `WAVE_ANNOUNCEMENT_TEXT`.

### Justificación
- Cumple con la regla de Cátedra: textos en español bajo constantes descriptivas con sufijo `_TEXT`.
- Permite reutilizar íntegramente el `WaveDirector` sin modificar su lógica asíncrona multi-hilo ni romper compatibilidad con los niveles 1 al 7.

---

## 4. Configuración del Nivel 8 (`level_8.tscn`)

### Contexto
El nivel debe desafiar al jugador en las 5 líneas completas con los 4 tipos de enemigos existentes y acceso al banco completo de 9 cartas.

### Decisión
Configuración específica para `level_8.tscn`:
- `total_enemies = 45`
- `is_special_level = true`
- `active_rows = [2, 3, 4, 5, 6]`
- 5 Dementores defensivos en el carril izquierdo.
- `next_level_to_unlock = 9`
- `enemy_scenes`: `[slytherin_student.tscn, draco.tscn, protego_student.tscn, slytherin_prefect.tscn]`
- HUD con 9 botones de cartas:
  1. Harry (100)
  2. Snitch Box (50)
  3. Ron (125)
  4. Recordadora (150)
  5. Protego (50)
  6. Escoba (125)
  7. Hermione (125)
  8. McGonagall (200)
  9. Accio (0)

---

## 5. Asset Gráfico de McGonagall (`Images/mcgonagall.png`)

### Contexto
La textura de McGonagall debe mantener el estilo visual e iconografía de los personajes existentes (Harry, Ron, Hermione, que poseen resolución estándar de 130x130 con fondo transparente).

### Decisión
Proveer un sprite representativo `Images/mcgonagall.png` de 130x130 píxeles con fondo transparente, mostrando a la profesora McGonagall con túnica oscura/esmeralda y sombrero puntiagudo de hechicera.
