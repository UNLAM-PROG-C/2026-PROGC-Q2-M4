extends SceneTree

const EXIT_OK: int = 0
const TEST_SAVE_PATH: String = "user://test_progress_save.cfg"
const UNLOCKED_LEVEL: int = 4
const CLAIMED_LEVEL: int = 3


func _initialize() -> void:
	print("--- Running Progress Save Tests ---")
	_remove_save()
	_test_fresh_session_starts_at_level_one()
	_test_unlock_and_reward_survive_reload()
	_remove_save()
	print("--- All Progress Save Tests Passed ---")
	quit(EXIT_OK)


func _test_fresh_session_starts_at_level_one() -> void:
	var session: GameSession = _new_session()
	assert(session.max_unlocked_level == GameSession.INITIAL_UNLOCKED_LEVEL, "A new session starts at level 1")
	assert(session.claimed_rewards.is_empty(), "A new session has no claimed rewards")
	session.free()


func _test_unlock_and_reward_survive_reload() -> void:
	var first: GameSession = _new_session()
	first.unlock_level(UNLOCKED_LEVEL)
	first.claim_reward(CLAIMED_LEVEL)
	first.free()
	var second: GameSession = _new_session()
	assert(second.max_unlocked_level == UNLOCKED_LEVEL, "Unlocked level must be reloaded")
	assert(second.is_reward_claimed(CLAIMED_LEVEL), "Claimed reward must be reloaded")
	assert(not second.is_reward_claimed(UNLOCKED_LEVEL), "Unclaimed reward stays unclaimed")
	second.free()


func _new_session() -> GameSession:
	var session: GameSession = GameSession.new()
	session.save_path = TEST_SAVE_PATH
	session._load_progress()
	return session


func _remove_save() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
