# Feature Specification: Animación de Desbloqueo de Recompensa al Ganar Nivel

**Feature Branch**: `015-animacion-desbloqueo-recompensa`

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "Cuando se gana un nivel debera aparecer una animacion de la semilla que se desbloque en el siguiente nivel, Animacion:'Desde el centro de la pantalla, con el fondo blurreado, debera aparacer con un zoom in giratorio hasta que se pocicione, dejando un brebe lugar debajo de la semilla para que haya un texto descriptivo, estos 2 elementos deben ocupar toda la pantalla(la animacion es solo de la semilla no del texto)' En cada nivel: en el nivel 1 debe aparecer la animacion de la semilla de la recordadora (...)"

## Clarifications

### Session 2026-10-12

- Q: ¿Cuál debe ser el flujo del juego tras pulsar el botón 'Continuar' en la pantalla de desbloqueo de recompensa? → A: Mostrar a continuación el panel de victoria habitual (`LevelEndPanel`), permitiendo al jugador elegir entre 'Siguiente Nivel', 'Reintentar' o 'Volver al Mapa'.
- Q: ¿Se debe permitir saltar (omitir) la animación de zoom in giratorio si el jugador hace clic en la pantalla mientras está en curso? → A: Permitir saltar: si el jugador hace clic en la pantalla durante el giro, la semilla salta de inmediato a su tamaño/posición final y se habilita el botón 'Continuar'.
- Q: ¿La cinemática de desbloqueo debe mostrarse solo la primera vez que se supera el nivel o también al rejugar niveles ya completados? → A: Reproducirse únicamente la primera vez que el jugador supera el nivel (si se rejuega un nivel ya completado, pasa directo al panel de victoria habitual).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Presentación y Animación Cinemática de la Recompensa Desbloqueada (Priority: P1) 🎯 MVP

Como jugador, al ganar un nivel que otorgue un nuevo aliado, herramienta o trofeo, quiero ver una secuencia cinemática a pantalla completa con fondo difuminado (blur) donde la semilla o elemento desbloqueado aparezca desde el centro mediante un zoom in giratorio hasta asentarse en su posición final, acompañada de su texto descriptivo debajo, para experimentar una sensación gratificante de logro y progreso.

**Why this priority**: Es el núcleo de la experiencia solicitada por el usuario. Transforma la pantalla de victoria genérica en un evento de desbloqueo temático, celebratorio y claro que anticipa la nueva mecánica disponible para el siguiente nivel.

**Independent Test**: Puede probarse simulando la victoria en el Nivel 1: comprobar que el juego desenfoque/atenúe el escenario de fondo, instancie la pantalla de recompensa, anime la semilla de la Recordadora con zoom in y rotación continua hasta detenerse en su lugar asignado, muestre su descripción debajo sin animar el texto, y ofrezca un botón o acción para avanzar al siguiente destino.

**Acceptance Scenarios**:

1. **Given** el jugador completa con éxito las condiciones de victoria de un nivel con recompensa (ej. Nivel 1), **When** se detiene la partida y se activa el flujo de victoria, **Then** el fondo del nivel se muestra desenfocado/blurreado y se despliega la pantalla de desbloqueo a pantalla completa.
2. **Given** la pantalla de desbloqueo se encuentra activa, **When** inicia la cinemática, **Then** únicamente el icono/semilla ejecuta la animación de entrada con zoom in giratorio desde escala mínima en el centro hasta su tamaño y posición final.
3. **Given** el icono/semilla culmina o se asienta en su posición final, **When** se presenta la información al jugador, **Then** el texto descriptivo correspondiente se visualiza de forma estática y legible inmediatamente debajo del icono sin haber sufrido la rotación ni el zoom in.
4. **Given** el jugador revisa la recompensa y su descripción, **When** acciona el control de confirmación ("Continuar"), **Then** la pantalla de recompensa se cierra y se despliega de inmediato el panel de victoria habitual (`LevelEndPanel`), permitiendo al usuario decidir si continuar al siguiente nivel, reintentar o volver al mapa.
5. **Given** la animación de zoom in giratorio se encuentra en progreso, **When** el jugador hace clic o pulsa sobre la pantalla, **Then** la animación se omite inmediatamente, posicionando la semilla en su escala y rotación final de reposo y habilitando de inmediato el botón "Continuar".
6. **Given** el jugador rejuega un nivel que ya había completado y desbloqueado en partidas anteriores, **When** se declara la victoria, **Then** el sistema omite la pantalla de desbloqueo de recompensa y despliega directamente el panel estándar de victoria (`LevelEndPanel`).

