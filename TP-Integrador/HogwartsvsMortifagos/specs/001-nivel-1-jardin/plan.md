# Plan de desarrollo: 001-nivel-1-jardin

## Plan técnico

### 1. Nivel principal

- Mantener `NivelPrincipal` como `Node2D`.
- Usar el `TileMapLayer` existente para la grilla.
- Mantener visibles las cinco líneas.
- Activar únicamente la línea central.
- Usar `Spawners/Marker2D3` para generar Alumnos Slytherin.
- Deshabilitar `Marker2D`, `Marker2D2`, `Marker2D4` y `Marker2D5` para plantación, spawneo, avance y colisiones.
- Revalidar mediante MCP la conexión del Timer antes de implementar.

### 2. Escenas separadas

Crear una escena por entidad, todas con `Area2D` como raíz:

- `harry.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `TimerDisparo`
  - Referencia exportada a `proyectil.tscn`
- `caja_snitch.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `TimerGeneracionSnitches`
- `alumno_slytherin.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `Area2D` de detección o ataque
- `proyectil.tscn`
  - `Area2D`
  - `CollisionShape2D`
  - `VisibleOnScreenNotifier2D`

### 3. Grupos, capas y colisiones

Usar los grupos canónicos definidos en `AGENTS.md` (`aliados`, `enemigos`, `hechizos`, `dementores`) y capas físicas 2D:

- **Capa 1 (Aliados)**: Harry, Caja de Snitch, Dementores (`collision_layer = 1`, `collision_mask = 0` o `2`).
- **Capa 2 (Enemigos)**: Alumno Slytherin (`collision_layer = 2`, `collision_mask = 0`). Su área de detección usa `collision_mask = 1` para detectar aliados.
- **Capa 3 (Hechizos)**: Proyectil de Harry (`collision_layer = 4`, `collision_mask = 2` para impactar enemigos).
- **Capa 4 (Snitches)**: Snitch física (`collision_layer = 8`, `collision_mask = 0`, `input_pickable = true` para clic del ratón).

Matriz de interacción:

- `hechizos` (Capa 3) → `enemigos` (Capa 2): impacto y aplicación de 20 de daño.
- `hechizos` → `aliados`: ignorado completamente por máscara de colisión.
- `enemigos` → `aliados`: `AreaDeteccion` detecta Capa 1 y aplica daño continuo por segundo.
- `aliados` ↔ `aliados`: validación en grilla para bloquear la misma celda.
- `dementores` → `enemigos`: contacto en Capa 2 activa avance y elimina instantáneamente a los enemigos de la fila.
- Líneas deshabilitadas: bloqueo visual con ColorRect semi-transparente (placeholder) y lógica que rechaza plantación y spawneo fuera de la fila central (`Y=4`).

### 4. Economía y Snitches

- Inicializar el saldo en 150 Snitches.
- Harry cuesta 100 Snitches.
- Caja de Snitch cuesta 50 Snitches.
- Caja de Snitch genera 25 Snitches cada 10 segundos.
- **Mecánica física de Snitches**: Al expirar el temporizador de 10s, la Caja de Snitch instancia una `Snitch` física que realiza un salto hacia arriba (pop) y reposa cerca en el suelo.
- El jugador debe hacer clic sobre la Snitch para recogerla y acreditar los 25 Snitches al saldo.
- Si no se recoge, la Snitch desaparece automáticamente al agotarse su tiempo de vida (10 segundos).
- Snitches del cielo: caen cada 10s en zigzag desde el borde superior y se recolectan al hacer clic.

### 5. Menú interactivo de fin de partida y progresión

- Modal `PanelFinNivel` en el HUD con diseño estilo pergamino de Harry Potter (`#e4cd9f` y `#3c2415`).
- Al ganar:
  - Título: `¡VICTORIA!`
  - Mensaje informativo: `¡Has defendido el jardín con éxito! Nivel 2 desbloqueado en el Mapa del Merodeador.`
  - Desbloqueo del Nivel 2 en memoria de sesión (`MenuNiveles.progreso_desbloqueado = 2`).
  - Botones: "Siguiente Nivel" (lleva al mapa), "Reintentar" y "Volver al Mapa".
- Al perder:
  - Título: `¡DERROTA!`
  - Mensaje informativo: `Los mortífagos han invadido el jardín de Hogwarts.`
  - Botones: "Reintentar" (recarga el nivel) y "Volver al Mapa" (carga `menu_niveles.tscn`).

### 6. Orden de implementación completado

1. Confirmar estructura de escenas (`Node2D`, `TileMapLayer`, `Marker2D3`, timers).
2. Configurar la grilla central activa (`FILA_ACTIVA = 4`) y bloqueo visual en las otras cuatro filas.
3. Crear y configurar escenas con tipado estático estricto: `harry.tscn`, `caja_snitch.tscn`, `alumno_slytherin.tscn`, `Proyectil.tscn`, `snitch.tscn`, `dementor.tscn`.
4. Implementar plantación de aliados, costos, disparos, avance y ataque cuerpo a cuerpo de enemigos.
5. Implementar expulsión física de Snitches desde la Caja de Snitch con animación de pop y recolección manual por clic.
6. Configurar capas y máscaras físicas (Capas 1, 2, 3 y 4).
7. Desarrollar el modal interactivo de Victoria/Derrota y conectarlo con la progresión del mapa (`menu_niveles.tscn`).
