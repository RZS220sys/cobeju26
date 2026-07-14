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
	_test_forward_compatible_save()
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
	original.quest_stage = 9
	original.gold_coins = 41
	original.completed_quest_ids.append("first_crossing")
	var decoded := LumenfallSaveData.deserialize_binary(original.serialize_binary())
	_expect(is_instance_valid(decoded), "CCL profile decodes")
	_expect(decoded.display_name == "Juniper", "CCL preserves traveler name")
	_expect(decoded.quest_stage == 9 and decoded.gold_coins == 41, "CCL preserves progression and currency")
	_expect(decoded.completed_quest_ids == ["first_crossing"], "CCL preserves completed quests")
	var settings := AdventureSettingsStore.defaults()
	settings.mouse_sensitivity = 0.0037
	settings.reduce_motion = true
	var decoded_settings := LumenfallSettings.deserialize_binary(settings.serialize_binary())
	_expect(is_equal_approx(decoded_settings.mouse_sensitivity, 0.0037) and decoded_settings.reduce_motion, "CCL preserves accessibility settings")


@private
func _test_forward_compatible_save() -> void:
	_suites += 1
	var original := _make_profile("forward")
	original.quest_stage = 4
	var bytes := original.serialize_binary()
	var old_version_bytes := bytes.slice(0, maxi(1, bytes.size() - 16))
	var decoded := LumenfallSaveData.deserialize_binary(old_version_bytes)
	_expect(is_instance_valid(decoded), "Older truncated profile remains readable")
	_expect(decoded.quest_stage == 4, "Early save fields survive appended-field truncation")


@private
func _test_inventory_rules() -> void:
	_suites += 1
	var profile := _make_profile("inventory")
	AdventureInventory.add(profile, "riftglass", 3)
	_expect(AdventureInventory.count(profile, "riftglass") == 3, "Inventory adds stackable materials")
	_expect(AdventureInventory.remove(profile, "riftglass", 2), "Inventory spends available materials")
	_expect(not AdventureInventory.remove(profile, "riftglass", 2), "Inventory rejects overspending")
	AdventureInventory.unlock_recipe(profile, "lantern_lens")
	AdventureInventory.unlock_recipe(profile, "lantern_lens")
	_expect(profile.unlocked_recipe_ids == ["lantern_lens"], "Recipe unlocks are idempotent")


