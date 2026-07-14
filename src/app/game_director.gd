class_name GameDirector
extends Node

var _world_selection_screen: WorldSelectionScreen
var _world: LumenfallWorld


@override
func _ready() -> void:
	_show_world_selection()


@private
func _show_world_selection() -> void:
	_world_selection_screen = WorldSelectionScreen.new()
	_world_selection_screen.name = "WorldSelectionScreen"
	_world_selection_screen.world_selected.connect(_start_world)
	add_child(_world_selection_screen)


@private
func _start_world(state: LumenfallWorldState) -> void:
	if is_instance_valid(_world_selection_screen):
		_world_selection_screen.queue_free()
	_world = LumenfallWorld.new()
	_world.name = "LumenfallWorld"
	_world.configure(state)
	_world.traveler_book_requested.connect(_return_to_world_selection)
	add_child(_world)


@private
func _return_to_world_selection() -> void:
	if is_instance_valid(_world):
		_world.queue_free()
		_world = null
	_show_world_selection.call_deferred()


@override
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(_world):
			_world.persistence.save_checkpoint()
		get_tree().quit()
