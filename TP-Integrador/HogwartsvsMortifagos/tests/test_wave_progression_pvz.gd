extends SceneTree

const EXIT_OK: int = 0
const EXIT_ERROR: int = 1
const LEVEL_1_PHASE_QUOTA: int = 5
const LEVEL_1_TOTAL: int = 10
const LEVEL_8_PHASE_QUOTA: int = 15
const UNEQUAL_FIRST_QUOTA: int = 10
const UNEQUAL_SECOND_QUOTA: int = 40


func _initialize() -> void:
	print("--- Running Test Wave Progression PvZ ---")
	_run_all_tests()


func _run_all_tests() -> void:
	await _test_two_wave_fractions()
	await _test_wave_does_not_start_with_active_enemies()
	await _test_wave_enemies_do_not_count_in_meter()
	await _test_final_wave_screen_clear_and_win()
	await _test_three_wave_thresholds()
	await _test_meter_textures()
	await _test_unequal_thresholds_are_not_averaged()
	print("--- All Wave Progression PvZ Tests Passed Successfully! ---")
	quit(EXIT_OK)


func _create_level(scene_path: String) -> Level:
	var scene: PackedScene = load(scene_path)
	assert(scene != null, "Scene %s failed to load" % scene_path)
	var lvl: Level = scene.instantiate() as Level
	root.add_child(lvl)
	return lvl


func _test_two_wave_fractions() -> void:
	var lvl: Level = _create_level("res://level_1.tscn")
	await process_frame
	assert(lvl.wave_kill_thresholds.size() == 2, "Level 1 must have 2 waves")
	assert(lvl.call("_get_phase_threshold", 0) == LEVEL_1_PHASE_QUOTA, "Phase 0 keeps the authored quota")
	assert(lvl.call("_get_phase_threshold", 1) == LEVEL_1_PHASE_QUOTA, "Phase 1 keeps the authored quota")
	lvl.set("_phase_defeated_enemies", 3)
	assert(lvl.call("_get_current_meter_progress") == 3, "Meter should reflect 3 kills")
	lvl.set("_phase_defeated_enemies", 10)
	assert(lvl.call("_get_current_meter_progress") == LEVEL_1_PHASE_QUOTA, "Meter caps at the phase quota")
	lvl.queue_free()
	await process_frame


func _test_wave_does_not_start_with_active_enemies() -> void:
	var lvl: Level = _create_level("res://level_1.tscn")
	await process_frame
	lvl.set("_active_enemies", 2)
	lvl.set("_phase_defeated_enemies", LEVEL_1_PHASE_QUOTA)
	lvl.call("_reach_wave_threshold")
	await _ensure_wave_plan_ready(lvl)
	assert(lvl.get("_wave_state") == WaveState.Value.WAVE_PREPARATION, "Must be in preparation")
	assert(lvl.enemy_spawn_timer.is_stopped(), "Spawn timer must stop at threshold")
	assert(lvl.call("_get_current_meter_progress") == LEVEL_1_PHASE_QUOTA, "Meter must stay pinned at 50%")
	lvl.call("_on_enemy_defeated", _make_dummy_enemy(lvl, true))
	assert(lvl.get("_wave_state") == WaveState.Value.WAVE_PREPARATION, "Wave must wait for 0 enemies")
	lvl.call("_on_enemy_defeated", _make_dummy_enemy(lvl, true))
	assert(lvl.get("_wave_state") == WaveState.Value.WAVE_ACTIVE, "Wave must start when active is 0")
	lvl.queue_free()
	await process_frame


func _ensure_wave_plan_ready(lvl: Level) -> void:
	for _i: int in range(30):
		if lvl.get("_pending_wave_plan") != null:
			return
		lvl.call("_poll_wave_future")
		await process_frame


func _make_dummy_enemy(lvl: Level, is_regular: bool) -> Node2D:
	var dummy: Node2D = Node2D.new()
	lvl.add_child(dummy)
	lvl.get("_regular_enemy_ids")[dummy.get_instance_id()] = is_regular
	return dummy


