# Feature Specification: Nivel 5 - Introducción de Ron y Escalado de Mortífagos

**Feature Branch**: `[008-nivel-5-ron]`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 5 del juego. Será un nivel estándar de defensa y gestión de recursos (snitches) en la grilla completa, con el objetivo central de introducir y utilizar estratégicamente al nuevo atacante: Ron. Contexto del Nivel 5: Tipo de mecánica: Nivel de defensa clásico con recolección de economía. Cuadrícula: 5 líneas completas. Enemigos: 'Alumno Slytherin' (básico) y 'Draco' (blindado). Habrá una mayor frecuencia de aparición de Dracos que en el Nivel 4. Arsenal disponible: Harry (100), Caja de Snitch (50), Recordadora (150), Protego (50) y Accio (Remoción). Nueva carta desbloqueada: Ron (Costo: 125 snitches)..."

## Clarifications

### Session 2026-10-06

- Q: ¿Cuál es el multiplicador y valor exacto de daño por impacto de los proyectiles de Ron respecto a Harry? → A: 1.5x el daño base de Harry (30.0 puntos de daño por impacto en lugar de 40.0), requiriendo 3 impactos para derrotar a un Alumno Slytherin (70 de vida) y 5 para un Draco (140 de vida).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Desbloqueo, Plantado y Ataque de Ron (Priority: P1)

Como jugador, quiero poder seleccionar y plantar a Ron pagando 125 snitches en una celda libre para contar con un atacante de alto impacto que inflija daño elevado y ayude a derrotar a los enemigos con mucha vida (Dracos).

**Why this priority**: Es la mecánica central y el objetivo principal de la funcionalidad: introducir una nueva unidad ofensiva con balance propio (alto daño, cadencia lenta).

**Independent Test**: Iniciar una partida, acumular 125 snitches, hacer clic en la carta de Ron en el HUD, plantarlo en una celda libre y verificar que dispara proyectiles que infligen 30 de daño (1.5x el daño de Harry) cada 3 segundos cuando hay enemigos en su línea.

**Acceptance Scenarios**:

1. **Given** el HUD del Nivel 5 con la carta de Ron visible, **When** el jugador acumula al menos 125 snitches y la carta no está en recarga, **Then** la carta se muestra habilitada y permite ser seleccionada para plantar.
2. **Given** la carta de Ron seleccionada, **When** el jugador hace clic en una celda válida y desocupada de una fila activa, **Then** Ron se planta en el centro de la celda, se descuentan 125 snitches del saldo y la carta inicia su tiempo de recarga (cooldown).
3. **Given** Ron plantado en una fila, **When** al menos un enemigo vivo entra o se encuentra en esa misma fila, **Then** Ron comienza a disparar proyectiles con una cadencia de un disparo cada 3.0 segundos.
4. **Given** un proyectil disparado por Ron, **When** colisiona contra un enemigo (Alumno Slytherin o Draco), **Then** el proyectil inflige 30 puntos de daño al enemigo (1.5x superior al proyectil base de 20 puntos de Harry) y desaparece mostrando un efecto de impacto.
5. **Given** Ron plantado en una fila, **When** no hay ningún enemigo activo en esa fila, **Then** Ron permanece en guardia y no dispara proyectiles innecesariamente.
6. **Given** el saldo del jugador con menos de 125 snitches o la carta de Ron en tiempo de recarga, **When** el jugador intenta hacer clic sobre la carta de Ron, **Then** la carta no se activa ni permite iniciar el plantado.

---

### User Story 2 - Coherencia Visual y Asignación de Texturas (Priority: P2)

Como diseñador y jugador, quiero que Ron y su carta en el HUD muestren su representación visual oficial cargada desde los archivos de imagen del proyecto para garantizar coherencia estética y evitar texturas faltantes o dependencias rotas.

**Why this priority**: Asegura la fidelidad visual de la nueva unidad aliada y la consistencia en el HUD y el tablero de juego.

**Independent Test**: Cargar el Nivel 5 e inspeccionar que tanto la carta de Ron en el HUD como la unidad física plantada en el tablero utilizan la textura gráfica de Ron sin deformaciones ni errores de carga.

**Acceptance Scenarios**:

