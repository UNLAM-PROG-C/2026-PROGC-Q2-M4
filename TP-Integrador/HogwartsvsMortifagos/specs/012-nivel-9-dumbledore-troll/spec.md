# Feature Specification: Nivel 9 - Dumbledore y el Troll Colosal

**Feature Branch**: `[012-nivel-9-dumbledore-troll]`

**Created**: 2026-10-08

**Status**: Draft

**Input**: User description: "Vamos a desarrollar el Nivel 9 del juego. El objetivo central es integrar a Dumbledore (daño en área 3x3, equivalente a Melon-pult pero con disparo recto) y al Troll (fuerza bruta instakill, equivalente al Gargantuar). Contexto del Nivel 9: Cuadrícula: 5 líneas completas. Enemigos: 'Alumno Slytherin', 'Draco', 'Alumno con Protego', 'Prefecto Slytherin' y la nueva amenaza colosal: 'Troll'. Arsenal disponible: Harry, Caja de Snitch, Recordadora, Protego, Accio, Ron, Escoba, Hermione, McGonagall y la nueva carta: Dumbledore. Assets ya preparados por el usuario: La escena del enemigo Troll (troll.tscn) junto con sus animaciones y sprite ya existen en el proyecto. NO se debe modificar la estructura de nodos visuales ni el AnimationPlayer de esta escena, solo inyectar la lógica. El sprite de Dumbledore está en la carpeta Images. HU-1: Ataque Pesado con Splash Damage (Dumbledore). HU-2: Integración de la Lógica del Troll (Enemigo Colosal)."

## Clarifications

### Session 2026-10-08

- Q: ¿Cómo debe comportarse la animación 'attack' del Troll al colisionar con un aliado? → A: Pausa de golpe estilo Gargantuar: al encontrar una planta aliada en su celda frontal, el Troll se detiene brevemente para ejecutar la animación `'attack'`, destruye al aliado con un impacto letal de instakill (9999 de daño) y, al concluir el golpe, retoma su avance hacia la izquierda reproduciendo la animación `'Walk'`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ataque Pesado con Splash Damage: Dumbledore (Priority: P1)

Como jugador, quiero poder plantar a "Dumbledore" en el jardín pagando 300 snitches para que dispare poderosos hechizos en línea recta que exploten al primer impacto contra un enemigo o escudo, causando daño simultáneo en un área de 3x3 celdas y diezmando grupos densos de mortífagos en múltiples carriles contiguos.

**Why this priority**: Es la nueva carta aliada del Nivel 9 y la unidad de daño masivo en área (splash damage) del juego (equivalente a Melon-pult pero con trayectoria recta), indispensable para responder a las oleadas densas y al avance de enemigos colosales.

**Independent Test**: Plantar a Dumbledore en una fila central (e.g. fila 3); verificar que al detectar enemigos en su carril dispara un proyectil horizontal (`dumbledore_projectile.tscn`). Al impactar al primer enemigo, el proyectil detona y genera daño simultáneo (20 puntos, equivalente a un disparo normal de Harry) en una caja de explosión de 3x3 celdas centrada en el impacto, dañando a los enemigos de la fila del impacto, la fila superior y la fila inferior. El proyectil se destruye tras la detonación.

**Acceptance Scenarios**:

1. **Given** el HUD del Nivel 9 con un saldo de al menos 300 snitches, **When** el jugador selecciona la carta de Dumbledore y hace clic en una celda libre de una fila activa, **Then** se descuentan 300 snitches, se inicia el tiempo de recarga de la carta y se instancia a Dumbledore en la celda seleccionada utilizando la textura explícita `res://Images/dumbledore.png`.
2. **Given** Dumbledore plantado en una fila activa, **When** no hay enemigos presentes en su carril hacia la derecha, **Then** se mantiene en guardia sin disparar proyectiles.
3. **Given** Dumbledore plantado en una fila activa, **When** detecta al menos un enemigo en su carril hacia la derecha y su tiempo de recarga (3.0 segundos) está listo, **Then** dispara un proyectil mágico en línea recta horizontal (eje X) a velocidad constante sin física de parábola ni catapulta, utilizando la textura `res://Images/dumbledore_shot.png`.
4. **Given** el proyectil de Dumbledore en vuelo, **When** colisiona con el primer enemigo o escudo que encuentra en su trayectoria, **Then** el proyectil detona de inmediato calculando un área de impacto de 3x3 celdas (aproximadamente 384x384 píxeles) centrada en el punto de contacto.
5. **Given** la detonación del proyectil de Dumbledore, **When** se evalúan las áreas superpuestas dentro del radio de 3x3 celdas, **Then** cada enemigo perteneciente al grupo `enemies` dentro del radio recibe exactamente 20 puntos de daño (igual al impacto base de Harry), abarcando enemigos en la fila del impacto, en la fila inmediata superior y en la fila inmediata inferior.
6. **Given** la aplicación del daño en área de la explosión, **When** concluye la iteración sobre todos los enemigos alcanzados, **Then** el proyectil se elimina inmediatamente del árbol de escena mediante `queue_free()`.
7. **Given** el proyectil de Dumbledore en vuelo en un carril vacío o donde el enemigo fue derrotado antes de ser alcanzado, **When** el proyectil cruza el límite derecho de la pantalla sin impactar ninguna entidad, **Then** se libera limpiamente sin detonar daño fantasma.

---

### User Story 2 - Amenaza Colosal Imparable: El Troll (Priority: P1)

Como jugador, me enfrentaré al "Troll", un enemigo colosal que avanza por el carril y, al encontrar una planta en su paso, se detiene brevemente para ejecutar su animación de ataque (`"attack"`) y aplastarla de un solo golpe demoledor (instakill), reanudando de inmediato su marcha (`"Walk"`), requiriendo exactamente 2 impactos de daño masivo (Escoba o Recordadora) para ser derrotado.

**Why this priority**: Es la nueva clase de enemigo colosal del juego (equivalente al Gargantuar), que redefine la estrategia defensiva al forzar el uso coordinado de daño masivo, sacrificio táctico y daño en área pesado antes de que alcance la casa.

**Independent Test**: Instanciar al Troll en una fila del jardín con múltiples aliados plantados (Harry, Protego, etc.); verificar que avanza continuamente a velocidad fija hacia la izquierda ejecutando su animación `"Walk"`. Al colisionar frontalmente con cualquier aliado del grupo `allies`, el Troll pausa su marcha, ejecuta la animación `"attack"`, destruye al aliado instantáneamente aplicando 9999 de daño, y una vez culminado el golpe vuelve a la animación `"Walk"` reanudando su avance. Verificar que resiste un impacto masivo de 1800 (quedando al 50% de su vida) y es derrotado exactamente al recibir el segundo impacto de 1800 (3600 de salud total).

**Acceptance Scenarios**:

1. **Given** la estructura de oleadas del Nivel 9, **When** transcurre la partida regular, **Then** el Troll solo es generado en los picos de dificultad extrema o durante la Gran Oleada Final, nunca en las escaramuzas iniciales.
2. **Given** el Troll en movimiento por un carril activo, **When** no tiene aliados bloqueando su paso frontal, **Then** avanza continuamente hacia la izquierda a velocidad constante (20.0 px/s) reproduciendo en bucle la animación `"Walk"`.
3. **Given** el Troll avanzando, **When** su área de detección o colisión física entra en contacto con cualquier aliado del grupo `allies` (incluso una defensa resistente como Protego), **Then** detiene su traslación horizontal, cambia a la animación `"attack"`, destruye inmediatamente al aliado con daño letal (9999 puntos de daño) y, al concluir el ataque, vuelve a la animación `"Walk"` y reanuda su marcha.
4. **Given** el Troll con su salud máxima intacta (3600 HP base), **When** recibe un primer impacto de daño masivo de una Escoba o una Recordadora (1800 puntos de daño), **Then** su salud se reduce exactamente al 50% (1800 HP restantes) y continúa avanzando sin morir.
5. **Given** el Troll al 50% de salud (1800 HP restantes), **When** recibe un segundo impacto de daño masivo (1800 puntos de daño de Escoba o Recordadora) o daño acumulado equivalente de proyectiles aliados, **Then** su salud llega a 0, emite la señal `defeated` y se elimina del tablero.
6. **Given** la escena existente `troll.tscn`, **When** se ejecuta el enemigo en el juego, **Then** se preserva íntegramente su jerarquía de nodos visuales (`Troll_Body`, `Right_Arm`, `Left_Arm`, `Back_Leg`, `Front_Leg`, `Loincloth`, etc.) y su nodo `AnimationPlayer` con las animaciones `"Walk"` y `"attack"`.

