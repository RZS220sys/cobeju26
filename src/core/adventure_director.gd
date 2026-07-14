class_name LumenfallAdventureDirector
extends Node

var _profile_screen: AdventureProfileScreen
var _world: LumenfallAdventureWorld


@override
func _ready() -> void:
	_show_profiles()


@private
func _show_profiles() -> void:
	_profile_screen = AdventureProfileScreen.new()
	_profile_screen.name = "ProfileScreen"
	_profile_screen.profile_selected.connect(_start_adventure)
	add_child(_profile_screen)


@private
func _start_adventure(profile: LumenfallSaveData) -> void:
	if is_instance_valid(_profile_screen):
		_profile_screen.queue_free()
	_world = LumenfallAdventureWorld.new()
	_world.name = "AdventureWorld"
	_world.configure(profile)
	_world.traveler_book_requested.connect(_return_to_profiles)
	add_child(_world)


@private
func _return_to_profiles() -> void:
	if is_instance_valid(_world):
		_world.queue_free()
		_world = null
	_show_profiles.call_deferred()


@override
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(_world):
			_world.save_checkpoint()
		get_tree().quit()
