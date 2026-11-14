# Feature Specification: Sistema Híbrido de Oleadas por Bajas y Medidor Visual de Progreso

**Feature Branch**: `[013-wave-progression-meter]`

**Created**: 2026-10-08

**Status**: Draft

**Input**: User description: "Vamos a refactorizar el sistema de progresión y oleadas del juego. El evento principal de 'Gran Oleada' (Huge Wave) ya no se disparará por tiempo, sino por la cantidad de enemigos derrotados (Kills). Sin embargo, el hilo o temporizador original de oleadas DEBE mantenerse corriendo en segundo plano, ya que seguirá siendo el responsable de calcular la escalada de dificultad y el ritmo de spawn de los enemigos comunes. Además, implementaremos un medidor de progreso visual temático. Se usaran de las imagenes Personajes_Medidor 2 oleadas y 3 oleadas, deberas cambiarle el nombre a ingles para respetar las reglas, estos se ubicaran a la izquierda inferior para mostrar el progreso..."

---

## Clarifications

### Session 2026-10-08
- Q: ¿Cómo debe comportarse el temporizador de spawn de enemigos comunes mientras una Gran Oleada está activa en pantalla? → A: Pausar temporalmente el spawn regular durante la Gran Oleada y reanudarlo al limpiar el asalto masivo.
- Q: ¿Cómo se resuelve la victoria del nivel y el medidor de progreso al alcanzar el umbral de bajas de la Oleada Final? → A: Al alcanzar el último umbral de bajas, el medidor llega al 100%, se dispara la Gran Oleada Final y la victoria se otorga al derrotar a todos los enemigos restantes en pantalla.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gestor Híbrido de Oleadas: Eventos por Bajas y Dificultad Temporal (Priority: P1) 🎯 MVP

Como jugador, quiero que las Grandes Oleadas se disparen de acuerdo con mi habilidad y velocidad para derrotar enemigos en lugar de ocurrir por un temporizador ciego, mientras que la dificultad ambiental y la frecuencia de aparición de enemigos comunes continúa escalando con el tiempo, para que el ritmo de la partida premie la defensa activa y mantenga la tensión táctica.

**Why this priority**: Es la mecánica troncal del bucle jugable. Desacopla el flujo de supervivencia del paso pasivo de los segundos y lo enlaza directamente a la interacción del jugador contra las oleadas de Mortífagos, evitando que una oleada masiva caiga cuando el jugador aún no ha podido limpiar la fase previa.

**Independent Test**: Iniciar cualquier nivel (ej. Nivel 1); derrotar 15 enemigos comunes; verificar que la Gran Oleada 1 se dispara en el momento exacto en que se registra la baja número 15. Verificar que el contador de fase se reinicia a 0 y que tras derrotar 20 enemigos subsiguientes se dispara la Oleada Final. Verificar además que el ritmo de spawn temporal de enemigos comunes sigue acelerándose de forma continua en segundo plano.

**Acceptance Scenarios**:

1. **Given** una partida en curso en el Nivel 1 en su primera fase (umbral de 15 bajas), **When** el jugador derrota al enemigo número 15 (salud del enemigo reducida a 0 por daño de aliados o hechizos), **Then** el sistema activa el anuncio y el despliegue masivo de la Gran Oleada 1, y reinicia el contador de bajas de la fase a 0 para el siguiente objetivo (20 bajas).
2. **Given** un nivel con 3 oleadas (Nivel 8 o Nivel 9), **When** el jugador acumula secuencialmente las bajas requeridas por fase (20, 40 y 60 en Nivel 8; 30, 40 y 70 en Nivel 9), **Then** cada Gran Oleada intermedia y la Oleada Final se disparan exactamente al alcanzar sus umbrales respectivos, reseteando el contador de fase en cada hito y sin arrastrar excedentes de bajas a fases futuras.
3. **Given** que el jugador tarda más tiempo en derrotar enemigos, **When** el temporizador de dificultad temporal sigue transcurriendo en segundo plano, **Then** el intervalo de spawn de enemigos comunes se reduce progresivamente aumentando la presión en pantalla, sin forzar la Gran Oleada hasta que se cumpla la cuota de bajas.
4. **Given** un enemigo que invade el jardín cruzando el límite izquierdo o una entidad removida sin morir en combate, **When** abandona el tablero, **Then** dicha salida NO se contabiliza como baja para los umbrales de Gran Oleada.

---

### User Story 2 - Interfaz de Medidor Visual de Progreso (Reloj de Arena) (Priority: P1)

Como jugador, quiero ver un medidor temático en la esquina inferior izquierda de la pantalla que se llene de líquido rojo de abajo hacia arriba a medida que derroto Mortífagos, para saber con claridad cuánto progreso global llevo en el nivel y cuán cerca estoy de las Grandes Oleadas y de la victoria final.

**Why this priority**: Proporciona retroalimentación visual inmediata e intuitiva del progreso hacia los umbrales de bajas, permitiendo al jugador anticipar visualmente cuándo se aproxima la marea de enemigos.

