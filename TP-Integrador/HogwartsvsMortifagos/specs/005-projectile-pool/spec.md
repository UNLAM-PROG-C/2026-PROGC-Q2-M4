# Feature Specification: Projectile Object Pool

**Feature Branch**: `005-projectile-pool`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Quiero crear un nuevo plan para crear un ThreadPool de proyectiles, para que la creacion y eliminacion de proyectiles sea mas Eficiente. Para los proyectiles se propone un pool de objetos reutilizables en el hilo principal. La idea es crear una cantidad controlada de proyectiles(50 en un inicio y en el caso de necesitar mas sumar de a 10 proyectiles en la pool), ocultarlos o desactivarlos cuando no están en uso y reutilizarlos al disparar. Al impactar o salir de pantalla, el proyectil vuelve al pool en lugar de destruirse con queue_free() para ser creado nuevamente."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reutilizar proyectiles durante una oleada (Priority: P1)

Como jugador, quiero que los disparos de Harry se reutilicen cuando impactan o salen de pantalla para que las oleadas con muchos enemigos mantengan un comportamiento fluido y consistente.

**Why this priority**: Es el objetivo principal de la funcionalidad y reduce el trabajo repetido de crear y destruir nodos durante el combate.

**Independent Test**: Ejecutar una escena jugable, generar una oleada con disparos, observar que los proyectiles disponibles vuelven a utilizarse después de impactar o salir de pantalla y comprobar que el disparo continúa funcionando.

**Acceptance Scenarios**:

1. **Given** un proyectil disponible, **When** Harry dispara, **Then** el proyectil se activa, aparece en el punto de disparo y avanza como en el comportamiento actual.
2. **Given** un proyectil activo que impacta contra un enemigo, **When** se procesa el impacto, **Then** el proyectil aplica su daño una sola vez y vuelve a estar disponible sin crear una nueva instancia para el siguiente disparo.
3. **Given** un proyectil activo que sale de la pantalla, **When** se detecta su salida, **Then** el proyectil se desactiva, deja de colisionar y vuelve a estar disponible.

### User Story 2 - Administrar el crecimiento controlado del pool (Priority: P2)

Como responsable del balance del juego, quiero que el sistema comience con 50 proyectiles y aumente su capacidad en grupos de 10 solo cuando sea necesario, para evitar una reserva ilimitada de recursos.

**Why this priority**: Permite absorber picos de disparos sin reservar memoria de forma indiscriminada y mantiene predecible el consumo del juego.

**Independent Test**: Configurar una situación en la que se soliciten más proyectiles que la capacidad actual, comprobar que la capacidad aumenta exactamente en grupos de 10 y repetir la prueba verificando que no se crean unidades adicionales mientras haya proyectiles libres.

**Acceptance Scenarios**:

1. **Given** un pool inicial de 50 proyectiles, **When** se solicitan hasta 50 proyectiles simultáneos, **Then** no se amplía la capacidad.
2. **Given** que no hay proyectiles libres, **When** se solicita otro proyectil, **Then** la capacidad aumenta en 10 y la solicitud devuelve un proyectil utilizable.
3. **Given** que vuelve a haber proyectiles libres, **When** se solicita otro disparo, **Then** se reutiliza uno disponible y no se amplía el pool.

### User Story 3 - Mantener seguridad y comportamiento existente (Priority: P3)

Como jugador, quiero que el cambio de administración interna no altere el daño, la animación, las colisiones ni la liberación visual de los disparos.

**Why this priority**: La optimización solo es válida si conserva las reglas jugables que ya funcionan.

**Independent Test**: Comparar una secuencia de disparos antes y después de activar el pool, verificando daño, animación, colisión, salida de pantalla y ausencia de proyectiles duplicados o persistentes.

**Acceptance Scenarios**:

1. **Given** un proyectil reutilizado, **When** se vuelve a activar, **Then** reinicia posición, frame de animación, estado de impacto y movimiento sin conservar datos de su uso anterior.
2. **Given** una tarea de cálculo concurrente relacionada con la gestión de disparos, **When** produce un resultado, **Then** los cambios sobre nodos y escenas se aplican de forma segura en el hilo principal.
3. **Given** que el pool alcanza su capacidad actual y no puede ampliar temporalmente, **When** se solicita un disparo, **Then** la solicitud se rechaza de forma controlada sin bloquear el juego ni producir un proyectil inválido.

### Edge Cases

