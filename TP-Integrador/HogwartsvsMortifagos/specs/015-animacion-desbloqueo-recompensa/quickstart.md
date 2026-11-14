# Quickstart: Validación de la Animación de Desbloqueo de Recompensa

**Feature**: `015-animacion-desbloqueo-recompensa`  
**Date**: 2026-10-12

Esta guía define los escenarios ejecutables para verificar la cinemática de desbloqueo de recompensas.

## Prerrequisitos

- Motor: Godot 4.7.2 stable instalado (`C:\Users\polol\Desktop\Godot_v4.7.2-stable_win64.exe`).
- Terminal: PowerShell en la raíz del repositorio.

---

## Escenario 1: Validación de Reglas de Código de la Cátedra

Verifica que ningún método supere las 15 líneas y no existan identificadores prohibidos.

```powershell
cmd.exe /c "C:\Users\polol\Desktop\Godot_v4.7.2-stable_win64.exe --headless --path . -s tools/check_rules.gd"
```

**Resultado esperado**:
- `reward_unlock_screen.gd`, modificaciones en `level.gd` y `game_manager.gd` pasan con 0 violaciones.

---

## Escenario 2: Prueba Headless del Catálogo de Recompensas y Textos

Verifica que cada uno de los 10 niveles retorne la textura correcta, el texto exacto sin truncar y el comportamiento nulo del Nivel 9.

```powershell
cmd.exe /c "C:\Users\polol\Desktop\Godot_v4.7.2-stable_win64.exe --headless --path . -s tests/test_reward_unlock.gd"
```

**Comprobaciones automáticas**:
1. Nivel 1 retorna semilla Recordadora y descripción exacta de la Recordadora.
2. Nivel 2 retorna semilla Protego y descripción de Protego.
3. Nivel 3 retorna varita Accio (`Images/elder_wand.png`) y descripción de Accio.
4. Nivel 4 a 8 retornan las semillas correspondientes (Ron, Escoba, Hermione, McGonagall, Dumbledore).
5. Nivel 9 retorna `null` (sin recompensa).
6. Nivel 10 retorna trofeo Piedra Filosofal y mensaje conmemorativo extenso.

---

## Escenario 3: Prueba de Cinemática y Salto (Skip)

Verifica el ciclo de vida del nodo `RewardUnlockScreen`:
1. Iniciar cinemática: el nodo entra en estado `ANIMATING`, el Tween inicia la rotación y zoom.
2. Pulsar / simular clic: el método `skip_animation()` cancela el Tween, ubica la semilla en posición/escala de reposo y habilita el botón "Continuar".
3. Pulsar "Continuar": la señal `reward_dismissed` es emitida con el número de nivel correcto.

---

## Escenario 4: Prueba de Rejugabilidad y Flujo con `LevelEndPanel`

Verifica que:
1. Al ganar un nivel no completado previamente, `level.gd` despliega `RewardUnlockScreen`.
2. Al cerrar la pantalla de recompensa, se presenta de forma inmediata `LevelEndPanel` con sus botones funcionales ("Siguiente Nivel", "Reintentar", "Volver al Mapa").
3. Al ganar nuevamente el mismo nivel (rejugabilidad), `RewardUnlockScreen` se omite y se muestra directamente `LevelEndPanel`.
