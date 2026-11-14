class_name SoundAssetCatalog
extends RefCounted

var registry: SoundRegistry = null
var root_dir: String = "res://res/sounds/tables"

func _ready() -> void:
    if registry == null:
        push_error("SoundAssetCatalog requires a SoundRegistry reference")
        return
    _load_all_tables()

func _load_all_tables() -> void:
    var script_dir = get_script().resource_path.get_base_dir()
    var tables_dir = script_dir + "/tables/"
    var dir: DirAccess = DirAccess.open(tables_dir)
    if dir == null:
        push_error("SoundAssetCatalog: cannot open directory " + root_dir)
        return

    var files: Array = dir.get_files()
    for file in files:
        if not file.ends_with(".tres"):
            continue

        var path: String = tables_dir + file
        var table: SoundTable = load(path) as SoundTable
        if table == null:
            push_error("SoundAssetCatalog: failed to load SoundTable at " + path)
        else:
            registry.register_table(table)

func load_table(event_name: String) -> SoundTable:
    if registry == null:
        return null
    return registry.get_table(event_name)
