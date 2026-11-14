class_name Ally
extends Area2D

## Base ally: takes damage from enemies, flashes and is freed when its
## health runs out.

## Emitted right before the ally is freed for running out of health.
signal defeated(entity: Node2D)

## Total health.
@export var health: float = 100.0
## Shared projectile pool, injected by the level when the ally is placed.
## Only shooters use it; the others ignore it.
var projectile_pool: ProjectilePool = null

@onready var damage_flash: DamageFlash = $DamageFlash


func update_row_z_index() -> void:
  z_index = Lane.get_ally_z_index(global_position.y)


## Called by enemies while attacking.
func take_damage(amount: float) -> void:
  health -= amount
  damage_flash.flash()
  if health <= 0.0:
    defeated.emit(self)
    queue_free()


## Shared lane check used by every shooter ally.
func _has_enemy_in_lane() -> bool:
  return not Lane.enemies_in_lane(get_tree(), global_position.y).is_empty()


## Takes a projectile from the shared pool; returns null when there is no pool.
func acquire_pooled_projectile(
  pool: ProjectilePool,
  origin: Vector2,
  shot_damage: float,
  slows_target: bool,
  texture: Texture2D
) -> Projectile:
  if pool == null or not is_instance_valid(pool):
    return null
  return pool.acquire_projectile(origin, shot_damage, slows_target, texture)
