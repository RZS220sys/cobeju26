class_name DialogueLine
extends RefCounted

var speaker: String
var text: String
var duration: float


func _init(speaker_value: String = "", text_value: String = "", duration_value: float = 4.0) -> void:
	speaker = speaker_value
	text = text_value
	duration = duration_value
