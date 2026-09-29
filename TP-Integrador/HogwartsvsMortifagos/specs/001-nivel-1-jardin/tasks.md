# Tareas de Implementación: 001-nivel-1-jardin

**Feature**: Nivel 1 - Defensa de una línea
**Ruta del Feature**: `specs/001-nivel-1-jardin`
**Estado general**: Completado y Auditado

---

## Fase 1: Grilla y Arquitectura Base (HU-01)

- [x] **T01-01**: Configurar la grilla de una sola línea activa en `nivel_principal.gd` (`FILA_ACTIVA = 4`, celda horizontal Y=4).
- [x] **T01-02**: Deshabilitar el spawneo y plantación en las filas no activas (filas 2, 3, 5 y 6).
- [x] **T01-03**: Implementar bloqueo visual para filas inactivas mediante `ColorRect` semi-transparentes en `NivelPrincipal.tscn` (placeholder hasta diseño de sprites).
- [x] **T01-04**: Inicializar el saldo en 150 Snitches y reflejarlo en el HUD (`LabelSnitches`).

---

## Fase 2: Aliados y Proyectiles (HU-02)

- [x] **T02-01**: Crear escena `harry.tscn` con `Area2D` raíz, `CollisionShape2D`, `Sprite2D`, `PuntoDisparo` y `TimerDisparo`.
- [x] **T02-02**: Crear script `harry.gd` con tipado estático estricto, coste de 100 Snitches y temporizador de disparo a 1.5s.
- [x] **T02-03**: Implementar detección horizontal de enemigos en `_hay_enemigo_en_linea()` antes de disparar.
- [x] **T02-04**: Crear escena `Proyectil.tscn` con `Area2D` raíz, capa de colisión 3 (`collision_layer = 4`), máscara de enemigos (`collision_mask = 2`) y `VisibleOnScreenNotifier2D`.
- [x] **T02-05**: Implementar desplazamiento hacia la derecha a 400 px/s e impacto de 20 de daño sobre enemigos en `Proyectil.gd`.

---

## Fase 3: Economía y Caja de Snitch (HU-03)

- [x] **T03-01**: Crear escena `caja_snitch.tscn` con `Area2D` raíz, coste de 50 Snitches y temporizador a 10.0s.
- [x] **T03-02**: Implementar script `caja_snitch.gd` con señal `snitch_soltada(snitch_instancia: Snitch)`.
- [x] **T03-03**: Crear escena `snitch.tscn` y script `snitch.gd` con soporte de recolección manual por clic (`input_event`, `_unhandled_input`, `input_pickable = true`).
- [x] **T03-04**: Configurar capa de colisión 4 (`collision_layer = 8`) para Snitches físicas.
- [x] **T03-05**: Implementar método `configurar_de_caja(pos_origen: Vector2)` en `snitch.gd` con animación de pop hacia arriba y caída suave al suelo.
- [x] **T03-06**: Conectar `snitch_soltada` en `nivel_principal.gd` para instanciar en escena y conectar señal `recogida(valor)`.
- [x] **T03-07**: Implementar tiempo de vida (10s) para que la Snitch desaparezca automáticamente si el jugador no la recoge.
- [x] **T03-08**: Mantener Snitches ambientales del cielo que caen cada 10s en zigzag y se recogen por clic.

---

## Fase 4: Enemigos y Combate (HU-04)

- [x] **T04-01**: Crear escena `alumno_slytherin.tscn` con `Area2D` raíz (Capa 2: `collision_layer = 2`), `AreaDeteccion` (detecta Capa 1: `collision_mask = 1`) y 200 HP.
- [x] **T04-02**: Implementar script `alumno_slytherin.gd` con velocidad de 32 px/s (4s por baldosa de 128px), ataque continuo cuerpo a cuerpo a aliados y señales `derrotado` e `invasion_jardin`.
- [x] **T04-03**: Configurar generación de Alumno Slytherin desde `Spawners/Marker2D3` cada 15 segundos en `NivelPrincipal.tscn`.
- [x] **T04-04**: Configurar Dementores de respaldo en el extremo izquierdo del jardín para limpiar la fila si un enemigo sobrepasa la defensa.

---

## Fase 5: Menú Interactivo de Fin de Partida y Progresión (HU-05)

- [x] **T05-01**: Diseñar `PanelFinNivel` modal en `NivelPrincipal.tscn` con estilo pergamino (`#e4cd9f` y `#3c2415`).
- [x] **T05-02**: Conectar botones interactivos: "Siguiente Nivel", "Volver al Mapa" y "Reintentar".
- [x] **T05-03**: Implementar actualización de progresión a Nivel 2 en `MenuNiveles.progreso_desbloqueado` al ganar el nivel.
- [x] **T05-04**: Conectar navegación fluida entre `NivelPrincipal.tscn` y `menu_niveles.tscn`.

---

## Fase 6: Cierre de Trazabilidad y Calidad

- [x] **T06-01**: Actualizar especificación técnica en `specs/001-nivel-1-jardin/spec.md`.
- [x] **T06-02**: Actualizar plan de desarrollo en `specs/001-nivel-1-jardin/plan.md`.
- [x] **T06-03**: Cerrar y validar checklist técnica en `specs/001-nivel-1-jardin/checklists/technical.md`.
