class_name RegionLandmarks
extends Node3D

var streamer: WorldStreamer
var landmarks: Dictionary[InteractionCatalog.Id, WorldInteractable] = {}


func configure(streamer_value: WorldStreamer) -> void:
	streamer = streamer_value


@override
func _ready() -> void:
	name = "RegionLandmarks"
	_build_glasswood_shrine()
	_build_amberfen_orrery()
	_build_bellscar_bell()
	_build_glass_road_beacon()


@private
func _build_glasswood_shrine() -> void:
	var center := Vector3(0.0, streamer.sample_height(0.0, -180.0), -180.0)
	var root := Node3D.new()
	root.name = "GlasswoodShrine"
	root.position = center
	add_child(root)
	_add_cylinder(root, Vector3(0, 0.35, 0), 5.8, 0.7, Color("31383c"), 16)
	for index: int in range(7):
		var angle := float(index) / 7.0 * TAU
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.8, 3.8 + (index % 3), 0.9)
		crystal.mesh = mesh
		crystal.position = Vector3(cos(angle) * 4.2, 2.0 + (index % 3) * 0.5, sin(angle) * 4.2)
		crystal.rotation = Vector3(0.12 * sin(angle), -angle, 0.15 * cos(angle))
		crystal.material_override = ModelLibrary.material(Color("447b92"), 0.24, Color("3aa8d2"), 1.4)
		root.add_child(crystal)
	for side: int in [-1, 1]:
		_add_box(root, Vector3(side * 2.4, 2.5, 0.0), Vector3(0.55, 5.0, 0.8), Color("3e4444"), Vector3(0, 0, side * -0.22))
	_add_box(root, Vector3(0, 5.0, 0), Vector3(5.2, 0.55, 0.8), Color("3e4444"))
	_add_interactable(InteractionCatalog.Id.GLASSWOOD_SHRINE, "Listen at the Glasswood Shrine", center, "Glasswood Shrine")


@private
func _build_amberfen_orrery() -> void:
	var center := Vector3(180.0, streamer.sample_height(180.0, 20.0), 20.0)
	var root := Node3D.new()
	root.name = "AmberfenOrrery"
	root.position = center
	add_child(root)
	_add_cylinder(root, Vector3(0, 0.5, 0), 4.8, 1.0, Color("55462d"), 14)
	_add_cylinder(root, Vector3(0, 3.6, 0), 0.38, 6.4, Color("684526"), 10)
	for index: int in range(3):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 2.1 + index * 0.68
		mesh.outer_radius = mesh.inner_radius + 0.12
		mesh.rings = 12
		mesh.ring_segments = 42
		ring.mesh = mesh
		ring.position.y = 5.7
		ring.rotation = Vector3(PI * 0.5, index * 0.52, index * 0.37)
		ring.material_override = ModelLibrary.material(Color("b67829"), 0.32, Color("d18d34"), 0.7)
		root.add_child(ring)
	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.72
	core_mesh.height = 1.44
	core.mesh = core_mesh
	core.position.y = 5.7
	core.material_override = ModelLibrary.material(Color("f0aa3c"), 0.22, Color("e99628"), 2.0)
	root.add_child(core)
	_add_interactable(InteractionCatalog.Id.AMBERFEN_ORRERY, "Turn the Amberfen Orrery", center, "Amberfen Orrery")
	_add_static_cylinder(center + Vector3.UP * 1.7, 0.55, 3.4)


@private
func _build_bellscar_bell() -> void:
	var center := Vector3(-45.0, streamer.sample_height(-45.0, 190.0), 190.0)
	var root := Node3D.new()
	root.name = "BellscarWake"
	root.position = center
	add_child(root)
	for side: int in [-1, 1]:
		_add_box(root, Vector3(side * 3.4, 3.5, 0), Vector3(0.75, 7.0, 1.1), Color("4b4442"), Vector3(0, 0, side * -0.12))
	_add_box(root, Vector3(0, 7.0, 0), Vector3(7.5, 0.75, 1.1), Color("4b4442"))
	var bell := MeshInstance3D.new()
	var bell_mesh := CylinderMesh.new()
	bell_mesh.top_radius = 1.15
	bell_mesh.bottom_radius = 2.35
	bell_mesh.height = 3.8
	bell_mesh.radial_segments = 18
	bell.mesh = bell_mesh
	bell.position.y = 4.7
	bell.material_override = ModelLibrary.material(Color("6f4b37"), 0.38, Color("7d392f"), 0.32)
	root.add_child(bell)
	_add_cylinder(root, Vector3(0, 2.5, 0), 0.3, 4.2, Color("2b2928"), 10)
	_add_interactable(InteractionCatalog.Id.BELLSCAR_BELL, "Touch the silent Bellscar bell", center, "Bellscar Wake")
	_add_static_box(center + Vector3(0, 3.5, 0), Vector3(8.0, 7.0, 1.2))


@private
func _build_glass_road_beacon() -> void:
	var center := Vector3(-170.0, streamer.sample_height(-170.0, 28.0), 28.0)
	var root := Node3D.new()
	root.name = "GlassRoadBeacon"
	root.position = center
	add_child(root)
	_add_cylinder(root, Vector3(0, 0.45, 0), 3.6, 0.9, Color("3d4246"), 14)
	for index: int in range(5):
		var shard := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.42, 3.2 + index * 0.85, 0.46)
		shard.mesh = mesh
		var angle := float(index) / 5.0 * TAU
		shard.position = Vector3(cos(angle) * 1.4, 1.6 + index * 0.42, sin(angle) * 1.4)
		shard.rotation.z = sin(angle) * 0.22
		shard.material_override = ModelLibrary.material(Color("d3edf1"), 0.16, Color("74d8e8"), 1.7)
		root.add_child(shard)
	var light := OmniLight3D.new()
	light.light_color = Color("7bddeb")
	light.light_energy = 3.2
	light.omni_range = 13.0
	light.position.y = 3.0
	root.add_child(light)
	_add_interactable(InteractionCatalog.Id.GLASS_ROAD_BEACON, "Inspect the western glass-road beacon", center, "Glass Road Beacon")


@private
func _add_interactable(id_value: InteractionCatalog.Id, prompt: String, at: Vector3, node_name: String) -> void:
	var interactable := WorldInteractable.new()
	interactable.name = node_name
	interactable.configure(id_value, prompt)
	interactable.position = at
	add_child(interactable)
	landmarks[id_value] = interactable


@private
func _add_box(parent: Node3D, at: Vector3, size: Vector3, color: Color, rotation_value: Vector3 = Vector3.ZERO) -> void:
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.position = at
	visual.rotation = rotation_value
	visual.material_override = ModelLibrary.material(color, 0.9)
	parent.add_child(visual)


@private
func _add_cylinder(parent: Node3D, at: Vector3, radius: float, height: float, color: Color, segments: int) -> void:
	var visual := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	visual.mesh = mesh
	visual.position = at
	visual.material_override = ModelLibrary.material(color, 0.88)
	parent.add_child(visual)


@private
func _add_static_box(at: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = at
	body.collision_layer = PhysicsLayers.Id.WORLD
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


@private
func _add_static_cylinder(at: Vector3, radius: float, height: float) -> void:
	var body := StaticBody3D.new()
	body.position = at
	body.collision_layer = PhysicsLayers.Id.WORLD
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
