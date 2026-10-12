# Feature Specification: Nivel 10 - Batalla contra Jefe Final (Quirrell / Voldemort)

**Feature Branch**: `014-nivel-10-quirrell-boss`

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 10, el nivel final del juego. Este nivel rompe con la mecánica clásica de oleadas y se centra en una batalla contra un Jefe Final: el Profesor Quirrell/Voldemort."

## Clarifications

### Session 2026-10-12
- Q: ¿Qué debe suceder con los enemigos y sombras remanentes en el tablero en el instante exacto en que la vida de Quirrell llega a 0? → A: Victoria inmediata: al llegar Quirrell a 0 de vida, todos los enemigos y sombras activos son derrotados automáticamente y se muestra la victoria final.
- Q: ¿Dónde se ubica exactamente Quirrell y cómo interactúa con la plantación de aliados en su posición? → A: Bloquea la última columna: Quirrell se coloca dentro de la celda de la cuadrícula en la columna extrema derecha (columna 10) y esa casilla específica queda bloqueada para plantar mientras él esté allí.
- Q: ¿Qué sucede si un aliado ya estaba plantado en la última columna de la fila a la que Quirrell se teletransporta? → A: Aplasta al aliado: si Quirrell se teletransporta a una celda de la última columna (columna 10) donde hay un aliado plantado, el aliado es destruido inmediatamente.
- Q: ¿Qué variedad de enemigos regulares de apoyo debe aparecer durante el Nivel 10? → A: Todos los tipos de enemigos: Slytherin Student, Draco, Protego Student, Slytherin Prefect y Troll aparecen como apoyo durante el nivel.
- Q: ¿Cómo se anima el enemigo Sombra? → A: Sprite animado de 1 fila y 2 columnas (`hframes = 2`, `vframes = 1`), ciclando entre ambas poses al desplazarse.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Duelo contra el Jefe Final Estacionario y Teletransportación (Priority: P1)

Como jugador, quiero enfrentarme a un jefe final imponente que se mantenga en la última columna del tablero y cambie de carril periódicamente, para que deba planificar y distribuir estratégicamente mis plantas y hechizos en todas las líneas.

**Why this priority**: Es el núcleo de la experiencia del Nivel 10. Transforma el juego de supervivencia por oleadas en una batalla contra un objetivo único de alta resistencia.

**Independent Test**: Puede probarse instanciando al jefe en la última columna de la cuadrícula con su barra de vida en el HUD, verificando que bloquee la plantación en su celda, que reciba daño de proyectiles y explosiones, que se teletransporte entre carriles cada 20 segundos dejando una sombra a sus pies y aplastando cualquier aliado en su celda de destino, y que al llegar a 0 de vida se active la victoria del nivel eliminando a los enemigos restantes.

**Acceptance Scenarios**:

1. **Given** el inicio del Nivel 10 en la arena final de piedra gris, **When** carga el nivel, **Then** Quirrell aparece en la última columna de la cuadrícula (columna 8) en una fila activa, bloquea la plantación en esa casilla, permanece estacionario sin avanzar hacia el jardín y el HUD muestra una barra de vida superior del jefe en lugar del reloj de arena de oleadas.
2. **Given** Quirrell en su posición, **When** recibe impactos de hechizos regulares o explosiones de Recordadora o Escoba, **Then** su vida disminuye proporcionalmente y la barra superior de vida refleja el daño inmediatamente.
3. **Given** Quirrell en una fila, **When** transcurren 20 segundos exactos, **Then** desaparece dejando un efecto de sombra oscura en sus pies y reaparece instantáneamente en una de las otras 4 filas de forma aleatoria en la última columna.
4. **Given** un aliado plantado en la última columna de una fila, **When** Quirrell se teletransporta a esa celda, **Then** el aliado existente en dicha casilla es destruido inmediatamente al materializarse el jefe.
5. **Given** Quirrell en combate, **When** sus puntos de salud se reducen a 0, **Then** el jefe es derrotado, todos los enemigos y sombras activos en pantalla son eliminados automáticamente y se dispara la pantalla de victoria final del juego.

