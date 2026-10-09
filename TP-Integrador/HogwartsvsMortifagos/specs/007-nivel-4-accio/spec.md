# Feature Specification: Nivel 4 - Remoción con Hechizo Accio

**Feature Branch**: `[007-nivel-4-accio]`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "/speckit-specify Vamos a desarrollar el Nivel 4 del juego. El objetivo principal es otorgarle al jugador la capacidad de gestionar la cuadrícula mediante la remoción de aliados, introduciendo la mecánica de la Pala (que en nuestra temática será el hechizo 'Accio')..."

## Clarifications

### Session 2026-10-06

- Q: ¿Cómo debe interactuar el modo de remoción Accio con la selección activa de cartas de plantado en el HUD? → A: Exclusión mutua automática: activar Accio deselecciona cualquier carta de aliado, y seleccionar una carta desactiva Accio inmediatamente.
- Q: ¿Puede utilizarse el hechizo Accio para remover Dementores (las defensas fijas al inicio de cada carril)? → A: Restringido estrictamente a aliados: los Dementores son defensas fijas de último recurso y no pueden ser removidos con Accio.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Selección y Manejo de la Herramienta Accio (Priority: P1)

Como jugador, quiero hacer clic en el botón de "Accio" en la interfaz para activar el modo de remoción y ver que mi cursor cambia, indicando que estoy listo para quitar un aliado, o cancelarlo si cambio de opinión.

**Why this priority**: Es la base de interacción para activar y desactivar la herramienta de remoción en el HUD de manera controlada y predecible.

**Independent Test**: Hacer clic en el botón de Accio en el HUD, comprobar que el botón pasa a estado activo/toggled y el cursor cambia; luego hacer clic derecho o presionar ESC para verificar que el estado se cancela, el botón se desmarca y el cursor del sistema vuelve a la normalidad.

**Acceptance Scenarios**:

1. **Given** la partida en curso en el Nivel 4, **When** el jugador hace clic izquierdo en el botón persistente de "Accio", **Then** el juego entra en estado de remoción (`ESTADO_REMOVIENDO`), el botón se visualiza presionado (toggled), el cursor del sistema se oculta y es reemplazado por un indicador visual (sprite/icono placeholder).
2. **Given** el juego en estado de remoción (`ESTADO_REMOVIENDO`), **When** el jugador hace clic derecho en cualquier parte de la pantalla o presiona la tecla `ESC`, **Then** el estado de remoción se cancela, el botón de Accio se desmarca y el cursor normal se restablece.
3. **Given** el botón de Accio en el HUD, **When** el jugador lo consulta o utiliza, **Then** el botón está siempre disponible: no consume snitches, no tiene tiempo de recarga (cooldown) y tiene usos infinitos.
4. **Given** una carta de aliado seleccionada en el HUD, **When** el jugador hace clic en el botón de Accio, **Then** la carta seleccionada se deselecciona automáticamente y el juego entra en modo remoción.
5. **Given** el juego en `ESTADO_REMOVIENDO`, **When** el jugador hace clic en una carta de aliado del HUD, **Then** `ESTADO_REMOVIENDO` se cancela de inmediato y el jugador pasa a tener la carta seleccionada para plantar.

---

### User Story 2 - Lógica de Remoción en la Cuadrícula y Feedback (Priority: P1)

Como jugador, quiero apuntar con la herramienta "Accio" a un aliado existente en el tablero y hacer clic para removerlo, liberando el espacio instantáneamente para reubicar defensas sin recibir snitches a cambio.

**Why this priority**: Constituye la mecánica central de gestión de la cuadrícula (equivalente a la Pala), permitiendo rectificar o adaptar la estrategia defensiva.

**Independent Test**: Plantar un aliado en una celda, activar Accio, colocar el cursor sobre el aliado para comprobar el feedback visual (modulate), hacer clic izquierdo y verificar que el aliado desaparece del tablero, la celda queda disponible de inmediato para plantar otro aliado, el contador de snitches no cambia y el cursor vuelve automáticamente al estado normal.

**Acceptance Scenarios**:

