# Technical Research: Nivel 7 - Hermione y Prefecto Slytherin

## Decision 1: Mecánica de Ralentización en la clase base `Enemy`

- **Decisión**: Implementar el estado de ralentización directamente en `Enemy` (`enemy.gd`), exponiendo `apply_slow(factor: float, duration: float) -> void`.
- **Detalle**:
  - Se añade una variable de estado `_slow_factor: float = 1.0` y un `Timer` interno (One Shot) `_slow_timer`.
  - El movimiento horizontal en `_process` se multiplica por `_slow_factor`: `position.x -= speed * _slow_factor * delta`.
  - El daño por segundo al atacar un aliado se escala por el mismo factor: `_target_ally.take_damage(damage_per_second * _slow_factor * delta)`.
  - Cuando se llama a `apply_slow(factor, duration)`:
    - Se fija `_slow_factor = minf(_slow_factor, factor)` asegurando que nunca sea menor a `0.70` (30% de ralentización máxima).
    - Se reinicia el temporizador de duración (5.0s).
    - Se actualiza el color base a un tinte azul celeste `Color(0.5, 0.75, 1.0)`.
  - Al expirar el temporizador (`timeout`):
    - Se restablece `_slow_factor = 1.0`.
    - Se restaura el color base a `Color.WHITE`.
- **Justificación**: Centralizar la ralentización en la clase base `Enemy` permite que cualquier tipo de enemigo (Alumno Slytherin, Draco, Alumno con Protego, Prefecto Slytherin) responda automáticamente al hechizo de hielo de Hermione sin duplicar lógica en subclases.
- **Alternativas consideradas**:
  - *Manejar ralentización como un componente Node hijo separado*: Rechazado por complejidad innecesaria para un estado alterado simple y para cumplir con las directrices de métodos cortos de la cátedra.
  - *Subclase específica de enemigo ralentizable*: Rechazado porque todos los enemigos deben ser ralentizables por diseño de juego.

---

## Decision 2: Compatibilidad de Proyectiles y ProjectilePool con Hechizos Helados

- **Decisión**: Extender `ProjectilePool` y `Projectile` para admitir proyectiles con propiedad `slows: bool = false`, o permitir que Hermione dispare a través de `acquire_projectile` configurando `slows = true` y tiñendo el sprite de azul `Color(0.3, 0.6, 1.0)`.
- **Detalle**:
  - `Projectile` incluye `@export var slows: bool = false`, `@export var slow_factor: float = 0.7`, `@export var slow_duration: float = 5.0`.
  - En `_on_area_entered` de `projectile.gd`:
    ```gdscript
    enemy.take_damage(damage)
    if slows and enemy.has_method("apply_slow"):
        enemy.apply_slow(slow_factor, slow_duration)
    ```
  - Al regresar al pool (`_return_to_pool`), `slows` se resetea a `false` y `sprite.modulate = Color.WHITE`.
  - `ProjectilePool.acquire_projectile(spawn_position, custom_damage, slows = false)` configura el proyectil activado.
- **Justificación**: Reutiliza la arquitectura de pool de memoria existente de alta eficiencia sin requerir un pool secundario ni instanciaciones dinámicas por disparo.
- **Alternativas consideradas**:
  - *Instanciar una escena separada `hermione_projectile.tscn` en cada disparo sin pool*: Rechazado porque contradice el principio de rendimiento y pooling establecido en el hito 005.

---

## Decision 3: Coexistencia entre `DamageFlash` y el Tinte de Ralentización

- **Decisión**: Permitir que `Enemy` coordine la modulación de su sprite para que el flash de daño rojo de `DamageFlash` no sobreescriba permanentemente el tinte azul cuando el enemigo está ralentizado.
- **Detalle**:
  - En `Enemy`, se almacena el color base actual (`_base_modulate: Color = Color.WHITE`), que es azul si está ralentizado y blanco si es normal.
  - Al terminar el flash o actualizar textura, `sprite.modulate = _base_modulate`.
- **Justificación**: Previene el error visual de que un impacto de proyectil restaure el sprite a blanco inmediatamente antes de que terminen los 5 segundos de ralentización.
- **Alternativas consideradas**:
  - *Desactivar DamageFlash mientras está ralentizado*: Rechazado porque privaría al jugador de la retroalimentación de impacto crítico.

---

## Decision 4: Enemigo a Distancia `SlytherinPrefect` y Detección de Aliados

- **Decisión**: Crear `slytherin_prefect.gd` heredando de `Enemy`, reutilizando la textura `Images/slytherin_protego.png` (sin el nodo `ShieldSprite`).
- **Detalle**:
  - Propiedades: `max_health = 200.0`, `shoot_interval = 3.5`.
  - Dispone de un `Timer` interno `shoot_timer`.
  - Al activarse el timer, verifica si hay aliados en su fila hacia la izquierda mediante el helper `Lane.has_allies_in_lane_ahead(get_tree(), global_position.y, global_position.x)`.
  - Si hay un aliado adelante, se detiene brevemente (pausa de movimiento de 0.5s), reproduce la postura de varita e instancia `EnemyProjectile`.
  - Si no hay aliados adelante, continúa caminando sin disparar.
- **Justificación**: Cumple con la resolución de la clarificación previa de no disparar al vacío cuando el carril está despejado.
- **Alternativas consideradas**:
  - *Disparo incondicional periódico*: Rechazado explícitamente en la sesión de clarificación.
  - *RayCast2D*: Rechazado para evitar nodos de física extra cuando `Lane` ya ofrece detección limpia y probada basada en grupos y coordenadas.

---

## Decision 5: `EnemyProjectile` y Animación por Sprite Sheet

- **Decisión**: Crear una escena ligera `enemy_projectile.tscn` con script `enemy_projectile.gd`.
- **Detalle**:
  - Nodo raíz `Area2D`, `collision_layer = 0`, `collision_mask = 1` (detecta aliados).
  - Sprite2D con textura `res://Images/slytherin_shot.png`, `hframes = 4, vframes = 1` (dimensiones por fotograma: 140x52 px).
  - Ciclo de animación: `frame = (frame + 1) % 4` cada 0.08s (idéntico al frame timing de `Projectile`).
  - Velocidad: 400.0 px/s hacia la izquierda (`Vector2.LEFT`).
  - Al colisionar con un área en grupo `allies`:
    ```gdscript
    if area.is_in_group(Groups.ALLIES):
        (area as Ally).take_damage(damage)
        queue_free()
    ```
- **Justificación**: Estructura simple, reactiva y desacoplada que respeta estrictamente los requerimientos visuales de `slytherin_shot.png`.
- **Alternativas consideradas**:
  - *Reutilizar ProjectilePool para proyectiles enemigos*: Rechazado porque la cadencia enemiga es mucho más baja y el proyectil viaja en sentido opuesto con lógica de colisión inversa (máscara de aliados).

---

## Decision 6: Escenario Nivel 7 y Composición del Mazo

- **Decisión**: Crear `level_7.tscn` derivado de la arquitectura de niveles existente, con 5 carriles activos, 5 Dementores, 8 cartas aliadas en HUD y 4 tipos de enemigos en la tabla de oleadas.
- **Detalle**:
  - `active_rows = [2, 3, 4, 5, 6]`.
  - HUD contiene 8 botones: Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba, Hermione y Accio.
  - `enemy_scenes`: Alumno Slytherin, Draco, Alumno con Protego, Prefecto Slytherin.
  - `next_level_to_unlock = 8`.
- **Justificación**: Permite al jugador experimentar la sinergia completa de todas las cartas aprendidas a lo largo de la campaña.
