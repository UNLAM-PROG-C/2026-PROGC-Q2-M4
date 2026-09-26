# Checklist técnica: colisiones físicas y economía

## Colisiones físicas

- [ ] Definir los nombres canónicos de los grupos. La solicitud usa `magos`, `mortifagos` y `hechizos`, mientras [`AGENTS.md`](../../../AGENTS.md) reserva `aliados`, `enemigos` y `hechizos`.
- [ ] Definir la matriz de interacción entre grupos:
  - [ ] `magos`/`aliados` con `mortifagos`/`enemigos`: contacto físico, ataque o ambos.
  - [ ] `hechizos` con `mortifagos`/`enemigos`: impacto y aplicación de daño.
  - [ ] `hechizos` con `magos`/`aliados`: confirmar si debe ignorarse.
  - [ ] `magos`/`aliados` con `magos`/`aliados`: confirmar si bloquean la misma celda.
  - [ ] `mortifagos`/`enemigos` con `mortifagos`/`enemigos`: confirmar si pueden atravesarse o bloquearse.
- [ ] Definir capas y máscaras de colisión para cada interacción aprobada.
- [ ] Confirmar que las líneas deshabilitadas no permitan plantación, spawneo, avance ni colisiones jugables.
- [ ] Mantener la detección por `Area2D` y Grupos, sin comparar nombres de nodos.

## Economía y Snitches

- [x] Definir el saldo inicial: 150 Snitches.
- [x] Definir el costo de Harry: 100 Snitches.
- [x] Definir el costo de la Caja de Snitch: 50 Snitches.
- [x] Definir la generación de la Caja de Snitch: 25 Snitches cada 25 segundos.
- [ ] Definir si los Snitches generados aparecen como objetos físicos que requieren clic o si se acreditan automáticamente al saldo.
- [ ] Si requieren clic, definir qué ocurre cuando el jugador no hace clic:
  - [ ] Permanecen indefinidamente.
  - [ ] Desaparecen después de un tiempo determinado.
  - [ ] Se desplazan o caen fuera de la zona recogible.
  - [ ] Se acreditan automáticamente después de un tiempo.
- [ ] Definir el tiempo exacto de permanencia o caída de un Snitch no recogido.
- [ ] Definir si existe un límite de Snitches simultáneos en pantalla.
- [ ] Definir el `Area2D` y el Grupo de recogida para los Snitches físicos.
- [ ] Definir si recoger un Snitch requiere clic sobre el objeto, clic dentro de un `Area2D` o interacción global del jugador.
- [ ] Definir el comportamiento cuando el saldo alcanza un límite máximo, si existe.

## Resultado de la auditoría

- El spec define costos, saldo inicial y generación periódica, pero no define Snitches físicos recogibles ni su comportamiento ante falta de clic.
- El spec exige usar Grupos, pero no define una matriz de colisiones ni nombres concretos para `magos` y `mortifagos`.
- No existe todavía un plan técnico que pueda marcar estos puntos como resueltos.
