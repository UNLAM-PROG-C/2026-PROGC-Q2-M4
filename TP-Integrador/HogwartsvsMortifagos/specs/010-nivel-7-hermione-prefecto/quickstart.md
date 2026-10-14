# Quickstart Guide: Validación del Nivel 7 - Hermione y Prefecto Slytherin

Esta guía describe los pasos prácticos para verificar la correcta integración de Hermione, el estado de ralentización, el Prefecto Slytherin y el Nivel 7.

## Escenarios de Validación Rápida

### Escenario 1: Verificación de la Ralentización de Hermione
1. **Objetivo**: Probar que Hermione dispara proyectiles azules que ralentizan a los enemigos y los tiñen visualmente.
2. **Pasos**:
   - Iniciar `level_7.tscn`.
   - Acumular 125 snitches y plantar a Hermione en una celda de una fila activa donde avance un enemigo.
   - Observar el proyectil: debe tener una modulación celeste/azul (`Color(0.3, 0.6, 1.0)`).
   - Observar el impacto: el enemigo debe teñirse de azul y su velocidad de caminata debe descender perceptiblemente al 70% de su velocidad original.
   - Si colisiona con un Protego o aliado, verificar que la cadencia de mordida también se reduce al 70%.
   - Esperar 5.0 segundos sin que reciba nuevos impactos: el enemigo debe recuperar su velocidad normal y su color blanco.

### Escenario 2: Verificación de Ataque a Distancia del Prefecto Slytherin
1. **Objetivo**: Comprobar que el Prefecto dispara proyectiles hacia la izquierda cuando hay aliados en su carril.
2. **Pasos**:
   - Iniciar `level_7.tscn` y dejar avanzar a un Prefecto Slytherin en una fila donde haya al menos un aliado plantado (por ejemplo, una planta defensiva como Protego).
   - Observar que el Prefecto camina hacia la izquierda y cada 3.5 segundos se detiene brevemente para disparar.
   - Observar el proyectil `slytherin_shot`: debe reproducir en bucle continuo los 4 fotogramas mientras vuela a 400 px/s hacia la izquierda.
   - El proyectil debe impactar sobre el aliado, infligiendo 20 puntos de daño y destruyéndose.
   - Colocar un Protego delante y verificar que absorbe los disparos protegiendo a las plantas ubicadas detrás.

### Escenario 3: Condición de Disparo (Fila Vacía)
1. **Objetivo**: Verificar que el Prefecto NO dispara si no hay aliados a su izquierda.
2. **Pasos**:
   - En una fila donde no se haya plantado ningún aliado, observar el avance del Prefecto Slytherin.
   - El Prefecto debe avanzar continuamente sin detenerse ni disparar proyectiles al vacío.

### Escenario 4: Progresión y Flujo Completo del Nivel 7
1. **Objetivo**: Validar el juego completo del Nivel 7 y el desbloqueo del Nivel 8.
2. **Pasos**:
   - Abrir el selector de niveles (`level_select_menu.tscn`).
   - Seleccionar el botón del "Nivel 7".
   - Confirmar que el HUD carga con las 8 cartas disponibles: Harry, Caja de Snitch, Ron, Recordadora, Protego, Escoba, Hermione y Accio.
   - Superar todas las oleadas compuestas por Alumnos Slytherin, Dracos, Alumnos con Protego y Prefectos Slytherin.
   - Al derrotar al último enemigo, verificar la visualización del panel de victoria y comprobar que el Nivel 8 queda desbloqueado en el Mapa del Merodeador.
