# Feature Specification: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Feature Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]`

**Created**: 2026-10-07

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 8 del juego. El objetivo de este nivel es aumentar significativamente el desafío extendiendo el combate a 3 oleadas principales (en lugar de 2) y otorgando al jugador el DPS (daño por segundo) definitivo: McGonagall, basada en la Gatling Pea (Ametralladora) del juego original. Contexto del Nivel 8: Cuadrícula: 5 líneas completas. Enemigos: 'Alumno Slytherin' (básico), 'Draco' (cono), 'Alumno con Protego' (cubo/puerta) y 'Prefecto Slytherin' (rango). Arsenal disponible: Harry (100), Caja de Snitch (50), Recordadora (150), Protego (50), Accio (0), Ron (125), Escoba (125), Hermione (125) y la nueva carta: McGonagall (200 snitches). Oleadas: El nivel tendrá una estructura extendida con 3 eventos de 'Gran Oleada' (Huge Wave). HU-1: Fuego Rápido en Ráfaga (McGonagall / Ametralladora). HU-4: Extensión del Gestor de Oleadas (3 Oleadas Masivas)."

## Clarifications

### Session 2026-10-07

- Q: ¿Debe el aviso en pantalla distinguir la tercera oleada como "Oleada Final" frente a las dos primeras Grandes Oleadas? → A: Sí, diferenciar textos: `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` en las oleadas 1 y 2, y `"¡OLEADA FINAL!"` en la oleada 3.
- Q: ¿Debe McGonagall reutilizar el proyectil mágico estándar del pool común (`projectile_pool.gd`) o requiere una apariencia visual distintiva en sus hechizos? → A: Reutilizar el proyectil mágico estándar (`projectile.tscn`) sin modificaciones a través del pool común.
- Q: ¿Cuál debe ser la cantidad total de enemigos regulares (`total_enemies`) configurada en el Nivel 8 para balancear el ritmo del combate a lo largo de las 3 Grandes Oleadas? → A: 45 enemigos en total (desafío prolongado con hitos de oleada intermedia aproximadamente en las bajas 15 y 30 antes de la Oleada Final).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fuego Rápido en Ráfaga: McGonagall (Priority: P1)

Como jugador, quiero poder plantar a la profesora "McGonagall" en el jardín pagando 200 snitches para que dispare una ráfaga letal de 4 hechizos consecutivos ante la presencia de enemigos en su carril, destruyendo velozmente a los enemigos con armadura pesada o de ataque a distancia antes de que alcancen mis líneas.

**Why this priority**: Es la nueva carta aliada del Nivel 8 y la unidad de DPS definitivo del juego, introduciendo el disparo en ráfaga cuádruple y expandiendo el abanico táctico para lidiar con enemigos de alta resistencia.

**Independent Test**: Plantar a McGonagall en una fila del jardín con enemigos en avance; verificar que al detectar un enemigo dispara exactamente 4 proyectiles en rápida sucesión (intervalo de 0.15 segundos), espera su tiempo de recarga base (1.5 segundos) y vuelve a disparar otra ráfaga mientras permanezcan enemigos en su fila, infligiendo 20 de daño por cada proyectil (80 de daño total por ráfaga completa).

**Acceptance Scenarios**:

1. **Given** el HUD del Nivel 8 con un saldo de al menos 200 snitches, **When** el jugador selecciona la carta de McGonagall y hace clic en una celda libre de una fila activa, **Then** se descuentan 200 snitches, se inicia el tiempo de recarga de la carta y se instancia a McGonagall en la celda seleccionada.
2. **Given** McGonagall plantada en una fila activa, **When** no hay enemigos en su fila hacia la derecha, **Then** McGonagall se mantiene en guardia sin disparar ningún proyectil.
3. **Given** McGonagall plantada en una fila activa, **When** detecta al menos un enemigo en su carril hacia la derecha y su recarga está disponible, **Then** dispara una ráfaga secuencial de 4 proyectiles con un intervalo de aproximadamente 0.15 segundos entre cada disparo consecutivo.
4. **Given** la finalización de los 4 disparos de la ráfaga, **When** el cuarto proyectil es emitido, **Then** McGonagall entra en un período de recarga base de 1.5 segundos (idéntico al tiempo de recarga entre disparos de Harry) antes de poder iniciar una nueva ráfaga.
5. **Given** un enemigo con alta resistencia (e.g. Draco o Alumno con Protego), **When** recibe el impacto de los proyectiles de la ráfaga de McGonagall, **Then** cada proyectil aplica 20 puntos de daño individual, reduciendo 80 puntos de salud acumulada tras la ráfaga completa.
6. **Given** McGonagall recibiendo daño enemigo hasta perder toda su salud (300 HP base), **When** es derrotada mientras ejecutaba una ráfaga, **Then** la ráfaga se cancela de forma inmediata sin emitir los disparos restantes ni dejar temporizadores pendientes.

