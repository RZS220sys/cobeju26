class_name ThreeVoicesQuest
extends Node

var profile: LumenfallSaveData
var player: WayfarerController
var hud: AdventureHud
var world: LumenfallAdventureWorld
var _choice_ui: CrossingChoice

const VOICE_ITEMS: Dictionary[LumenfallTypes.InteractionId, LumenfallTypes.ItemId] = {
	LumenfallTypes.InteractionId.IVEN_VOICE: LumenfallTypes.ItemId.CAUSEWAY_IVEN_VOICE,
	LumenfallTypes.InteractionId.SOLA_VOICE: LumenfallTypes.ItemId.CAUSEWAY_SOLA_VOICE,
	LumenfallTypes.InteractionId.ORIN_VOICE: LumenfallTypes.ItemId.CAUSEWAY_ORIN_VOICE,
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
	if profile.quest_stage < LumenfallTypes.QuestStage.BRING_COMPASS_TO_WAYSTONE:
		return
	match profile.quest_stage:
		LumenfallTypes.QuestStage.BRING_COMPASS_TO_WAYSTONE:
			hud.set_objective("Carry the Memory Compass to the awakened Waystone")
		LumenfallTypes.QuestStage.AWAKEN_CAUSEWAY_VOICES, LumenfallTypes.QuestStage.ANSWER_CAUSEWAY_GATE:
			world.enter_echo_causeway()
			_restore_altars()
			_update_causeway_objective()
		LumenfallTypes.QuestStage.REPORT_CROSSING_ANSWER:
			hud.set_objective("Tell Nia what the forgotten road asked")
		_:
			hud.set_objective("See how Hearthmere changed after your answer")


func handle_interaction(interactable: Node3D) -> void:
	if interactable is AdventureWorldInteractable:
		var world_object := interactable as AdventureWorldInteractable
		if profile.quest_stage == LumenfallTypes.QuestStage.BRING_COMPASS_TO_WAYSTONE and world_object.interaction_id == LumenfallTypes.InteractionId.WAYSTONE:
			_begin_causeway()
		elif profile.quest_stage == LumenfallTypes.QuestStage.AWAKEN_CAUSEWAY_VOICES and world_object.interaction_id in VOICE_ITEMS:
			_awaken_voice(world_object.interaction_id)
		elif profile.quest_stage == LumenfallTypes.QuestStage.ANSWER_CAUSEWAY_GATE and world_object.interaction_id == LumenfallTypes.InteractionId.THREE_VOICES_GATE:
			_open_crossing_choice()
		elif profile.quest_stage == LumenfallTypes.QuestStage.EXAMINE_CROSSING_AFTERMATH and world_object.interaction_id == LumenfallTypes.InteractionId.CROSSING_AFTERMATH:
			_examine_aftermath()
	elif interactable is AdventureNpc:
		var npc := interactable as AdventureNpc
		if profile.quest_stage == LumenfallTypes.QuestStage.REPORT_CROSSING_ANSWER and npc.npc_id == LumenfallTypes.NpcId.NIA:
			_complete_crossing()


@private
func _begin_causeway() -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.AWAKEN_CAUSEWAY_VOICES
	profile.active_quest_id = LumenfallTypes.QuestId.CROSSING_OF_THREE_VOICES
	world.enter_echo_causeway()
	_restore_altars()
	_update_causeway_objective()
	hud.show_dialogue("Memory Compass", "Three names pull the needle toward a road that exists only when remembered together.", 5.5)
	world.soundscape.play_memory()
	world.save_checkpoint()


@private
func _awaken_voice(altar_id: LumenfallTypes.InteractionId) -> void:
	var item_id: LumenfallTypes.ItemId = VOICE_ITEMS[altar_id]
	if AdventureInventory.count(profile, item_id) > 0:
		return
	AdventureInventory.add(profile, item_id)
	world.echo_causeway.awaken_altar(altar_id)
	world.soundscape.play_memory()
	match altar_id:
		LumenfallTypes.InteractionId.IVEN_VOICE:
			hud.show_dialogue("Iven's Thread", "A road is also every apology made while walking home.", 4.5)
		LumenfallTypes.InteractionId.SOLA_VOICE:
			hud.show_dialogue("Sola's Thread", "A home chosen freely is not a betrayal of the homes refused.", 4.8)
		LumenfallTypes.InteractionId.ORIN_VOICE:
			hud.show_dialogue("Orin's Thread", "A name survives when another person answers it.", 4.5)
	if _voice_count() >= 3:
		profile.quest_stage = LumenfallTypes.QuestStage.ANSWER_CAUSEWAY_GATE
		profile.active_quest_id = LumenfallTypes.QuestId.THE_ROAD_ASKS
		hud.set_objective("Answer the gate at the center of the causeway")
	else:
		_update_causeway_objective()
	world.save_checkpoint()


@private
func _open_crossing_choice() -> void:
	if is_instance_valid(_choice_ui):
		return
	_choice_ui = CrossingChoice.new()
	_choice_ui.choice_made.connect(_on_crossing_choice)
	player.input_enabled = false
	world.add_child(_choice_ui)


@private
func _on_crossing_choice(choice_id: LumenfallTypes.CrossingChoice) -> void:
	AdventureInventory.add(profile, LumenfallTypes.crossing_choice_item(choice_id))
	profile.quest_stage = LumenfallTypes.QuestStage.REPORT_CROSSING_ANSWER
	profile.active_quest_id = LumenfallTypes.QuestId.ANSWER_CARRIED_HOME
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	world.return_to_hearthmere()
	world.village.apply_crossing_choice(profile)
	match choice_id:
		LumenfallTypes.CrossingChoice.SHELTER:
			hud.show_dialogue("Nia", "The road folded like a blanket. Safe—for now—but something on the other side noticed.", 5.5)
		LumenfallTypes.CrossingChoice.BRIDGE:
			hud.show_dialogue("Nia", "The road accepted three living anchors. We owe Iven, Sola, and Orin more than thanks.", 5.5)
		LumenfallTypes.CrossingChoice.WITNESS:
			hud.show_dialogue("Nia", "You crossed without claiming it. For one heartbeat, I saw the person who erased our road.", 5.5)
	hud.set_objective("Tell Nia what the forgotten road asked")
	world.soundscape.play_memory()
	world.save_checkpoint()


@private
func _complete_crossing() -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.EXAMINE_CROSSING_AFTERMATH
	profile.active_quest_id = LumenfallTypes.QuestId.HEARTHMERE_AFTER_THE_ANSWER
	profile.completed_quest_ids.append(LumenfallTypes.QuestId.CROSSING_OF_THREE_VOICES)
	profile.gold_coins += 75
	hud.show_dialogue("Nia", "Whatever we do next, we do it knowing the rifts were made—not born.", 5.2)
	hud.set_objective("See how Hearthmere changed after your answer")
	world.save_checkpoint()


@private
func _examine_aftermath() -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.FOLLOW_GLASS_ROAD
	profile.active_quest_id = LumenfallTypes.QuestId.THE_GLASS_ROAD
	if AdventureInventory.count(profile, LumenfallTypes.ItemId.CROSSING_CHOICE_SHELTER) > 0:
		hud.show_dialogue("Mara", "The shelter-ring holds, but every crystal points west. Something is testing its edge.", 5.2)
	elif AdventureInventory.count(profile, LumenfallTypes.ItemId.CROSSING_CHOICE_BRIDGE) > 0:
		hud.show_dialogue("Orin", "I can feel the bridge breathing through my name. We'll set rules before it learns bad habits.", 5.2)
	else:
		hud.show_dialogue("Forgotten Architect", "You witnessed me once. Find the glass road before they erase me twice.", 5.2)
	hud.set_objective("Follow the new light west of Hearthmere")
	profile.completed_quest_ids.append(LumenfallTypes.QuestId.HEARTHMERE_AFTER_THE_ANSWER)
	world.save_checkpoint()


@private
func _restore_altars() -> void:
	if not is_instance_valid(world.echo_causeway):
		return
	for altar_id: LumenfallTypes.InteractionId in VOICE_ITEMS:
		if AdventureInventory.count(profile, VOICE_ITEMS[altar_id]) > 0:
			world.echo_causeway.awaken_altar(altar_id)


@private
func _voice_count() -> int:
	var count := 0
	for item_id: LumenfallTypes.ItemId in VOICE_ITEMS.values():
		if AdventureInventory.count(profile, item_id) > 0:
			count += 1
	return count


@private
func _update_causeway_objective() -> void:
	hud.set_objective("Awaken the three rescued voices  •  %d / 3" % _voice_count())