1. **Given** el juego en estado de remoción (`ESTADO_REMOVIENDO`), **When** el cursor pasa por encima de una celda ocupada por un aliado (grupo `allies`), **Then** el aliado muestra feedback visual inmediato (tono semitransparente o rojizo mediante modulación).
2. **Given** el cursor resaltando un aliado con feedback visual, **When** el cursor sale de la celda sin haber hecho clic, **Then** el aliado recupera su modulación visual normal.
3. **Given** el juego en estado de remoción y el cursor sobre un aliado, **When** el jugador hace clic izquierdo sobre el aliado, **Then** el aliado es eliminado inmediatamente del escenario y la celda queda marcada como vacía.
4. **Given** una celda recién liberada mediante Accio, **When** el jugador selecciona una carta de aliado y hace clic en esa misma celda, **Then** el nuevo aliado se planta con normalidad sin colisiones ni impedimentos.
5. **Given** la remoción exitosa de un aliado, **When** se procesa la acción, **Then** el saldo de snitches del jugador permanece intacto (costo 0, reembolso 0) y el juego vuelve automáticamente al estado normal con cursor estándar.
6. **Given** el juego en estado de remoción, **When** el jugador hace clic izquierdo sobre una celda vacía o sobre un enemigo (Mortífago), **Then** no se produce ninguna acción, el aliado no se altera y el estado de remoción se mantiene activo hasta su cancelación o remoción válida.
7. **Given** el juego en estado de remoción, **When** el jugador apunta o hace clic sobre un Dementor en el inicio del carril, **Then** el Dementor no sufre ninguna alteración y el modo de remoción permanece activo sin removerlo.

---

### User Story 3 - Integración del Escenario y Desafío del Nivel 4 (Priority: P2)

Como jugador, quiero experimentar el Nivel 4 completo con las 5 líneas de ataque activas, enfrentando a Alumnos Slytherin y Dracos con mi arsenal completo y la herramienta Accio integrada en la interfaz.

**Why this priority**: Da contexto jugable y progresivo a la nueva herramienta dentro del balance general de niveles del juego.

**Independent Test**: Iniciar el Nivel 4, comprobar que las 5 filas están habilitadas para plantado y aparición de oleadas de Alumnos Slytherin y Dracos, y que el arsenal incluye Harry, Caja de Snitch, Recordadora, Protego y el botón de Accio.

**Acceptance Scenarios**:

1. **Given** el Nivel 4 iniciado, **When** se presentan las opciones de plantado y herramientas en el HUD, **Then** están disponibles las cartas de Harry (100), Caja de Snitch (50), Recordadora (150), Protego (50) y el botón persistente de Accio separado de las cartas.
2. **Given** el avance de la partida en el Nivel 4, **When** se generan las oleadas de enemigos, **Then** aparecen Alumnos Slytherin básicos y Dracos blindados distribuidos a lo largo de las 5 líneas del tablero.

---

### Edge Cases

