class_name SoundRegistry
extends RefCounted

## Catálogo de tablas de sonido por nombre de evento.
static var tables: Dictionary = {}

func register_table(table: SoundTable) -> void:
    if table == null:
        return
    if table.name == "":
        push_error("SoundRegistry: SoundTable has no name")
        return
    tables[table.name] = table

func get_table(event_name: String) -> SoundTable:
    return tables.get(event_name, null)

func get_sound_for(event_name: String, variant: String = "main") -> String:
    var table := get_table(event_name)
    if table == null:
        return ""
    return table.get_sound_for(variant)
