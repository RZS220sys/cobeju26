class_name GameDirector
extends Node

var _title_screen: PalimpsestTitleScreen
var _world: EchoWorld
var _verdict_screen: MemoryVerdictScreen
var _profile: PalimpsestSaveData
var _surface_screen: Control
var _soundscape: ArchiveSoundscape
var _ending_screen: EndingScreen


@override
func _ready() -> void:
	_profile = ArchiveSaveManager.load_profile()
	_apply_profile_settings()
	_soundscape = ArchiveSoundscape.new()
	_soundscape.name = "Soundscape"
	add_child(_soundscape)
	_show_title()


@private
func _show_title() -> void:
	if is_instance_valid(_world):
		_world.queue_free()
	_title_screen = PalimpsestTitleScreen.new()
	_title_screen.name = "TitleScreen"
	_title_screen.configure(_profile)
	_title_screen.expedition_requested.connect(_begin_expedition)
	_title_screen.archive_requested.connect(_show_archive)
	_title_screen.workshop_requested.connect(_show_workshop)
	_title_screen.settings_requested.connect(_show_settings)
	_title_screen.credits_requested.connect(_show_credits)
	_title_screen.quit_requested.connect(get_tree().quit)
	add_child(_title_screen)


@private
func _begin_expedition() -> void:
	if is_instance_valid(_title_screen):
		_title_screen.queue_free()
	_profile.last_seed = absi(hash("%s:%s:%s" % [_profile.last_seed, _profile.expeditions, Time.get_unix_time_from_system()]))
	_world = EchoWorld.new()
	_world.name = "EchoWorld"
	_world.configure(_profile, _soundscape)
	_world.expedition_finished.connect(_on_expedition_finished)
	add_child(_world)


@private
func _on_expedition_finished(result: ExpeditionResult) -> void:
	_profile.expeditions += 1
	_profile.total_echoes += result.echoes
	_profile.total_hollows += result.hollows
	_profile.archive_fragments += result.echoes + floori(float(result.hollows) / 3.0) + result.tide_bonus
	for record: String in result.recovered_records:
		if record not in _profile.discovered_records:
			_profile.discovered_records.append(record)
	if result.victory:
		_profile.successful_expeditions += 1
		_profile.story_depth += 1
		if _profile.best_time_seconds <= 0.0 or result.elapsed_seconds < _profile.best_time_seconds:
			_profile.best_time_seconds = result.elapsed_seconds
	ArchiveSaveManager.save_profile(_profile)
	if is_instance_valid(_world):
		_world.queue_free()
	if result.victory:
		_verdict_screen = MemoryVerdictScreen.new()
		_verdict_screen.name = "MemoryVerdict"
		_verdict_screen.configure(result, _profile.story_depth)
		_verdict_screen.verdict_chosen.connect(_on_verdict_chosen)
		add_child.call_deferred(_verdict_screen)
	else:
		_show_title.call_deferred()


@private
func _on_verdict_chosen(path: StringName) -> void:
	_soundscape.play_verdict()
	match path:
		&"witness":
			_profile.witness_affinity += 1
			_unlock_boon(&"unbroken_testimony")
		&"mercy":
			_profile.mercy_affinity += 1
			_unlock_boon(&"kind_ending")
		&"continuance":
			_profile.continuance_affinity += 1
			_unlock_boon(&"golden_revision")
	ArchiveSaveManager.save_profile(_profile)
	if is_instance_valid(_verdict_screen):
		_verdict_screen.queue_free()
	if _profile.story_depth >= 4:
		var ending_id := String(path)
		if ending_id not in _profile.endings_seen:
			_profile.endings_seen.append(ending_id)
		ArchiveSaveManager.save_profile(_profile)
		_ending_screen = EndingScreen.new()
		_ending_screen.name = "Ending"
		_ending_screen.configure(path)
		_ending_screen.continue_requested.connect(_on_ending_continue)
		add_child.call_deferred(_ending_screen)
	else:
		_show_title.call_deferred()


@private
func _unlock_boon(boon_id: StringName) -> void:
	var boon_text := String(boon_id)
	if boon_text not in _profile.unlocked_boons:
		_profile.unlocked_boons.append(boon_text)


@private
func _on_ending_continue() -> void:
	if is_instance_valid(_ending_screen):
		_ending_screen.queue_free()
	_show_title.call_deferred()


@private
func _show_archive() -> void:
	_close_title()
	var archive := ArchiveScreen.new()
	archive.name = "SurfaceArchive"
	archive.configure(_profile)
	archive.back_requested.connect(_return_from_surface)
	_surface_screen = archive
	add_child(archive)


@private
func _show_workshop() -> void:
	_close_title()
	var workshop := WorkshopScreen.new()
	workshop.name = "LanternWorkshop"
	workshop.configure(_profile)
	workshop.back_requested.connect(_return_from_surface)
	_surface_screen = workshop
	add_child(workshop)


@private
func _show_settings() -> void:
	_close_title()
	var settings := SettingsScreen.new()
	settings.name = "Settings"
	settings.configure(_profile)
	settings.back_requested.connect(_return_from_surface)
	_surface_screen = settings
	add_child(settings)


@private
func _show_credits() -> void:
	_close_title()
	var credits := CreditsScreen.new()
	credits.name = "Credits"
	credits.back_requested.connect(_return_from_surface)
	_surface_screen = credits
	add_child(credits)


@private
func _close_title() -> void:
	if is_instance_valid(_title_screen):
		_title_screen.queue_free()


@private
func _return_from_surface() -> void:
	if is_instance_valid(_surface_screen):
		_surface_screen.queue_free()
	_show_title.call_deferred()


@private
func _apply_profile_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(_profile.master_volume))
	AudioServer.set_bus_mute(0, _profile.master_volume <= 0.001)
	if _profile.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
