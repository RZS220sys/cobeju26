class_name NamesInWindQuest
extends Node

var profile: LumenfallSaveData
var player: WayfarerController
var hud: AdventureHud
var world: LumenfallAdventureWorld

var missing_people: Dictionary[LumenfallTypes.NpcId, AdventureNpc] = {}
var _prisons: Dictionary[LumenfallTypes.NpcId, Node3D] = {}

const DISPLAY_NAMES: Dictionary[LumenfallTypes.NpcId, String] = {
	LumenfallTypes.NpcId.IVEN: "Iven",
	LumenfallTypes.NpcId.SOLA: "Sola",
	LumenfallTypes.NpcId.ORIN: "Orin",
}
const PRISON_POSITIONS: Dictionary[LumenfallTypes.NpcId, Vector3] = {
	LumenfallTypes.NpcId.IVEN: Vector3(7.0, 1.0, -177.0),
	LumenfallTypes.NpcId.SOLA: Vector3(184.0, 1.0, 25.0),
	LumenfallTypes.NpcId.ORIN: Vector3(-38.0, 1.0, 190.0),
}
const RESCUED_ITEMS: Dictionary[LumenfallTypes.NpcId, LumenfallTypes.ItemId] = {
	LumenfallTypes.NpcId.IVEN: LumenfallTypes.ItemId.RESCUED_IVEN,
	LumenfallTypes.NpcId.SOLA: LumenfallTypes.ItemId.RESCUED_SOLA,
	LumenfallTypes.NpcId.ORIN: LumenfallTypes.ItemId.RESCUED_ORIN,
}


func configure(profile_value: LumenfallSaveData, player_value: WayfarerController, hud_value: AdventureHud, world_value: LumenfallAdventureWorld) -> void:
	profile = profile_value
	player = player_value
	hud = hud_value
	world = world_value


@override
func _ready() -> void:
	activate_if_needed()


func activate_if_needed() -> void:
	if profile.quest_stage < LumenfallTypes.QuestStage.RESCUE_MISSING_VILLAGERS:
		return
	if missing_people.is_empty():
		_spawn_missing_people()
	match profile.quest_stage:
		LumenfallTypes.QuestStage.RESCUE_MISSING_VILLAGERS:
			_update_rescue_objective()
		LumenfallTypes.QuestStage.RETURN_THREE_NAMES:
			hud.set_objective("Return the three lost names to Nia")
		LumenfallTypes.QuestStage.CRAFT_MEMORY_COMPASS:
			hud.set_objective("Forge Nia's Memory Compass at Bram's bench")
		_:
			hud.set_objective("Carry the Memory Compass to the awakened Waystone")


func handle_interaction(interactable: Node3D) -> void:
	if interactable is AdventureNpc:
		var npc := interactable as AdventureNpc
		if profile.quest_stage == LumenfallTypes.QuestStage.RESCUE_MISSING_VILLAGERS and npc.npc_id in DISPLAY_NAMES:
			_rescue_missing_person(npc)
		elif profile.quest_stage == LumenfallTypes.QuestStage.RETURN_THREE_NAMES and npc.npc_id == LumenfallTypes.NpcId.NIA:
			_finish_rescue_search()
	elif interactable is AdventureWorldInteractable:
		var world_object := interactable as AdventureWorldInteractable
		if profile.quest_stage == LumenfallTypes.QuestStage.CRAFT_MEMORY_COMPASS and world_object.interaction_id == LumenfallTypes.InteractionId.BRAM_WORKBENCH:
			_open_compass_workshop()


@private
func _spawn_missing_people() -> void:
	var village_positions: Dictionary[LumenfallTypes.NpcId, Vector3] = {
		LumenfallTypes.NpcId.IVEN: Vector3(-8.0, 0.0, 3.0),
		LumenfallTypes.NpcId.SOLA: Vector3(6.0, 0.0, 6.0),
		LumenfallTypes.NpcId.ORIN: Vector3(10.0, 0.0, 3.0),
	}
	for npc_id: LumenfallTypes.NpcId in DISPLAY_NAMES:
		var rescued_item: LumenfallTypes.ItemId = RESCUED_ITEMS[npc_id]
		var rescued := AdventureInventory.count(profile, rescued_item) > 0
		var npc := AdventureNpc.new()
		npc.configure(npc_id, DISPLAY_NAMES[npc_id])
		npc.name = DISPLAY_NAMES[npc_id]
		npc.position = village_positions[npc_id] if rescued else PRISON_POSITIONS[npc_id]
		world.add_child(npc)
		missing_people[npc_id] = npc
		if not rescued:
			_build_memory_prison(npc)


