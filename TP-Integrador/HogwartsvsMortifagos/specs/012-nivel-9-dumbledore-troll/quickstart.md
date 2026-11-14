# Quickstart & Validation Guide: Nivel 9 - Dumbledore y el Troll Colosal

**Feature Branch**: `[012-nivel-9-dumbledore-troll]` | **Date**: 2026-10-08

## Prerrequisitos

- Motor: Godot 4.x instalado.
- Directorio del proyecto: `c:\Users\polol\Documents\GitHub\2026-PROGC-Q2-M4\TP-Integrador\HogwartsvsMortifagos`.
- Presencia de assets en `Images/`:
  - `Images/dumbledore.png`
  - `Images/dumbledore_shot.png`
  - Sprites del Troll (`troll_body.png`, `troll_right_arm.png`, etc.)
- Presencia de la escena `troll.tscn`.

---

## Escenario de Validación 1: Daño en Área 3x3 de Dumbledore

**Objetivo**: Probar que Dumbledore dispara en línea recta y su proyectil explota en un área de 3x3 celdas infligiendo 20 de daño a todos los enemigos alcanzados.

### Pasos de ejecución
1. Iniciar la escena del Nivel 9 (o escena de prueba con Dumbledore).
2. Acumular 300 snitches y plantar a Dumbledore en la fila central (Fila 4).
3. Spawnear o esperar el avance de enemigos agrupados en las filas 3, 4 y 5.
4. Observar el proyectil de Dumbledore:
   - Avanza en línea recta horizontal (eje X) sin caída ni parábola.
   - Al impactar al primer enemigo o escudo en la fila 4, detona de inmediato.
   - Los enemigos de la fila 4 (impacto directo), fila 3 (arriba) y fila 5 (abajo) dentro del radio de 3x3 celdas reciben simultáneamente 20 puntos de daño.
   - El proyectil se destruye inmediatamente tras el estallido.

---

## Escenario de Validación 2: Marcha del Troll, Pausa de Golpe e Instakill

**Objetivo**: Verificar que el Troll camina con la animación `"Walk"`, se detiene brevemente al encontrar un aliado para reproducir `"attack"`, lo destruye de un golpe (instakill 9999 HP) y reanuda su marcha.

### Pasos de ejecución
1. Plantar un Protego (alta salud) y un Harry detrás en una fila activa.
2. Hacer avanzar al Troll en esa misma fila.
3. Observar la marcha: avanza hacia la izquierda reproduciendo la animación `"Walk"`.
4. Al entrar en contacto con el Protego:
   - El Troll frena su traslación horizontal.
   - Reproduce la animación `"attack"` del `AnimationPlayer`.
   - El Protego es aplastado y destruido inmediatamente.
   - Concluido el golpe, el Troll reanuda su animación `"Walk"` y vuelve a avanzar.
5. Al llegar hasta Harry, repite el aplastamiento y continúa hacia el extremo izquierdo.

---

## Escenario de Validación 3: Resistencia del Troll a 2 Ataques de Daño Masivo

**Objetivo**: Confirmar que la salud máxima del Troll (3600 HP) resiste exactamente 1 ataque de daño masivo de 1800 HP y muere con el segundo.

### Pasos de ejecución
1. Hacer avanzar a un Troll en un carril despejado.
2. Activar una Escoba en ese carril (1800 de daño masivo) o detonar una Recordadora a su paso:
   - El Troll recibe 1800 de daño; su salud baja al 50% (1800 HP restantes).
   - El Troll sobrevive y sigue avanzando.
3. Activar una segunda Escoba o detonar una segunda Recordadora sobre el mismo Troll:
   - Recibe los 1800 puntos de daño restantes (3600 HP acumulados).
   - El Troll muere de forma instantánea y limpia, emitiendo la señal `defeated`.

---

## Escenario de Validación 4: Partida Completa del Nivel 9 y Desbloqueo del Nivel 10

**Objetivo**: Validar el ensamblado general del Nivel 9 con las 10 cartas en el HUD y el desbloqueo del nivel final.

### Pasos de ejecución
1. Iniciar `level_9.tscn` desde el selector de niveles.
2. Comprobar que el HUD muestra las 10 cartas funcionales (Harry, Snitch Box, Ron, Recordadora, Protego, Escoba, Hermione, McGonagall, Dumbledore y Accio).
3. Resistir las oleadas mixtas y defenderse de los Trolls durante la Gran Oleada Final.
4. Tras eliminar al último enemigo y despejar el tablero:
   - Se muestra el panel de victoria.
   - Se registra el desbloqueo del Nivel 10 en `GameManager`.
5. Volver al Mapa del Merodeador y verificar que el Nivel 10 (Profesor Quirrell) está disponible.
