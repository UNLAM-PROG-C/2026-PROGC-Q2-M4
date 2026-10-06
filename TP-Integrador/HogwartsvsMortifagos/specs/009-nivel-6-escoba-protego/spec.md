# Feature Specification: Nivel 6 - Escoba y Alumno con Protego

**Feature Branch**: `[009-nivel-6-escoba-protego]`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 6 del juego. El objetivo central de este nivel es introducir mecánicas de control de masas para líneas completas (la Escoba) y enemigos con defensas complejas multiparte (Alumno Slytherin con Protego). Contexto del Nivel 6: Cuadrícula: 5 líneas completas. Enemigos: 'Alumno Slytherin', 'Draco' y el nuevo 'Alumno con Protego' (equivalente al Zombi con Puerta/Cubo). Arsenal disponible: Harry (100), Caja de Snitch (50), Recordadora (150), Protego (50), Accio (0), Ron (125) y la nueva adición: Escoba (125 snitches). Ritmo de recarga: La Escoba tiene un tiempo de recarga 'Muy lento'..."

## Clarifications

### Session 2026-10-06

- Q: ¿Desde qué posición horizontal debe iniciar el barrido la Escoba al ser plantada en una celda de la fila? → A: Desde el extremo izquierdo del carril (inicio de la cuadrícula en X), barriendo la totalidad de la fila de punta a punta sin importar en qué columna de dicha fila se haya hecho clic.
- Q: ¿Cuál debe ser el valor numérico exacto de la salud del escudo Protego del nuevo enemigo (shield_health)? → A: 300.0 puntos de vida de escudo (requiriendo 15 disparos de Harry o 10 de Ron), con umbrales de daño visual al recibir 100.0 (Frame 1) y 200.0 (Frame 2) de daño, y salud base del alumno en 200.0 puntos.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ataque de Área en Fila con la Escoba (Priority: P1)

Como jugador, quiero poder seleccionar y plantar la "Escoba" pagando 125 snitches en una fila comprometida para desencadenar un barrido horizontal que inicie desde el extremo izquierdo y barra toda la línea aplicando daño masivo a todos los enemigos de esa fila.

**Why this priority**: Es la nueva mecánica central de control de masas para líneas completas otorgada al jugador, actuando como recurso de emergencia de alto impacto.

**Independent Test**: Iniciar una partida con enemigos en una fila, acumular 125 snitches, plantar la Escoba en cualquier celda de esa fila y verificar que inicia su barrido desde el extremo izquierdo del carril desplazándose hacia la derecha, infligiendo 1800 puntos de daño masivo a cada enemigo en su trayectoria, y destruyéndose al salir del margen derecho.

**Acceptance Scenarios**:

1. **Given** el HUD con la carta de la Escoba disponible y saldo mayor o igual a 125 snitches, **When** el jugador selecciona la carta de la Escoba y hace clic en cualquier celda válida de una fila activa, **Then** se descuentan 125 snitches, la carta inicia su tiempo de recarga ("Muy lento", 25.0 segundos) y se libera la celda para que la Escoba comience su barrido.
2. **Given** la Escoba activada en una fila, **When** inicia su acción, **Then** parte desde el extremo izquierdo del carril y se desplaza en línea recta horizontal hacia la derecha atravesando toda la fila de punta a punta con una velocidad constante y animación de barrido.
3. **Given** la Escoba desplazándose por el carril, **When** colisiona con uno o múltiples enemigos en su trayectoria (Alumno Slytherin, Draco o Alumno con Protego), **Then** aplica un daño masivo de 1800 puntos (equivalente a la Recordadora) a cada enemigo alcanzado sin frenar ni interrumpir su movimiento.
4. **Given** la Escoba habiendo atravesado toda la fila, **When** supera el borde derecho de la pantalla, **Then** el nodo de la Escoba se libera automáticamente (`queue_free()`) sin dejar fugas ni bloquear la celda donde fue plantada.
5. **Given** la carta de la Escoba recién utilizada, **When** el jugador intenta seleccionarla antes de que transcurran sus 25.0 segundos de recarga, **Then** la carta permanece deshabilitada e inaccesible.

---

### User Story 2 - Composición Visual del Alumno con Protego (Priority: P2)

Como jugador y diseñador, quiero que el "Alumno con Protego" sea una entidad compuesta claramente por dos capas visuales identificables (el alumno y su escudo protego por delante) con 3 estados visibles de daño, para comprender inmediatamente el tipo de amenaza y el estado de la defensa mágica enemiga.

**Why this priority**: Brinda retroalimentación visual inmediata sobre la naturaleza compuesta del enemigo, diferenciándolo de los enemigos estándar.

