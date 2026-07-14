class_name ArchiveArenaGenerator
extends Node3D

var arena_radius: float = 20.0
var seed_value: int = 1907
var _random := RandomNumberGenerator.new()


@override
func _ready() -> void:
	_random.seed = seed_value
	_build_floor()
	_build_ruins()


@private
func _build_floor() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "ArchiveFloor"
	floor_body.collision_layer = 32
	floor_body.collision_mask = 0
	add_child(floor_body)

	var collision := CollisionShape3D.new()
	var floor_shape := CylinderShape3D.new()
	floor_shape.radius = arena_radius
	floor_shape.height = 0.8
	collision.shape = floor_shape
	collision.position.y = -0.45
	floor_body.add_child(collision)

	var floor_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = arena_radius
	cylinder.bottom_radius = arena_radius + 0.8
	cylinder.height = 0.8
	cylinder.radial_segments = 64
	floor_mesh.mesh = cylinder
	floor_mesh.position.y = -0.45
	floor_mesh.material_override = ArchivePalette.make_archive_floor_material()
	floor_body.add_child(floor_mesh)

	for ring_index: int in range(4):
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 4.7 + float(ring_index) * 4.3
		torus.outer_radius = torus.inner_radius + 0.045
		torus.rings = 8
		torus.ring_segments = 64
		ring.mesh = torus
		ring.position.y = 0.02
		ring.material_override = ArchivePalette.make_material(Color(0.25, 0.48, 0.5, 0.45), 0.4, 0.35)
		add_child(ring)


@private
func _build_ruins() -> void:
	for index: int in range(22):
		var angle := _random.randf_range(0.0, TAU)
		var radius := _random.randf_range(6.0, arena_radius - 2.2)
		var ruin_position := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		if ruin_position.distance_to(Vector3(0.0, 0.0, 13.2)) < 3.0:
			continue
		_create_pillar(ruin_position, _random.randf_range(1.1, 3.8), _random.randf_range(0.35, 0.72), index)

	for index: int in range(9):
		var angle := float(index) / 9.0 * TAU
		var marker := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.22, 1.2, 0.18)
		marker.mesh = mesh
		marker.position = Vector3(cos(angle) * (arena_radius - 0.8), 0.58, sin(angle) * (arena_radius - 0.8))
		marker.material_override = ArchivePalette.make_material(ArchivePalette.brass(), 1.1, 0.38)
		add_child(marker)


@private
func _create_pillar(at: Vector3, height: float, width: float, index: int) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	body.position = at
	body.rotation.y = float(index) * 0.73
	add_child(body)

	var shape_node := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(width * 1.4, height, width)
	shape_node.shape = box_shape
	shape_node.position.y = height * 0.5
	body.add_child(shape_node)

	var visual := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_shape.size
	visual.mesh = box_mesh
	visual.position = shape_node.position
	visual.material_override = ArchivePalette.make_material(Color("29434a").lerp(Color("876f48"), fmod(float(index) * 0.17, 0.35)), 0.0, 0.88)
	body.add_child(visual)

	if index % 3 == 0:
		var cap := MeshInstance3D.new()
		var cap_mesh := CylinderMesh.new()
		cap_mesh.top_radius = width * 0.85
		cap_mesh.bottom_radius = width
		cap_mesh.height = 0.18
		cap_mesh.radial_segments = 8
		cap.mesh = cap_mesh
		cap.position.y = height + 0.08
		cap.material_override = ArchivePalette.make_material(ArchivePalette.brass().darkened(0.28), 0.0, 0.65)
		body.add_child(cap)


func random_open_position(minimum_radius: float = 4.0, maximum_radius: float = 17.5) -> Vector3:
	var angle := _random.randf_range(0.0, TAU)
	var radius := sqrt(_random.randf_range(minimum_radius * minimum_radius, maximum_radius * maximum_radius))
	return Vector3(cos(angle) * radius, 0.8, sin(angle) * radius)