1. **Given** la escena de Ron en el tablero, **When** es instanciada, **Then** su representación visual carga su gráfico desde la carpeta de imágenes del proyecto (`res://Images/ron.png`).
2. **Given** el banco de cartas en el HUD, **When** se muestra la carta correspondiente a Ron, **Then** la carta exhibe el icono y arte identificatorio correspondiente a Ron con su costo de 125 snitches claramente visible.

---

### User Story 3 - Desafío y Progresión del Nivel 5 con Oleadas Densas (Priority: P1)

Como jugador, quiero jugar el Nivel 5 en las 5 líneas completas del tablero enfrentando oleadas densas de Alumnos Slytherin y una mayor frecuencia de Dracos, requiriendo el uso táctico de Ron para contener la oleada final y desbloquear el siguiente nivel.

**Why this priority**: Proporciona el entorno de juego y desafío equilibrado donde la nueva unidad adquiere sentido táctico frente a enemigos acorazados.

**Independent Test**: Completar una partida en el Nivel 5, comprobar que los enemigos circulan por las 5 filas, resistir la mayor frecuencia de Dracos y la oleada final múltiple, y verificar que al vencer se otorga la victoria y se desbloquea el Nivel 6 en el Mapa del Merodeador.

**Acceptance Scenarios**:

1. **Given** el Nivel 5 iniciado, **When** se inicializa el tablero, **Then** las 5 filas (Y=2..6) están activas para plantado y protegidas inicialmente por los 5 Dementores defensivos.
2. **Given** el HUD del Nivel 5, **When** el jugador revisa el arsenal disponible, **Then** tiene acceso a Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50) y la herramienta Accio.
3. **Given** la generación de enemigos durante el nivel, **When** transcurre la partida, **Then** los enemigos aparecen en las 5 filas con una proporción significativamente mayor de Dracos respecto a niveles anteriores.
4. **Given** la llegada de la oleada final, **When** se ejecuta el spawn masivo de enemigos, **Then** aparecen múltiples Dracos blindados distribuidos simultáneamente a lo largo de diferentes filas.
5. **Given** la derrota de todos los enemigos de la oleada final, **When** el tablero queda completamente despejado, **Then** se muestra el panel de victoria y se desbloquea el Nivel 6 en el progreso general del juego.

---

### Edge Cases

- **Enemigo derrotado con proyectil en vuelo**: Si un enemigo en la fila muere por otra fuente (como la explosión de una Recordadora) mientras el proyectil de Ron viaja hacia él, el proyectil debe continuar su trayectoria hasta el límite derecho de la pantalla o hasta impactar a otro enemigo que se encuentre en esa misma fila.
- **Remoción de Ron con Accio**: Si el jugador utiliza la herramienta Accio sobre un Ron plantado, Ron debe ser eliminado inmediatamente de la cuadrícula, liberando la celda sin reembolsar snitches y deteniendo cualquier temporizador de disparo en curso.
- **Múltiples enemigos en la misma fila**: Si varios enemigos avanzan por la fila de Ron, los proyectiles deben colisionar e infligir daño al primer enemigo que encuentren en su trayectoria horizontal (el más cercano a la izquierda).
- **Aparición de enemigos durante el disparo**: Si un enemigo entra en la fila justo después de que el temporizador de disparo de Ron finaliza, Ron debe detectar la presencia e iniciar el ciclo de disparo de 3 segundos sin demoras anómalas.
- **Interacción con proyectiles y pool**: Si el sistema de proyectiles utiliza un pool reutilizable, los proyectiles disparados por Ron deben devolver sus recursos al pool al impactar o salir de la pantalla, sin fugas de nodos ni interferir con los disparos de Harry.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incorporar una carta de aliado para "Ron" que muestre su coste de 125 snitches.
- **FR-002**: La carta de Ron MUST activarse únicamente cuando el saldo del jugador sea mayor o igual a 125 snitches y el tiempo de recarga esté inactivo.
- **FR-003**: Tras plantar a Ron, su carta en el HUD MUST entrar en tiempo de recarga (cooldown de 7.5 segundos) antes de permitir un nuevo plantado.
- **FR-004**: Al plantar a Ron en una celda válida de una fila activa, el sistema MUST descontar exactamente 125 snitches del saldo.
- **FR-005**: Ron MUST pertenecer a la categoría de aliados (grupo `allies`) y colocarse en el centro de la celda seleccionada.
- **FR-006**: Ron MUST detectar enemigos en su misma fila horizontal utilizando la alineación de carril.
- **FR-007**: Ron MUST disparar proyectiles a una cadencia fija de un disparo cada 3.0 segundos mientras haya al menos un enemigo en su fila.
- **FR-008**: Los proyectiles disparados por Ron MUST infligir 30 puntos de daño por impacto a los enemigos que alcancen (1.5x superior al daño base de 20 puntos de Harry).
- **FR-009**: La textura visual de Ron en el tablero MUST cargarse desde `res://Images/ron.png`.
- **FR-010**: El icono de la carta de Ron en el HUD MUST utilizar la representación gráfica de Ron desde la carpeta de imágenes del proyecto.
- **FR-011**: El Nivel 5 MUST configurar las 5 filas completas del tablero como activas (`active_rows = [2, 3, 4, 5, 6]`).
- **FR-012**: El Nivel 5 MUST incluir 5 Dementores defensivos ubicados al inicio de cada una de las 5 filas.
- **FR-013**: El arsenal disponible en el Nivel 5 MUST incluir a Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50) y el botón de remoción Accio.
- **FR-014**: La lista de enemigos del Nivel 5 MUST incluir Alumnos Slytherin y Dracos, con una presencia y frecuencia de aparición de Dracos superior a la del Nivel 4.
- **FR-015**: La oleada final del Nivel 5 MUST generar múltiples Dracos de forma simultánea repartidos en diferentes líneas.
- **FR-016**: Al completar la victoria del Nivel 5, el sistema MUST registrar el desbloqueo del Nivel 6 en el gestor de juego y en el menú del Mapa del Merodeador.
- **FR-017**: La herramienta Accio MUST poder aplicarse sobre Ron para removerlo y liberar la celda sin reembolsar snitches.

