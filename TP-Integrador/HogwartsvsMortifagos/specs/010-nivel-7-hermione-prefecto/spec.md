# Feature Specification: Nivel 7 - Hermione y Prefecto Slytherin

**Feature Branch**: `[010-nivel-7-hermione-prefecto]`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 6 y 7 del juego (enfocado en el Nivel 7). El objetivo central de este nivel es introducir mecánicas de estados alterados (ralentización) y el primer enemigo con capacidad de ataque a distancia, rompiendo la regla de que los enemigos solo hacen daño cuerpo a cuerpo. Contexto del Nivel 7: Cuadrícula: 5 líneas completas. Enemigos: 'Alumno Slytherin', 'Draco', 'Alumno con Protego' y la nueva amenaza: 'Prefecto Slytherin' (Enemigo a distancia). Arsenal disponible: Harry (100), Caja de Snitch (50), Recordadora (150), Protego (50), Accio (0), Ron (125), Escoba (125) y la nueva carta: Hermione (125 snitches). HU-1: Ataque de Hielo/Ralentización (Hermione). HU-2: Enemigo a Distancia (Prefecto Slytherin). HU-3: Animación del Proyectil Enemigo."

## Clarifications

### Session 2026-10-06

- Q: ¿Debe el Prefecto Slytherin disparar periódicamente de forma incondicional o solo cuando detecta aliados a su izquierda en su fila? → A: Disparar únicamente si detecta al menos un aliado presente en su fila hacia la izquierda.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ataque Ralentizador de Hermione (Priority: P1)

Como jugador, quiero poder plantar a "Hermione" en el jardín pagando 125 snitches para que dispare hechizos mágicos con efecto de hielo que infligen daño y ralentizan el avance y la cadencia de ataque de los enemigos, dándome más tiempo para destruirlos antes de que alcancen mis defensas.

**Why this priority**: Es la nueva carta y mecánica central del jugador introducida en el Nivel 7, permitiendo por primera vez aplicar estados alterados de control y sinergizar con atacantes como Harry o Ron.

**Independent Test**: Plantar a Hermione en una fila con enemigos en avance; verificar que dispara proyectiles teñidos de azul con la misma cadencia y daño base que Harry, y que al impactar, el enemigo reduce su velocidad de desplazamiento y ataque al 70% (30% de reducción), adoptando un tinte azul visual durante 5.0 segundos sin que múltiples impactos acumulen una reducción mayor al 30%.

**Acceptance Scenarios**:

1. **Given** el HUD del Nivel 7 con saldo de al menos 125 snitches, **When** el jugador selecciona la carta de Hermione y hace clic en una celda libre de una fila activa, **Then** se descuentan 125 snitches, se inicia su tiempo de recarga y se coloca a Hermione en dicha celda.
2. **Given** Hermione ubicada en una fila con un enemigo visible frente a ella, **When** detecta al enemigo en su línea, **Then** dispara un proyectil de hechizo que comparte la cadencia (1.5 segundos), velocidad y daño base (20 puntos) de Harry, pero con un tinte visual distintivo en color azul celeste.
3. **Given** un enemigo en movimiento o atacando (Alumno Slytherin, Draco, Alumno con Protego o Prefecto Slytherin), **When** es impactado por el proyectil de Hermione, **Then** recibe el daño base y entra inmediatamente en estado de ralentización, reduciendo su velocidad de movimiento y su cadencia de ataque al 70% de su valor normal (30% de ralentización).
4. **Given** un enemigo afectado por la ralentización, **When** se encuentra bajo dicho efecto, **Then** su sprite muestra un tinte azul continuo que comunica visualmente el estado alterado hasta que expira el tiempo de efecto (5.0 segundos) o hasta que el enemigo muere.
5. **Given** un enemigo ya ralentizado, **When** recibe impactos adicionales de proyectiles de Hermione antes de que expire el efecto previo, **Then** la duración de la ralentización se reinicia a 5.0 segundos pero el factor de reducción no se acumula por debajo del 70%.
6. **Given** un enemigo ralentizado cuyo efecto llega a los 5.0 segundos sin recibir nuevos impactos de Hermione, **When** termina el temporizador del estado, **Then** recupera inmediatamente su velocidad normal (100%), su cadencia normal y su coloración visual estándar.

---

### User Story 2 - Enemigo a Distancia: Prefecto Slytherin (Priority: P1)

Como jugador, me enfrentaré al "Prefecto Slytherin", un enemigo capaz de lanzar ataques a distancia que dañan a mis aliados desde lejos, obligándome a proteger mis líneas con aliados defensivos como Protego.

**Why this priority**: Rompe la regla previa de combate estrictamente cuerpo a cuerpo, transformando la dinámica táctica del juego y forzando al jugador a utilizar defensas preventivas.

