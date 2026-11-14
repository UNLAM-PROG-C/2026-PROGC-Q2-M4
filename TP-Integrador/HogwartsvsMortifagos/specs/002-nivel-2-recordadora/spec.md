# Especificación: Nivel 2 — Expansión a 3 Líneas y la Recordadora

**Feature Branch**: `002-nivel-2-recordadora`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "Desarrollar el Nivel 2 del juego. Expandir tablero a 3 líneas jugables, introducir la Recordadora como bomba de área, y adaptar el spawner de enemigos a multilínea."

## Clarifications

### Session 2026-09-29

- Q: ¿Cuáles son las 3 filas jugables habilitadas en el Nivel 2 dentro del tablero de 5 filas? → A: Las 3 filas centrales: la fila central activa del Nivel 1 (Fila 4, Y=576) y las 2 filas inmediatamente adyacentes a ella (Fila 3, Y=448 y Fila 5, Y=704), manteniendo bloqueadas visual y funcionalmente únicamente las 2 filas de los extremos (Fila 2, Y=320 y Fila 6, Y=832).
- Q: ¿Tendrá la Recordadora un tiempo de recarga (cooldown) en su carta del HUD tras ser plantada, o solo dependerá de contar con 150 Snitches? → A: Sí, la carta de la Recordadora tendrá un tiempo de recarga largo (25 segundos) tras ser plantada, durante el cual no podrá volver a seleccionarse aunque se disponga de 150 Snitches.
- Q: ¿Cuál será la cantidad total de enemigos a derrotar y el intervalo de spawn en el Nivel 2 para alcanzar la condición de victoria? → A: 20 Alumnos Slytherin en total con un intervalo de spawn de 6 segundos entre apariciones.
- Q: ¿Debe haber un Dementor defensivo (cortadora de césped) en cada fila al inicio del Nivel 2? → A: Sí, 1 Dementor en cada una de las 5 filas del tablero (X=160, Y=[320, 448, 576, 704, 832]), exactamente igual que en el Nivel 1, protegiendo tanto las filas jugables como las bloqueadas.
- Q: ¿Se debe mantener el intervalo de aparición de Snitches celestes (caídas del cielo) en 10 segundos otorgando 25 Snitches, igual que en el Nivel 1? → A: Sí, se mantiene la misma frecuencia que en el Nivel 1 (cada 10 segundos cae 1 Snitch recolectable del cielo que otorga 25 Snitches).

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Expansión del Campo de Batalla a 3 Líneas (Priority: P1)

Como jugador, quiero visualizar e interactuar con una cuadrícula de 3 líneas horizontales (las 3 centrales: Filas 3, 4 y 5) para tener mayor espacio de plantado y un desafío táctico superior.

**Why this priority**: Sin la expansión a 3 líneas, el Nivel 2 no se diferencia del Nivel 1. Es el cimiento de todas las demás mecánicas del nivel: tanto la Recordadora como el spawner multilínea dependen de que existan 3 filas activas.

**Independent Test**: Se puede verificar ejecutando el Nivel 2 y confirmando que las 3 filas centrales (Fila 3, 4 y 5; Y entre 384 y 768) aceptan plantado de aliados, mientras las filas extremas (Fila 2 y 6) permanecen bloqueadas. Los enemigos deben aparecer distribuidos en cualquiera de los 3 spawners correspondientes (Marker2D2, Marker2D3, Marker2D4).

**Acceptance Scenarios**:

1. **Given** el jugador inicia el Nivel 2, **When** observa la grilla, **Then** las 3 filas centrales (Filas 3, 4 y 5) están habilitadas para plantar aliados y las 2 filas extremas (Filas 2 y 6) muestran el bloqueo visual translúcido de `BloqueoMagico`.
2. **Given** el jugador intenta plantar un aliado en una fila bloqueada (Fila 2 o Fila 6), **When** hace clic sobre esa fila, **Then** no se planta ninguna entidad y no se descuentan Snitches.
3. **Given** el jugador planta un aliado en cualquiera de las 3 filas desbloqueadas (Filas 3, 4 o 5), **When** confirma la colocación, **Then** el aliado se instancia en la celda seleccionada y se descuentan las Snitches correspondientes.

