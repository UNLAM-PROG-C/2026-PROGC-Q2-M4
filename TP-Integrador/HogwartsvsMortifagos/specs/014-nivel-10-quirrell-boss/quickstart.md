# Quickstart & Validation Guide: Nivel 10 - Quirrell Boss

**Feature Branch**: `014-nivel-10-quirrell-boss` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

Este documento detalla los escenarios de validación ejecutables para verificar de forma integral el Nivel 10 y la batalla contra Quirrell/Voldemort.

---

## 1. Validación de Reglas de Código de la Cátedra

Antes de ejecutar cualquier prueba funcional, validar que todo el código nuevo cumpla las directivas de la cátedra:

```powershell
cmd.exe /c "C:\Users\polol\Desktop\Godot_v4.7.2-stable_win64.exe --headless --path . -s tools/check_rules.gd"
```

**Criterios de Aceptación**:
- 0 violaciones nuevas de `LONG_FUNCTION` (ningún método supera 15 líneas).
- 0 violaciones de identificadores en desuso o en español.
- Tipado estático estricto en el 100% de declaraciones.

---

## 2. Escenario 1: Entorno Visual y Posicionamiento Inicial

**Objetivo**: Validar que la arena final de piedra gris cargue con Quirrell en la columna 8 y el HUD adecuado.

**Pasos de prueba**:
1. Ejecutar la escena `res://level_10.tscn` en Godot.
2. Observar el fondo: debe mostrarse la textura `res://Images/final_background.png`.
3. Observar el HUD superior:
   - El reloj de arena de oleadas está oculto (`visible = false`).
   - Se muestra la barra de vida del jefe en la parte superior central al 100% (36.000 HP).
4. Observar a Quirrell:
   - Se ubica en la columna 8 de una de las filas activas (filas 2 a 6).
   - Permanece estacionario (su coordenada X no decrece hacia el jardín).
   - Su sprite tiene el turbante morado puesto (`$TurbanSprite.visible == true`).

---

## 3. Escenario 2: Daño y Actualización de la Barra de Vida

**Objetivo**: Comprobar que Quirrell reciba daño de proyectiles y explosiones masivas.

**Pasos de prueba**:
1. Plantar un aliado en la fila de Quirrell (por ejemplo, Harry o Dumbledore).
2. Verificar que los disparos colisionen con Quirrell y reduzcan su vida.
3. Plantar una Recordadora o Escoba que alcance su carril.
4. Verificar que al impactar la explosión (1.800 de daño):
   - La salud de Quirrell se reduzca en 1.800 puntos.
   - La barra de vida superior del HUD refleje la reducción instantáneamente.
   - Se active el efecto de parpadeo (`DamageFlash`).

---

## 4. Escenario 3: Teletransporte Cada 20 Segundos y Aplastamiento de Aliados

**Objetivo**: Validar el movimiento periódico de Quirrell y la interacción con la cuadrícula.

**Pasos de prueba**:
1. Observar a Quirrell durante 20 segundos sin derrotarlo.
2. Al cumplirse 20 segundos:
   - Quirrell desaparece de su fila actual dejando el efecto visual de sombra oscura en sus pies.
   - Reaparece instantáneamente en una de las otras 4 filas activas en la columna 8.
3. Colocar previamente un aliado (ej. Protego) en la columna 8 de una fila diferente.
4. Esperar a que Quirrell se teletransporte a esa fila:
   - El aliado plantado en esa casilla debe ser destruido/eliminado de inmediato.
5. Intentar plantar un aliado en la celda donde está Quirrell actualmente:
   - El juego debe rechazar la plantación (la celda está bloqueada).

---

## 5. Escenario 4: Transición a Fase 2 (Caída del Turbante)

**Objetivo**: Comprobar la transición a Fase 2 al descender la vida a $\le 50\%$.

**Pasos de prueba**:
1. Infligir daño a Quirrell hasta reducir su vida a 18.000 puntos o menos (equivalente a 10 explosiones de 1.800).
2. En el instante exacto en que la vida es $\le 18.000$:
   - El nodo `$TurbanSprite` se oculta permanentemente.
   - Se revela el rostro de Voldemort en la nuca del sprite base.
   - El temporizador de invocación pasa de 15 segundos a 8 segundos.

---

## 6. Escenario 5: Invocación de Sombras y Ataque Masivo

**Objetivo**: Validar el comportamiento del enemigo "Sombra" y la probabilidad del 10%.

**Pasos de prueba**:
1. En Fase 1: Cada 15 segundos aparece 1 Sombra en el carril actual de Quirrell.
2. En Fase 2: Cada 8 segundos ocurre una invocación.
   - En el 90% de los casos: 1 Sombra en el carril actual.
   - En el 10% de los casos: Invocación de 1 Sombra simultánea en cada uno de los 5 carriles.
3. Medir el avance de la Sombra:
   - Debe avanzar visiblemente más rápido que un Alumno Slytherin (48 px/s vs 32 px/s).
   - Debe ser eliminada tras recibir 200 puntos de daño.
   - Si colisiona con un aliado, debe detenerse y morder infligiendo 30 de daño/segundo.

---

## 7. Escenario 6: Derrota del Jefe y Victoria Final

**Objetivo**: Verificar la condición de victoria única de Quirrell.

**Pasos de prueba**:
1. Reducir la vida de Quirrell a 0.
2. En ese instante exacto:
   - Quirrell es eliminado del juego.
   - Todos los enemigos regulares y Sombras activos en la pantalla se derrotan/eliminan automáticamente.
   - Se detienen las invocaciones y spawners.
   - Aparece la pantalla de victoria final de Hogwarts vs Mortífagos.
