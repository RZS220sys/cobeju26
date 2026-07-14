class_name AdventureProfileStore
extends RefCounted


static func load_index() -> LumenfallProfileIndex:
	_ensure_directory()
	var path := _index_path()
	if not FileAccess.file_exists(path):
		return _default_index()
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return _default_index()
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var index := LumenfallProfileIndex.deserialize_binary(bytes)
	if not is_instance_valid(index) or index.schema_version <= 0:
		return _default_index()
	if index.profiles == null:
		index.profiles = [] as Array[LumenfallProfileSummary]
	index.schema_version = 1
	return index


static func create_profile(display_name: String) -> LumenfallSaveData:
	var cleaned_name := display_name.strip_edges()
	if cleaned_name.is_empty():
		cleaned_name = "Wayfarer"
	cleaned_name = cleaned_name.left(24)
	var profile_id := "%d_%d" % [floori(Time.get_unix_time_from_system()), Time.get_ticks_msec() % 100000]
	var profile := _default_profile(profile_id, cleaned_name)
	save_profile(profile)
	return profile


static func load_profile(profile_id: String) -> LumenfallSaveData:
	var path := _profile_path(profile_id)
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return null
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var profile := LumenfallSaveData.deserialize_binary(bytes)
	if not is_instance_valid(profile) or profile.schema_version <= 0 or profile.profile_id != profile_id:
		return null
	return profile


static func save_profile(profile: LumenfallSaveData) -> bool:
	_ensure_directory()
	profile.schema_version = 1
	profile.last_played_unix = floori(Time.get_unix_time_from_system())
	if not _write_atomic(_profile_path(profile.profile_id), profile.serialize_binary()):
		return false
	var index := load_index()
	var found := false
	for summary: LumenfallProfileSummary in index.profiles:
		if is_instance_valid(summary) and summary.profile_id == profile.profile_id:
			_update_summary(summary, profile)
			found = true
			break
	if not found:
		var summary := LumenfallProfileSummary.new()
		_update_summary(summary, profile)
		index.profiles.append(summary)
	index.last_profile_id = profile.profile_id
	return _save_index(index)


static func delete_profile(profile_id: String) -> bool:
	var index := load_index()
	for summary_index: int in range(index.profiles.size() - 1, -1, -1):
		var summary := index.profiles[summary_index]
		if is_instance_valid(summary) and summary.profile_id == profile_id:
			index.profiles.remove_at(summary_index)
	if index.last_profile_id == profile_id:
		index.last_profile_id = ""
	var path := _profile_path(profile_id)
	var backup_path := path + ".bak"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(backup_path))
	return _save_index(index)


static func reset_profile(profile_id: String) -> LumenfallSaveData:
	var old_profile := load_profile(profile_id)
	var display_name := old_profile.display_name if is_instance_valid(old_profile) else "Wayfarer"
	var reset := _default_profile(profile_id, display_name)
	save_profile(reset)
	return reset


@private
static func _default_index() -> LumenfallProfileIndex:
	var index := LumenfallProfileIndex.new()
	index.schema_version = 1
	index.profiles = [] as Array[LumenfallProfileSummary]
	index.last_profile_id = ""
	return index


@private
static func _default_profile(profile_id: String, display_name: String) -> LumenfallSaveData:
	var profile := LumenfallSaveData.new()
	profile.schema_version = 1
	profile.profile_id = profile_id
	profile.display_name = display_name
	profile.played_seconds = 0.0
	profile.player_x = 0.0
	profile.player_y = 0.1
	profile.player_z = -11.2
	profile.player_yaw = 0.0
	profile.quest_stage = LumenfallTypes.QuestStage.SUMMONED
	profile.active_quest_id = LumenfallTypes.QuestId.THE_WRONG_STAR
	profile.completed_quest_ids = [] as Array[int]
	profile.inventory_item_ids = [] as Array[int]
	profile.inventory_item_counts = [] as Array[int]
	profile.unlocked_recipe_ids = [] as Array[int]
	profile.gold_coins = 0
	profile.riftglass_pieces = 0
	profile.current_health = 100.0
	profile.maximum_health = 100.0
	profile.last_played_unix = floori(Time.get_unix_time_from_system())
	profile.tutorial_stage = LumenfallTypes.TutorialStage.NOT_STARTED
	return profile


@private
static func _update_summary(summary: LumenfallProfileSummary, profile: LumenfallSaveData) -> void:
	summary.profile_id = profile.profile_id
	summary.display_name = profile.display_name
	summary.played_seconds = profile.played_seconds
	summary.quest_stage = profile.quest_stage
	summary.last_played_unix = profile.last_played_unix


@private
static func _save_index(index: LumenfallProfileIndex) -> bool:
	index.schema_version = 1
	return _write_atomic(_index_path(), index.serialize_binary())


@private
static func _write_atomic(path: String, data: PackedByteArray) -> bool:
	var temporary_path := path + ".tmp"
	var backup_path := path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if not is_instance_valid(file):
		push_error("Could not write LUMENFALL save: %s" % FileAccess.get_open_error())
		return false
	file.store_buffer(data)
	file.flush()
	file.close()
	var global_target := ProjectSettings.globalize_path(path)
	var global_temporary := ProjectSettings.globalize_path(temporary_path)
	var global_backup := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(global_backup)
	if FileAccess.file_exists(path):
		var rotate_error := DirAccess.rename_absolute(global_target, global_backup)
		if rotate_error != OK:
			DirAccess.remove_absolute(global_temporary)
			return false
	var commit_error := DirAccess.rename_absolute(global_temporary, global_target)
	if commit_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(global_backup, global_target)
		return false
	return true


@private
static func _ensure_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://lumenfall_profiles"))


@private
static func _index_path() -> String:
	return "user://lumenfall_profiles/index.cclbin"


@private
static func _profile_path(profile_id: String) -> String:
	var safe_id := profile_id.validate_filename()
	return "user://lumenfall_profiles/%s.cclbin" % safe_id
