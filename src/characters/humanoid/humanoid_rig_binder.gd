class_name HumanoidRigBinder
extends RigBinder


static func bind(model: Node3D) -> void:
	if not is_instance_valid(model):
		return
	for side: String in ["L", "R"] as Array[String]:
		reparent_part(model, "Forearm%s" % side, "UpperArm%s" % side)
		reparent_part(model, "Hand%s" % side, "Forearm%s" % side)
		reparent_part(model, "Shin%s" % side, "Thigh%s" % side)
		reparent_part(model, "Boot%s" % side, "Shin%s" % side)