### Key Entities

- **Ron (`Ally`)**: Unidad aliada ofensiva de alto costo (125 snitches), cadencia lenta (3.0 segundos) y daño incrementado (30 puntos por impacto, 1.5x de Harry).
- **Proyectil de Ron (`Projectile`)**: Entidad de proyectil que viaja horizontalmente a lo largo del carril e inflige 30 puntos de daño al colisionar con un enemigo.
- **Nivel 5 (`Level`)**: Escenario completo de 5 líneas con arsenal de 5 cartas más Accio, oleadas mixtas de Alumnos Slytherin y Dracos con alta densidad, y desbloqueo del Nivel 6.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El plantado de Ron descuenta exactamente 125 snitches en el 100% de los intentos válidos.
- **SC-002**: El daño por proyectil de Ron es medible y exactamente igual a 30 puntos (1.5x el proyectil estándar de 20 puntos de Harry), derrotando a un Alumno Slytherin (70 de vida) en 3 disparos (en lugar de 4) y a un Draco (140 de vida) en 5 disparos (en lugar de 7).
- **SC-003**: La cadencia de disparo de Ron se mantiene constante a 3.0 segundos entre lanzamientos (con tolerancia menor a 0.05 s).
- **SC-004**: El tiempo de recarga de la carta de Ron en el HUD cumple con los 7.5 segundos requeridos antes de permitir una nueva selección.
- **SC-005**: Las 5 filas del tablero en el Nivel 5 reciben enemigos y permiten plantado sin desfasajes ni bloqueos en ninguna de sus 9 columnas.
- **SC-006**: Al superar la oleada final del Nivel 5, el Nivel 6 se habilita en el Mapa del Merodeador en el 100% de los casos.

## Assumptions

- El tiempo de recarga (cooldown) de la carta de Ron se fija en 7.5 segundos, estándar para unidades ofensivas primarias del banco de semillas.
- La velocidad de desplazamiento del proyectil de Ron se mantiene coherente con el proyectil base (400.0 píxeles por segundo).
- La salud de Ron se fija en 300 puntos, equivalente a la salud de Harry y de los aliados de soporte estándar.
- La vida de los enemigos se mantiene en 70 puntos para el Alumno Slytherin y 140 puntos para Draco.
- El Nivel 6 está contemplado en el Mapa del Merodeador (`LEVEL_COUNT = 10`), permitiendo el desbloqueo de forma secuencial.
