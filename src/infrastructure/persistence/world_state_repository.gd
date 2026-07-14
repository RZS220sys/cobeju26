class_name WorldStateRepository
extends RefCounted

const SCHEMA_VERSION := 1


static func load_state(world_id: String) -> LumenfallWorldState:
	var path := StoragePaths.world_file(world_id)
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return null
	var decoded := LumenfallWorldState.deserialize_binary(file.get_buffer(file.get_length()))
	file.close()
	if not is_instance_valid(decoded) or decoded.schema_version != SCHEMA_VERSION or decoded.world_id != world_id:
		return null
	return decoded


static func save_state(state: LumenfallWorldState) -> bool:
	StoragePaths.ensure_world(state.world_id)
	state.schema_version = SCHEMA_VERSION
	state.last_played_unix = floori(Time.get_unix_time_from_system())
	return AtomicFileWriter.write(StoragePaths.world_file(state.world_id), state.serialize_binary())