---

### User Story 2 - Extensión del Gestor de Oleadas a 3 Grandes Oleadas (Priority: P1)

Como jugador, quiero enfrentarme a un nivel extendido con 3 picos de dificultad extrema (Gran Oleada 1, Gran Oleada 2 y Oleada Final) en lugar de las 2 tradicionales, requiriendo mayor planificación económica y una defensa consolidada a lo largo de un combate prolongado.

**Why this priority**: Es la evolución estructural del sistema de oleadas para los niveles avanzados, elevando sustancialmente la exigencia y justificando la inversión en unidades de alto costo como McGonagall.

**Independent Test**: Jugar el Nivel 8 y registrar la progresión de oleadas; verificar que se activan 3 avisos de gran oleada en pantalla en los hitos correspondientes (aproximadamente al 33%, 66% y 100% de la cuota de enemigos), con despliegue masivo y simultáneo de enemigos en múltiples carriles en cada uno de los 3 eventos, culminando con la victoria únicamente tras derrotar a todos los enemigos de la tercera oleada.

**Acceptance Scenarios**:

1. **Given** la progresión del Nivel 8, **When** los enemigos derrotados alcanzan el primer tercio del presupuesto del nivel (aproximadamente 33%), **Then** se detiene el spawn regular, se despliega en pantalla la advertencia `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` y se inicia la primera Gran Oleada con un despliegue simultáneo de enemigos a través de los carriles activos.
2. **Given** la reanudación del combate tras limpiar la primera Gran Oleada, **When** los enemigos derrotados alcanzan los dos tercios del presupuesto (aproximadamente 66%), **Then** se activa la segunda advertencia de gran oleada (`"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"`) y se genera la segunda Gran Oleada masiva en pantalla.
3. **Given** el agotamiento de los enemigos regulares tras la segunda oleada, **When** el tablero queda despejado de la fase intermedia, **Then** se activa la tercera y última gran oleada con el anuncio `"¡OLEADA FINAL!"`.
4. **Given** el despliegue de la tercera oleada ("Oleada Final"), **When** aparecen los enemigos en pantalla, **Then** se concentra la mayor densidad y variedad de enemigos blindados (Draco, Alumno con Protego) y Prefectos Slytherin del nivel.
5. **Given** la batalla de la Oleada Final, **When** todos los enemigos de la tercera oleada son derrotados y no quedan atacantes activos en el jardín, **Then** el nivel concluye con la victoria del jugador.

---

### User Story 3 - Desafío y Progresión Completa del Nivel 8 (Priority: P1)

Como jugador, quiero jugar el Nivel 8 en un tablero de 5 líneas completas disponiendo de un arsenal completo de 9 cartas (incluyendo a la nueva McGonagall) para enfrentar la combinación completa de Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin, desbloqueando el Nivel 9 en el Mapa del Merodeador al ganar.

**Why this priority**: Integra todas las mecánicas construidas (economía de snitches, defensas, control por ralentización, ataques a distancia y daño concentrado) en una experiencia jugable coherente y balanceada.

**Independent Test**: Iniciar el Nivel 8 desde el selector de niveles o tras vencer el Nivel 7; verificar 5 filas activas con 5 Dementores, 9 cartas funcionales en el HUD (Harry, Snitch Box, Ron, Recordadora, Protego, Escoba, Hermione, Accio y McGonagall), oleadas compuestas por los 4 tipos de enemigos y el correcto desbloqueo del Nivel 9 tras triunfar.

**Acceptance Scenarios**:

1. **Given** el inicio del Nivel 8, **When** carga el escenario, **Then** las 5 filas (Y=2..6) están habilitadas para plantar y se posicionan 5 Dementores de respaldo en el extremo izquierdo del jardín.
2. **Given** el HUD del Nivel 8, **When** el jugador inspecciona sus cartas, **Then** tiene a su disposición las 9 opciones: Harry (100), Snitch Box (50), Ron (125), Recordadora (150), Protego (50), Escoba (125), Hermione (125), McGonagall (200) y la pala Accio (0).
3. **Given** las oleadas regulares y masivas del Nivel 8, **When** los enemigos aparecen en escena, **Then** la composición incluye Alumnos Slytherin comunes, Dracos con armadura ligera, Alumnos con Protego con escudo pesado y Prefectos Slytherin atacantes a distancia.
4. **Given** la victoria sobre la oleada final del Nivel 8, **When** el tablero queda completamente despejado, **Then** se muestra el panel de victoria y se registra el desbloqueo del Nivel 9 en el progreso global del juego.

---

### Edge Cases

