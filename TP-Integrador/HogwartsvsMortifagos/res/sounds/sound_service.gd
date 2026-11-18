class_name SoundService
extends Node

signal sound_played(name: String, variant: String, position: Vector3, volume: float)
signal system_shutdown()

const MAX_ACTIVE_SOUNDS: int = 10
const VOLUME: float = 1.0

@export var max_active_sounds: int = MAX_ACTIVE_SOUNDS

var _registry: SoundRegistry = null
var _free_players: Array[AudioStreamPlayer] = []
var _active_players: Array[AudioStreamPlayer] = []
var _finish_callbacks: Dictionary[AudioStreamPlayer, Callable] = {}


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
    _ensure_capacity()
    _play_sound(resolved_path, VOLUME, event_name, variant, position)


func _is_valid_event(event_name: String) -> bool:
    return event_name != "" and is_instance_valid(self)


func _resolve_sound_path(event_name: String, variant: String) -> String:
    var path := _registry.get_sound_for(event_name, variant)
    if path == "":
        push_error("SoundService: sound not found for event '%s' with variant '%s'" % [event_name, variant])
        return ""
    return path


## Reuses the oldest voice once the cap is full so a new event still plays.
func _ensure_capacity() -> void:
    if _active_players.size() < max_active_sounds:
        return
    _recycle_oldest_player()


func _recycle_oldest_player() -> void:
    if _active_players.is_empty():
        return
    var oldest: AudioStreamPlayer = _active_players[0]
    _disconnect_finished(oldest)
    _retire_player(oldest, true)


func _retire_player(player: AudioStreamPlayer, force_stop: bool) -> void:
    if not _active_players.has(player):
        return
    _active_players.erase(player)
    if force_stop:
        player.stop()
    _free_players.append(player)


func _disconnect_finished(player: AudioStreamPlayer) -> void:
    if not _finish_callbacks.has(player):
        return
    var callback: Callable = _finish_callbacks[player]
    _finish_callbacks.erase(player)
    if player.finished.is_connected(callback):
        player.finished.disconnect(callback)


func _play_sound(path: String, volume: float, event_name: String, variant: String, position: Vector3) -> void:
    var player := _take_player()
    var stream := load(path) as AudioStream
    if stream == null:
        push_error("SoundService: failed to load audio '%s'" % path)
        _free_players.append(player)
        return
    _start_playback(player, stream, volume, event_name, variant, position)


func _start_playback(player: AudioStreamPlayer, stream: AudioStream, volume: float, event_name: String, variant: String, position: Vector3) -> void:
    _active_players.append(player)
    player.stream = stream
    player.volume_db = linear_to_db(volume)
    _connect_finished(player)
    player.play()
    sound_played.emit(event_name, variant, position, volume)


func _connect_finished(player: AudioStreamPlayer) -> void:
    var callback := _on_sound_finished.bind(player)
    _finish_callbacks[player] = callback
    if not player.finished.is_connected(callback):
        player.finished.connect(callback, CONNECT_ONE_SHOT)


func _take_player() -> AudioStreamPlayer:
    if _free_players.is_empty():
        return _create_player()
    var available: AudioStreamPlayer = _free_players.pop_front()
    if is_instance_valid(available):
        return available
    return _create_player()


func _create_player() -> AudioStreamPlayer:
    var created := AudioStreamPlayer.new()
    add_child(created)
    return created


func _on_sound_finished(player: AudioStreamPlayer) -> void:
    _finish_callbacks.erase(player)
    _retire_player(player, false)
