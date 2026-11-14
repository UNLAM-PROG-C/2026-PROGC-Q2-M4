class_name SoundTable
extends Resource

@export var name: String = ""
@export var variants: Dictionary = {}

func get_sound_for(variant: String) -> String:
    if variant == "" or variant == null:
        variant = "main"
    if variants.has(variant):
        return variants[variant]
    return ""
