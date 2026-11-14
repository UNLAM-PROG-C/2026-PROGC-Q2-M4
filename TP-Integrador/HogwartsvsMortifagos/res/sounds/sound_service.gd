class_name SoundService
extends Node

signal sound_played(name: String, variant: String, position: Vector3, volume: float)
signal system_shutdown()

const MAX_ACTIVE_SOUNDS: int = 10
const VOLUME: float = 1
@export var max_active_sounds = MAX_ACTIVE_SOUNDS

var _registry: SoundRegistry = null
var _active_count: int = 0
var _free_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
    if _registry == null:
        _registry = SoundRegistry.new()

func set_registry(registry: SoundRegistry) -> void:
    _registry = registry

func play(event_name: String, variant: String = "main", position: Vector3 = Vector3.ZERO) -> void:
    if not _is_valid_event(event_name):
        return

    var resolved_path := _resolve_sound_path(event_name, variant)
    if resolved_path == "":
        return

    if not _has_available_capacity(event_name):
        return

    var volume = VOLUME
    var effective_volume := _resolve_volume(volume)
    _play_sound(resolved_path, effective_volume, event_name, variant, position)


func _is_valid_event(event_name: String) -> bool:
    return event_name != "" and is_instance_valid(self)


func _resolve_sound_path(event_name: String, variant: String) -> String:
    var path := _registry.get_sound_for(event_name, variant)

    if path == "":
        push_error("SoundService: sound not found for event '%s' with variant '%s'" % [event_name, variant])
        return ""

    return path


func _has_available_capacity(event_name: String) -> bool:
    if _active_count >= max_active_sounds:
        push_error("SoundService: audio saturation, event '%s' ignored" % event_name)
        return false

    return true


func _resolve_volume(volume: float) -> float:
    return volume


func _play_sound(path: String, volume: float, event_name: String, variant: String, position: Vector3) -> void:
    var player := _get_audio_player()

    if player == null:
        player = AudioStreamPlayer.new()
        add_child(player)

    var stream := load(path) as AudioStream
    if stream == null:
        push_error("SoundService: failed to load audio '%s'" % path)
        return

    _active_count += 1
    player.stream = stream
    player.volume_db = linear_to_db(volume)
    player.finished.connect(_on_sound_finished.bind(player))
    player.play()

    sound_played.emit(event_name, variant, position, volume)

func _get_audio_player() -> AudioStreamPlayer:
    var available: AudioStreamPlayer = _free_players.pop_front()
    if available != null and is_instance_valid(available):
        return available
    return null

func _on_sound_finished(player: AudioStreamPlayer) -> void:
    player.finished.disconnect(_on_sound_finished)
    _active_count -= 1
    _free_players.append(player)