---

### User Story 2 - Mapeo de Recompensas Específicas por Nivel (Priority: P2)

Como jugador, quiero que cada nivel superado (del 1 al 8) me premie específicamente con la semilla o herramienta que se utilizará en el siguiente nivel, con su arte distintivo y un texto explicativo claro que resalte su utilidad táctica en el combate.

**Why this priority**: Garantiza la coherencia narrativa y mecánica de la campaña del juego. Los niveles deben desbloquear ordenadamente a sus aliados y herramientas correspondientes.

**Independent Test**: Puede probarse venciendo secuencialmente cada nivel del 1 al 8 y verificando que el elemento y la descripción mostrada coincidan con exactitud con los textos y sprites requeridos.

**Acceptance Scenarios**:

1. **Given** la victoria en el Nivel 1, **When** se presenta la recompensa, **Then** se exhibe la semilla de la Recordadora con el texto: *"¿Olvidaste algo? Su humo rojo se vuelve tan inestable que estalla mágicamente, fulminando al instante a los enemigos en un radio cercano."*
2. **Given** la victoria en el Nivel 2, **When** se presenta la recompensa, **Then** se exhibe la semilla de Protego con el texto: *"¿Necesitas tiempo? Este poderoso encantamiento crea una sólida barrera mágica que detiene a los mortífagos en seco, absorbiendo daño para proteger tus defensas."*
3. **Given** la victoria en el Nivel 3, **When** se presenta la recompensa, **Then** se exhibe la herramienta/semilla de Accio con el texto: *"¿Necesitas espacio? Usa el hechizo convocador Accio para retirar instantáneamente a cualquier aliado del campo de batalla y reorganizar tu estrategia mágica."*
4. **Given** la victoria en el Nivel 4, **When** se presenta la recompensa, **Then** se exhibe la semilla de Ron con el texto: *"¡Pura potencia! Aunque le toma un momento extra preparar su ataque, los hechizos de Ron golpean con una fuerza aplastante que destroza al enemigo."*
5. **Given** la victoria en el Nivel 5, **When** se presenta la recompensa, **Then** se exhibe la semilla de la Escoba con el texto: *"¡A despejar el camino! Esta veloz escoba cruza el campo volando, barriendo una línea entera y fulminando a todos los mortífagos a su paso."*
6. **Given** la victoria en el Nivel 6, **When** se presenta la recompensa, **Then** se exhibe la semilla de Hermione con el texto: *"¿Demasiado rápidos? Hermione conjura precisos hechizos gélidos que ralentizan el avance de los mortífagos, devolviéndote el control absoluto de la batalla."*
7. **Given** la victoria en el Nivel 7, **When** se presenta la recompensa, **Then** se exhibe la semilla de McGonagall con el texto: *"¿Peligro inminente? La profesora McGonagall desata una ráfaga implacable de cuatro hechizos consecutivos, destrozando velozmente hasta las defensas más resistentes de los mortífagos."*
8. **Given** la victoria en el Nivel 8, **When** se presenta la recompensa, **Then** se exhibe la semilla de Dumbledore con el texto: *"¿Magia suprema? Dumbledore lanza un poderoso encantamiento frontal que detona al impactar, dañando simultáneamente a múltiples mortífagos en su zona de explosión."*

---

### User Story 3 - Casos Especiales de los Niveles Finales (Nivel 9 y Nivel 10) (Priority: P3)

Como jugador, quiero que el Nivel 9 pase directamente al panel de victoria sin mostrar cinemática de semilla al no haber nuevo aliado que desbloquear, y que al derrotar a Quirrell en el Nivel 10 se exhiba el trofeo supremo de la Piedra Filosofal como consagración final del juego con su respectivo mensaje conmemorativo.

