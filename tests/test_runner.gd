extends SceneTree

var _failures: int = 0
var _suites: int = 0


@override
func _initialize() -> void:
	_run.call_deferred()


@private
func _run() -> void:
	_ensure_input_actions()
	_test_ccl_round_trip()
	_test_enum_domains()
	_test_inventory_rules()
	_test_relative_time_formatter()
	_test_asset_integrity()
	_test_world_storage_and_npc_architecture()
	_test_source_architecture()
	_test_project_invariants()
	await _test_complete_first_crossing()
	if _failures == 0:
		print("LUMENFALL TESTS: %d suites passed" % _suites)
		quit(0)
	else:
		push_error("LUMENFALL TESTS: %d failure(s)" % _failures)
		quit(1)


@private
func _ensure_input_actions() -> void:
	var actions: Array[StringName] = [
		&"move_forward", &"move_back", &"move_left", &"move_right", &"interact",
		&"jump", &"sprint", &"ui_cancel",
	]
	for action: StringName in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)


@private
func _test_ccl_round_trip() -> void:
	_suites += 1
	var original := _make_world_state("round_trip")
	original.display_name = "Juniper"
	original.quest_stage = QuestCatalog.Stage.LISTEN_TO_ASTER
	original.gold_coins = 41
	original.completed_quest_ids.append(QuestCatalog.Id.THE_FIRST_CROSSING)
	var decoded := LumenfallWorldState.deserialize_binary(original.serialize_binary())
	_expect(is_instance_valid(decoded), "CCL world state decodes")
	_expect(decoded.display_name == "Juniper", "CCL preserves traveler name")
	_expect(decoded.quest_stage == QuestCatalog.Stage.LISTEN_TO_ASTER and decoded.gold_coins == 41, "CCL preserves progression and currency")
	_expect(decoded.completed_quest_ids == [QuestCatalog.Id.THE_FIRST_CROSSING], "CCL preserves completed quests")
	var settings := SettingsRepository.defaults()
	settings.mouse_sensitivity = 0.0037
	settings.reduce_motion = true
	var decoded_settings := LumenfallSettings.deserialize_binary(settings.serialize_binary())
	_expect(is_equal_approx(decoded_settings.mouse_sensitivity, 0.0037) and decoded_settings.reduce_motion, "CCL preserves accessibility settings")


@private
func _test_enum_domains() -> void:
	_suites += 1
	_expect(QuestCatalog.Stage.SUMMONED == 0, "Quest stage enum starts at the persisted origin")
	_expect(QuestCatalog.Stage.FOLLOW_GLASS_ROAD == 23, "Quest stage enum preserves the authored campaign order")
	_expect(ModelCatalog.Id.size() == 16, "Every authored model has an asset enum member")
	_expect(CrossingChoiceCatalog.evidence_item(CrossingChoiceCatalog.Id.BRIDGE) == ItemCatalog.Id.CROSSING_CHOICE_BRIDGE, "Narrative choices map to typed inventory evidence")


@private
func _test_inventory_rules() -> void:
	_suites += 1
	var state := _make_world_state("inventory")
	Inventory.add(state, ItemCatalog.Id.RIFTGLASS, 3)
	_expect(Inventory.count(state, ItemCatalog.Id.RIFTGLASS) == 3, "Inventory adds stackable materials")
	_expect(Inventory.remove(state, ItemCatalog.Id.RIFTGLASS, 2), "Inventory spends available materials")
	_expect(not Inventory.remove(state, ItemCatalog.Id.RIFTGLASS, 2), "Inventory rejects overspending")
	Inventory.unlock_recipe(state, RecipeCatalog.Id.LANTERN_LENS)
	Inventory.unlock_recipe(state, RecipeCatalog.Id.LANTERN_LENS)
	_expect(state.unlocked_recipe_ids == [RecipeCatalog.Id.LANTERN_LENS], "Recipe unlocks are idempotent")


