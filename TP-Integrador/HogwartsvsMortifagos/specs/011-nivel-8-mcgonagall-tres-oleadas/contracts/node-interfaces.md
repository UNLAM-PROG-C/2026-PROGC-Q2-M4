# Node Interfaces & Scene Contracts: Nivel 8 - McGonagall y Tres Oleadas Masivas

**Feature Branch**: `[011-nivel-8-mcgonagall-tres-oleadas]` | **Date**: 2026-10-07

## 1. Contrato de la Escena `mcgonagall.tscn`

### Jerarquía de Nodos
```text
McGonagall (Area2D) [Script: res://mcgonagall.gd] [Groups: "allies"]
├── Sprite2D (Texture: res://Images/mcgonagall.png)
├── CollisionShape2D (Shape: RectangleShape2D o CircleShape2D)
├── ShootTimer (Timer: wait_time = 1.5, one_shot = true)
├── BurstTimer (Timer: wait_time = 0.15, one_shot = false)
└── ShootPoint (Marker2D: position = Vector2(24, 0))
```

### Contrato del Script `mcgonagall.gd`
```gdscript
class_name McGonagall
extends Ally

@export var shot_interval: float = 1.5
@export var burst_interval: float = 0.15
@export var burst_count: int = 4
@export var projectile_pool: ProjectilePool

var _shots_remaining: int = 0

@onready var shoot_timer: Timer = $ShootTimer
@onready var burst_timer: Timer = $BurstTimer
@onready var shoot_point: Marker2D = $ShootPoint

func _ready() -> void
func _on_shoot_timer_timeout() -> void
func _on_burst_timer_timeout() -> void
func _start_burst() -> void
func _fire_burst_shot() -> void
func _finish_burst() -> void
func _has_enemy_in_lane() -> bool
func _die() -> void
```

### Reglas de Diseño GDScript (Reglas de la Cátedra)
- Cada función implementada DEBE tener 15 líneas o menos.
- Tipado estático estricto en todos los retornos (`void`, `bool`, etc.) y parámetros.
- Constantes descriptivas en inglés para cualquier valor que no sea variable exportada.
- Desconexión o detención limpia de `burst_timer` en `_die()` y `_exit_tree()`.

---

## 2. Contrato de la Carta `mcgonagall_card.tres` y Botón en HUD

### Recurso `mcgonagall_card.tres`
```text
[gd_resource type="Resource" script_class="AllyCard" format=3]
[ext_resource type="Script" path="res://ally_card.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://mcgonagall.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
display_name = "McGonagall"
scene = ExtResource("2_scene")
cost = 200
cooldown = 7.5
```

### Nodo de HUD `McGonagallCardButton` en `level_8.tscn`
```text
[node name="McGonagallCardButton" type="Button" parent="HUD"]
offset_left = 1270.0
offset_top = 10.0
offset_right = 1410.0
offset_bottom = 55.0
theme_override_font_sizes/font_size = 18
text = "McGonagall (200)"
script = ExtResource("card_button_script")
card = ExtResource("mcgonagall_card_tres")
```

---

## 3. Contrato de Notificación de Oleadas en `level.gd`

### Nuevas Constantes
```gdscript
const WAVE_ANNOUNCEMENT_TEXT: String = "¡SE AVECINA UNA GRAN OLEADA DE MORTÍFAGOS!"
const FINAL_WAVE_ANNOUNCEMENT_TEXT: String = "¡OLEADA FINAL!"
const WAVE_ANNOUNCEMENT_DURATION: float = 2.0
```

### Método `_show_wave_announcement()`
```gdscript
func _show_wave_announcement() -> void:
	if _final_wave_active:
		wave_announcement_label.text = FINAL_WAVE_ANNOUNCEMENT_TEXT
	else:
		wave_announcement_label.text = WAVE_ANNOUNCEMENT_TEXT
	wave_announcement.visible = true
	await get_tree().create_timer(WAVE_ANNOUNCEMENT_DURATION).timeout
	if is_instance_valid(wave_announcement):
		wave_announcement.visible = false
```

---

## 4. Contrato de la Escena `level_8.tscn`

### Jerarquía General
```text
Level8 (Node2D) [Script: res://level.gd]
├── Grid (Node2D)
│   └── TileMapLayer
├── Background (Sprite2D)
├── HUD (CanvasLayer)
│   ├── SnitchesLabel (Label)
│   ├── PoolDebugLabel (Label)
│   ├── HarryCardButton (Button)
│   ├── SnitchBoxCardButton (Button)
│   ├── RonCardButton (Button)
│   ├── RemembrallCardButton (Button)
│   ├── ProtegoCardButton (Button)
│   ├── BroomstickCardButton (Button)
│   ├── HermioneCardButton (Button)
│   ├── McGonagallCardButton (Button)
│   ├── AccioButton (Button)
│   ├── WaveAnnouncement (Panel)
│   │   └── WaveAnnouncementLabel (Label)
│   └── LevelEndPanel (Control)
│       └── ...
├── Dementors (Node2D)
│   ├── Dementor (Fila 2)
│   ├── Dementor2 (Fila 3)
│   ├── Dementor3 (Fila 4)
│   ├── Dementor4 (Fila 5)
│   └── Dementor5 (Fila 6)
├── Spawners (Node2D)
│   ├── Marker2D (Fila 2)
│   ├── Marker2D2 (Fila 3)
│   ├── Marker2D3 (Fila 4)
│   ├── Marker2D4 (Fila 5)
│   └── Marker2D5 (Fila 6)
├── ProjectilePool (Node2D) [Script: res://projectile_pool.gd]
├── WaveDirector (Node) [Script: res://wave_director.gd]
├── EnemySpawnTimer (Timer)
└── SnitchSpawnTimer (Timer)
```

### Configuración del Nodo Raíz `Level8`
```text
script = ExtResource("3_script")
starting_snitches = 150
total_enemies = 45
is_special_level = true
next_level_to_unlock = 9
active_rows = Array[int]([2, 3, 4, 5, 6])
dementor_row_cells = Array[int]([2, 3, 4, 5, 6])
enemy_scenes = [
  ExtResource("slytherin_student"),
  ExtResource("draco"),
  ExtResource("protego_student"),
  ExtResource("slytherin_prefect")
]
```
