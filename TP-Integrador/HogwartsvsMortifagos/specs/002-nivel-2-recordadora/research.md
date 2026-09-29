# Investigación y Decisiones Técnicas: Nivel 2 y la Recordadora

**Branch**: `002-nivel-2-recordadora`  
**Feature**: Nivel 2 — Expansión a 3 Líneas y la Recordadora  
**Fecha**: 2026-09-29  

---

## 1. Arquitectura de Escena del Nivel 2

### Contexto
El Nivel 1 se implementó en `NivelPrincipal.tscn` gobernado por `nivel_principal.gd`, el cual fijaba de forma estática `const FILA_ACTIVA: int = 4` y un único spawner `Marker2D3`. El Nivel 2 requiere activar 3 filas (Filas 3, 4 y 5), bloquear únicamente las filas extremas (Filas 2 y 6), soportar 3 spawners activos aleatorios y añadir la carta de la Recordadora al HUD.

### Decisiones de Diseño

- **Decisión**: Generalizar `nivel_principal.gd` mediante propiedades exportadas (`filas_activas: Array[int]`, `spawners_activos: Array[Marker2D]`, `tiempo_spawneo: float`, `total_enemigos: int`) y crear una escena dedicada `nivel_2.tscn` que reutilice la base arquitectónica sin duplicar lógica monolítica.
- **Razón**: Respeta el Principio II de la Constitución ("Las entidades DEBEN reutilizarse mediante instanciación de escenas, evitando duplicar nodos o lógica") y la regla de no duplicar código de gestión de plantado, Dementores ni fin de partida.
- **Alternativas consideradas**:
  - *Duplicar `nivel_principal.gd` en `nivel_2.gd`*: Rechazado porque genera deuda técnica y duplica 300 líneas de código idéntico (Dementores, plantado, cálculo de coordenadas, modales de victoria/derrota).
  - *Hardcodear condicionales `if numero_nivel == 2` dentro de `nivel_principal.gd`*: Rechazado porque viola el desacoplamiento de escenas y ensucia la lógica del Nivel 1.

---

## 2. Entidad Recordadora (`recordadora.tscn` y `recordadora.gd`)

### Contexto
La Recordadora cumple el rol de la Cereza Explosiva (Cherry Bomb) en Plants vs. Zombies: cuesta 150 Snitches, no dispara proyectiles, detona tras 1,5 segundos de ser plantada con una animación de aviso, inflige daño letal en un radio de 3×3 celdas (384×384 píxeles en celdas de 128×128) y se autodestruye.

### Decisiones de Diseño

- **Decisión**: Crear `recordadora.tscn` con nodo raíz `Area2D` perteneciente al grupo `aliados` (capa de colisión 1).
  - Incorpora un `CollisionShape2D` propio para ser atacable por enemigos mientras prepara la explosión (salud: 100).
  - Incorpora un área hija `AreaExplosion` (`Area2D`) con forma rectangular de 384×384 px (radio 3×3 celdas), `collision_layer = 0` y `collision_mask = 2` (Enemigos).
  - Temporizador de activación de 1,5 segundos mediante `Timer` interno o `get_tree().create_timer(1.5)`.
  - Animación previa con `Tween`: oscilación de escala (`1.0` a `1.25`) y modulación de color hacia un tinte carmesí vibrante (`Color(1.0, 0.3, 0.3)`).
  - Al detonar: obtiene todas las áreas superpuestas en `AreaExplosion`, verifica que pertenezcan al grupo `enemigos`, aplica 1800 de daño mediante `recibir_danio(1800)` y ejecuta `queue_free()`.
- **Razón**: 
  - Usar 1800 de daño letal garantiza eliminar instantáneamente al Alumno Slytherin (200 HP) y mantiene compatibilidad formal con futuras variantes de enemigos.
  - La máscara de colisión `collision_mask = 2` asegura físicamente que los aliados propios (Capa 1) jamás reciban daño de la explosión.
