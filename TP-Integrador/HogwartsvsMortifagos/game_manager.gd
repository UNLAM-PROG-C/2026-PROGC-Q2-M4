extends Node

## Session progression shared by the levels and the level select menu (autoload).

const INITIAL_UNLOCKED_LEVEL: int = 10
const CustomCursor = preload("res://custom_cursor.gd")
const CURSOR_SCENE: PackedScene = preload("res://custom_cursor.tscn")
const BACKGROUND_MUSIC_PATH: String = "res://music/harry_potter_song.mp3"
const MUSIC_PLAYER_NODE_NAME: String = "BackgroundMusicPlayer"
const DEFAULT_MUSIC_VOLUME: float = 1.0
const MIN_AUDIBLE_VOLUME: float = 0.001
const MUTED_VOLUME_DB: float = -80.0

var max_unlocked_level: int = INITIAL_UNLOCKED_LEVEL
var debug_mode: bool = false
var claimed_rewards: Dictionary = {}
var _custom_cursor: Node = null
var _music_player: AudioStreamPlayer = null
var _music_volume: float = DEFAULT_MUSIC_VOLUME


func _ready() -> void:
	_setup_custom_cursor()
	_setup_background_music()


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


func unlock_level(level_number: int) -> void:
	max_unlocked_level = maxi(max_unlocked_level, level_number)


func claim_reward(level_number: int) -> void:
	claimed_rewards[level_number] = true


func is_reward_claimed(level_number: int) -> bool:
	return claimed_rewards.has(level_number)
