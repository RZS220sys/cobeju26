class_name RigBinder
extends RefCounted


static func reparent_part(model: Node3D, child_name: String, parent_name: String) -> void:
	var child := model.find_child(child_name, true, false) as Node3D
	var parent := model.find_child(parent_name, true, false) as Node3D
	if not is_instance_valid(child) or not is_instance_valid(parent) or child.get_parent() == parent:
		return
	child.reparent(parent, true)