---

### User Story 2 — Uso de la Recordadora como Bomba de Área (Priority: P1)

Como jugador, quiero usar la Recordadora pagando 150 Snitches para eliminar grupos grandes de enemigos concentrados en un área de 3×3 celdas, con un tiempo de recarga balanceado que requiera planificación táctica.

**Why this priority**: Es el aliado nuevo del nivel y la mecánica diferencial frente al Nivel 1. Sin ella, el jugador no tendría herramientas para gestionar la carga enemiga que implican 3 líneas simultáneas.

**Independent Test**: Se puede verificar plantando la Recordadora en una celda cercana a enemigos, esperando 1,5 segundos y confirmando que los enemigos dentro del radio de 3×3 celdas son eliminados instantáneamente y la Recordadora se destruye, verificando además que su carta en el HUD queda deshabilitada durante 25 segundos antes de permitir una nueva compra.

**Acceptance Scenarios**:

1. **Given** el jugador tiene 150 o más Snitches y la carta no está en recarga, **When** observa el HUD, **Then** el botón de la Recordadora está habilitado.
2. **Given** el jugador tiene menos de 150 Snitches o la carta está en periodo de recarga, **When** observa el HUD, **Then** el botón de la Recordadora está deshabilitado (grisado).
3. **Given** el jugador selecciona la Recordadora y hace clic en una celda válida, **When** la planta, **Then** se descuentan exactamente 150 Snitches, la Recordadora aparece en la celda seleccionada y su carta entra inmediatamente en recarga por 25 segundos.
4. **Given** la Recordadora acaba de ser plantada, **When** transcurre un tiempo menor a 25 segundos, **Then** la carta permanece deshabilitada aunque el saldo de Snitches vuelva a superar las 150.
5. **Given** transcurren los 25 segundos de recarga y el jugador cuenta con 150 o más Snitches, **When** finaliza el ciclo, **Then** el botón de la Recordadora vuelve a habilitarse.
6. **Given** la Recordadora está plantada en una celda, **When** transcurren 1,5 segundos, **Then** reproduce una animación visual (cambio de color y/o escala) y explota.
7. **Given** la Recordadora explota, **When** hay Alumnos Slytherin dentro del radio de 3×3 celdas adyacentes, **Then** todos esos enemigos son eliminados instantáneamente.
8. **Given** la Recordadora explota, **When** no hay enemigos en el radio, **Then** la explosión ocurre igualmente y la Recordadora se destruye sin causar daño.
9. **Given** la Recordadora explota, **When** hay aliados propios dentro del radio de explosión, **Then** los aliados propios no reciben daño.

---

### User Story 3 — Spawner de Enemigos Multilínea (Priority: P2)

Como diseñador de niveles, quiero un gestor de oleadas que genere 20 Alumnos Slytherin cada 6 segundos repartidos aleatoriamente entre las 3 líneas jugables para mantener la tensión y exigir decisiones tácticas al jugador.

**Why this priority**: Complementa la expansión de las 3 líneas pero puede probarse con la lógica de spawn existente adaptada. No introduce una mecánica nueva de interacción para el jugador, sino un ajuste de diseño de nivel.

**Independent Test**: Se puede verificar observando que se generan 20 enemigos a razón de 1 cada 6 segundos distribuidos entre las 3 filas, y que al derrotar a los 20 enemigos se produce la victoria.

**Acceptance Scenarios**:

1. **Given** el Nivel 2 está en curso, **When** el timer de spawn genera un nuevo Alumno Slytherin, **Then** se selecciona al azar uno de los 3 puntos de spawn de las filas activas (`Marker2D2`, `Marker2D3`, `Marker2D4`).
2. **Given** el Nivel 2 está en curso, **When** opera el temporizador de generación, **Then** genera un nuevo Alumno Slytherin cada 6 segundos hasta completar una cuota total de 20 enemigos.
3. **Given** el jugador juega una partida completa del Nivel 2, **When** se observa el patrón de aparición de enemigos, **Then** las 3 líneas reciben enemigos a lo largo de la partida (no se concentran todos en una sola fila).
4. **Given** se han generado los 20 Alumnos Slytherin del nivel, **When** el jugador derrota al último enemigo y no quedan enemigos en pantalla, **Then** se activa la victoria del nivel y se despliega el menú interactivo de fin de nivel.

---

### Edge Cases

- ¿Qué ocurre si el jugador planta la Recordadora en una celda ocupada? La celda rechaza la plantación (misma regla que con otros aliados: máximo un aliado por celda).
- ¿Qué ocurre si la Recordadora explota pero el Alumno Slytherin está parcialmente fuera del radio? Solo se afectan los enemigos cuya área de colisión se superponga con el radio de explosión de la Recordadora.
- ¿Qué ocurre si el jugador planta la Recordadora y es destruida por un enemigo antes de los 1,5 segundos? La Recordadora no explota; simplemente se destruye sin causar daño.
- ¿Qué ocurre si todos los enemigos son eliminados pero el timer de spawn aún tiene oleadas pendientes? La partida continúa hasta que todas las oleadas hayan sido generadas y eliminadas.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE presentar una grilla de 3 líneas horizontales jugables correspondientes a las filas centrales (Filas 3, 4 y 5; Y entre 384 y 768) al iniciar el Nivel 2.
- **FR-002**: El sistema DEBE bloquear visualmente y funcionalmente únicamente las 2 filas de los extremos (Fila 2 y Fila 6) en el Nivel 2 mediante la capa `BloqueoMagico`.
- **FR-003**: El sistema DEBE permitir plantar aliados (Harry, Caja de Snitch y Recordadora) únicamente en celdas de las 3 filas desbloqueadas (Filas 3, 4 y 5).
- **FR-004**: El sistema DEBE mostrar la carta de la Recordadora en el HUD con un coste de 150 Snitches.
- **FR-005**: El sistema DEBE habilitar la carta de la Recordadora únicamente cuando el jugador cuente con 150 o más Snitches Y la carta haya completado su ciclo de recarga (cooldown) de 25 segundos tras el último plantado.
- **FR-006**: La Recordadora DEBE reproducir una animación visual (cambio de color y/o escala) tras ser plantada, durante 1,5 segundos.
- **FR-007**: La Recordadora DEBE explotar tras 1,5 segundos, eliminando instantáneamente a cualquier Alumno Slytherin en un radio de 3×3 celdas adyacentes.
- **FR-008**: La explosión de la Recordadora NO DEBE causar daño a aliados propios.
- **FR-009**: La Recordadora DEBE destruirse (desaparecer) después de la explosión.
- **FR-010**: La Recordadora NO DEBE disparar proyectiles en ningún momento.
- **FR-011**: El spawner de enemigos DEBE seleccionar al azar entre los 3 puntos de spawn de las filas activas (`Marker2D2` Y=448, `Marker2D3` Y=576, `Marker2D4` Y=704) antes de instanciar cada Alumno Slytherin.
- **FR-012**: El spawner de enemigos DEBE generar un total de 20 Alumnos Slytherin con un intervalo regular de 6 segundos entre apariciones.
- **FR-013**: El Nivel 2 DEBE utilizar únicamente Alumnos Slytherin como tipo de enemigo.
- **FR-014**: El Nivel 2 DEBE iniciar con el mismo saldo de Snitches que el Nivel 1 (150 Snitches).
- **FR-015**: Las capas de colisión DEBEN seguir la misma estructura del Nivel 1 (Capa 1: Aliados, Capa 2: Enemigos, Capa 3: Hechizos, Capa 4: Snitches).
- **FR-016**: La victoria del Nivel 2 DEBE desbloquear el Nivel 3 en el Mapa del Merodeador.
- **FR-017**: Al finalizar el Nivel 2 (victoria o derrota), DEBE presentarse el menú interactivo con las mismas opciones que el Nivel 1 (Siguiente Nivel / Reintentar / Volver al Mapa).
- **FR-018**: El sistema DEBE instanciar un Dementor protector al inicio del nivel en la posición X=160 para cada una de las 5 filas del tablero (Y=[320, 448, 576, 704, 832]), activándose para eliminar a todos los enemigos de la fila al ser tocado y prevenir la derrota directa.
- **FR-019**: El temporizador de Snitches celestes (`SpawnerDeSnitches`) DEBE generar una Snitch recolectable cada 10 segundos otorgando 25 Snitches al ser recogida, manteniendo la economía base del Nivel 1.

