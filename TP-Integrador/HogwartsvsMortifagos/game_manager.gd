extends Node

## Session progression shared by the levels and the level select menu (autoload).

## Highest unlocked level when the game starts (every level is open today).
const INITIAL_UNLOCKED_LEVEL: int = 10

var max_unlocked_level: int = INITIAL_UNLOCKED_LEVEL


func unlock_level(level_number: int) -> void:
	max_unlocked_level = maxi(max_unlocked_level, level_number)
