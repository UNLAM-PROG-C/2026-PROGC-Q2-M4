# Technical Research & Decisions: Nivel 5 - Ron

## Decision 1: Arquitectura de Ron y Sistema de Proyectiles

- **Decision**: Crear `ron.gd` (clase `Ron` que extiende `Ally`) y la escena `ron.tscn`. Ron utiliza una propiedad exportada `@export var damage: float = 30.0` y `@export var shot_interval: float = 3.0`. Al disparar, solicita un proyectil a `ProjectilePool` y configura su daño a `30.0` antes de su trayectoria (o `ProjectilePool.acquire_projectile` acepta un parámetro opcional de daño). Al desactivarse y retornar al pool, el proyectil restaura su daño por defecto (`20.0`).
- **Rationale**: Reutiliza la infraestructura de pooling de proyectiles (`ProjectilePool`) introducida en la Feature 005, evitando la instanciación y liberación continua de nodos en memoria. Al mismo tiempo, permite que el proyectil comparta la textura `Images/projectile.png` y las animaciones de impacto existentes.
- **Alternatives considered**:
  - *Crear una escena `ron_projectile.tscn` separada*: Implicaría crear un segundo pool de proyectiles (`RonProjectilePool`) o instanciar y destruir nodos manualmente con `queue_free()`, perdiendo la optimización de memoria.
  - *Extender `Harry` directamente*: Viola el principio de responsabilidad única y la convención de `AGENTS.md` (una escena y un script por entidad con herencia limpia desde `Ally`).

## Decision 2: Representación Visual y Carga de Assets

- **Decision**: El nodo `Sprite2D` de `ron.tscn` asigna exclusivamente la textura `res://Images/ron.png`. La carta del HUD utiliza `AllyCardButton` con el recurso `ron_card.tres`, mostrando el texto temático `"Ron (125)"` y aplicando la textura o icono desde `res://Images/ron.png`.
- **Rationale**: Cumple estrictamente con la HU-2 y el requisito de evitar dependencias rotas, validando que el archivo `Images/ron.png` ya existe en el repositorio y tiene sus metadatos `.import` generados por Godot.
- **Alternatives considered**:
  - *Usar placeholders o colores planos*: Descartado por requerimiento explícito del usuario de enlazar la textura existente desde el primer momento.

## Decision 3: Recurso AllyCard y Botón de HUD

- **Decision**: Crear `ron_card.tres` como instancia de `AllyCard` con:
  - `display_name = "Ron"`
  - `scene = ExtResource("res://ron.tscn")`
  - `cost = 125`
  - `cooldown = 7.5`
  En `level_5.tscn`, instanciar `RonCardButton` como hijo de `$HUD` usando el script `ally_card_button.gd` y conectar sus señales en `level.gd` como parte del arreglo `_card_buttons()`.
- **Rationale**: Mantiene el patrón establecido en niveles anteriores donde cada carta es un recurso desacoplado y reutilizable.

## Decision 4: Integración del Nivel 5 y Escalado de Mortífagos

- **Decision**: Crear `level_5.tscn` derivado de la estructura de `level_4.tscn`, configurando:
  - `active_rows = [2, 3, 4, 5, 6]` (5 carriles activos)
  - `dementor_row_cells = [2, 3, 4, 5, 6]` (5 Dementores defensivos)
  - `Grid`: `position = Vector2(24, -128)`, `scale = Vector2(1.25, 1.25)` (sin desfasaje gráfico)
  - `tile_map_data`: 45 celdas completas (9 columnas $\times$ 5 filas)
  - `enemy_scenes = [slytherin_student, draco]`
  - `EnemySpawnTimer.wait_time = 5.0` (ritmo más intenso y denso que los 8.0 s de niveles previos)
  - `total_enemies = 25`
  - `next_level_to_unlock = 6`
- **Rationale**: Asegura la consistencia visual y matemática recién corregida en todos los niveles, mientras eleva la dificultad mediante un spawn más dinámico y mayor proporción de Dracos para justificar el uso de Ron.
- **Alternatives considered**:
  - *Crear un nuevo tipo de enemigo*: Descartado porque la especificación indica usar Alumno Slytherin y Draco con mayor densidad y frecuencia.

## Decision 5: Regla de Modularidad y Límite de 15 Líneas (AGENTS.md)

- **Decision**: En `level.gd`, para evitar que `_place_ally` supere el límite de 15 líneas al inicializar `Ron`, extraer la inyección de dependencias a un método auxiliar `_init_placed_ally(ally: Ally) -> void`.
- **Rationale**: Cumple de manera inquebrantable con la Regla 4 de la cátedra (`AGENTS.md`) garantizando que ninguna función exceda las 15 líneas de código.
