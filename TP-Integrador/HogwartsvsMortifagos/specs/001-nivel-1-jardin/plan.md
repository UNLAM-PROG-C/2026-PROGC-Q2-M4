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

### 3. Grupos y colisiones

Como `AGENTS.md` reserva los grupos `aliados`, `enemigos` y `hechizos`, usar esos nombres canónicos:

- Harry y Caja de Snitch: `aliados`.
- Alumno Slytherin: `enemigos`.
- Proyectil: `hechizos`.

Matriz de interacción:

- `hechizos` → `enemigos`: impacto y daño.
- `hechizos` → `aliados`: ignorar.
- `aliados` ↔ `enemigos`: contacto físico o ataque según la entidad.
- `aliados` ↔ `aliados`: bloquear la misma celda.
- Líneas deshabilitadas: sin plantación, spawneo ni colisiones jugables.

Las validaciones deben usar Grupos, `Area2D`, capas y máscaras, nunca nombres de nodos.

### 4. Economía

- Inicializar el saldo en 150 Snitches.
- Harry cuesta 100 Snitches.
- Caja de Snitch cuesta 50 Snitches.
- Caja de Snitch genera 25 Snitches cada 25 segundos.
- La especificación todavía no define Snitches físicos recogibles por clic; el plan base los acredita automáticamente. La mecánica de caída y falta de clic debe resolverse antes de convertirlos en objetos físicos.

### 5. Orden de implementación

1. Confirmar nuevamente en MCP el `TileMapLayer`, `Marker2D3` y la conexión del Timer.
2. Configurar la grilla central y el bloqueo visual de las otras líneas.
3. Crear las cuatro escenas con `Area2D` raíz y sus grupos.
4. Implementar plantación, costos, disparos, daño y generación económica.
5. Validar colisiones y actualizar el checklist técnico antes de marcar el backlog.
