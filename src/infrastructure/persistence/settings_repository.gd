class_name SettingsRepository
extends RefCounted

const SETTINGS_PATH := "user://lumenfall_settings.cclbin"


static func load_settings() -> LumenfallSettings:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return defaults()
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not is_instance_valid(file):
		return defaults()
	var settings := LumenfallSettings.deserialize_binary(file.get_buffer(file.get_length()))
	file.close()
	if not is_instance_valid(settings) or settings.schema_version <= 0:
		return defaults()
	settings.master_volume = clampf(settings.master_volume, 0.0, 1.0)
	settings.mouse_sensitivity = clampf(settings.mouse_sensitivity, 0.0008, 0.006)
	settings.field_of_view = clampf(settings.field_of_view, 55.0, 90.0)
	return settings


static func save_settings(settings: LumenfallSettings) -> bool:
	settings.schema_version = 1
	var temporary_path := SETTINGS_PATH + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if not is_instance_valid(file):
		return false
	file.store_buffer(settings.serialize_binary())
	file.flush()
	file.close()
	var target := ProjectSettings.globalize_path(SETTINGS_PATH)
	var temporary := ProjectSettings.globalize_path(temporary_path)
	if FileAccess.file_exists(SETTINGS_PATH):
		DirAccess.remove_absolute(target)
	return DirAccess.rename_absolute(temporary, target) == OK


static func apply(settings: LumenfallSettings) -> void:
	var master_index := AudioServer.get_bus_index(&"Master")
	if master_index >= 0:
		AudioServer.set_bus_volume_db(master_index, linear_to_db(maxf(0.001, settings.master_volume)))
		AudioServer.set_bus_mute(master_index, settings.master_volume <= 0.001)
	var desired_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_MAXIMIZED
	if DisplayServer.window_get_mode() != desired_mode:
		DisplayServer.window_set_mode(desired_mode)


static func defaults() -> LumenfallSettings:
	var settings := LumenfallSettings.new()
	settings.schema_version = 1
	settings.master_volume = 0.78
	settings.mouse_sensitivity = 0.0024
	settings.invert_vertical = false
	settings.field_of_view = 68.0
	settings.fullscreen = DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	settings.reduce_motion = false
	return settings