@private
func _build_memory_prison(npc: AdventureNpc) -> void:
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
		ring.material_override = AdventureAssetLibrary.material(Color("7652b8"), 0.3, Color("8a5de0"), 1.6)
		prison.add_child(ring)
	var light := OmniLight3D.new()
	light.light_color = Color("8b67d8")
	light.light_energy = 1.6
	light.omni_range = 5.0
	prison.add_child(light)
	_prisons[npc.npc_id] = prison


@private
func _rescue_missing_person(npc: AdventureNpc) -> void:
	var rescued_item: LumenfallTypes.ItemId = RESCUED_ITEMS[npc.npc_id]
	if AdventureInventory.count(profile, rescued_item) > 0:
		return
	AdventureInventory.add(profile, rescued_item)
	AdventureInventory.add(profile, LumenfallTypes.ItemId.MEMORY_THREAD)
	var prison: Node3D = _prisons.get(npc.npc_id) as Node3D
	if is_instance_valid(prison):
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(prison, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(prison, "rotation:y", TAU, 0.5)
		tween.chain().tween_callback(prison.queue_free)
	npc.greet(player.global_position)
	world.soundscape.play_memory()
	match npc.npc_id:
		LumenfallTypes.NpcId.IVEN:
			hud.show_dialogue("Iven", "I kept walking north, but every step returned me to the same apology.", 5.0)
		LumenfallTypes.NpcId.SOLA:
			hud.show_dialogue("Sola", "The orrery showed every home I could have chosen. None of them had my daughter.", 5.2)
		LumenfallTypes.NpcId.ORIN:
			hud.show_dialogue("Orin", "The silent bell was loud enough to erase my own name. Thank you for saying it.", 5.2)
	if _rescued_count() >= 3:
		profile.quest_stage = LumenfallTypes.QuestStage.RETURN_THREE_NAMES
		profile.active_quest_id = LumenfallTypes.QuestId.THREE_NAMES_RETURNED
		hud.set_objective("Return the three lost names to Nia")
	else:
		_update_rescue_objective()
	world.save_checkpoint()


@private
func _finish_rescue_search() -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.CRAFT_MEMORY_COMPASS
	profile.active_quest_id = LumenfallTypes.QuestId.FORGE_THE_MEMORY_COMPASS
	AdventureInventory.unlock_recipe(profile, LumenfallTypes.RecipeId.MEMORY_COMPASS)
	profile.completed_quest_ids.append(LumenfallTypes.QuestId.NAMES_IN_THE_WIND)
	profile.gold_coins += 36
	hud.show_dialogue("Nia", "Three people came home carrying three threads of the same impossible road. My compass can braid them.", 5.8)
	hud.set_objective("Forge Nia's Memory Compass at Bram's bench")
	world.save_checkpoint()


@private
func _open_compass_workshop() -> void:
	var workshop := world.open_workshop()
	if not workshop.crafted_memory_compass.is_connected(_on_memory_compass_crafted):
		workshop.crafted_memory_compass.connect(_on_memory_compass_crafted)


@private
func _on_memory_compass_crafted() -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.BRING_COMPASS_TO_WAYSTONE
	profile.active_quest_id = LumenfallTypes.QuestId.COMPASS_TO_THE_WAYSTONE
	hud.show_dialogue("Nia", "It points toward what the world was forced to forget. Keep both hands on it.", 5.0)
	hud.set_objective("Carry the Memory Compass to the awakened Waystone")
	world.soundscape.play_craft()
	world.save_checkpoint()
	world.activate_three_voices()


@private
func _rescued_count() -> int:
	var count := 0
	for item_id: LumenfallTypes.ItemId in RESCUED_ITEMS.values():
		if AdventureInventory.count(profile, item_id) > 0:
			count += 1
	return count


@private
func _update_rescue_objective() -> void:
	hud.set_objective("Find the missing villagers  •  %d / 3 names returned" % _rescued_count())
