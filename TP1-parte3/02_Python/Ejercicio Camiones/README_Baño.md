# Baño compartido

Solución en Python del ejercicio **Baño compartido**, perteneciente a la actividad práctica opcional de comunicación y sincronización.

El programa simula empleados que intentan utilizar un único baño compartido. Cada empleado es representado por un hilo y el baño funciona como un recurso compartido entre todos los hilos.

## Reglas del problema

- El baño admite como máximo tres empleados simultáneamente.
- Hombres y mujeres no pueden ocuparlo al mismo tiempo.
- Si el baño está ocupado por un género, los empleados del otro deben esperar.
- Cuando sale la última persona de un género, el baño queda disponible para el siguiente grupo.

## Archivo principal

La implementación se encuentra en:

```text
Practica_N°_1_Parte_3_Baño.ipynb
```

## Mecanismos de concurrencia utilizados

### Hilos

Cada empleado se ejecuta mediante un `threading.Thread`. Todos los hilos se inician con `start()` y el hilo principal espera su finalización mediante `join()`.

### Capacidad del baño

Un `threading.BoundedSemaphore(3)` limita la cantidad de empleados dentro del baño. Cada empleado toma un permiso antes de entrar y lo devuelve al salir.

### Reserva por género

Un `threading.Semaphore(1)` representa la disponibilidad general del baño:

- La primera persona de un género reserva el baño.
- Las siguientes personas del mismo género pueden compartir esa reserva.
- La última persona de ese género libera el baño.

### Protección de contadores

El programa mantiene un contador para cada género. Cada contador está protegido por su propio `threading.Lock` para impedir condiciones de carrera al incrementarlo o disminuirlo.

También se utiliza un `Lock` independiente para ordenar las impresiones realizadas por los distintos hilos.

## Ejecución

1. Abrir `Practica_N°_1_Parte_3_Baño.ipynb` con Jupyter Notebook, JupyterLab o Visual Studio Code.
2. Reiniciar el kernel para evitar que permanezcan hilos de ejecuciones anteriores.
3. Ejecutar todas las celdas en orden.
4. Esperar hasta que todos los empleados hayan finalizado.

La salida informa el tiempo transcurrido, la acción, el nombre y el género de cada empleado:

```text
[  0.0s] ESPERA  | Ana        | mujer
[  0.0s] ENTRA   | Ana        | mujer
[  5.0s] SALE    | Ana        | mujer
```

El orden exacto puede cambiar entre ejecuciones debido a la planificación concurrente de los hilos.

## Conceptos aplicados

- Hilos y recursos compartidos.
- Regiones críticas.
- Condiciones de carrera.
- Exclusión mutua mediante locks.
- Sincronización mediante semáforos.
- Espera y liberación de recursos.

## Consideración sobre inanición

La solución impide que ambos géneros ocupen el baño simultáneamente y respeta la capacidad máxima. Sin embargo, no implementa un criterio estricto de turnos entre géneros. Si continuaran llegando empleados de un mismo género, el otro podría permanecer esperando durante un tiempo prolongado. Este comportamiento se conoce como **inanición** o *starvation*.