- **Enemigo atacando al aliado removido**: Si un Mortífago está atacando un aliado y este es removido con Accio, el enemigo debe detectar la ausencia de la presa y reanudar su marcha hacia adelante sin quedarse congelado ni generar errores de instancia nula.
- **Cancelación con hover activo**: Si el jugador cancela el modo Accio (clic derecho o ESC) mientras el cursor está encima de un aliado, la modulación visual del aliado debe restablecerse de inmediato al valor estándar.
- **Accio durante animación o daño**: Si el aliado está recibiendo daño o ejecutando una acción (ej. Caja de Snitch produciendo o Harry disparando), Accio debe removerlo instantáneamente sin dejar proyectiles huérfanos ni estados inconsistentes.
- **Clic fuera del tablero**: Hacer clic con Accio en áreas del HUD, márgenes o zonas no pertenecientes a la cuadrícula no debe disparar remociones ni causar errores.
- **Dementores protegidos**: Los Dementores ubicados como última línea de defensa no pertenecen al grupo de remoción de celdas y no pueden ser seleccionados ni destruidos mediante Accio.
- **Concurrencia de modos**: La selección de cartas y la activación de Accio son mutuamente excluyentes; en ningún caso pueden coexistir ambos estados activos simultáneamente.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incluir un botón persistente para la herramienta "Accio", ubicado de forma claramente separada del selector de cartas de aliados.
- **FR-002**: La herramienta "Accio" MUST tener costo 0 de snitches, 0 tiempo de recarga (cooldown) y usos ilimitados durante todo el nivel.
- **FR-003**: Al hacer clic izquierdo en el botón de Accio, el sistema MUST transicionar a `ESTADO_REMOVIENDO`, marcar visualmente el botón como presionado (toggled) y reemplazar el cursor del sistema por un indicador visual (sprite o icono de cursor).
- **FR-004**: Al presionar clic derecho o la tecla `ESC` durante `ESTADO_REMOVIENDO`, el sistema MUST cancelar dicho estado, desmarcar el botón y restaurar el cursor habitual.
- **FR-005**: Mientras esté activo `ESTADO_REMOVIENDO`, al situar el cursor sobre una celda que contenga un aliado perteneciente al grupo `allies`, el sistema MUST aplicar feedback visual sobre dicho aliado (modulación translúcida o tinte rojizo).
- **FR-006**: Al retirar el cursor de la celda de un aliado sin confirmar la acción, el sistema MUST devolver al aliado su aspecto visual original.
- **FR-007**: Al hacer clic izquierdo sobre un aliado en `ESTADO_REMOVIENDO`, el sistema MUST destruir/remover inmediatamente a la entidad aliada del escenario de juego.
- **FR-008**: La remoción de un aliado MUST desocupar la celda correspondiente en el registro interno de celdas de la cuadrícula, permitiendo plantar otro aliado en esa celda de forma inmediata.
- **FR-009**: La acción de remover un aliado NO MUST otorgar ni devolver snitches al jugador.
- **FR-010**: Al completar con éxito la remoción de un aliado, el sistema MUST transicionar automáticamente de regreso al estado normal, desmarcando el botón y restaurando el cursor estándar.
- **FR-011**: Hacer clic izquierdo en `ESTADO_REMOVIENDO` sobre celdas vacías o enemigos NO MUST alterar el escenario ni cancelar el modo de remoción.
- **FR-012**: El Nivel 4 MUST habilitar las 5 líneas completas del mapa para el plantado y la circulación de entidades.
- **FR-013**: El Nivel 4 MUST configurar oleadas compuestas por Alumnos Slytherin (básicos) y Dracos (blindados).
- **FR-014**: El mazo de plantado del Nivel 4 MUST ofrecer a Harry (100), Caja de Snitch (50), Recordadora (150) y Protego (50).
- **FR-015**: Activar Accio MUST deseleccionar automáticamente cualquier carta de aliado activa; recíprocamente, seleccionar una carta de aliado en el HUD MUST cancelar inmediatamente `ESTADO_REMOVIENDO` y restaurar el cursor habitual.
- **FR-016**: La herramienta Accio MUST operar exclusivamente sobre aliados plantados en la cuadrícula (`allies`); los Dementores y otras defensas del escenario NO MUST poder ser removidos por Accio.

### Key Entities

- **Herramienta Accio (Pala)**: Elemento de control en el HUD que activa y gestiona el estado de remoción en el tablero sin costo ni recarga.
- **Cuadrícula y Celdas de Tablero**: Matriz de posiciones en el nivel que mapea cada celda coordinada con el estado de ocupación y la referencia al aliado presente.
- **Aliados (`allies`)**: Entidades mágicas ubicadas en las celdas (Harry, SnitchBox, Remembrall, Protego) pasibles de ser removidas por Accio.
- **Nivel 4**: Escenario de 5 carriles que integra la totalidad del arsenal de cartas actual, los dos tipos de enemigos y el botón de remoción Accio.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El jugador puede activar la herramienta Accio y cancelar la operación en menos de 1 segundo mediante clic derecho o tecla ESC sin efectos residuales.
- **SC-002**: El 100% de las remociones de aliados liberan la celda de inmediato, permitiendo plantar exitosamente un nuevo aliado en el siguiente turno de interacción.
- **SC-003**: 0 snitches de reembolso son otorgadas en el 100% de las operaciones de remoción realizadas con Accio.
- **SC-004**: El feedback visual de modulación sobre el aliado responde inmediatamente (latencia menor a 100 ms) al posicionar el cursor sobre su celda en modo remoción.
- **SC-005**: Al remover un aliado, el cursor y el botón retornan al estado inicial en un solo paso en el 100% de los casos exitosos.
- **SC-006**: La alternancia entre selección de cartas de aliado y herramienta Accio es 100% mutuamente excluyente y sin estados superpuestos.
- **SC-007**: El Nivel 4 permite completar una partida completa en las 5 líneas con ambas clases de enemigos y el arsenal de 4 aliados junto con Accio.

## Assumptions

- Se utiliza el grupo reservado `allies` de acuerdo al Principio IV de la Constitución del Proyecto para identificar a cualquier mago o defensa susceptible de remoción.
- El cursor personalizado y el botón de Accio pueden emplear recursos visuales temporales o placeholders claramente identificables si los assets finales aún no están provistos.
- Los enemigos que estén en proceso de atacar al aliado al momento de su remoción detectarán la pérdida de la entidad y continuarán su marcha automáticamente sin arrojar errores de referencia nula.
- La cuadrícula del Nivel 4 mantiene las dimensiones estándar de 5 filas y las columnas correspondientes a los niveles previos del proyecto.