- **McGonagall eliminada durante la ejecución de una ráfaga**: Si un enemigo cuerpo a cuerpo muerde a McGonagall o un proyectil enemigo impacta y reduce su salud a 0 mientras quedan disparos pendientes en su ráfaga de 4, el temporizador de ráfaga debe detenerse inmediatamente y ningún proyectil residual debe ser emitido.
- **Enemigo objetivo derrotado antes de completar los 4 disparos**: Si el primer disparo de la ráfaga elimina al único enemigo en la fila, los proyectiles restantes ya encolados de esa ráfaga se disparan en línea recta hacia adelante, pudiendo impactar a futuros enemigos que ingresen a la fila o saliendo libremente del tablero.
- **Enemigo a quemarropa**: Si un enemigo llega a la misma celda de McGonagall mientras ella dispara, los proyectiles deben instanciarse y registrar la colisión inmediatamente contra dicho enemigo sin traspasarlo ni trabar el ciclo.
- **Activación de Dementor durante una Gran Oleada**: Si la densidad de una de las 3 grandes oleadas desborda una fila y un enemigo alcanza el límite izquierdo, el Dementor de esa fila debe activarse, eliminar a todos los enemigos de la línea y contabilizarlos hacia el total de enemigos derrotados.
- **Pausa entre oleada intermedia y oleada final**: El pasaje entre oleadas debe mantener la estabilidad del estado del juego: no deben superponerse dos anuncios simultáneos de oleada ni deben generarse oleadas simultáneas en paralelo.
- **Impacto de la ráfaga contra escudos**: Los proyectiles de McGonagall deben impactar sucesivamente el escudo de un Alumno con Protego; al destruirse el escudo con los primeros impactos, los siguientes proyectiles de la misma ráfaga deben infligir daño directamente al cuerpo del alumno.
- **Interacción con ralentización de Hermione**: Un enemigo ralentizado por Hermione que entra en el rango de McGonagall recibe múltiples impactos de ráfaga acumulando daño masivo mientras su avance se encuentra disminuido al 70%.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incorporar una carta de aliado para "McGonagall" con un costo explícito de 200 snitches.
- **FR-002**: La carta de McGonagall MUST tener un tiempo de recarga de colocación en el HUD (7.5 segundos) coherente con las unidades avanzadas.
- **FR-003**: La aliada "McGonagall" MUST pertenecer al grupo `allies` y contar con 300 puntos de salud base.
- **FR-004**: McGonagall MUST detectar si existen enemigos presentes en su misma fila hacia la derecha antes de iniciar un ciclo de ataque.
- **FR-005**: Al detectar al menos un enemigo en su carril, McGonagall MUST ejecutar un ataque en ráfaga compuesto por 4 disparos consecutivos de proyectiles mágicos.
- **FR-006**: El intervalo de tiempo entre cada uno de los 4 disparos de la ráfaga de McGonagall MUST ser de aproximadamente 0.15 segundos.
- **FR-007**: Cada proyectil individual de la ráfaga de McGonagall MUST reutilizar la escena estándar de proyectil aliado con velocidad horizontal constante hacia la derecha (+400 px/s) e infligir 20 puntos de daño por impacto.
- **FR-008**: Al finalizar la emisión del cuarto proyectil de la ráfaga, McGonagall MUST entrar en un período de recarga base de 1.5 segundos antes de poder iniciar la siguiente ráfaga de disparos.
- **FR-009**: La ejecución de los disparos de la ráfaga MUST realizarse mediante un temporizador secundario independiente en la escena de McGonagall sin bloquear el bucle principal de ejecución del motor.
- **FR-010**: Si McGonagall es derrotada o eliminada del tablero, cualquier disparo pendiente en la ráfaga en curso MUST cancelarse de inmediato.
- **FR-011**: El sistema de oleadas del Nivel 8 MUST estructurarse con 3 eventos de Gran Oleada (Huge Wave): dos oleadas intermedias y una oleada final.
- **FR-012**: El Nivel 8 MUST configurar un presupuesto base de 45 enemigos regulares (`total_enemies = 45`), activando las dos oleadas intermedias de forma secuencial al alcanzar las 15 y 30 bajas regulares (~33% y ~66%), seguidas de la Oleada Final tras agotar el presupuesto y despejar la fase regular.
- **FR-013**: Cada hito de Gran Oleada (oleadas 1 y 2) MUST mostrar en pantalla la advertencia visual `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` durante un período predeterminado antes del desembarco masivo de enemigos.
- **FR-014**: La tercera oleada masiva MUST ser la "Oleada Final" y MUST mostrar en pantalla la advertencia visual `"¡OLEADA FINAL!"` anunciando el combate final.
- **FR-015**: La tercera oleada masiva MUST concentrar la mayor cantidad y densidad de enemigos con armadura (Draco, Alumno con Protego) y Prefectos Slytherin de todo el nivel.
- **FR-016**: El Nivel 8 MUST contar con 5 filas activas en el tablero (coordenadas de cuadrícula Y=2..6) protegidas por 5 Dementores defensivos.
- **FR-017**: El Nivel 8 MUST habilitar en el HUD un banco de 9 cartas: Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba, Hermione, McGonagall y la herramienta Accio.
- **FR-018**: El Nivel 8 MUST generar en sus oleadas a 4 tipos de enemigos: Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin.
- **FR-019**: La victoria en el Nivel 8 MUST ocurrir únicamente cuando todos los enemigos de la tercera oleada hayan sido eliminados y el jardín quede despejado.
- **FR-020**: Al conseguir la victoria en el Nivel 8, el juego MUST desbloquear el Nivel 9 en el Mapa del Merodeador y en el menú de selección de niveles.

