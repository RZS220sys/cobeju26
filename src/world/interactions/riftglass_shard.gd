class_name RiftglassShard
extends WorldInteractable

var _visual: Node3D
var _time: float = 0.0


@override
func _ready() -> void:
	super._ready()
	_visual = Node3D.new()
	_visual.name = "RiftglassVisual"
	add_child(_visual)
	for index: int in range(3):
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.22 + index * 0.06, 0.75 - index * 0.1, 0.28)
		crystal.mesh = mesh
		crystal.position = Vector3((index - 1) * 0.24, 0.48 + index * 0.08, 0.0)
		crystal.rotation_degrees.z = -18.0 + index * 18.0
		var material := ModelLibrary.material(Color("6ee8ff"), 0.22, Color("2fd5ff"), 2.2)
		crystal.material_override = material
		_visual.add_child(crystal)
	var glow := OmniLight3D.new()
	glow.light_color = Color("5bdfff")
	glow.light_energy = 1.7
	glow.omni_range = 4.5
	glow.position.y = 0.7
	add_child(glow)


@override
func _process(delta: float) -> void:
	_time += delta
	if is_instance_valid(_visual):
		_visual.rotation.y += delta * 0.8
		_visual.position.y = sin(_time * 2.4) * 0.12
