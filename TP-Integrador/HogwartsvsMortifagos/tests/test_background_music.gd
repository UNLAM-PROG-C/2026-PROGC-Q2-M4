extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const EXPECTED_MUSIC_PATH: String = "res://music/harry_potter_song.mp3"
const EXPECTED_NODE_NAME: String = "BackgroundMusicPlayer"


func _initialize() -> void:
	print("--- Running Test Background Music ---")
	_run_tests()


func _run_tests() -> void:
	await process_frame
	await _test_music_player_setup()
	await _test_pause_preservation()
	await _test_loop_mechanism()
	await _test_scene_change_persistence()
	print("--- All Background Music Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_scene_change_persistence() -> void:
	print("Testing background music persistence across scene changes...")
	var game_manager_node: Node = root.get_node_or_null("GameManager")
	var player: AudioStreamPlayer = game_manager_node.get_node_or_null(EXPECTED_NODE_NAME) as AudioStreamPlayer
	var scene: PackedScene = load("res://level_1.tscn") as PackedScene
	var level_instance: Node = scene.instantiate()
	root.add_child(level_instance)
	await process_frame
	assert(player != null and player.playing, "Music must keep playing when level is loaded")
	level_instance.queue_free()
	await process_frame
	assert(player != null and player.playing, "Music must keep playing after level is freed")
	print("Scene change persistence PASSED.")


func _test_music_player_setup() -> void:
	print("Testing GameManager background music player initialization...")
	var game_manager_node: Node = root.get_node_or_null("GameManager")
	assert(game_manager_node != null, "GameManager autoload must exist in root")
	var player: AudioStreamPlayer = game_manager_node.get_node_or_null(EXPECTED_NODE_NAME) as AudioStreamPlayer
	assert(player != null, "BackgroundMusicPlayer must be instantiated as child of GameManager")
	assert(player.stream != null, "Audio stream must not be null")
	assert(player.stream is AudioStreamMP3, "Audio stream must be an AudioStreamMP3")
	var mp3_stream: AudioStreamMP3 = player.stream as AudioStreamMP3
	assert(mp3_stream.loop, "Audio stream loop property must be true")
	assert(player.process_mode == Node.PROCESS_MODE_ALWAYS, "Process mode must be PROCESS_MODE_ALWAYS")
	assert(player.bus == &"Master", "Audio bus must be Master")
	assert(player.playing, "Background music player must be playing")
	print("GameManager background music player initialization PASSED.")


func _test_pause_preservation() -> void:
	print("Testing background music during tree pause...")
	var game_manager_node: Node = root.get_node_or_null("GameManager")
	var player: AudioStreamPlayer = game_manager_node.get_node_or_null(EXPECTED_NODE_NAME) as AudioStreamPlayer
	paused = true
	await process_frame
	assert(player.process_mode == Node.PROCESS_MODE_ALWAYS, "Player must maintain PROCESS_MODE_ALWAYS")
	assert(player.can_process(), "Player must be able to process while paused")
	paused = false
	await process_frame
	print("Pause preservation PASSED.")


func _test_loop_mechanism() -> void:
	print("Testing music loop and finished signal reconnection...")
	var game_manager_node: Node = root.get_node_or_null("GameManager")
	var player: AudioStreamPlayer = game_manager_node.get_node_or_null(EXPECTED_NODE_NAME) as AudioStreamPlayer
	assert(player.finished.is_connected(game_manager_node._on_music_finished), "finished must be connected")
	player.stop()
	assert(not player.playing, "Player stopped")
	player.finished.emit()
	assert(player.playing, "Player must resume playing after finished signal")
	print("Music loop mechanism PASSED.")
