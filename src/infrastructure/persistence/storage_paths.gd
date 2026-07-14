class_name StoragePaths
extends RefCounted

const ROOT := "user://game_data"


static func ensure_root() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT))


static func ensure_world(world_id: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(npc_directory(world_id)))


static func index_file() -> String:
	return "%s/index.cclbin" % ROOT


static func world_directory(world_id: String) -> String:
	return "%s/%s" % [ROOT, _safe_world_id(world_id)]


static func world_file(world_id: String) -> String:
	return "%s/world.cclbin" % world_directory(world_id)


static func npc_directory(world_id: String) -> String:
	return "%s/npcs" % world_directory(world_id)


static func npc_file(world_id: String, npc_id: NpcCatalog.Id) -> String:
	return "%s/%s.cclbin" % [npc_directory(world_id), NpcCatalog.file_stem(npc_id)]


static func absolute_world_directory(world_id: String) -> String:
	return ProjectSettings.globalize_path(world_directory(world_id))


@private
static func _safe_world_id(world_id: String) -> String:
	return world_id.validate_filename()
