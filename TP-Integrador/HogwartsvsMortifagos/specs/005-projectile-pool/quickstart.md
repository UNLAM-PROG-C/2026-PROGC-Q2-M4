# Quickstart: Validar el Projectile Object Pool

## Prerrequisitos

- Godot 4.7.2 disponible.
- Proyecto abierto desde `TP-Integrador/HogwartsvsMortifagos`.
- Escenas de los niveles 1, 2 y 3 disponibles.
- El cambio de implementación del pool aplicado según [plan.md](./plan.md).

## Validación estática

1. Validar los scripts modificados con el comprobador de GDScript de Godot.
2. Confirmar que no haya errores de tipado ni referencias a nodos liberados.
3. Revisar que `projectile.tscn` conserve grupo `spells`, capa 4, máscara 2 y sus señales.

## Escenarios funcionales

### Capacidad inicial

1. Ejecutar un nivel.
2. Solicitar hasta 50 proyectiles activos antes de que alguno termine.
3. Verificar que la capacidad no crece y que todos los proyectiles se muestran y avanzan.

### Crecimiento controlado

1. Mantener 50 proyectiles activos.
2. Solicitar un proyectil adicional.
3. Verificar que se agregan exactamente 10 unidades y que la nueva solicitud se atiende.
4. Liberar un proyectil y solicitar otro.
5. Verificar que se reutiliza el disponible y no vuelve a crecer la capacidad.

### Impacto y salida de pantalla

1. Disparar contra un `enemies`.
2. Comprobar que el enemigo recibe daño una sola vez y aparece la mini explosión.
3. Disparar sin objetivo hasta que el proyectil salga de pantalla.
4. Confirmar que queda inactivo, invisible y sin monitoreo de colisiones.

### Reinicio de estado

1. Reutilizar un proyectil que ya haya impactado.
2. Confirmar que inicia en el primer frame, con `_has_hit` reiniciado, tiempo de animación en cero y posición nueva.
3. Repetir la activación varias veces y comprobar que no hay conexiones duplicadas ni daño omitido.

### Señales simultáneas

1. Provocar una situación donde impacto y salida de pantalla ocurran en el mismo cuadro.
2. Confirmar que el daño se aplica como máximo una vez y que el proyectil vuelve al pool una sola vez.

### Cambio de nivel

1. Activar proyectiles en un nivel.
2. Cambiar de nivel o reiniciar la partida.
3. Confirmar que no quedan proyectiles activos, invisibles o con referencias al nivel anterior.

## Resultado esperado

- Se conserva la jugabilidad, el daño, la animación y las colisiones existentes.
- La capacidad observada es 50 inicialmente y crece de 10 en 10.
- Al menos 100 disparos consecutivos reutilizan instancias liberadas.
- Ninguna tarea secundaria modifica el Scene Tree ni nodos de Godot.
