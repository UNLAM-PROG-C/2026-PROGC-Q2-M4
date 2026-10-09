# Quickstart: Validación de Nivel 4 y Hechizo Accio

Guía de pruebas y validación funcional para verificar el Nivel 4 y la mecánica del hechizo Accio (Pala).

## Prerrequisitos y Configuración

1. Abrir el proyecto en Godot 4.
2. Iniciar la escena del Nivel 4 (`level_4.tscn`) directamente desde el editor o mediante el botón F6.
3. Verificar que el HUD muestra:
   - Contador de Snitches (iniciando en 150).
   - Botones de cartas: `Harry (100)`, `Caja Snitch (50)`, `Recordadora (150)`, `Protego (50)`.
   - Botón independiente: `Accio`.

---

## Escenario 1: Activación, Cursor y Cancelación de Accio

### Pasos:
1. Hacer clic izquierdo sobre el botón `Accio` en el HUD.
2. Observar que el botón pasa a estado presionado (toggled / cambio de color) y el cursor del sistema se oculta, apareciendo el cursor placeholder de Accio siguiendo la posición del mouse.
3. Presionar la tecla `ESC` o hacer clic derecho en cualquier parte del mapa.

### Resultado Esperado:
- El modo de remoción se cancela de inmediato.
- El botón `Accio` se desmarca.
- El cursor del sistema vuelve a ser visible y el cursor placeholder desaparece.

---

## Escenario 2: Exclusión Mutua entre Plantado y Accio

### Pasos:
1. Hacer clic en la carta de `Harry (100)`. El botón de Harry queda seleccionado en verde.
2. Sin deseleccionar Harry, hacer clic en el botón `Accio`.
3. Comprobar que Harry se deselecciona automáticamente y el cursor pasa a modo Accio.
4. Con Accio activo, hacer clic sobre la carta de `Protego (50)`.

### Resultado Esperado:
- El modo Accio se desactiva instantáneamente, restaurando el cursor habitual.
- La carta de Protego queda seleccionada para plantado.

---

## Escenario 3: Feedback Visual (Hover) y Remoción de un Aliado

### Pasos:
1. Con suficientes snitches, plantar un Harry en la fila 3, columna 4.
2. Hacer clic en el botón `Accio`.
3. Pasar el cursor sobre el Harry recién plantado (sin hacer clic).
4. Mover el cursor fuera de la celda de Harry hacia una celda vacía.
5. Volver a colocar el cursor sobre Harry y hacer clic izquierdo.

### Resultado Esperado:
- Al posar el cursor sobre Harry, su modulación cambia a un tono rojizo translúcido.
- Al salir el cursor, Harry recupera su color blanco normal.
- Al hacer clic izquierdo sobre Harry:
  - Harry es destruido de inmediato del tablero.
  - La celda queda vacía.
  - El contador de snitches no cambia (no devuelve snitches).
  - El modo Accio se desactiva automáticamente, volviendo al estado y cursor normales.

---

## Escenario 4: Re-plantado Inmediato sobre la Celda Liberada

### Pasos:
1. Inmediatamente después de remover al aliado en el Escenario 3, seleccionar una `Caja Snitch (50)`.
2. Hacer clic exactamente en la misma celda donde estaba el Harry removido.

### Resultado Esperado:
- La Caja de Snitch se planta sin problemas ni advertencias en la consola.
- Se descuentan los 50 snitches correspondientes y comienza a funcionar.

---

## Escenario 5: Clics Inválidos y Protección de Defensas del Entorno

### Pasos:
1. Activar el botón `Accio`.
2. Hacer clic izquierdo sobre una celda vacía del césped.
3. Hacer clic izquierdo sobre un enemigo (Alumno Slytherin o Draco) que esté avanzando.
4. Hacer clic izquierdo sobre el Dementor ubicado al inicio del carril.

### Resultado Esperado:
- En ninguno de los tres casos se produce remoción ni error en consola.
- El modo Accio permanece activo esperando un aliado válido o la cancelación voluntaria del jugador.
