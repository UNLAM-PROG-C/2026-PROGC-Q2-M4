# Quickstart: Guía de Validación de Progresión de Oleadas y Medidor Visual

## Prerrequisitos
- Godot 4.3 instalado o ejecutable en línea de comandos (`godot`).
- Proyecto ubicado en `TP-Integrador/HogwartsvsMortifagos`.

---

## Escenarios de Validación Rápida

### Escenario 1: Assets Normalizados y Presencia del Medidor en el HUD
1. **Comprobación de Assets**:
   - Verificar la existencia de `res://Images/wave_meter_2_waves.png` y `res://Images/wave_meter_3_waves.png`.
   - Verificar que no queden referencias rotas a los nombres en español antiguos.
2. **Ejecución de Nivel 1**:
   - Ejecutar la escena `level_1.tscn`.
   - Observar la esquina inferior izquierda: debe verse el marco de cristal para 2 oleadas (`wave_meter_2_waves.png`) con líquido rojo al 0%.
3. **Ejecución de Nivel 8 o 9**:
   - Ejecutar `level_8.tscn` o `level_9.tscn`.
   - Observar la esquina inferior izquierda: debe verse el marco de cristal para 3 oleadas (`wave_meter_3_waves.png`).

---

### Escenario 2: Activación de Oleadas Estrictamente por Bajas
1. **Fase 1 (Nivel 1 - 15 Bajas)**:
   - Colocar cartas aliadas (Harry, etc.) en los carriles.
   - Cada Mortífago derrotado debe incrementar en 1 unidad el acumulador y hacer ascender el líquido rojo verticalmente de abajo hacia arriba.
   - Al registrar la baja número 15, debe aparecer el cartel de anuncio de Gran Oleada y desplegarse la masa de asalto.
   - El spawn regular de fondo debe pausarse mientras dura la oleada.
2. **Fase 2 (Nivel 1 - 20 Bajas)**:
   - Tras limpiar la primera oleada masiva, el spawn regular se reanuda.
   - El contador de bajas de fase comienza en 0 mientras el total acumulado en el medidor continúa desde 15.
   - Al alcanzar 20 bajas en esta fase (total acumulado de 35), debe dispararse el anuncio de la Gran Oleada Final y el medidor debe alcanzar el 100% de llenado.

---

### Escenario 3: Victoria y Casos Borde
1. **Resolución de Victoria**:
   - Durante la Oleada Final, eliminar a los enemigos restantes.
   - Una vez que no quedan enemigos en pantalla (`_active_enemies == 0`), debe mostrarse el panel de Victoria desbloqueando el siguiente nivel.
2. **Invasión del Jardín**:
   - Dejar pasar a un enemigo hasta el borde izquierdo de la pantalla.
   - Debe dispararse la señal `garden_invaded` y el panel de Derrota.
   - Verificar que esta invasión no sumó ninguna baja al contador ni al medidor de progreso.
3. **Escalado Temporal en Background**:
   - No matar enemigos inmediatamente y comprobar que el temporizador regular sigue spawneando enemigos periódicamente sin disparar Grandes Oleadas de forma prematura.