---

### User Story 3 - Desafío y Progresión Completa del Nivel 9 (Priority: P1)

Como jugador, quiero disputar el Nivel 9 en un tablero de 5 líneas completas disponiendo de un arsenal completo de 10 cartas (incluyendo a Dumbledore) para enfrentar a la combinación de Alumnos Slytherin, Dracos, Alumnos con Protego, Prefectos Slytherin y Trolls colosales, culminando en la victoria y el desbloqueo del Nivel 10 (Jefe Final: Profesor Quirrell).

**Why this priority**: Ensambla todas las mecánicas del juego hasta la fecha, ofreciendo el desafío más intenso antes de la batalla final contra el jefe, balanceando la economía para permitir el despliegue tanto de Dumbledore como de unidades de daño masivo contra los Trolls.

**Independent Test**: Cargar el Nivel 9 (`level_9.tscn`) desde el menú de selección de niveles o tras vencer el Nivel 8; verificar 5 filas activas con 5 Dementores defensivos, HUD con 10 cartas funcionales, oleadas mixtas que culminan con la aparición del Troll en la Gran Oleada Final, y verificar que al vencer se otorga la victoria y se desbloquea el Nivel 10 en el Mapa del Merodeador.

**Acceptance Scenarios**:

1. **Given** el inicio del Nivel 9, **When** carga el escenario, **Then** las 5 filas del tablero (Y=2..6) están activas para plantado y protegidas en el extremo izquierdo por 5 Dementores de respaldo.
2. **Given** el HUD del Nivel 9, **When** el jugador examina sus cartas, **Then** cuenta con las 10 opciones disponibles: Harry (100), Caja de Snitch (50), Ron (125), Recordadora (150), Protego (50), Escoba (125), Hermione (125), McGonagall (200), Dumbledore (300) y la pala Accio (0).
3. **Given** la tabla de enemigos del Nivel 9, **When** se generan las oleadas, **Then** intervienen los 5 tipos de enemigos: Alumnos Slytherin comunes, Dracos con armadura, Alumnos con Protego con escudo, Prefectos Slytherin atacantes a distancia y Trolls aplastadores.
4. **Given** el desembarco de la Gran Oleada Final del Nivel 9, **When** suena la advertencia `"¡OLEADA FINAL!"`, **Then** aparece al menos un Troll colosal escoltado por múltiples enemigos regulares y blindados a través de los carriles.
5. **Given** la batalla de la Oleada Final, **When** el jugador derrota a todos los atacantes (incluyendo a los Trolls) y el jardín queda libre de enemigos, **Then** se despliega el panel de victoria y se registra el desbloqueo del Nivel 10 en la progresión global del juego.

---

### Edge Cases

