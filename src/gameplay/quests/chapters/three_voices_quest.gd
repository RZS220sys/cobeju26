class_name ThreeVoicesQuest
extends Node

var world_state: LumenfallWorldState
var player: WayfarerController
var hud: GameHud
var world: LumenfallWorld
var _choice_ui: CrossingChoice

const VOICE_ITEMS: Dictionary[InteractionCatalog.Id, ItemCatalog.Id] = {
	InteractionCatalog.Id.IVEN_VOICE: ItemCatalog.Id.CAUSEWAY_IVEN_VOICE,
	InteractionCatalog.Id.SOLA_VOICE: ItemCatalog.Id.CAUSEWAY_SOLA_VOICE,
	InteractionCatalog.Id.ORIN_VOICE: ItemCatalog.Id.CAUSEWAY_ORIN_VOICE,
}


func configure(state_value: LumenfallWorldState, player_value: WayfarerController, hud_value: GameHud, world_value: LumenfallWorld) -> void:
	world_state = state_value
	player = player_value
	hud = hud_value
	world = world_value


@override
func _ready() -> void:
	activate_if_needed()


func activate_if_needed() -> void:
	if world_state.quest_stage < QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE:
		return
	match world_state.quest_stage:
		QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE:
			hud.set_objective("Carry the Memory Compass to the awakened Waystone")
		QuestCatalog.Stage.AWAKEN_CAUSEWAY_VOICES, QuestCatalog.Stage.ANSWER_CAUSEWAY_GATE:
			world.travel.enter_echo_causeway()
			_restore_altars()
			_update_causeway_objective()
		QuestCatalog.Stage.REPORT_CROSSING_ANSWER:
			hud.set_objective("Tell Nia what the forgotten road asked")
		_:
			hud.set_objective("See how Hearthmere changed after your answer")


func handle_interaction(interactable: Node3D) -> void:
	if interactable is WorldInteractable:
		var world_object := interactable as WorldInteractable
		if world_state.quest_stage == QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE and world_object.interaction_id == InteractionCatalog.Id.WAYSTONE:
			_begin_causeway()
		elif world_state.quest_stage == QuestCatalog.Stage.AWAKEN_CAUSEWAY_VOICES and world_object.interaction_id in VOICE_ITEMS:
			_awaken_voice(world_object.interaction_id)
		elif world_state.quest_stage == QuestCatalog.Stage.ANSWER_CAUSEWAY_GATE and world_object.interaction_id == InteractionCatalog.Id.THREE_VOICES_GATE:
			_open_crossing_choice()
		elif world_state.quest_stage == QuestCatalog.Stage.EXAMINE_CROSSING_AFTERMATH and world_object.interaction_id == InteractionCatalog.Id.CROSSING_AFTERMATH:
			_examine_aftermath()
	elif interactable is NpcActor:
		var npc := interactable as NpcActor
		if world_state.quest_stage == QuestCatalog.Stage.REPORT_CROSSING_ANSWER and npc.npc_id == NpcCatalog.Id.NIA:
			_complete_crossing()


@private
func _begin_causeway() -> void:
	world_state.quest_stage = QuestCatalog.Stage.AWAKEN_CAUSEWAY_VOICES
	world_state.active_quest_id = QuestCatalog.Id.CROSSING_OF_THREE_VOICES
	world.travel.enter_echo_causeway()
	_restore_altars()
	_update_causeway_objective()
	hud.show_dialogue("Memory Compass", "Three names pull the needle toward a road that exists only when remembered together.", 5.5)
	world.soundscape.play_memory()
	world.persistence.save_checkpoint()


@private
func _awaken_voice(altar_id: InteractionCatalog.Id) -> void:
	var item_id: ItemCatalog.Id = VOICE_ITEMS[altar_id]
	if Inventory.count(world_state, item_id) > 0:
		return
	Inventory.add(world_state, item_id)
	world.travel.echo_causeway.awaken_altar(altar_id)
	world.soundscape.play_memory()
	match altar_id:
		InteractionCatalog.Id.IVEN_VOICE:
			hud.show_dialogue("Iven's Thread", "A road is also every apology made while walking home.", 4.5)
		InteractionCatalog.Id.SOLA_VOICE:
			hud.show_dialogue("Sola's Thread", "A home chosen freely is not a betrayal of the homes refused.", 4.8)
		InteractionCatalog.Id.ORIN_VOICE:
			hud.show_dialogue("Orin's Thread", "A name survives when another person answers it.", 4.5)
	if _voice_count() >= 3:
		world_state.quest_stage = QuestCatalog.Stage.ANSWER_CAUSEWAY_GATE
		world_state.active_quest_id = QuestCatalog.Id.THE_ROAD_ASKS
		hud.set_objective("Answer the gate at the center of the causeway")
	else:
		_update_causeway_objective()
	world.persistence.save_checkpoint()


