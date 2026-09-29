# Contrato de Flujo y Progresión: Nivel 2

**Branch**: `002-nivel-2-recordadora`  
**Fecha**: 2026-09-29  

---

## 1. Entrada al Nivel 2 (Desde el Mapa del Merodeador)

- **Emisor**: `menu_niveles.gd`
- **Condición**: `MenuNiveles.progreso_desbloqueado >= 2`
- **Acción**: Al presionar `BotonNivel2`:
  - `get_tree().change_scene_to_packed(escena_nivel_2)`

## 2. Inicialización del Nivel 2

1. **Grilla y Filas**:
   - `filas_activas`: Filas 3, 4 y 5 (Y=448, Y=576, Y=704).
   - `filas_bloqueadas`: Filas 2 y 6 (Y=320, Y=832). Nodos `Fila2` y `Fila6` en `BloqueoMagico` permanecen visibles con ColorRect translúcido; `Fila3` y `Fila5` permanecen ocultos/desactivados.
2. **Defensas**:
   - 5 Dementores instanciados en X=160 en las 5 filas (Y=[320, 448, 576, 704, 832]).
3. **Economía Inicial**:
   - Saldo inicial: 150 Snitches.
   - Snitches celestes caen cada 10 segundos otorgando 25 Snitches.
4. **Arsenal en HUD**:
   - Botón Harry (100 Snitches)
   - Botón Caja de Snitch (50 Snitches)
   - Botón Recordadora (150 Snitches, cooldown inicial 0s)

## 3. Flujo de Oleadas y Victoria

1. **Timer de Spawneo**:
   - `wait_time = 6.0`, `autostart = true`.
   - Límite: `total_enemigos = 20`.
2. **Selección de Fila**:
   - `spawner_elegido = [Marker2D2, Marker2D3, Marker2D4].pick_random()`.
3. **Condición de Victoria**:
   - `enemigos_derrotados == 20` AND `enemigos_activos == 0`.
   - Se activa `_victoria()`.
   - `MenuNiveles.progreso_desbloqueado = maxi(MenuNiveles.progreso_desbloqueado, 3)`.
   - Se muestra modal `PanelFinNivel` con título `¡VICTORIA!` y mensaje de desbloqueo del Nivel 3.
