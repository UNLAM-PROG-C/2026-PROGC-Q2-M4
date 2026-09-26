# Especificación: Nivel 1 - Defensa de una línea

## Resumen

El jugador defiende un jardín mediante una grilla de una sola línea. Puede gastar Snitches para plantar aliados que atacan o generan economía mientras un Alumno Slytherin avanza desde la derecha hacia el jardín.

## Objetivo

Completar el núcleo jugable del Nivel 1: iniciar con 150 Snitches, plantar a Harry y la Caja de Snitch, generar proyectiles y economía, y enfrentar al Alumno Slytherin como enemigo básico.

## Alcance

### Incluido

- Una grilla jugable de una sola línea.
- Saldo inicial de 150 Snitches.
- Plantación de Harry por 100 Snitches.
- Disparo de proyectiles por parte de Harry.
- Plantación de la Caja de Snitch por 50 Snitches.
- Generación periódica de 25 Snitches por parte de la Caja de Snitch.
- Aparición del Alumno Slytherin como enemigo básico.
- Avance del Alumno Slytherin desde la derecha hacia el jardín.
- Interacción de ataque entre los proyectiles de Harry y el Alumno Slytherin.
- La línea central es la única línea activa del Nivel 1.
- Las demás líneas permanecen visibles con una textura de bloqueo mágico diferente.
- Las líneas deshabilitadas no permiten plantar aliados ni recibir enemigos.

### Presentación de la grilla

- La grilla debe mostrar todas las líneas disponibles del jardín para anticipar la progresión futura.
- La línea central debe usar la textura jugable normal y aceptar celdas, aliados y enemigos.
- Las líneas no activas deben usar una textura visual distinta con marcas mágicas de bloqueo.
- Las líneas no activas deben estar deshabilitadas tanto para la plantación como para el spawneo y avance de enemigos.
- Las líneas no activas no deben participar en las colisiones jugables del Nivel 1.

### Fuera de alcance

- Grillas de más de una línea.
- Otros aliados o enemigos.
- Niveles posteriores y progresión de desbloqueos.
- Accio, mejoras, habilidades especiales y jefes.
- Persistencia del progreso entre partidas.

## Historias de usuario

### HU-01: Saldo inicial

Como jugador, quiero comenzar el Nivel 1 con 150 Snitches para poder elegir qué aliado plantar primero.

**Criterios de aceptación:**

- Al iniciar el Nivel 1, el saldo visible es de 150 Snitches.
- El saldo inicial se puede gastar en aliados disponibles.
- El saldo no puede quedar por debajo de cero.

### HU-02: Plantar a Harry

Como jugador, quiero plantar a Harry por 100 Snitches para que ataque a los enemigos con proyectiles.

**Criterios de aceptación:**

- Harry solo se puede plantar en una celda disponible de la única línea.
- La plantación descuenta exactamente 100 Snitches.
- La plantación se rechaza si el jugador tiene menos de 100 Snitches.
- Harry dispara proyectiles cuando existe un Alumno Slytherin válido en su línea.
- Harry dispara un proyectil cada 1,5 segundos.
- Los proyectiles pueden impactar al Alumno Slytherin y causarle daño.

### HU-03: Plantar la Caja de Snitch

Como jugador, quiero plantar una Caja de Snitch por 50 Snitches para generar economía periódicamente.

**Criterios de aceptación:**

- La Caja de Snitch solo se puede plantar en una celda disponible de la única línea.
- La plantación descuenta exactamente 50 Snitches.
- La plantación se rechaza si el jugador tiene menos de 50 Snitches.
- La Caja de Snitch genera periódicamente una recompensa de exactamente 25 Snitches.
- La Caja de Snitch genera la recompensa cada 25 segundos.
- La recompensa se suma al saldo del jugador y puede utilizarse para plantar aliados.

### HU-04: Enemigo básico

Como jugador, quiero que aparezca un Alumno Slytherin desde la derecha para defender el jardín de un enemigo básico.

**Criterios de aceptación:**

- El Nivel 1 genera al menos un Alumno Slytherin.
- El Alumno Slytherin aparece en el extremo derecho de la única línea.
- El Alumno Slytherin avanza hacia la izquierda, en dirección al jardín.
- El Alumno Slytherin tiene 200 puntos de vida.
- El Alumno Slytherin tarda 4 pasos en desplazarse de una baldosa a otra.
- El Alumno Slytherin puede recibir daño de los proyectiles de Harry.
- El Alumno Slytherin interactúa con las entidades mediante sus categorías de Grupos y áreas de colisión, no mediante comparaciones por nombre de nodo.

## Reglas funcionales

- La partida comienza con 150 Snitches.
- Harry cuesta 100 Snitches.
- Harry dispara cada 1,5 segundos.
- La Caja de Snitch cuesta 50 Snitches.
- Cada generación de la Caja de Snitch entrega 25 Snitches.
- La Caja de Snitch genera Snitches cada 25 segundos.
- El Alumno Slytherin comienza con 200 puntos de vida.
- El Alumno Slytherin tarda 4 pasos por baldosa.
- La única línea contiene las celdas disponibles para plantar aliados.
- Cada celda puede contener como máximo un aliado.
- Los aliados se plantan en la grilla y los enemigos avanzan desde la derecha.
- Las colisiones de ataques y objetivos se resuelven mediante `Area2D` y Grupos.

## Reglas de finalización del Nivel 1

- El nivel puede continuar mientras existan enemigos activos o el jugador pueda defender la línea.
- El nivel se considera ganado cuando todos los Alumnos Slytherin generados son derrotados.
- El nivel se considera perdido si un Alumno Slytherin alcanza la condición de invasión del jardín definida por el diseño del nivel.

## Restricciones técnicas

- La implementación debe respetar Godot 4, el renderizador Compatibility y GDScript con tipado estático estricto.
- Debe existir una escena y un script propios para cada entidad.
- El estado de la interfaz debe leerse del estado real del motor mediante `godot-mcp` durante la implementación.
- La arquitectura debe basarse estrictamente en Nodos y Escenas.
