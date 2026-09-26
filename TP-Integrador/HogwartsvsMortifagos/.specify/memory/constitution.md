# Constitución del Proyecto Hogwarts vs. Mortífagos

## Principios

### I. Motor y lenguaje

El proyecto DEBE usar Godot 4 con el renderizador Compatibility y GDScript con tipado estático estricto. Toda variable, constante, parámetro, señal y retorno DEBE declarar su tipo cuando corresponda.

### II. Arquitectura basada en Nodos y Escenas

La arquitectura DEBE estar basada estrictamente en Nodos y Escenas de Godot. Cada entidad DEBE tener una escena propia y su script correspondiente. Las entidades DEBEN reutilizarse mediante instanciación de escenas, evitando duplicar nodos o lógica.

### III. Vocabulario temático

El juego DEBE conservar la temática de Harry Potter sobre la estructura de Plants vs. Zombies:

- Los aliados DEBEN llamarse y tratarse como Magos.
- Los enemigos DEBEN llamarse y tratarse como Mortífagos.
- La moneda DEBE llamarse `Snitches`.
- El código, las escenas, los grupos y la interfaz DEBEN respetar el diccionario temático definido en [`AGENTS.md`](../../AGENTS.md).

### IV. Colisiones por áreas y grupos

La detección de colisiones DEBE realizarse mediante `Area2D` y señales de colisión de Godot. Las categorías de entidades DEBEN identificarse mediante Grupos, como `aliados`, `enemigos` y `hechizos`.

Está PROHIBIDO comparar entidades por nombres de nodos. Las validaciones DEBEN consultar Grupos, capas y máscaras de colisión coherentes. Las áreas de ataque, daño, detección y recogida DEBEN existir como nodos explícitos en las escenas correspondientes.

### V. Estado de interfaz sincronizado con Godot MCP

Todo estado de la interfaz DEBE leerse directamente del servidor `godot-mcp`. El Scene Tree, los nodos, las propiedades, los grupos, las señales y cualquier otro estado expuesto por el motor DEBEN considerarse la única fuente de verdad para representar el estado de la interfaz.

No se DEBE inferir el estado de la interfaz únicamente desde archivos `.tscn`, `.gd` u otros archivos de texto. Si `godot-mcp` no está disponible o devuelve información incompleta, la tarea DEBE detenerse e informar el bloqueo en lugar de adivinar.

## Cumplimiento

Toda propuesta, implementación, revisión o cambio estructural DEBE verificarse contra estos principios y contra las reglas técnicas de [`AGENTS.md`](../../AGENTS.md). Las excepciones DEBEN documentarse y aprobarse antes de implementarse.

## Metadatos

- Versión: 1.0.0
- Ratificada: 2026-09-25
- Última modificación: 2026-09-25
