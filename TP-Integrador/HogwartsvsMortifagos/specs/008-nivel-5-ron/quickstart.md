# Quickstart: Validación de Nivel 5 y Ron

Guía de pruebas y validación funcional para verificar el Nivel 5, el atacante Ron, el daño de $30.0$ ($1.5\times$), y el escalado de oleadas con Dracos.

## Prerrequisitos y Configuración

1. Abrir el proyecto en Godot 4.
2. Ejecutar la escena del Nivel 5 (`level_5.tscn`) directamente con F6 o desde el Mapa del Merodeador seleccionando el Nivel 5.
3. Verificar la interfaz del HUD al iniciar:
   - Contador de Snitches (inicia en 150).
   - Mazo completo de cartas: `Harry (100)`, `Caja Snitch (50)`, `Ron (125)`, `Recordadora (150)`, `Protego (50)`.
   - Botón independiente: `Accio`.
   - Cuadrícula de 5 filas activas con los 5 Dementores defensivos ubicados a la izquierda.

---

## Escenario 1: Selección, Plantado y Cooldown de Ron

### Pasos:
1. Al iniciar con 150 snitches, observar que la carta `Ron (125)` está habilitada.
2. Hacer clic en `Ron (125)`. El botón pasa a estado seleccionado (color verde).
3. Hacer clic en una celda libre de la fila 3 (ej. columna 2).
4. Observar el saldo de snitches y el botón de la carta.

### Resultado Esperado:
- Ron se planta en el centro exacto de la baldosa de piedra elegida.
- El saldo disminuye en 125 snitches (pasa de 150 a 25 snitches).
- La carta de Ron entra en tiempo de recarga durante 7.5 segundos y queda deshabilitada.
- Ron muestra la textura de `res://Images/ron.png`.

---

## Escenario 2: Ataque de Ron y Daño Potenciado ($30.0$)

### Pasos:
1. Con un Ron plantado en la fila 3, esperar a que aparezca un Alumno Slytherin (70 de vida) en esa misma fila.
2. Contar los disparos realizados por Ron hasta vencer al enemigo y medir el intervalo.

### Resultado Esperado:
- Ron dispara proyectiles con una cadencia fija de un disparo cada 3.0 segundos.
- Cada proyectil inflige 30 puntos de daño al colisionar.
- El Alumno Slytherin es derrotado exactamente tras **3 impactos**:
  - Impacto 1: $70 - 30 = 40$ de vida restante.
  - Impacto 2: $40 - 30 = 10$ de vida restante.
  - Impacto 3: $10 - 30 = 0$ (enemigo derrotado).
- Cuando no quedan enemigos en el carril, Ron cesa el disparo.

---

## Escenario 3: Efectividad contra Draco (Blindado)

### Pasos:
1. Con un Ron plantado en una fila, esperar a que aparezca un Draco (140 de vida).
2. Observar la cantidad de disparos requeridos para eliminarlo.

### Resultado Esperado:
- Draco resiste los ataques mostrando el feedback de daño en su textura.
- Draco es derrotado en **5 disparos** de Ron ($5 \times 30 = 150 \ge 140$), a diferencia de los 7 disparos requeridos por Harry ($7 \times 20 = 140$).

---

## Escenario 4: Remoción de Ron mediante Accio

### Pasos:
1. Con Ron plantado en el tablero, hacer clic en la herramienta `Accio`.
2. Posar el cursor sobre Ron (observar el feedback de modulación rojiza translúcida).
3. Hacer clic izquierdo sobre Ron.

### Resultado Esperado:
- Ron es eliminado instantáneamente del tablero.
- La celda queda liberada para un nuevo plantado.
- El contador de snitches no varía (sin reembolso).
- El temporizador de disparo de Ron se detiene y se libera sin advertencias ni fugas de memoria.

---

## Escenario 5: Oleadas del Nivel 5 y Desbloqueo del Nivel 6

### Pasos:
1. Jugar el nivel defendiendo las 5 filas con la combinación de Harry, SnitchBox, Ron, Protego, Recordadora y Accio.
2. Superar la oleada intermedia y la oleada final (con múltiples Dracos distribuidos en distintos carriles).
3. Tras derrotar al último Mortífago de la oleada final, observar la resolución del nivel.

### Resultado Esperado:
- Se despliega el panel modal de ¡VICTORIA! indicando el desbloqueo del Nivel 6.
- Al regresar al Mapa del Merodeador, el botón del Nivel 6 aparece habilitado para ser jugado.
