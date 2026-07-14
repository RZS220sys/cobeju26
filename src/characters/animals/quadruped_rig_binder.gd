class_name QuadrupedRigBinder
extends RigBinder


static func bind(model: Node3D) -> void:
	if not is_instance_valid(model):
		return
	for side: String in ["L", "R"] as Array[String]:
		reparent_part(model, "PawFront%s" % side, "FrontLeg%s" % side)
		reparent_part(model, "PawBack%s" % side, "BackLeg%s" % side)
