class_name QuestCoordinator
extends Node

var world_state: LumenfallWorldState
var player: WayfarerController
var hud: GameHud
var world: LumenfallWorld
var first_crossing: FirstCrossingQuest
var names_in_wind: NamesInWindQuest
var three_voices: ThreeVoicesQuest


func configure(state: LumenfallWorldState, player_controller: WayfarerController, game_hud: GameHud, world_root: LumenfallWorld) -> void:
	world_state = state
	player = player_controller
	hud = game_hud
	world = world_root


@override
func _ready() -> void:
	first_crossing = FirstCrossingQuest.new()
	first_crossing.configure(world_state, player, hud, world)
	add_child(first_crossing)
	names_in_wind = NamesInWindQuest.new()
	names_in_wind.configure(world_state, player, hud, world)
	add_child(names_in_wind)
	three_voices = ThreeVoicesQuest.new()
	three_voices.configure(world_state, player, hud, world)
	add_child(three_voices)


func handle_interaction(target: Node3D) -> void:
	if world_state.quest_stage >= QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE:
		three_voices.handle_interaction(target)
	elif world_state.quest_stage >= QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS:
		names_in_wind.handle_interaction(target)
	else:
		first_crossing.handle_interaction(target)
		if world_state.quest_stage >= QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS:
			names_in_wind.activate_if_needed()


func activate_three_voices() -> void:
	three_voices.activate_if_needed()


func on_player_rescued() -> void:
	first_crossing.on_player_rescued()
