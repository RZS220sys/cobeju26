class_name FirstHuntObjective
extends Node

var hound: RiftHoundNpc
var memory: RiftglassShard
var world_state: LumenfallWorldState
var player: WayfarerController
var hud: GameHud
var world: LumenfallWorld


func configure(state: LumenfallWorldState, player_controller: WayfarerController, game_hud: GameHud, world_root: LumenfallWorld) -> void:
	world_state = state
	player = player_controller
	hud = game_hud
	world = world_root


func begin(restored: bool) -> void:
	if is_instance_valid(hound):
		return
	world.village.eastern_crossing.remove_from_group(&"interactables")
	var mara := world.village.npcs.get(NpcCatalog.Id.MARA) as NpcActor
	if is_instance_valid(mara):
		mara.global_position = Vector3(34.5, 0.0, 3.8)
		mara.rotation.y = -1.2
	hound = RiftHoundNpc.new()
	hound.bind_world(world_state.world_id)
	hound.configure_target(player)
	hound.position = Vector3(41.0, 1.0, 1.5)
	hound.defeated.connect(_on_hound_defeated)
	world.story_root.add_child(hound)
	hud.set_objective("Defend the lantern road  •  Left click to strike")
	if not restored:
		hud.show_dialogue("Mara", "Wait. That hound is terrified—hold the road, but watch its rift-scar.", 5.0)


func restore_memory() -> void:
	hud.set_objective("Use the Lantern Lens on the hound's rift-scar")
	world.village.eastern_crossing.remove_from_group(&"interactables")
	var mara := world.village.npcs.get(NpcCatalog.Id.MARA) as NpcActor
	if is_instance_valid(mara):
		mara.global_position = Vector3(34.5, 0.0, 3.8)
	_spawn_memory(Vector3(40.0, 0.25, 1.5))


func listen(interactable: WorldInteractable) -> void:
	interactable.remove_from_group(&"interactables")
	interactable.queue_free()
	Inventory.add(world_state, ItemCatalog.Id.ASTER_MEMORY)
	world.soundscape.play_memory()
	world_state.quest_stage = QuestCatalog.Stage.REPORT_ASTER
	world_state.active_quest_id = QuestCatalog.Id.THE_NAME_ASTER
	hud.show_dialogue("Aster's Memory", "Small hands. A red ribbon. Someone promising: I will come back before the bells.", 6.0)
	hud.set_objective("Tell Nia what the hound remembered")
	world.persistence.save_checkpoint()


func rescue_player() -> void:
	if world_state.quest_stage != QuestCatalog.Stage.DEFEND_LANTERN_ROAD:
		return
	world_state.quest_stage = QuestCatalog.Stage.REACH_EASTERN_CROSSING
	world_state.active_quest_id = QuestCatalog.Id.BEYOND_THE_LANTERNS
	if is_instance_valid(hound):
		hound.queue_free()
		hound = null
	if not world.village.eastern_crossing.is_in_group(&"interactables"):
		world.village.eastern_crossing.add_to_group(&"interactables")
	var mara := world.village.npcs.get(NpcCatalog.Id.MARA) as NpcActor
	if is_instance_valid(mara):
		mara.global_position = Vector3(-5.5, 0.0, 5.0)
	hud.set_objective("Regroup with Mara beyond the eastern lanterns")


@private
func _on_hound_defeated(defeated_hound: RiftHoundNpc) -> void:
	if world_state.quest_stage != QuestCatalog.Stage.DEFEND_LANTERN_ROAD:
		return
	world_state.quest_stage = QuestCatalog.Stage.LISTEN_TO_ASTER
	world_state.active_quest_id = QuestCatalog.Id.A_NAME_INSIDE_THE_NOISE
	hud.show_dialogue("Mara", "It wasn't hunting us. It was running from something that knew its name.", 5.2)
	hud.set_objective("Use the Lantern Lens on the hound's rift-scar")
	_spawn_memory(defeated_hound.global_position + Vector3.UP * 0.25)
	world.soundscape.play_memory()
	world.persistence.save_checkpoint()


@private
func _spawn_memory(at: Vector3) -> void:
	if is_instance_valid(memory):
		return
	memory = RiftglassShard.new()
	memory.name = "AsterMemory"
	memory.configure(InteractionCatalog.Id.HOUND_MEMORY, "Listen through the Lantern Lens")
	memory.position = at
	memory.scale = Vector3.ONE * 0.78
	world.story_root.add_child(memory)