- **Troll alcanzando a un Dementor defensivo**: Si un Troll desborda una fila y alcanza el extremo izquierdo donde descansa un Dementor de respaldo, el Dementor se activa al contacto físico, barriendo la fila e infligiendo su daño masivo de instakill (9999 puntos) para destruir al Troll de forma garantizada.
- **Detonación de Dumbledore en los bordes del tablero**: Si el proyectil de Dumbledore impacta a un enemigo en la fila superior (fila 2) o en la fila inferior (fila 6), el área de splash de 3x3 celdas no debe generar errores fuera de rango; simplemente afecta a las filas adyacentes válidas dentro del tablero.
- **Impacto del proyectil de Dumbledore contra escudo Protego**: Si el proyectil colisiona contra el escudo de un Alumno con Protego, la explosión detona de inmediato en ese punto, dañando el escudo y simultáneamente dañando a cualquier otro enemigo presente en el radio 3x3 celdas (incluyendo enemigos detrás o en carriles contiguos).
- **Múltiples enemigos concentrados en el punto de impacto**: El proyectil de Dumbledore detona al entrar en contacto con el primer enemigo; todos los enemigos que se encuentren dentro de la caja de 3x3 celdas reciben exactamente 20 puntos de daño una sola vez por esa detonación. El proyectil se libera de inmediato (`queue_free()`) para evitar duplicaciones de daño en el mismo cuadro.
- **Troll colisionando con Protego**: Al entrar en contacto con Protego, el Troll detiene su avance, reproduce la animación `"attack"`, aplasta instantáneamente al Protego con su impacto de 9999 puntos de daño y retoma su marcha hacia la izquierda tras concluir la animación.
- **Doble impacto simultáneo de daño masivo sobre el Troll**: Si una Escoba barre la línea del Troll y simultáneamente una Recordadora detona a su lado, ambas aplican 1800 puntos de daño sumando 3600 puntos, lo que elimina al Troll de forma instantánea y limpia.
- **Ralentización de Hermione sobre el Troll**: Si un proyectil de Hermione impacta al Troll, su velocidad se reduce al factor mínimo permitido (70% de su velocidad base) durante el tiempo estipulado, ofreciendo al jugador segundos cruciales para preparar su defensa.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El HUD MUST incorporar una carta de aliado para "Dumbledore" con un costo explícito de 300 snitches.
- **FR-002**: La carta de Dumbledore MUST cargar su icono visual explícitamente desde la ruta `res://Images/dumbledore.png`.
- **FR-003**: La carta de Dumbledore MUST configurar un tiempo de recarga en el HUD (15.0 segundos) acorde a las unidades pesadas de alto coste.
- **FR-004**: La aliada "Dumbledore" (`dumbledore.tscn` / `dumbledore.gd`) MUST pertenecer al grupo `allies` y contar con 300 puntos de salud base.
- **FR-005**: Dumbledore MUST detectar la presencia de enemigos en su misma fila hacia la derecha antes de iniciar un ciclo de ataque.
- **FR-006**: Al detectar enemigos en su carril, Dumbledore MUST disparar un proyectil mágico pesado (`dumbledore_projectile.tscn`) con un intervalo de recarga de 3.0 segundos.
- **FR-007**: El proyectil de Dumbledore MUST utilizar la textura `res://Images/dumbledore_shot.png` y avanzar horizontalmente en línea recta hacia la derecha (eje X) a velocidad constante (+350 px/s) sin parábolas ni trayectoria de catapulta.
- **FR-008**: Al colisionar con un área del grupo `enemies`, el proyectil de Dumbledore MUST detonar inmediatamente activando un área de detección de splash de 3x3 celdas (aproximadamente 384x384 píxeles).
- **FR-009**: La detonación de Dumbledore MUST aplicar exactamente 20 puntos de daño (equivalente al disparo de Harry) a todas las entidades del grupo `enemies` detectadas dentro del área de 3x3 celdas.
- **FR-010**: Tras iterar y aplicar el daño a todos los enemigos dentro del área de splash, el proyectil de Dumbledore MUST destruirse inmediatamente (`queue_free()`).
- **FR-011**: El enemigo "Troll" MUST implementarse mediante el script `troll.gd` asociado al nodo raíz de la escena existente `troll.tscn`.
- **FR-012**: La escena `troll.tscn` NO MUST alterar su jerarquía de nodos visuales y su `AnimationPlayer` MUST alternar entre las animaciones `"Walk"` (durante el avance) y `"attack"` (durante el aplastamiento de un aliado).
- **FR-013**: El Troll MUST pertenecer al grupo `enemies` y tener una salud máxima base fijada exactamente en 3600.0 puntos de vida (`max_health = 3600.0`), calculada para resistir exactamente 2 impactos de daño masivo de 1800.0 puntos (Escoba o Recordadora).
- **FR-014**: El Troll MUST avanzar hacia la izquierda a velocidad constante (20.0 px/s) en cada cuadro (`position.x -= speed * delta`) mientras no se encuentre detenido ejecutando la animación de ataque contra una planta.
- **FR-015**: Al detectar contacto o proximidad frontal con una entidad del grupo `allies`, el Troll MUST pausar su avance, reproducir la animación `"attack"`, aplicar daño letal instantáneo (9999.0 de daño) al aliado objetivo para destruirlo de inmediato, y al finalizar la animación MUST reanudar su marcha hacia la izquierda con la animación `"Walk"`.
- **FR-016**: El gestor de oleadas (`wave_director.gd` / `WaveDirector`) MUST soportar la generación del enemigo Troll en la lista de escenas enemigas del nivel.
- **FR-017**: En el Nivel 9, el Troll MUST generarse únicamente en los picos de dificultad o durante la Gran Oleada Final, nunca en la fase inicial de apertura del nivel.
- **FR-018**: El Nivel 9 (`level_9.tscn`) MUST configurar 5 líneas completas del tablero (`active_rows = [2, 3, 4, 5, 6]`) respaldadas por 5 Dementores defensivos.
- **FR-019**: El Nivel 9 MUST habilitar un banco de 10 cartas en el HUD: Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba, Hermione, McGonagall, Dumbledore y la herramienta Accio.
- **FR-020**: El Nivel 9 MUST configurar la presencia de 5 tipos de enemigos: Alumnos Slytherin, Dracos, Alumnos con Protego, Prefectos Slytherin y Trolls.
- **FR-021**: El presupuesto total de enemigos del Nivel 9 MUST configurarse en al menos 40 enemigos regulares más los refuerzos colosales de las oleadas.
- **FR-022**: La victoria en el Nivel 9 MUST alcanzarse únicamente cuando todos los enemigos (incluyendo todos los Trolls desplegados) hayan sido derrotados y el jardín quede completamente despejado.
- **FR-023**: Al triunfar en el Nivel 9, el juego MUST marcar el nivel como completado y registrar el desbloqueo del Nivel 10 (Jefe Final) en el Mapa del Merodeador y en el gestor de progreso (`GameManager`).
- **FR-024**: Todo el código de scripts, señales, variables y constantes MUST escribirse en inglés y respetar tipado estático estricto, estilo Allman de llaves y el límite máximo de 15 líneas por función exigido por las reglas de la cátedra.
- **FR-025**: Los textos visibles para el usuario en HUD, botones y avisos de oleada MUST conservarse en español temático.

