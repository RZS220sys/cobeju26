class_name ArchiveSaveManager
extends RefCounted


static func load_profile() -> PalimpsestSaveData:
	var path := _save_path()
	if not FileAccess.file_exists(path):
		return create_default_profile()
	var file := FileAccess.open(path, FileAccess.READ)
	if not is_instance_valid(file):
		return create_default_profile()
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var profile := PalimpsestSaveData.deserialize_binary(bytes)
	if not is_instance_valid(profile) or profile.schema_version <= 0:
		return create_default_profile()
	if profile.unlocked_boons == null:
		profile.unlocked_boons = [] as Array[String]
	if profile.discovered_records == null:
		profile.discovered_records = [] as Array[String]
	if profile.endings_seen == null:
		profile.endings_seen = [] as Array[String]
	profile.schema_version = 3
	return profile


static func save_profile(profile: PalimpsestSaveData) -> bool:
	var target_path := _save_path()
	var temporary_path := target_path + ".tmp"
	var backup_path := target_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if not is_instance_valid(file):
		push_error("Could not open temporary Archive save: %s" % FileAccess.get_open_error())
		return false
	file.store_buffer(profile.serialize_binary())
	file.flush()
	file.close()
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	if FileAccess.file_exists(target_path):
		var backup_error := DirAccess.rename_absolute(target_path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temporary_path)
			push_error("Could not rotate Archive save: %s" % error_string(backup_error))
			return false
	var commit_error := DirAccess.rename_absolute(temporary_path, target_path)
	if commit_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, target_path)
		push_error("Could not commit Archive save: %s" % error_string(commit_error))
		return false
	return true


static func create_default_profile() -> PalimpsestSaveData:
	var profile := PalimpsestSaveData.new()
	profile.schema_version = 3
	profile.expeditions = 0
	profile.successful_expeditions = 0
	profile.total_echoes = 0
	profile.total_hollows = 0
	profile.archive_fragments = 0
	profile.unlocked_boons = [&"steady_wick"] as Array[String]
	profile.discovered_records = [] as Array[String]
	profile.witness_affinity = 0
	profile.mercy_affinity = 0
	profile.continuance_affinity = 0
	profile.best_time_seconds = 0.0
	profile.last_seed = 1907
	profile.difficulty = 1
	profile.aim_assist = true
	profile.master_volume = 0.8
	profile.fullscreen = true
	profile.tutorial_seen = false
	profile.story_depth = 0
	profile.endings_seen = [] as Array[String]
	profile.wick_rank = 0
	profile.lens_rank = 0
	profile.reservoir_rank = 0
	return profile


@private
static func _save_path() -> String:
	return "user://palimpsest_archive.cclbin"
