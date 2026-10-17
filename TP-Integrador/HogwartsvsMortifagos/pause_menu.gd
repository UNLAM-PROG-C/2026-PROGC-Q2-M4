class_name PauseMenu
extends Control

## Pause menu displayed across all levels in the top-right corner.
## Can be toggled with the pause button or the Escape key.

signal pause_requested
signal resume_requested
signal retry_requested
signal back_to_map_requested

const PAUSE_SYMBOL_TEXT: String = "❚ ❚"
const PAUSE_TITLE_TEXT: String = "PAUSA"
const VOLUME_LABEL_TEXT: String = "Volumen de fondo"
const RESUME_BUTTON_TEXT: String = "Reanudar"
const RETRY_BUTTON_TEXT: String = "Reiniciar nivel"
const BACK_TO_MAP_BUTTON_TEXT: String = "Volver al Mapa"

@onready var pause_button: Button = $PauseButton
@onready var modal_overlay: Control = $ModalOverlay
@onready var title_label: Label = $ModalOverlay/ModalBox/VBox/TitleLabel
@onready var volume_label: Label = $ModalOverlay/ModalBox/VBox/VolumeContainer/VolumeLabel
@onready var volume_slider: HSlider = $ModalOverlay/ModalBox/VBox/VolumeContainer/VolumeSlider
@onready var resume_button: Button = $ModalOverlay/ModalBox/VBox/ResumeButton
@onready var retry_button: Button = $ModalOverlay/ModalBox/VBox/RetryButton
@onready var back_to_map_button: Button = $ModalOverlay/ModalBox/VBox/BackToMapButton

var _is_paused: bool = false
var _enabled: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_labels()
	_connect_button_signals()
	_sync_volume_slider()
	if modal_overlay != null:
		modal_overlay.visible = false


func _setup_labels() -> void:
	if pause_button != null:
		pause_button.text = PAUSE_SYMBOL_TEXT
	if title_label != null:
		title_label.text = PAUSE_TITLE_TEXT
	if volume_label != null:
		volume_label.text = VOLUME_LABEL_TEXT
	if resume_button != null:
		resume_button.text = RESUME_BUTTON_TEXT
	if retry_button != null:
		retry_button.text = RETRY_BUTTON_TEXT
	if back_to_map_button != null:
		back_to_map_button.text = BACK_TO_MAP_BUTTON_TEXT


func _connect_button_signals() -> void:
	if pause_button != null and not pause_button.pressed.is_connected(_on_pause_button_pressed):
		pause_button.pressed.connect(_on_pause_button_pressed)
	if resume_button != null and not resume_button.pressed.is_connected(_on_resume_button_pressed):
		resume_button.pressed.connect(_on_resume_button_pressed)
	if retry_button != null and not retry_button.pressed.is_connected(_on_retry_button_pressed):
		retry_button.pressed.connect(_on_retry_button_pressed)
	if back_to_map_button != null and not back_to_map_button.pressed.is_connected(_on_back_to_map_button_pressed):
		back_to_map_button.pressed.connect(_on_back_to_map_button_pressed)
	_connect_volume_slider()


func _connect_volume_slider() -> void:
	if volume_slider != null and not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
		volume_slider.value_changed.connect(_on_volume_slider_value_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return
	if _is_escape_event(event):
		get_viewport().set_input_as_handled()
		_toggle_pause()


func _is_escape_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		return key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE
	return false


func _toggle_pause() -> void:
	if _is_paused:
		resume()
	else:
		pause()


func pause() -> void:
	if _is_paused or not _enabled:
		return
	_is_paused = true
	get_tree().paused = true
	_sync_volume_slider()
	if modal_overlay != null:
		modal_overlay.visible = true
	pause_requested.emit()


func resume() -> void:
	if not _is_paused:
		return
	_is_paused = false
	get_tree().paused = false
	if modal_overlay != null:
		modal_overlay.visible = false
	resume_requested.emit()


func _sync_volume_slider() -> void:
	if volume_slider == null:
		return
	var manager: Node = _get_game_manager()
	if manager != null and manager.has_method("get_music_volume"):
		volume_slider.value = manager.call("get_music_volume")


func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")


func _on_volume_slider_value_changed(value: float) -> void:
	var manager: Node = _get_game_manager()
	if manager != null and manager.has_method("set_music_volume"):
		manager.call("set_music_volume", value)


func _on_pause_button_pressed() -> void:
	_toggle_pause()


func _on_resume_button_pressed() -> void:
	resume()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	retry_requested.emit()


func _on_back_to_map_button_pressed() -> void:
	get_tree().paused = false
	back_to_map_requested.emit()


func is_paused() -> bool:
	return _is_paused


func is_enabled() -> bool:
	return _enabled


func set_enabled(p_enabled: bool) -> void:
	_enabled = p_enabled
	if pause_button != null:
		pause_button.visible = p_enabled
	if not _enabled and _is_paused:
		resume()
