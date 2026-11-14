class_name SoundServiceLoader
extends Node

@export var sound_service: SoundService = null
@export var sound_catalog: SoundAssetCatalog = null
@export var sound_volume_controller: SoundVolumeController = null
@export var table_dir: String = "res://sounds/tables"

func _ready() -> void:
    if sound_service == null:
        push_error("SoundServiceLoader: sound_service is null")
        return
    if sound_catalog == null:
        sound_catalog = SoundAssetCatalog.new()
        sound_catalog.registry = SoundRegistry.new()
        sound_catalog.root_dir = table_dir
        sound_catalog._load_all_tables()

    if sound_volume_controller == null:
        sound_volume_controller = SoundVolumeController.new()

    if sound_service._registry == null:
        sound_service.set_registry(sound_catalog.registry)
