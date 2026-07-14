class_name AdventureEchoCauseway
extends Node3D

var altars: Dictionary[StringName, AdventureWorldInteractable] = {}
var crossing_gate: AdventureWorldInteractable


@override
func _ready() -> void:
	name = "EchoCauseway"
	position = Vector3(420.0, 18.0, -420.0)
	_build_causeway()


@private
func _build_causeway() -> void:
	_add_floor(Vector3.ZERO, Vector3(16.0, 1.0, 16.0))
	var altar_data: Dictionary[StringName, Vector3] = {
		&"iven_voice": Vector3(-24.0, 0.0, -18.0),
		&"sola_voice": Vector3(24.0, 0.0, -18.0),
		&"orin_voice": Vector3(0.0, 0.0, 28.0),
	}
	for altar_id: StringName in altar_data:
		var offset: Vector3 = altar_data[altar_id]
		_add_bridge(offset * 0.5, offset)
		_add_floor(offset, Vector3(11.0, 1.0, 11.0))
		_build_altar(altar_id, offset)
	_build_crossing_gate()


@private
func _add_bridge(center: Vector3, endpoint: Vector3) -> void:
	var length := Vector2(endpoint.x, endpoint.z).length()
	var yaw := atan2(endpoint.x, endpoint.z)
	_add_floor(center, Vector3(5.0, 0.7, length), yaw)


@private
func _add_floor(at: Vector3, size: Vector3, yaw: float = 0.0) -> void:
	var body := StaticBody3D.new()
	body.position = at - Vector3.UP * size.y * 0.5
	body.rotation.y = yaw
	body.collision_layer = 1
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = AdventureAssetLibrary.material(Color("272e3a"), 0.72, Color("213b55"), 0.22)
	body.add_child(visual)
	add_child(body)


@private
func _build_altar(altar_id: StringName, at: Vector3) -> void:
	var root := Node3D.new()
	root.name = String(altar_id).to_pascal_case()
	root.position = at
	add_child(root)
	for index: int in range(3):
		var pillar := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.65, 3.2 + index * 0.55, 0.75)
		pillar.mesh = mesh
		var angle := float(index) / 3.0 * TAU
		pillar.position = Vector3(cos(angle) * 2.0, 1.8, sin(angle) * 2.0)
		pillar.material_override = AdventureAssetLibrary.material(Color("5a4c86"), 0.35, Color("7661bd"), 0.8)
		root.add_child(pillar)
	var interactable := AdventureWorldInteractable.new()
	interactable.name = "%sInteractable" % root.name
	interactable.configure(altar_id, "Place a rescued name in the altar")
	interactable.position = at
	add_child(interactable)
	altars[altar_id] = interactable


@private
func _build_crossing_gate() -> void:
	var gate := Node3D.new()
	gate.name = "ThreeVoicesGate"
	gate.position = Vector3(0.0, 0.0, -4.0)
	add_child(gate)
	for side: int in [-1, 1]:
		var pillar := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.0, 8.0, 1.2)
		pillar.mesh = mesh
		pillar.position = Vector3(side * 4.0, 4.0, 0.0)
		pillar.material_override = AdventureAssetLibrary.material(Color("343849"), 0.78)
		gate.add_child(pillar)
	var lintel := MeshInstance3D.new()
	var lintel_mesh := BoxMesh.new()
	lintel_mesh.size = Vector3(9.0, 1.0, 1.2)
	lintel.mesh = lintel_mesh
	lintel.position.y = 8.0
	lintel.material_override = AdventureAssetLibrary.material(Color("343849"), 0.78)
	gate.add_child(lintel)
	crossing_gate = AdventureWorldInteractable.new()
	crossing_gate.name = "ThreeVoicesGateInteractable"
	crossing_gate.configure(&"three_voices_gate", "Open the Crossing of Three Voices")
	crossing_gate.position = gate.position
	add_child(crossing_gate)


func awaken_altar(altar_id: StringName) -> void:
	var interactable: AdventureWorldInteractable = altars.get(altar_id) as AdventureWorldInteractable
	if not is_instance_valid(interactable):
		return
	interactable.remove_from_group(&"adventure_interactables")
	interactable.interaction_prompt = "Listen to the awakened voice"
	var light := OmniLight3D.new()
	light.light_color = Color("8b70e8")
	light.light_energy = 4.0
	light.omni_range = 12.0
	interactable.add_child(light)
