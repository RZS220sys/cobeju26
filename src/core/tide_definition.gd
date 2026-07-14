class_name TideDefinition
extends RefCounted

var tide_id: StringName
var title: String
var description: String
var bonus_fragments: int


func _init(id_value: StringName, title_value: String, description_value: String, bonus_value: int) -> void:
	tide_id = id_value
	title = title_value
	description = description_value
	bonus_fragments = bonus_value
