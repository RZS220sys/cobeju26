class_name WorldIndexRepository
extends RefCounted

const SCHEMA_VERSION := 1


static func load_index() -> LumenfallWorldIndex:
	StoragePaths.ensure_root()
	var path := StoragePaths.index_file()
	if not FileAccess.file_exists(path):
		return _empty_index()
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return _empty_index()
	var decoded := LumenfallWorldIndex.deserialize_binary(file.get_buffer(file.get_length()))
	file.close()
	if not is_instance_valid(decoded) or decoded.schema_version != SCHEMA_VERSION:
		return _empty_index()
	return decoded


static func save_index(index: LumenfallWorldIndex) -> bool:
	index.schema_version = SCHEMA_VERSION
	return AtomicFileWriter.write(StoragePaths.index_file(), index.serialize_binary())


static func upsert(world_state: LumenfallWorldState) -> bool:
	var index := load_index()
	var summary := _find_summary(index, world_state.world_id)
	if not is_instance_valid(summary):
		summary = LumenfallWorldSummary.new()
		index.worlds.append(summary)
	_update_summary(summary, world_state)
	index.last_world_id = world_state.world_id
	return save_index(index)


static func remove(world_id: String) -> bool:
	var index := load_index()
	for summary_index: int in range(index.worlds.size() - 1, -1, -1):
		var summary := index.worlds[summary_index]
		if is_instance_valid(summary) and summary.world_id == world_id:
			index.worlds.remove_at(summary_index)
	if index.last_world_id == world_id:
		index.last_world_id = ""
	return save_index(index)


@private
static func _find_summary(index: LumenfallWorldIndex, world_id: String) -> LumenfallWorldSummary:
	for summary: LumenfallWorldSummary in index.worlds:
		if is_instance_valid(summary) and summary.world_id == world_id:
			return summary
	return null


@private
static func _update_summary(summary: LumenfallWorldSummary, state: LumenfallWorldState) -> void:
	summary.world_id = state.world_id
	summary.display_name = state.display_name
	summary.played_seconds = state.played_seconds
	summary.quest_stage = state.quest_stage
	summary.last_played_unix = state.last_played_unix


@private
static func _empty_index() -> LumenfallWorldIndex:
	var index := LumenfallWorldIndex.new()
	index.schema_version = SCHEMA_VERSION
	index.worlds = [] as Array[LumenfallWorldSummary]
	index.last_world_id = ""
	return index
