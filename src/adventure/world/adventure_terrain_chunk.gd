class_name AdventureTerrainChunk
extends StaticBody3D

var chunk_coordinate: Vector2i
var chunk_size: float = 64.0
var resolution: int = 16
var terrain_noise: FastNoiseLite
var terrain_material: Material


func configure(coordinate: Vector2i, size_value: float, noise_value: FastNoiseLite, material_value: Material) -> void:
	chunk_coordinate = coordinate
	chunk_size = size_value
	terrain_noise = noise_value
	terrain_material = material_value


@override
func _ready() -> void:
	name = "Terrain_%d_%d" % [chunk_coordinate.x, chunk_coordinate.y]
	collision_layer = 1
	collision_mask = 0
	position = Vector3(float(chunk_coordinate.x) * chunk_size, 0.0, float(chunk_coordinate.y) * chunk_size)
	_build_mesh_and_collision()


@private
func _build_mesh_and_collision() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z_index: int in range(resolution):
		for x_index: int in range(resolution):
			var local_x0 := float(x_index) / float(resolution) * chunk_size
			var local_x1 := float(x_index + 1) / float(resolution) * chunk_size
			var local_z0 := float(z_index) / float(resolution) * chunk_size
			var local_z1 := float(z_index + 1) / float(resolution) * chunk_size
			var p00 := _terrain_vertex(local_x0, local_z0)
			var p10 := _terrain_vertex(local_x1, local_z0)
			var p01 := _terrain_vertex(local_x0, local_z1)
			var p11 := _terrain_vertex(local_x1, local_z1)
			_add_triangle(surface, p00, p11, p01)
			_add_triangle(surface, p00, p10, p11)
	var mesh := surface.commit()
	var visual := MeshInstance3D.new()
	visual.name = "TerrainSurface"
	visual.mesh = mesh
	visual.material_override = terrain_material
	add_child(visual)
	var collision := CollisionShape3D.new()
	collision.name = "TerrainCollision"
	var terrain_shape := mesh.create_trimesh_shape()
	terrain_shape.backface_collision = true
	collision.shape = terrain_shape
	add_child(collision)
	_build_forest_cover()


@private
func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.y < 0.0:
		normal = -normal
	for vertex: Vector3 in [a, b, c] as Array[Vector3]:
		surface.set_normal(normal)
		surface.set_uv(Vector2((position.x + vertex.x) * 0.035, (position.z + vertex.z) * 0.035))
		surface.add_vertex(vertex)


@private
func _terrain_vertex(local_x: float, local_z: float) -> Vector3:
	var world_x := position.x + local_x
	var world_z := position.z + local_z
	return Vector3(local_x, sample_height(world_x, world_z), local_z)


func sample_height(world_x: float, world_z: float) -> float:
	var distance_from_village := Vector2(world_x, world_z).length()
	if distance_from_village < 30.0:
		return 0.0
	var village_blend := smoothstep(30.0, 58.0, distance_from_village)
	var broad := terrain_noise.get_noise_2d(world_x * 0.38, world_z * 0.38) * 8.5
	var detail := terrain_noise.get_noise_2d(world_x * 1.6 + 730.0, world_z * 1.6 - 410.0) * 1.25
	return (broad + detail) * village_blend


@private
func _build_forest_cover() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = hash("%d:%d:forest" % [chunk_coordinate.x, chunk_coordinate.y])
	var center_world := Vector2(position.x + chunk_size * 0.5, position.z + chunk_size * 0.5)
	var in_glasswood := center_world.y < -90.0
	var in_amberfen := center_world.x > 110.0
	var in_bellscar := center_world.y > 140.0
	var minimum_trees := 11 if in_glasswood else (2 if in_bellscar else 4)
	var maximum_trees := 17 if in_glasswood else (5 if in_amberfen or in_bellscar else 8)
	var tree_count := random.randi_range(minimum_trees, maximum_trees)
	for index: int in range(tree_count):
		var local_x := random.randf_range(5.0, chunk_size - 5.0)
		var local_z := random.randf_range(5.0, chunk_size - 5.0)
		var world_x := position.x + local_x
		var world_z := position.z + local_z
		if Vector2(world_x, world_z).length() < 36.0:
			continue
		var pine_chance := 0.76 if in_glasswood else (0.28 if in_amberfen else 0.48)
		var asset_name := "pine" if random.randf() < pine_chance else "oak"
		var tree := AdventureAssetLibrary.instantiate_model(asset_name)
		if not is_instance_valid(tree):
			continue
		tree.name = "Wild%s_%d" % [asset_name.capitalize(), index]
		tree.position = Vector3(local_x, sample_height(world_x, world_z), local_z)
		tree.rotation.y = random.randf_range(0.0, TAU)
		var tree_scale := random.randf_range(0.72, 1.28)
		tree.scale = Vector3(tree_scale, random.randf_range(0.85, 1.2) * tree_scale, tree_scale)
		add_child(tree)
		var trunk := StaticBody3D.new()
		trunk.name = "WildTrunk_%d" % index
		trunk.collision_layer = 1
		trunk.position = tree.position + Vector3.UP * 1.55 * tree.scale.y
		var shape_node := CollisionShape3D.new()
		var trunk_shape := CylinderShape3D.new()
		trunk_shape.radius = 0.36 * tree_scale
		trunk_shape.height = 3.1 * tree.scale.y
		shape_node.shape = trunk_shape
		trunk.add_child(shape_node)
		add_child(trunk)
