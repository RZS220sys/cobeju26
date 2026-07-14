class_name LoreRecord
extends RefCounted

var record_id: String
var title: String
var excerpt: String
var body: String
var depth: int


func _init(id_value: String, title_value: String, excerpt_value: String, body_value: String, depth_value: int) -> void:
	record_id = id_value
	title = title_value
	excerpt = excerpt_value
	body = body_value
	depth = depth_value