**Independent Test**: Instanciar un Alumno con Protego en el juego y observar que se visualiza con el sprite base del alumno (`res://Images/slytherin_protego.png`) y el sprite del escudo (`res://Images/protego.png`) superpuesto a su izquierda, reflejando sus 3 fases de textura según el daño recibido.

**Acceptance Scenarios**:

1. **Given** la aparición de un Alumno con Protego en el tablero, **When** entra en pantalla, **Then** se compone visualmente por el sprite del alumno portando protección y, ubicado por delante de este (a su izquierda en el eje X), el sprite del escudo Protego.
2. **Given** el sprite del escudo Protego en su estado intacto (100% de vida del escudo), **When** no ha recibido impactos, **Then** muestra el fotograma inicial (Frame 0) de brillo mágico pleno sin fisuras.
3. **Given** el escudo Protego habiendo recibido daño moderado (entre 33% y 66% de su vida), **When** se actualiza su estado visual, **Then** cambia al fotograma intermedio (Frame 1) exhibiendo fracturas visibles en la barrera mágica.
4. **Given** el escudo Protego con daño crítico (más del 66% de su vida consumida), **When** se actualiza su estado visual, **Then** cambia al fotograma avanzado (Frame 2) mostrando un escudo severamente agrietado y a punto de colapsar.

---

### User Story 3 - Mecánica de Degradación de Escudo y Absorción de Daño (Priority: P1)

Como jugador, quiero que mis ataques convencionales desgasten y destruyan primero el escudo mágico antes de dañar al alumno que se refugia detrás, garantizando una lógica de combate estratificada.

**Why this priority**: Define el núcleo mecánico del enemigo tipo "tanque/blindado con escudo" (equivalente al Zombi con Cubo/Puerta), obligando al jugador a concentrar daño sostenido.

**Independent Test**: Colocar un atacante frente a un Alumno con Protego y verificar que los proyectiles impactan y reducen únicamente la salud del escudo (300 HP); al agotarse, el escudo desaparece, el alumno adopta su aspecto común y recibe el daño remanente en su salud base (200 HP).

**Acceptance Scenarios**:

1. **Given** un Alumno con Protego con escudo activo, **When** recibe impactos de proyectiles (Harry con 20 de daño, Ron con 30 de daño), **Then** el 100% del daño se resta de la reserva de salud del escudo (`shield_health`) sin afectar la salud base del alumno (`base_health`).
2. **Given** el escudo recibiendo daño continuo, **When** la salud del escudo llega a 0 o menos, **Then** el sprite del escudo desaparece inmediatamente, el sprite del alumno cambia de `slytherin_protego` a `slytherin` estándar, y el enemigo pierde su protección mágica.
3. **Given** un Alumno con Protego cuyo escudo ya fue destruido, **When** recibe nuevos impactos de proyectiles, **Then** el daño se descuenta directamente de la salud base del alumno (200 puntos).
4. **Given** un impacto masivo (como la Escoba o Recordadora con 1800 de daño), **When** alcanza a un Alumno con Protego, **Then** el daño sobrepasa la vida del escudo y el remanente se transfiere a la salud base del alumno, derrotando a la entidad completa en el acto.

---

### User Story 4 - Animaciones Dinámicas de Ataque con y sin Escudo (Priority: P2)

Como jugador, quiero ver que el Alumno con Protego realiza un ataque físico golpeando con el escudo mientras lo conserve, y que adopte la mordida estándar cuando haya perdido el escudo, asegurando coherencia visual en los combates cuerpo a cuerpo.

**Why this priority**: Enriquece la inmersión del combate y clarifica al jugador el método de ataque y el estado de la unidad cuando colisiona contra aliados defensivos como Protego.

**Independent Test**: Hacer que un Alumno con Protego colisione contra un aliado; verificar que realiza la animación oscilante de embestida con el escudo sin mordida, y que si su escudo es destruido mientras ataca, cambia de inmediato a la animación de mordida estándar (`slytherin_attacking`).

**Acceptance Scenarios**:

1. **Given** un Alumno con Protego que colisiona con un aliado en su fila y aún conserva su escudo, **When** comienza su ciclo de ataque, **Then** ejecuta una animación donde el sprite del escudo se desplaza hacia adelante y hacia atrás golpeando al aliado, mientras el sprite del alumno permanece en postura de empuje sin realizar animación de mordida.
2. **Given** un Alumno con Protego que se encuentra atacando con su escudo, **When** el escudo es destruido por impactos externos, **Then** el ataque con escudo cesa y la unidad transiciona inmediatamente a la animación estándar de mordida `slytherin_attacking` (con soporte para su variante de daño `slytherin_attacking_hurt`).
3. **Given** un Alumno con Protego sin escudo atacando a un aliado, **When** el aliado es derrotado o removido con Accio, **Then** el alumno regresa a su animación de marcha estándar `slytherin` avanzando hacia la izquierda.

