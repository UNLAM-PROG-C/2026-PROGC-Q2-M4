---
name: "Convenciones de GDScript para Godot"
description: "Aplicar al escribir o modificar GDScript en Godot 4: tipado estricto, referencias de nodos, movimiento con delta y validación de entidades liberadas."
applyTo: "**/*.gd"
---

# Convenciones de GDScript

Estas reglas aplican únicamente a archivos `*.gd`. Para las reglas generales del proyecto y el diccionario temático, consultar [AGENTS.md](../../AGENTS.md).

## Tipado estricto

El tipado estático es obligatorio. Declarar el tipo de variables, parámetros, retornos, señales y referencias exportadas.

```gdscript
@export var velocidad: float = 120.0
var objetivo: Node2D

func recibir_danio(cantidad: int) -> void:
    salud -= cantidad
```

## Referencias a nodos

Está prohibido usar rutas absolutas largas con `get_node()` o `$`. Usar referencias exportadas o Unique Names del Scene Tree.

```gdscript
@export var nodo: Node
@export var area_ataque: Area2D

@onready var animacion: AnimatedSprite2D = %Animacion
```

Cuando se use una referencia exportada, asignarla desde el Inspector. Cuando se use `%NombreNodo`, activar `Access as Unique Name` en el nodo correspondiente del Scene Tree.

## Movimiento en `_process()`

Multiplicar siempre por `delta` los cálculos de movimiento realizados en `_process()` para que la velocidad sea independiente de los cuadros por segundo.

```gdscript
func _process(delta: float) -> void:
    position.x += velocidad * delta
```

## Referencias a entidades liberadas

Antes de interactuar con una referencia a otra entidad, comprobar siempre `is_instance_valid()`. Esto evita crashes cuando la entidad fue liberada con `queue_free()`.

```gdscript
func atacar_protego(protego: Node2D) -> void:
    if not is_instance_valid(protego):
        return

    protego.recibir_danio(danio)
```

Esta comprobación es obligatoria en ataques, objetivos, proyectiles, señales diferidas y cualquier otra interacción entre entidades que pueda ocurrir después de un `queue_free()`.
