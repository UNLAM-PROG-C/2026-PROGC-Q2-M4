# Checklist técnica: colisiones físicas y economía

## Colisiones físicas

- [x] Definir los nombres canónicos de los grupos: se utilizan `aliados`, `enemigos`, `hechizos` y `dementores` según [`AGENTS.md`](../../../AGENTS.md).
- [x] Definir la matriz de interacción entre grupos:
  - [x] `aliados` con `enemigos`: los enemigos detectan aliados mediante `AreaDeteccion` (Capa 1) y aplican daño continuo cuerpo a cuerpo.
  - [x] `hechizos` con `enemigos`: impacto con Capa 2 y aplicación de 20 de daño inmediato.
  - [x] `hechizos` con `aliados`: ignorado por máscara de colisión física y filtro de grupo.
  - [x] `aliados` con `aliados`: impiden la superposición bloqueando la misma celda mediante `celdas_ocupadas`.
  - [x] `enemigos` con `enemigos`: se desplazan en paralelo/superposición según el diseño de carriles tipo PvZ.
- [x] Definir capas y máscaras de colisión:
  - Capa 1: `aliados`
  - Capa 2: `enemigos`
  - Capa 3: `hechizos`
  - Capa 4: `snitches`
- [x] Confirmar que las líneas deshabilitadas no permitan plantación, spawneo, avance ni colisiones jugables (`FILA_ACTIVA = 4`).
- [x] Mantener la detección por `Area2D`, capas/máscaras y Grupos, sin comparar nombres de nodos.

## Economía y Snitches

- [x] Definir el saldo inicial: 150 Snitches.
- [x] Definir el costo de Harry: 100 Snitches.
- [x] Definir el costo de la Caja de Snitch: 50 Snitches.
- [x] Definir la generación de la Caja de Snitch: 25 Snitches cada 10 segundos.
- [x] Definir si los Snitches generados aparecen como objetos físicos: Sí, la Caja de Snitch expulsa una Snitch física con animación de pop hacia arriba.
- [x] Definir comportamiento ante falta de clic: desaparece automáticamente al agotarse su tiempo de vida (10.0 segundos).
- [x] Definir el tiempo exacto de permanencia: 10.0 segundos.
- [x] Definir interacción de recogida: clic del ratón mediante `input_event` y eventos de ratón (`input_pickable = true`).
- [x] Definir el `Area2D` y la capa de colisión: `Area2D` en Capa 4 (`collision_layer = 8`).
- [x] Snitches ambientales del cielo: caen cada 10 segundos en zigzag y otorgan 25 Snitches al recogerse con clic.

## Menú interactivo y progresión

- [x] Menú interactivo de fin de partida (`PanelFinNivel`) para estados de Victoria y Derrota.
- [x] Botones de navegación: "Siguiente Nivel", "Volver al Mapa" y "Reintentar".
- [x] Desbloqueo del Nivel 2 en el Mapa del Merodeador al ganar el Nivel 1 (`MenuNiveles.progreso_desbloqueado = 2`).

## Resultado de la auditoría

- Todos los puntos técnicos de colisiones, economía física por clic y navegación interactiva han sido completamente especificados, implementados y validados.
- La feature 001-nivel-1-jardin queda cerrada y lista para producción.