@private
func _test_relative_time_formatter() -> void:
	_suites += 1
	var now := 2_000_000_000
	_expect(RelativeTimeFormatter.format_since(now - 20, now) == "20s ago", "Recent play time uses seconds")
	_expect(RelativeTimeFormatter.format_since(now - 20 * 60, now) == "20m ago", "Recent play time uses minutes")
	_expect(RelativeTimeFormatter.format_since(now - 20 * 60 * 60, now) == "20h ago", "Recent play time uses hours")
	_expect(RelativeTimeFormatter.format_since(now - 20 * 24 * 60 * 60, now) == "20d ago", "Recent play time uses days")
	_expect(RelativeTimeFormatter.format_since(now - 20 * 365 * 24 * 60 * 60, now) == "20y ago", "Recent play time uses years")
	_expect(RelativeTimeFormatter.format_since(now + 1, now) == "0s ago", "Future clock drift clamps to the present")


@private
func _test_asset_integrity() -> void:
	_suites += 1
	for asset_id: ModelCatalog.Id in ModelCatalog.Id.values():
		var model := ModelLibrary.instantiate_model(asset_id)
		_expect(is_instance_valid(model), "Model instantiates: %s" % ModelCatalog.file_name(asset_id))
		if is_instance_valid(model):
			model.free()
	var texture := ResourceLoader.load("res://assets/textures/meadow_grass_v1.png", "Texture2D")
	_expect(texture is Texture2D, "Authored meadow texture imports")


@private
func _test_world_storage_and_npc_architecture() -> void:
	_suites += 1
	var state := WorldLibrary.create_world("Architecture Test")
	_expect(FileAccess.file_exists(StoragePaths.world_file(state.world_id)), "World state lives inside its shareable world folder")
	for npc_id: NpcCatalog.Id in NpcCatalog.persistent_ids():
		_expect(FileAccess.file_exists(StoragePaths.npc_file(state.world_id, npc_id)), "NPC owns a separate CCL file: %s" % NpcCatalog.file_stem(npc_id))
	var nia_state := NpcStateRepository.load_state(state.world_id, NpcCatalog.Id.NIA)
	nia_state.mood = NpcCatalog.Mood.HOPEFUL
	nia_state.trust_player = 0.42
	NpcStateRepository.save_state(state.world_id, nia_state)
	var restored_nia := NpcStateRepository.load_state(state.world_id, NpcCatalog.Id.NIA)
	_expect(restored_nia.mood == NpcCatalog.Mood.HOPEFUL and is_equal_approx(restored_nia.trust_player, 0.42), "NPC emotional state round-trips independently")
	var nia := NiaNpc.new()
	var dog := DogNpc.new()
	var wolf := WolfNpc.new()
	var hound := RiftHoundNpc.new()
	_expect(nia is HumanoidNpc and nia is NpcActor, "Named humanoids inherit the NPC base")
	_expect(dog is BeastNpc and dog is AnimalNpc and dog is NpcActor, "Dogs follow the animal/beast inheritance chain")
	_expect(wolf is BeastNpc and hound is BeastNpc, "Wolf and rift hound specialize reusable beast behavior")
	nia.free()
	dog.free()
	wolf.free()
	hound.free()
	WorldLibrary.delete_world(state.world_id)
	_expect(not DirAccess.dir_exists_absolute(StoragePaths.absolute_world_directory(state.world_id)), "Deleting a world removes its complete shareable folder")


@private
func _test_source_architecture() -> void:
	_suites += 1
	var class_pattern := RegEx.new()
	class_pattern.compile("(?m)^class_name\\s+(\\w+)")
	for path: String in _gd_files("res://src"):
		var source := FileAccess.get_file_as_string(path)
		var match_result := class_pattern.search(source)
		if match_result == null:
			continue
		var declared_name := match_result.get_string(1)
		var expected_name := path.get_file().get_basename().to_pascal_case()
		_expect(declared_name == expected_name, "class_name matches filename: %s" % path)
		_expect("LumenfallTypes" not in source, "No global type bucket returns: %s" % path)
	var world_source := FileAccess.get_file_as_string("res://src/world/runtime/lumenfall_world.gd")
	_expect(world_source.count("\n") + 1 < 120, "LumenfallWorld remains a small composition root")
	_expect("match world_state.quest_stage" not in world_source, "Quest policy stays outside LumenfallWorld")


