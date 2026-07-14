class_name HearthmereScenery
extends Node3D


@override
func _ready() -> void:
	name = "Scenery"
	_build_roads()
	_add_building(ModelCatalog.Id.COTTAGE_BLUE, Vector3(-8.0, 0.0, -7.0), 0.32, Vector3(5.2, 3.2, 4.6))
	_add_building(ModelCatalog.Id.COTTAGE_RED, Vector3(9.0, 0.0, -6.0), -0.4, Vector3(5.8, 3.3, 5.0))
	_add_building(ModelCatalog.Id.COTTAGE_BLUE, Vector3(-10.0, 0.0, 8.0), 2.6, Vector3(5.2, 3.2, 4.6))
	_add_model(ModelCatalog.Id.VILLAGE_PROPS, Vector3(0.0, 0.0, -1.0), 0.0)
	_add_model(ModelCatalog.Id.WAYSTONE, Vector3(0.0, 0.0, -15.0), 0.0)
	_build_trees()
	_build_landmark_collisions()


@private
func _build_roads() -> void:
	_add_road(Vector3(0.0, 0.025, -2.0), Vector2(5.5, 34.0), 0.0)
	_add_road(Vector3(12.0, 0.03, 1.5), Vector2(52.0, 4.2), 0.0)
	var square := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 6.0
	mesh.bottom_radius = 6.0
	mesh.height = 0.05
	mesh.radial_segments = 16
	square.mesh = mesh
	square.position = Vector3(0.0, 0.02, 0.0)
	square.material_override = ModelLibrary.material(Color("776548"), 0.94)
	add_child(square)


@private
func _add_road(at: Vector3, size: Vector2, yaw: float) -> void:
	var road := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	road.mesh = mesh
	road.position = at
	road.rotation.y = yaw
	road.material_override = ModelLibrary.material(Color("66583f"), 0.96)
	add_child(road)


@private
func _add_model(model_id: ModelCatalog.Id, at: Vector3, yaw: float) -> Node3D:
	var model := ModelLibrary.instantiate_model(model_id)
	if is_instance_valid(model):
		model.position = at
		model.rotation.y = yaw
		add_child(model)
	return model


@private
func _add_building(model_id: ModelCatalog.Id, at: Vector3, yaw: float, collision_size: Vector3) -> void:
	_add_model(model_id, at, yaw)
	ColliderFactory.add_box(self, "%sCollision" % ModelCatalog.file_name(model_id).to_pascal_case(), at + Vector3.UP * collision_size.y * 0.5, collision_size, yaw)


@private
func _build_trees() -> void:
	var points: Array[Vector3] = [
		Vector3(-17, 0, -15), Vector3(15, 0, -14), Vector3(-19, 0, -2),
		Vector3(18, 0, 5), Vector3(-15, 0, 17), Vector3(13, 0, 16),
		Vector3(-5, 0, 22), Vector3(5, 0, 23), Vector3(22, 0, -4),
	]
	for index: int in range(points.size()):
		var model_id := ModelCatalog.Id.PINE if index % 3 == 0 else ModelCatalog.Id.OAK
		_add_model(model_id, points[index], float(index) * 0.73)
		ColliderFactory.add_cylinder(self, "TreeCollision_%d" % index, points[index] + Vector3.UP * 1.7, 0.42, 3.4)


@private
func _build_landmark_collisions() -> void:
	ColliderFactory.add_cylinder(self, "WellCollision", Vector3(0.0, 0.55, -1.0), 1.12, 1.1)
	ColliderFactory.add_box(self, "WellBeamCollision", Vector3(0.0, 2.45, -1.0), Vector3(2.3, 0.22, 0.22))
	ColliderFactory.add_box(self, "BenchCollision", Vector3(3.0, 0.72, -1.0), Vector3(2.7, 1.25, 0.7))
	ColliderFactory.add_cylinder(self, "WaystoneCollision", Vector3(0.0, 1.15, -15.0), 1.25, 2.3)
	ColliderFactory.add_box(self, "WorkbenchCollision", Vector3(11.0, 0.72, -1.7), Vector3(2.5, 1.35, 0.8))
