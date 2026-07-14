class_name AdventureAssetLibrary
extends RefCounted


static func instantiate_model(asset_name: String) -> Node3D:
	var path := "res://assets/adventure/models/%s.glb" % asset_name
	var resource := ResourceLoader.load(path, "PackedScene")
	if resource is PackedScene:
		var packed := resource as PackedScene
		var instance := packed.instantiate()
		if instance is Node3D:
			return instance as Node3D
	return null


static func material(color: Color, roughness: float = 0.82, emission_color: Color = Color.TRANSPARENT, emission_energy: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission_energy > 0.0:
		result.emission_enabled = true
		result.emission = emission_color
		result.emission_energy_multiplier = emission_energy
	return result
