class_name HearthmereInteractions
extends Node3D

var waystone: WorldInteractable
var workshop: WorldInteractable
var eastern_crossing: WorldInteractable
var field_map: WorldInteractable


@override
func _ready() -> void:
	name = "Interactions"
	waystone = _add_interactable(InteractionCatalog.Id.WAYSTONE, "Touch the sleeping Waystone", Vector3(0.0, 0.0, -15.0))
	workshop = _add_interactable(InteractionCatalog.Id.BRAM_WORKBENCH, "Use Bram's lantern bench", Vector3(11.0, 0.0, -1.7))
	_build_workbench()
	_build_eastern_lanterns()
	_build_field_map()


@private
func _add_interactable(interaction_id: InteractionCatalog.Id, prompt: String, at: Vector3) -> WorldInteractable:
	var interactable := WorldInteractable.new()
	interactable.configure(interaction_id, prompt)
	interactable.position = at
	add_child(interactable)
	return interactable


@private
func _build_workbench() -> void:
	var root := Node3D.new()
	root.name = "BramWorkbench"
	root.position = Vector3(11.0, 0.0, -1.7)
	add_child(root)
	var top := MeshInstance3D.new()
	var top_mesh := BoxMesh.new()
	top_mesh.size = Vector3(2.5, 0.18, 0.82)
	top.mesh = top_mesh
	top.position.y = 0.82
	top.material_override = ModelLibrary.material(Color("573a24"), 0.92)
	root.add_child(top)
	for x: float in [-0.95, 0.95]:
		for z: float in [-0.25, 0.25]:
			var leg := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.16, 0.8, 0.16)
			leg.mesh = mesh
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
	lens.material_override = ModelLibrary.material(Color("d59b3d"), 0.35, Color("f0bc58"), 0.8)
	root.add_child(lens)


@private
func _build_eastern_lanterns() -> void:
	for index: int in range(4):
		var post := ModelLibrary.instantiate_model(ModelCatalog.Id.LANTERN_POST)
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
	eastern_crossing = _add_interactable(InteractionCatalog.Id.EASTERN_CROSSING, "Cross beyond the lanterns", Vector3(33.0, 0.0, 1.5))


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
	table.material_override = ModelLibrary.material(Color("553821"), 0.9)
	root.add_child(table)
	var map_sheet := MeshInstance3D.new()
	var sheet_mesh := PlaneMesh.new()
	sheet_mesh.size = Vector2(2.05, 1.2)
	map_sheet.mesh = sheet_mesh
	map_sheet.position.y = 0.92
	map_sheet.material_override = ModelLibrary.material(Color("c8b47f"), 0.88)
	root.add_child(map_sheet)
	for token_position: Vector3 in [Vector3(-0.55, 0.98, -0.25), Vector3(0.5, 0.98, -0.1), Vector3(0.0, 0.98, 0.36)]:
		var token := MeshInstance3D.new()
		var token_mesh := CylinderMesh.new()
		token_mesh.top_radius = 0.08
		token_mesh.bottom_radius = 0.08
		token_mesh.height = 0.05
		token.mesh = token_mesh
		token.position = token_position
		token.material_override = ModelLibrary.material(Color("36758b"), 0.4, Color("42b8d6"), 0.5)
		root.add_child(token)
	field_map = _add_interactable(InteractionCatalog.Id.FIELD_MAP, "Read Mara's field map", root.position)
	field_map.name = "FieldMapInteractable"
	ColliderFactory.add_box(self, "FieldMapCollision", root.position + Vector3.UP * 0.45, Vector3(2.5, 0.9, 1.6))
