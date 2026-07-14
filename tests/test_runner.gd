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
	_test_asset_integrity()
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
		&"adventure_jump", &"adventure_sprint", &"ui_cancel",
	]
	for action: StringName in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)


@private
func _test_ccl_round_trip() -> void:
	_suites += 1
	var original := _make_profile("round_trip")
	original.display_name = "Juniper"
	original.quest_stage = LumenfallTypes.QuestStage.LISTEN_TO_ASTER
	original.gold_coins = 41
	original.completed_quest_ids.append(LumenfallTypes.QuestId.THE_FIRST_CROSSING)
	var decoded := LumenfallSaveData.deserialize_binary(original.serialize_binary())
	_expect(is_instance_valid(decoded), "CCL profile decodes")
	_expect(decoded.display_name == "Juniper", "CCL preserves traveler name")
	_expect(decoded.quest_stage == LumenfallTypes.QuestStage.LISTEN_TO_ASTER and decoded.gold_coins == 41, "CCL preserves progression and currency")
	_expect(decoded.completed_quest_ids == [LumenfallTypes.QuestId.THE_FIRST_CROSSING], "CCL preserves completed quests")
	var settings := AdventureSettingsStore.defaults()
	settings.mouse_sensitivity = 0.0037
	settings.reduce_motion = true
	var decoded_settings := LumenfallSettings.deserialize_binary(settings.serialize_binary())
	_expect(is_equal_approx(decoded_settings.mouse_sensitivity, 0.0037) and decoded_settings.reduce_motion, "CCL preserves accessibility settings")


@private
func _test_enum_domains() -> void:
	_suites += 1
	_expect(LumenfallTypes.QuestStage.SUMMONED == 0, "Quest stage enum starts at the persisted origin")
	_expect(LumenfallTypes.QuestStage.FOLLOW_GLASS_ROAD == 23, "Quest stage enum preserves the authored campaign order")
	_expect(LumenfallTypes.AssetId.size() == 16, "Every authored model has an asset enum member")
	_expect(LumenfallTypes.crossing_choice_item(LumenfallTypes.CrossingChoice.BRIDGE) == LumenfallTypes.ItemId.CROSSING_CHOICE_BRIDGE, "Narrative choices map to typed inventory evidence")


@private
func _test_inventory_rules() -> void:
	_suites += 1
	var profile := _make_profile("inventory")
	AdventureInventory.add(profile, LumenfallTypes.ItemId.RIFTGLASS, 3)
	_expect(AdventureInventory.count(profile, LumenfallTypes.ItemId.RIFTGLASS) == 3, "Inventory adds stackable materials")
	_expect(AdventureInventory.remove(profile, LumenfallTypes.ItemId.RIFTGLASS, 2), "Inventory spends available materials")
	_expect(not AdventureInventory.remove(profile, LumenfallTypes.ItemId.RIFTGLASS, 2), "Inventory rejects overspending")
	AdventureInventory.unlock_recipe(profile, LumenfallTypes.RecipeId.LANTERN_LENS)
	AdventureInventory.unlock_recipe(profile, LumenfallTypes.RecipeId.LANTERN_LENS)
	_expect(profile.unlocked_recipe_ids == [LumenfallTypes.RecipeId.LANTERN_LENS], "Recipe unlocks are idempotent")


