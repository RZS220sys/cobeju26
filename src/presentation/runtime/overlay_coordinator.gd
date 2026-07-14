class_name OverlayCoordinator
extends Node

signal traveler_book_requested

var world_state: LumenfallWorldState
var player: WayfarerController
var camera_rig: ThirdPersonCamera
var settings: LumenfallSettings
var persistence: WorldPersistenceController
var workshop: WorkshopMenu
var region_map: RegionMap
var _pause_menu: PauseMenu
var _settings_panel: SettingsPanel


func configure(state: LumenfallWorldState, player_controller: WayfarerController, camera_controller: ThirdPersonCamera, game_settings: LumenfallSettings, persistence_controller: WorldPersistenceController) -> void:
	world_state = state
	player = player_controller
	camera_rig = camera_controller
	settings = game_settings
	persistence = persistence_controller


@override
func _ready() -> void:
	_pause_menu = PauseMenu.new()
	_pause_menu.resume_requested.connect(_resume)
	_pause_menu.settings_requested.connect(_open_settings)
	_pause_menu.traveler_book_requested.connect(_open_traveler_book)
	_pause_menu.quit_requested.connect(_save_and_quit)
	add_child(_pause_menu)


@override
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not get_tree().paused and not is_instance_valid(workshop) and not is_instance_valid(region_map):
		get_viewport().set_input_as_handled()
		player.input_enabled = false
		_pause_menu.open()
		get_tree().paused = true


func open_workshop() -> WorkshopMenu:
	if is_instance_valid(workshop):
		return workshop
	workshop = WorkshopMenu.new()
	workshop.configure(world_state)
	workshop.closed.connect(_on_workshop_closed)
	player.input_enabled = false
	add_child(workshop)
	return workshop


func open_region_map() -> RegionMap:
	if is_instance_valid(region_map):
		return region_map
	region_map = RegionMap.new()
	region_map.configure(world_state)
	region_map.closed.connect(_on_region_map_closed)
	player.input_enabled = false
	add_child(region_map)
	return region_map


@private
func _resume() -> void:
	get_tree().paused = false
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


@private
func _open_settings() -> void:
	if is_instance_valid(_settings_panel):
		return
	_settings_panel = SettingsPanel.new()
	_settings_panel.configure(settings, camera_rig)
	_settings_panel.closed.connect(func() -> void: _settings_panel = null)
	add_child(_settings_panel)


@private
func _open_traveler_book() -> void:
	get_tree().paused = false
	persistence.save_checkpoint()
	traveler_book_requested.emit()


@private
func _save_and_quit() -> void:
	get_tree().paused = false
	persistence.save_checkpoint()
	get_tree().quit()


@private
func _on_workshop_closed() -> void:
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	workshop = null
	persistence.save_checkpoint()


@private
func _on_region_map_closed() -> void:
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	region_map = null
	persistence.save_checkpoint()
