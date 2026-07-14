class_name QuestNavigationController
extends Node

var world_state: LumenfallWorldState
var player: WayfarerController
var camera_rig: ThirdPersonCamera
var hud: GameHud
var village: HearthmereVillage
var landmarks: RegionLandmarks
var quests: QuestCoordinator
var travel: WorldTravelController


func configure(state: LumenfallWorldState, player_controller: WayfarerController, camera_controller: ThirdPersonCamera, game_hud: GameHud, hearthmere: HearthmereVillage, region_landmarks: RegionLandmarks, quest_coordinator: QuestCoordinator, travel_controller: WorldTravelController) -> void:
	world_state = state
	player = player_controller
	camera_rig = camera_controller
	hud = game_hud
	village = hearthmere
	landmarks = region_landmarks
	quests = quest_coordinator
	travel = travel_controller


@override
func _process(_delta: float) -> void:
	var target := _target()
	if not is_instance_valid(target):
		hud.set_navigation("", "", 0.0)
		return
	var offset := target.global_position - player.global_position
	offset.y = 0.0
	var distance := offset.length()
	var label := QuestCatalog.navigation_label(world_state.quest_stage, world_state.active_quest_id)
	if distance < 0.01:
		hud.set_navigation("◆", label, 0.0)
		return
	var camera := camera_rig.get_player_camera()
	var forward := -camera.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := camera.global_basis.x
	right.y = 0.0
	right = right.normalized()
	var direction := offset / distance
	var angle := atan2(right.dot(direction), forward.dot(direction))
	hud.set_navigation(_direction_glyph(angle), label, distance)


@private
func _target() -> Node3D:
	match QuestCatalog.navigation_kind(world_state.quest_stage):
		QuestCatalog.NavigationKind.NPC:
			return village.npcs.get(QuestCatalog.navigation_npc(world_state.quest_stage)) as Node3D
		QuestCatalog.NavigationKind.INTERACTION:
			return _interaction_target(QuestCatalog.navigation_interaction(world_state.quest_stage))
		QuestCatalog.NavigationKind.ACTIVE_RIFTGLASS:
			return _nearest_riftglass()
		QuestCatalog.NavigationKind.MISSING_VILLAGER:
			return _nearest_missing_villager()
		QuestCatalog.NavigationKind.SLEEPING_VOICE:
			return _nearest_sleeping_voice()
		QuestCatalog.NavigationKind.REGIONAL_INSTRUMENT:
			return landmarks.landmarks.get(QuestCatalog.regional_interaction(world_state.active_quest_id)) as Node3D
	return null


@private
func _interaction_target(interaction_id: InteractionCatalog.Id) -> Node3D:
	match interaction_id:
		InteractionCatalog.Id.WAYSTONE:
			return village.waystone_interactable
		InteractionCatalog.Id.BRAM_WORKBENCH:
			return village.workshop_interactable
		InteractionCatalog.Id.EASTERN_CROSSING:
			return village.eastern_crossing
		InteractionCatalog.Id.FIELD_MAP:
			return village.field_map
		InteractionCatalog.Id.HOUND_MEMORY:
			return quests.first_crossing.first_hunt.memory
		InteractionCatalog.Id.THREE_VOICES_GATE:
			return travel.echo_causeway.crossing_gate if is_instance_valid(travel.echo_causeway) else null
		InteractionCatalog.Id.CROSSING_AFTERMATH:
			return village.crossing_aftermath
		InteractionCatalog.Id.GLASS_ROAD_BEACON:
			return landmarks.landmarks.get(InteractionCatalog.Id.GLASS_ROAD_BEACON) as Node3D
	return null


@private
func _nearest_riftglass() -> Node3D:
	var candidates: Array[Node3D] = []
	for shard: RiftglassShard in quests.first_crossing.riftglass.spawned_shards:
		candidates.append(shard)
	return _nearest(candidates)


@private
func _nearest_missing_villager() -> Node3D:
	var candidates: Array[Node3D] = []
	for npc: NpcActor in quests.names_in_wind.missing_people.values():
		candidates.append(npc)
	return _nearest(candidates)


@private
func _nearest_sleeping_voice() -> Node3D:
	if not is_instance_valid(travel.echo_causeway):
		return null
	var candidates: Array[Node3D] = []
	for altar: WorldInteractable in travel.echo_causeway.altars.values():
		candidates.append(altar)
	return _nearest(candidates)


@private
func _nearest(candidates: Array[Node3D]) -> Node3D:
	var closest: Node3D
	var closest_distance := INF
	for candidate: Node3D in candidates:
		if not is_instance_valid(candidate) or not candidate.is_in_group(&"interactables"):
			continue
		var distance := player.global_position.distance_squared_to(candidate.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = candidate
	return closest


@private
func _direction_glyph(angle: float) -> String:
	if absf(angle) > 2.45:
		return "↓"
	if angle > 0.38:
		return "→"
	if angle < -0.38:
		return "←"
	return "↑"
