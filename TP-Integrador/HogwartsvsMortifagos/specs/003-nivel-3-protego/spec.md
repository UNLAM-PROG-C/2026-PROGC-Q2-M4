# Feature Specification: Nivel 3 - Expansión y Tanques

**Feature Branch**: `[003-nivel-3-protego]`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "/speckit-specify Vamos a desarrollar el Nivel 3 del juego. El objetivo principal es habilitar el tablero completo e introducir la dinámica de "tanqueo" de daño..."

## Clarifications

### Session 2026-09-30
- Q: ¿Cuál será el tiempo de recarga de la carta Protego? → A: Tiempo medio, de 10 a 15 segundos.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Expansión Total del Campo (Priority: P1)

Como jugador, quiero tener acceso a las 5 líneas del mapa, para aprovechar todo el espacio disponible y gestionar un escenario más complejo.

**Why this priority**: Habilitar el tablero completo es fundamental para el diseño del Nivel 3 y escalar la dificultad.

**Independent Test**: Jugar el nivel 3 y comprobar que es posible plantar aliados en las 5 filas del tablero y que los enemigos aparecen aleatoriamente en cualquiera de esas 5 filas.

**Acceptance Scenarios**:

1. **Given** el Nivel 3 iniciado, **When** el sistema de oleadas instancia enemigos, **Then** los enemigos se distribuyen aleatoriamente en las 5 rutas horizontales posibles.
2. **Given** el jugador dispone de snitches, **When** hace clic en cualquier celda vacía de las 5 filas del mapa, **Then** el aliado se planta correctamente.

---

### User Story 2 - Enemigo Blindado "Draco" (Priority: P2)

Como jugador, me enfrentaré a un nuevo enemigo llamado "Draco" que resiste más impactos, para obligarme a concentrar defensas pesadas en su línea de ataque.

**Why this priority**: Introduce el concepto de tanques enemigos, forzando a replantear la estrategia defensiva.

**Independent Test**: Esperar a que se instancie un enemigo "Draco" y observar que soporta el doble de ataques que un Alumno Slytherin normal antes de ser derrotado, mientras ataca a los aliados al colisionar.

**Acceptance Scenarios**:

1. **Given** un enemigo Draco, **When** recibe daño de hechizos, **Then** absorbe el doble de daño que un Alumno Slytherin antes de morir.
2. **Given** un enemigo Draco avanzando, **When** colisiona con un aliado, **Then** detiene su avance y aplica daño continuo al aliado hasta destruirlo.

---

### User Story 3 - Desbloqueo de Barrera Defensiva "Protego" (Priority: P2)

Como jugador, quiero usar "Protego" pagando 50 snitches, para bloquear el avance de los enemigos en una celda específica y ganar tiempo para que mis atacantes los eliminen.

**Why this priority**: Proporciona una herramienta defensiva clave para lidiar con enemigos resistentes como Draco o con aglomeraciones.

**Independent Test**: Plantar un Protego y verificar que los enemigos se detienen a atacarlo y que el Protego soporta un daño masivo antes de ser destruido, sin atacar a los enemigos.

**Acceptance Scenarios**:

1. **Given** el HUD del Nivel 3, **When** el jugador selecciona Protego y paga 50 snitches, **Then** puede plantarlo en la cuadrícula.
2. **Given** un Protego plantado, **When** un enemigo colisiona con él, **Then** el enemigo se detiene y comienza a atacarlo.
3. **Given** un Protego bajo ataque, **When** recibe daño, **Then** no ataca ni dispara, simplemente absorbe el daño perdiendo salud progresivamente hasta llegar a cero.

### Edge Cases

- ¿Qué sucede si se planta un Protego justo sobre un enemigo en movimiento? (El enemigo debe detectarlo inmediatamente a través de las áreas de colisión y comenzar a atacarlo sin atravesarlo).
- ¿Qué ocurre si un Dementor barre la línea de un Draco? (Debería destruirlo instantáneamente como al resto, ya que el daño del Dementor es masivo).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El tablero del Nivel 3 MUST habilitar la validación de plantado para las 5 filas completas de la cuadrícula.
- **FR-002**: El generador de oleadas MUST distribuir la aparición de enemigos entre 5 puntos de spawn independientes, correspondientes a cada línea.
- **FR-003**: El sistema MUST incluir a "Draco" como una entidad enemiga, configurada con el doble de vida base respecto al Alumno Slytherin.
- **FR-004**: El enemigo Draco MUST utilizar un recurso visual (sprite/animación) específico para distinguirse del resto.
- **FR-005**: La interfaz MUST permitir la selección de la carta "Protego", validando un costo de 50 snitches.
- **FR-006**: Protego MUST reaccionar al daño (efectos visuales y pérdida de vida) pero NO MUST emitir proyectiles ni infligir daño.
- **FR-007**: Protego MUST configurarse con un valor de vida sustancialmente mayor (e.g. 40 veces la vida de un mago normal) para actuar como barrera defensiva.
- **FR-008**: Los enemigos MUST detectar a Protego como un obstáculo aliado y detenerse para atacarlo.
- **FR-009**: La carta Protego MUST tener un tiempo de recarga medio (entre 10 y 15 segundos) después de ser plantada.

### Key Entities

- **Draco**: Entidad enemiga pesada (tanque). Alta resistencia, velocidad estándar.
- **Protego**: Entidad aliada defensiva (barrera). Costo bajo, salud masiva, ataque nulo.
- **Nivel 3**: Nuevo escenario que gestiona 5 filas activas y nuevas configuraciones de HUD para el nuevo aliado.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Las 5 filas del escenario permiten interacciones completas (plantar aliados y recibir enemigos).
- **SC-002**: El enemigo Draco soporta exactamente el doble de impactos numéricos requeridos para vencer a un enemigo estándar.
- **SC-003**: El aliado Protego absorbe ataques enemigos durante un periodo de tiempo significativamente mayor al de una planta atacante antes de caer.

## Assumptions

- Se asumirá que la vida y daño del Alumno Slytherin están balanceados para usarse como punto de referencia numérico para Draco.
- Las mecánicas de daño, colisión y renderizado usarán exactamente la misma infraestructura (grupos, Area2D) de las demás entidades para cumplir con la arquitectura de Godot.
- La carta visual de Protego y el sprite de Draco están disponibles o se usarán placeholders visuales temporales si es necesario.
