# Technical Research & Decisions: Nivel 6 - Escoba y Alumno con Protego

## Decision 1: Arquitectura y Mecánica de la Escoba (`Broomstick`)

- **Decision**: Implementar la Escoba como la entidad `broomstick.gd` (clase `Broomstick` que extiende de `Ally`) y su escena `broomstick.tscn` (`Area2D` con colisión en grupo `allies` o detección de `enemies`). Al ser plantada, se registra en la fila seleccionada, se libera de inmediato la celda de la cuadrícula en `level.gd` (para no bloquear plantados futuros), y la Escoba inicia su desplazamiento horizontal a velocidad constante `speed = 600.0` px/s desde el margen izquierdo (`X = 0` o inicio del césped) hacia el borde derecho.
- **Rationale**: Reproduce la experiencia clásica del Jalapeño: el jugador invierte 125 snitches en una fila crítica y el barrido limpia la totalidad de la línea de izquierda a derecha. Utiliza un diccionario interno `_damaged_enemies: Dictionary[int, bool]` para garantizar que cada enemigo en la fila reciba exactamente un impacto de daño masivo (1800 puntos) sin detener el avance de la escoba. Al rebasar `X > 1950.0`, invoca `queue_free()`.
- **Alternatives considered**:
  - *Disparar una ráfaga estática de ancho de pantalla*: Descartado porque la especificación exige explícitamente una animación de desplazamiento horizontal (la Escoba barriendo a lo largo del eje X).
  - *Matar enemigos instantáneamente (instakill)*: Descartado por requerimiento explícito del usuario (aplica daño masivo numérico igual a la Recordadora, no muerte instantánea de dementor).

## Decision 2: Composición Multiparte y Máquina de Salud del Alumno con Protego (`ProtegoStudent`)

- **Decision**: Crear `protego_student.gd` (clase `ProtegoStudent` que extiende de `Enemy`) y la escena `protego_student.tscn`. La escena contiene:
  - `$Sprite2D`: Representa el cuerpo del alumno. Utiliza inicialmente `res://Images/slytherin_protego.png` (`hframes = 8`). Al destruirse el escudo, transiciona a `res://Images/slytherin.png`.
  - `$ShieldSprite`: Nodo hijo `Sprite2D` posicionado a la izquierda del alumno (`position.x = -35.0`), que carga `res://Images/protego.png` (`hframes = 3`, escala aproximada `(0.12, 0.12)`).
  - Variables de salud separadas: `@export var shield_max_health: float = 300.0` y `_shield_health: float = 300.0`, junto con `max_health = 200.0` (salud base).
- **Rationale**: Mantiene el desacoplamiento entre la capa de armadura mágica y la entidad física del estudiante. Al sobreescribir `take_damage(amount: float)`, el daño se descuenta primero del escudo, calculando el daño de desborde (`overflow_damage`) si el impacto supera la salud restante del escudo, aplicándolo limpiamente a la salud base con `super.take_damage(overflow)`.
- **Alternatives considered**:
  - *Crear dos nodos Area2D independientes (uno para el escudo y otro para el alumno)*: Generaría colisiones dobles complejas, interceptación de proyectiles no deseada y problemas de sincronización de movimiento entre nodos padre e hijo.

## Decision 3: Degradación Visual en 3 Estados del Escudo

- **Decision**: Mapear la salud del escudo directamente a los 3 frames de `res://Images/protego.png`:
  - `_shield_health > 200.0` (>66% de 300): `shield_sprite.frame = 0` (escudo brillante intacto).
  - `_shield_health > 100.0` (entre 33% y 66%): `shield_sprite.frame = 1` (fracturas intermedias).
  - `_shield_health > 0.0` (<=33%): `shield_sprite.frame = 2` (fisuras críticas).
  - `_shield_health <= 0.0`: `shield_sprite.visible = false` y cambio de textura base a `slytherin.png`.
- **Rationale**: Utiliza la textura existente `Images/protego.png` (que ya posee `hframes = 3` verificados en `protego.tscn`) sin requerir assets externos ni shaders adicionales.
- **Alternatives considered**:
  - *Modulación de color alfa*: Menos expresivo que los fotogramas de rotura nativos de la textura.

## Decision 4: Animaciones de Ataque Dinámicas

- **Decision**: Mientras `_shield_health > 0.0`, cuando el enemigo entra en estado atacante contra un aliado, no ejecuta la animación de mordida en `$Sprite2D` (mantiene frame 0 o marcha estática); en su lugar, un temporizador u oscilación en `_process` desplaza horizontalmente `$ShieldSprite` hacia adelante y hacia atrás simulando golpes de escudo. Cuando el escudo es destruido, pasa inmediatamente a la animación de ataque estándar `slytherin_attacking.png` (y su variante `slytherin_attacking_hurt.png` si su vida base cae al 50%).
- **Rationale**: Cumple fielmente con la HU-4 y proporciona una distinción visual contundente entre el asalto con escudo y la agresión cuerpo a cuerpo desprotegida.

## Decision 5: Configuración del Nivel 6

- **Decision**: Crear `level_6.tscn` heredando la arquitectura de `Level`:
  - 5 líneas activas (`active_rows = [2, 3, 4, 5, 6]`), 5 Dementores defensivos.
  - Grilla calibrada en `position = Vector2(24, -128)`, `scale = Vector2(1.25, 1.25)`.
  - Mazo con 6 cartas: Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50), Escoba (125), más herramienta Accio.
  - Enemigos: `enemy_scenes = [slytherin_student, draco, protego_student]`.
  - Cuota de enemigos: `total_enemies = 30`.
  - Cadencia de spawn: `wait_time = 4.5` s (alta densidad).
  - Desbloqueo: `next_level_to_unlock = 7`.
- **Rationale**: Escalado de dificultad natural que consolida las mecánicas de defensas pesadas y control de masas de línea.
