# Implementation Plan: Projectile Object Pool

**Branch**: `005-projectile-pool` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-projectile-pool/spec.md`

## Summary

Se reemplazará la creación y destrucción de cada proyectil por un pool de objetos reutilizables asociado al nivel. El pool precalentará 50 proyectiles, reutilizará primero los inactivos y agregará lotes de 10 cuando todos estén ocupados. Cada proyectil tendrá un ciclo de activación, impacto o salida de pantalla y devolución idempotente al pool, conservando el daño, la animación y las colisiones actuales. El pool y los nodos se administrarán exclusivamente desde el hilo principal; no se usará `WorkerThreadPool` para modificar el Scene Tree.

## Technical Context

**Language/Version**: GDScript con tipado estático estricto, Godot 4.7.2

**Primary Dependencies**: Godot 4, `PackedScene`, `Area2D`, señales de colisión y `VisibleOnScreenNotifier2D`; sin dependencias externas

**Storage**: N/A; el estado del pool vive durante el ciclo de vida del nivel

**Testing**: Validación de scripts Godot, ejecución de niveles 1 a 3 y pruebas manuales/automatizadas del ciclo de vida del pool según [quickstart.md](./quickstart.md)

**Target Platform**: Juego 2D de escritorio, renderizador Compatibility, resolución objetivo 1920x1080

**Project Type**: Juego 2D basado estrictamente en Nodos y Escenas

**Performance Goals**: Sostener oleadas de al menos 100 disparos consecutivos sin crear una instancia nueva por cada impacto o salida de pantalla; mantener el comportamiento de juego a 60 FPS cuando sea posible

**Constraints**: Capacidad inicial de 50, crecimiento en lotes de 10, sin `queue_free()` durante el uso normal de proyectiles, sin acceso concurrente al Scene Tree y sin modificar la resolución, el renderizador o dependencias del proyecto

**Scale/Scope**: Proyectiles disparados por Harry en los niveles existentes; pool asociado a cada nivel y destruido junto con él; la explosión visual de impacto queda fuera del pool en esta primera iteración

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Motor y lenguaje**: PASS. El diseño usa Godot 4 y GDScript estrictamente tipado.
- **II. Nodos y Escenas**: PASS. El pool será un nodo del nivel y reutilizará instancias de la escena existente `projectile.tscn`; no se crea una arquitectura global monolítica.
- **III. Vocabulario e idioma**: PASS. Los identificadores nuevos estarán en inglés (`ProjectilePool`, `ReusableProjectile`, `active_projectiles`, `available_projectiles`); los textos visibles no cambian.
- **IV. Áreas y grupos**: PASS. Se conservan `Area2D`, señales, grupo `spells`, capa 4 y máscara de enemigos. No se identificarán entidades por nombre.
- **V. Estado del motor**: PASS para esta fase documental. No se modifica el Scene Tree durante la planificación; la implementación deberá validar la escena real antes de aplicar cambios estructurales.

No hay violaciones que requieran Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/005-projectile-pool/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/
│   └── requirements.md
└── tasks.md                 # Se generará con /speckit-tasks
```

No se crea `contracts/`: esta funcionalidad es interna al juego y no expone APIs externas, endpoints ni formatos de intercambio con otros sistemas.

### Source Code (repository root)

```text
TP-Integrador/HogwartsvsMortifagos/
├── harry.gd                 # Solicita proyectiles al pool
├── harry.tscn               # Conserva la referencia a projectile_scene
├── projectile.gd            # Ciclo de activación, impacto y devolución
├── projectile.tscn           # Escena reutilizable y sus colisiones
├── level.gd                 # Propietario del pool y limpieza del nivel
├── level_1.tscn
├── level_2.tscn
├── level_3.tscn
└── level_select_menu.gd     # Patrón existente de reutilización para Footprint
```

**Structure Decision**: Se mantiene la estructura plana y basada en escenas del proyecto. El administrador del pool se incorporará como nodo hijo de cada nivel, con un script propio si la implementación lo requiere; Harry solicitará instancias al administrador en lugar de instanciarlas directamente.

## Complexity Tracking

No aplica: el diseño respeta la arquitectura existente y no agrega dependencias, servicios globales ni procesos secundarios para manipular nodos.