@private
func _test_asset_integrity() -> void:
	_suites += 1
	for asset_id: LumenfallTypes.AssetId in LumenfallTypes.AssetId.values():
		var model := AdventureAssetLibrary.instantiate_model(asset_id)
		_expect(is_instance_valid(model), "Adventure model instantiates: %s" % LumenfallTypes.asset_file_name(asset_id))
		if is_instance_valid(model):
			model.free()
	var texture := ResourceLoader.load("res://assets/textures/meadow_grass_v1.png", "Texture2D")
	_expect(texture is Texture2D, "Authored meadow texture imports")


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
	var profile_id := "automated_quest_%d" % Time.get_ticks_msec()
	var profile := _make_profile(profile_id)
	# Begin at the first interaction so the cinematic tween cannot make the test timing-dependent.
	profile.quest_stage = LumenfallTypes.QuestStage.WAKE_WAYSTONE
	var world := LumenfallAdventureWorld.new()
	world.configure(profile)
	root.add_child(world)
	for _frame: int in range(8):
		await process_frame
	_expect(is_instance_valid(world.player), "Quest world creates a controllable third-person player")
	var streamer := world.get_node_or_null("WorldStreamer") as AdventureWorldStreamer
	_expect(is_instance_valid(streamer) and streamer.loaded_chunk_count() == 25, "Open world streams a 5x5 chunk neighborhood")
	var quest: FirstCrossingQuest = world._quest
	var nia: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.NIA) as AdventureNpc
	var bram: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.BRAM) as AdventureNpc
	var mara: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.MARA) as AdventureNpc

	profile.quest_stage = LumenfallTypes.QuestStage.SUMMONED
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.WAKE_WAYSTONE, "Nia advances the arrival quest")
	quest.handle_interaction(world.village.waystone_interactable)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.MEET_MARA, "Waystone awakens and answers the sky")
	quest.handle_interaction(mara)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.GATHER_RIFTGLASS and quest._spawned_shards.size() == 3, "Mara starts the three-shard field task")
	_expect(get_nodes_in_group(&"adventure_enemies").is_empty(), "Safe opening contains no enemies")

	for shard: AdventureRiftglassShard in quest._spawned_shards:
		quest.handle_interaction(shard)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.RETURN_SHARDS_TO_BRAM and profile.riftglass_pieces == 3, "All unique riftglass pickups complete the collection")
	quest.handle_interaction(bram)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.CRAFT_LANTERN_LENS, "Bram directs the player to the physical workbench")
	quest.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world._workshop), "Workbench opens the in-world crafting interface")
	world._workshop.craft_lantern_lens()
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.SHOW_LENS_TO_MARA, "Forging the Lantern Lens advances the quest")
	_expect(AdventureInventory.count(profile, LumenfallTypes.ItemId.LANTERN_LENS) == 1, "Crafting consumes shards and grants one lens")
	world._workshop.close_workshop()
	quest.handle_interaction(mara)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.REACH_EASTERN_CROSSING, "Mara opens the eastern expedition only after preparation")
	quest.handle_interaction(world.village.eastern_crossing)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.DEFEND_LANTERN_ROAD and is_instance_valid(quest._first_hound), "Crossing the lantern boundary starts the first combat event")
	quest._first_hound.take_damage(1000.0)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.LISTEN_TO_ASTER and is_instance_valid(quest._hound_memory), "Defeating the hound reveals story through an in-world memory")
	quest.handle_interaction(quest._hound_memory)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.REPORT_ASTER and AdventureInventory.count(profile, LumenfallTypes.ItemId.ASTER_MEMORY) == 1, "Listening preserves Aster's memory")
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.CHOOSE_REGION and profile.gold_coins == 18, "Returning to Nia completes the chapter and pays wages")
	_expect(LumenfallTypes.QuestId.THE_FIRST_CROSSING in profile.completed_quest_ids, "First Crossing is recorded as complete")

	var region_routes: Array[LumenfallTypes.RegionId] = [LumenfallTypes.RegionId.GLASSWOOD, LumenfallTypes.RegionId.AMBERFEN, LumenfallTypes.RegionId.BELLSCAR]
	var region_targets: Array[LumenfallTypes.InteractionId] = [LumenfallTypes.InteractionId.GLASSWOOD_SHRINE, LumenfallTypes.InteractionId.AMBERFEN_ORRERY, LumenfallTypes.InteractionId.BELLSCAR_BELL]
	for route_index: int in range(region_routes.size()):
		quest.handle_interaction(world.village.field_map)
		_expect(is_instance_valid(world._region_map), "Field map opens for regional lead %d" % route_index)
		world._region_map.choose_region(region_routes[route_index])
		_expect(profile.quest_stage == LumenfallTypes.QuestStage.DISCOVER_REGION_INSTRUMENT, "Choosing a map lead starts regional travel")
		quest.handle_interaction(world.region_landmarks.landmarks[region_targets[route_index]])
		_expect(profile.quest_stage == LumenfallTypes.QuestStage.MARK_REGION_DISCOVERY, "Regional instrument records an in-world discovery")
		quest.handle_interaction(world.village.field_map)
	if is_instance_valid(world._region_map):
		world._region_map.close_map()
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.REPORT_THREE_INSTRUMENTS, "All three regional discoveries converge into the next chapter")
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.RESCUE_MISSING_VILLAGERS and profile.gold_coins == 58, "Three Instruments chapter completes with human-paid wages")
	_expect(LumenfallTypes.QuestId.THE_THREE_INSTRUMENTS in profile.completed_quest_ids, "Regional chapter is recorded as complete")
	world._names_quest.activate_if_needed()
	_expect(world._names_quest.missing_people.size() == 3, "Names in the Wind spawns three distinct missing villagers")
	for missing_id: LumenfallTypes.NpcId in [LumenfallTypes.NpcId.IVEN, LumenfallTypes.NpcId.SOLA, LumenfallTypes.NpcId.ORIN]:
		world._names_quest.handle_interaction(world._names_quest.missing_people[missing_id])
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.RETURN_THREE_NAMES and AdventureInventory.count(profile, LumenfallTypes.ItemId.MEMORY_THREAD) == 3, "Rescuing all three names yields three story-bound threads")
	world._names_quest.handle_interaction(nia)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.CRAFT_MEMORY_COMPASS and AdventureInventory.has_recipe(profile, LumenfallTypes.RecipeId.MEMORY_COMPASS), "Nia unlocks the Memory Compass recipe")
	world._names_quest.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world._workshop), "Names chapter returns to the physical workshop")
	world._workshop.craft_memory_compass()
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.BRING_COMPASS_TO_WAYSTONE and AdventureInventory.count(profile, LumenfallTypes.ItemId.MEMORY_COMPASS) == 1, "Three rescued names forge into the Memory Compass")
	world._workshop.close_workshop()
	world._voices_quest.handle_interaction(world.village.waystone_interactable)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.AWAKEN_CAUSEWAY_VOICES and is_instance_valid(world.echo_causeway), "Memory Compass opens the playable Echo Causeway")
	for altar_id: LumenfallTypes.InteractionId in [LumenfallTypes.InteractionId.IVEN_VOICE, LumenfallTypes.InteractionId.SOLA_VOICE, LumenfallTypes.InteractionId.ORIN_VOICE]:
		world._voices_quest.handle_interaction(world.echo_causeway.altars[altar_id])
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.ANSWER_CAUSEWAY_GATE, "All three rescued voices awaken the central gate")
	world._voices_quest.handle_interaction(world.echo_causeway.crossing_gate)
	_expect(is_instance_valid(world._voices_quest._choice_ui), "Causeway presents a consequential three-way answer")
	world._voices_quest._choice_ui.make_choice(LumenfallTypes.CrossingChoice.BRIDGE)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.REPORT_CROSSING_ANSWER and AdventureInventory.count(profile, LumenfallTypes.ItemId.CROSSING_CHOICE_BRIDGE) == 1, "Crossing choice persists in the traveler profile")
	world._voices_quest.handle_interaction(nia)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.EXAMINE_CROSSING_AFTERMATH and profile.gold_coins == 169, "Crossing of Three Voices resolves and pays the final chapter wages")
	_expect(LumenfallTypes.QuestId.CROSSING_OF_THREE_VOICES in profile.completed_quest_ids, "Causeway chapter is recorded as complete")
	_expect(is_instance_valid(world.village.crossing_aftermath), "Crossing choice creates a physical change beside the Waystone")
	world._voices_quest.handle_interaction(world.village.crossing_aftermath)
	_expect(profile.quest_stage == LumenfallTypes.QuestStage.FOLLOW_GLASS_ROAD and profile.active_quest_id == LumenfallTypes.QuestId.THE_GLASS_ROAD, "Examining the changed village opens the Glass Road chapter")

	world.queue_free()
	for _cleanup_frame: int in range(4):
		await process_frame
	AdventureProfileStore.delete_profile(profile_id)


@private
func _make_profile(profile_id: String) -> LumenfallSaveData:
	var profile := LumenfallSaveData.new()
	profile.schema_version = 1
	profile.profile_id = profile_id
	profile.display_name = "Automated Wayfarer"
	profile.player_y = 0.1
	profile.player_z = -11.2
	profile.quest_stage = LumenfallTypes.QuestStage.SUMMONED
	profile.active_quest_id = LumenfallTypes.QuestId.THE_WRONG_STAR
	profile.completed_quest_ids = [] as Array[int]
	profile.inventory_item_ids = [] as Array[int]
	profile.inventory_item_counts = [] as Array[int]
	profile.unlocked_recipe_ids = [] as Array[int]
	profile.maximum_health = 100.0
	profile.current_health = 100.0
	return profile


@private
func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("TEST FAILURE: %s" % message)