---

### User Story 2 - Progresión de Fases del Jefe y Caída del Turbante (Priority: P2)

Como jugador, quiero que el jefe cambie de fase al sufrir daño significativo, perdiendo su turbante y volviéndose más agresivo, para sentir una escalada dramática de tensión en el clímax de la batalla.

**Why this priority**: Proporciona ritmo narrativo y desafío creciente al combate, evitando que la batalla contra un jefe con tanta vida se vuelva monótona.

**Independent Test**: Puede probarse reduciendo la vida de Quirrell al 50%, verificando que el gorro desaparezca para mostrar el rostro oculto en su nuca, y comprobando que la cadencia de invocación pase de 15 segundos a 8 segundos con la posibilidad de ataque masivo.

**Acceptance Scenarios**:

1. **Given** Quirrell en Fase 1 con más del 50% de su vida máxima, **When** transcurre su ciclo de invocación cada 15 segundos, **Then** invoca una Sombra en su fila actual manteniendo visible su turbante morado.
2. **Given** Quirrell recibiendo daño en Fase 1, **When** su vida cae al 50% o menos de su salud máxima (18.000 puntos o menos), **Then** el turbante morado desaparece revelando el rostro de Voldemort en la nuca y el jefe transiciona permanentemente a Fase 2.
3. **Given** Quirrell en Fase 2, **When** transcurre su ciclo de invocación acelerado cada 8 segundos, **Then** invoca Sombras con mayor frecuencia.
4. **Given** un ciclo de invocación en Fase 2 (cada 8 segundos), **When** se evalúa la probabilidad del 10%, **Then** en el 90% de los casos invoca 1 Sombra en su carril actual, y en el 10% de los casos activa su habilidad definitiva invocando 1 Sombra simultáneamente en cada una de las 5 líneas del tablero.

---

### User Story 3 - Amenaza Rápida de las Sombras Invocadas y Apoyo de Enemigos (Priority: P3)

Como jugador, quiero que las Sombras invocadas por el jefe avancen velozmente junto a oleadas de apoyo de todos los tipos de enemigos de Hogwarts, para ponerme a prueba ante invasiones dinámicas y sorpresivas.

**Why this priority**: Las sombras y los enemigos regulares de apoyo complementan la amenaza del jefe, obligando al jugador a mantener defensas activas y no enfocarse únicamente en disparar a Quirrell.

**Independent Test**: Puede probarse midiendo la velocidad de avance de una Sombra en comparación con un Alumno Slytherin estándar, verificando que avance 1.5 veces más rápido y requiera la misma cantidad de impactos para ser derrotada, mientras enemigos regulares (Slytherin, Draco, Protego Student, Prefect y Troll) aparecen periódicamente.

**Acceptance Scenarios**:

1. **Given** una Sombra invocada en el tablero, **When** avanza hacia la izquierda, **Then** se desplaza a una velocidad 50% mayor (1.5x) que la de un Alumno Slytherin común (48 px/s).
2. **Given** una Sombra alcanzando un aliado, **When** inicia su ataque cuerpo a cuerpo, **Then** inflige el mismo daño por segundo que un Alumno Slytherin básico (30 de daño/segundo).
3. **Given** una Sombra recibiendo daño, **When** acumula daño equivalente a la vida de un Alumno Slytherin básico (200 puntos), **Then** es eliminada del tablero.
4. **Given** el transcurso del combate, **When** avanza el nivel, **Then** el sistema genera enemigos regulares de apoyo de todos los tipos (Slytherin Student, Draco, Protego Student, Slytherin Prefect y Troll).

---

### Edge Cases

