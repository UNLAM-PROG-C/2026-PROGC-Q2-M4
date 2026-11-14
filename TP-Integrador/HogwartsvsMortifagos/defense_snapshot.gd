class_name DefenseSnapshot
extends RefCounted

var ally_value: float = 0.0
var spell_value: float = 0.0
var total_value: float = 0.0

func set_values(allies: float, spells: float) -> void:
	ally_value = maxf(allies, 0.0)
	spell_value = maxf(spells, 0.0)
	total_value = ally_value + spell_value
