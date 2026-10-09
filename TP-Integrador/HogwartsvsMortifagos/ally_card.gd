class_name AllyCard
extends Resource

## Card of an ally in a level's HUD: the single source of its cost and cooldown.

## Name shown on the card button.
@export var display_name: String = ""
## Ally scene placed on the grid.
@export var scene: PackedScene
## Snitches spent when placing the ally.
@export var cost: int = 0
## Seconds the card stays disabled after placing the ally.
@export var cooldown: float = 0.0


func is_valid() -> bool:
	return scene != null and cost > 0 and cooldown >= 0.0
