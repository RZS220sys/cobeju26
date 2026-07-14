class_name HearthmereVillage
extends Node3D

var npcs: Dictionary[LumenfallTypes.NpcId, AdventureNpc] = {}
var waystone_interactable: AdventureWorldInteractable
var workshop_interactable: AdventureWorldInteractable
var eastern_crossing: AdventureWorldInteractable
var field_map: AdventureWorldInteractable
var crossing_aftermath: AdventureWorldInteractable


@override
func _ready() -> void:
	name = "Hearthmere"
	_build_roads()
	_add_building(LumenfallTypes.AssetId.COTTAGE_BLUE, Vector3(-8.0, 0.0, -7.0), 0.32, Vector3(5.2, 3.2, 4.6))
	_add_building(LumenfallTypes.AssetId.COTTAGE_RED, Vector3(9.0, 0.0, -6.0), -0.4, Vector3(5.8, 3.3, 5.0))
	_add_building(LumenfallTypes.AssetId.COTTAGE_BLUE, Vector3(-10.0, 0.0, 8.0), 2.6, Vector3(5.2, 3.2, 4.6))
	_add_model(LumenfallTypes.AssetId.VILLAGE_PROPS, Vector3(0.0, 0.0, -1.0), 0.0)
	_add_model(LumenfallTypes.AssetId.WAYSTONE, Vector3(0.0, 0.0, -15.0), 0.0)
	waystone_interactable = AdventureWorldInteractable.new()
	waystone_interactable.configure(LumenfallTypes.InteractionId.WAYSTONE, "Touch the sleeping Waystone")
	waystone_interactable.position = Vector3(0.0, 0.0, -15.0)
	add_child(waystone_interactable)
	_add_village_landmark_collisions()
	_add_npc(LumenfallTypes.NpcId.NIA, "Nia", Vector3(2.2, 0.0, -12.8), PI)
	_add_npc(LumenfallTypes.NpcId.BRAM, "Bram", Vector3(8.0, 0.0, -2.0), -1.3)
	_add_npc(LumenfallTypes.NpcId.MARA, "Mara", Vector3(-5.5, 0.0, 5.0), 2.5)
	_add_npc(LumenfallTypes.NpcId.PIP, "Pip", Vector3(2.0, 0.0, 4.0), -0.4)
	workshop_interactable = AdventureWorldInteractable.new()
	workshop_interactable.configure(LumenfallTypes.InteractionId.BRAM_WORKBENCH, "Use Bram's lantern bench")
	workshop_interactable.position = Vector3(11.0, 0.0, -1.7)
	add_child(workshop_interactable)
	_add_workbench_visual()
	_build_eastern_lanterns()
	_build_field_map()
	_build_trees()


@private
func _build_roads() -> void:
	_add_road(Vector3(0.0, 0.025, -2.0), Vector2(5.5, 34.0), 0.0)
	_add_road(Vector3(12.0, 0.03, 1.5), Vector2(52.0, 4.2), 0.0)
	var square := MeshInstance3D.new()
	var square_mesh := CylinderMesh.new()
	square_mesh.top_radius = 6.0
	square_mesh.bottom_radius = 6.0
	square_mesh.height = 0.05
	square_mesh.radial_segments = 16
	square.mesh = square_mesh
	square.position = Vector3(0.0, 0.02, 0.0)
	square.material_override = AdventureAssetLibrary.material(Color("776548"), 0.94)
	add_child(square)


@private
func _add_road(at: Vector3, road_size: Vector2, yaw: float) -> void:
	var road := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = road_size
	road.mesh = mesh
	road.position = at
	road.rotation.y = yaw
	road.material_override = AdventureAssetLibrary.material(Color("66583f"), 0.96)
	add_child(road)


@private
func _add_model(asset_id: LumenfallTypes.AssetId, at: Vector3, yaw: float) -> Node3D:
	var model := AdventureAssetLibrary.instantiate_model(asset_id)
	if is_instance_valid(model):
		model.position = at
		model.rotation.y = yaw
		add_child(model)
	return model


@private
func _add_building(asset_id: LumenfallTypes.AssetId, at: Vector3, yaw: float, collision_size: Vector3) -> void:
	_add_model(asset_id, at, yaw)
	var body := StaticBody3D.new()
	body.collision_layer = LumenfallTypes.PhysicsLayer.WORLD
	body.collision_mask = LumenfallTypes.PhysicsLayer.NONE
	body.position = at + Vector3.UP * collision_size.y * 0.5
	body.rotation.y = yaw
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = collision_size
	shape_node.shape = shape
	body.add_child(shape_node)
	add_child(body)


@private
func _add_npc(npc_id: LumenfallTypes.NpcId, display_name: String, at: Vector3, yaw: float) -> void:
	var actor := AdventureNpc.new()
	actor.configure(npc_id, display_name)
	actor.name = display_name
	actor.position = at
	actor.rotation.y = yaw
	add_child(actor)
	npcs[npc_id] = actor