@private
func _open_crossing_choice() -> void:
	if is_instance_valid(_choice_ui):
		return
	_choice_ui = CrossingChoice.new()
	_choice_ui.choice_made.connect(_on_crossing_choice)
	player.input_enabled = false
	world.story_root.add_child(_choice_ui)


@private
func _on_crossing_choice(choice_id: CrossingChoiceCatalog.Id) -> void:
	Inventory.add(world_state, CrossingChoiceCatalog.evidence_item(choice_id))
	world_state.quest_stage = QuestCatalog.Stage.REPORT_CROSSING_ANSWER
	world_state.active_quest_id = QuestCatalog.Id.ANSWER_CARRIED_HOME
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	world.travel.return_to_hearthmere()
	world.village.apply_crossing_choice(world_state)
	match choice_id:
		CrossingChoiceCatalog.Id.SHELTER:
			hud.show_dialogue("Nia", "The road folded like a blanket. Safe—for now—but something on the other side noticed.", 5.5)
		CrossingChoiceCatalog.Id.BRIDGE:
			hud.show_dialogue("Nia", "The road accepted three living anchors. We owe Iven, Sola, and Orin more than thanks.", 5.5)
		CrossingChoiceCatalog.Id.WITNESS:
			hud.show_dialogue("Nia", "You crossed without claiming it. For one heartbeat, I saw the person who erased our road.", 5.5)
	hud.set_objective("Tell Nia what the forgotten road asked")
	world.soundscape.play_memory()
	world.persistence.save_checkpoint()


@private
func _complete_crossing() -> void:
	var nia := world.village.npcs.get(NpcCatalog.Id.NIA) as NpcActor
	if is_instance_valid(nia):
		nia.remember_event(NpcCatalog.Event.CAUSEWAY_ANSWERED)
	world_state.quest_stage = QuestCatalog.Stage.EXAMINE_CROSSING_AFTERMATH
	world_state.active_quest_id = QuestCatalog.Id.HEARTHMERE_AFTER_THE_ANSWER
	world_state.completed_quest_ids.append(QuestCatalog.Id.CROSSING_OF_THREE_VOICES)
	world_state.gold_coins += 75
	hud.show_dialogue("Nia", "Whatever we do next, we do it knowing the rifts were made—not born.", 5.2)
	hud.set_objective("See how Hearthmere changed after your answer")
	world.persistence.save_checkpoint()


@private
func _examine_aftermath() -> void:
	world_state.quest_stage = QuestCatalog.Stage.FOLLOW_GLASS_ROAD
	world_state.active_quest_id = QuestCatalog.Id.THE_GLASS_ROAD
	if Inventory.count(world_state, ItemCatalog.Id.CROSSING_CHOICE_SHELTER) > 0:
		hud.show_dialogue("Mara", "The shelter-ring holds, but every crystal points west. Something is testing its edge.", 5.2)
	elif Inventory.count(world_state, ItemCatalog.Id.CROSSING_CHOICE_BRIDGE) > 0:
		hud.show_dialogue("Orin", "I can feel the bridge breathing through my name. We'll set rules before it learns bad habits.", 5.2)
	else:
		hud.show_dialogue("Forgotten Architect", "You witnessed me once. Find the glass road before they erase me twice.", 5.2)
	hud.set_objective("Follow the new light west of Hearthmere")
	world_state.completed_quest_ids.append(QuestCatalog.Id.HEARTHMERE_AFTER_THE_ANSWER)
	world.persistence.save_checkpoint()


@private
func _restore_altars() -> void:
	if not is_instance_valid(world.travel.echo_causeway):
		return
	for altar_id: InteractionCatalog.Id in VOICE_ITEMS:
		if Inventory.count(world_state, VOICE_ITEMS[altar_id]) > 0:
			world.travel.echo_causeway.awaken_altar(altar_id)


@private
func _voice_count() -> int:
	var count := 0
	for item_id: ItemCatalog.Id in VOICE_ITEMS.values():
		if Inventory.count(world_state, item_id) > 0:
			count += 1
	return count


@private
func _update_causeway_objective() -> void:
	hud.set_objective("Awaken the three rescued voices  •  %d / 3" % _voice_count())
