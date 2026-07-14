class_name LumenfallAdventureWorld
extends Node3D

signal traveler_book_requested

var player: WayfarerController
var camera_rig: ThirdPersonAdventureCamera
var profile: LumenfallSaveData
var _autosave_elapsed: float = 0.0
var _last_safe_position: Vector3 = Vector3(0.0, 0.1, 9.0)
var _hud: AdventureHud
var _quest: FirstCrossingQuest
var _names_quest: NamesInWindQuest
var _voices_quest: ThreeVoicesQuest
var _focused_interactable: Node3D
var village: HearthmereVillage
var _workshop: AdventureWorkshop
var _pause_menu: AdventurePauseMenu
var streamer: AdventureWorldStreamer
var region_landmarks: AdventureRegionLandmarks
var _region_map: AdventureRegionMap
var soundscape: LumenfallSoundscape
var settings: LumenfallSettings
var _settings_panel: AdventureSettingsPanel
var echo_causeway: AdventureEchoCauseway


func configure(profile_value: LumenfallSaveData) -> void:
	profile = profile_value


@override
func _ready() -> void:
	name = "LumenfallWorld"
	settings = AdventureSettingsStore.load_settings()
	AdventureSettingsStore.apply(settings)
	_build_environment()
	player = WayfarerController.new()
	player.position = Vector3(profile.player_x, profile.player_y, profile.player_z) if is_instance_valid(profile) else Vector3(0.0, 0.1, 9.0)
	player.rotation.y = profile.player_yaw if is_instance_valid(profile) else 0.0
	add_child(player)
	player.configure_health(profile.current_health, profile.maximum_health)
	soundscape = LumenfallSoundscape.new()
	soundscape.configure(player)
	add_child(soundscape)
	streamer = AdventureWorldStreamer.new()
	streamer.configure(player)
	add_child(streamer)
	village = HearthmereVillage.new()
	add_child(village)
	region_landmarks = AdventureRegionLandmarks.new()
	region_landmarks.configure(streamer)
	add_child(region_landmarks)
	camera_rig = ThirdPersonAdventureCamera.new()
	camera_rig.configure(player)
	add_child(camera_rig)
	camera_rig.apply_settings(settings)
	player.set_adventure_camera(camera_rig.get_player_camera())
	player.interaction_requested.connect(_on_interaction_requested)
	player.attack_started.connect(_on_player_attack_started)
	player.attack_started.connect(soundscape.play_sword)
	player.health_changed.connect(_on_player_health_changed)
	player.health_changed.connect(soundscape.on_health_changed)
	player.defeated.connect(_on_player_defeated)
	_last_safe_position = player.global_position
	_hud = AdventureHud.new()
	add_child(_hud)
	_hud.set_health(player.current_health, player.maximum_health)
	_hud.set_lens_owned(AdventureInventory.count(profile, "lantern_lens") > 0)
	_quest = FirstCrossingQuest.new()
	_quest.configure(profile, player, _hud, self)
	add_child(_quest)
	_names_quest = NamesInWindQuest.new()
	_names_quest.configure(profile, player, _hud, self)
	add_child(_names_quest)
	_voices_quest = ThreeVoicesQuest.new()
	_voices_quest.configure(profile, player, _hud, self)
	add_child(_voices_quest)
	_pause_menu = AdventurePauseMenu.new()
	_pause_menu.resume_requested.connect(_resume_from_pause)
	_pause_menu.settings_requested.connect(_open_settings)
	_pause_menu.traveler_book_requested.connect(_return_to_traveler_book)
	_pause_menu.quit_requested.connect(_save_and_quit)
	add_child(_pause_menu)


@override
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not get_tree().paused and not is_instance_valid(_workshop):
		get_viewport().set_input_as_handled()
		_open_pause()


@override
func _process(delta: float) -> void:
	if not is_instance_valid(profile) or not is_instance_valid(player):
		return
	profile.played_seconds += delta
	_autosave_elapsed += delta
	if player.is_on_floor() and player.global_position.y > -5.0:
		_last_safe_position = player.global_position
	if player.global_position.y < -35.0:
		player.global_position = _last_safe_position + Vector3.UP * 0.8
		player.velocity = Vector3.ZERO
	if _autosave_elapsed >= 20.0:
		_autosave_elapsed = 0.0
		save_checkpoint()
	_update_interaction_focus()


@override
func _exit_tree() -> void:
	if is_instance_valid(profile) and is_instance_valid(player) and player.is_inside_tree():
		save_checkpoint()


func save_checkpoint() -> bool:
	profile.player_x = player.global_position.x
	profile.player_y = maxf(-5.0, player.global_position.y)
	profile.player_z = player.global_position.z
	profile.player_yaw = player.rotation.y
	profile.current_health = player.current_health
	profile.maximum_health = player.maximum_health
	return AdventureProfileStore.save_profile(profile)


func open_workshop() -> AdventureWorkshop:
	if is_instance_valid(_workshop):
		return _workshop
	_workshop = AdventureWorkshop.new()
	_workshop.configure(profile)
	_workshop.closed.connect(_on_workshop_closed)
	player.input_enabled = false
	add_child(_workshop)
	return _workshop


func open_region_map() -> AdventureRegionMap:
	if is_instance_valid(_region_map):
		return _region_map
	_region_map = AdventureRegionMap.new()
	_region_map.configure(profile)
	_region_map.closed.connect(_on_region_map_closed)
	player.input_enabled = false
	add_child(_region_map)
	return _region_map


