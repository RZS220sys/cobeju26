class_name ArchiveModelLibrary
extends RefCounted


static func instantiate_model(resource_path: String) -> Node3D:
	var resource := ResourceLoader.load(resource_path, "PackedScene")
	if resource is PackedScene:
		var packed := resource as PackedScene
		var instance := packed.instantiate()
		if instance is Node3D:
			return instance as Node3D
	return null


static func enemy_path(enemy_kind: int, boss: bool) -> String:
	if boss:
		return "res://assets/models/warden.glb"
	match enemy_kind:
		1: return "res://assets/models/murmur.glb"
		2: return "res://assets/models/keeper.glb"
	return "res://assets/models/hollow.glb"