**Independent Test**: Cargar cualquier nivel y observar el HUD inferior izquierdo; verificar la presencia del marco de cristal de reloj de arena correspondiente al nivel (medidor de 2 oleadas para niveles 1 al 7; medidor de 3 oleadas para niveles 8 y 9). Derrotar enemigos y verificar que el líquido rojo asciende verticalmente de abajo hacia arriba de forma proporcional a la suma total de bajas del nivel (ej. en Nivel 1, el 100% corresponde a 35 bajas).

**Acceptance Scenarios**:

1. **Given** un nivel del 1 al 7 iniciado, **When** se visualiza el HUD en la esquina inferior izquierda, **Then** se muestra el medidor con el marco temático para 2 oleadas (`wave_meter_2_waves.png`) con el líquido rojo vacío (0%).
2. **Given** un nivel de 3 oleadas (Niveles 8 y 9), **When** se visualiza el HUD, **Then** se muestra el medidor con el marco temático para 3 oleadas (`wave_meter_3_waves.png`) cuyo rango total (100%) equivale a la suma de los tres umbrales del nivel (120 en Nivel 8, 140 en Nivel 9).
3. **Given** que un enemigo es derrotado válidamente, **When** se procesa la baja, **Then** el valor del medidor se incrementa en 1 unidad llenándose de abajo hacia arriba (`Bottom to Top`), reflejando la proporción exacta de bajas acumuladas en el nivel.
4. **Given** que se alcanza el umbral de bajas de la Oleada Final, **When** se procesa la última baja requerida, **Then** el medidor visual alcanza el 100% de llenado y se despliega la Gran Oleada Final; la condición de victoria se activa una vez que todos los enemigos restantes en pantalla son derrotados sin que el medidor sobrepase el 100%.

---

### Edge Cases

- **Múltiples muertes simultáneas por daño en área**: Si un hechizo explosivo (como la Recordadora, la Escoba o el proyectil de Dumbledore) derrota a múltiples enemigos al mismo tiempo cruzando el umbral de la fase, el sistema debe registrar el evento de Gran Oleada de manera segura una sola vez sin duplicar transiciones de estado ni saltarse fases.
- **Enemigos que invaden el jardín o son descartados**: Si un enemigo llega al borde izquierdo (`global_position.x < 0`), debe gatillar derrota del jugador y NO sumar al contador de bajas ni al medidor de progreso.
- **Transición de fase con oleada masiva activa**: Cuando se dispara una Gran Oleada, los enemigos spawnados durante la misma que sean derrotados deben contar para la siguiente fase activa solo una vez que dicha fase haya iniciado su conteo oficial.
- **Reinicio del nivel o salida al mapa**: Al reiniciar el nivel o regresar al mapa, los contadores de bajas de fase y acumulados del medidor deben restablecerse completamente a 0.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El gestor de oleadas del nivel DEBE mantener activo en segundo plano el temporizador original de spawn/dificultad para regular el ritmo temporal y la composición de los enemigos comunes.
- **FR-002**: El disparo de las Grandes Oleadas (eventos de oleada intermedia y oleada final) DEBE estar completamente desacoplado del temporizador de tiempo y depender exclusivamente del contador de enemigos derrotados en combate.
- **FR-003**: Cada entidad enemiga DEBE notificar su derrota en combate únicamente cuando sus puntos de salud se reduzcan a cero o menos, excluyendo salidas por invasión o remoción administrativa.
- **FR-004**: Los umbrales de bajas por fase para disparar las Grandes Oleadas DEBEN configurarse exactamente con los siguientes valores por nivel:
  - **Nivel 1** (2 oleadas): Oleada 1 = 15 bajas, Oleada Final = 20 bajas (Total nivel = 35 bajas).
  - **Nivel 2** (2 oleadas): Oleada 1 = 20 bajas, Oleada Final = 25 bajas (Total nivel = 45 bajas).
  - **Nivel 3** (2 oleadas): Oleada 1 = 20 bajas, Oleada Final = 30 bajas (Total nivel = 50 bajas).
  - **Nivel 4** (2 oleadas): Oleada 1 = 25 bajas, Oleada Final = 30 bajas (Total nivel = 55 bajas).
  - **Nivel 5** (2 oleadas): Oleada 1 = 30 bajas, Oleada Final = 35 bajas (Total nivel = 65 bajas).
  - **Nivel 6** (2 oleadas): Oleada 1 = 30 bajas, Oleada Final = 30 bajas (Total nivel = 60 bajas).
  - **Nivel 7** (2 oleadas): Oleada 1 = 30 bajas, Oleada Final = 30 bajas (Total nivel = 60 bajas).
  - **Nivel 8** (3 oleadas): Oleada 1 = 20 bajas, Oleada 2 = 40 bajas, Oleada Final = 60 bajas (Total nivel = 120 bajas).
  - **Nivel 9** (3 oleadas): Oleada 1 = 30 bajas, Oleada 2 = 40 bajas, Oleada Final = 70 bajas (Total nivel = 140 bajas).
