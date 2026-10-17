# Node Interfaces & Scene Contracts: Nivel 9 - Dumbledore y el Troll Colosal

**Feature Branch**: `[012-nivel-9-dumbledore-troll]` | **Date**: 2026-10-08

## 1. Contrato de la Escena `dumbledore.tscn`

### Jerarquía de Nodos
```text
Dumbledore (Area2D) [Script: res://dumbledore.gd] [Groups: "allies"]
├── Sprite2D (Texture: res://Images/dumbledore.png)
├── CollisionShape2D (Shape: RectangleShape2D, size = Vector2(80, 110))
├── ShootTimer (Timer: wait_time = 3.0, autostart = true)
├── ShootPoint (Marker2D: position = Vector2(30, -10))
└── DamageFlash (Instance: res://damage_flash.tscn)
```

### Contrato del Script `dumbledore.gd`
```gdscript
class_name Dumbledore
extends Ally

@export var shot_interval: float = 3.0
@export var projectile_scene: PackedScene

@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

func _ready() -> void
func _on_shoot_timer_timeout() -> void
func _shoot() -> void
func _has_enemy_in_lane() -> bool
```

---

## 2. Contrato de la Escena `dumbledore_projectile.tscn`

### Jerarquía de Nodos
```text
DumbledoreProjectile (Area2D) [Script: res://dumbledore_projectile.gd] [Groups: "spells"]
├── Sprite2D (Texture: res://Images/dumbledore_shot.png)
├── CollisionShape2D (Shape: CircleShape2D o RectangleShape2D de impacto frontal)
└── SplashArea (Area2D: monitoring = true, collision_mask = 2)
    └── CollisionShape2D (Shape: RectangleShape2D, size = Vector2(384, 384))
```

### Contrato del Script `dumbledore_projectile.gd`
```gdscript
class_name DumbledoreProjectile
extends Area2D

@export var speed: float = 350.0
@export var splash_damage: float = 20.0

@onready var splash_area: Area2D = $SplashArea

func _ready() -> void
func _process(delta: float) -> void
func _on_area_entered(area: Area2D) -> void
func _detonate() -> void
func _apply_splash_damage() -> void
func _spawn_impact_effect() -> void
```

---

## 3. Contrato del Recurso `dumbledore_card.tres` y HUD Button

### Recurso `dumbledore_card.tres`
```text
[gd_resource type="Resource" script_class="AllyCard" format=3]
[ext_resource type="Script" path="res://ally_card.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://dumbledore.tscn" id="2_scene"]
[ext_resource type="Texture2D" path="res://Images/dumbledore.png" id="3_texture"]

[resource]
script = ExtResource("1_script")
display_name = "Dumbledore"
scene = ExtResource("2_scene")
cost = 300
cooldown = 15.0
texture = ExtResource("3_texture")
```

### Botón en el HUD de `level_9.tscn`
```text
[node name="DumbledoreCardButton" type="Button" parent="HUD"]
offset_left = 1420.0
offset_top = 10.0
offset_right = 1570.0
offset_bottom = 55.0
theme_override_font_sizes/font_size = 18
text = "Dumbledore (300)"
script = ExtResource("card_button_script")
card = ExtResource("dumbledore_card_tres")
```

---

## 4. Contrato de la Escena `troll.tscn` y Script `troll.gd`

### Jerarquía de Nodos (Preserva nodos visuales existentes)
```text
Troll (Area2D) [Script: res://troll.gd] [Groups: "enemies"] [Collision: layer 2, mask 1]
├── Troll_Body (Sprite2D)
│   ├── Right_Arm (Sprite2D)
│   ├── Left_Arm (Sprite2D)
│   ├── Back_Leg (Sprite2D)
│   │   └── Back_Foot (Sprite2D)
│   ├── Front_Leg (Sprite2D)
│   │   └── Front_Foot (Sprite2D)
│   └── Loincloth (Sprite2D)
├── Animation (AnimationPlayer: animations "RESET", "Walk", "attack")
├── CollisionShape2D (Shape: RectangleShape2D, size = Vector2(100, 180))
├── DetectionArea (Area2D: frontal, mask = 1)
│   └── CollisionShape2D (Shape: RectangleShape2D, size = Vector2(60, 140), position = Vector2(-40, 0))
└── DamageFlash (Instance: res://damage_flash.tscn)
```

### Contrato del Script `troll.gd`
```gdscript
class_name Troll
extends Enemy

@export var damage_instakill: float = 9999.0

@onready var animation_player: AnimationPlayer = $Animation
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void
func _process(delta: float) -> void
func _process_movement(delta: float) -> void
func _on_detection_area_area_entered(area: Area2D) -> void
func _start_smash(target: Ally) -> void
func _execute_instakill() -> void
func _on_animation_finished(anim_name: StringName) -> void
func take_damage(amount: float) -> void
func _die() -> void
```

---

## 5. Contrato de la Escena `level_9.tscn`

### Jerarquía Principal
```text
Level9 (Node2D) [Script: res://level.gd]
├── Background (Sprite2D)
├── TileMap (TileMapLayer)
├── LawnMowers (5 Dementor instances)
├── EntityLayer (Node2D)
├── Projectiles (Node2D)
├── ProjectilePool (Node)
├── HUD (CanvasLayer)
│   ├── SnitchCounter (Label)
│   ├── HarryCardButton (Button)
│   ├── SnitchBoxCardButton (Button)
│   ├── RonCardButton (Button)
│   ├── RemembrallCardButton (Button)
│   ├── ProtegoCardButton (Button)
│   ├── BroomstickCardButton (Button)
│   ├── HermioneCardButton (Button)
│   ├── McGonagallCardButton (Button)
│   ├── DumbledoreCardButton (Button)
│   └── AccioButton (Button)
├── WaveAnnouncement (CenterContainer)
│   └── Label (Label)
└── WaveDirector (Node)
```
