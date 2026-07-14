class_name AdventureRigBinder
extends RefCounted


static func bind_humanoid(model: Node3D) -> void:
	if not is_instance_valid(model):
		return
	for side: String in ["L", "R"] as Array[String]:
		_reparent(model, "Forearm%s" % side, "UpperArm%s" % side)
		_reparent(model, "Hand%s" % side, "Forearm%s" % side)
		_reparent(model, "Shin%s" % side, "Thigh%s" % side)
		_reparent(model, "Boot%s" % side, "Shin%s" % side)


static func bind_hound(model: Node3D) -> void:
	if not is_instance_valid(model):
		return
	for side: String in ["L", "R"] as Array[String]:
		_reparent(model, "PawFront%s" % side, "FrontLeg%s" % side)
		_reparent(model, "PawBack%s" % side, "BackLeg%s" % side)


@private
static func _reparent(model: Node3D, child_name: String, parent_name: String) -> void:
	var child := model.find_child(child_name, true, false) as Node3D
	var parent := model.find_child(parent_name, true, false) as Node3D
	if not is_instance_valid(child) or not is_instance_valid(parent) or child.get_parent() == parent:
		return
	child.reparent(parent, true)