- **Teletransporte mientras recibe daño continuo**: Si un proyectil o ataque continuo (como Escoba) coincide con el segundo 20 de teletransporte, el daño pendiente debe resolverse antes o después de la reubicación sin provocar lecturas nulas ni saltos anómalos de posición.
- **Invocación masiva con carriles saturados**: Si el 10% de invocación masiva se dispara cuando hay enemigos normales ya avanzando en las 5 líneas, las 5 sombras deben instanciarse correctamente sin interferir con las colisiones ni sobreescribir otros enemigos.
- **Transición de fase al recibir daño letal o masivo**: Si un impacto potente (ej. explosión de 1800 de daño) hace que la vida pase de más del 50% a menos del 50%, la transición de Fase 2 (ocultar turbante y ajustar temporizador) debe ejecutarse limpiamente de inmediato sin retrasos.
- **Teletransporte sobre un aliado plantado**: Si la celda de destino en la columna 8 contiene un aliado, este es destruido inmediatamente para evitar estados con múltiples entidades ocupando la misma casilla.
- **Derrota con enemigos y sombras remanentes**: Cuando Quirrell llega a 0 de vida, el nivel concluye en victoria inmediata, detiene cualquier nuevo spawn y elimina/derrota automáticamente a todos los enemigos y sombras presentes en el tablero.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El Nivel 10 DEBE ambientarse en la arena final de combate utilizando el fondo temático de piedra gris rodeado de raíces y tentáculos (`final_background.png`) sobre una cuadrícula activa de 5 filas completas (filas 2 a 6).
- **FR-002**: El HUD del Nivel 10 DEBE ocultar el medidor tradicional de oleadas (reloj de arena) y en su lugar DEBE exhibir una barra de progreso superior visible para la vida del jefe.
- **FR-003**: La barra de vida superior del jefe DEBE actualizarse dinámicamente en tiempo real cada vez que la salud del jefe cambie, mostrando visualmente el porcentaje restante entre el valor inicial y cero.
- **FR-004**: El jefe final (Profesor Quirrell) DEBE instanciarse al iniciar el nivel en la columna extrema derecha de la cuadrícula (columna 10) en una fila activa, manteniéndose estacionario sin desplazamiento horizontal hacia el jardín.
- **FR-005**: Mientras Quirrell ocupe una celda en la columna 10, dicha casilla DEBE estar bloqueada para la plantación de aliados.
- **FR-006**: La salud máxima de Quirrell DEBE fijarse en exactamente 36.000 puntos, calculada para resistir exactamente 20 explosiones masivas de 1.800 de daño (Recordadora o Escoba).
- **FR-007**: Quirrell DEBE recibir daño de todos los proyectiles de los aliados y de las áreas de explosión masiva que intersecten su posición.
- **FR-008**: Quirrell DEBE teletransportarse cada 20 segundos exactos a otra de las 4 filas activas elegida al azar, mostrando un efecto visual de sombra oscura en sus pies en el punto de origen y reapareciendo instantáneamente en la columna 10 de la nueva fila.
- **FR-009**: Si la casilla de destino en la columna 10 a la que Quirrell se teletransporta contiene un aliado, dicho aliado DEBE ser destruido inmediatamente al materializarse el jefe.
- **FR-010**: Durante la Fase 1 (salud superior al 50%, es decir, > 18.000 puntos), Quirrell DEBE mostrar su turbante morado sobre su sprite y DEBE invocar 1 enemigo Sombra en su carril actual cada 15 segundos.
- **FR-011**: Al descender la salud de Quirrell al 50% o menos ($\le$ 18.000 puntos), el jefe DEBE transicionar a Fase 2: el turbante morado desaparece para revelar el rostro de Voldemort en la nuca.
- **FR-012**: Durante la Fase 2, el intervalo de invocación del jefe DEBE reducirse a 8 segundos.
- **FR-013**: En cada ciclo de invocación de Fase 2 (cada 8 segundos), el sistema DEBE evaluar una probabilidad del 10% para desencadenar la Habilidad Definitiva (invocar 1 Sombra en cada una de las 5 líneas simultáneamente); en el 90% restante DEBE invocar 1 Sombra en el carril actual del jefe.
- **FR-014**: El enemigo "Sombra" DEBE pertenecer al grupo de enemigos (`enemies`), utilizar un sprite animado de 1 fila y 2 columnas, avanzar hacia la izquierda a una velocidad de 48 px/s (1.5x la velocidad de 32 px/s del Alumno Slytherin), poseer 200 puntos de salud y causar 30 de daño/segundo a los aliados.
- **FR-015**: El nivel DEBE continuar generando enemigos regulares de apoyo de todos los tipos existentes (Slytherin Student, Draco, Protego Student, Slytherin Prefect y Troll) a lo largo del combate.
- **FR-016**: La condición de victoria del Nivel 10 DEBE alcanzarse cuando la salud de Quirrell llega a 0. En ese instante exacto, todos los enemigos regulares y sombras activos en el tablero DEBEN ser derrotados/eliminados automáticamente y DEBE mostrarse la pantalla de victoria final del juego.

