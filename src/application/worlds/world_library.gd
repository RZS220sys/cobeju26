class_name WorldLibrary
extends RefCounted


static func list_worlds() -> LumenfallWorldIndex:
	var index := WorldIndexRepository.load_index()
	index.worlds.sort_custom(_recent_world_first)
	return index


static func create_world(display_name: String) -> LumenfallWorldState:
	var world_id := "%d_%d" % [floori(Time.get_unix_time_from_system()), Time.get_ticks_msec() % 100000]
	var state := _new_state(world_id, _clean_name(display_name))
	NpcStateRepository.create_world_states(world_id)
	save_world(state)
	return state


static func load_world(world_id: String) -> LumenfallWorldState:
	return WorldStateRepository.load_state(world_id)


static func save_world(state: LumenfallWorldState) -> bool:
	if not WorldStateRepository.save_state(state):
		return false
	return WorldIndexRepository.upsert(state)


static func reset_world(world_id: String) -> LumenfallWorldState:
	var previous := load_world(world_id)
	var display_name := previous.display_name if is_instance_valid(previous) else "Wayfarer"
	_delete_world_directory(world_id)
	var state := _new_state(world_id, display_name)
	NpcStateRepository.create_world_states(world_id)
	save_world(state)
	return state


static func delete_world(world_id: String) -> bool:
	_delete_world_directory(world_id)
	return WorldIndexRepository.remove(world_id)


static func shareable_directory(world_id: String) -> String:
	return StoragePaths.absolute_world_directory(world_id)


@private
static func _new_state(world_id: String, display_name: String) -> LumenfallWorldState:
	var state := LumenfallWorldState.new()
	state.schema_version = WorldStateRepository.SCHEMA_VERSION
	state.world_id = world_id
	state.display_name = display_name
	state.player_y = 0.1
	state.player_z = -11.2
	state.quest_stage = QuestCatalog.Stage.SUMMONED
	state.active_quest_id = QuestCatalog.Id.THE_WRONG_STAR
	state.completed_quest_ids = [] as Array[int]
	state.inventory_item_ids = [] as Array[int]
	state.inventory_item_counts = [] as Array[int]
	state.unlocked_recipe_ids = [] as Array[int]
	state.maximum_health = 100.0
	state.current_health = 100.0
	state.tutorial_stage = TutorialCatalog.Stage.NOT_STARTED
	return state


@private
static func _clean_name(display_name: String) -> String:
	var cleaned := display_name.strip_edges()
	if cleaned.is_empty():
		cleaned = "Wayfarer"
	return cleaned.left(24)


@private
static func _recent_world_first(left: LumenfallWorldSummary, right: LumenfallWorldSummary) -> bool:
	if not is_instance_valid(left):
		return false
	if not is_instance_valid(right):
		return true
	if left.last_played_unix != right.last_played_unix:
		return left.last_played_unix > right.last_played_unix
	return left.world_id > right.world_id


@private
static func _delete_world_directory(world_id: String) -> void:
	var absolute_path := StoragePaths.absolute_world_directory(world_id)
	_remove_directory_tree(absolute_path)


@private
static func _remove_directory_tree(absolute_path: String) -> void:
	if not DirAccess.dir_exists_absolute(absolute_path):
		return
	for child_file: String in DirAccess.get_files_at(absolute_path):
		DirAccess.remove_absolute(absolute_path.path_join(child_file))
	for child_directory: String in DirAccess.get_directories_at(absolute_path):
		_remove_directory_tree(absolute_path.path_join(child_directory))
	DirAccess.remove_absolute(absolute_path)
