# Research: Sistema de Oleadas Mágicas

## Decision 1: Tarea de cálculo acotada por decisión

**Decision**: El director ejecutará cálculos de planificación sobre una instantánea de datos y finalizará cada tarea cuando produzca un `WavePlan`. El nivel podrá reutilizar un `Thread` controlado por ciclo de vida o el mecanismo de trabajo equivalente de Godot, pero la tarea no tendrá acceso a nodos.

**Rationale**: El sistema necesita demostrar comunicación y sincronización entre hilos, pero no necesita un hilo consumidor que consulte continuamente el Scene Tree. Una tarea acotada reduce el riesgo de fugas, facilita la cancelación y permite comprobar que el trabajo concurrente es determinista respecto de su entrada.

**Alternatives considered**:

- **Hilo persistente que inspecciona nodos**: rechazado porque leer nodos, grupos o propiedades del árbol desde el hilo secundario rompe la separación de responsabilidades.
- **`WorkerThreadPool` para instanciar enemigos**: rechazado porque la creación, configuración y liberación de nodos debe ocurrir en el hilo principal.
- **Sin concurrencia, solo señales entre nodos**: rechazado porque no demuestra el requisito académico de comunicación entre hilos.

## Decision 2: Instantánea de datos simples

**Decision**: `Level` construirá un `BoardSnapshot` con enteros, flotantes, booleanos y arreglos de valores simples antes de solicitar el cálculo. El snapshot incluirá estado de oleada, enemigos regulares derrotados, cuota total, enemigos activos, valor defensivo y un identificador de generación del nivel.

**Rationale**: Una copia cerrada evita que el hilo secundario retenga referencias a `Node`, `Resource`, `PackedScene`, señales o colecciones mutables del juego. También hace reproducible la fórmula de dificultad.

**Alternatives considered**:

- **Pasar el nodo `Level` al trabajador**: rechazado por acceso inseguro al Scene Tree.
- **Compartir directamente los contadores del nivel**: rechazado porque introduce carreras de datos y hace difícil cancelar resultados viejos.

## Decision 3: Mutex para estado y cola de resultados

**Decision**: El director protegerá con `Mutex` la solicitud vigente, la generación del nivel, la bandera de cancelación y la cola de `WaveResult`. El hilo principal tomará los resultados bajo bloqueo breve, liberará el mutex y aplicará la orden fuera de la sección crítica.

**Rationale**: El bloqueo queda limitado a copiar estructuras pequeñas. La instanciación y las señales no ocurren bajo el mutex, evitando pausas largas y reentrancia.

**Alternatives considered**:

- **Emitir señales directamente desde el hilo trabajador**: rechazado como mecanismo principal porque una cola consumida por el hilo principal hace explícita la seguridad del receptor.
- **Esperar al trabajador desde `_process`**: rechazado porque puede congelar el juego durante cálculos o cancelaciones.

## Decision 4: Estado de enemigos basado en señales existentes

**Decision**: El nivel seguirá conectando `Enemy.defeated` y `Enemy.garden_invaded`. El contador de activos se actualizará en el hilo principal al instanciar y al recibir derrota; los Dementores y entidades que no pertenezcan a la cuota regular no se incluirán en `EnemyBudget` salvo configuración explícita.

**Rationale**: El proyecto ya utiliza señales tipadas y evita consultar el árbol para contar entidades. La lógica actual de `Level` tiene `_spawned_enemies`, `_defeated_enemies` y `total_enemies`; el diseño agregará contadores de oleada sin invalidar esas señales.

**Alternatives considered**:

- **Contar enemigos con `get_tree().get_nodes_in_group()` desde el director**: rechazado por acceso al Scene Tree y por mezclar enemigos regulares con entidades especiales.
- **Usar únicamente el número generado para detectar tablero vacío**: rechazado porque no representa enemigos todavía vivos.

## Decision 5: Cancelación por generación de nivel

**Decision**: Cada nivel tendrá un `level_generation` monotónico. Al iniciar, reiniciar, ganar o perder, el nivel marcará cancelación y detendrá el director. Un resultado solo se aplicará si su generación coincide con la actual y el nivel sigue activo; luego se hará `wait_to_finish()` en una fase de limpieza que no bloquee el ciclo de juego normal.

**Rationale**: Evita que una orden calculada para una escena anterior instancie enemigos después de un cambio de nivel. La generación es más robusta que comprobar únicamente `is_instance_valid`, porque un nodo válido puede pertenecer a una ejecución anterior.

**Alternatives considered**:

- **Descartar solo por referencia al nodo**: rechazado porque no distingue reinicios de la misma escena.
- **Liberar el director sin esperar al hilo**: rechazado por riesgo de carrera y acceso a memoria liberada.

## Decision 6: Fórmulas de oleadas configurables

**Decision**: La configuración de umbrales, mínimo/máximo intermedio, mínimo final y bonificación final será exportable en `Level` o en un recurso de configuración, con valores por defecto para niveles estándar y especiales. La fórmula intermedia clampa a 10–20; la final usa como mínimo `max(25, intermediate + random_bonus)`.

**Rationale**: Permite integrar primero niveles 1–3 y preparar niveles futuros sin duplicar lógica. El cálculo recibe números, no aliados ni nodos.

**Alternatives considered**:

- **Valores codificados por nivel en el director**: rechazado por números mágicos y baja capacidad de balance.
- **Una fórmula distinta por escena sin componente común**: rechazado porque duplicaría estados y reglas.

## Integration Findings

- Godot está en versión `4.7.2.stable`.
- `Level/Entities/ProjectilePool` ya existe y debe permanecer independiente del director.
- `Level/EnemySpawnTimer` tiene `wait_time = 15.0`, `autostart = true` y está conectado a `_on_enemy_spawn_timer_timeout`.
- El spawn actual instancia una escena desde `enemy_scenes`, la agrega a `Entities`, incrementa `_spawned_enemies` y conecta `defeated` y `garden_invaded`.
- Las escenas actuales jugables son `level_1.tscn`, `level_2.tscn` y `level_3.tscn`; el alcance inicial se limita a ellas.
- No se identificó un framework de tests del juego; la validación deberá combinar `--check-only`, ejecución headless y casos manuales.
