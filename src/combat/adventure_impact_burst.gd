class_name AdventureImpactBurst
extends Node3D

var color: Color = Color("76ddf2")


func configure(color_value: Color) -> void:
	color = color_value


@override
func _ready() -> void:
	var material := AdventureAssetLibrary.material(color, 0.24, color, 2.2)
	for index: int in range(7):
		var shard := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.07, 0.32, 0.06)
		shard.mesh = mesh
		shard.material_override = material
		shard.rotation = Vector3(index * 0.71, index * 1.13, index * 0.43)
		add_child(shard)
		var angle := float(index) / 7.0 * TAU
		var destination := Vector3(cos(angle) * 0.85, 0.3 + (index % 3) * 0.22, sin(angle) * 0.85)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(shard, "position", destination, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(shard, "scale", Vector3.ZERO, 0.34).set_delay(0.08)
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 3.5
	light.omni_range = 4.0
	add_child(light)
	var light_tween := create_tween()
	light_tween.tween_property(light, "light_energy", 0.0, 0.3)
	light_tween.tween_callback(queue_free)
