class_name CrossingAftermath
extends Node3D

var interactable: WorldInteractable


func configure(state: GameWorldState) -> void:
	var choice := _choice(state)
	if choice == CrossingChoiceCatalog.Id.NONE:
		queue_free()
		return
	name = "CrossingAftermath"
	position = Vector3(0.0, 0.0, -15.0)
	match choice:
		CrossingChoiceCatalog.Id.SHELTER:
			_build_shelter()
		CrossingChoiceCatalog.Id.BRIDGE:
			_build_bridge()
		CrossingChoiceCatalog.Id.WITNESS:
			_build_witness()
	interactable = WorldInteractable.new()
	interactable.name = "CrossingAftermathInteractable"
	interactable.configure(InteractionCatalog.Id.CROSSING_AFTERMATH, "Examine what your answer changed")
	interactable.position = Vector3(-2.6, 0.0, 0.0)
	add_child(interactable)


@private
func _choice(state: GameWorldState) -> CrossingChoiceCatalog.Id:
	for choice: CrossingChoiceCatalog.Id in [CrossingChoiceCatalog.Id.SHELTER, CrossingChoiceCatalog.Id.BRIDGE, CrossingChoiceCatalog.Id.WITNESS]:
		if Inventory.count(state, CrossingChoiceCatalog.evidence_item(choice)) > 0:
			return choice
	return CrossingChoiceCatalog.Id.NONE


@private
func _build_shelter() -> void:
	for index: int in range(12):
		var angle := float(index) / 12.0 * TAU
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.22, 1.6, 0.2)
		crystal.mesh = mesh
		crystal.position = Vector3(cos(angle) * 3.4, 0.8, sin(angle) * 3.4)
		crystal.rotation.y = -angle
		crystal.material_override = ModelLibrary.material(Color("68d5ef"), 0.22, Color("4ac8e6"), 1.4)
		add_child(crystal)
	var light := OmniLight3D.new()
	light.light_color = Color("69d9f2")
	light.light_energy = 2.4
	light.omni_range = 9.0
	light.position.y = 1.5
	add_child(light)


@private
func _build_bridge() -> void:
	var colors: Array[Color] = [Color("68d9f2"), Color("efb75b"), Color("d486e9")]
	for index: int in range(3):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 1.45 + index * 0.5
		mesh.outer_radius = mesh.inner_radius + 0.08
		mesh.rings = 10
		mesh.ring_segments = 40
		ring.mesh = mesh
		ring.position.y = 1.35
		ring.rotation = Vector3(PI * 0.5, index * 0.62, index * 0.38)
		ring.material_override = ModelLibrary.material(colors[index], 0.25, colors[index], 1.4)
		add_child(ring)


@private
func _build_witness() -> void:
	var ghost := ModelLibrary.instantiate_model(ModelCatalog.Id.IVEN)
	if not is_instance_valid(ghost):
		return
	ghost.name = "ForgottenArchitectEcho"
	ghost.position = Vector3(0.0, 0.15, -0.4)
	ghost.scale = Vector3.ONE * 1.12
	add_child(ghost)
	var material := ModelLibrary.material(Color(0.48, 0.31, 0.72, 0.42), 0.25, Color("8e5ed3"), 1.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for descendant: Node in ghost.find_children("*", "MeshInstance3D", true, false):
		(descendant as MeshInstance3D).material_override = material
	var light := OmniLight3D.new()
	light.light_color = Color("9a68df")
	light.light_energy = 2.0
	light.omni_range = 7.0
	light.position.y = 1.4
	add_child(light)