@private
func _build_trees() -> void:
	var points: Array[Vector3] = [
		Vector3(-17, 0, -15), Vector3(15, 0, -14), Vector3(-19, 0, -2),
		Vector3(18, 0, 5), Vector3(-15, 0, 17), Vector3(13, 0, 16),
		Vector3(-5, 0, 22), Vector3(5, 0, 23), Vector3(22, 0, -4),
	]
	for index: int in range(points.size()):
		var asset_id := LumenfallTypes.AssetId.PINE if index % 3 == 0 else LumenfallTypes.AssetId.OAK
		_add_model(asset_id, points[index], float(index) * 0.73)
		var trunk := StaticBody3D.new()
		trunk.collision_layer = LumenfallTypes.PhysicsLayer.WORLD
		trunk.position = points[index] + Vector3.UP * 1.7
		var shape_node := CollisionShape3D.new()
		var cylinder_shape := CylinderShape3D.new()
		cylinder_shape.radius = 0.42
		cylinder_shape.height = 3.4
		shape_node.shape = cylinder_shape
		trunk.add_child(shape_node)
		add_child(trunk)


@private
func _add_village_landmark_collisions() -> void:
	_add_static_cylinder("WellCollision", Vector3(0.0, 0.55, -1.0), 1.12, 1.1)
	_add_static_box("WellBeamCollision", Vector3(0.0, 2.45, -1.0), Vector3(2.3, 0.22, 0.22))
	_add_static_box("BenchCollision", Vector3(3.0, 0.72, -1.0), Vector3(2.7, 1.25, 0.7))
	_add_static_cylinder("WaystoneCollision", Vector3(0.0, 1.15, -15.0), 1.25, 2.3)
	_add_static_box("WorkbenchCollision", Vector3(11.0, 0.72, -1.7), Vector3(2.5, 1.35, 0.8))


@private
func _add_workbench_visual() -> void:
	var root := Node3D.new()
	root.name = "BramWorkbench"
	root.position = Vector3(11.0, 0.0, -1.7)
	add_child(root)
	var top := MeshInstance3D.new()
	var top_mesh := BoxMesh.new()
	top_mesh.size = Vector3(2.5, 0.18, 0.82)
	top.mesh = top_mesh
	top.position.y = 0.82
	top.material_override = AdventureAssetLibrary.material(Color("573a24"), 0.92)
	root.add_child(top)
	for x: float in [-0.95, 0.95]:
		for z: float in [-0.25, 0.25]:
			var leg := MeshInstance3D.new()
			var leg_mesh := BoxMesh.new()
			leg_mesh.size = Vector3(0.16, 0.8, 0.16)
			leg.mesh = leg_mesh
			leg.position = Vector3(x, 0.4, z)
			leg.material_override = top.material_override
			root.add_child(leg)
	var lens := MeshInstance3D.new()
	var lens_mesh := TorusMesh.new()
	lens_mesh.inner_radius = 0.22
	lens_mesh.outer_radius = 0.3
	lens.mesh = lens_mesh
	lens.position = Vector3(0.35, 1.03, 0.0)
	lens.rotation.x = PI * 0.5
	lens.material_override = AdventureAssetLibrary.material(Color("d59b3d"), 0.35, Color("f0bc58"), 0.8)
	root.add_child(lens)


@private
func _build_eastern_lanterns() -> void:
	for index: int in range(4):
		var post := AdventureAssetLibrary.instantiate_model(LumenfallTypes.AssetId.LANTERN_POST)
		if not is_instance_valid(post):
			continue
		post.name = "EasternLantern_%d" % index
		post.position = Vector3(19.0 + index * 4.0, 0.0, -1.0 if index % 2 == 0 else 4.0)
		post.rotation.y = PI * 0.5 if index % 2 == 0 else -PI * 0.5
		add_child(post)
		var light := OmniLight3D.new()
		light.light_color = Color("77dcff")
		light.light_energy = 1.1
		light.omni_range = 7.0
		light.position = post.position + Vector3.UP * 2.4
		add_child(light)
	eastern_crossing = AdventureWorldInteractable.new()
	eastern_crossing.configure(LumenfallTypes.InteractionId.EASTERN_CROSSING, "Cross beyond the lanterns")
	eastern_crossing.position = Vector3(33.0, 0.0, 1.5)
	add_child(eastern_crossing)