**Independent Test**: Permitir el avance de un Prefecto Slytherin en una fila con aliados; verificar que camina hacia la izquierda con la salud de un Alumno común, verifica la existencia de aliados a su izquierda en su fila y se detiene periódicamente para agitar su varita y disparar un proyectil mágico que colisiona con el primer aliado en su trayectoria restándole vida.

**Acceptance Scenarios**:

1. **Given** la aparición de un Prefecto Slytherin en una fila, **When** ingresa al tablero, **Then** su salud base es idéntica a la de un Alumno Slytherin común (200 puntos) y su aspecto visual reutiliza al alumno en postura de varita de Slytherin Protego sin mostrar ningún escudo protector.
2. **Given** el Prefecto avanzando hacia el jardín, **When** transcurre su intervalo de ataque a distancia (cada 3.5 segundos) y detecta al menos un aliado presente en su fila hacia la izquierda, **Then** se detiene brevemente en su posición, apunta hacia la izquierda y dispara un proyectil enemigo en línea recta horizontal hacia dicho aliado.
3. **Given** el Prefecto avanzando en una fila donde no hay ningún aliado presente hacia la izquierda, **When** transcurre su temporizador de disparo, **Then** no dispara proyectiles y continúa caminando hacia la izquierda de forma ininterrumpida.
4. **Given** un proyectil enemigo viajando hacia la izquierda en una fila, **When** alcanza al primer aliado en su trayectoria (e.g. Protego, Harry, Snitch Box, Ron o Hermione), **Then** el proyectil impacta, se destruye y reduce la salud del aliado en 20 puntos de daño.
5. **Given** un Prefecto Slytherin que llega a estar adyacente cuerpo a cuerpo con un aliado, **When** entra en rango de colisión física, **Then** ataca cuerpo a cuerpo de forma coherente con los demás enemigos.
6. **Given** un Prefecto que recibe impactos de proyectiles aliados mientras prepara o ejecuta disparos, **When** su salud llega a 0, **Then** es derrotado inmediatamente, interrumpiendo cualquier disparo pendiente y emitiendo su señal de derrota.

---

### User Story 3 - Visual y Animación del Hechizo del Prefecto (Priority: P2)

Como jugador y diseñador, quiero que el proyectil disparado por el Prefecto esté animado con un ciclo continuo de 4 fotogramas usando la textura `slytherin_shot`, para que se distinga nítidamente de los hechizos de los aliados y transmita la sensación de magia oscura en movimiento.

**Why this priority**: Ofrece retroalimentación visual clara y atractiva que permite al jugador identificar instantáneamente un ataque enemigo hostil en vuelo y distinguirlo de sus propios hechizos.

**Independent Test**: Observar el proyectil disparado por el Prefecto desplazándose hacia la izquierda; verificar que cicla fluidamente por los 4 cuadros horizontales de la hoja `slytherin_shot.png` hasta impactar con un aliado o salir de pantalla.

**Acceptance Scenarios**:

1. **Given** el disparo ejecutado por el Prefecto Slytherin ante un aliado detectado, **When** el proyectil aparece en el carril, **Then** se renderiza utilizando la textura `res://Images/slytherin_shot.png`.
2. **Given** la hoja de sprites de `slytherin_shot` de 1 fila por 4 columnas, **When** el proyectil se desplaza hacia la izquierda, **Then** cicla de manera continua y en bucle a través de los fotogramas 0, 1, 2 y 3.
3. **Given** el proyectil enemigo en vuelo, **When** supera el margen izquierdo de la pantalla (o si el aliado fue retirado antes del impacto), **Then** se destruye y libera automáticamente de la memoria sin generar errores.

---

### User Story 4 - Desafío y Progresión del Nivel 7 (Priority: P1)

Como jugador, quiero jugar el Nivel 7 en las 5 líneas completas con un arsenal completo de 8 cartas (incluyendo la nueva Hermione) para superar oleadas combinadas de Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin, desbloqueando el Nivel 8 tras la victoria.

**Why this priority**: Es la culminación jugable de la funcionalidad donde convergen todas las mecánicas anteriores junto con la ralentización y el ataque a distancia enemigo.

**Independent Test**: Iniciar el Nivel 7 desde el selector de niveles, verificar 5 filas activas con 5 Dementores, seleccionar cartas del banco completo de 8 cartas, resistir las oleadas con la nueva mezcla de 4 tipos de enemigos y verificar el desbloqueo del Nivel 8 en el mapa al ganar.

**Acceptance Scenarios**:

