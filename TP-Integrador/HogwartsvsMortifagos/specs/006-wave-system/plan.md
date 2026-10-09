# Implementation Plan: Sistema de Oleadas Mágicas

**Branch**: `006-wave-system` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

## Summary

Se reemplazará el spawn lineal basado únicamente en `EnemySpawnTimer` por un director de oleadas ligado a cada nivel. El hilo principal conservará la física, las señales, la instanciación y el Scene Tree; una tarea de cálculo concurrente recibirá una instantánea tipada, calculará el siguiente `WavePlan` y entregará el resultado mediante una cola protegida por `Mutex`. El nivel aplicará el resultado en su ciclo principal y cancelará cualquier cálculo pendiente al finalizar o cambiar de escena.

## Technical Context

**Language/Version**: GDScript de Godot 4.7.2, con tipado estático estricto

**Primary Dependencies**: APIs integradas de Godot (`Thread`, `Mutex`, `Semaphore`, señales y `call_deferred`); no se agregan dependencias externas

**Storage**: N/A; el estado de la oleada vive durante la escena del nivel

**Testing**: Validación con Godot `--check-only`, ejecución headless cuando sea posible y pruebas manuales repetibles de niveles 1–3; no existe framework de tests del juego actualmente

**Target Platform**: Escritorio, Godot 4.7.2, renderizador Compatibility, resolución objetivo 1920x1080

**Project Type**: Videojuego 2D basado en escenas y nodos

**Performance Goals**: Mantener el procesamiento del hilo principal en 60 FPS durante la planificación; el cálculo concurrente debe trabajar solo con datos simples y no bloquear el Scene Tree

**Constraints**: No modificar nodos desde el hilo secundario; no leer nodos, grupos o propiedades del Scene Tree desde ese hilo; cancelar y unir el hilo antes de liberar el nivel; no modificar `project.godot`, resolución, renderizador ni instalar addons

**Scale/Scope**: Primera integración en niveles 1–3 existentes, con soporte de configuración para niveles futuros; cuotas actuales de hasta 20 enemigos regulares y oleadas especiales de 10–20 enemigos

## Constitution Check

*GATE: Must pass before Phase 0 research and after Phase 1 design.*

- **Godot 4 y tipado estricto**: PASS. Las nuevas escenas y scripts seguirán GDScript tipado.
- **Nodos y escenas**: PASS. El director será un nodo de la escena del nivel y las entidades continuarán siendo escenas propias.
- **Identificadores en inglés y textos visibles en español**: PASS. Los nombres técnicos usarán `WaveDirector`, `WavePlan`, `EnemyBudget`, etc.; la HUD seguirá en español.
- **Señales tipadas entre nodos**: PASS. Las notificaciones de enemigos y las órdenes aplicadas al nivel tendrán parámetros tipados.
- **Colisiones y grupos**: PASS. El director no reemplaza las colisiones; el nivel seguirá conectando `Enemy.defeated` y consultando categorías existentes.
- **Seguridad del Scene Tree**: PASS. El hilo secundario producirá datos simples o copias; solo el hilo principal instanciará, agregará, moverá o liberará nodos.
- **Restricciones del proyecto**: PASS. No se requieren cambios de configuración ni dependencias externas.

## Research Summary

Las decisiones y alternativas están documentadas en [research.md](./research.md). Se eligió una tarea de decisión acotada por evento con una cola de resultados protegida, en lugar de un hilo que consulte nodos continuamente o de instanciar enemigos desde el trabajador.

## Project Structure

### Documentation

```text
specs/006-wave-system/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md              # se generará con /speckit-tasks
```

### Source Code

```text
HogwartsvsMortifagos/
├── level.gd                         # integración y aplicación en hilo principal
├── level_1.tscn
├── level_2.tscn
├── level_3.tscn                     # configuración del director por nivel
├── enemy.gd                         # señales existentes de derrota/invasión
├── wave_director.gd                 # cálculo concurrente y sincronización
├── wave_plan.gd                     # datos del plan de oleada
├── wave_state.gd                    # estados y transiciones válidas
└── wave_director.tscn               # nodo reutilizable, si la implementación lo requiere
```

**Structure Decision**: Se mantiene la estructura plana existente del proyecto Godot, con un script por responsabilidad y escenas reutilizables. La primera implementación puede usar `WaveDirector` como hijo de `Level`; si se necesita configuración visual o conexiones persistentes, se extraerá a `wave_director.tscn` sin convertirlo en Autoload.

## Implementation Phases

### Phase 0: Research

1. Confirmar ciclo de vida y límites de `Thread`, `Mutex` y `Semaphore` en Godot 4.7.2.
2. Confirmar el patrón seguro para entregar resultados desde un cálculo concurrente al hilo principal.
3. Revisar el conteo actual de enemigos generados y derrotados para separar cuota regular, enemigos activos y oleadas especiales.
4. Definir la política de cancelación, espera y limpieza al cambiar, reiniciar, ganar o perder un nivel.

### Phase 1: Design

1. Crear las entidades tipadas de [data-model.md](./data-model.md).
2. Implementar la máquina de estados y validar sus transiciones antes de conectarla a la escena.
3. Integrar el director con `Level`, manteniendo `EnemySpawnTimer` como tick del hilo principal o reemplazándolo solo cuando la lógica equivalente esté cubierta.
4. Configurar niveles 1–3 sin alterar rutas, filas ni escenas de enemigos existentes.
5. Validar la ejecución concurrente, la cancelación y la ausencia de operaciones del Scene Tree fuera del hilo principal.

## Complexity Tracking

No hay violaciones constitucionales que requieran justificar complejidad adicional. La sincronización concurrente es necesaria por el requisito académico y queda aislada en un componente de datos, mientras que la creación real de nodos permanece en `Level`.
