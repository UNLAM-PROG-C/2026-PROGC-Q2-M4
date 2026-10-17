# Research & Technical Decisions: Nivel 9 - Dumbledore y el Troll Colosal

**Feature Branch**: `[012-nivel-9-dumbledore-troll]` | **Date**: 2026-10-08

## 1. Mecánica de Daño en Área 3x3 de Dumbledore (`dumbledore.gd` / `dumbledore_projectile.gd`)

### Contexto
Dumbledore es la unidad pesada de daño en área (equivalente a Melon-pult en Plants vs. Zombies pero con disparo en línea recta horizontal sin parábola). Al impactar a un enemigo o escudo, debe provocar una detonación de 3x3 celdas (afectando la fila de impacto, la fila superior y la fila inferior en un radio de ~384x384 px) infligiendo a todos los enemigos dentro del área un daño exactamente igual al disparo estándar de Harry (20 puntos).

### Decisión
Diseñar la entidad aliada y su proyectil con dos escenas y scripts separados:
1. `dumbledore.tscn` / `dumbledore.gd` (`class_name Dumbledore extends Ally`):
   - Costo: 300 snitches (definido en `dumbledore_card.tres`).
   - Salud base: 300 HP.
   - Cadencia: `shot_interval = 3.0` s.
   - Detección de línea mediante `Lane.enemies_in_lane(get_tree(), global_position.y)`.
   - Disparo horizontal mediante instancia de `dumbledore_projectile.tscn` en `ShootPoint.global_position`.
   - Textura visual explícita: `res://Images/dumbledore.png`.