---

### Key Entities

- **McGonagall (`McGonagall`)**: Entidad aliada que representa a la profesora McGonagall (rol equivalente a la Gatling Pea / Ametralladora). Costo: 200 snitches. Salud: 300 HP. Dispara ráfagas de 4 hechizos cada 1.5 segundos de recarga.
- **Carta de McGonagall (`mcgonagall_card.tres`)**: Recurso de datos de la carta aliada que define el nombre para el jugador, el costo de 200 snitches, la escena a instanciar y su tiempo de recarga en el HUD.
- **Ráfaga Cuádruple (`BurstTimer` / Temporizador de Ráfaga)**: Mecanismo de disparo secuencial que despacha 4 proyectiles a razón de 1 cada 0.15 segundos al activarse el ciclo de ataque.
- **Nivel 8 (`Level8` / Escena de Nivel 8)**: Nivel avanzado de 5 carriles configurado con combate extendido en 3 eventos de Gran Oleada, 4 tipos de enemigos y acceso a las 9 cartas del jugador.
- **Gestor de 3 Oleadas Masivas (`WaveDirector` / Configuración de Nivel Especial)**: Sistema de control de oleadas que divide el progreso en 3 hitos críticos (33%, 66% y 100%) disparando avisos en pantalla y desembarcos simultáneos multilínea.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: McGonagall dispara con éxito exactamente 4 proyectiles en una sola ráfaga cada vez que se activa su ciclo de ataque con enemigos en su carril, con una separación temporal de 0.15 segundos entre disparos consecutivos.
- **SC-002**: El intervalo de descanso entre el fin de una ráfaga de 4 disparos y el inicio de la siguiente ráfaga es exactamente de 1.5 segundos de recarga base.
- **SC-003**: Cada proyectil de McGonagall inflige 20 puntos de daño base, alcanzando un potencial ofensivo de 80 de daño concentrado por ciclo de ráfaga completa.
- **SC-004**: El Nivel 8 ejecuta de manera ordenada y sin fallas los 3 eventos de Gran Oleada (dos intermedias y una final) en los hitos correspondientes del nivel.
- **SC-005**: Durante cada una de las 3 grandes oleadas, se despliegan simultáneamente enemigos en las filas activas precedidos por la advertencia visual correspondiente en pantalla.
- **SC-006**: La derrota del último enemigo de la tercera oleada culmina en la pantalla de victoria y desbloquea el Nivel 9 en el progreso del juego en el 100% de las partidas exitosas.

---

## Assumptions

- McGonagall reutiliza el proyectil mágico estándar (`projectile.tscn`) proporcionado por el pool de proyectiles (`projectile_pool.gd`), compartiendo su velocidad de 400 px/s y daño base de 20 puntos, lo que garantiza consistencia y rendimiento óptimo de memoria.
- La salud base de McGonagall es de 300 puntos de salud, igual a la de Harry y Hermione, dependiendo de sus aliados protectores (Protego) para sobrevivir a las amenazas a distancia y cuerpo a cuerpo.
- El costo de 200 snitches y el tiempo de recarga de 7.5 segundos de la carta equilibran su elevado daño ofensivo, incentivando una sólida economía inicial de Cajas de Snitch.
- El Nivel 8 utiliza la configuración de nivel extendido con 3 oleadas (`is_special_level = true` o soporte equivalente de 3 marcas de oleada) para gestionar los hitos del 33%, 66% y la oleada final.
- El selector de niveles (`level_select_menu.gd`) soporta el desbloqueo del Nivel 9 ya que su constante de niveles máximos (`LEVEL_COUNT`) está definida para soportar hasta el Nivel 10.
- La textura gráfica de McGonagall se incorpora en `Images/mcgonagall.png` adaptada al estilo visual e iconografía de los aliados existentes (Harry, Ron, Hermione).