**Why this priority**: Cierra el ciclo de progresión del juego, gestionando adecuadamente la ausencia de desbloqueos previos a la batalla final y celebrando la victoria definitiva de la campaña.

**Independent Test**: Puede probarse ganando el Nivel 9 (comprobando que no surge pantalla de recompensa) y ganando el Nivel 10 (comprobando que se exhibe la Piedra Filosofal como trofeo con su sprite de marcador de posición y el texto de felicitaciones).

**Acceptance Scenarios**:

1. **Given** el jugador gana el Nivel 9, **When** se evalúa la recompensa del nivel, **Then** el sistema determina que no hay desbloqueo y transiciona de forma inmediata al panel regular de victoria.
2. **Given** el jugador derrota a Quirrell en el Nivel 10, **When** se activa la pantalla de recompensa final, **Then** se exhibe el artefacto de la Piedra Filosofal utilizando un marcador visual (placeholder) provisional animado con el mismo zoom in giratorio.
3. **Given** la pantalla de recompensa del Nivel 10 se encuentra visible, **When** el jugador observa la descripción, **Then** se muestra el texto completo de victoria: *"¡Has protegido la legendaria Piedra Filosofal! Gracias a tu brillante estrategia mágica, lograste derrotar a Quirrell y frustrar los oscuros planes de Voldemort. Este invaluable tesoro es el trofeo definitivo que consagra tu gran victoria. ¡Muchísimas gracias por jugar y defender los terrenos de Hogwarts hasta el final!"*

---

### Edge Cases

- **Resolución y Escalado de Pantalla**: La semilla ampliada y el texto descriptivo de longitud variable (especialmente el párrafo extenso del Nivel 10) DEBEN mantener márgenes seguros y alineación vertical equilibrada ocupando toda la pantalla sin desbordarse ni truncar el botón de continuación a 1920x1080.
- **Interrupción o Clic para Omitir**: Si el jugador pulsa la pantalla durante el transcurso de la animación de zoom in giratorio, la animación DEBE interrumpirse de inmediato, situando la semilla en su posición y escala final de reposo y mostrando el botón de confirmación ("Continuar") sin riesgo de doble invocación ni congelamiento.
- **Ausencia de Sprite Final para la Piedra Filosofal**: Debe emplearse un sprite temporal o generado como placeholder visualmente coherente hasta que se suministre el arte final definitivo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema MUST proveer una escena desacoplada y reutilizable para la presentación de recompensas de nivel (`reward_unlock_screen.tscn` / `reward_unlock_screen.gd`).
- **FR-002**: La pantalla de recompensa MUST desplegar una capa de fondo con efecto de desenfoque visual (shader de blur o atenuación traslúcida) que cubra la totalidad de la resolución (1920x1080).
- **FR-003**: La pantalla de recompensa MUST contener un nodo visual central para el elemento desbloqueado (textura de semilla o trofeo) y un nodo de texto inferior para la descripción temática.
- **FR-004**: Al presentarse la pantalla de recompensa, el sistema MUST animar exclusivamente el nodo del icono/semilla desde el centro de la pantalla mediante una combinación simultánea de escala (zoom in progresivo) y rotación angular continua.
- **FR-005**: El texto descriptivo NO MUST rotar ni escalarse durante la animación de la semilla; DEBE permanecer estático debajo de la posición final del icono, apareciendo de forma limpia y perfectamente legible.
- **FR-006**: Ambos elementos (icono del elemento desbloqueado y bloque de texto descriptivo) MUST estructurarse para ocupar armónicamente el espacio vertical y horizontal de la pantalla completa.
- **FR-007**: El sistema MUST asociar a cada nivel su respectivo elemento desbloqueado y descripción:
  - Nivel 1: Semilla Recordadora (`Images/seed_remembrall.png`) + texto de Recordadora.
  - Nivel 2: Semilla Protego (`Images/seed_protego.png`) + texto de Protego.
  - Nivel 3: Herramienta Accio (`Images/elder_wand.png` o semilla Accio) + texto de Accio.
  - Nivel 4: Semilla Ron (`Images/seed_ron.png`) + texto de Ron.
  - Nivel 5: Semilla Escoba (`Images/seed_broomstick.png`) + texto de Escoba.
  - Nivel 6: Semilla Hermione (`Images/seed_hermione.png`) + texto de Hermione.
  - Nivel 7: Semilla McGonagall (`Images/seed_mcgonagall.png`) + texto de McGonagall.
  - Nivel 8: Semilla Dumbledore (`Images/seed_dumbledore.png`) + texto de Dumbledore.
  - Nivel 9: Ninguna recompensa (desactivado; omisión automática de la pantalla de recompensa).
  - Nivel 10: Piedra Filosofal (textura de marcador de posición temporal) + texto conmemorativo final.
