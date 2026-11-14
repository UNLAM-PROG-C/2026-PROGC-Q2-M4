class_name SoundRequest
extends RefCounted

enum EventType {
    Play,
    Stop,
    SetVolume,
    SetMasterVolume,
    Pause,
    Resume
}

var event_type: EventType = EventType.Play
var event_name: String = ""
var variant: String = "main"
var position: Vector3 = Vector3.ZERO
var volume: float = 1.0
var priority: int = 0