1. **Given** la carga del Nivel 7, **When** se inicia la escena, **Then** las 5 filas (Y=2..6) están activas con sus 5 Dementores y se respeta un período de gracia inicial de 10 segundos antes del primer spawn.
2. **Given** el banco de cartas del Nivel 7, **When** el jugador revisa el HUD, **Then** dispone de Harry (100), Snitch Box (50), Ron (125), Recordadora (150), Protego (50), Escoba (125), Hermione (125) y Accio (0).
3. **Given** las oleadas del Nivel 7, **When** se generan enemigos, **Then** aparecen Alumnos comunes, Dracos, Alumnos con Protego y Prefectos Slytherin en los diferentes carriles.
4. **Given** la presencia de Prefectos Slytherin en retaguardia detrás de Alumnos con Protego, **When** avanzan en conjunto, **Then** el jugador debe combinar la ralentización de Hermione y la protección de Protego para defender sus carriles.
5. **Given** la derrota del último enemigo de la oleada final, **When** el tablero queda despejado, **Then** se muestra el panel de victoria y se registra el desbloqueo del Nivel 8 en el progreso del juego.

---

### Edge Cases

- **Enemigo derrotado mientras está ralentizado**: La expiración del temporizador de ralentización o la liberación de la entidad no debe producir referencias nulas ni fallos en memoria si el enemigo es destruido durante el efecto.
- **Múltiples impactos de Hermione en rápida sucesión**: Si un enemigo recibe 3 disparos seguidos de Hermione, el multiplicador de velocidad debe mantenerse fijado en 0.70 (sin decrecer a 0.49 ni 0.34) y únicamente renovar la cuenta regresiva de 5.0 segundos.
- **Prefecto en fila sin aliados por delante**: Si no hay aliados plantados en la fila o todos fueron eliminados, el Prefecto no realiza disparos y continúa su avance horizontal continuo.
- **Prefecto eliminado con proyectil en vuelo**: Si el Prefecto muere mientras su proyectil viaja por la fila, dicho proyectil debe continuar su trayectoria e impactar a los aliados con normalidad.
- **Interacción de proyectil enemigo con Dementores**: Si un proyectil enemigo alcanza el borde izquierdo antes que el Prefecto, no debe activar al Dementor defensivo (el Dementor solo se activa ante la invasión física de un enemigo que pisa la celda del extremo).
- **Proyectil de Hermione contra escudo de Alumno con Protego**: El proyectil de Hermione debe aplicar su daño al escudo y además aplicar el efecto de ralentización y tinte azul a toda la unidad compuesta mientras tenga escudo o sin él.
- **Impacto de proyectil enemigo sobre Protego aliado**: Protego debe absorber el impacto del proyectil restando de su propia reserva de salud y reflejando sus estados de grieta normales.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incorporar una carta de aliado para "Hermione" con un costo de 125 snitches y tiempo de recarga estándar (5.0 segundos).
- **FR-002**: La aliada "Hermione" MUST contar con 300 puntos de salud base y una cadencia de disparo de 1 proyectil cada 1.5 segundos (idéntica a Harry).
- **FR-003**: El proyectil disparado por Hermione MUST infligir 20 puntos de daño base al colisionar con un enemigo.
- **FR-004**: El proyectil disparado por Hermione MUST mostrar una coloración azul celeste distintiva mediante tinte (`modulate`) sobre el sprite del proyectil.
- **FR-005**: Al impactar sobre cualquier enemigo, el proyectil de Hermione MUST activar un estado de ralentización que reduce la velocidad de desplazamiento del enemigo al 70% de su valor base.
- **FR-006**: El estado de ralentización MUST reducir la cadencia de ataque cuerpo a cuerpo del enemigo al 70% de su velocidad normal (daño por segundo reducido en un 30%).
- **FR-007**: El estado de ralentización MUST tener una duración de 5.0 segundos, reiniciable con cada nuevo impacto ralentizador sin acumular reducciones adicionales más allá del factor 0.70.
- **FR-008**: Durante la duración del estado de ralentización, el sprite del enemigo afectado MUST exhibir un tinte azul visual para indicar claramente la alteración de estado.
- **FR-009**: Al expirar el tiempo de ralentización, el enemigo MUST restaurar de inmediato su velocidad original, cadencia normal y modulación de color estándar.
- **FR-010**: El juego MUST incorporar al enemigo "Prefecto Slytherin" (`SlytherinPrefect`) perteneciente al grupo `enemies`.
- **FR-011**: El Prefecto Slytherin MUST contar con 200 puntos de salud base (idéntica al Alumno Slytherin común).
- **FR-012**: El sprite del Prefecto Slytherin MUST basarse en la textura `slytherin_protego` mostrando la figura del alumno con su varita y omitiendo la capa visual del escudo.
- **FR-013**: El Prefecto Slytherin MUST desplazarse horizontalmente hacia la izquierda y disparar proyectiles periódicamente cada 3.5 segundos únicamente cuando detecta al menos un aliado presente en su fila hacia la izquierda; si no hay aliados por delante en su fila, MUST continuar caminando sin disparar.
- **FR-014**: El proyectil del Prefecto Slytherin MUST desplazarse en línea recta horizontal hacia la izquierda a una velocidad constante (400 píxeles por segundo).
- **FR-015**: El proyectil del Prefecto Slytherin MUST usar la textura `res://Images/slytherin_shot.png` configurada con 4 fotogramas en horizontal (`hframes = 4, vframes = 1`).
- **FR-016**: La animación del proyectil enemigo MUST reproducir en bucle continuo los 4 fotogramas durante su trayectoria.
- **FR-017**: Al colisionar con cualquier aliado en su carril, el proyectil enemigo MUST infligir 20 puntos de daño al aliado y destruirse inmediatamente.
- **FR-018**: El Nivel 7 MUST configurar las 5 líneas completas del tablero (`active_rows = [2, 3, 4, 5, 6]`) protegidas por 5 Dementores defensivos.
- **FR-019**: El Nivel 7 MUST incluir en su arsenal a Harry, Snitch Box, Ron, Recordadora, Protego, Escoba, Hermione y la herramienta Accio.
- **FR-020**: El Nivel 7 MUST generar en sus oleadas a Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin.
- **FR-021**: La victoria en el Nivel 7 MUST desbloquear el Nivel 8 en el Mapa del Merodeador y en el menú de niveles.

