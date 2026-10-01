# Validation Guide: 003-nivel-3-protego

## Pruebas de Jugabilidad (Playtesting en Godot)

1. **Validar las 5 líneas (HU-1)**:
   - Inicia el juego corriendo la escena `nivel_3.tscn`.
   - Observa si los enemigos (Slytherins o Dracos) aparecen aleatoriamente en cualquiera de las 5 alturas (rutas horizontales).
   - Consigue Snitches. Haz clic en las celdas de las rutas superior e inferior extrema para validar que puedes plantar aliados en toda la extensión vertical del tablero (5 filas).

2. **Validar a Protego (HU-3)**:
   - Acumula 50 Snitches.
   - Selecciona la carta "Protego" en el menú de cartas de HUD.
   - Plántala en la ruta donde se acerque un enemigo.
   - **Resultado Esperado A**: El enemigo (Slytherin o Draco) al tocar al Protego se detiene y comienza su animación de ataque.
   - **Resultado Esperado B**: El Protego NO dispara ni hace daño al enemigo.
   - **Resultado Esperado C**: El Protego actúa como un muro efectivo, resistiendo decenas de segundos de ataque continuo antes de morir y desaparecer.

3. **Validar a Draco (HU-2)**:
   - Observa la llegada del enemigo Draco (debería tener un sprite distintivo, ej. con un escudo/cono).
   - Planta aliados atacantes (como Harry) en su línea.
   - **Resultado Esperado A**: Cuenta visualmente los hechizos requeridos para matarlo. Debería resistir el doble de impactos que el Alumno Slytherin básico.
   - **Resultado Esperado B**: Al chocar con un aliado (Mago o Protego), Draco se detiene correctamente y reduce la salud del aliado.
