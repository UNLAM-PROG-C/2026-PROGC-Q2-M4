class_name Ron
extends Ally

const RON_SHOT_TEXTURE: Texture2D = preload("res://Images/ron_shot.png")

## Seconds between shots.
@export var shot_interval: float = 3.0
## Damage dealt to the enemy hit by Ron's projectile (3x base damage).
@export var damage: float = 60.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
    shoot_timer.wait_time = shot_interval
    shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
    if not _has_enemy_in_lane():
        return
    _shoot()


func _shoot() -> void:
    acquire_pooled_projectile(projectile_pool, shoot_point.global_position, damage, false, RON_SHOT_TEXTURE)
    _play_card_action()


func _play_card_action() -> void:
    var game_manager := get_tree().root.get_node_or_null("GameManager")
    if game_manager != null and game_manager.sound_service != null:
        var variant := "mage"
        game_manager.sound_service.play("card_action", variant)
