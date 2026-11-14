extends SceneTree

## Automated headless test for RewardCatalog and RewardUnlockScreen.

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1


func _init() -> void:
	print("--- Running Reward Unlock Test Suite ---")
	_test_catalog_levels_1_to_4()
	_test_catalog_levels_5_to_8()
	_test_catalog_special_levels()
	_test_game_manager_claiming()
	_test_screen_instance_and_skip()
	print("--- All Reward Unlock Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _test_catalog_levels_1_to_4() -> void:
	var r1: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(1)
	assert(r1 != null and r1.item_name == "Remembrall", "Level 1 reward mismatch")
	assert(r1.texture != null and r1.description_text == RewardCatalog.LEVEL_1_DESC_TEXT)
	var r2: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(2)
	assert(r2 != null and r2.item_name == "Protego", "Level 2 reward mismatch")
	var r3: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(3)
	assert(r3 != null and r3.item_name == "Accio", "Level 3 reward mismatch")
	var r4: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(4)
	assert(r4 != null and r4.item_name == "Ron", "Level 4 reward mismatch")


func _test_catalog_levels_5_to_8() -> void:
	var r5: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(5)
	assert(r5 != null and r5.item_name == "Broomstick", "Level 5 reward mismatch")
	var r6: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(6)
	assert(r6 != null and r6.item_name == "Hermione", "Level 6 reward mismatch")
	var r7: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(7)
	assert(r7 != null and r7.item_name == "McGonagall", "Level 7 reward mismatch")
	var r8: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(8)
	assert(r8 != null and r8.item_name == "Dumbledore", "Level 8 reward mismatch")


func _test_catalog_special_levels() -> void:
	var r9: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(9)
	assert(r9 == null, "Level 9 must have null reward")
	var r10: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(10)
	assert(r10 != null and r10.item_name == "PhilosophersStone", "Level 10 reward mismatch")
	assert(r10.texture != null, "Level 10 texture must not be null")
	assert(r10.description_text == RewardCatalog.LEVEL_10_DESC_TEXT)


func _test_game_manager_claiming() -> void:
	var gm: Node = Node.new()
	gm.set_script(preload("res://game_manager.gd"))
	assert(not gm.is_reward_claimed(1), "Reward 1 should not be claimed yet")
	gm.claim_reward(1)
	assert(gm.is_reward_claimed(1), "Reward 1 should now be claimed")
	gm.free()


func _test_screen_instance_and_skip() -> void:
	var scene: PackedScene = preload("res://reward_unlock_screen.tscn")
	var screen: RewardUnlockScreen = scene.instantiate() as RewardUnlockScreen
	root.add_child(screen)
	var r1: RewardCatalog.RewardData = RewardCatalog.get_reward_for_level(1)
	screen.setup(1, r1.texture, r1.description_text)
	assert(screen._state == RewardUnlockScreen.STATE_ANIMATING, "Screen should be animating")
	screen.skip_animation()
	assert(screen._state == RewardUnlockScreen.STATE_RESTING, "Screen should be resting after skip")
	assert(screen.continue_button.visible, "Continue button must be visible after skip")
	screen.queue_free()
