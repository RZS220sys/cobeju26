class_name NpcStateRepository
extends RefCounted

const SCHEMA_VERSION := 1


static func load_state(world_id: String, npc_id: NpcCatalog.Id) -> LumenfallNpcState:
	var path := StoragePaths.npc_file(world_id, npc_id)
	if not FileAccess.file_exists(path):
		return create_state(world_id, npc_id)
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return create_state(world_id, npc_id)
	var decoded := LumenfallNpcState.deserialize_binary(file.get_buffer(file.get_length()))
	file.close()
	if not is_instance_valid(decoded) or decoded.schema_version != SCHEMA_VERSION or decoded.npc_id != npc_id:
		return create_state(world_id, npc_id)
	return decoded


static func save_state(world_id: String, state: LumenfallNpcState) -> bool:
	StoragePaths.ensure_world(world_id)
	state.schema_version = SCHEMA_VERSION
	return AtomicFileWriter.write(StoragePaths.npc_file(world_id, state.npc_id), state.serialize_binary())


static func create_state(world_id: String, npc_id: NpcCatalog.Id) -> LumenfallNpcState:
	var state := LumenfallNpcState.new()
	state.schema_version = SCHEMA_VERSION
	state.npc_id = npc_id
	state.mood = NpcCatalog.Mood.CALM
	state.behavior = NpcCatalog.Behavior.IDLE
	state.trust_player = 0.0
	state.fear = 0.0
	state.hope = 0.5
	state.important_event_ids = [] as Array[int]
	state.relationship_npc_ids = [] as Array[int]
	state.relationship_values = [] as Array[float]
	state.choice_ids = [] as Array[int]
	save_state(world_id, state)
	return state


static func create_world_states(world_id: String) -> void:
	for npc_id: NpcCatalog.Id in NpcCatalog.persistent_ids():
		create_state(world_id, npc_id)
