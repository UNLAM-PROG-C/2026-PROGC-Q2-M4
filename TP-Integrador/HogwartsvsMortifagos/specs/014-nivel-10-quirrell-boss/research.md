# Architectural Research: Nivel 10 - Batalla contra Jefe Final (Quirrell / Voldemort)

**Feature Branch**: `014-nivel-10-quirrell-boss` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

## Decisiones Arquitectónicas

### 1. Entidad del Jefe Final (`quirrell.tscn` y `quirrell.gd`)

- **Decisión**: Crear una escena dedicada `quirrell.tscn` con script `quirrell.gd` que extiende de `Area2D` y pertenece al grupo `enemies`.
- **Estructura de nodos**:
  - `Quirrell` (`Area2D`, grupo `enemies`, layer 2, mask 0)
    - `Sprite2D` (textura `res://Images/quirrell.png`)
    - `TurbanSprite` (`Sprite2D`, textura `res://Images/quirrell_turban.png`, hijo directo posicionado sobre la cabeza)
    - `FeetShadow` (`Sprite2D`, textura `res://Images/character_shadow.png`, visible durante teletransporte)
    - `CollisionShape2D` (`RectangleShape2D` ajustada al tamaño del sprite)
    - `TeleportTimer` (`Timer`, `wait_time = 20.0`, `autostart = true`)
    - `InvocationTimer` (`Timer`, `wait_time = 15.0`, `autostart = true`)
    - `DamageFlash` (componente reutilizable de parpadeo al recibir daño)
- **Comportamiento**:
  - En `_process(delta)` NO se desplaza hacia la izquierda (`speed = 0.0`), manteniéndose anclado en su carril.
  - Implementa `take_damage(amount: float) -> void` compatible con proyectiles y explosiones (`Remembrall`, `Broomstick`).
  - Emite `health_changed(current_health: float, max_health: float)` y `defeated(entity: Node2D)`.
- **Justificación**: Cumple con el principio de responsabilidad única y la arquitectura basada en escenas y nodos de Godot 4, asegurando que todos los proyectiles y hechizos existentes lo reconozcan automáticamente como objetivo mediante el grupo `enemies`.
- **Alternativas descartadas**:
  - Heredar directamente de `Enemy`: `Enemy` tiene lógica fija de desplazamiento `global_position.x -= speed * delta` hacia el jardín y chequeo de invasión `GARDEN_EDGE_X`. Extender `Area2D` con interfaz compatible (`take_damage`, grupo `enemies`) evita acoplamientos innecesarios o sobreescritura sucia del loop de movimiento.

---

### 2. Mecánica de Teletransporte e Interacción con la Cuadrícula

- **Decisión**: El teletransporte se ejecuta cada 20 segundos mediante `TeleportTimer`.
  - Origen: Se reproduce un efecto visual de sombra en sus pies (`FeetShadow`) y se oculta momentáneamente el sprite.
  - Selección de destino: Se elige al azar una de las otras 4 filas activas (excluyendo la fila actual).
  - Posicionamiento: Se ancla a la columna 8 (la última columna de la cuadrícula, celda X = 1280).
  - Destrucción de aliados en destino: Si la celda de destino está ocupada en `Level._occupied_cells`, se invoca `take_damage(INSTAKILL_DAMAGE)` en el aliado para destruirlo instantáneamente.
  - Bloqueo de plantación: En `Level._can_place_at(cell: Vector2i)`, se verifica si `cell == quirrell_cell`; si coincide, se deniega la plantación devolviendo `false`.
- **Justificación**: Mantiene la integridad del modelo de cuadrícula de Hogwarts vs Mortífagos sin duplicar estados de celdas ni generar inconsistencias espaciales.
- **Alternativas descartadas**:
  - Permitir plantar en la celda de Quirrell: Crearía superposición de sprites confusa y problemas con áreas de colisión superpuestas.

---

### 3. Enemigo Invocado "Sombra" (`shadow_enemy.tscn` y `shadow_enemy.gd`)

- **Decisión**: Crear una escena `shadow_enemy.tscn` con script `shadow_enemy.gd` que extiende de `Enemy`.
  - Textura visual: `res://Images/character_shadow.png` modulada o silueta espectral animada.
  - Vida máxima (`max_health`): 200.0 puntos (igual al Alumno Slytherin).
  - Daño por segundo (`damage_per_second`): 30.0 puntos (igual al Alumno Slytherin).
  - Velocidad (`speed`): 48.0 px/s (exactamente 1.5x de los 32.0 px/s estándar).
- **Justificación**: Reutiliza toda la infraestructura de movimiento por carril, ataque cuerpo a cuerpo a aliados y recepción de daño de la clase `Enemy`, asegurando compatibilidad completa con proyectiles, enlentecimiento de Hermione, congelamiento y explosiones.
- **Alternativas descartadas**:
  - Crear un nodo ad-hoc sin heredar de `Enemy`: Obligaría a reimplementar detección de aliados, daño periódico y registro de muerte.

---

### 4. Barra de Vida del Jefe en la Interfaz (`BossHealthBar`)

- **Decisión**: Implementar `BossHealthBar` en el `HUD` del nivel:
  - Tipo de nodo: `TextureProgressBar` o `ProgressBar` estilizado con temática de pergamino/dorado de Hogwarts, visible en la parte superior central de la pantalla.
  - Rango: `min_value = 0.0`, `max_value = 36000.0`, `value = 36000.0`.
  - Conexión: Conectada a la señal `health_changed(current_health, max_health)` de Quirrell.
  - Reemplazo del HUD: En el Nivel 10, el nodo `WaveProgressBar` (reloj de arena de oleadas) permanece `visible = false`, garantizando que la barra del jefe tenga preponderancia absoluta.
- **Justificación**: Proporciona feedback visual instantáneo del combate, reforzando la sensación épica del enfrentamiento final.
- **Alternativas descartadas**:
  - Reutilizar el reloj de arena para la vida del jefe: Confundiría al jugador al romper la semántica de "progreso temporal/bajas" del reloj.

---

### 5. Flujo del Nivel 10 y Resolución de Victoria

- **Decisión**:
  - Escena: `level_10.tscn` con fondo `res://Images/final_background.png` y 5 filas activas (`[2, 3, 4, 5, 6]`).
  - Spawning: Genera enemigos regulares de soporte de todos los tipos existentes mediante `EnemySpawnTimer`.
  - Quirrell: Se instancia al inicio del nivel en la columna 8 de una fila activa.
  - Señal de derrota: Al recibir el daño final (`health <= 0`), Quirrell emite `defeated`.
  - Limpieza y Victoria: El nivel captura la derrota de Quirrell, detiene los temporizadores de spawn, recorre todos los nodos en el grupo `enemies` y los elimina/derrota automáticamente, disparando el modal de victoria final del juego.
- **Justificación**: Cumple estrictamente con la decisión acordada en la sesión de clarificación, brindando un clímax definitivo y satisfactorio.
