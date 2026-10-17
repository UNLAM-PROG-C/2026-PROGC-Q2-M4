# Feature Specification: Sistema de Oleadas Mágicas

**Feature Branch**: `006-wave-system`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Crear un sistema de oleadas para un Tower Defense mágico que utilice un hilo director para calcular la progresión, dificultad y aparición de enemigos, comunicándose de forma segura con el hilo principal, que conserva la responsabilidad de la física, las animaciones y la instanciación de nodos."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Administrar oleadas y bloqueo del tablero (Priority: P1)

Como jugador, quiero enfrentar oleadas ordenadas de enemigos para que la partida tenga una progresión clara y no aparezcan nuevos enemigos mientras todavía estoy resolviendo una oleada especial.

**Why this priority**: Define el flujo principal del nivel y garantiza que la dificultad avance de forma predecible.

**Independent Test**: Ejecutar un nivel con una cuota conocida de enemigos regulares, avanzar hasta cada umbral de eliminación y comprobar que los spawns normales se detienen, la oleada especial aparece y el siguiente estado solo comienza cuando el tablero queda despejado.

**Acceptance Scenarios**:

1. **Given** un nivel estándar con una cuota de enemigos regulares, **When** se alcanza el 50% de enemigos regulares eliminados y no quedan enemigos activos, **Then** se detiene el spawn normal y se prepara una oleada intermedia.
2. **Given** una oleada intermedia activa, **When** todos sus enemigos son derrotados, **Then** el sistema reanuda el spawn normal o prepara la oleada final según el progreso alcanzado.
3. **Given** que la cuota regular llegó al 100% y el tablero quedó vacío, **When** el sistema inicia la fase final, **Then** se genera la oleada final y el nivel solo se completa cuando sus enemigos también llegan a cero.

### User Story 2 - Ajustar la dificultad según las defensas (Priority: P2)

Como jugador, quiero que la cantidad de enemigos de una oleada especial se ajuste a la solidez de mis defensas para que el desafío sea dinámico sin salir de los límites definidos.

**Why this priority**: Evita que la oleada tenga una dificultad fija y conecta la progresión con las decisiones del jugador.

**Independent Test**: Ejecutar la misma oleada con distintos valores de defensas activas y comprobar que la cantidad calculada queda entre 10 y 20 enemigos, aumentando cuando el valor defensivo es mayor.

**Acceptance Scenarios**:

1. **Given** defensas mínimas activas, **When** se calcula la oleada intermedia, **Then** la cantidad queda en el mínimo configurado de 10 enemigos.
2. **Given** defensas sólidas activas, **When** se calcula la oleada intermedia, **Then** la cantidad puede aumentar hasta un máximo de 20 enemigos.
3. **Given** una oleada intermedia ya calculada, **When** se prepara la oleada final, **Then** la cantidad final es estrictamente mayor que la intermedia y nunca menor que 25 enemigos.

### User Story 3 - Comunicar el cálculo concurrente de forma segura (Priority: P3)

Como responsable del proyecto, quiero que el cálculo del director de oleadas se ejecute separado del hilo principal y comunique resultados de forma segura para demostrar concurrencia sin modificar nodos de Godot desde un hilo secundario.

**Why this priority**: Cumple el requisito académico de integrar procesos o hilos que se comuniquen y sincronicen, preservando la estabilidad del motor.

**Independent Test**: Ejecutar una oleada y registrar que el hilo director recibe una copia del estado, calcula una orden y la entrega al hilo principal; comprobar que la instanciación, física y animación siguen ejecutándose sin errores en el hilo principal.

**Acceptance Scenarios**:

1. **Given** un estado de nivel disponible, **When** el director necesita decidir la siguiente acción, **Then** lee una instantánea protegida y no accede directamente a nodos del Scene Tree.
2. **Given** una orden de oleada calculada, **When** el director la comunica, **Then** el hilo principal recibe datos simples y realiza la instanciación de los enemigos.
3. **Given** que el hilo principal está procesando física o una señal de colisión, **When** llega una orden del director, **Then** la orden se procesa de forma diferida y no modifica nodos durante una señal física bloqueada.

### Edge Cases