@private
func _gd_files(directory: String) -> Array[String]:
	var result: Array[String] = []
	for file_name: String in DirAccess.get_files_at(directory):
		if file_name.ends_with(".gd"):
			result.append(directory.path_join(file_name))
	for child_directory: String in DirAccess.get_directories_at(directory):
		result.append_array(_gd_files(directory.path_join(child_directory)))
	return result


@private
func _test_project_invariants() -> void:
	_suites += 1
	var product_name := String(ProjectSettings.get_setting("application/config/name", ""))
	_expect(product_name.begins_with("LUMENFALL"), "Project identity is LUMENFALL")
	_expect(ProjectSettings.get_setting("application/run/main_scene", "") != "", "Project has a main scene")
	_expect(ProjectSettings.get_setting("display/window/size/viewport_width", 0) >= 1280, "Viewport meets minimum width")
	_expect(ProjectSettings.get_setting("display/window/size/viewport_height", 0) >= 720, "Viewport meets minimum height")
	_expect(FileAccess.file_exists("res://assets/legal/THIRD_PARTY_NOTICES.txt"), "Third-party notices exist")


@private
func _test_complete_first_crossing() -> void:
	_suites += 1
	var world_id := "automated_quest_%d" % Time.get_ticks_msec()
	var state := _make_world_state(world_id)
	# Begin at the first interaction so the cinematic tween cannot make the test timing-dependent.
	state.quest_stage = QuestCatalog.Stage.WAKE_WAYSTONE
	var world := LumenfallWorld.new()
	world.configure(state)
	root.add_child(world)
	for _frame: int in range(8):
		await process_frame
	_expect(is_instance_valid(world.player), "Quest world creates a controllable third-person player")
	var streamer := world.get_node_or_null("WorldStreamer") as WorldStreamer
	_expect(is_instance_valid(streamer) and streamer.loaded_chunk_count() == 25, "Open world streams a 5x5 chunk neighborhood")
	var quest: FirstCrossingQuest = world.quests.first_crossing
	var nia: NpcActor = world.village.npcs.get(NpcCatalog.Id.NIA) as NpcActor
	var bram: NpcActor = world.village.npcs.get(NpcCatalog.Id.BRAM) as NpcActor
	var mara: NpcActor = world.village.npcs.get(NpcCatalog.Id.MARA) as NpcActor

	state.quest_stage = QuestCatalog.Stage.SUMMONED
	quest.handle_interaction(nia)
	_expect(state.quest_stage == QuestCatalog.Stage.WAKE_WAYSTONE, "Nia advances the arrival quest")
	quest.handle_interaction(world.village.waystone_interactable)
	_expect(state.quest_stage == QuestCatalog.Stage.MEET_MARA, "Waystone awakens and answers the sky")
	quest.handle_interaction(mara)
	_expect(state.quest_stage == QuestCatalog.Stage.GATHER_RIFTGLASS and quest.riftglass.spawned_shards.size() == 3, "Mara starts the three-shard field task")
	_expect(get_nodes_in_group(&"enemies").is_empty(), "Safe opening contains no enemies")

	for shard: RiftglassShard in quest.riftglass.spawned_shards:
		quest.handle_interaction(shard)
	_expect(state.quest_stage == QuestCatalog.Stage.RETURN_SHARDS_TO_BRAM and state.riftglass_pieces == 3, "All unique riftglass pickups complete the collection")
	quest.handle_interaction(bram)
	_expect(state.quest_stage == QuestCatalog.Stage.CRAFT_LANTERN_LENS, "Bram directs the player to the physical workbench")
	quest.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world.overlays.workshop), "Workbench opens the in-world crafting interface")
	world.overlays.workshop.craft_lantern_lens()
	_expect(state.quest_stage == QuestCatalog.Stage.SHOW_LENS_TO_MARA, "Forging the Lantern Lens advances the quest")
	_expect(Inventory.count(state, ItemCatalog.Id.LANTERN_LENS) == 1, "Crafting consumes shards and grants one lens")
	world.overlays.workshop.close_workshop()
	quest.handle_interaction(mara)
	_expect(state.quest_stage == QuestCatalog.Stage.REACH_EASTERN_CROSSING, "Mara opens the eastern expedition only after preparation")
	quest.handle_interaction(world.village.eastern_crossing)
	_expect(state.quest_stage == QuestCatalog.Stage.DEFEND_LANTERN_ROAD and is_instance_valid(quest.first_hunt.hound), "Crossing the lantern boundary starts the first combat event")
	quest.first_hunt.hound.take_damage(1000.0)
	_expect(state.quest_stage == QuestCatalog.Stage.LISTEN_TO_ASTER and is_instance_valid(quest.first_hunt.memory), "Defeating the hound reveals story through an in-world memory")
	quest.handle_interaction(quest.first_hunt.memory)
	_expect(state.quest_stage == QuestCatalog.Stage.REPORT_ASTER and Inventory.count(state, ItemCatalog.Id.ASTER_MEMORY) == 1, "Listening preserves Aster's memory")
	quest.handle_interaction(nia)
	_expect(state.quest_stage == QuestCatalog.Stage.CHOOSE_REGION and state.gold_coins == 18, "Returning to Nia completes the chapter and pays wages")
	_expect(QuestCatalog.Id.THE_FIRST_CROSSING in state.completed_quest_ids, "First Crossing is recorded as complete")

	var region_routes: Array[RegionCatalog.Id] = [RegionCatalog.Id.GLASSWOOD, RegionCatalog.Id.AMBERFEN, RegionCatalog.Id.BELLSCAR]
	var region_targets: Array[InteractionCatalog.Id] = [InteractionCatalog.Id.GLASSWOOD_SHRINE, InteractionCatalog.Id.AMBERFEN_ORRERY, InteractionCatalog.Id.BELLSCAR_BELL]
	for route_index: int in range(region_routes.size()):
		quest.handle_interaction(world.village.field_map)
		_expect(is_instance_valid(world.overlays.region_map), "Field map opens for regional lead %d" % route_index)
		world.overlays.region_map.choose_region(region_routes[route_index])
		_expect(state.quest_stage == QuestCatalog.Stage.DISCOVER_REGION_INSTRUMENT, "Choosing a map lead starts regional travel")
		quest.handle_interaction(world.region_landmarks.landmarks[region_targets[route_index]])
		_expect(state.quest_stage == QuestCatalog.Stage.MARK_REGION_DISCOVERY, "Regional instrument records an in-world discovery")
		quest.handle_interaction(world.village.field_map)
	if is_instance_valid(world.overlays.region_map):
		world.overlays.region_map.close_map()
	_expect(state.quest_stage == QuestCatalog.Stage.REPORT_THREE_INSTRUMENTS, "All three regional discoveries converge into the next chapter")
	quest.handle_interaction(nia)
	_expect(state.quest_stage == QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS and state.gold_coins == 58, "Three Instruments chapter completes with human-paid wages")
	_expect(QuestCatalog.Id.THE_THREE_INSTRUMENTS in state.completed_quest_ids, "Regional chapter is recorded as complete")
	world.quests.names_in_wind.activate_if_needed()
	_expect(world.quests.names_in_wind.missing_people.size() == 3, "Names in the Wind spawns three distinct missing villagers")
	for missing_id: NpcCatalog.Id in [NpcCatalog.Id.IVEN, NpcCatalog.Id.SOLA, NpcCatalog.Id.ORIN]:
		world.quests.names_in_wind.handle_interaction(world.quests.names_in_wind.missing_people[missing_id])
	_expect(state.quest_stage == QuestCatalog.Stage.RETURN_THREE_NAMES and Inventory.count(state, ItemCatalog.Id.MEMORY_THREAD) == 3, "Rescuing all three names yields three story-bound threads")
	world.quests.names_in_wind.handle_interaction(nia)
	_expect(state.quest_stage == QuestCatalog.Stage.CRAFT_MEMORY_COMPASS and Inventory.has_recipe(state, RecipeCatalog.Id.MEMORY_COMPASS), "Nia unlocks the Memory Compass recipe")
	world.quests.names_in_wind.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world.overlays.workshop), "Names chapter returns to the physical workshop")
	world.overlays.workshop.craft_memory_compass()
	_expect(state.quest_stage == QuestCatalog.Stage.BRING_COMPASS_TO_WAYSTONE and Inventory.count(state, ItemCatalog.Id.MEMORY_COMPASS) == 1, "Three rescued names forge into the Memory Compass")
	world.overlays.workshop.close_workshop()
	world.quests.three_voices.handle_interaction(world.village.waystone_interactable)
	_expect(state.quest_stage == QuestCatalog.Stage.AWAKEN_CAUSEWAY_VOICES and is_instance_valid(world.travel.echo_causeway), "Memory Compass opens the playable Echo Causeway")
	for altar_id: InteractionCatalog.Id in [InteractionCatalog.Id.IVEN_VOICE, InteractionCatalog.Id.SOLA_VOICE, InteractionCatalog.Id.ORIN_VOICE]:
		world.quests.three_voices.handle_interaction(world.travel.echo_causeway.altars[altar_id])
	_expect(state.quest_stage == QuestCatalog.Stage.ANSWER_CAUSEWAY_GATE, "All three rescued voices awaken the central gate")
	world.quests.three_voices.handle_interaction(world.travel.echo_causeway.crossing_gate)
	_expect(is_instance_valid(world.quests.three_voices._choice_ui), "Causeway presents a consequential three-way answer")
	world.quests.three_voices._choice_ui.make_choice(CrossingChoiceCatalog.Id.BRIDGE)
	_expect(state.quest_stage == QuestCatalog.Stage.REPORT_CROSSING_ANSWER and Inventory.count(state, ItemCatalog.Id.CROSSING_CHOICE_BRIDGE) == 1, "Crossing choice persists in the world state")
	world.quests.three_voices.handle_interaction(nia)
	_expect(state.quest_stage == QuestCatalog.Stage.EXAMINE_CROSSING_AFTERMATH and state.gold_coins == 169, "Crossing of Three Voices resolves and pays the final chapter wages")
	_expect(QuestCatalog.Id.CROSSING_OF_THREE_VOICES in state.completed_quest_ids, "Causeway chapter is recorded as complete")
	_expect(is_instance_valid(world.village.crossing_aftermath), "Crossing choice creates a physical change beside the Waystone")
	world.quests.three_voices.handle_interaction(world.village.crossing_aftermath)
	_expect(state.quest_stage == QuestCatalog.Stage.FOLLOW_GLASS_ROAD and state.active_quest_id == QuestCatalog.Id.THE_GLASS_ROAD, "Examining the changed village opens the Glass Road chapter")

	world.queue_free()
	for _cleanup_frame: int in range(12):
		await process_frame
	WorldLibrary.delete_world(world_id)


@private
func _make_world_state(world_id: String) -> LumenfallWorldState:
	var state := LumenfallWorldState.new()
	state.schema_version = 1
	state.world_id = world_id
	state.display_name = "Automated Wayfarer"
	state.player_y = 0.1
	state.player_z = -11.2
	state.quest_stage = QuestCatalog.Stage.SUMMONED
	state.active_quest_id = QuestCatalog.Id.THE_WRONG_STAR
	state.completed_quest_ids = [] as Array[int]
	state.inventory_item_ids = [] as Array[int]
	state.inventory_item_counts = [] as Array[int]
	state.unlocked_recipe_ids = [] as Array[int]
	state.maximum_health = 100.0
	state.current_health = 100.0
	return state


@private
func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("TEST FAILURE: %s" % message)
