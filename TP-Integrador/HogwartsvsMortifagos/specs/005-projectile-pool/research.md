# Research: Projectile Object Pool

## Decisión 1: Pool de objetos en el hilo principal

**Decision**: Implementar un pool de instancias de `Projectile` administrado por un nodo del nivel. No se utilizará `WorkerThreadPool` para crear, activar, mover, colisionar, ocultar o devolver nodos.

**Rationale**: Godot exige que las operaciones sobre el Scene Tree y los nodos se realicen desde el hilo principal. El objetivo de esta funcionalidad es reducir la creación y destrucción repetidas, no paralelizar la manipulación de nodos. Los cálculos auxiliares futuros podrían ejecutarse fuera del hilo principal, pero sus resultados deberán aplicarse mediante el hilo principal.

**Alternatives considered**:
- `WorkerThreadPool` para administrar proyectiles: rechazado porque introduciría acceso inseguro al Scene Tree y no aporta valor a la detección de colisiones.
- Pool global persistente entre niveles: rechazado en la primera versión porque podría conservar referencias a nodos liberados al cambiar de escena.

## Decisión 2: Propietario ligado al nivel

**Decision**: Cada nivel será propietario del pool durante su ciclo de vida. El pool se ubicará bajo el nivel o su contenedor de entidades y limpiará sus proyectiles al salir o reiniciar el nivel.

**Rationale**: `level.gd` ya administra la creación de aliados, enemigos, Snitches y Dementores, y dispone de un contenedor `Entities`. Asociar el pool al nivel evita referencias inválidas y permite que el cambio de escena libere todo el estado junto con el nivel.

**Alternatives considered**:
- Autoload global: rechazado porque no es necesario y ampliaría el alcance de la funcionalidad.
- Pool creado por cada Harry: rechazado porque duplicaría la administración si existieran varios aliados capaces de disparar.

## Decisión 3: Precalentamiento y crecimiento

**Decision**: Crear 50 proyectiles durante la inicialización del pool. Si no hay proyectiles disponibles, agregar exactamente 10 instancias antes de atender la solicitud.

**Rationale**: Cumple la especificación, limita las asignaciones durante el inicio de una oleada y hace medible el crecimiento. La búsqueda siempre debe revisar primero la colección de disponibles.

**Alternatives considered**:
- Crear proyectiles bajo demanda desde cero: rechazado porque conserva el problema actual.
- Reservar una cantidad ilimitada: rechazado porque puede producir crecimiento accidental de memoria.

## Decisión 4: Estado explícito e idempotencia

**Decision**: Cada proyectil tendrá un estado activo/inactivo y una operación única de devolución. Activar reiniciará posición, frame, tiempo de animación, velocidad y estado de impacto. Devolver deshabilitará visibilidad y colisiones, y será segura si llegan simultáneamente las señales de impacto y salida de pantalla.

**Rationale**: El proyectil actual conserva `_has_hit` y `_animation_elapsed`; ambos deben reiniciarse para evitar estado residual. Ocultar un `Area2D` no basta para impedir colisiones, por lo que la detección también se desactivará o el nodo se retirará temporalmente del árbol según el diseño final.

**Alternatives considered**:
- Destruir y volver a instanciar: rechazado porque contradice el objetivo del pool.
- Conectar señales en cada activación: rechazado porque puede producir conexiones duplicadas.

## Decisión 5: Mantener la explosión de impacto fuera del pool

**Decision**: La mini explosión continuará siendo una instancia efímera independiente en esta iteración.

**Rationale**: La solicitud se limita al pool de proyectiles. Reutilizar también las explosiones requeriría otra política de ciclo de vida y podría mezclar dos optimizaciones distintas. Se conservará el comportamiento visual existente.

**Alternatives considered**:
- Crear un segundo pool para explosiones: queda como optimización futura, fuera del alcance actual.

## Patrones existentes relevantes

- `level_select_menu.gd` ya mantiene objetos disponibles, los reactiva, reinicia sus transformaciones y los devuelve sin destruirlos. Ese patrón será la referencia de organización.
- `harry.gd` actualmente llama a `projectile_scene.instantiate()` por disparo; será el punto de integración principal.
- `projectile.gd` usa `Area2D`, grupo `spells`, señales `area_entered` y `screen_exited`, y una animación de cuatro cuadros. Esas reglas deben permanecer.

## Riesgos y mitigaciones

- Estado residual: reinicializar todos los campos de movimiento, impacto y animación en cada activación.
- Doble devolución: proteger la operación con el estado activo y retirar el proyectil de activos antes de añadirlo a disponibles.
- Colisiones invisibles: deshabilitar explícitamente la detección o retirar el nodo del árbol mientras está inactivo.
- Referencias inválidas al cambiar de nivel: mantener el pool bajo el nivel y limpiar activos antes de su liberación.
- Crecimiento no controlado: centralizar la ampliación en el pool y dejar documentado el rechazo controlado si una ampliación no puede completarse.