---

### Key Entities

- **Dumbledore (`Dumbledore` / `dumbledore.gd`)**: Entidad aliada pesada de daño en área (rol equivalente a Melon-pult con tiro recto). Costo: 300 snitches. Salud: 300 HP. Dispara proyectiles mágicos pesados cada 3.0 segundos.
- **Proyectil de Dumbledore (`DumbledoreProjectile` / `dumbledore_projectile.gd`)**: Proyectil mágico que avanza en línea recta a 350 px/s. Al contactar a un enemigo, detona un área de splash de 3x3 celdas (384x384 px) e inflige 20 puntos de daño a todos los enemigos contenidos.
- **Carta de Dumbledore (`dumbledore_card.tres`)**: Recurso de datos de la carta aliada que define el nombre visible, el costo de 300 snitches, la escena `dumbledore.tscn` y el icono `res://Images/dumbledore.png`.
- **Troll (`Troll` / `troll.gd`)**: Enemigo colosal de fuerza bruta (rol equivalente a Gargantuar). Salud: 3600 HP (2 impactos masivos de 1800 HP). Velocidad: 20 px/s continua. Ejecuta la animación `"attack"` para aplastar instantáneamente con 9999 de daño a los aliados en su camino, reanudando `"Walk"` tras el golpe.
- **Nivel 9 (`Level9` / `level_9.tscn`)**: Escenario de 5 carriles activos con 10 cartas en el HUD, oleadas combinadas de los 5 tipos de mortífagos y culminación con Trolls colosales.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dumbledore dispara proyectiles en línea recta hacia la derecha cada 3.0 segundos mientras haya enemigos en su carril, alcanzando al primer objetivo con una trayectoria completamente horizontal.
- **SC-002**: La detonación del proyectil de Dumbledore aplica exactamente 20 puntos de daño simultáneo a cada enemigo ubicado dentro de un radio de 3x3 celdas (384x384 px) del punto de impacto, afectando hasta 3 carriles contiguos en el 100% de las colisiones.
- **SC-003**: El proyectil de Dumbledore se destruye de forma inmediata tras completar la distribución del daño en área, sin generar impactos secundarios ni duplicación de daño.
- **SC-004**: Al entrar en contacto con una planta aliada, el Troll detiene su avance, ejecuta la animación `"attack"` y la destruye instantáneamente aplicando 9999 puntos de daño, volviendo de inmediato a la animación `"Walk"` y reanudando su marcha hacia la izquierda tras concluir el golpe.
- **SC-005**: El Troll resiste exactamente un impacto de daño masivo de 1800 puntos (reduciendo su salud al 50%) y muere garantizadamente al recibir un segundo impacto de 1800 puntos (3600 HP totales).
- **SC-006**: El Nivel 9 se ejecuta de forma fluida con las 10 cartas disponibles en el HUD, 5 filas activas y despliegue ordenado de los 5 tipos de enemigos en las oleadas.
- **SC-007**: La victoria en el Nivel 9 desbloquea de manera verificable el Nivel 10 en el Mapa del Merodeador y en el selector de niveles en el 100% de las partidas ganadas.