---

### User Story 5 - Desafío y Progresión del Nivel 6 (Priority: P1)

Como jugador, quiero enfrentar el Nivel 6 en las 5 líneas completas con un mazo ampliado a 7 cartas (incluyendo la nueva Escoba), resistiendo oleadas densas con la presencia combinada de Alumnos Slytherin, Dracos y Alumnos con Protego, y desbloquear el Nivel 7 al conseguir la victoria.

**Why this priority**: Proporciona el escenario balanceado donde la combinación de la Escoba (limpieza de línea) y atacantes pesados (Ron) se vuelve indispensable ante enemigos con escudos protectores.

**Independent Test**: Jugar el Nivel 6 desde el selector de niveles, verificar que cuenta con 5 filas activas y 5 Dementores, utilizar la Escoba y el resto del arsenal contra las oleadas de enemigos, y comprobar que al vencer la oleada final se otorga la victoria y se desbloquea el Nivel 7 en el Mapa del Merodeador.

**Acceptance Scenarios**:

1. **Given** el inicio del Nivel 6, **When** se carga la escena, **Then** las 5 filas (Y=2..6) están activas con sus 5 Dementores defensivos, y transcurren 10 segundos iniciales de gracia antes del primer spawn de enemigos.
2. **Given** el HUD del Nivel 6, **When** el jugador revisa su banco de cartas, **Then** dispone de Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50), Escoba (125) y la herramienta Accio (0).
3. **Given** las oleadas de enemigos del Nivel 6, **When** se generan unidades, **Then** aparecen Alumnos Slytherin, Dracos y Alumnos con Protego distribuidos a lo largo de las 5 líneas.
4. **Given** la oleada final del Nivel 6, **When** se produce el asalto masivo, **Then** múltiples Alumnos con Protego avanzan simultáneamente respaldados por Dracos en diferentes carriles, incentivando el uso de la Escoba.
5. **Given** la eliminación de todos los enemigos del nivel, **When** el tablero queda despejado, **Then** se muestra la pantalla de victoria y se registra el desbloqueo del Nivel 7.

---

### Edge Cases

- **Escoba plantada en celda sin enemigos**: Si el jugador planta la Escoba en una fila completamente vacía, la Escoba debe realizar su recorrido de barrido completo hasta el margen derecho y liberarse sin fallos.
- **Accio intentado sobre la Escoba**: Como la Escoba es una unidad consumible de activación instantánea que inicia su desplazamiento de inmediato, no debe ser seleccionable para remoción con Accio mientras se desplaza.
- **Múltiples enemigos apilados en la misma celda al pasar la Escoba**: La Escoba debe infligir su daño masivo (1800) a todos y cada uno de los enemigos que colisionen con su área de barrido, sin detenerse ni limitarse al primer contacto.
- **Enemigo derrotado mientras la Escoba lo atraviesa**: Si un enemigo muere al primer contacto con la Escoba, su colisión debe desactivarse o procesarse adecuadamente para no generar dobles bajas ni excepciones en el árbol de nodos.
- **Destrucción del escudo durante la colisión con Protego aliado**: Si el escudo del Alumno con Protego colapsa mientras ambos están interactuando, el enemigo debe continuar dañando al aliado con su ataque de mordida sin reiniciar su posición ni desfasarse en el carril.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incorporar una carta de aliado para la "Escoba" con un costo de 125 snitches.
- **FR-002**: La carta de la Escoba MUST implementar un tiempo de recarga (cooldown) "Muy lento" configurado en 25.0 segundos.
- **FR-003**: Al plantar la Escoba en cualquier celda válida de una fila activa, el sistema MUST descontar 125 snitches y activar el desplazamiento horizontal de la Escoba hacia la derecha.
- **FR-004**: La Escoba MUST iniciar su barrido desde el extremo izquierdo de la fila (inicio de la cuadrícula en X) y desplazarse horizontalmente a velocidad constante hacia la derecha atravesando toda la fila.
- **FR-005**: La Escoba MUST infligir 1800 puntos de daño masivo (equivalente al daño de la Recordadora) a todos los enemigos que intersequen su trayectoria en dicha fila.
- **FR-006**: La Escoba MUST liberarse automáticamente (`queue_free()`) tras rebasar el margen derecho del área visible del juego.
- **FR-007**: El juego MUST incorporar al enemigo "Alumno con Protego" (`ProtegoStudent`) perteneciente al grupo `enemies`.
- **FR-008**: El Alumno con Protego MUST contar con dos reservas de salud independientes: salud del escudo (`shield_health = 300.0`) y salud base del alumno (`base_health = 200.0`).
- **FR-009**: Todo daño recibido por el Alumno con Protego mientras `shield_health > 0` MUST deducirse exclusivamente de la salud del escudo.
- **FR-010**: El sprite del escudo Protego MUST actualizarse a 3 estados visuales de degradación: Frame 0 (vida > 66%), Frame 1 (vida entre 33% y 66%) y Frame 2 (vida <= 33%).
- **FR-011**: Cuando `shield_health` llega a 0, el nodo del escudo MUST ocultarse o destruirse, y el sprite del alumno MUST cambiar de `slytherin_protego` a `slytherin`.
- **FR-012**: Una vez destruido el escudo, todo daño posterior recibido MUST deducirse de la salud base del alumno (`base_health`).
- **FR-013**: Mientras conserve su escudo, el Alumno con Protego atacando a un aliado MUST ejecutar una animación oscilante de golpe con el escudo (`SpriteEscudo`) sin animación de mordida en el alumno.
- **FR-014**: Al perder el escudo durante un ataque, el enemigo MUST cambiar automáticamente a la animación de ataque estándar `slytherin_attacking` (y su variante de daño `slytherin_attacking_hurt`).
- **FR-015**: El Nivel 6 MUST configurar las 5 filas activas (`active_rows = [2, 3, 4, 5, 6]`) protegidas inicialmente por 5 Dementores defensivos.
- **FR-016**: El Nivel 6 MUST incluir en su arsenal a Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba y la herramienta Accio.
- **FR-017**: La lista de enemigos del Nivel 6 MUST generar Alumnos Slytherin, Dracos y Alumnos con Protego.
- **FR-018**: El Nivel 6 MUST respetar el tiempo inicial de gracia de 10 segundos antes del primer spawn de enemigos.
- **FR-019**: La victoria en el Nivel 6 MUST desbloquear el Nivel 7 en el Mapa del Merodeador.
- **FR-020**: La textura de la Escoba MUST cargarse desde `res://Images/broomstick.png`.

