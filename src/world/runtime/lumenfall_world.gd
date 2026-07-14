class_name LumenfallWorld
extends Node3D

signal traveler_book_requested

var world_state: LumenfallWorldState
var player: WayfarerController
var camera_rig: ThirdPersonCamera
var hud: GameHud
var soundscape: LumenfallSoundscape
var settings: LumenfallSettings
var streamer: WorldStreamer
var village: HearthmereVillage
var region_landmarks: RegionLandmarks
var story_root: Node3D

var persistence: WorldPersistenceController
var travel: WorldTravelController
var overlays: OverlayCoordinator
var quests: QuestCoordinator
var player_coordinator: PlayerCoordinator
var interaction_controller: InteractionController
var navigation_controller: QuestNavigationController


func configure(state: LumenfallWorldState) -> void:
	world_state = state


@override
func _ready() -> void:
	name = "LumenfallWorld"
	settings = SettingsRepository.load_settings()
	SettingsRepository.apply(settings)
	EnvironmentBuilder.build(self)
	_build_world_content()
	_build_runtime_services()


@private
func _build_world_content() -> void:
	story_root = Node3D.new()
	story_root.name = "StoryRuntime"
	add_child(story_root)
	player = WayfarerController.new()
	player.position = Vector3(world_state.player_x, world_state.player_y, world_state.player_z)
	player.rotation.y = world_state.player_yaw
	add_child(player)
	player.configure_health(world_state.current_health, world_state.maximum_health)
	soundscape = LumenfallSoundscape.new()
	soundscape.configure(player)
	add_child(soundscape)
	streamer = WorldStreamer.new()
	streamer.configure(player)
	add_child(streamer)
	village = HearthmereVillage.new()
	village.configure(world_state.world_id)
	add_child(village)
	village.apply_crossing_choice(world_state)
	region_landmarks = RegionLandmarks.new()
	region_landmarks.configure(streamer)
	add_child(region_landmarks)
	camera_rig = ThirdPersonCamera.new()
	camera_rig.configure(player)
	add_child(camera_rig)
	camera_rig.apply_settings(settings)
	hud = GameHud.new()
	add_child(hud)


@private
func _build_runtime_services() -> void:
	persistence = WorldPersistenceController.new()
	persistence.configure(world_state, player)
	add_child(persistence)
	travel = WorldTravelController.new()
	travel.configure(self, player)
	add_child(travel)
	overlays = OverlayCoordinator.new()
	overlays.configure(world_state, player, camera_rig, settings, persistence)
	overlays.traveler_book_requested.connect(traveler_book_requested.emit)
	add_child(overlays)
	quests = QuestCoordinator.new()
	quests.configure(world_state, player, hud, self)
	add_child(quests)
	player_coordinator = PlayerCoordinator.new()
	player_coordinator.configure(player, camera_rig, world_state, hud, soundscape, quests, persistence)
	add_child(player_coordinator)
	interaction_controller = InteractionController.new()
	interaction_controller.configure(player, hud, soundscape)
	interaction_controller.target_activated.connect(quests.handle_interaction)
	add_child(interaction_controller)
	navigation_controller = QuestNavigationController.new()
	navigation_controller.configure(world_state, player, camera_rig, hud, village, region_landmarks, quests, travel)
	add_child(navigation_controller)