### Key Entities

- **Recordadora**: Aliado de tipo bomba de área. Coste: 150 Snitches. Tiempo de recarga en carta: 25 segundos. No dispara proyectiles. Explota tras 1,5 segundos de ser plantada, eliminando enemigos en un radio de 3×3 celdas. Se destruye después de la explosión.
- **Alumno Slytherin**: Enemigo básico heredado del Nivel 1. 200 puntos de vida. Velocidad de 32 px/s. Único tipo de enemigo en el Nivel 2.
- **Dementor**: Entidad defensiva de última línea (equivalente a cortadora de césped). Ubicado en el extremo izquierdo (X=160) de cada una de las 5 filas. Se activa al contacto con un enemigo, eliminando a todos los atacantes a su paso en esa fila y descartándose tras su uso.
- **Cuadrícula Nivel 2**: Grilla de 5 filas totales donde las 3 filas centrales (Filas 3, 4 y 5) son jugables, y las 2 filas de los extremos (Filas 2 y 6) permanecen bloqueadas visual y funcionalmente mediante `BloqueoMagico`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El jugador puede plantar aliados en cualquiera de las 3 filas habilitadas y no puede plantarlos en las filas bloqueadas.
- **SC-002**: La Recordadora elimina a todos los Alumnos Slytherin dentro de su radio de 3×3 celdas al explotar, en el 100% de las activaciones exitosas.
- **SC-003**: La carta de la Recordadora se habilita únicamente cuando el jugador cuenta con al menos 150 Snitches y el temporizador de recarga de 25 segundos ha concluido tras su uso previo.
- **SC-004**: Los enemigos aparecen distribuidos entre las 3 filas disponibles a lo largo de cada partida.
- **SC-005**: El jugador puede completar el Nivel 2 en una sesión de juego continua y al ganar se desbloquea el Nivel 3 en el Mapa del Merodeador.
- **SC-006**: El spawner genera una cuota exacta de 20 Alumnos Slytherin con un intervalo de 6 segundos, y la condición de victoria se activa al derrotar a la totalidad de los 20 enemigos generados.

## Assumptions

- El Nivel 2 hereda la mecánica base del Nivel 1 (saldo inicial de 150 Snitches, Harry a 100 Snitches, Caja de Snitch a 50 Snitches, proyectiles y Alumno Slytherin).
- La economía pasiva de Snitches celestes mantiene un intervalo de 10 segundos y valor de 25 Snitches cada una, estimulando el plantado de Cajas de Snitch para complementar ingresos.
- La Recordadora se implementará como una entidad independiente con su propia escena y script (conforme a la constitución del proyecto).
- La grilla visual (TileMapLayer) y los spawners (Marker2D) existentes se ajustarán para soportar 3 líneas, no se crean sistemas nuevos.
- El bloqueo visual de las filas no activas utiliza el mismo mecanismo de placeholder translúcido del Nivel 1.
- La Recordadora no tiene interacción con otros aliados (no los daña ni los beneficia).
- La Recordadora puede ser destruida por un enemigo antes de explotar si un Alumno Slytherin la alcanza y la ataca.
- El tipo de enemigo del Nivel 2 es exclusivamente el Alumno Slytherin (sin variantes ni jefes).