func _test_wave_enemies_do_not_count_in_meter() -> void:
	var lvl: Level = _create_level("res://level_1.tscn")
	await process_frame
	lvl.set("_current_phase_index", 0)
	lvl.set("_phase_defeated_enemies", LEVEL_1_PHASE_QUOTA)
	lvl.set("_total_defeated_enemies", LEVEL_1_PHASE_QUOTA)
	lvl.set("_wave_state", WaveState.Value.WAITING_FOR_CLEAR)
	var wave_enemy: Node2D = _make_dummy_enemy(lvl, false)
	lvl.set("_active_enemies", 1)
	lvl.call("_on_enemy_defeated", wave_enemy)
	assert(lvl.get("_total_defeated_enemies") == LEVEL_1_PHASE_QUOTA, "Wave enemy defeat must NOT add total kill")
	assert(lvl.call("_get_current_meter_progress") == LEVEL_1_PHASE_QUOTA, "Meter must not move during wave")
	assert(lvl.get("_wave_state") == WaveState.Value.SPAWNING_NORMAL, "Must resume regular phase")
	assert(lvl.get("_current_phase_index") == 1, "Phase must advance to 1")
	lvl.queue_free()
	await process_frame


func _test_final_wave_screen_clear_and_win() -> void:
	var lvl: Level = _create_level("res://level_1.tscn")
	await process_frame
	lvl.set("_current_phase_index", 1)
	lvl.set("_phase_defeated_enemies", LEVEL_1_PHASE_QUOTA)
	lvl.set("_total_defeated_enemies", LEVEL_1_TOTAL)
	lvl.set("_active_enemies", 1)
	lvl.call("_reach_wave_threshold")
	await _ensure_wave_plan_ready(lvl)
	assert(lvl.get("_wave_state") == WaveState.Value.FINAL_WAVE_PREPARATION, "State must be final prep")
	assert(lvl.call("_get_current_meter_progress") == LEVEL_1_TOTAL, "Meter must be 100% full")
	lvl.call("_on_enemy_defeated", _make_dummy_enemy(lvl, true))
	assert(lvl.get("_wave_state") == WaveState.Value.WAVE_ACTIVE, "Final wave must start at 0 active")
	lvl.queue_free()
	await process_frame


func _test_three_wave_thresholds() -> void:
	var lvl: Level = _create_level("res://level_8.tscn")
	await process_frame
	assert(lvl.wave_kill_thresholds.size() == 3, "Level 8 must have 3 waves")
	assert(lvl.call("_get_phase_threshold", 0) == LEVEL_8_PHASE_QUOTA, "Phase 0 keeps the authored quota")
	assert(lvl.call("_get_phase_threshold", 1) == LEVEL_8_PHASE_QUOTA, "Phase 1 keeps the authored quota")
	assert(lvl.call("_get_phase_threshold", 2) == LEVEL_8_PHASE_QUOTA, "Phase 2 keeps the authored quota")
	lvl.set("_current_phase_index", 1)
	lvl.set("_phase_defeated_enemies", 5)
	assert(lvl.call("_get_current_meter_progress") == 20, "Meter progress must sum base + phase")
	lvl.queue_free()
	await process_frame


func _test_meter_textures() -> void:
	var lvl1: Level = _create_level("res://level_1.tscn")
	await process_frame
	var bar1: WaveProgressBar = lvl1.get("_wave_progress_bar") as WaveProgressBar
	assert(bar1.get_frame_texture().resource_path == "res://Images/wave_meter_2_waves.png")
	assert(bar1.get_progress_texture().resource_path == "res://Images/wave_charge_1_wave.png")
	lvl1.queue_free()
	await process_frame
	var lvl8: Level = _create_level("res://level_8.tscn")
	await process_frame
	var bar8: WaveProgressBar = lvl8.get("_wave_progress_bar") as WaveProgressBar
	assert(bar8.get_frame_texture().resource_path == "res://Images/wave_meter_3_waves.png")
	assert(bar8.get_progress_texture().resource_path == "res://Images/wave_charge_2_waves.png")
	lvl8.queue_free()
	await process_frame


func _test_unequal_thresholds_are_not_averaged() -> void:
	var lvl: Level = _create_level("res://level_1.tscn")
	await process_frame
	lvl.wave_kill_thresholds = [UNEQUAL_FIRST_QUOTA, UNEQUAL_SECOND_QUOTA] as Array[int]
	lvl.call("_calculate_total_level_kills")
	assert(lvl.call("_get_phase_threshold", 0) == UNEQUAL_FIRST_QUOTA, "Phase 0 keeps its authored quota")
	assert(lvl.call("_get_phase_threshold", 1) == UNEQUAL_SECOND_QUOTA, "Phase 1 keeps its authored quota")
	lvl.set("_current_phase_index", 1)
	lvl.set("_phase_defeated_enemies", 5)
	assert(lvl.call("_get_current_meter_progress") == UNEQUAL_FIRST_QUOTA + 5, "Meter adds the real phase quotas")
	lvl.queue_free()
	await process_frame