### Key Entities

- **Hermione (`Hermione`)**: Entidad aliada que dispara hechizos de hielo que dañan y ralentizan el movimiento y el ataque de los enemigos. Costo: 125 snitches. Salud: 300 HP.
- **Proyectil de Hermione (`HermioneProjectile` / `Projectile` con efecto helado)**: Proyectil mágico azul que viaja hacia la derecha aplicando 20 de daño y el estado de ralentización del 30% por 5 segundos.
- **Prefecto Slytherin (`SlytherinPrefect`)**: Entidad enemiga a distancia que camina hacia la izquierda y dispara proyectiles oscuros periódicamente contra los aliados en su fila cuando detecta su presencia. Salud: 200 HP.
- **Proyectil Enemigo (`EnemyProjectile`)**: Proyectil animado de 4 fotogramas que viaja hacia la izquierda a 400 px/s e inflige 20 de daño al primer aliado que impacta.
- **Nivel 7 (`Level7`)**: Escenario de 5 líneas con oleadas mixtas de 4 tipos de enemigos y un mazo completo de 8 cartas aliadas.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Los enemigos alcanzados por el proyectil de Hermione ven reducida su velocidad de desplazamiento y de ataque exactamente al 70% de su valor base (reducción del 30%) en menos de 1 fotograma tras el impacto.
- **SC-002**: El efecto de ralentización y el tinte azul persisten exactamente durante 5.0 segundos desde el último impacto, restableciendo la velocidad normal al expirar en el 100% de los casos.
- **SC-003**: Múltiples impactos consecutivos de Hermione renuevan la duración de 5.0 segundos sin reducir la velocidad por debajo del factor 0.70.
- **SC-004**: El Prefecto Slytherin dispara proyectiles hacia la izquierda con una cadencia de 3.5 segundos siempre que haya al menos un aliado en su fila, sin generar disparos innecesarios cuando no hay aliados por delante.
- **SC-005**: El proyectil del Prefecto reproduce un ciclo ininterrumpido de 4 fotogramas a lo largo de su vuelo hasta colisionar o salir de la pantalla.
- **SC-006**: Al completar la victoria del Nivel 7, el Nivel 8 queda registrado como desbloqueado en el progreso del juego en el 100% de los intentos exitosos.

---

## Assumptions

- La duración base del estado de ralentización es de 5.0 segundos, suficiente para compensar la cadencia de disparo de Hermione (1.5 segundos) y asegurar que un enemigo bajo fuego continuo se mantenga permanentemente ralentizado.
- El factor de ralentización de 0.70 reduce en un 30% tanto la velocidad de caminata horizontal como la tasa de daño por segundo que infligen los enemigos al morder aliados.
- El Prefecto Slytherin tiene un intervalo de disparo de 3.5 segundos y un daño de 20 puntos por impacto, coherente con la escala de daño estándar de los proyectiles aliados.
- La velocidad del proyectil del Prefecto es de 400.0 px/s en dirección `-X` (hacia la izquierda), idéntica a la velocidad hacia la derecha de los proyectiles aliados.
- El proyectil del Prefecto no colisiona con otros enemigos ni con otros proyectiles en vuelo; impacta exclusivamente contra aliados (grupo `allies`).
- La textura `slytherin_shot.png` contiene 4 fotogramas horizontales de dimensiones uniformes para su reproducción cíclica.
- El desbloqueo del Nivel 8 está soportado por el selector de niveles (`LEVEL_COUNT = 10`).
