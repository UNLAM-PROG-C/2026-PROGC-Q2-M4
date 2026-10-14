# Interface Contracts: Nivel 3 (Godot Nodes)

En el contexto de esta arquitectura de Godot (basada en Nodos y Duck Typing), los "contratos" definen las firmas de métodos y señales públicas que las entidades deben exponer para que el resto de los sistemas (proyectiles, gestores de nivel, colisiones) interactúen con ellas sin conocer su tipo exacto.

## Contrato de Daño (Entities Reactivas)

Ambas entidades (Draco y Protego) deben cumplir con el contrato estándar de recepción de daño utilizado por el motor de colisiones y proyectiles del juego.

### Método Público
```gdscript
func recibir_danio(cantidad: float) -> void
```
- **Descripción**: Aplica un daño numérico a la salud de la entidad.
- **Comportamiento esperado en Draco**: Resta `cantidad` de su vida. Si la vida llega a cero, muere y se elimina de la escena.
- **Comportamiento esperado en Protego**: Resta `cantidad` de su salud y emite destellos de daño. Si la salud llega a cero, emite señal `derrotado` y se elimina.

## Contrato de Ciclo de Vida (Aliados)

Para que el gestor de la cuadrícula o el nivel (e.g. `nivel_3.gd`) sepa cuándo una celda vuelve a quedar libre, Protego debe respetar el contrato de señales de los aliados.

### Señal Pública
```gdscript
signal derrotado(entidad: Node2D)
```
- **Emisión**: Debe emitirse justo antes de llamar a `queue_free()` cuando la salud de Protego llega o cae por debajo de `0.0`.
- **Argumentos**: `entidad` pasa la propia referencia (`self`) para que la celda correspondiente la identifique y limpie su estado de ocupación.

## Grupos y Capas de Colisión (Contratos Implícitos)

En Godot, la pertenencia a grupos actúa como un contrato de interfaz (Duck Typing).

- **Draco** MUST pertenecer al grupo `"enemigos"`.
- **Protego** MUST pertenecer al grupo `"aliados"`.
- **Capas (Layers)**: Protego debe residir en la capa correspondiente a las plantas/aliados para que los RayCast o Area2D de los enemigos lo detecten y cambien a estado de ataque.
