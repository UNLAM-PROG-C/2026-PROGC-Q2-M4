# AGENTS.md

## Alcance del proyecto

Este proyecto es un clon de Plants vs. Zombies con temática de Harry Potter.

- Motor: Godot 4.
- Lenguaje: GDScript.
- Resolución objetivo: 1920x1080.
- Renderizador objetivo: Compatibility.
- Arquitectura: basada estrictamente en Nodos y Escenas de Godot.

## Diccionario temático

Usar siempre estos nombres y equivalencias en el código, las escenas, los grupos y la interfaz del juego.

### Moneda

- **Snitches**: moneda del juego, equivalente a los Soles.
- Valor de referencia: 25 Snitches.

### Aliados

Los aliados cumplen el rol de las plantas:

| Entidad | Rol equivalente | Coste |
| --- | --- | ---: |
| Harry | Lanzaguisantes | 100 |
| Caja de Snitch | Girasol | 50 |
| Ron | Ataque Scabbers | 125 |
| Hermione | Ralentiza | 125 |
| Recordadora | Cereza explosiva | 150 |
| Protego | Nuez | 50 |
| Escoba | Jalapeño | 125 |
| McGonagall | Ametralladora | 200 |
| Accio | Pala | No aplica |

### Enemigos

Los enemigos cumplen el rol de los zombies:

- **Alumno Slytherin**: enemigo común.
- **Draco**: enemigo con cono.
- **Alumno con Protego**: enemigo con cubo.
- **Prefecto Slytherin**: rompe defensas.
- **Troll**: enemigo gigante.
- **Profesor Quirrell**: jefe final.

## Reglas obligatorias de Godot

### Tipado

Usar tipado estricto estático en GDScript siempre. Toda variable, constante, parámetro y retorno debe declarar su tipo cuando corresponda.

```gdscript
var salud: int = 100
var velocidad: float = 120.0
var objetivo: Node2D

func recibir_danio(cantidad: int) -> void:
    salud -= cantidad
```

No introducir variables sin tipo explícito salvo que una limitación concreta de la API de Godot lo haga inevitable.

### Escenas y entidades

- Mantener una arquitectura basada estrictamente en Nodos y Escenas.
- Usar una escena por entidad.
- Cada entidad debe tener su propia escena y su propio script.
- Ejemplos: `harry.tscn` con `harry.gd`, `draco.tscn` con `draco.gd`.
- Las escenas deben organizar sus responsabilidades mediante nodos hijos y no mediante lógica global monolítica.
- Reutilizar entidades instanciando sus escenas en lugar de duplicar nodos o lógica.

### Comunicación entre nodos

- Usar Señales (Signals) para comunicar nodos hijos hacia sus padres.
- Las señales deben declarar tipos para sus parámetros.
- Conectar señales en el lugar apropiado y desconectarlas cuando la vida útil del nodo lo requiera.
- Evitar que los nodos hijos busquen o modifiquen directamente detalles internos de sus padres cuando una señal pueda expresar el evento.

Ejemplo:

```gdscript
signal salud_agotada(entidad: Node2D)

func recibir_danio(cantidad: int) -> void:
    salud -= cantidad
    if salud <= 0:
        salud_agotada.emit(self)
```

### Inspector

- Exponer en el Inspector todas las variables de configuración que deban ajustarse durante el diseño o el balance del juego usando `@export`.
- Mantener el tipo explícito en las variables exportadas.

```gdscript
@export var coste: int = 100
@export var tiempo_recarga: float = 5.0
@export var escena_proyectil: PackedScene
```

### Colisiones y grupos

- Detectar colisiones usando `Area2D` y señales de colisión de Godot.
- Usar Grupos para identificar categorías de entidades, como `aliados`, `enemigos` y `hechizos`.
- Consultar grupos para validar objetivos y evitar comprobaciones frágiles basadas únicamente en nombres de nodos.
- Usar las capas y máscaras de colisión de forma coherente con los `Area2D` de cada entidad.
- Las áreas de ataque, daño, recogida y detección deben ser nodos explícitos dentro de las escenas correspondientes.

Grupos mínimos reservados:

- `aliados`
- `enemigos`
- `hechizos`

## Restricciones de cambios

- No instalar addons.
- No modificar `project.godot` sin preguntar previamente.
- No cambiar la resolución objetivo ni el renderizador sin preguntar previamente.
- No introducir dependencias externas si la funcionalidad puede resolverse con Godot 4 y la arquitectura existente.
- Mantener los cambios enfocados en la tarea solicitada y respetar las escenas, scripts y recursos existentes.
