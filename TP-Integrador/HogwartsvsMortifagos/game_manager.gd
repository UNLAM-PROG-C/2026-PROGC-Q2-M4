class_name GameSession
extends Node

## Session progression shared by the levels and the level select menu (autoload).
## The class is named GameSession because the autoload node is called GameManager
## and a class_name cannot hide an autoload singleton.

const INITIAL_UNLOCKED_LEVEL: int = 1
const DEFAULT_SAVE_PATH: String = "user://progress.cfg"
const SAVE_SECTION: String = "progress"
const UNLOCKED_KEY: String = "max_unlocked_level"
const REWARDS_KEY: String = "claimed_rewards"
const CURSOR_SCENE: PackedScene = preload("res://custom_cursor.tscn")
const BACKGROUND_MUSIC_PATH: String = "res://music/harry_potter_song.mp3"
const MUSIC_PLAYER_NODE_NAME: String = "BackgroundMusicPlayer"
const DEFAULT_MUSIC_VOLUME: float = 1.0
const MIN_AUDIBLE_VOLUME: float = 0.001
const MUTED_VOLUME_DB: float = -80.0

var max_unlocked_level: int = INITIAL_UNLOCKED_LEVEL
var debug_mode: bool = false
var claimed_rewards: Dictionary[int, bool] = {}
var save_path: String = DEFAULT_SAVE_PATH
var _custom_cursor: Node = null
var _music_player: AudioStreamPlayer = null
var _music_volume: float = DEFAULT_MUSIC_VOLUME
var sound_service: SoundService = null


func _ready() -> void:
    _load_progress()
    _setup_custom_cursor()
    _setup_background_music()
    _setup_sound_system()


func _setup_sound_system() -> void:
    
    var catalog := SoundAssetCatalog.new()
    catalog.registry = SoundRegistry.new()
    catalog.root_dir = "res://sounds/tables"
    catalog._load_all_tables()
    
    # Delay sound service addition to ensure proper class resolution
    get_tree().create_timer(0.01).timeout.connect(_delayed_setup_sound)
    
func _delayed_setup_sound() -> void:
    var service := SoundService.new()
    var registry := SoundRegistry.new()
    service.set_registry(registry)
    add_child(service)
    sound_service = service


func _setup_custom_cursor() -> void:
    if _custom_cursor == null:
        _custom_cursor = CURSOR_SCENE.instantiate()
        add_child(_custom_cursor)


func _setup_background_music() -> void:
    if _music_player != null:
        return
    var stream: AudioStreamMP3 = load(BACKGROUND_MUSIC_PATH) as AudioStreamMP3
    if stream == null:
        return
    stream.loop = true
    _create_music_player(stream)


func _create_music_player(stream: AudioStreamMP3) -> void:
    _music_player = AudioStreamPlayer.new()
    _music_player.name = MUSIC_PLAYER_NODE_NAME
    _music_player.stream = stream
    _music_player.process_mode = Node.PROCESS_MODE_ALWAYS
    _music_player.bus = &"Master"
    _music_player.finished.connect(_on_music_finished)
    add_child(_music_player)
    set_music_volume(_music_volume)
    _music_player.play()


func _on_music_finished() -> void:
    if _music_player != null and not _music_player.playing:
        _music_player.play()


func set_music_volume(volume: float) -> void:
    _music_volume = clampf(volume, 0.0, 1.0)
    if _music_player != null:
        if _music_volume <= MIN_AUDIBLE_VOLUME:
            _music_player.volume_db = MUTED_VOLUME_DB
        else:
            _music_player.volume_db = linear_to_db(_music_volume)


func get_music_volume() -> float:
    return _music_volume


func get_music_player() -> AudioStreamPlayer:
    return _music_player


func _load_progress() -> void:
    var config: ConfigFile = ConfigFile.new()
    if config.load(save_path) != OK:
        return
    max_unlocked_level = int(config.get_value(SAVE_SECTION, UNLOCKED_KEY, INITIAL_UNLOCKED_LEVEL))
    _read_rewards(config)


func _read_rewards(config: ConfigFile) -> void:
    var stored: Variant = config.get_value(SAVE_SECTION, REWARDS_KEY, {})
    if typeof(stored) != TYPE_DICTIONARY:
        return
    var table: Dictionary = stored
    for key: Variant in table.keys():
        claimed_rewards[int(key)] = true


func _save_progress() -> void:
    var config: ConfigFile = ConfigFile.new()
    config.set_value(SAVE_SECTION, UNLOCKED_KEY, max_unlocked_level)
    config.set_value(SAVE_SECTION, REWARDS_KEY, claimed_rewards)
    config.save(save_path)


func unlock_level(level_number: int) -> void:
    max_unlocked_level = maxi(max_unlocked_level, level_number)
    _save_progress()


func claim_reward(level_number: int) -> void:
    claimed_rewards[level_number] = true
    _save_progress()


func is_reward_claimed(level_number: int) -> bool:
    return claimed_rewards.has(level_number)