- **Alternativas consideradas**:
  - *Iterar por todos los nodos en el árbol y calcular distancia matemática*: Rechazado por violar el Principio IV de la Constitución ("La detección de colisiones DEBE realizarse mediante Area2D y señales de colisión de Godot").

---

## 3. Temporizador de Recarga (Cooldown) en el HUD

### Contexto
En la clarificación se determinó que la Recordadora debe tener un tiempo de recarga de 25 segundos en el HUD tras ser plantada para evitar el spam masivo de bombas.

### Decisiones de Diseño

- **Decisión**: Extender el HUD para incorporar `BotonRecordadora` con una lógica de recarga explícita:
  - Variable `var tiempo_recarga_recordadora: float = 0.0`.
  - Al plantar una Recordadora con éxito, `tiempo_recarga_recordadora = 25.0`.
  - En `_process(delta)` del nivel/HUD, se decrementa el temporizador.
  - El botón se habilita únicamente si: `snitches >= 150 and tiempo_recarga_recordadora <= 0.0`.
  - Visualización: mientras esté en recarga, el botón muestra el texto `"Recordadora (150)\n[" + str(ceili(tiempo_recarga_recordadora)) + "s]"` o sombreado visual, regresando a `"Recordadora (150)"` al estar listo.
- **Razón**: Brinda retroalimentación visual clara e instantánea al jugador sin requerir shaders complejos ni dependencias externas.
- **Alternativas consideradas**:
  - *Usar un Timer independiente de Godot*: Funcional, pero usar una variable con `delta` permite reflejar el contador de segundos restantes en el texto del botón con un costo nulo.

---

## 4. Spawner Multilínea y Gestión de Oleadas

### Contexto
El Nivel 2 genera un total de 20 Alumnos Slytherin con un intervalo de 6 segundos repartidos aleatoriamente entre las 3 filas activas (Fila 3 Y=448, Fila 4 Y=576, Fila 5 Y=704).

### Decisiones de Diseño

- **Decisión**: 
  - Lista de spawners activos: `[Marker2D2, Marker2D3, Marker2D4]`.
  - En cada timeout del `TimerSpawneoMortifagos` (wait_time = 6.0), se selecciona aleatoriamente un spawner de la lista: `var spawner_elegido: Marker2D = spawners_activos.pick_random()`.
  - Se instancia el Alumno Slytherin en la posición del spawner seleccionado.
  - Contador de control: `enemigos_generados += 1`. Si `enemigos_generados >= total_enemigos (20)`, se detiene el timer.
  - Condición de victoria: cuando `enemigos_derrotados >= total_enemigos (20)` y no queden enemigos activos en pantalla.
- **Razón**: Permite aleatoriedad uniforme e impredecible entre las tres filas garantizando que todas reciban atacantes a lo largo del nivel.

---

## 5. Integración con el Mapa del Merodeador y Progresión

### Contexto
El Nivel 2 debe ser accesible desde `menu_niveles.tscn` al hacer clic en el botón `Nivel 2` (desbloqueado tras ganar el Nivel 1). Al ganar el Nivel 2, debe desbloquearse el Nivel 3 (`progreso_desbloqueado = 3`).

### Decisiones de Diseño

- **Decisión**:
  - `menu_niveles.gd` mapeará cada nivel con su escena empaquetada correspondiente (`@export var escenas_niveles: Array[PackedScene]` o diccionario por índice).
  - Al hacer clic en `Nivel 1`, carga `NivelPrincipal.tscn`. Al hacer clic en `Nivel 2`, carga `nivel_2.tscn`.
  - Al producirse la victoria en Nivel 2, se ejecuta:
    `MenuNiveles.progreso_desbloqueado = maxi(MenuNiveles.progreso_desbloqueado, 3)`
    y el modal de victoria informa el desbloqueo del Nivel 3.
- **Razón**: Encaja perfectamente con la arquitectura de progresión de 10 niveles ya existente en `menu_niveles.gd`.
