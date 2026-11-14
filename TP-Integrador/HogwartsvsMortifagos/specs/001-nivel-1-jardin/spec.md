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
- Generación periódica de 25 Snitches por parte de la Caja de Snitch soltadas físicamente en el suelo para su recolección por clic.
- Aparición del Alumno Slytherin como enemigo básico.
- Avance del Alumno Slytherin desde la derecha hacia el jardín.
- Interacción de ataque entre los proyectiles de Harry y el Alumno Slytherin.
- La línea central es la única línea activa del Nivel 1.
- Las demás líneas permanecen visibles con una textura/capa de bloqueo mágico (placeholder translúcido en v1).
- Las líneas deshabilitadas no permiten plantar aliados ni recibir enemigos.
- Menú interactivo de fin de nivel con opciones para siguiente nivel, volver al Mapa del Merodeador y reintentar.

### Presentación de la grilla

- La grilla debe mostrar todas las líneas disponibles del jardín para anticipar la progresión futura.
- La línea central debe usar la textura jugable normal y aceptar celdas, aliados y enemigos.
- Las líneas no activas deben mostrar un bloqueo visual (actualmente superposiciones translúcidas como placeholder hasta desarrollo de sprites).
- Las líneas no activas deben estar deshabilitadas tanto para la plantación como para el spawneo y avance de enemigos.
- Las líneas no activas no deben participar en las colisiones jugables del Nivel 1.

### Fuera de alcance

- Grillas de más de una línea.
- Otros aliados o enemigos.
- Niveles posteriores y progresión de desbloqueos (salvo desbloqueo del Nivel 2 al ganar).
- Accio, mejoras, habilidades especiales y jefes.
- Persistencia permanente del progreso en disco (se gestiona en memoria de sesión por ahora).

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

Como jugador, quiero plantar una Caja de Snitch por 50 Snitches para que suelte Snitches periódicamente en el suelo y pueda recogerlas con clic.

**Criterios de aceptación:**

- La Caja de Snitch solo se puede plantar en una celda disponible de la única línea.
- La plantación descuenta exactamente 50 Snitches.
- La plantación se rechaza si el jugador tiene menos de 50 Snitches.
- La Caja de Snitch expulsa periódicamente una Snitch física con un valor de 25 Snitches.
- La Caja de Snitch genera la recompensa cada 10 segundos.
- La Snitch expulsada realiza una animación de salto suave hacia arriba y reposa en el suelo.
- Al hacer clic sobre la Snitch física, se suma automáticamente al saldo del jugador y puede utilizarse para plantar aliados.
- Si el jugador no recoge la Snitch, ésta desaparece tras expirar su tiempo de vida (10 segundos).

### HU-04: Enemigo básico

Como jugador, quiero que aparezca un Alumno Slytherin desde la derecha para defender el jardín de un enemigo básico.

**Criterios de aceptación:**

- El Nivel 1 genera al menos un Alumno Slytherin.
- El Alumno Slytherin aparece en el extremo derecho de la única línea.
- El Alumno Slytherin avanza hacia la izquierda, en dirección al jardín.
- El Alumno Slytherin tiene 200 puntos de vida.
- El Alumno Slytherin tarda 4 pasos en desplazarse de una baldosa a otra (velocidad de 32 px/s en baldosas de 128 px).
- El Alumno Slytherin puede recibir daño de los proyectiles de Harry.
- El Alumno Slytherin interactúa con las entidades mediante sus categorías de Grupos y áreas de colisión, no mediante comparaciones por nombre de nodo.

### HU-05: Menú interactivo de fin de nivel y progresión

Como jugador, quiero que al terminar la partida (por victoria o derrota) aparezca un menú interactivo para decidir cómo continuar.

**Criterios de aceptación:**

- Al derrotar a todos los enemigos, se presenta el modal de "¡VICTORIA!" con opciones: "Siguiente Nivel", "Volver al Mapa" y "Reintentar".
- Ganar el Nivel 1 desbloquea el Nivel 2 en el Mapa del Merodeador (`MenuNiveles`).
- Al invadirse el jardín, se presenta el modal de "¡DERROTA!" con opciones: "Reintentar" y "Volver al Mapa".
- El botón "Reintentar" recarga el Nivel 1 de inmediato.
- El botón "Volver al Mapa" carga la escena `menu_niveles.tscn`.

## Reglas funcionales

- La partida comienza con 150 Snitches.
- Harry cuesta 100 Snitches.
- Harry dispara cada 1,5 segundos.
- La Caja de Snitch cuesta 50 Snitches.
- Cada generación de la Caja de Snitch entrega una Snitch física de 25 Snitches cada 10 segundos.
- El Alumno Slytherin comienza con 200 puntos de vida.
- El Alumno Slytherin tarda 4 segundos por baldosa de 128px (velocidad 32 px/s).
- La única línea contiene las celdas disponibles para plantar aliados.
- Cada celda puede contener como máximo un aliado.
- Los aliados se plantan en la grilla y los enemigos avanzan desde la derecha.
- Capas de colisión física 2D:
  - Capa 1: Aliados (Harry, Caja de Snitch, Dementores)
  - Capa 2: Enemigos (Alumno Slytherin)
  - Capa 3: Hechizos (Proyectil)
  - Capa 4: Snitches (Snitch física recolectable)
- Las colisiones de ataques y objetivos se resuelven mediante `Area2D`, capas/máscaras y Grupos (`aliados`, `enemigos`, `hechizos`, `dementores`).

## Reglas de finalización del Nivel 1

- El nivel puede continuar mientras existan enemigos activos o el jugador pueda defender la línea.
- El nivel se considera ganado cuando todos los Alumnos Slytherin generados son derrotados.
- El nivel se considera perdido si un Alumno Slytherin alcanza la condición de invasión del jardín.

## Restricciones técnicas

- La implementación debe respetar Godot 4, el renderizador Compatibility y GDScript con tipado estático estricto.
- Debe existir una escena y un script propios para cada entidad.
- El estado de la interfaz debe leerse del estado real del motor mediante `godot-mcp` durante la implementación.
- La arquitectura debe basarse estrictamente en Nodos y Escenas.