### Key Entities *(include if feature involves data)*

- **Quirrell (Boss)**: Entidad jefe final posicionada en la columna 8. Atributos: `health` (36000), `max_health` (36000), `current_phase` (1 o 2), `teleport_timer` (20s), `invocation_timer` (15s en fase 1, 8s en fase 2), `has_turban` (true en fase 1, false en fase 2). Emite señales de cambio de vida y derrota.
- **Shadow (Enemy)**: Invocación espectral del jefe. Atributos: `speed` (48 px/s), `health` (200), `damage_per_second` (30). Desplazamiento horizontal hacia la izquierda, colisión con aliados y detección en carril.
- **BossHealthBar (UI)**: Componente de interfaz ubicado en la parte superior del HUD. Atributos: `value`, `max_value` (36000). Escucha las variaciones de salud del jefe para reflejar el progreso del combate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El combate contra el jefe final concluye en victoria cuando la vida de Quirrell llega a 0, requiriendo exactamente 36.000 puntos de daño acumulado y derrotando automáticamente a todos los enemigos activos restantes.
- **SC-002**: El teletransporte del jefe ocurre consistentemente a intervalos de 20 segundos ($\pm 0.1$ s), eligiendo siempre una fila diferente a la actual y destruyendo cualquier aliado preexistente en la celda de destino.
- **SC-003**: La plantación de aliados queda bloqueada en la celda donde Quirrell esté ubicado en todo momento.
- **SC-004**: La transición a Fase 2 ocurre de forma inmediata en el instante exacto en que la salud llega a 18.000 puntos o menos, ocultando el turbante y reduciendo el intervalo de invocación de 15 s a 8 s.
- **SC-005**: Durante Fase 2, el ataque masivo de 5 sombras se ejecuta con una tasa observada del 10% de las invocaciones a lo largo de pruebas estadísticas.
- **SC-006**: La Sombra se desplaza a exactamente 48 px/s, completando el recorrido de un carril de 1920 px un 33% más rápido que un enemigo común.
- **SC-007**: La barra de vida del jefe en el HUD permanece visible durante todo el nivel y reemplaza completamente el reloj de arena de oleadas.

## Assumptions

- Las cartas de aliados disponibles en el Nivel 10 corresponden al conjunto completo desbloqueado en el Nivel 9 (Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba, Hermione, McGonagall y Dumbledore).
- Los enemigos comunes que aparecen de soporte continúan utilizando la lógica de spawners y ritmo de dificultad del nivel, abarcando todos los tipos de enemigos del juego (Slytherin Student, Draco, Protego Student, Slytherin Prefect y Troll).
- Los recursos gráficos `final_background.png`, `quirrell.png`, `quirrell_turban.png` y `character_shadow.png` en la carpeta `Images/` están disponibles y listos para ser utilizados por las escenas.
- El valor de daño de Recordadora y Escoba es de 1.800 puntos (verificado en sus recursos y scripts del proyecto), por lo que 20 impactos corresponden exactamente a 36.000 de vida máxima.