2. `dumbledore_projectile.tscn` / `dumbledore_projectile.gd` (`class_name DumbledoreProjectile extends Area2D`):
   - Textura: `res://Images/dumbledore_shot.png` (uid://tlcaashchsh0).
   - Movimiento: `position.x += speed * delta` con velocidad horizontal constante `speed = 350.0` px/s.
   - Detección de impacto: `area_entered` sobre el grupo `Groups.ENEMIES` (capa 2).
   - Detonación de splash: al colisionar, activa un área de splash secundaria (`SplashArea` de 384x384 px con `RectangleShape2D`) y obtiene todos los enemigos alcanzados con `splash_area.get_overlapping_areas()`. Para garantizar máxima robustez ante entidades en el mismo fotograma, también valida los enemigos en el radio de 3x3 celdas (`HALF_EXTENT = 192.0` px) iterando sobre `tree.get_nodes_in_group(Groups.ENEMIES)`.
   - Aplica `enemy.take_damage(splash_damage)` con `splash_damage = 20.0` a cada enemigo en el área.
   - Instancia el efecto visual `ImpactExplosion` (`impact_explosion.tscn`) y se destruye inmediatamente con `queue_free()`.

### Justificación
- Garantiza que la detonación afecte exactamente a los enemigos de la fila actual, superior e inferior sin desbordar el área.
- Elimina cualquier física balística compleja asegurando una respuesta inmediata y predecible en el eje X.
- Mantiene los métodos con menos de 15 líneas de código cumpliendo con la regla de la cátedra.

### Alternativas Consideradas
- **Reutilizar `ProjectilePool` común para Dumbledore**: Descartado debido a que el proyectil de Dumbledore posee lógica de splash damage 3x3, textura única (`dumbledore_shot.png`) y ciclo de vida de detonación especializado, distinto del proyectil lineal simple de Harry y McGonagall.
- **Daño concentrado en el objetivo primario y menor en el splash**: Descartado por requerimiento explícito del usuario: todo enemigo dentro de la caja de explosión recibe exactamente el daño normal de Harry (20.0 HP).

---

## 2. Lógica del Troll Colosal y Animaciones (`troll.gd` / `troll.tscn`)

### Contexto
El Troll representa la amenaza colosal de fuerza bruta (equivalente al Gargantuar). La escena `troll.tscn` ya cuenta con nodos visuales esqueletales y un `AnimationPlayer` con las animaciones `"Walk"` y `"attack"`. El Troll debe avanzar continuamente a la izquierda, pausar brevemente al encontrar un aliado para reproducir `"attack"` y aplastarlo con instakill (9999 de daño), reanudar su marcha con `"Walk"`, y resistir exactamente 2 impactos de daño masivo (1800 de Escoba o Recordadora) con 3600 de vida total.

### Decisión
1. Modificar la raíz de `troll.tscn` para convertirla en `Area2D` con script `res://troll.gd` (`class_name Troll extends Enemy`), agregando un `CollisionShape2D` y un `AttackArea` sin modificar en absoluto los nodos visuales existentes (`Troll_Body`, brazos, piernas, taparrabos) ni su `AnimationPlayer`.
2. Parámetros y balance en `troll.gd`:
   - `max_health = 3600.0` (fijado matemáticamente para resistir exactamente 2 golpes masivos de 1800.0).
   - `speed = 20.0` px/s (marcha pesada y amenazante).
   - `damage_instakill = 9999.0` (garantiza la destrucción instantánea de cualquier aliado, incluyendo Protego).
3. Ciclo de ataque (resultado de la clarificación):
   - Mientras no esté en combate, reproduce en bucle la animación `"Walk"` y avanza (`position.x -= speed * delta`).
   - Al detectar un aliado en `AttackArea` (`area.is_in_group(Groups.ALLIES)`):
     - Pausa su avance (`_is_attacking = true`).
     - Reproduce la animación `"attack"` en `AnimationPlayer`.
     - Aplica 9999 de daño al aliado mediante `target_ally.take_damage(damage_instakill)`.
     - Al terminar la animación de ataque (o tras un intervalo de golpe calibrado), verifica si aún hay aliados en su celda frontal; de no haberlos, restablece la animación a `"Walk"` y reanuda su marcha.
4. Sobrescritura de `take_damage(amount)`:
   - Recibe el daño, activa el destello de daño y emite `defeated(self)` al llegar a 0 de salud.
   - Un impacto de 1800 (Escoba o Recordadora) reduce su vida de 3600 a 1800 (50%). Un segundo impacto reduce su vida a 0, destruyéndolo.

### Justificación
- Respeta íntegramente el arte y las animaciones preparadas por el usuario en `troll.tscn`.
- Implementa la pausa de golpe estilo Gargantuar solicitada en la clarificación, ofreciendo un impacto visual imponente cuando aplasta las defensas.
- Cumple la matemática estricta de 2 golpes masivos.

### Alternativas Consideradas
- **Avance continuo sin pausa de animación**: Evaluado en la especificación inicial, pero refinado a pausa de aplastamiento estilo Gargantuar tras la clarificación del usuario para aprovechar la animación `"attack"` ya existente en la escena.
- **Vida variable según oleada**: Descartada para mantener consistencia matemática con el daño masivo (3600 HP fijos).

---

## 3. Integración de la Carta de Dumbledore en el HUD (`dumbledore_card.tres`)

### Contexto
El arsenal del Nivel 9 cuenta con 10 opciones en el HUD, incorporando a Dumbledore como la carta más costosa del mazo (300 snitches).

### Decisión
Crear el recurso `dumbledore_card.tres` (`AllyCard`):
- `display_name = "Dumbledore"`
- `scene = ExtResource("dumbledore_scene")`
- `cost = 300`
- `cooldown = 15.0`
- `texture = ExtResource("dumbledore_texture")` (`res://Images/dumbledore.png`)

En `level_9.tscn`, el HUD contendrá los 10 botones organizados horizontalmente:
Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50), Escoba (125), Hermione (125), McGonagall (200), Dumbledore (300) y Accio (0).

---

## 4. Ensamblado del Nivel 9 (`level_9.tscn`) y Progresión

### Contexto
El Nivel 9 es el penúltimo nivel del juego y el escenario de máxima exigencia táctica antes de la batalla final contra Quirrell (Nivel 10).

### Decisión
Configurar `level_9.tscn` sobre la arquitectura estándar de `level.gd`:
- `active_rows = [2, 3, 4, 5, 6]` (5 carriles activos).
- 5 Dementores defensivos en el flanco izquierdo.
- `total_enemies = 45`.
- `enemy_scenes`: `[slytherin_student.tscn, draco.tscn, protego_student.tscn, slytherin_prefect.tscn, troll.tscn]`.
- Oleadas: el Troll se incorpora en los picos de dificultad y como líder colosal en la Gran Oleada Final.
- `next_level_to_unlock = 10` (desbloquea al Profesor Quirrell en el selector de niveles y Mapa del Merodeador).
