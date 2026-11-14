# Guía de Validación Rápida: Nivel 2 y la Recordadora

**Branch**: `002-nivel-2-recordadora`  
**Feature**: Nivel 2 — Expansión a 3 Líneas y la Recordadora  
**Fecha**: 2026-09-29  

---

## 1. Requisitos Previos

- Godot 4.x instalado y ejecutable desde terminal o editor.
- Proyecto abierto en la carpeta raíz.

## 2. Escenarios de Validación End-to-End

### Escenario 1: Validación de Grilla (3 Líneas Activas y 2 Bloqueadas)
- **Ejecutar escena**: `res://nivel_2.tscn` (o presionar F6 con la escena abierta en Godot).
- **Prueba 1 (Plantado en filas activas)**:
  - Hacer clic en la carta de Harry (100 Snitches) y luego clic en una celda de la Fila 3 (Y=448). Confirmar que Harry se planta y el saldo baja a 50.
  - Repetir la plantación en Fila 4 (Y=576) y Fila 5 (Y=704). Confirmar que ambas celdas son válidas.
- **Prueba 2 (Rechazo en filas bloqueadas)**:
  - Intentar plantar en Fila 2 (Y=320) o Fila 6 (Y=832). Confirmar que no se planta nada y no se descuentan Snitches.
- **Resultado esperado**: Únicamente las Filas 3, 4 y 5 aceptan colocación de entidades; Filas 2 y 6 muestran el bloqueo visual translúcido de `BloqueoMagico`.

---

### Escenario 2: Prueba de la Recordadora (Bomba 3×3 y Recarga de 25s)
- **Prueba de HUD y Cooldown**:
  - Iniciar el nivel con 150 Snitches. Verificar que la carta de la Recordadora esté habilitada.
  - Seleccionar la Recordadora y plantarla en la celda central de la Fila 4.
  - Confirmar que el saldo disminuye en exactamente 150 Snitches.
  - Verificar que el botón de la Recordadora entra inmediatamente en estado de recarga (deshabilitado con contador regresivo de 25s).
- **Prueba de Explosión en Área**:
  - Al transcurrir 1,5 segundos desde el plantado, observar la animación de aviso (pulso de escala / cambio de color).
  - Confirmar que detona y elimina instantáneamente a todos los Alumnos Slytherin presentes en el área de 3×3 celdas.
  - Confirmar que los aliados adyacentes (Harry o Caja de Snitch) no sufren daño.
  - Confirmar que la Recordadora desaparece (`queue_free()`).
- **Prueba de Fin de Recarga**:
  - Transcurridos los 25 segundos y habiendo recuperado al menos 150 Snitches, confirmar que la carta de la Recordadora vuelve a estar habilitada.

---

### Escenario 3: Spawner Multilínea y Flujo de Victoria
- **Prueba de Spawner**:
  - Observar el avance de la partida. Confirmar que los Alumnos Slytherin aparecen a intervalos regulares de 6 segundos.
  - Verificar que los enemigos aparecen repartidos aleatoriamente entre los spawners de las 3 filas activas (`Marker2D2`, `Marker2D3`, `Marker2D4`).
- **Prueba de Victoria y Progresión**:
  - Dejar avanzar la oleada hasta completar los 20 enemigos generados.
  - Eliminar al enemigo número 20.
  - Confirmar que se despliega el modal `¡VICTORIA!` con el mensaje de desbloqueo del Nivel 3.
  - Al pulsar "Siguiente Nivel" o "Volver al Mapa", verificar que en el Mapa del Merodeador (`menu_niveles.tscn`) el botón `Nivel 3` se encuentra desbloqueado.

---

### Escenario 4: Red de Salvamento de Dementores
- Permitir que un Alumno Slytherin atraviese una de las filas hasta alcanzar el extremo izquierdo (X=160).
- Confirmar que el Dementor de esa fila se activa, avanza eliminando a los enemigos de la fila y evita la pantalla de Derrota inmediata.