@private
func _test_asset_integrity() -> void:
	_suites += 1
	var asset_names: Array[String] = [
		"wayfarer", "nia", "bram", "mara", "pip", "cottage_blue", "cottage_red",
		"waystone", "village_props", "oak", "pine", "rift_hound", "lantern_post",
		"iven", "sola", "orin",
	]
	for asset_name: String in asset_names:
		var model := AdventureAssetLibrary.instantiate_model(asset_name)
		_expect(is_instance_valid(model), "Adventure model instantiates: %s" % asset_name)
		if is_instance_valid(model):
			model.free()
	var texture := ResourceLoader.load("res://assets/adventure/textures/meadow_grass_v1.png", "Texture2D")
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
	profile.quest_stage = 1
	var world := LumenfallAdventureWorld.new()
	world.configure(profile)
	root.add_child(world)
	for _frame: int in range(8):
		await process_frame
	_expect(is_instance_valid(world.player), "Quest world creates a controllable third-person player")
	var streamer := world.get_node_or_null("WorldStreamer") as AdventureWorldStreamer
	_expect(is_instance_valid(streamer) and streamer.loaded_chunk_count() == 25, "Open world streams a 5x5 chunk neighborhood")
	var quest: FirstCrossingQuest = world._quest
	var nia: AdventureNpc = world.village.npcs.get(&"nia") as AdventureNpc
	var bram: AdventureNpc = world.village.npcs.get(&"bram") as AdventureNpc
	var mara: AdventureNpc = world.village.npcs.get(&"mara") as AdventureNpc

	profile.quest_stage = 0
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == 1, "Nia advances the arrival quest")
	quest.handle_interaction(world.village.waystone_interactable)
	_expect(profile.quest_stage == 2, "Waystone awakens and answers the sky")
	quest.handle_interaction(mara)
	_expect(profile.quest_stage == 3 and quest._spawned_shards.size() == 3, "Mara starts the three-shard field task")
	_expect(get_nodes_in_group(&"adventure_enemies").is_empty(), "Safe opening contains no enemies")

	for shard: AdventureRiftglassShard in quest._spawned_shards:
		quest.handle_interaction(shard)
	_expect(profile.quest_stage == 4 and profile.riftglass_pieces == 3, "All unique riftglass pickups complete the collection")
	quest.handle_interaction(bram)
	_expect(profile.quest_stage == 5, "Bram directs the player to the physical workbench")
	quest.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world._workshop), "Workbench opens the in-world crafting interface")
	world._workshop.craft_lantern_lens()
	_expect(profile.quest_stage == 6, "Forging the Lantern Lens advances the quest")
	_expect(AdventureInventory.count(profile, "lantern_lens") == 1, "Crafting consumes shards and grants one lens")
	world._workshop.close_workshop()
	quest.handle_interaction(mara)
	_expect(profile.quest_stage == 7, "Mara opens the eastern expedition only after preparation")
	quest.handle_interaction(world.village.eastern_crossing)
	_expect(profile.quest_stage == 8 and is_instance_valid(quest._first_hound), "Crossing the lantern boundary starts the first combat event")
	quest._first_hound.take_damage(1000.0)
	_expect(profile.quest_stage == 9 and is_instance_valid(quest._hound_memory), "Defeating the hound reveals story through an in-world memory")
	quest.handle_interaction(quest._hound_memory)
	_expect(profile.quest_stage == 10 and AdventureInventory.count(profile, "aster_memory") == 1, "Listening preserves Aster's memory")
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == 11 and profile.gold_coins == 18, "Returning to Nia completes the chapter and pays wages")
	_expect("the_first_crossing" in profile.completed_quest_ids, "First Crossing is recorded as complete")

	var region_routes: Array[StringName] = [&"glasswood", &"amberfen", &"bellscar"]
	var region_targets: Array[StringName] = [&"glasswood_shrine", &"amberfen_orrery", &"bellscar_bell"]
	for route_index: int in range(region_routes.size()):
		quest.handle_interaction(world.village.field_map)
		_expect(is_instance_valid(world._region_map), "Field map opens for regional lead %d" % route_index)
		world._region_map.choose_region(region_routes[route_index])
		_expect(profile.quest_stage == 12, "Choosing a map lead starts regional travel")
		quest.handle_interaction(world.region_landmarks.landmarks[region_targets[route_index]])
		_expect(profile.quest_stage == 13, "Regional instrument records an in-world discovery")
		quest.handle_interaction(world.village.field_map)
	if is_instance_valid(world._region_map):
		world._region_map.close_map()
	_expect(profile.quest_stage == 14, "All three regional discoveries converge into the next chapter")
	quest.handle_interaction(nia)
	_expect(profile.quest_stage == 15 and profile.gold_coins == 58, "Three Instruments chapter completes with human-paid wages")
	_expect("the_three_instruments" in profile.completed_quest_ids, "Regional chapter is recorded as complete")
	world._names_quest.activate_if_needed()
	_expect(world._names_quest.missing_people.size() == 3, "Names in the Wind spawns three distinct missing villagers")
	for missing_id: StringName in [&"iven", &"sola", &"orin"] as Array[StringName]:
		world._names_quest.handle_interaction(world._names_quest.missing_people[missing_id])
	_expect(profile.quest_stage == 16 and AdventureInventory.count(profile, "memory_thread") == 3, "Rescuing all three names yields three story-bound threads")
	world._names_quest.handle_interaction(nia)
	_expect(profile.quest_stage == 17 and AdventureInventory.has_recipe(profile, "memory_compass"), "Nia unlocks the Memory Compass recipe")
	world._names_quest.handle_interaction(world.village.workshop_interactable)
	_expect(is_instance_valid(world._workshop), "Names chapter returns to the physical workshop")
	world._workshop.craft_memory_compass()
	_expect(profile.quest_stage == 18 and AdventureInventory.count(profile, "memory_compass") == 1, "Three rescued names forge into the Memory Compass")
	world._workshop.close_workshop()
	world._voices_quest.handle_interaction(world.village.waystone_interactable)
	_expect(profile.quest_stage == 19 and is_instance_valid(world.echo_causeway), "Memory Compass opens the playable Echo Causeway")
	for altar_id: StringName in [&"iven_voice", &"sola_voice", &"orin_voice"] as Array[StringName]:
		world._voices_quest.handle_interaction(world.echo_causeway.altars[altar_id])
	_expect(profile.quest_stage == 20, "All three rescued voices awaken the central gate")
	world._voices_quest.handle_interaction(world.echo_causeway.crossing_gate)
	_expect(is_instance_valid(world._voices_quest._choice_ui), "Causeway presents a consequential three-way answer")
	world._voices_quest._choice_ui.make_choice(&"bridge")
	_expect(profile.quest_stage == 21 and AdventureInventory.count(profile, "crossing_choice_bridge") == 1, "Crossing choice persists in the traveler profile")
	world._voices_quest.handle_interaction(nia)
	_expect(profile.quest_stage == 22 and profile.gold_coins == 169, "Crossing of Three Voices resolves and pays the final chapter wages")
	_expect("crossing_of_three_voices" in profile.completed_quest_ids, "Causeway chapter is recorded as complete")

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
	profile.active_quest_id = "the_wrong_star"
	profile.completed_quest_ids = [] as Array[String]
	profile.inventory_item_ids = [] as Array[String]
	profile.inventory_item_counts = [] as Array[int]
	profile.unlocked_recipe_ids = [] as Array[String]
	profile.maximum_health = 100.0
	profile.current_health = 100.0
	return profile


@private
func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("TEST FAILURE: %s" % message)