- Cuando varios proyectiles impactan en el mismo cuadro, cada uno debe procesar como máximo un impacto y volver al pool una sola vez.
- Cuando un proyectil impacta y también recibe la señal de salida de pantalla en el mismo cuadro, solo debe ejecutarse una devolución al pool.
- Cuando se reinicia un nivel, no deben quedar proyectiles activos ni referencias a proyectiles del nivel anterior.
- Cuando el pool crece varias veces, su capacidad debe permanecer en múltiplos de 10 después de la capacidad inicial.
- Las tareas concurrentes no deben modificar directamente nodos, áreas de colisión, sprites ni el árbol de escenas.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE mantener un conjunto reutilizable de proyectiles inactivos y activos.
- **FR-002**: El sistema DEBE iniciar con una capacidad de 50 proyectiles.
- **FR-003**: El sistema DEBE ampliar la capacidad en grupos exactos de 10 cuando no exista ningún proyectil disponible para una solicitud.
- **FR-004**: El sistema DEBE reutilizar un proyectil inactivo antes de ampliar la capacidad.
- **FR-005**: Al activarse, un proyectil DEBE restablecer su posición, visibilidad, movimiento, frame de animación, estado de impacto y detección de colisiones.
- **FR-006**: Al impactar contra un enemigo, el proyectil DEBE aplicar el daño una sola vez y regresar al conjunto de proyectiles inactivos.
- **FR-007**: Al salir de la pantalla, el proyectil DEBE desactivarse y regresar al conjunto de proyectiles inactivos.
- **FR-008**: Un proyectil inactivo NO DEBE ser visible, moverse, detectar colisiones ni aplicar daño.
- **FR-009**: El sistema DEBE evitar que un mismo proyectil sea devuelto al pool más de una vez por ciclo de activación.
- **FR-010**: El sistema DEBE conservar la animación visual actual del proyectil al activarlo y durante su desplazamiento.
- **FR-011**: El sistema DEBE conservar las capas, máscaras y grupos necesarios para que los proyectiles interactúen únicamente con enemigos.
- **FR-012**: Si se utiliza procesamiento concurrente para cálculos auxiliares, sus tareas DEBEN comunicar resultados al hilo principal y NO DEBEN modificar directamente el árbol de escenas ni sus nodos.
- **FR-013**: Si no puede obtenerse un proyectil válido, el sistema DEBE rechazar el disparo de forma controlada y mantener el estado del nivel consistente.
- **FR-014**: Al cambiar de nivel o reiniciar una partida, el sistema DEBE desactivar todos los proyectiles activos y dejar el pool listo para reutilización.

### Key Entities

- **Projectile Pool**: Conjunto de proyectiles disponibles y activos, con una capacidad inicial y un crecimiento controlado.
- **Reusable Projectile**: Disparo que puede alternar entre estado inactivo y activo, conservando su apariencia y reglas de colisión al reutilizarse.
- **Pool Request**: Solicitud de activación de un proyectil para un disparo, con la información necesaria para ubicarlo y reiniciar su estado.
- **Pool Return**: Evento que devuelve un proyectil al conjunto inactivo después de un impacto, salida de pantalla o reinicio.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En una prueba con al menos 100 disparos consecutivos, el sistema reutiliza proyectiles liberados y no crea una instancia nueva por cada impacto o salida de pantalla.
- **SC-002**: La capacidad inicial observada es de 50 proyectiles y cada ampliación incrementa la capacidad exactamente en 10.
- **SC-003**: En una prueba con 50 proyectiles simultáneos, la jugabilidad mantiene el mismo comportamiento de daño, colisión y animación que antes del cambio.
- **SC-004**: El 100% de los proyectiles que impactan o salen de pantalla quedan inactivos y disponibles para una activación posterior, sin proyectiles invisibles que continúen dañando o colisionando.
- **SC-005**: Durante una prueba de reinicio o cambio de nivel, no queda ningún proyectil activo del estado anterior.
- **SC-006**: En las pruebas de concurrencia, ninguna tarea secundaria produce modificaciones directas sobre nodos o el árbol de escenas.

## Assumptions

- El pool administra proyectiles en el hilo principal; cualquier procesamiento concurrente se limita a cálculos auxiliares y entrega resultados simples al hilo principal.
- La escena y el script actuales del proyectil continúan siendo la base visual y de colisión.
- La capacidad puede crecer sin un límite fijo en la primera versión, siempre que cada ampliación sea de 10 y solo ocurra cuando no haya proyectiles disponibles.
- El rechazo controlado de un disparo es preferible a crear un proyectil fuera del pool o bloquear el hilo principal.
- El alcance inicial incluye los niveles jugables existentes y no modifica el comportamiento de enemigos, aliados ni la economía de Snitches.