@private
func _on_region_map_closed() -> void:
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_region_map = null
	save_checkpoint()


@private
func _on_player_attack_started() -> void:
	var nearest: AdventureRiftHound
	var nearest_distance := 3.0
	var forward := -player.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	for candidate: Node in get_tree().get_nodes_in_group(&"adventure_enemies"):
		if candidate is AdventureRiftHound:
			var hound := candidate as AdventureRiftHound
			var offset := hound.global_position - player.global_position
			offset.y = 0.0
			var distance := offset.length()
			if distance < nearest_distance and distance > 0.01 and forward.dot(offset / distance) > 0.05:
				nearest = hound
				nearest_distance = distance
	if is_instance_valid(nearest):
		nearest.take_damage(28.0)


@private
func _on_player_health_changed(current: float, maximum: float) -> void:
	profile.current_health = current
	profile.maximum_health = maximum
	if is_instance_valid(_hud):
		_hud.set_health(current, maximum)


@private
func _on_player_defeated() -> void:
	_hud.show_dialogue("Mara", "Breathe. The village lanterns still know your name.", 4.5)
	if is_instance_valid(_quest):
		_quest.on_player_rescued()
	player.global_position = Vector3(0.0, 0.6, -10.5)
	player.velocity = Vector3.ZERO
	player.restore_full_health()
	save_checkpoint()


func refresh_inventory_hud() -> void:
	_hud.set_lens_owned(AdventureInventory.count(profile, "lantern_lens") > 0)


func activate_three_voices() -> void:
	_voices_quest.activate_if_needed()


func enter_echo_causeway() -> void:
	if not is_instance_valid(echo_causeway):
		echo_causeway = AdventureEchoCauseway.new()
		add_child(echo_causeway)
	player.global_position = Vector3(420.0, 19.2, -408.0)
	player.velocity = Vector3.ZERO


func return_to_hearthmere() -> void:
	player.global_position = Vector3(0.0, 0.7, -10.5)
	player.velocity = Vector3.ZERO


@private
func _open_pause() -> void:
	player.input_enabled = false
	_pause_menu.open()
	get_tree().paused = true


@private
func _resume_from_pause() -> void:
	get_tree().paused = false
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


@private
func _open_settings() -> void:
	if is_instance_valid(_settings_panel):
		return
	_settings_panel = AdventureSettingsPanel.new()
	_settings_panel.configure(settings, camera_rig)
	_settings_panel.closed.connect(func() -> void: _settings_panel = null)
	add_child(_settings_panel)


@private
func _return_to_traveler_book() -> void:
	get_tree().paused = false
	save_checkpoint()
	traveler_book_requested.emit()


@private
func _save_and_quit() -> void:
	get_tree().paused = false
	save_checkpoint()
	get_tree().quit()


@private
func _on_workshop_closed() -> void:
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_workshop = null
	save_checkpoint()


@private
func _update_interaction_focus() -> void:
	var nearest: Node3D
	var nearest_distance := 3.25
	for candidate: Node in get_tree().get_nodes_in_group(&"adventure_interactables"):
		if candidate is Node3D:
			var candidate_3d := candidate as Node3D
			var distance := player.global_position.distance_to(candidate_3d.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = candidate_3d
	if nearest != _focused_interactable:
		if is_instance_valid(_focused_interactable):
			_set_interactable_focus(_focused_interactable, false)
		_focused_interactable = nearest
		if is_instance_valid(_focused_interactable):
			_set_interactable_focus(_focused_interactable, true)
	if is_instance_valid(_focused_interactable):
		_hud.set_interaction(_interaction_prompt(_focused_interactable))
	else:
		_hud.set_interaction("")


@private
func _on_interaction_requested() -> void:
	if is_instance_valid(_focused_interactable):
		soundscape.play_interaction()
		if profile.quest_stage >= 18:
			_voices_quest.handle_interaction(_focused_interactable)
		elif profile.quest_stage >= 15:
			_names_quest.handle_interaction(_focused_interactable)
		else:
			_quest.handle_interaction(_focused_interactable)
			if profile.quest_stage >= 15:
				_names_quest.activate_if_needed()


@private
func _set_interactable_focus(interactable: Node3D, focused: bool) -> void:
	if interactable is AdventureNpc:
		(interactable as AdventureNpc).set_interaction_focus(focused)
	elif interactable is AdventureWorldInteractable:
		(interactable as AdventureWorldInteractable).set_interaction_focus(focused)


@private
func _interaction_prompt(interactable: Node3D) -> String:
	if interactable is AdventureNpc:
		return (interactable as AdventureNpc).get_interaction_prompt()
	if interactable is AdventureWorldInteractable:
		return (interactable as AdventureWorldInteractable).get_interaction_prompt()
	return ""


@private
func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("295a83")
	sky_material.sky_horizon_color = Color("d0a36f")
	sky_material.ground_bottom_color = Color("172820")
	sky_material.ground_horizon_color = Color("665c42")
	sky_material.sun_angle_max = 12.0
	sky_material.sun_curve = 0.08
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("b4b5a1")
	environment.fog_density = 0.0025
	environment.fog_sky_affect = 0.3
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-53.0, -34.0, 0.0)
	sun.light_color = Color("ffd1a0")
	sun.light_energy = 0.82
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90.0
	add_child(sun)
