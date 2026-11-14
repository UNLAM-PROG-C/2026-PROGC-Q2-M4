# Quickstart & Validation Guide: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Feature Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]` | **Date**: 2026-10-07

## Prerrequisitos

- Motor: Godot 4.x instalado (ejecutable: `C:\Users\polol\Desktop\Godot_v4.7.2-stable_win64.exe`).
- Directorio del proyecto: `c:\Users\polol\Documents\GitHub\2026-PROGC-Q2-M4\TP-Integrador\HogwartsvsMortifagos`.
- Presencia del asset `Images/mcgonagall.png` (130x130 con transparencia).

---

## Escenario de Validación 1: Fuego en Ráfaga de McGonagall

**Objetivo**: Probar que McGonagall ejecuta ráfagas de 4 disparos a 0.15s de separación y respeta el tiempo de recarga base de 1.5s.

### Pasos de ejecución
1. Ejecutar el proyecto y cargar el Nivel 8 (o escena de prueba con McGonagall).
2. Acumular 200 snitches y seleccionar la carta `McGonagall (200)`.
3. Plantar a McGonagall en una fila activa donde avance un enemigo blindado (ej. Draco o Alumno con Protego).
4. Observar el comportamiento de disparo:
   - Al entrar el enemigo en línea recta, McGonagall dispara en ráfaga rápida de 4 proyectiles.
   - Los 4 proyectiles se emiten sucesivamente en ~0.6 segundos totales (separación de ~0.15s).
   - Al terminar el 4° disparo, transcurren 1.5 segundos de pausa antes de la siguiente ráfaga.
5. Observar el impacto en el enemigo:
   - Los 4 proyectiles impactan de forma sucesiva aplicando 20 de daño cada uno (80 total).
   - El escudo de Protego o el cono de Draco se deteriora velozmente bajo el fuego concentrado.

---

## Escenario de Validación 2: Cancelación Limpia al Ser Derrotada

**Objetivo**: Verificar que si McGonagall es derrotada a mitad de una ráfaga, no deja temporizadores huérfanos ni genera errores en consola.

### Pasos de ejecución
1. Plantar a McGonagall cerca del frente ante un atacante cuerpo a cuerpo o recibir daño letal de un Prefecto.
2. Permitir que la salud de McGonagall llegue a 0 justo al comenzar a disparar su ráfaga.
3. Verificar que la entidad se libera del árbol (`queue_free()`) y que los disparos pendientes de esa ráfaga se cancelan de inmediato.
4. Confirmar que la consola de Godot no arroja errores de tipo `Invalid call` o `null instance`.

---

## Escenario de Validación 3: Las 3 Grandes Oleadas del Nivel 8

**Objetivo**: Probar que el nivel ejecuta las 2 oleadas intermedias y la Oleada Final en los momentos exactos.

### Pasos de ejecución
1. Iniciar el Nivel 8 (`res://level_8.tscn`).
2. Defender las 5 filas y observar la progresión de bajas:
   - Al alcanzar ~15 bajas (33% de 45), aparece el banner `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` y se desata la primera Gran Oleada multilínea.
   - Tras limpiar la primera oleada y llegar a ~30 bajas (66% de 45), aparece nuevamente `"¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"` y se desata la segunda Gran Oleada.
   - Al agotar los 45 enemigos regulares y limpiar el jardín, aparece el banner `"¡OLEADA FINAL!"` y desembarca la oleada de máxima densidad con Dracos, Alumnos con Protego y Prefectos.

---

## Escenario de Validación 4: Victoria y Desbloqueo del Nivel 9

**Objetivo**: Comprobar que limpiar la Oleada Final otorga la victoria y desbloquea el siguiente nivel.

### Pasos de ejecución
1. Derrotar a todos los enemigos de la tercera oleada.
2. Verificar que se despliega el panel de victoria (`LevelEndPanel`) con el mensaje confirmando el desbloqueo del Nivel 9 en el Mapa del Merodeador.
3. Presionar "Volver al Mapa" y verificar que el Nivel 9 aparece habilitado para jugar.
