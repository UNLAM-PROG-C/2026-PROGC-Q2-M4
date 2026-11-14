class_name SoundEnvironment
extends Node

@export var sound_service: SoundService = null
@export var sound_volume_controller: SoundVolumeController = null

func _ready() -> void:
    _initialize_volume_controller()
    _initialize_sound_service()
    _initialize_registry()
    _load_sound_tables()

func _initialize_volume_controller() -> void:
    if sound_volume_controller != null:
        return

    sound_volume_controller = SoundVolumeController.new()
    add_child(sound_volume_controller)


func _initialize_sound_service() -> void:
    if sound_service != null:
        return

    sound_service = SoundService.new()
    sound_service.sound_volume_controller = sound_volume_controller
    add_child(sound_service)


func _initialize_registry() -> void:
    if sound_service._registry == null:
        sound_service.set_registry(SoundAssetCatalog.new())


func _load_sound_tables() -> void:
    var directory_path := "res://sounds/tables"
    var files := DirAccess.get_files_at(directory_path)

    for file in files:
        if file.ends_with(".tres"):
            _register_sound_table(directory_path, file)


func _register_sound_table(directory_path: String, file: String) -> void:
    var path := directory_path + "/" + file
    var table := load(path) as SoundTable

    if table != null:
        sound_service._registry.register_table(table)
