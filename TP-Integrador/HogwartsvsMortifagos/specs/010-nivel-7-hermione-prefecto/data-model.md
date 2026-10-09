# Data Model: Nivel 7 - Hermione y Prefecto Slytherin

Este documento define las entidades del juego, sus atributos, estados y relaciones para la implementación de Hermione, el Prefecto Slytherin, los hechizos y el Nivel 7.

## 1. Entidad Aliada: Hermione (`Hermione`)

Representa la unidad mágica plantable de ataque con hechizos helados.

- **Herencia**: `Ally` → `Area2D`
- **Grupo Godot**: `allies`
- **Atributos**:
  - `health`: `float` = 300.0 (Salud máxima idéntica a Harry).
  - `shot_interval`: `float` = 1.5 (Segundos entre disparos).
  - `damage`: `float` = 20.0 (Daño por impacto).
  - `projectile_scene`: `PackedScene` (Escena fallback de proyectil).
  - `projectile_pool`: `ProjectilePool` (Pool inyectado para reciclaje).
- **Relaciones**:
  - Pertenece a una celda de la cuadrícula (`Grid` / `TileMapLayer`).
  - Consulta `Lane.enemies_in_lane()` para verificar objetivos antes de disparar.
  - Solicita proyectiles a `ProjectilePool`.

## 2. Entidad Base: Mortífago/Enemigo (`Enemy` - Extensión de Estado)

Adquiere la capacidad de recibir y procesar el estado alterado de ralentización.

- **Atributos nuevos**:
  - `_slow_factor`: `float` = 1.0 (Multiplicador de velocidad de movimiento y DPS, rango [0.70, 1.0]).
  - `_is_slowed`: `bool` = false (Bandera de estado alterado activo).
  - `_base_modulate`: `Color` = Color.WHITE (Color base del sprite: blanco si normal, celeste si ralentizado).
  - `_slow_timer`: `Timer` (Temporizador One Shot con duración de 5.0 segundos).
- **Transiciones de Estado**:
  - `NORMAL`: `_slow_factor = 1.0`, `_base_modulate = Color.WHITE`.
  - `SLOWED`: `_slow_factor = 0.70`, `_base_modulate = Color(0.5, 0.75, 1.0)`.
  - `RENEW_SLOW`: Al recibir nuevo impacto mientras está en `SLOWED`, reinicia temporizador a 5.0s sin reducir `_slow_factor` más allá de 0.70.
  - `SLOW_EXPIRED`: El temporizador llega a cero; regresa al estado `NORMAL`.

## 3. Entidad Enemiga: Prefecto Slytherin (`SlytherinPrefect`)

Representa el primer enemigo con ataque a distancia.

- **Herencia**: `Enemy` → `Area2D`
- **Grupo Godot**: `enemies`
- **Atributos**:
  - `max_health`: `float` = 200.0 (Salud idéntica al Alumno Slytherin común).
  - `speed`: `float` = 32.0 (Velocidad de marcha estándar hacia la izquierda).
  - `shoot_interval`: `float` = 3.5 (Intervalo de recarga de disparo).
  - `projectile_scene`: `PackedScene` (Escena de `enemy_projectile.tscn`).
  - `_is_shooting`: `bool` = false (Pausa temporal de movimiento para animar el disparo).
- **Transiciones de Estado**:
  - `WALKING`: Avanza en el eje X hacia la izquierda a `speed * _slow_factor`.
  - `SHOOTING`: Se detiene temporalmente, verifica la presencia de aliados a su izquierda mediante `Lane.has_allies_in_lane_ahead()`, lanza `EnemyProjectile` hacia la izquierda y retoma la marcha.
  - `MELEE_ATTACK`: Si colisiona cuerpo a cuerpo con un aliado, ataca por contacto directo (`take_damage` continuo) al igual que otros enemigos.

## 4. Entidad Proyectil Enemigo (`EnemyProjectile`)

Representa el ataque mágico a distancia disparado por el Prefecto Slytherin.

- **Herencia**: `Area2D`
- **Grupo Godot**: `enemy_projectiles` (o detecta grupo `allies`)
- **Capas y Máscaras**:
  - `collision_layer`: 0
  - `collision_mask`: 1 (Detecta la capa donde habitan los aliados)
- **Atributos**:
  - `speed`: `float` = 400.0 (Desplazamiento horizontal en px/s hacia la izquierda).
  - `damage`: `float` = 20.0 (Daño aplicado al colisionar con un aliado).
  - `animation_frame_duration`: `float` = 0.08 (Duración de cada uno de los 4 fotogramas).
  - `_animation_elapsed`: `float` = 0.0 (Acumulador delta).
- **Comportamiento**:
  - Recorre la fila hacia la izquierda ciclando continuamente entre los 4 fotogramas de `slytherin_shot.png`.
  - Colisión con `Ally`: Aplica `ally.take_damage(damage)` y se destruye (`queue_free()`).
  - Salida de pantalla: `VisibleOnScreenNotifier2D` libera el nodo.

## 5. Extensión de Proyectil Aliado (`Projectile` y `ProjectilePool`)

Permite proyectiles con efecto helado reutilizables en el pool.

- **Atributos en `Projectile`**:
  - `slows`: `bool` = false
  - `slow_factor`: `float` = 0.70
  - `slow_duration`: `float` = 5.0
- **Comportamiento en `ProjectilePool`**:
  - `acquire_projectile(spawn_position, custom_damage, slows = false)`: Configura el proyectil, modula en azul si `slows == true`.
  - Al regresar al pool: Resetea `slows = false` y `modulate = Color.WHITE`.

## 6. Recurso de Carta: Hermione (`hermione_card.tres`)

- **Tipo**: `AllyCard`
- **Propiedades**:
  - `display_name`: `"Hermione"`
  - `scene`: `res://hermione.tscn`
  - `cost`: 125
  - `cooldown`: 7.5 (o 5.0) segundos

## 7. Configuración del Nivel 7 (`level_7.tscn`)

- **Script**: `res://level.gd`
- **Propiedades exportadas**:
  - `active_rows`: `[2, 3, 4, 5, 6]` (5 líneas activas)
  - `starting_snitches`: 150
  - `total_enemies`: 25
  - `enemy_scenes`:
    1. `res://slytherin_student.tscn`
    2. `res://draco.tscn`
    3. `res://protego_student.tscn`
    4. `res://slytherin_prefect.tscn`
  - `next_level_to_unlock`: 8
  - `dementor_rows_y`: `[320.0, 448.0, 576.0, 704.0, 832.0]` (5 Dementores)
  - Banco de Cartas en HUD:
    1. `HarryCardButton` (Harry - 100)
    2. `SnitchBoxCardButton` (Caja de Snitch - 50)
    3. `RonCardButton` (Ron - 125)
    4. `RemembrallCardButton` (Recordadora - 150)
    5. `ProtegoCardButton` (Protego - 50)
    6. `BroomstickCardButton` (Escoba - 125)
    7. `HermioneCardButton` (Hermione - 125)
    8. `AccioButton` (Accio - 0)