- Si el tablero no queda vacío al alcanzar un umbral, el spawn normal debe permanecer bloqueado y no debe duplicarse la oleada.
- Si una tarea concurrente se cancela al cambiar de nivel, no debe emitir órdenes sobre nodos del nivel anterior.
- Si el resultado del director llega después de que el nivel terminó, debe descartarse.
- Si no existen defensas activas, la dificultad debe usar el mínimo configurado.
- Si se solicita una cantidad fuera de los límites, debe ajustarse al rango válido antes de instanciar enemigos.
- Si varias señales de derrota de enemigos llegan en el mismo cuadro, el contador debe actualizarse una sola vez por enemigo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE administrar una máquina de estados de oleadas con al menos `SPAWNING_NORMAL`, `WAVE_PREPARATION`, `WAVE_ACTIVE`, `WAITING_FOR_CLEAR`, `FINAL_WAVE_PREPARATION` y `LEVEL_COMPLETE`.
- **FR-002**: En niveles estándar, el sistema DEBE dividir la progresión en una oleada intermedia al 50% de enemigos regulares eliminados y una oleada final al 100%.
- **FR-003**: En niveles especiales, el sistema DEBE permitir tres oleadas con umbrales intermedios al 33% y 66%, y una oleada final al 100%.
- **FR-004**: Al alcanzarse un umbral, el sistema DEBE detener el spawn regular hasta que la oleada correspondiente termine y el tablero quede vacío.
- **FR-005**: El sistema DEBE instanciar la oleada final solo después de agotar la cuota regular y confirmar que no quedan enemigos activos.
- **FR-006**: El sistema DEBE calcular la oleada intermedia dentro del rango de 10 a 20 enemigos.
- **FR-007**: El sistema DEBE calcular la oleada final con una cantidad estrictamente mayor que la oleada intermedia y un mínimo de 25 enemigos.
- **FR-008**: El sistema DEBE calcular el valor de las defensas a partir de los aliados o hechizos activos considerados por el balance del nivel.
- **FR-009**: El hilo director DEBE trabajar con una instantánea de datos simples y no modificar directamente nodos, escenas, áreas, sprites, timers ni el Scene Tree.
- **FR-010**: El hilo principal DEBE ser el único responsable de instanciar enemigos, agregarlos al nivel, configurar posiciones, procesar física y actualizar animaciones.
- **FR-011**: El sistema DEBE proteger el estado compartido entre el hilo director y el hilo principal mediante un mecanismo de exclusión mutua.
- **FR-012**: Las órdenes del director DEBEN comunicarse al hilo principal mediante una entrega segura y diferida.
- **FR-013**: El sistema DEBE descartar resultados pendientes cuando el nivel cambie o finalice.
- **FR-014**: El sistema DEBE impedir que una misma oleada sea instanciada dos veces por señales o resultados concurrentes duplicados.
- **FR-015**: El nivel DEBE declarar el resultado como completado cuando todos los enemigos de la oleada final hayan sido derrotados.

### Key Entities

- **Wave Director**: Componente que calcula la progresión, los umbrales y la próxima orden de oleada a partir de una instantánea del estado del nivel.
- **Wave State**: Estado actual de la máquina de oleadas y sus transiciones válidas.
- **Wave Plan**: Orden de datos simples que indica tipo de oleada, cantidad de enemigos y momento de activación.
- **Board Snapshot**: Copia consistente de enemigos activos, enemigos regulares derrotados, cuota restante y valor de defensas.
- **Enemy Budget**: Cuota total de enemigos regulares que debe agotarse antes de la oleada final.
- **Wave Result**: Resultado entregado al hilo principal para instanciar una oleada o completar el nivel.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En 10 ejecuciones de un nivel estándar, las oleadas intermedia y final se activan exactamente una vez en sus umbrales correspondientes.
- **SC-002**: En 10 ejecuciones de un nivel especial, los umbrales del 33%, 66% y 100% se respetan sin generar oleadas duplicadas.
- **SC-003**: El 100% de las oleadas especiales verificadas quedan dentro del rango de 10 a 20 enemigos y el 100% de las oleadas finales supera a la intermedia y alcanza al menos 25 enemigos.
- **SC-004**: En una prueba de 20 órdenes del director, todas se entregan al hilo principal sin modificar nodos desde el cálculo concurrente.
- **SC-005**: En 10 cambios o reinicios de nivel durante una tarea de cálculo, ninguna orden pendiente produce enemigos en la escena anterior.
- **SC-006**: El jugador puede completar una partida sin spawns regulares durante una espera de limpieza y sin bloqueos o errores visibles del juego.

## Assumptions

- Los niveles 1 a 3 actuales se utilizarán como primera superficie de integración; la configuración de niveles 4 a 10 se incorporará cuando sus escenas existan.
- “Enemigos regulares” excluye Dementores y otros eventos especiales que no formen parte de la cuota principal.
- El valor de cada aliado o hechizo será definido por el balance existente y podrá configurarse sin modificar la fórmula general.
- La comunicación entre hilos se limita a datos simples; el hilo secundario no ejecuta operaciones del Scene Tree.
- El director se cancela y reinicia junto con cada nivel, sin persistir entre escenas.
- La oleada final mantiene un mínimo de 25 enemigos y agrega una variación controlada de 5 a 10 sobre la oleada intermedia.
