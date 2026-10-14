# Research: Sistema Híbrido de Oleadas por Bajas y Medidor Visual de Progreso

## 1. Decisiones de Arquitectura de Oleadas

### Decisión 1: Control de Bajas y Transición de Fases
- **Elección**: Manejo de umbrales por nivel mediante un arreglo de enteros exportado `@export var wave_kill_thresholds: Array[int] = []` en `level.gd`.
- **Razón**: `level.gd` ya centraliza la conexión de señales `defeated` de los enemigos (`_on_enemy_defeated`), el estado de oleada `_wave_state`, la coordinación con `wave_director.gd` y la llamada a `_win()` / `_lose()`. Mantener dos contadores explícitos:
  - `_phase_defeated_enemies: int = 0`: cuenta las bajas dentro de la fase actual y se reinicia a 0 en cada Gran Oleada alcanzada.
  - `_total_defeated_enemies: int = 0`: acumulador monótono que alimenta directamente el valor del medidor del HUD.
- **Alternativas descartadas**:
  - *Calcular porcentajes dinámicos*: Frágil ante variaciones de spawn y propenso a errores de redondeo.
  - *Crear un autoload global*: Innecesario y violaría la encapsulación de cada nivel independiente.

### Decisión 2: Temporizador en Segundo Plano y Escalado de Dificultad
- **Elección**: Mantener `enemy_spawn_timer` corriendo durante la fase normal (`STATE_SPAWNING_NORMAL`) sin límite estricto de `total_enemies` que corte el spawn prematuramente. A medida que transcurre el tiempo, el intervalo entre spawns se reduce gradualmente con un factor de decremento hasta un suelo mínimo (`MIN_SPAWN_INTERVAL = 2.0s`), acelerando la cadencia de enemigos comunes.
- **Razón**: Cumple estrictamente con el requerimiento de mantener el cálculo de dificultad temporal en segundo plano sin que el tiempo gatille la Gran Oleada.
- **Comportamiento durante Grandes Oleadas**: Al activarse una Gran Oleada, `enemy_spawn_timer.stop()` pausa el spawn regular (conforme a la clarificación Q1). Una vez finalizada y derrotada la masa de asalto, si no es la oleada final, `enemy_spawn_timer.start()` reanuda el flujo de enemigos comunes para la siguiente fase.

### Decisión 3: Condición de Victoria y Oleada Final
- **Elección**: Cuando `_phase_defeated_enemies` alcanza el umbral de la Oleada Final (la última fase del nivel), el medidor visual se sitúa en su valor máximo (100%), se detiene definitivamente el spawn regular y se solicita el asalto masivo de la Gran Oleada Final. La victoria (`_win()`) se declara únicamente cuando todos los enemigos en pantalla han sido eliminados (`_active_enemies == 0` y `_final_wave_active == true`).
- **Razón**: Respeta el estándar clásico de Plants vs. Zombies y la respuesta ratificada en `/speckit-clarify` (Q2).

---

## 2. Decisiones de Interfaz y Recursos Gráficos

### Decisión 4: Normalización y Renombrado de Assets
- **Elección**:
  - `Images/Personajes_Medidor 2 oleadas.png` → `Images/wave_meter_2_waves.png`
  - `Images/Personajes_Medidor 3 oleadas.png` → `Images/wave_meter_3_waves.png`
- **Razón**: `AGENTS.md` y la Constitución del proyecto (§III) prohíben estrictamente identificadores o assets con espacios o en español. Las referencias `.import` se actualizarán coherentemente.

### Decisión 5: Arquitectura del Medidor Visual (`WaveProgressBar`)
- **Elección**: Crear una escena modular dedicada `wave_progress_bar.tscn` con script `wave_progress_bar.gd` que hereda de `Control` conteniendo un nodo hijo `TextureProgressBar`.
- **Configuración de `TextureProgressBar`**:
  - `fill_mode`: `3` (`TextureProgressBar.FILL_BOTTOM_TO_TOP`).
  - `texture_over`: El marco de cristal (`wave_meter_2_waves.png` o `wave_meter_3_waves.png`).
  - `texture_progress`: Una textura de líquido rojo (`res://Images/wave_meter_red_progress.png`) de 294x1014 px con el canal alfa recortado al ancho interno de la columna (x: 48 a 245), para que el líquido llene limpiamente el interior del tubo sin desbordar los bordes exteriores ni la base.
  - Dimensiones en pantalla: Escalado a `Vector2(0.24, 0.24)` para que ocupe aproximadamente 70x243 px en la esquina inferior izquierda (`position = Vector2(30, 800)`), visible y sin tapar los carriles de combate ni el mazo de cartas superior.
  - Suavizado visual: `Tween` opcional o actualización reactiva directa mediante la función `set_progress(current_kills: int, max_kills: int)`.

---

## 3. Matriz de Umbrales de Bajas por Nivel

| Nivel | N° Oleadas | Umbrales por Fase (`wave_kill_thresholds`) | Total Bajas (`max_value`) | Textura HUD |
| :---: | :---: | :---: | :---: | :---: |
| **Nivel 1** | 2 | `[15, 20]` | 35 | `wave_meter_2_waves.png` |
| **Nivel 2** | 2 | `[20, 25]` | 45 | `wave_meter_2_waves.png` |
| **Nivel 3** | 2 | `[20, 30]` | 50 | `wave_meter_2_waves.png` |
| **Nivel 4** | 2 | `[25, 30]` | 55 | `wave_meter_2_waves.png` |
| **Nivel 5** | 2 | `[30, 35]` | 65 | `wave_meter_2_waves.png` |
| **Nivel 6** | 2 | `[30, 30]` | 60 | `wave_meter_2_waves.png` |
| **Nivel 7** | 2 | `[30, 30]` | 60 | `wave_meter_2_waves.png` |
| **Nivel 8** | 3 | `[20, 40, 60]` | 120 | `wave_meter_3_waves.png` |
| **Nivel 9** | 3 | `[30, 40, 70]` | 140 | `wave_meter_3_waves.png` |