- **FR-008**: Al ganar un nivel en `level.gd`, si el nivel cuenta con una recompensa asignada Y el jugador no había desbloqueado aún el siguiente nivel (primera victoria del nivel), el sistema MUST mostrar primero la pantalla de desbloqueo antes de pasar al panel de victoria. Si el nivel ya fue completado previamente (rejugabilidad), DEBE omitir la pantalla de desbloqueo y desplegar de forma directa el panel estándar de victoria (`LevelEndPanel`).
- **FR-009**: Al ganar el Nivel 9, el sistema MUST omitir la pantalla de desbloqueo y desplegar directamente el panel estándar de victoria.
- **FR-010**: La pantalla de recompensa MUST incluir un botón interactivo de confirmación ("Continuar") que, al ser presionado, cierre la pantalla de recompensa y despliegue inmediatamente el panel estándar de victoria (`LevelEndPanel`), permitiendo al usuario decidir si continuar al siguiente nivel, reintentar o volver al mapa.
- **FR-011**: El sistema MUST permitir omitir la cinemática de rotación y zoom in: si el jugador hace clic o pulsa en cualquier área de la pantalla mientras la animación se encuentra en curso, la cinemática debe avanzar instantáneamente a su estado final de reposo y habilitar el botón "Continuar".

### Key Entities

- **RewardUnlockScreen**: Escena de interfaz superpuesta que orquesta el desenfoque de fondo, la cinemática de rotación/zoom de la semilla, la muestra del texto descriptivo y la confirmación del usuario para avanzar.
- **RewardData**: Estructura o recurso de datos que encapsula la textura a mostrar, el texto descriptivo asociado y el identificador del nivel que lo otorga.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los niveles con recompensa (1 al 8 y 10) muestran su respectivo elemento desbloqueado con la cinemática de rotación y zoom in al ganar la partida.
- **SC-002**: El Nivel 9 avanza limpiamente sin mostrar la cinemática de recompensa, respetando que no hay nuevo aliado que desbloquear.
- **SC-003**: La animación de zoom in giratorio de la semilla se completa de manera fluida en un tiempo comprendido entre 1.0 y 2.0 segundos sin tirones visuales ni desincronización.
- **SC-004**: Los textos descriptivos especificados coinciden de forma exacta (100% de fidelidad de contenido y puntuación) con las cadenas requeridas por el usuario.
- **SC-005**: La interfaz se adapta completamente a la resolución objetivo de 1920x1080 sin truncar texto ni superponer elementos interactivos.

## Assumptions

- La cinemática de recompensa se activa inmediatamente después de que se declara la victoria del nivel (`_win()` en `level.gd`).
- Al pulsar "Continuar" tras visualizar la recompensa, se presenta inmediatamente el panel estándar de victoria (`LevelEndPanel`), preservando las opciones habituales de avanzar al siguiente nivel, reintentar o regresar al mapa.
- La animación se puede implementar fluidamente mediante un Tween de Godot 4 que manipule las propiedades `scale` y `rotation` del nodo contenedor de la textura mientras el fondo ejecuta el desenfoque.
- Para el Nivel 10, dado que el arte definitivo de la Piedra Filosofal no está terminado, se creará un gráfico placeholder digno y estilizado (ej. joya/piedra mágica de color rubí) que podrá ser reemplazado fácilmente sin alterar la escena ni el código.