---

## Assumptions

- Dumbledore utiliza una cadencia de disparo de 3.0 segundos (más lenta que la cadencia de 1.5s de Harry y McGonagall) para equilibrar el enorme valor táctico del daño en área de 3x3 celdas.
- El costo de 300 snitches de Dumbledore refleja su estatus como la carta ofensiva más cara y destructiva del juego (equivalente a Melon-pult), exigiendo al jugador una economía bien consolidada con Cajas de Snitch.
- El proyectil de Dumbledore utiliza un área de colisión secundaria o llamada a solapamiento para resolver el radio de 3x3 celdas (384x384 píxeles, considerando celdas estándar de 128x128 píxeles del TileMap).
- La escena `troll.tscn` provista por el usuario conserva íntegramente sus nodos de sprites esqueletales y su `AnimationPlayer` con las animaciones `"Walk"` y `"attack"`, limitándose la modificación a adjuntar el script `troll.gd` en la raíz e incorporar su `CollisionShape2D` y área de detección frontal para interactuar con proyectiles y plantas.
- La velocidad del Troll se establece en 20.0 px/s (ligeramente inferior a los 32.0 px/s de un Alumno común), simulando el paso pesado y colosal característico de un Gargantuar.
- El daño de 9999.0 aplicado por el Troll a las plantas durante su golpe garantiza el instakill inmediato sobre cualquier aliado sin importar su vida máxima actual.
- El gestor de niveles (`level_select_menu.gd`) ya cuenta con soporte para niveles hasta el Nivel 10 (`LEVEL_COUNT = 10`), permitiendo el desbloqueo natural del Nivel 10 tras la victoria en el Nivel 9.