### Key Entities

- **Escoba (`Broomstick`)**: Entidad aliada consumible de ataque de área de línea completa, con costo de 125 snitches, daño masivo de 1800 puntos y desplazamiento horizontal continuo hacia la derecha hasta salir de pantalla.
- **Alumno con Protego (`ProtegoStudent`)**: Entidad enemiga compuesta por un cuerpo de alumno y un escudo frontal, con absorción de daño estratificada (escudo primero, alumno después), retroalimentación visual en 3 estados y dos modos de animación de ataque.
- **Nivel 6 (`Level`)**: Escenario completo de 5 líneas con arsenal de 6 cartas aliadas más Accio, enfrentando una combinación de Alumnos comunes, blindados con cono (Draco) y blindados con escudo (Alumno con Protego).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: La Escoba barre la fila completa a velocidad constante e inflige 1800 puntos de daño al 100% de los enemigos ubicados en su trayectoria sin detenerse.
- **SC-002**: El Alumno con Protego absorbe hasta 300 puntos de daño en su escudo antes de que el alumno reciba un solo punto de daño directo en su salud base.
- **SC-003**: El escudo Protego transiciona visualmente entre sus 3 estados de daño (Frame 0, Frame 1, Frame 2) al alcanzar exactamente los umbrales de salud correspondientes (100%-67%, 66%-34%, 33%-1%).
- **SC-004**: Al destruirse el escudo, el sprite del alumno cambia a la textura estándar de Slytherin en menos de 1 fotograma (inmediatamente) y el escudo deja de renderizarse.
- **SC-005**: La Escoba se libera del Scene Tree (`queue_free()`) dentro de los 100 ms tras sobrepasar el límite derecho de la pantalla, sin consumir memoria residual.
- **SC-006**: Al completar la victoria del Nivel 6, el Nivel 7 se habilita en el Mapa del Merodeador en el 100% de los casos.

---

## Assumptions

- La salud del escudo de Protego se establece en 300.0 puntos (equivalente a 15 disparos de Harry o 10 disparos de Ron), mientras que la salud base del Alumno es de 200.0 puntos (salud estándar del enemigo base).
- La velocidad de desplazamiento horizontal de la Escoba se fija en 600.0 píxeles por segundo, tardando aproximadamente entre 2 y 3 segundos en cruzar la pantalla completa.
- El tiempo de recarga de la carta de la Escoba en el HUD es de 25.0 segundos, alineado con el estándar "Muy lento" de la Recordadora.
- El Nivel 7 está contemplado en el selector de niveles (`LEVEL_COUNT = 10`), permitiendo el desbloqueo secuencial.
- El daño masivo de la Escoba de 1800 puntos es suficiente para derrotar en un solo barrido al Alumno con Protego completo ($300 + 200 = 500 < 1800$), a Draco (140 HP) y al Alumno común (200 HP).
