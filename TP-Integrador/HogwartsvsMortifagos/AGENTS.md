# AGENTS.md

> El [`AGENTS.md` raíz del repositorio](../../AGENTS.md) (reglas de la cátedra) es la regla superior y prevalece sobre este archivo y sobre la constitución del proyecto (`.specify/memory/constitution.md`).

## Alcance del proyecto

Este proyecto es un clon de Plants vs. Zombies con temática de Harry Potter.

- Motor: Godot 4.
- Lenguaje: GDScript.
- Resolución objetivo: 1920x1080.
- Renderizador objetivo: Compatibility.
- Arquitectura: basada estrictamente en Nodos y Escenas de Godot.

## Idioma

- Todo identificador y comentario (scripts, clases, métodos, señales, variables, constantes, nodos, grupos, uniforms) debe estar en inglés, usando la columna "Identificador" del diccionario temático.
- Los textos visibles para el jugador (botones, HUD, mensajes) se mantienen en español, en constantes con sufijo `_TEXT` o en la propiedad `text` de las escenas.

## Diccionario temático

Usar siempre estas equivalencias. El nombre en español es el que ve el jugador; el identificador en inglés es el que se usa en el código, las escenas y los grupos.

### Moneda

| Entidad | Identificador | Rol equivalente |
| --- | --- | --- |
| Snitches | `snitch` | Soles |

- Valor de referencia: 25 Snitches.

### Aliados

Los aliados cumplen el rol de las plantas:

| Entidad | Identificador | Rol equivalente | Coste |
| --- | --- | --- | ---: |
| Harry | `Harry` | Lanzaguisantes | 100 |
| Caja de Snitch | `SnitchBox` | Girasol | 50 |
| Ron | `Ron` | Ataque Scabbers | 125 |
| Hermione | `Hermione` | Ralentiza | 125 |
| Recordadora | `Remembrall` | Cereza explosiva | 150 |
| Protego | `Protego` | Nuez | 50 |
| Escoba | `Broomstick` | Jalapeño | 125 |
| McGonagall | `McGonagall` | Ametralladora | 200 |
| Accio | `Accio` | Pala | No aplica |

### Enemigos

Los enemigos cumplen el rol de los zombies:

| Entidad | Identificador | Rol equivalente |
| --- | --- | --- |
| Alumno Slytherin | `SlytherinStudent` | Enemigo común |
| Draco | `Draco` | Enemigo con cono |
| Alumno con Protego | `ProtegoStudent` | Enemigo con cubo |
| Prefecto Slytherin | `SlytherinPrefect` | Rompe defensas |
| Troll | `Troll` | Enemigo gigante |
| Profesor Quirrell | `Quirrell` | Jefe final |

## Reglas obligatorias de Godot

### Tipado

Usar tipado estricto estático en GDScript siempre. Toda variable, constante, parámetro y retorno debe declarar su tipo cuando corresponda.

```gdscript
var health: int = 100
var speed: float = 120.0
var target: Node2D

func take_damage(amount: int) -> void:
    health -= amount
```

No introducir variables sin tipo explícito salvo que una limitación concreta de la API de Godot lo haga inevitable.

### Escenas y entidades

- Mantener una arquitectura basada estrictamente en Nodos y Escenas.
- Usar una escena por entidad.
- Cada entidad debe tener su propia escena y su propio script.
- Ejemplos: `harry.tscn` con `harry.gd`, `slytherin_student.tscn` con `slytherin_student.gd`.
- Las escenas deben organizar sus responsabilidades mediante nodos hijos y no mediante lógica global monolítica.
- Reutilizar entidades instanciando sus escenas en lugar de duplicar nodos o lógica.

### Comunicación entre nodos

- Usar Señales (Signals) para comunicar nodos hijos hacia sus padres.
- Las señales deben declarar tipos para sus parámetros.
- Conectar señales en el lugar apropiado y desconectarlas cuando la vida útil del nodo lo requiera.
- Evitar que los nodos hijos busquen o modifiquen directamente detalles internos de sus padres cuando una señal pueda expresar el evento.

Ejemplo:

```gdscript
signal health_depleted(entity: Node2D)

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        health_depleted.emit(self)
```

### Inspector

- Exponer en el Inspector todas las variables de configuración que deban ajustarse durante el diseño o el balance del juego usando `@export`.
- Mantener el tipo explícito en las variables exportadas.

```gdscript
@export var cost: int = 100
@export var cooldown: float = 5.0
@export var projectile_scene: PackedScene
```

### Colisiones y grupos

- Detectar colisiones usando `Area2D` y señales de colisión de Godot.
- Usar Grupos para identificar categorías de entidades, como `allies`, `enemies` y `spells`.
- Consultar grupos para validar objetivos y evitar comprobaciones frágiles basadas únicamente en nombres de nodos.
- Usar las capas y máscaras de colisión de forma coherente con los `Area2D` de cada entidad.
- Las áreas de ataque, daño, recogida y detección deben ser nodos explícitos dentro de las escenas correspondientes.

Grupos mínimos reservados:

- `allies`
- `enemies`
- `spells`

## Restricciones de cambios

- No instalar addons.
- No modificar `project.godot` sin preguntar previamente.
- No cambiar la resolución objetivo ni el renderizador sin preguntar previamente.
- No introducir dependencias externas si la funcionalidad puede resolverse con Godot 4 y la arquitectura existente.
- Mantener los cambios enfocados en la tarea solicitada y respetar las escenas, scripts y recursos existentes.
