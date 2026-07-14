class_name NpcActor
extends CharacterBody3D

var npc_id: NpcCatalog.Id
var display_name: String
var model_id: ModelCatalog.Id
var interaction_prompt: String
var persistent_state: LumenfallNpcState

var _world_id: String = ""
var _marker: Label3D


func bind_world(world_id: String) -> void:
	_world_id = world_id
	persistent_state = NpcStateRepository.load_state(_world_id, identity_id())


@override
func _ready() -> void:
	npc_id = identity_id()
	display_name = identity_name()
	model_id = identity_model()
	interaction_prompt = "Talk to %s" % display_name
	name = display_name
	collision_layer = PhysicsLayers.Id.WORLD
	collision_mask = PhysicsLayers.Id.WORLD
	add_to_group(&"npcs")
	if not is_instance_valid(persistent_state):
		persistent_state = _transient_state()
	_build_collision()
	if shows_interaction_marker():
		_build_marker()
	_restore_position()
	build_visual()
	configure_behavior()


@override
func _exit_tree() -> void:
	save_state()


func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.NIA


func identity_name() -> String:
	return "NPC"


func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.for_npc(identity_id())


func body_radius() -> float:
	return 0.38


func body_height() -> float:
	return 1.78


func shows_interaction_marker() -> bool:
	return false


func build_visual() -> void:
	pass


func configure_behavior() -> void:
	pass


func greet(_player_position: Vector3) -> void:
	pass


func remember_event(event_id: NpcCatalog.Event) -> void:
	if event_id in persistent_state.important_event_ids:
		return
	persistent_state.important_event_ids.append(event_id)
	react_to_event(event_id)
	save_state()


func react_to_event(_event_id: NpcCatalog.Event) -> void:
	pass


func set_relationship(other_npc: NpcCatalog.Id, value: float) -> void:
	var clamped := clampf(value, -1.0, 1.0)
	var index := persistent_state.relationship_npc_ids.find(other_npc)
	if index < 0:
		persistent_state.relationship_npc_ids.append(other_npc)
		persistent_state.relationship_values.append(clamped)
	else:
		persistent_state.relationship_values[index] = clamped
	save_state()


func relationship_with(other_npc: NpcCatalog.Id) -> float:
	var index := persistent_state.relationship_npc_ids.find(other_npc)
	if index < 0 or index >= persistent_state.relationship_values.size():
		return 0.0
	return persistent_state.relationship_values[index]


func save_state() -> void:
	if _world_id.is_empty() or not is_instance_valid(persistent_state):
		return
	persistent_state.position_x = global_position.x
	persistent_state.position_y = global_position.y
	persistent_state.position_z = global_position.z
	NpcStateRepository.save_state(_world_id, persistent_state)


func set_interaction_focus(focused: bool) -> void:
	if is_instance_valid(_marker):
		_marker.visible = focused


func get_interaction_prompt() -> String:
	return interaction_prompt


@private
func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = body_radius()
	shape.height = body_height()
	collision.shape = shape
	collision.position.y = shape.height * 0.5
	add_child(collision)


@private
func _build_marker() -> void:
	_marker = Label3D.new()
	_marker.name = "InteractionMarker"
	_marker.text = "◇\n%s" % display_name
	_marker.position.y = body_height() + 0.45
	_marker.font_size = 26
	_marker.outline_size = 8
	_marker.modulate = Color(1.0, 0.82, 0.34, 0.95)
	_marker.no_depth_test = true
	_marker.visible = false
	add_child(_marker)


@private
func _restore_position() -> void:
	if not persistent_state.has_position:
		persistent_state.position_x = global_position.x
		persistent_state.position_y = global_position.y
		persistent_state.position_z = global_position.z
		persistent_state.has_position = true
		return
	global_position = Vector3(persistent_state.position_x, persistent_state.position_y, persistent_state.position_z)


@private
func _transient_state() -> LumenfallNpcState:
	var state := LumenfallNpcState.new()
	state.npc_id = identity_id()
	state.mood = NpcCatalog.Mood.CALM
	state.behavior = NpcCatalog.Behavior.IDLE
	state.hope = 0.5
	state.important_event_ids = [] as Array[int]
	state.relationship_npc_ids = [] as Array[int]
	state.relationship_values = [] as Array[float]
	state.choice_ids = [] as Array[int]
	return state