- **FR-005**: Al alcanzarse el umbral de bajas de una fase, el contador de bajas de esa fase DEBE reiniciarse a cero, sin arrastrar bajas previas a la siguiente fase.
- **FR-006**: La interfaz del HUD en todos los niveles DEBE incorporar un componente visual de progreso ubicado en la esquina inferior izquierda.
- **FR-007**: El componente visual de progreso DEBE utilizar una textura de reloj de arena de cristal en su capa superior (`Over`) y una textura de color rojo en su capa de progreso (`Progress`).
- **FR-008**: Para los niveles 1 al 7, el marco del medidor DEBE utilizar el recurso gráfico adaptado a inglés `wave_meter_2_waves.png` (renombrado desde `Personajes_Medidor 2 oleadas.png`).
- **FR-009**: Para los niveles 8 y 9, el marco del medidor DEBE utilizar el recurso gráfico adaptado a inglés `wave_meter_3_waves.png` (renombrado desde `Personajes_Medidor 3 oleadas.png`).
- **FR-010**: El llenado del medidor visual DEBE realizarse estrictamente en dirección vertical de abajo hacia arriba (`Bottom to Top`), revelando el color rojo proporcionalmente al total acumulado de bajas del nivel.
- **FR-011**: El valor máximo del medidor (`max_value`) DEBE ser igual a la suma de todos los umbrales de bajas del nivel correspondiente.
- **FR-012**: Mientras una Gran Oleada se encuentre activa en pantalla, el temporizador de spawn de enemigos comunes DEBE pausarse temporalmente, reanudándose una vez que el asalto de dicha Gran Oleada haya sido despejado por el jugador.
- **FR-013**: Al alcanzarse el umbral de bajas correspondiente a la Oleada Final, el medidor visual DEBE alcanzar su valor máximo (100%) y el gestor DEBE disparar el despliegue de la Gran Oleada Final. La condición de victoria del nivel (`_win`) DEBE activarse una vez que todos los enemigos desplegados en dicha oleada y en pantalla hayan sido derrotados (`_active_enemies == 0`), sin permitir que el medidor exceda su valor máximo.

---

### Key Entities *(include if feature involves data)*

- **Gestor de Oleadas / Wave Manager**: Componente de lógica del nivel que orquesta el ciclo de vida del escenario, manteniendo el temporizador de escalada temporal de spawn regular e incrementando el registro de bajas para disparar las Grandes Oleadas según los umbrales predefinidos.
- **Umbral de Bajas de Fase (Kill Threshold)**: Valor numérico entero que define cuántos enemigos válidos deben ser derrotados en combate en la fase actual para desbloquear la siguiente Gran Oleada.
- **Medidor Visual de Progreso (Wave Progress Meter)**: Elemento del HUD (`TextureProgressBar`) posicionado en la esquina inferior izquierda que mapea el acumulador total de bajas del nivel sobre una barra de progreso vertical de cristal con líquido rojo.
- **Recurso de Medidor Gráfico (Wave Meter Texture Resource)**: Activos visuales del reloj de arena temático con divisiones visuales para 2 oleadas (`wave_meter_2_waves.png`) y 3 oleadas (`wave_meter_3_waves.png`).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de las Grandes Oleadas en los niveles 1 al 9 se disparan únicamente cuando el contador de bajas alcanza el umbral exacto estipulado para la fase en curso.
- **SC-002**: Ninguna Gran Oleada es disparada por expiración de temporizador de tiempo, mientras que el ritmo de spawn de enemigos regulares continúa adaptándose y acelerándose temporalmente según la curva de dificultad prevista.
- **SC-003**: El medidor visual en la esquina inferior izquierda incrementa su valor en tiempo real con cada baja válida, alcanzando el 100% de llenado vertical (Bottom to Top) al completarse la cuota total de bajas del nivel.
- **SC-004**: Los niveles 1 al 7 muestran con precisión el medidor de 2 oleadas, y los niveles 8 y 9 muestran el medidor de 3 oleadas sin errores de asignación de textura ni deformaciones de interfaz.
- **SC-005**: La totalidad del código nuevo y refactorizado cumple con los estándares de la cátedra (identificadores en inglés, funciones <= 15 líneas, tipado estático estricto y ausencia de números mágicos).

---

## Assumptions

- Los archivos `Personajes_Medidor 2 oleadas.png` y `Personajes_Medidor 3 oleadas.png` presentes en `Images/` son renombrados a `wave_meter_2_waves.png` y `wave_meter_3_waves.png` para cumplir con la regla de inglés en identificadores y assets del repositorio (`AGENTS.md`).
- El relleno del medidor rojo se implementará con una textura roja plana dimensionada adecuadamente para la máscara del `TextureProgressBar`.
- La señal `defeated` ya existente en `Enemy` (o emitida al morir con vida <= 0) es la fuente canónica de eventos de bajas para alimentar al gestor y al medidor.
- La dificultad temporal de los enemigos regulares continúa operando a través de los temporizadores de spawn y directores de oleadas existentes sin alterar el balance de daño o vida de los enemigos.
