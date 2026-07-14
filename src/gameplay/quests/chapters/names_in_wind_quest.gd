class_name NamesInWindQuest
extends Node

var world_state: GameWorldState
var player: WayfarerController
var hud: GameHud
var world: GameWorld

var missing_people: Dictionary[NpcCatalog.Id, NpcActor] = {}
var _prisons: Dictionary[NpcCatalog.Id, Node3D] = {}

const DISPLAY_NAMES: Dictionary[NpcCatalog.Id, String] = {
	NpcCatalog.Id.IVEN: "Iven",
	NpcCatalog.Id.SOLA: "Sola",
	NpcCatalog.Id.ORIN: "Orin",
}
const PRISON_POSITIONS: Dictionary[NpcCatalog.Id, Vector3] = {
	NpcCatalog.Id.IVEN: Vector3(7.0, 1.0, -177.0),
	NpcCatalog.Id.SOLA: Vector3(184.0, 1.0, 25.0),
	NpcCatalog.Id.ORIN: Vector3(-38.0, 1.0, 190.0),
}
const RESCUED_ITEMS: Dictionary[NpcCatalog.Id, ItemCatalog.Id] = {
	NpcCatalog.Id.IVEN: ItemCatalog.Id.RESCUED_IVEN,
	NpcCatalog.Id.SOLA: ItemCatalog.Id.RESCUED_SOLA,
	NpcCatalog.Id.ORIN: ItemCatalog.Id.RESCUED_ORIN,
}


func configure(state_value: GameWorldState, player_value: WayfarerController, hud_value: GameHud, world_value: GameWorld) -> void:
	world_state = state_value
	player = player_value
	hud = hud_value
	world = world_value


@override
func _ready() -> void:
	activate_if_needed()


func activate_if_needed() -> void:
	if world_state.quest_stage < QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS:
		return
	if missing_people.is_empty():
		_spawn_missing_people()
	match world_state.quest_stage:
		QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS:
			_update_rescue_objective()
		QuestCatalog.Stage.RETURN_THREE_NAMES:
			hud.set_objective("Return the three lost names to Nia")
		QuestCatalog.Stage.CRAFT_MEMORY_COMPASS:
			hud.set_objective("Forge Nia's Memory Compass at Bram's bench")
		_:
			hud.set_objective("Carry the Memory Compass to the awakened Waystone")


func handle_interaction(interactable: Node3D) -> void:
	if interactable is NpcActor:
		var npc := interactable as NpcActor
		if world_state.quest_stage == QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS and npc.npc_id in DISPLAY_NAMES:
			_rescue_missing_person(npc)
		elif world_state.quest_stage == QuestCatalog.Stage.RETURN_THREE_NAMES and npc.npc_id == NpcCatalog.Id.NIA:
			_finish_rescue_search()
	elif interactable is WorldInteractable:
		var world_object := interactable as WorldInteractable
		if world_state.quest_stage == QuestCatalog.Stage.CRAFT_MEMORY_COMPASS and world_object.interaction_id == InteractionCatalog.Id.BRAM_WORKBENCH:
			_open_compass_workshop()


@private
func _spawn_missing_people() -> void:
	var village_positions: Dictionary[NpcCatalog.Id, Vector3] = {
		NpcCatalog.Id.IVEN: Vector3(-8.0, 0.0, 3.0),
		NpcCatalog.Id.SOLA: Vector3(6.0, 0.0, 6.0),
		NpcCatalog.Id.ORIN: Vector3(10.0, 0.0, 3.0),
	}
	for npc_id: NpcCatalog.Id in DISPLAY_NAMES:
		var rescued_item: ItemCatalog.Id = RESCUED_ITEMS[npc_id]
		var rescued := Inventory.count(world_state, rescued_item) > 0
		var npc := NpcFactory.create_humanoid(npc_id)
		if not is_instance_valid(npc):
			continue
		npc.bind_world(world_state.world_id)
		npc.position = village_positions[npc_id] if rescued else PRISON_POSITIONS[npc_id]
		world.story_root.add_child(npc)
		missing_people[npc_id] = npc
		if not rescued:
			_build_memory_prison(npc)


