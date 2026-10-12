class_name BossHealthBar
extends Control

const BOSS_NAME_TEXT: String = "PROFESOR QUIRRELL"
const DEFAULT_MAX_HEALTH: float = 36000.0
const HEALTH_LABEL_FORMAT: String = "%d / %d"

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var title_label: Label = $TitleLabel
@onready var health_label: Label = $HealthLabel


func _ready() -> void:
	if title_label != null:
		title_label.text = BOSS_NAME_TEXT
	initialize_bar(DEFAULT_MAX_HEALTH)


func initialize_bar(max_hp: float) -> void:
	if progress_bar != null:
		progress_bar.max_value = max_hp
		progress_bar.value = max_hp
	_update_health_label(max_hp, max_hp)


func set_health(current_hp: float) -> void:
	if progress_bar != null:
		progress_bar.value = clampf(current_hp, 0.0, progress_bar.max_value)
		_update_health_label(progress_bar.value, progress_bar.max_value)


func _update_health_label(current: float, max_hp: float) -> void:
	if health_label != null:
		health_label.text = HEALTH_LABEL_FORMAT % [int(current), int(max_hp)]
