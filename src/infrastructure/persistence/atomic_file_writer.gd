class_name AtomicFileWriter
extends RefCounted


static func write(path: String, data: PackedByteArray) -> bool:
	var temporary_path := path + ".tmp"
	var backup_path := path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if not is_instance_valid(file):
		push_error("Could not write save data: %s" % FileAccess.get_open_error())
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
	if commit_error == OK:
		return true
	if FileAccess.file_exists(backup_path):
		DirAccess.rename_absolute(global_backup, global_target)
	return false
