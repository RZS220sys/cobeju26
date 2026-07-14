class_name BoonDefinition
extends RefCounted

var boon_id: StringName
var title: String
var description: String
var flavor: String
var color: Color


func _init(id_value: StringName, title_value: String, description_value: String, flavor_value: String, color_value: Color) -> void:
	boon_id = id_value
	title = title_value
	description = description_value
	flavor = flavor_value
	color = color_value