@private
func _build_memory_prison(npc: NpcActor) -> void:
	var prison := Node3D.new()
	prison.name = "%sMemoryPrison" % npc.display_name
	prison.position.y = 1.0
	npc.add_child(prison)
	for index: int in range(3):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 0.72 + index * 0.08
		mesh.outer_radius = mesh.inner_radius + 0.045
		mesh.rings = 8
		mesh.ring_segments = 30
		ring.mesh = mesh
		ring.rotation = Vector3(PI * 0.5, index * 0.62, index * 0.4)
		ring.position.y = (index - 1) * 0.55
		ring.material_override = ModelLibrary.material(Color("7652b8"), 0.3, Color("8a5de0"), 1.6)
		prison.add_child(ring)
	var light := OmniLight3D.new()
	light.light_color = Color("8b67d8")
	light.light_energy = 1.6
	light.omni_range = 5.0
	prison.add_child(light)
	_prisons[npc.npc_id] = prison


@private
func _rescue_missing_person(npc: NpcActor) -> void:
	var rescued_item: ItemCatalog.Id = RESCUED_ITEMS[npc.npc_id]
	if Inventory.count(world_state, rescued_item) > 0:
		return
	Inventory.add(world_state, rescued_item)
	Inventory.add(world_state, ItemCatalog.Id.MEMORY_THREAD)
	var prison: Node3D = _prisons.get(npc.npc_id) as Node3D
	if is_instance_valid(prison):
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(prison, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(prison, "rotation:y", TAU, 0.5)
		tween.chain().tween_callback(prison.queue_free)
	npc.greet(player.global_position)
	npc.remember_event(NpcCatalog.Event.RESCUED_FROM_MEMORY)
	world.soundscape.play_memory()
	match npc.npc_id:
		NpcCatalog.Id.IVEN:
			hud.show_dialogue("Iven", "I kept walking north, but every step returned me to the same apology.", 5.0)
		NpcCatalog.Id.SOLA:
			hud.show_dialogue("Sola", "The orrery showed every home I could have chosen. None of them had my daughter.", 5.2)
		NpcCatalog.Id.ORIN:
			hud.show_dialogue("Orin", "The silent bell was loud enough to erase my own name. Thank you for saying it.", 5.2)
	if _rescued_count() >= 3:
		world_state.quest_stage = QuestCatalog.Stage.RETURN_THREE_NAMES
		world_state.active_quest_id = QuestCatalog.Id.THREE_NAMES_RETURNED
		hud.set_objective("Return the three lost names to Nia")
	else:
		_update_rescue_objective()
	world.persistence.save_checkpoint()


@private
func _finish_rescue_search() -> void:
	var nia := world.village.npcs.get(NpcCatalog.Id.NIA) as NpcActor
	if is_instance_valid(nia):
		nia.remember_event(NpcCatalog.Event.RESCUED_FROM_MEMORY)
	world_state.quest_stage = QuestCatalog.Stage.CRAFT_MEMORY_COMPASS
	world_state.active_quest_id = QuestCatalog.Id.FORGE_THE_MEMORY_COMPASS
	Inventory.unlock_recipe(world_state, RecipeCatalog.Id.MEMORY_COMPASS)
	world_state.completed_quest_ids.append(QuestCatalog.Id.NAMES_IN_THE_WIND)
	world_state.gold_coins += 36
	hud.show_dialogue("Nia", "Three people came home carrying three threads of the same impossible road. My compass can braid them.", 5.8)
	hud.set_objective("Forge Nia's Memory Compass at Bram's bench")
	world.persistence.save_checkpoint()


@private
func _open_compass_workshop() -> void:
	var workshop := world.overlays.open_workshop()
	if not workshop.crafted_memory_compass.is_connected(_on_memory_compass_crafted):
		workshop.crafted_memory_compass.connect(_on_memory_compass_crafted)


@private
func _on_memory_compass_crafted() -> void:
	for npc_id: NpcCatalog.Id in [NpcCatalog.Id.NIA, NpcCatalog.Id.BRAM] as Array[NpcCatalog.Id]:
		var witness := world.village.npcs.get(npc_id) as NpcActor
		if is_instance_valid(witness):
			witness.remember_event(NpcCatalog.Event.MEMORY_COMPASS_FORGED)
	world_state.quest_stage = QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE
	world_state.active_quest_id = QuestCatalog.Id.COMPASS_TO_THE_WAYSTONE
	hud.show_dialogue("Nia", "It points toward what the world was forced to forget. Keep both hands on it.", 5.0)
	hud.set_objective("Carry the Memory Compass to the awakened Waystone")
	world.soundscape.play_craft()
	world.persistence.save_checkpoint()
	world.quests.activate_three_voices()


@private
func _rescued_count() -> int:
	var count := 0
	for item_id: ItemCatalog.Id in RESCUED_ITEMS.values():
		if Inventory.count(world_state, item_id) > 0:
			count += 1
	return count


@private
func _update_rescue_objective() -> void:
	hud.set_objective("Find the missing villagers  •  %d / 3 names returned" % _rescued_count())
