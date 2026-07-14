class_name AnimalNpc
extends NpcActor

var alertness: float = 0.0


func notice(observed_position: Vector3) -> void:
	var direction := observed_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		rotation.y = atan2(-direction.x, -direction.z)
	alertness = 1.0
