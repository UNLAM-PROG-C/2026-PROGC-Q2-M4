# Quickstart: Validación de Nivel 6 - Escoba y Alumno con Protego

Guía paso a paso para validar la Escoba (`Broomstick`), el Alumno con Protego (`ProtegoStudent`) y la progresión del Nivel 6 en Godot 4.

## Prerrequisitos

1. Abrir el proyecto en Godot 4.
2. Ejecutar directamente la escena `level_6.tscn` (con F6) o acceder a través del Mapa del Merodeador seleccionando el Nivel 6.
3. Comprobar que el HUD muestra las 6 cartas aliadas: Harry (100), Caja Snitch (50), Ron (125), Recordadora (150), Protego (50), Escoba (125) y el botón Accio.

---

## Escenario 1: Barrido de Línea Completa con la Escoba

### Pasos:
1. Acumular al menos 125 snitches.
2. Hacer clic en la carta `Escoba (125)`.
3. Hacer clic en cualquier celda de la fila donde avanzan enemigos.

### Resultado Esperado:
- Se descuentan 125 snitches del saldo.
- La carta de la Escoba entra en tiempo de recarga ("Muy lento", 25.0 segundos).
- La Escoba inicia su movimiento desde el margen izquierdo de la fila y se desplaza horizontalmente hacia la derecha a 600 px/s.
- Todo enemigo tocado por la Escoba en esa fila recibe 1800 puntos de daño de impacto y es derrotado.
- La Escoba se destruye (`queue_free()`) al superar el margen derecho de la pantalla sin bloquear la cuadrícula.

---

## Escenario 2: Degradación Visual del Escudo Protego

### Pasos:
1. Esperar la aparición de un Alumno con Protego en una fila defendida por Harry.
2. Observar el sprite del escudo frente al alumno tras recibir sucesivos impactos de 20 de daño.

### Resultado Esperado:
- **0 a 5 impactos (300 a 200 HP)**: El escudo se muestra intacto y brillante (Frame 0).
- **6 a 10 impactos (199 a 100 HP)**: El escudo cambia al estado de fracturas intermedias (Frame 1).
- **11 a 14 impactos (99 a 1 HP)**: El escudo exhibe fisuras críticas severas (Frame 2).

---

## Escenario 3: Rotura del Escudo y Daño al Alumno Base

### Pasos:
1. Continuar atacando al Alumno con Protego hasta completar 15 disparos de Harry (300 de daño total).
2. Observar la transformación del enemigo y los impactos siguientes.

### Resultado Esperado:
- El sprite del escudo desaparece de inmediato.
- El cuerpo del alumno cambia de `slytherin_protego` a `slytherin` estándar.
- Los siguientes 10 disparos de Harry (200 de daño) se descuentan de su salud base hasta derrotarlo.

---

## Escenario 4: Animación Dinámica de Ataque con Escudo

### Pasos:
1. Permitir que un Alumno con Protego con escudo intacto alcance a un Protego aliado.
2. Observar el patrón de ataque mientras conserva el escudo.
3. Observar el cambio cuando el escudo se rompe en pleno ataque.

### Resultado Esperado:
- Con escudo: el sprite del escudo oscila hacia adelante y hacia atrás golpeando al aliado; el alumno no muerde.
- Al romperse el escudo durante la colisión: pasa automáticamente a la animación de mordida `slytherin_attacking`.

---

## Escenario 5: Victoria en Nivel 6 y Desbloqueo de Nivel 7

### Pasos:
1. Defender las 5 filas del Nivel 6 combinando atacantes, Protego, Escoba y Accio.
2. Superar las oleadas con Alumnos Slytherin, Dracos y Alumnos con Protego.
3. Derrotar al último enemigo de la oleada final.

### Resultado Esperado:
- Se despliega la pantalla modal de ¡VICTORIA! indicando el desbloqueo del Nivel 7.
- Al volver al Mapa del Merodeador, el botón del Nivel 7 aparece desbloqueado y disponible.
