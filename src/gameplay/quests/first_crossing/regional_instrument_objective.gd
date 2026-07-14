class_name RegionalInstrumentObjective
extends Node

const DISCOVERY_ITEMS: Array[ItemCatalog.Id] = [
	ItemCatalog.Id.GLASSWOOD_RESONANCE,
	ItemCatalog.Id.AMBER_ORBIT,
	ItemCatalog.Id.BELLSCAR_ECHO,
]

var world_state: GameWorldState
var hud: GameHud
var world: GameWorld


func configure(state: GameWorldState, game_hud: GameHud, world_root: GameWorld) -> void:
	world_state = state
	hud = game_hud
	world = world_root


func open_map() -> void:
	if world_state.quest_stage == QuestCatalog.Stage.MARK_REGION_DISCOVERY:
		if discovery_count() >= DISCOVERY_ITEMS.size():
			world_state.quest_stage = QuestCatalog.Stage.REPORT_THREE_INSTRUMENTS
			world_state.active_quest_id = QuestCatalog.Id.THREE_INSTRUMENTS_ANSWERED
			hud.show_dialogue("Mara", "All three marks point to the same blank place. Nia needs to see this.", 4.5)
			hud.set_objective("Tell Nia what the three instruments revealed")
			world.persistence.save_checkpoint()
			return
		world_state.quest_stage = QuestCatalog.Stage.CHOOSE_REGION
	var map := world.overlays.open_region_map()
	if not map.region_selected.is_connected(_on_region_selected):
		map.region_selected.connect(_on_region_selected)


func set_travel_objective() -> void:
	match world_state.active_quest_id:
		QuestCatalog.Id.GLASSWOOD_CALL:
			hud.set_objective("Travel north to the Glasswood Shrine")
		QuestCatalog.Id.AMBERFEN_ORBIT:
			hud.set_objective("Travel east to the Amberfen Orrery")
		QuestCatalog.Id.BELLSCAR_WAKE:
			hud.set_objective("Travel south to the Bellscar bell")
		_:
			hud.set_objective("Consult Mara's field map beside the well")


func discover(interactable: WorldInteractable) -> void:
	var expected_id := QuestCatalog.regional_interaction(world_state.active_quest_id)
	if interactable.interaction_id != expected_id:
		return
	var discovery_item := _discovery_item(world_state.active_quest_id)
	if discovery_item == ItemCatalog.Id.NONE:
		return
	Inventory.add(world_state, discovery_item)
	world.soundscape.play_memory()
	world_state.quest_stage = QuestCatalog.Stage.MARK_REGION_DISCOVERY
	var story := _story(world_state.active_quest_id)
	hud.show_dialogue(story.speaker, story.text, story.duration)
	hud.set_objective("Mark the discovery on Mara's field map")
	_pulse(interactable)
	world.persistence.save_checkpoint()


func discovery_count() -> int:
	var total := 0
	for item_id: ItemCatalog.Id in DISCOVERY_ITEMS:
		if Inventory.count(world_state, item_id) > 0:
			total += 1
	return total


@private
func _on_region_selected(region_id: RegionCatalog.Id) -> void:
	world_state.quest_stage = QuestCatalog.Stage.DISCOVER_REGION_INSTRUMENT
	match region_id:
		RegionCatalog.Id.GLASSWOOD:
			world_state.active_quest_id = QuestCatalog.Id.GLASSWOOD_CALL
		RegionCatalog.Id.AMBERFEN:
			world_state.active_quest_id = QuestCatalog.Id.AMBERFEN_ORBIT
		RegionCatalog.Id.BELLSCAR:
			world_state.active_quest_id = QuestCatalog.Id.BELLSCAR_WAKE
	set_travel_objective()
	world.persistence.save_checkpoint()


@private
func _discovery_item(quest_id: QuestCatalog.Id) -> ItemCatalog.Id:
	match quest_id:
		QuestCatalog.Id.GLASSWOOD_CALL:
			return ItemCatalog.Id.GLASSWOOD_RESONANCE
		QuestCatalog.Id.AMBERFEN_ORBIT:
			return ItemCatalog.Id.AMBER_ORBIT
		QuestCatalog.Id.BELLSCAR_WAKE:
			return ItemCatalog.Id.BELLSCAR_ECHO
	return ItemCatalog.Id.NONE


@private
func _story(quest_id: QuestCatalog.Id) -> DialogueLine:
	match quest_id:
		QuestCatalog.Id.GLASSWOOD_CALL:
			return DialogueLine.new("Glasswood Shrine", "Aster was not the first hound. Every guardian here once had a human name.", 6.0)
		QuestCatalog.Id.AMBERFEN_ORBIT:
			return DialogueLine.new("Amberfen Orrery", "The rift is not above the world. It is the shadow cast by a road removed from memory.", 6.0)
		QuestCatalog.Id.BELLSCAR_WAKE:
			return DialogueLine.new("Bellscar Bell", "The bell remembers being rung by someone who has not been born yet.", 6.0)
	return DialogueLine.new()


@private
func _pulse(interactable: WorldInteractable) -> void:
	var landmark_root := interactable.get_parent().get_node_or_null(interactable.name.trim_suffix("Interactable")) as Node3D
	if not is_instance_valid(landmark_root):
		return
	var tween := create_tween()
	tween.tween_property(landmark_root, "scale", Vector3.ONE * 1.08, 0.28).set_trans(Tween.TRANS_BACK)
	tween.tween_property(landmark_root, "scale", Vector3.ONE, 0.75).set_trans(Tween.TRANS_ELASTIC)