@private
func _build_field_map() -> void:
	var root := Node3D.new()
	root.name = "MaraFieldMap"
	root.position = Vector3(-3.8, 0.0, 0.8)
	add_child(root)
	var table := MeshInstance3D.new()
	var table_mesh := BoxMesh.new()
	table_mesh.size = Vector3(2.4, 0.16, 1.5)
	table.mesh = table_mesh
	table.position.y = 0.82
	table.material_override = AdventureAssetLibrary.material(Color("553821"), 0.9)
	root.add_child(table)
	var map_sheet := MeshInstance3D.new()
	var sheet_mesh := PlaneMesh.new()
	sheet_mesh.size = Vector2(2.05, 1.2)
	map_sheet.mesh = sheet_mesh
	map_sheet.position.y = 0.92
	map_sheet.material_override = AdventureAssetLibrary.material(Color("c8b47f"), 0.88)
	root.add_child(map_sheet)
	for token_position: Vector3 in [Vector3(-0.55, 0.98, -0.25), Vector3(0.5, 0.98, -0.1), Vector3(0.0, 0.98, 0.36)]:
		var token := MeshInstance3D.new()
		var token_mesh := CylinderMesh.new()
		token_mesh.top_radius = 0.08
		token_mesh.bottom_radius = 0.08
		token_mesh.height = 0.05
		token.mesh = token_mesh
		token.position = token_position
		token.material_override = AdventureAssetLibrary.material(Color("36758b"), 0.4, Color("42b8d6"), 0.5)
		root.add_child(token)
	field_map = AdventureWorldInteractable.new()
	field_map.name = "FieldMapInteractable"
	field_map.configure(LumenfallTypes.InteractionId.FIELD_MAP, "Read Mara's field map")
	field_map.position = root.position
	add_child(field_map)
	_add_static_box("FieldMapCollision", root.position + Vector3.UP * 0.45, Vector3(2.5, 0.9, 1.6))


@private
func _add_static_box(body_name: String, at: Vector3, box_size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = LumenfallTypes.PhysicsLayer.WORLD
	body.position = at
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


@private
func _add_static_cylinder(body_name: String, at: Vector3, radius: float, height: float) -> void:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = LumenfallTypes.PhysicsLayer.WORLD
	body.position = at
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func apply_crossing_choice(profile: LumenfallSaveData) -> void:
	if has_node("CrossingAftermath"):
		return
	var choice := _crossing_choice(profile)
	if choice == LumenfallTypes.CrossingChoice.NONE:
		return
	var root := Node3D.new()
	root.name = "CrossingAftermath"
	root.position = Vector3(0.0, 0.0, -15.0)
	add_child(root)
	match choice:
		LumenfallTypes.CrossingChoice.SHELTER:
			_build_shelter_aftermath(root)
		LumenfallTypes.CrossingChoice.BRIDGE:
			_build_bridge_aftermath(root)
		LumenfallTypes.CrossingChoice.WITNESS:
			_build_witness_aftermath(root)
	crossing_aftermath = AdventureWorldInteractable.new()
	crossing_aftermath.name = "CrossingAftermathInteractable"
	crossing_aftermath.configure(LumenfallTypes.InteractionId.CROSSING_AFTERMATH, "Examine what your answer changed")
	crossing_aftermath.position = Vector3(-2.6, 0.0, -15.0)
	add_child(crossing_aftermath)


@private
func _crossing_choice(profile: LumenfallSaveData) -> LumenfallTypes.CrossingChoice:
	for choice: LumenfallTypes.CrossingChoice in [
		LumenfallTypes.CrossingChoice.SHELTER,
		LumenfallTypes.CrossingChoice.BRIDGE,
		LumenfallTypes.CrossingChoice.WITNESS,
	]:
		if AdventureInventory.count(profile, LumenfallTypes.crossing_choice_item(choice)) > 0:
			return choice
	return LumenfallTypes.CrossingChoice.NONE


@private
func _build_shelter_aftermath(root: Node3D) -> void:
	for index: int in range(12):
		var angle := float(index) / 12.0 * TAU
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.22, 1.6, 0.2)
		crystal.mesh = mesh
		crystal.position = Vector3(cos(angle) * 3.4, 0.8, sin(angle) * 3.4)
		crystal.rotation.y = -angle
		crystal.material_override = AdventureAssetLibrary.material(Color("68d5ef"), 0.22, Color("4ac8e6"), 1.4)
		root.add_child(crystal)
	var light := OmniLight3D.new()
	light.light_color = Color("69d9f2")
	light.light_energy = 2.4
	light.omni_range = 9.0
	light.position.y = 1.5
	root.add_child(light)


@private
func _build_bridge_aftermath(root: Node3D) -> void:
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
		ring.material_override = AdventureAssetLibrary.material(colors[index], 0.25, colors[index], 1.4)
		root.add_child(ring)


@private
func _build_witness_aftermath(root: Node3D) -> void:
	var ghost := AdventureAssetLibrary.instantiate_model(LumenfallTypes.AssetId.IVEN)
	if not is_instance_valid(ghost):
		return
	ghost.name = "ForgottenArchitectEcho"
	ghost.position = Vector3(0.0, 0.15, -0.4)
	ghost.scale = Vector3.ONE * 1.12
	root.add_child(ghost)
	var ghost_material := AdventureAssetLibrary.material(Color(0.48, 0.31, 0.72, 0.42), 0.25, Color("8e5ed3"), 1.3)
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for descendant: Node in ghost.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		mesh_instance.material_override = ghost_material
	var light := OmniLight3D.new()
	light.light_color = Color("9a68df")
	light.light_energy = 2.0
	light.omni_range = 7.0
	light.position.y = 1.4
	root.add_child(light)
