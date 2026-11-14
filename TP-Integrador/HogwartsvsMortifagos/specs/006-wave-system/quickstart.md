# Quickstart: Validación del Sistema de Oleadas

## Prerrequisitos

- Godot `4.7.2.stable` instalado.
- Proyecto abierto desde `TP-Integrador/HogwartsvsMortifagos`.
- Escenas `level_1.tscn`, `level_2.tscn` y `level_3.tscn` disponibles.
- No modificar `project.godot` ni instalar addons.

## Validación estática

Validar cada script nuevo o modificado con el editor de Godot o con:

```text
godot --path . --headless --check-only --script res://wave_director.gd
godot --path . --headless --check-only --script res://wave_plan.gd
godot --path . --headless --check-only --script res://level.gd
```

Resultado esperado: ningún error de parseo ni de tipado.

## Caso 1: nivel estándar

1. Ejecutar `level_1.tscn`.
2. Configurar una cuota de prueba que permita observar el umbral intermedio.
3. Derrotar enemigos hasta alcanzar el 50%.
4. Verificar que no aparecen spawns regulares adicionales mientras el tablero tenga enemigos activos.
5. Verificar que la oleada intermedia se instancia una sola vez cuando el tablero queda vacío.
6. Derrotar todos los enemigos intermedios y comprobar que el sistema continúa hasta la cuota regular.
7. Vaciar el tablero al completar la cuota.
8. Verificar que la oleada final es mayor que la intermedia y que la victoria aparece únicamente cuando la oleada final queda en cero.

## Caso 2: nivel especial

1. Ejecutar un nivel configurado como especial.
2. Registrar los enemigos regulares derrotados en los umbrales del 33% y 66%.
3. Comprobar que cada oleada especial se dispara una sola vez.
4. Comprobar que el spawn normal queda bloqueado durante cada espera de limpieza.
5. Verificar que la oleada final se activa al 100% y después de confirmar `active_enemies == 0`.

## Caso 3: cálculo concurrente

1. Activar el registro temporal del director para incluir `request_id`, `level_generation` y estado.
2. Ejecutar al menos 20 decisiones de oleada.
3. Comprobar que cada `BoardSnapshot` contiene solo valores simples.
4. Comprobar que el hilo principal aplica cada `WaveResult` y que el director no instancia ni libera nodos.
5. Confirmar que el juego mantiene el procesamiento normal durante el cálculo.

## Caso 4: cancelación

1. Iniciar una decisión del director.
2. Cambiar al mapa, reiniciar, ganar o perder el nivel antes de consumir el resultado.
3. Confirmar que el director termina correctamente.
4. Confirmar que no aparecen enemigos en la escena anterior y que no se accede a nodos liberados.

## Criterios de aceptación

- Las reglas de estados y datos se corresponden con [data-model.md](./data-model.md).
- Las métricas de éxito de [spec.md](./spec.md) se pueden observar en ejecución.
- La integración conserva las señales existentes de [enemy.gd](../../enemy.gd) y el pool de [projectile_pool.gd](../../projectile_pool.gd).
- Ningún cambio requiere modificar `project.godot`.
